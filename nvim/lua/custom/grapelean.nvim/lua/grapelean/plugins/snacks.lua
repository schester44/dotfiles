local colors = require('grapelean.utils').colors
local Group = require('grapelean.utils').Group

-- Picker
Group.new('SnacksPicker', colors.white, colors.bg_dark, nil)
Group.new('SnacksPickerBorder', colors.bg_dark, colors.bg_dark, nil)
Group.new('SnacksPickerTitle', colors.pink_light, colors.bg, nil)
Group.new('SnacksPickerInput', colors.white, colors.bg_dark, nil)
Group.new('SnacksPickerInputBorder', colors.bg, colors.bg_dark, nil)
Group.new('SnacksPickerInputTitle', colors.pink_light, colors.bg, nil)

Group.new('SnacksPickerPreview', colors.white, colors.bg_dark, nil)
Group.new('SnacksPickerPreviewBorder', colors.bg, colors.bg_dark, nil)
Group.new('SnacksPickerPreviewTitle', colors.yellow, colors.bg, nil)

Group.new('SnacksPickerList', colors.white, colors.bg_dark, nil)
Group.new('SnacksPickerListBorder', colors.bg, colors.bg_dark, nil)
Group.new('SnacksPickerListCursorLine', colors.green, colors.black, nil)
Group.new('SnacksPickerListTitle', colors.yellow, colors.bg, nil)

Group.new('SnacksPickerDir', colors.gray_light, nil, nil)
Group.new('SnacksPickerMatch', colors.green, nil, nil)
