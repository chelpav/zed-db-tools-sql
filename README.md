# zed-db-tools-sql

Zed-расширение для подсветки SQL-шаблонов с Jinja2 (`*.sql.tmpl`, `*.sql.j2`,
`*.sql.jinja`). Язык в Zed: **SQL (db-tools tmpl)**.

Грамматика — отдельный форк: [chelpav/tree-sitter-jinja2-sql](https://github.com/chelpav/tree-sitter-jinja2-sql).

## Что даёт

- Jinja2: `{% if/elif/else %}`, `{% for %}`, `{% macro %}`, `{% set %}`,
  `{% include/extends/import/from %}`, `{% filter %}`, `{% raw %}`, `{# #}`,
  значения `{{ ... }}` с пайп-фильтрами (`{{ x | sqlsafe }}`), кортежи, kwargs,
  trim-тире `{%- ... -%}` / `{{- ... -}}` / `{#- ... -#}`.
- **SQL инъектируется** в сырой текст между jinja-тегами (встроенная грамматика
  Zed «SQL»): `SELECT/JOIN/WHERE/...`, операторы `<=`, `<>`, `<=>` (pgvector).
- Слова, начинающие фрагмент после `}}`/`%}` (`AND`, `WHERE`, `NOT`,
  `EXISTS`...), подсвечиваются фолбэк-правилами: SQL-слой парсит каждую текстовую
  чанку как отдельный документ и сам теряет первые слова фрагментов.
- Jinja и SQL — в разных гаммах при любой теме: jinja — `@string.special` /
  `@attribute` («строчная» гамма), SQL — `@keyword` / `@function`.

## Установка

Получить папку расширения: `git clone https://github.com/chelpav/zed-db-tools-sql.git`
(или распаковать архив). Затем один из двух способов.

### Способ 1 — кнопкой (нужен доступ к github.com)

Zed → Extensions (⇧⌘X / Ctrl-Shift-X) → шестерёнка → **Install Dev Extension**
→ выбрать папку расширения.

Zed скомпилирует грамматику из репозитория форка (~10–30 сек) и попросит
перезапуск. Кнопка ставит симлинком и оставляет временный клон
`grammars/jinja2/` — при желании после неё запустить установщик из способа 2,
он поставит чистую копию.

### Способ 2 — установщиком (работает без сети)

- **macOS**: двойной клик по `install.command`;
- **Linux**: `bash install.command`;
- **Windows**: правый клик по `install.ps1` → «Run with PowerShell»
  (или `powershell -ExecutionPolicy Bypass -File install.ps1`).

Установщик кладёт копию расширения в каталог расширений Zed; грамматика —
готовый `grammars/jinja2.wasm` (ABI 14, совместим со старыми версиями Zed),
компиляция и сеть не нужны. Затем полностью перезапустить Zed.

## Обновление

`git pull` (или распаковать новую версию поверх) → повторить установку любым
способом.

## Проверка

Открыть любой `*.sql.tmpl` — внизу справа язык «SQL (db-tools tmpl)»,
SQL и jinja-теги подсвечены разными цветами.

## Устройство

```
extension.toml                 — манифест; repository/commit — форк грамматики
                                  (по нему Zed компилирует при установке кнопкой)
languages/db-tools-sql/
  config.toml                  — имя языка, path_suffixes, block_comment {# #}
  highlights.scm               — подсветка jinja + фолбэк SQL-ключевых слов
  injections.scm               — (raw_text) @content → язык SQL   ← ключевой файл
  indents.scm, brackets.scm
grammars/jinja2.wasm           — предсобранная грамматика (для установки скриптом)
install.command / install.ps1  — установщики (macOS+Linux / Windows)
```

Отличия форка грамматики от апстрима — в
[README форка](https://github.com/chelpav/tree-sitter-jinja2-sql).

## Разработка

Пересборка грамматики:

```bash
git clone https://github.com/chelpav/tree-sitter-jinja2-sql.git
cd tree-sitter-jinja2-sql
tree-sitter generate --abi 14   # ABI 14 — совместимость со старыми Zed
tree-sitter test                # корпус, должно быть 55/55
tree-sitter build --wasm        # docker (emscripten/emsdk)
cp tree-sitter-jinja2.wasm <папка-расширения>/grammars/jinja2.wasm
```

После изменений грамматики: коммит и push форка, затем обновить `commit = <новый
sha>` в `extension.toml` (кнопка компилирует именно этот sha) и push расширения.

Нужны tree-sitter CLI (`brew install tree-sitter`) и Docker.
