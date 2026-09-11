$ErrorActionPreference = 'Stop'

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$testBin = Join-Path $repoRoot '.qa-test-bin'
$tempRoot = if ($env:RUNNER_TEMP) { $env:RUNNER_TEMP } else { [System.IO.Path]::GetTempPath() }
$dockerLog = Join-Path $tempRoot ("monitor-docker-calls-{0}.log" -f ([guid]::NewGuid().ToString('N')))
$originalPath = $env:PATH

function Invoke-MonitorScenario {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][int]$DockerExit,
        [Parameter(Mandatory = $true)][string]$DockerOutput,
        [Parameter(Mandatory = $true)][int]$CurlExit,
        [Parameter(Mandatory = $true)][bool]$EnableTelegram,
        [Parameter(Mandatory = $true)][int]$ExpectedExit
    )

    $env:MOCK_DOCKER_EXIT = "$DockerExit"
    $env:MOCK_DOCKER_OUTPUT = $DockerOutput
    $env:MOCK_CURL_EXIT = "$CurlExit"
    $env:BUILD_NUMBER = 'contract-test'
    $env:RUN_TOKEN = 'contract'
    $env:DB_CONTAINER = 'qa-contract-postgres'

    if ($EnableTelegram) {
        $env:TOKEN = 'test-token'
        $env:CHAT_ID = 'test-chat'
    }
    else {
        Remove-Item Env:TOKEN -ErrorAction SilentlyContinue
        Remove-Item Env:CHAT_ID -ErrorAction SilentlyContinue
    }

    & cmd.exe /d /c (Join-Path $repoRoot 'monitor.bat')
    $actualExit = $LASTEXITCODE
    if ($actualExit -ne $ExpectedExit) {
        throw "Scenario '$Name' expected exit $ExpectedExit but got $actualExit"
    }

    Write-Host "PASS: $Name -> exit $actualExit"
}

try {
    New-Item -ItemType Directory -Force -Path $testBin | Out-Null

    @'
@echo off
if defined MOCK_DOCKER_LOG echo %*>>"%MOCK_DOCKER_LOG%"
if defined MOCK_DOCKER_OUTPUT echo %MOCK_DOCKER_OUTPUT%
exit /b %MOCK_DOCKER_EXIT%
'@ | Set-Content -Encoding ascii (Join-Path $testBin 'docker.cmd')

    @'
@echo off
exit /b %MOCK_CURL_EXIT%
'@ | Set-Content -Encoding ascii (Join-Path $testBin 'curl.cmd')

    $env:PATH = "$testBin;$originalPath"
    $env:MOCK_DOCKER_LOG = $dockerLog

    $expectedStatus = 'Build #contract-test - OK [contract]'
    Remove-Item -LiteralPath $dockerLog -ErrorAction SilentlyContinue

    Invoke-MonitorScenario `
        -Name 'database-success-without-telegram' `
        -DockerExit 0 `
        -DockerOutput $expectedStatus `
        -CurlExit 0 `
        -EnableTelegram $false `
        -ExpectedExit 0

    $dockerCalls = Get-Content -LiteralPath $dockerLog -Raw
    $expectedReadBackFilter = "WHERE status = '$expectedStatus'"
    if (-not $dockerCalls.Contains($expectedReadBackFilter)) {
        throw "Windows monitor did not query its exact per-run marker. Expected docker call to contain: $expectedReadBackFilter"
    }
    Write-Host 'PASS: read-back query targets the exact per-run marker'

    Invoke-MonitorScenario `
        -Name 'database-success-notification-failure' `
        -DockerExit 0 `
        -DockerOutput $expectedStatus `
        -CurlExit 1 `
        -EnableTelegram $true `
        -ExpectedExit 0

    Invoke-MonitorScenario `
        -Name 'database-readback-mismatch' `
        -DockerExit 0 `
        -DockerOutput 'unexpected persisted value' `
        -CurlExit 0 `
        -EnableTelegram $false `
        -ExpectedExit 1

    Invoke-MonitorScenario `
        -Name 'database-failure-notification-failure' `
        -DockerExit 1 `
        -DockerOutput 'unused' `
        -CurlExit 1 `
        -EnableTelegram $true `
        -ExpectedExit 1

    Write-Host 'Windows monitor contract: all scenarios passed.'
}
finally {
    $env:PATH = $originalPath
    Remove-Item -LiteralPath $dockerLog -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $testBin -Recurse -Force -ErrorAction SilentlyContinue

    foreach ($name in @(
        'MOCK_DOCKER_LOG',
        'MOCK_DOCKER_EXIT',
        'MOCK_DOCKER_OUTPUT',
        'MOCK_CURL_EXIT',
        'BUILD_NUMBER',
        'RUN_TOKEN',
        'DB_CONTAINER',
        'TOKEN',
        'CHAT_ID'
    )) {
        Remove-Item "Env:$name" -ErrorAction SilentlyContinue
    }
}

# The final scenario intentionally returns exit 1 from monitor.bat. Reset the
# process exit code only after every assertion above has passed; uncaught
# assertion errors still propagate as a failing PowerShell process.
exit 0
