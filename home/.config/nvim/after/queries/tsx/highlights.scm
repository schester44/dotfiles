;; extends

; `undefined`/`null` in type positions (e.g. `string | undefined`) should look
; like types, not like undefined/null values
(literal_type (undefined) @type.builtin)
(literal_type (null) @type.builtin)
