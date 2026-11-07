# zed-db-tools-sql

Zed extension with syntax highlighting for SQL templates with Jinja2
(`*.sql.tmpl`, `*.sql.j2`, `*.sql.jinja`). Built for
[db-tools](https://github.com/variasov/classic-db-tools) SQL template files;
works with any Jinja2 + SQL mix (dbt-style queries included).

Language name in Zed: **SQL (db-tools tmpl)**.

Grammar: a fork of [tree-sitter-jinja2](https://github.com/ArcherHume/tree-sitter-jinja2)
— [chelpav/tree-sitter-jinja2-sql](https://github.com/chelpav/tree-sitter-jinja2-sql).

## What you get

- Jinja2: `{% if/elif/else %}`, `{% for %}`, `{% macro %}`, `{% set %}`,
  `{% include/extends/import/from %}`, `{% filter %}`, `{% raw %}`, `{# #}`,
  `{{ ... }}` values with pipe filters (`{{ x | sqlsafe }}`), tuples, kwargs,
  boolean `and`/`or`, whitespace-trim dashes `{%- ... -%}` / `{{- ... -}}` / `{#- ... -#}`.
- **SQL is injected** into the raw text between jinja tags (Zed's built-in SQL
  grammar): `SELECT/JOIN/WHERE/...` and SQL operators like `<=`, `<>`, `<=>`
  (pgvector) get real SQL highlighting. All text chunks are parsed as a single
  combined document, so fragments starting mid-statement (right after `}}`/`%}`)
  keep their tables, columns and aliases highlighted.
- Jinja and SQL use distinct color palettes in any theme: jinja —
  `@string.special` / `@attribute`, SQL — `@keyword` / `@function`.

## Install

Get the extension folder (`git clone` this repository or unpack the archive),
then pick one of the two ways.

### Way 1 — the button (requires github.com access)

Zed → Extensions (Shift-Cmd-X / Ctrl-Shift-X) → gear icon → **Install Dev
Extension** → select the extension folder.

Zed compiles the grammar from the fork's repository (~10–30 s) and asks for a
restart. The button installs with a symlink and leaves a temporary
`grammars/jinja2/` clone behind — feel free to re-run the installer from way 2
to place a clean copy.

### Way 2 — the installer (works offline)

- **macOS**: double-click `install.command`;
- **Linux**: `bash install.command`;
- **Windows**: right-click `install.ps1` → "Run with PowerShell"
  (or `powershell -ExecutionPolicy Bypass -File install.ps1`).

The installer places a copy into Zed's extensions directory; the grammar ships
prebuilt (`grammars/jinja2.wasm`, tree-sitter ABI 14 — compatible with older
Zed versions), no compilation or network needed. Then fully restart Zed.

## Update

`git pull` (or unpack a new version over the folder) → repeat the install.

## Check

Open any `*.sql.tmpl` file — the language in the bottom right corner should be
"SQL (db-tools tmpl)", with SQL and jinja tags highlighted in different colors.

## Layout

```
extension.toml                 — manifest; repository/commit — the grammar fork
                                  (used by the button to compile on install)
languages/db-tools-sql/
  config.toml                  — language name, path_suffixes, block_comment {# #}
  highlights.scm               — jinja highlighting + SQL fallback rules
  injections.scm               — (raw_text) @content -> SQL   <- the key file
  indents.scm, brackets.scm
grammars/jinja2.wasm           — prebuilt grammar (for the offline installer)
install.command / install.ps1  — installers (macOS+Linux / Windows)
```

The differences between the grammar fork and upstream are described in the
[fork's README](https://github.com/chelpav/tree-sitter-jinja2-sql).

## Development

Rebuilding the grammar:

```bash
git clone https://github.com/chelpav/tree-sitter-jinja2-sql.git
cd tree-sitter-jinja2-sql
tree-sitter generate --abi 14   # ABI 14 — compatible with older Zed
tree-sitter test                # corpus tests, must be 57/57
tree-sitter build --wasm        # docker (emscripten/emsdk)
cp tree-sitter-jinja2.wasm <extension-folder>/grammars/jinja2.wasm
```

After grammar changes: commit and push the fork, then update
`commit = <new sha>` in `extension.toml` (the button compiles exactly that
sha) and push the extension.

Requires the tree-sitter CLI (`brew install tree-sitter`) and Docker.
