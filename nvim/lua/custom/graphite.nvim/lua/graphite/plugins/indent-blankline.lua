local colors = require("graphite.utils").colors
local Group = require("graphite.utils").Group

Group.new("IndentBlankLineChar", colors.darker_grey:light(), nil, nil)
Group.new("IndentBlankLineContextChar", colors.yellow, nil, nil)
