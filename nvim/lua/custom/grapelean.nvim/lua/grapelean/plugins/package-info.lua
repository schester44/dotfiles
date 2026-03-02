local colors = require("grapelean.utils").colors
local Group = require("grapelean.utils").Group

Group.new("PackageInfoOutdatedVersion", colors.pink:light():light(), nil, nil)
Group.new("PackageInfoUptoDateVersion", colors.gray_light:dark():dark(), nil, nil)
