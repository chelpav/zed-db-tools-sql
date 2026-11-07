(bool) @boolean

(integer) @number
(float) @number

(lit_string) @string

(identifier) @variable

(kwarg
  key: (identifier) @property)

(pair
  key: (lit_string) @property)

; Jinja delimiters {{ }} {% %} — a capture class that falls back to `string`:
; in any theme this differs from the keyword palette used by the SQL layer
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

; Jinja keywords — @string.special (falls back to `string`): a palette that is
; reliably distinct from the SQL layer's @keyword in any theme
["if" "elif" (jinja_else) "for" "in" "and" "or" "block" "endblock" "extends" "include" "import" "from" "as" "set" "macro" "endmacro" "endif" "endfor" "endcall" "filter" (jinja_raw) "endraw"] @string.special

; Block/macro/filter names — @attribute: does not collide with the SQL
; layer's @function (always different palettes in popular themes)
(jinja_block
  block_name: (identifier) @attribute)

(jinja_macro
  macro_name: (identifier) @attribute)

(jinja_filter
  filter_name: (identifier) @attribute)

; Pipe filters: {{ x | sqlsafe }}, {{ x | default('y') }}
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

; --- Identifier filler for SQL error-recovery zones -----------------------
; In error-recovery zones the SQL injection loses identifier/relation/column
; nodes — tables, aliases and fields render unstyled (macro bodies, branch
; concatenation). Paint them with the same classes the SQL layer uses; in
; valid zones the classes match and the overlap is invisible.
; IMPORTANT: these rules come BEFORE the keyword/function rules
; (the later pattern wins on overlap).

(raw_text
  (raw_word) @variable)

(raw_text
  (raw_word) @type
  .
  (raw_other) @_dot_qualifier
  (#match? @_dot_qualifier "^\\."))

(raw_text
  (raw_word) @_qualifier
  .
  (raw_other) @_dot_field
  (#match? @_dot_field "^\\.")
  .
  (raw_word) @property)

; --- SQL keyword fallback in raw text --------------------------------------
; The SQL injection parses each text chunk as a separate document: fragments
; starting mid-statement (AND/WHERE/NOT/EXISTS right after }} or %}) lose
; their first word in the SQL parser's ERROR node. These rules highlight
; such words at the jinja layer; where the SQL layer succeeds, the styles
; match and do not conflict.

((raw_word) @keyword
  (#match? @keyword "^(?i)(SELECT|FROM|WHERE|AND|OR|NOT|EXISTS|HAVING|UNION|ALL|ANY|SOME|DISTINCT|JOIN|INNER|LEFT|RIGHT|FULL|CROSS|OUTER|LATERAL|ON|USING|AS|WITH|RECURSIVE|INSERT|INTO|VALUES|UPDATE|DELETE|CREATE|DROP|ALTER|TABLE|INDEX|VIEW|RETURNING|ORDER|GROUP|BY|LIMIT|OFFSET|CASE|WHEN|THEN|ELSE|END|IS|IN|LIKE|ILIKE|SIMILAR|BETWEEN|ASC|DESC|EXCEPT|INTERSECT|WINDOW|OVER|PARTITION|RANGE|ROWS|FILTER|WITHIN|CAST|INTERVAL|DEFAULT|PRIMARY|FOREIGN|REFERENCES|UNIQUE|CHECK|CONSTRAINT|CONFLICT|DO|NOTHING|SET)$"))

((raw_word) @constant
  (#match? @constant "^(?i)(NULL|TRUE|FALSE)$"))

; Function at a fragment start: a word immediately followed by "("
; (lowercase only, so SQL keywords like WHERE (...) are not overridden)
(raw_text
  (raw_word) @function
  .
  (raw_other) @_paren
  (#match? @_paren "^\\(")
  (#match? @function "^[a-z][A-Za-z0-9_]*$"))
