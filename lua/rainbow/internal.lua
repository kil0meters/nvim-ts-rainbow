local parsers = require("nvim-treesitter.parsers")
local configs = require("nvim-treesitter.configs")
local nsid = vim.api.nvim_create_namespace("rainbow_ns")
local colors = require("rainbow.colors")
local async_lib = require("plenary.async_lib")
local async = async_lib.async
local await = async_lib.await
local void = async_lib.void
local custom = {
  ["html"] = true,
  ["jsx"] = true,
  ["lua"] = true,
  ["python"] = true,
  ["ruby"] = true,
  ["svelte"] = true,
  ["toml"] = true,
  ["tsx"] = true,
}

local function color_node(bufnr, node, len, count)
  local color_no = ((count - 1) % len) + 1
  local _, startCol, endRow, endCol = node:range()
  vim.highlight.range(
    bufnr,
    nsid,
    "rainbowcol" .. color_no,
    { endRow, startCol },
    { endRow, endCol - 1 },
    "blockwise",
    true
  )
end

local M = {}

M.highlight_node_recursive =
  async(function(parens, bufnr, extended_mode, node, len, count)
    local next_count = count

    for child in node:iter_children() do
      local paren
      if child:named() then
        paren = parens[child:type() .. "+"]
      else
        paren = parens[child:type()]
      end

      if paren ~= nil then
        next_count = next_count + paren[1]

        if paren[2] or (extended_mode and paren[3]) then
          color_node(bufnr, child, len, count)
        end

        await(M.highlight_node_recursive(parens, bufnr, extended_mode, child, len, next_count))

        if child:named() then
          next_count = next_count - paren[1]
        end
      elseif child:child_count() ~= 0 then
        await(M.highlight_node_recursive(parens, bufnr, extended_mode, child, len, next_count))
      end
    end
  end)

M.callbackfn = async(function(bufnr, parser, extended_mode)
  -- no need to do anything when pum is open
  if vim.fn.pumvisible() == 1 then
    return
  end

  --clear highlights or code commented out later has highlights too
  vim.api.nvim_buf_clear_namespace(bufnr, nsid, 0, -1)
  parser:parse()
  parser:for_each_tree(function(tree, lang_tree)
    local root_node = tree:root()

    local lang = lang_tree:lang()

    local parens
    if custom[lang] then
      parens = require("rainbow.langs." .. lang)
    else
      parens = require("rainbow.langs.default")
    end
    await(M.highlight_node_recursive(parens, bufnr, extended_mode, root_node, #colors, 1))
  end)
end)

function M.attach(bufnr, lang)
  local parser = parsers.get_parser(bufnr, lang)
  local config = configs.get_module("rainbow")

  local extended_mode = config.extended_mode or config.extended_mode[lang]
  await(M.callbackfn(bufnr, parser, extended_mode)) -- do it on attach
  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = void(async(function()
      await(M.callbackfn(bufnr, parser, extended_mode))
    end)),
  }) --do it on every change
end

function M.detach(bufnr)
  local hlmap = vim.treesitter.highlighter.hl_map
  hlmap["punctuation.bracket"] = "TSPunctBracket"
  vim.api.nvim_buf_clear_namespace(bufnr, nsid, 0, -1)
end

return M
