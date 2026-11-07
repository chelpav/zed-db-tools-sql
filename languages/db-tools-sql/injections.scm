; Сырой текст между Jinja2-тегами — это SQL. Все чанки парсятся как ОДИН
; документ (injection.combined): иначе каждый кусок после %}/}} начинается
; посреди инструкции и SQL-грамматика кладёт его в ERROR — таблицы/колонки
; теряют подсветку (JOIN/WHERE/ORDER в начале фрагмента и т.п.).
((raw_text) @content
  (#set! "language" "SQL")
  (#set! "injection.combined"))
