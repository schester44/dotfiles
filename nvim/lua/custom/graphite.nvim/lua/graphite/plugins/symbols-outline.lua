local Group = require("graphite/utils").Group
local colors = require("graphite/utils").colors

Group.new("FocusedSymbol", colors.yellow, colors.darker_blue, nil)
Group.new("SymbolsOutlineConnector", colors.yellow, colors.darker_blue, nil)
