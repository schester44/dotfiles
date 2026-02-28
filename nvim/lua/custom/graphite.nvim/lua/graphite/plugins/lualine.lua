local colors = require('graphite.utils').colors
local Group = require('graphite.utils').Group
local styles = require('graphite.utils').styles

Group.new('LualineRecording', colors.red, nil, nil)
Group.new('LualineCopilotOffline', colors.red, nil, nil)
Group.new('LualinePath', colors.keyword, nil, nil)
Group.new('LualineFilename', colors.light_grey, nil, nil)

Group.new('LualineFilenameModified', colors.light_yellow, nil, styles.italic)
