local colors = require('graphite.utils').colors
local styles = require('graphite.utils').styles
local Group = require('graphite.utils').Group

Group.new('AvantePromptInput', nil, colors.cobalt_bg_dark, nil)
Group.new('AvanteInlineHint', colors.keyword, nil, styles.italic)
