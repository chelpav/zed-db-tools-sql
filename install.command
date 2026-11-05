#!/usr/bin/env bash
# Установка Zed-расширения "SQL (db-tools tmpl)".
# Кладёт КОПИЮ расширения в каталог расширений Zed — как установка из
# маркетплейса. Внешняя папка после установки не нужна (оставьте как
# источник для обновлений). Без компиляции и сети: грамматика едет внутри
# (grammars/jinja2.wasm).
#
# Обновление: распаковать новую версию поверх и запустить скрипт ещё раз.
set -e

EXT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ "$(uname)" == "Darwin" ]]; then
    DEST="$HOME/Library/Application Support/Zed/extensions/installed"
else
    DEST="${XDG_DATA_HOME:-$HOME/.local/share}/zed/extensions/installed"
fi

mkdir -p "$DEST"
# убрать старые попытки: прежнюю копию/симлинк и хвост кнопки Install Dev Extension
rm -rf "$DEST/db-tools-sql" "$(dirname "$DEST")/dev/db-tools-sql"
# копируем (симлинки на Windows требуют Developer Mode; копия — универсально)
cp -R "$EXT_DIR" "$DEST/db-tools-sql"
rm -rf "$DEST/db-tools-sql/grammars/jinja2" 2>/dev/null || true

echo "Установлено (копия): $DEST/db-tools-sql"
echo "Теперь полностью перезапусти Zed."
echo "Проверка: открыть любой *.sql.tmpl — внизу справа язык «SQL (db-tools tmpl)»."
