local colors = require('grapelean.utils').colors
local Group = require('grapelean.utils').Group
local styles = require('grapelean.utils').styles

Group.new('CodeBlock', nil, colors.bg_dark, nil)

Group.new('Headline4', colors.yellow, colors.bg, styles.bold)
Group.new('Headline1', colors.green, colors.green_bg, styles.bold)
Group.new('Headline5', colors.purple, colors.bg, styles.bold)
Group.new('Headline3', colors.pink_light, colors.bg, styles.bold)
Group.new('Headline2', colors.blue_light, colors.blue_light_bg, styles.bold)
Group.new('Headline6', colors.yellow_light, colors.bg, styles.bold)
