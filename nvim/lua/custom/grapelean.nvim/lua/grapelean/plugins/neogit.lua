local colors = require('grapelean.utils').colors
local styles = require('grapelean.utils').styles
local Group = require('grapelean.utils').Group

Group.new('NeogitDiffAddHighlight', colors.green, nil, nil)
Group.new('NeogitDiffAddRegion', colors.green, nil, nil)
Group.new('NeogitDiffContextHighlight', nil, nil, nil)
Group.new('NeogitDiffDeleteHighlight', colors.red_muted, nil, nil)
Group.new('NeogitDiffDeleteRegion', colors.red, nil, nil)
Group.new('NeogitHunkHeaderHighlight', colors.yellow, colors.bg_light, styles.bold)
Group.new('NeogitHunkHeaderCursor', colors.yellow, colors.bg_lighter, styles.bold)

-- status buffer
Group.new('NeogitBranch', colors.green, nil, nil)
Group.new('NeogitFold', colors.blue, nil, nil)
Group.new('NeogitBranchHead', colors.red, nil, styles.bold)
Group.new('NeogitRemote', colors.pink, nil, nil)
Group.new('NeogitObjectId', colors.blue, nil, nil)
Group.new('NeogitStash', colors.pink_light, nil, nil)
Group.new('NeogitRebaseDone', colors.green, nil, nil)
Group.new('NeogitTagName', colors.yellow, nil, nil)
Group.new('NeogitTagDistance', colors.yellow_muted, nil, nil)

-- status and commit buffer
Group.new('NeogitHunkHeader', colors.yellow, colors.bg_light, styles.bold)
Group.new('NeogitDiffContext', nil, colors.bg, nil)
Group.new('NeogitDiffDelete', colors.red, nil, nil)
Group.new('NeogitDiffHeader', colors.blue, nil, nil)
Group.new('NeogitDiffAdd', colors.green, nil, nil)

-- applied to filenames
Group.new('NeogitChangeModified', colors.yellow_light, nil, nil)
Group.new('NeogitChangeAdded', colors.green, nil, styles.bold)
Group.new('NeogitChangeDeleted', colors.red, nil, styles.bold)
Group.new('NeogitChangeRenamed', colors.pink_muted, nil, styles.bold)
Group.new('NeogitChangeUpdated', colors.green, nil, styles.bold)
Group.new('NeogitChangeCopied', colors.yellow, nil, styles.bold)
Group.new('NeogitChangeBothModified', colors.red, nil, styles.bold)
Group.new('NeogitChangeNewFile', colors.green, nil, styles.bold)

-- commit buffer
Group.new('NeogitFilePath', colors.pink, nil, styles.bold)
Group.new('NeogitCommitViewHeader', colors.blue, nil, nil)

Group.new('NeogitChangeMStaged', colors.green, nil, nil)
Group.new('neogitremote', colors.keyword, nil, nil)
