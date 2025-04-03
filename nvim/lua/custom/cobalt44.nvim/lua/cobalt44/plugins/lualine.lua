local colors = require('cobalt44.utils').colors
local Group = require('cobalt44.utils').Group

Group.new('LualineRecording', colors.red, nil, nil)
Group.new('LualineCopilotOffline', colors.red, nil, nil)
Group.new('LualinePath', colors.dim_blue, nil, nil)
Group.new('LualineFilename', colors.dim_blue, nil, nil)
Group.new('LualineFilenameModified', colors.light_yellow, nil, nil)
