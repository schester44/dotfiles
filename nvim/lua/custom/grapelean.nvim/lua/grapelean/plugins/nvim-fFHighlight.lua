local colors = require("grapelean.utils").colors
local Group = require("grapelean.utils").Group

Group.new("fFHintChar", colors.pink, nil, nil)
Group.new("fFHintCurrentWord", colors.yellow, colors.cursor_hover, nil)
Group.new("fFHintNumber", colors.pink, nil, nil)
Group.new("fFHintWords", colors.gray_muted, nil, nil)
Group.new("fFPromptSign", colors.red, nil, nil)
