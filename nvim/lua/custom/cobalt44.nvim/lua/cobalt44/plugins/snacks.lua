local colors = require('cobalt44.utils').colors
local Group = require('cobalt44.utils').Group

-- Picker
Group.new('SnacksPicker', colors.white, colors.cobalt_bg_dark, nil)
Group.new('SnacksPickerBorder', colors.cobalt_bg_dark, colors.cobalt_bg_dark, nil)
Group.new('SnacksPickerTitle', colors.light_pink, colors.cobalt_bg, nil)
Group.new('SnacksPickerInput', colors.white, colors.cobalt_bg_dark, nil)
Group.new('SnacksPickerInputBorder', colors.cobalt_bg, colors.cobalt_bg_dark, nil)
Group.new('SnacksPickerInputTitle', colors.light_pink, colors.cobalt_bg, nil)

Group.new('SnacksPickerPreview', colors.white, colors.cobalt_bg_dark, nil)
Group.new('SnacksPickerPreviewBorder', colors.cobalt_bg, colors.cobalt_bg_dark, nil)
Group.new('SnacksPickerPreviewTitle', colors.yellow, colors.cobalt_bg, nil)

Group.new('SnacksPickerList', colors.white, colors.cobalt_bg_dark, nil)
Group.new('SnacksPickerListBorder', colors.cobalt_bg, colors.cobalt_bg_dark, nil)
Group.new('SnacksPickerListCursorLine', colors.yellow, colors.cobalt_bg, nil)
Group.new('SnacksPickerListTitle', colors.yellow, colors.cobalt_bg, nil)
