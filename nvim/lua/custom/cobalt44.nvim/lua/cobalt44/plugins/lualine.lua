local colors = require('cobalt44.utils').colors
local Group = require('cobalt44.utils').Group
local styles = require('cobalt44.utils').styles

Group.new('LualineRecording', colors.red, nil, nil)
Group.new('LualineCopilotOffline', colors.red, nil, nil)
Group.new('LualinePath', colors.dim_blue, nil, nil)
Group.new('LualineFilename', colors.light_grey, nil, nil)

Group.new('LualineFilenameModified', colors.light_yellow, nil, styles.italic)
