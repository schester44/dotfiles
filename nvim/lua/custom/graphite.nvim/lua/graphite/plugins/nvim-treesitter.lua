local colors = require('graphite.utils').colors
local styles = require('graphite.utils').styles
local Group = require('graphite.utils').Group

--- REF: https://neovim.io/doc/user/treesitter.html#_treesitter-trees

--------------------------------------------------------------------------------
--  NOTE: misc {{{
--------------------------------------------------------------------------------
Group.new('@annotation', colors.grey, nil, styles.italic)
Group.new('@error', colors.muted_red, nil, nil)
Group.new('@operator', colors.dark_grey, nil, nil)
Group.new('@structure', colors.grey, nil, styles.italic)
-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  NOTE: literals {{{
--------------------------------------------------------------------------------
Group.new('@string', colors.green, nil, nil)
Group.new('@string.escape', colors.blue, nil, nil)
Group.new('@string.regex', colors.blue, nil, nil)
Group.new('@string.special', colors.blue, nil, styles.italic)

Group.new('@character', colors.green, nil, nil)
Group.new('@character.special', colors.blue, nil, nil)

Group.new('@number', colors.purple, nil, nil)
Group.new('@float', colors.purple, nil, nil)
Group.new('@boolean', colors.purple, nil, nil)
-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  NOTE: functions {{{
--------------------------------------------------------------------------------
Group.new('@function', colors.yellow, nil, nil)
Group.new('@function.call', colors.yellow, nil, nil)
Group.new('@function.builtin', colors.yellow, nil, nil)
Group.new('@function.macro', colors.yellow, nil, nil)

Group.new('@method', colors.yellow, nil, nil)
Group.new('@method.call', colors.yellow, nil, nil)

Group.new('@constructor', colors.blue, nil, nil)
Group.new('@parameter', colors.white, nil, nil)
Group.new('@parameter.reference', colors.white, nil, nil)
-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  NOTE: keywords {{{
--------------------------------------------------------------------------------
Group.new('@keyword', colors.keyword, nil, nil)
Group.new('@keyword.import', colors.keyword, nil, nil)
Group.new('@keyword.function', colors.keyword, nil, nil)
Group.new('@keyword.operator', colors.grey, nil, nil)
Group.new('@keyword.return', colors.keyword, nil, nil)
Group.new('@keyword.exception', colors.keyword, nil, nil)
Group.new('@keyword.conditional', colors.keyword, nil, nil)

Group.new('@conditional', colors.keyword, nil, nil)
Group.new('@repeat', colors.keyword, nil, nil)
Group.new('@debug', colors.grey, nil, nil)
Group.new('@label', colors.grey, nil, nil)
Group.new('@include', colors.keyword, nil, nil)
Group.new('@exception', colors.keyword, nil, nil)

Group.new('@lsp.type.type', colors.blue, nil, nil)
Group.new('@lsp.type.enum', colors.blue, nil, nil)
Group.new('@lsp.type.class', colors.blue, nil, nil)

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  NOTE: types {{{
--------------------------------------------------------------------------------
Group.new('@type', colors.blue, nil, nil)
Group.new('@type.builtin', colors.blue, nil, nil)

Group.new('@attribute', colors.grey, nil, styles.italic)
Group.new('@field', colors.white, nil, nil)
Group.new('@property', colors.white, nil, nil)

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  NOTE: identifiers {{{
--------------------------------------------------------------------------------
Group.new('@variable', colors.white, nil, nil)
Group.new('@variable.builtin', colors.white, nil, nil)

Group.new('@constant', colors.white, nil, nil)
Group.new('@constant.builtin', colors.light_yellow, nil, styles.italic)
Group.new('@constant.macro', colors.blue, nil, nil)

Group.new('@namespace', colors.white, nil, nil)
Group.new('@symbol', colors.white, nil, nil)
Group.new('@module', colors.white, nil, nil)
-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  NOTE: punctuations {{{
--------------------------------------------------------------------------------
Group.new('@punctuation.bracket', colors.dark_grey, nil, nil)
Group.new('@punctuation.delimiter', colors.dark_grey, nil, nil)
Group.new('@punctuation.special', colors.dark_grey, nil, nil)
-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  NOTE: tags {{{
--------------------------------------------------------------------------------
Group.new('@tag', colors.green, nil, nil)
Group.new('@tag.builtin', colors.purple, nil, nil)
Group.new('@tag.attribute', colors.yellow, nil, styles.italic)
Group.new('@tag.delimiter', colors.white, nil, nil)
-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  NOTE: text {{{
--------------------------------------------------------------------------------
Group.new('@text', colors.white, nil, nil)
Group.new('@text.strong', colors.white, nil, styles.bold)
Group.new('@text.strike', colors.white, nil, styles.strikethrough)
Group.new('@text.emphasis', colors.white, nil, styles.italic)
Group.new('@text.underline', colors.white, nil, styles.underline)
Group.new('@text.uri', colors.light_blue, nil, styles.underline)
Group.new('@text.todo', colors.dark_pink, nil, styles.bold)
Group.new('@text.note', colors.green_muted, nil, styles.bold)
Group.new('@text.warning', colors.light_yellow, nil, styles.bold)
Group.new('@text.danger', colors.red:light(), nil, styles.bold)
Group.new('@text.underline', colors.white, nil, styles.underline)
Group.new('@text.diff.add', colors.green, nil, nil)
Group.new('@text.diff.delete', colors.red, nil, nil)

Group.new('@punctuation.delimiter', colors.white, nil, nil)

--------------------------------------------------------------------------------
--  markdown
--------------------------------------------------------------------------------
Group.new('@text.title', colors.dark_pink, nil, styles.bold)
Group.new('@text.title.1', colors.yellow, nil, styles.bold)
Group.new('@text.title.2', colors.dark_pink, nil, styles.bold)
Group.new('@text.literal', colors.green, nil, nil)
Group.new('@text.reference', colors.blue, nil, nil)
-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  treesitter-context
--------------------------------------------------------------------------------
Group.new('TreesitterContext', nil, colors.bg_muted, nil)
Group.new('TreesitterContextLineNumber', colors.grey, colors.bg_muted, nil)
Group.new('TreesitterContextSeparator', nil, colors.bg_muted, nil)
Group.new('TreesitterContextBottom', nil, colors.bg_muted, nil)
