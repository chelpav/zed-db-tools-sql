
(bool) @boolean

(integer) @number
(float) @number

(lit_string) @string

(identifier) @variable

(kwarg
  key: (identifier) @property)

(pair
  key: (lit_string) @property)

; Делимитеры {{ }} {% %} — класс с фолбэком на string: в любой теме
; отличается от keyword-гамки SQL
(jinja_statement_open) @string.special
(jinja_statement_close) @string.special
(jinja_value_open) @string.special
(jinja_value_close) @string.special
(jinja_comment_open) @comment
(jinja_comment_close) @comment
(jinja_comment_content) @comment

["(" ")" "[" "]" "{" "}"] @punctuation.bracket
["," ":" "="] @punctuation.delimiter

(comparison
  operator: _ @operator)

; Ключевые слова jinja — @string.special (фолбэк string): стабильно другая
; гамма, чем @keyword SQL-слоя, при любой теме
["if" "elif" (jinja_else) "for" "in" "and" "or" "block" "endblock" "extends" "include" "import" "from" "as" "set" "macro" "endmacro" "endif" "endfor" "endcall" "filter" (jinja_raw) "endraw"] @string.special

; Имена блоков/макросов/фильтров — @attribute: не пересекается с @function
; SQL-слоя (в популярных темах всегда разные гаммы)
(jinja_block
  block_name: (identifier) @attribute)

(jinja_macro
  macro_name: (identifier) @attribute)

(jinja_filter
  filter_name: (identifier) @attribute)

; Пайп-фильтры: {{ x | sqlsafe }}, {{ x | default('y') }}
(filter_spec
  filter_name: (identifier) @attribute)

(fn_call
  fn_name: (identifier) @attribute)

["|"] @operator

(jinja_extends
  parent_template: (lit_string) @string.special)

(jinja_include
  template: (lit_string) @string.special)

(jinja_import
  module: (lit_string) @string.special)

(jinja_from
  module: (lit_string) @string.special)

; --- Фолбэк-подсветка SQL в сыром тексте ------------------------------
; Слой SQL-инъекции парсит каждую raw_text-чанку как ОТДЕЛЬНЫЙ документ:
; фрагменты, начинающиеся посреди инструкции (AND/WHERE/NOT/EXISTS после
; закрытия %} или }}), теряют первое слово в ERROR-ноде SQL-парсера.
; Эти правила подсвечивают такие слова на уровне jinja-слоя; там, где
; SQL-слой справился сам, стили совпадают и друг другу не мешают.

((raw_word) @keyword
  (#match? @keyword "^(?i)(SELECT|FROM|WHERE|AND|OR|NOT|EXISTS|HAVING|UNION|ALL|ANY|SOME|DISTINCT|JOIN|INNER|LEFT|RIGHT|FULL|CROSS|OUTER|LATERAL|ON|USING|AS|WITH|RECURSIVE|INSERT|INTO|VALUES|UPDATE|DELETE|CREATE|DROP|ALTER|TABLE|INDEX|VIEW|RETURNING|ORDER|GROUP|BY|LIMIT|OFFSET|CASE|WHEN|THEN|ELSE|END|IS|IN|LIKE|ILIKE|SIMILAR|BETWEEN|ASC|DESC|EXCEPT|INTERSECT|WINDOW|OVER|PARTITION|RANGE|ROWS|FILTER|WITHIN|CAST|INTERVAL|DEFAULT|PRIMARY|FOREIGN|REFERENCES|UNIQUE|CHECK|CONSTRAINT|CONFLICT|DO|NOTHING|SET)$"))

((raw_word) @constant
  (#match? @constant "^(?i)(NULL|TRUE|FALSE)$"))

; Функция в начале фрагмента: слово непосредственно перед "("
; (строчными — чтобы не перекрывать ключевые слова вида WHERE (...)
(raw_text
  (raw_word) @function
  .
  (raw_other) @_paren
  (#match? @_paren "^\\(")
  (#match? @function "^[a-z][A-Za-z0-9_]*$"))
