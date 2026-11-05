# Установка Zed-расширения "SQL (db-tools tmpl)" на Windows.
# Грамматика едет внутри архива (grammars/jinja2.wasm) — компиляция и
# доступ к сети не нужны.
#
# Запуск: правый клик по install.ps1 -> "Run with PowerShell",
# либо в терминале:
#   powershell -ExecutionPolicy Bypass -File install.ps1

$ExtDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Base = "$env:LOCALAPPDATA\Zed\extensions"
$Dest = "$Base\installed\db-tools-sql"

New-Item -ItemType Directory -Force -Path "$Base\installed" | Out-Null

# убрать старые попытки: копию/симлинк и хвост от кнопки Install Dev Extension
if (Test-Path $Dest) { Remove-Item -Recurse -Force $Dest }
if (Test-Path "$Base\dev\db-tools-sql") { Remove-Item -Recurse -Force "$Base\dev\db-tools-sql" }

# копируем (симлинки на Windows требуют Developer Mode / админа)
Copy-Item -Path $ExtDir -Destination $Dest -Recurse

Write-Host "Установлено: $Dest"
Write-Host "Полностью перезапусти Zed и открой любой *.sql.tmpl —"
Write-Host "внизу справа должен быть язык 'SQL (db-tools tmpl)'."
