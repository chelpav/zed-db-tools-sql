# Установка Zed-расширения "SQL (db-tools tmpl)" на Windows.
# Грамматика едет внутри (grammars/jinja2.wasm) — компиляция и сеть не нужны.
# Файл хранится в UTF-8 с BOM: без BOM Windows PowerShell 5.1 читает скрипт
# в системной кодировке и падает на кириллице в строках.
#
# Запуск: правый клик -> "Run with PowerShell", либо:
#   powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = 'Stop'

$ExtDir = $PSScriptRoot
$Base = "$env:LOCALAPPDATA\Zed\extensions"
$Dest = "$Base\installed\db-tools-sql"

New-Item -ItemType Directory -Force -Path "$Base\installed" | Out-Null

# убрать старые попытки: прежнюю копию и хвост кнопки Install Dev Extension
if (Test-Path $Dest) { Remove-Item -Recurse -Force $Dest }
if (Test-Path "$Base\dev\db-tools-sql") { Remove-Item -Recurse -Force "$Base\dev\db-tools-sql" }

# копируем (симлинки на Windows требуют Developer Mode / админа)
Copy-Item -Path $ExtDir -Destination $Dest -Recurse
if (Test-Path "$Dest\grammars\jinja2") { Remove-Item -Recurse -Force "$Dest\grammars\jinja2" }

Write-Host "Installed: $Dest"
Write-Host "Restart Zed completely, then open any *.sql.tmpl file:"
Write-Host "language in the bottom-right corner should be 'SQL (db-tools tmpl)'."
