local colors = require('grapelean.utils').colors
local Group = require('grapelean.utils').Group
local styles = require('grapelean.utils').styles

Group.new('LualineRecording', colors.red, nil, nil)
Group.new('LualineCopilotOffline', colors.red, nil, nil)
Group.new('LualinePath', colors.keyword, nil, nil)
Group.new('LualineFilename', colors.gray_light, nil, nil)

Group.new('LualineFilenameModified', colors.yellow_light, nil, styles.italic)
