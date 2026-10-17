[CmdletBinding()]
param([switch]$TestOnly)
# Git-only fallback: github.com clone delivers the archive, no Raw/CDN DNS required.
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$zip=Join-Path $PSScriptRoot 'stage\devcontrol-next-agent-windows-x64.zip'
$sidecar="$zip.sha256"
if (-not (Test-Path $zip) -or -not (Test-Path $sidecar)) {throw 'Next ZIP missing from verified public Git branch.'}
$text=[IO.File]::ReadAllText($sidecar)
$m=[regex]::Match($text,'^([a-fA-F0-9]{64})  devcontrol-next-agent-windows-x64\.zip')
if (-not $m.Success -or (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash -ine $m.Groups[1].Value) {
    throw 'Next ZIP SHA256 mismatch; installation stopped.'
}
$dir=Join-Path $env:TEMP ('next-installer-'+[Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $dir -Force | Out-Null
try {
    Expand-Archive -LiteralPath $zip -DestinationPath $dir
    $installer=Join-Path $dir 'scripts\install_next_windows_agent.ps1'
    if (-not (Test-Path $installer)) {throw 'Missing independent Next installer.'}
    Write-Warning 'DevControl Next experimental unsigned preview: backend pairing unavailable.'
    & $installer -PackageDir $dir -GatewayUrl 'https://mcpx.devcontrol.dev' -DevelopmentUnsigned
    & $installer -Status
    if ($TestOnly) {
        & $installer -Uninstall
        Write-Output 'NEXT_WINDOWS_GIT_FALLBACK_INSTALL_TEST_AND_UNINSTALL_PASS'
    } else {
        Write-Output 'NEXT_WINDOWS_GIT_FALLBACK_INSTALLED; registration awaits Next Gateway'
    }
} finally {
    if (Test-Path $dir) {Remove-Item -LiteralPath $dir -Recurse -Force}
}
