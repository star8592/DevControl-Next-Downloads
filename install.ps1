# DevControl Next Windows x64 preview bootstrap, per-user. PowerShell 5.1+.
# Download from a PUBLIC binary-only release, check SHA-256, then use the
# dedicated Next installer. Never modify DevControl3-Agent or old state.
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$base='https://github.com/star8592/DevControl-Next-Downloads/releases/download/v0.1.0-preview.1'
$name='devcontrol-next-agent-windows-x64.zip'
$work=Join-Path $env:TEMP ('DevControlNext-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $work | Out-Null
try {
    $archive=Join-Path $work $name
    Invoke-WebRequest -UseBasicParsing -Uri "$base/$name" -OutFile $archive
    $digestText=(Invoke-WebRequest -UseBasicParsing -Uri "$base/$name.sha256").Content
    if ($digestText -is [byte[]]) { $digestText=[Text.Encoding]::UTF8.GetString($digestText) }
    $match=[regex]::Match([string]$digestText,'^([a-fA-F0-9]{64})  devcontrol-next-agent-windows-x64\.zip')
    if (-not $match.Success) {throw 'Invalid Next release SHA-256 manifest.'}
    $actual=(Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
    if ($actual -ine $match.Groups[1].Value) {throw 'Next download SHA-256 mismatch; cancelled.'}
    $extracted=Join-Path $work 'package'
    Expand-Archive -LiteralPath $archive -DestinationPath $extracted
    $installer=Join-Path $extracted 'scripts\install_next_windows_agent.ps1'
    if (-not (Test-Path $installer)) {throw 'Missing Next installer inside verified ZIP.'}
    Write-Warning 'PREVIEW CHANNEL: Windows executable is unsigned, and Next MCP is not online; device control will not yet work.'
    & $installer -PackageDir $extracted -GatewayUrl 'https://mcpx.devcontrol.dev' -DevelopmentUnsigned
    if (-not $?) {throw 'Next installer reported failure'}
    Write-Output 'NEXT_WINDOWS_INSTALL_OK (preview installed; enrollment awaits Next Gateway)'
} finally {
    if (Test-Path -LiteralPath $work) {Remove-Item -LiteralPath $work -Recurse -Force}
}
