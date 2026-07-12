local helpers = require("tests.helpers")
local opts = helpers.plugin_opts("snacks.nvim")
local explorer = opts.picker.sources.explorer

helpers.eq(explorer.hidden, true, "explorer shows hidden files")
helpers.eq(explorer.ignored, true, "explorer shows ignored files")
helpers.eq(explorer.git_status, true, "explorer shows git status")
helpers.eq(explorer.git_untracked, true, "explorer shows untracked files")
helpers.eq(explorer.layout.layout.position, "left", "explorer opens on the left")

print("explorer_spec: ok")
