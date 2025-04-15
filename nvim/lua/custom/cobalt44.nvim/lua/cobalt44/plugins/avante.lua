local colors = require('cobalt44.utils').colors
local styles = require('cobalt44.utils').styles
local Group = require('cobalt44.utils').Group

Group.new('AvantePromptInput', nil, colors.cobalt_bg_dark, nil)
Group.new('AvanteInlineHint', colors.dim_blue, nil, styles.italic)
