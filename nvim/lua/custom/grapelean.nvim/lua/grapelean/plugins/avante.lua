local colors = require('grapelean.utils').colors
local styles = require('grapelean.utils').styles
local Group = require('grapelean.utils').Group

Group.new('AvantePromptInput', nil, colors.bg_dark, nil)
Group.new('AvanteInlineHint', colors.keyword, nil, styles.italic)
