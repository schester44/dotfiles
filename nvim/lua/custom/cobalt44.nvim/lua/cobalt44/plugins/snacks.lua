local colors = require('cobalt44.utils').colors
local Group = require('cobalt44.utils').Group

Group.new('SnacksPickerInput', colors.white, colors.cobalt_bg_dark, nil)
Group.new('SnacksPickerInputBorder', colors.cobalt_bg, colors.cobalt_bg_dark, nil)
Group.new('SnacksPickerInputTitle', colors.light_pink, colors.cobalt_bg, nil)

Group.new('SnacksPickerPreview', colors.white, colors.cobalt_bg_dark, nil)
Group.new('SnacksPickerPreviewBorder', colors.cobalt_bg, colors.cobalt_bg_dark, nil)
Group.new('SnacksPickerPreviewTitle', colors.yellow, colors.cobalt_bg, nil)

Group.new('SnacksPickerList', colors.white, colors.cobalt_bg_dark, nil)
Group.new('SnacksPickerListBorder', colors.cobalt_bg, colors.cobalt_bg_dark, nil)
Group.new('SnacksPickerListCursorLine', colors.yellow, colors.cursor_hover, nil)
Group.new('SnacksPickerListTitle', colors.yellow, colors.cobalt_bg, nil)
