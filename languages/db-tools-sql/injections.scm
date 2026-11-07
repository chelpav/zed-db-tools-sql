; SQL text between Jinja2 tags. All chunks are parsed as ONE document
; (injection.combined): otherwise every chunk after %}/}} starts mid-statement
; and the SQL grammar swallows it into an ERROR node — tables/columns lose
; highlighting (JOIN/WHERE/ORDER at fragment starts etc.).
((raw_text) @content
  (#set! "language" "SQL")
  (#set! "injection.combined"))
