local colors = require("rainbow.colors")
local termcolors = require("rainbow.termcolors")

local M = {}

function M.init()
  -- define highlight groups
  for i = 1, #colors do
    local s = "highlight default rainbowcol"
      .. i
      .. " guifg="
      .. colors[i]
      .. " ctermfg="
      .. termcolors[i]
    vim.cmd(s)
  end

  require("nvim-treesitter").define_modules({
    rainbow = {
      module_path = "rainbow.internal",
      -- is_supported = true,
      extended_mode = true,
    },
  })
end

return M
