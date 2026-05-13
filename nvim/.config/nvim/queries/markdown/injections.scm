; Override of nvim-treesitter's markdown/injections.scm.
;
; The plugin's file uses (#set-lang-from-info-string! ...), whose
; pre-nvim-0.10 handler signature is broken on nvim 0.12 and throws
; "attempt to call method 'range' (a nil value)" from the highlighter.
;
; This is nvim 0.12's bundled query, which uses only standard
; directives. No `;; extends` — this fully replaces the plugin's file.
; Remove when migrating nvim-treesitter to the `main` branch.

(fenced_code_block
  (info_string
    (language) @injection.language)
  (code_fence_content) @injection.content)

((html_block) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined)
  (#set! injection.include-children))

((minus_metadata) @injection.content
  (#set! injection.language "yaml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

((plus_metadata) @injection.content
  (#set! injection.language "toml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

([
  (inline)
  (pipe_table_cell)
] @injection.content
  (#set! injection.language "markdown_inline"))
