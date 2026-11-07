# Installs the "SQL (db-tools tmpl)" Zed extension on Windows.
# The grammar ships prebuilt (grammars/jinja2.wasm) — no compilation
# and no network access are needed.
# This file is pure ASCII on purpose: Windows PowerShell 5.1 parses
# BOM-less UTF-8 scripts in the system codepage, which breaks on non-ASCII.
#
# Run: right-click -> "Run with PowerShell", or:
#   powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = 'Stop'

$ExtDir = $PSScriptRoot
$Base = "$env:LOCALAPPDATA\Zed\extensions"
$Dest = "$Base\installed\db-tools-sql"

New-Item -ItemType Directory -Force -Path "$Base\installed" | Out-Null

# Remove previous installs: an old copy and any leftover
# from the Install Dev Extension button
if (Test-Path $Dest) { Remove-Item -Recurse -Force $Dest }
if (Test-Path "$Base\dev\db-tools-sql") { Remove-Item -Recurse -Force "$Base\dev\db-tools-sql" }

# Copy (symlinks on Windows require Developer Mode / admin)
Copy-Item -Path $ExtDir -Destination $Dest -Recurse
if (Test-Path "$Dest\grammars\jinja2") { Remove-Item -Recurse -Force "$Dest\grammars\jinja2" }

Write-Host "Installed: $Dest"
Write-Host "Restart Zed completely, then open any *.sql.tmpl file:"
Write-Host "language in the bottom-right corner should be 'SQL (db-tools tmpl)'."
