# zed-db-tools-sql

Zed-расширение для подсветки SQL-шаблонов **classic-db-tools** (`*.sql.tmpl`, а также
`*.sql.j2`, `*.sql.jinja`). Язык называется **SQL (db-tools tmpl)**.

Что даёт:

- Jinja2-конструкции: `{% if/elif/else %}`, `{% for %}`, `{% macro %}`, `{% set %}`,
  `{% include/extends/import/from %}`, `{% filter %}`, `{% raw %}`, `{# комментарии #}`,
  значения `{{ ... }}` с пайп-фильтрами (`{{ x | sqlsafe }}`), кортежи, kwargs.
- Trim-тире: `{%- ... -%}`, `{{- ... -}}`, `{#- ... -#}`.
- **SQL инъектируется** в сырой текст между Jinja2-тегами (встроенная грамматика Zed "SQL") —
  `SELECT/JOIN/WHERE/...` подсвечиваются, включая операторы `<=`, `<>`, `<=>` (pgvector).

## Устройство

```
extension.toml                 — манифест; repository/commit = наш локальный форк
                                  (file://) — по ним КНОПКА компилирует на машине автора
languages/db-tools-sql/
  config.toml                  — имя языка, path_suffixes, block_comment {# #}
  highlights.scm               — подсветка Jinja2-части + фолбэк SQL-ключевых слов
                                   (jinja: @string.special/@attribute — гамма «строк»,
                                    SQL: @keyword/@function — гамма «ключевых слов»;
                                    расходится в любой теме, включая смену темы)
  injections.scm               — (raw_text) @content → язык SQL  ← ключевой файл
  indents.scm, brackets.scm
grammars/jinja2.wasm           — предсобранная грамматика (форк), ездит с расширением
```

Форк грамматики живёт на GitHub: **chelpav/tree-sitter-jinja2-sql**
(мастер-копия для правок — `~/evraz/tree-sitter-jinja2-sql`, push в `fork`).
Отличия от апстрима f5c7baa:

1. `raw_text` — **именованная** нода сырого текста (в апстриме скрытая `_text`) — только её
   можно захватить в injections.scm. В regex добавлен `<` — иначе SQL-операторы `<=`, `<=>`
   ломают парсер. `raw_text` токенизирована (слова/пробелы/символы) для фолбэк-подсветки.
2. Trim-тире (`-%}`) в апстриме давали ERROR-ноды.
3. `elif`/`else` — отдельные стейтменты (в апстриме ждались внутри `{% if %}`, что не так
   в реальном jinja).
4. Пайп-фильтры `{{ x | sqlsafe }}` в апстриме вообще не разбирались.
5. Кортежи в выражениях (`f.op in ('IS NULL', 'IS NOT NULL')`).
6. `{% fn() %}` — вызов функции как стейтмент (dbt-стиль).
7. Убраны HTML-правила (мёртвый груз для SQL) и `{% call %}` (неоднозначность с кортежами,
   в шаблонах не встречается).

Плюс слой фолбэк-подсветки в highlights.scm: SQL-инъекция парсит каждую текстовую чанку
как отдельный документ и теряет первые слова фрагментов после `%}`/`}}` (AND, WHERE,
NOT, EXISTS...) — эти слова подсвечиваются правилами jinja-слоя.

Все 4 реальных шаблона `prices_backend` парсятся без ERROR-нод; корпус-тесты грамматики —
55/55 зелёные.

## Пересборка после правок грамматики

Исходники грамматики — соседний репозиторий `~/evraz/tree-sitter-jinja2-sql`
(мастер-копия с историей; в расширение ездит только собранный wasm).

```bash
cd ~/evraz/tree-sitter-jinja2-sql
tree-sitter generate --abi 14  # перегенерация parser.c (ABI 14 — совместимость со старыми Zed)
tree-sitter test               # корпус (test/corpus/*.txt), должно быть 55/55
tree-sitter build --wasm       # docker: emscripten/emsdk, собирает tree-sitter-jinja2.wasm
cp tree-sitter-jinja2.wasm ../zed-db-tools-sql/grammars/jinja2.wasm
# если правки грамматики закоммичены — обновить commit = <новый sha>
# в ../zed-db-tools-sql/extension.toml (кнопка компилирует по этому sha)
# перезапустить Zed
```

Нужен tree-sitter CLI (`brew install tree-sitter`) и Docker (для wasm-сборки).

## Установка (автор, эта машина)

Вариант 1: запустить `install.command` (копия в каталог Zed, готовый wasm,
без сети) — основной способ.

Вариант 2: кнопка Extensions → ⚙ → **Install Dev Extension** → выбрать эту
папку — клонирует и компилирует наш форк с GitHub (~10–30 сек), ставит
симлинком и оставляет клон `grammars/jinja2/`; после неё лучше перезапустить
`install.command`.

## Дистрибуция (коллегам)

Папка расширения **самодостаточна**: грамматика едет внутри как предсобранный
`grammars/jinja2.wasm` (Zed грузит его при старте, ничего не клонируя — проверено).

⚠️ **Кнопка «Install Dev Extension»** работает у всех с доступом к GitHub:
она клонирует и компилирует наш форк (`repository` в манифесте указывает на
https://github.com/chelpav/tree-sitter-jinja2-sql), ~10–30 сек. После установки
кнопкой перезапусти `install.command` — он почистит клон и поставит копию.
Если GitHub недоступен — **только скриптом** (готовый wasm, без сети).

Передать коллеге:

```bash
cd ~/evraz && zip -r zed-db-tools-sql.zip zed-db-tools-sql
```

Коллега:

1. Распаковать zip в **постоянное** место (не в Downloads — папка должна жить).
2. Запустить установщик для своей ОС:
   - **macOS**: двойной клик по `zed-db-tools-sql/install.command`
     (или `bash zed-db-tools-sql/install.command`);
   - **Windows**: правый клик по `zed-db-tools-sql/install.ps1` → «Run with PowerShell»
     (или `powershell -ExecutionPolicy Bypass -File zed-db-tools-sql/install.ps1`);
   - **Linux**: `bash zed-db-tools-sql/install.command`.
3. Перезапустить Zed полностью.

Требование: Zed не сильно старый (wasm собран под ABI 14 — покрывает и предыдущие
версии; совсем древний Zed — обновить). macOS-путь проверен живьём; скрипты
Windows/Linux написаны по документированным путям Zed — если у коллеги упадёт,
прислать вывод скрипта/ошибку сюда, правится за минуту.

Копия ставится в каталог расширений Zed на всех ОС (обновление = распаковать
новую версию и запустить установщик ещё раз; внешняя папка после установки
не нужна). Ни компиляции, ни доступа к GitHub — грамматика внутри архива.

Проверка: открыть любой `*.sql.tmpl` — внизу справа должен быть язык
«SQL (db-tools tmpl)», SELECT/JOIN и jinja-теги подсвечены.
