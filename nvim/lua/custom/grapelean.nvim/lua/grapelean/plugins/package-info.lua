local colors = require("grapelean.utils").colors
local Group = require("grapelean.utils").Group

Group.new("PackageInfoOutdatedVersion", colors.dark_pink:light():light(), nil, nil)
Group.new("PackageInfoUptoDateVersion", colors.light_grey:dark():dark(), nil, nil)
