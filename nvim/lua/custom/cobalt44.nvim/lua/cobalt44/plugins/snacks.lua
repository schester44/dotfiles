local colors = require('cobalt44.utils').colors
local Group = require('cobalt44.utils').Group

-- Picker
Group.new('SnacksPicker', colors.white, colors.bg_dark, nil)
Group.new('SnacksPickerBorder', colors.bg_dark, colors.bg_dark, nil)
Group.new('SnacksPickerTitle', colors.light_pink, colors.bg, nil)
Group.new('SnacksPickerInput', colors.white, colors.bg_dark, nil)
Group.new('SnacksPickerInputBorder', colors.bg, colors.bg_dark, nil)
Group.new('SnacksPickerInputTitle', colors.light_pink, colors.bg, nil)

Group.new('SnacksPickerPreview', colors.white, colors.bg_dark, nil)
Group.new('SnacksPickerPreviewBorder', colors.bg, colors.bg_dark, nil)
Group.new('SnacksPickerPreviewTitle', colors.yellow, colors.bg, nil)

Group.new('SnacksPickerList', colors.white, colors.bg_dark, nil)
Group.new('SnacksPickerListBorder', colors.bg, colors.bg_dark, nil)
Group.new('SnacksPickerListCursorLine', colors.light_yellow, colors.bg, nil)
Group.new('SnacksPickerListTitle', colors.yellow, colors.bg, nil)

Group.new('SnacksPickerDir', colors.light_grey, nil, nil)
