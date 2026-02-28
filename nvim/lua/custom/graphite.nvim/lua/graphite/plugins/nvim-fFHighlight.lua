local colors = require("graphite.utils").colors
local Group = require("graphite.utils").Group

Group.new("fFHintChar", colors.pink, nil, nil)
Group.new("fFHintCurrentWord", colors.yellow, colors.cursor_hover, nil)
Group.new("fFHintNumber", colors.pink, nil, nil)
Group.new("fFHintWords", colors.dark_grey, nil, nil)
Group.new("fFPromptSign", colors.red, nil, nil)
