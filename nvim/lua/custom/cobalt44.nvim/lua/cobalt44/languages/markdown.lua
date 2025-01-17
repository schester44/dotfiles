local colors = require('cobalt44.utils').colors
local Group = require('cobalt44.utils').Group
local styles = require('cobalt44.utils').styles

Group.new('CodeBlock', nil, colors.cobalt_bg_dark, nil)

Group.new('Headline4', colors.yellow, colors.light_orange_bg, styles.bold)
Group.new('Headline1', colors.light_green, colors.light_green_bg, styles.bold)
Group.new('Headline5', colors.purple, colors.light_purple_bg, styles.bold)
Group.new('Headline3', colors.lightest_pink, colors.light_pink_bg, styles.bold)
Group.new('Headline2', colors.light_blue, colors.light_blue_bg, styles.bold)
Group.new('Headline6', colors.light_yellow, colors.light_yellow_bg, styles.bold)
