local queries = require("nvim-treesitter.query")
local nvim_query = require("vim.treesitter.query")
local parsers = require("nvim-treesitter.parsers")
local configs = require("nvim-treesitter.configs")
local locals = require("nvim-treesitter.locals")
local nsid = vim.api.nvim_create_namespace("rainbow_ns")
local colors = require("rainbow.colors")
local termcolors = require("rainbow.termcolors")
local async_lib = require("plenary.async_lib")
local state_table = {} -- tracks which buffers have rainbow disabled
local custom = {
        ['html'] = true,
        ['jsx'] = true,
        ['lua'] = true,
        ['python'] = true,
        ['ruby'] = true,
        ['svelte'] = true,
        ['toml'] = true,
        ['tsx'] = true,
}

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

local function try_async(f, v1, v2, v3, v4, v5, v6)
        local cancel = false
        return function()
                if cancel then
                        return true
                end
                local async_handle
                async_handle = vim.loop.new_async(vim.schedule_wrap(function()
                        f(v1, v2, v3, v4, v5, v6)
                        async_handle:close()
                end))
                async_handle:send()
        end, function()
                cancel = true
        end
end


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

VALUES = {}
local function highlight_node_recursive(lang, extended_mode, node, len, count)
        local next_count = count

        local parens = {}
        if custom[lang] then
                parens = require('rainbow.langs.' .. lang)
        else
                parens = require('rainbow.langs.default')
        end

        for child in node:iter_children() do
                local paren = {}
                if child:named() then
                        paren = parens[child:type() .. '+']
                else
                        paren = parens[child:type()]
                end

                if paren ~= nil then
                        table.insert(VALUES, child:type())
                        next_count = next_count + paren[1]

                        if paren[2] or (extended_mode and paren[3]) then
                                color_node(lang, child, len, count)
                        end

                        highlight_node_recursive(lang, extended_mode, child, len, next_count)

                        if child:named() then
                                next_count = next_count - paren[1]
                        end
                elseif child:child_count() ~= 0 then
                        highlight_node_recursive(lang, extended_mode, child, len, next_count)
                end
        end
end

local function callbackfn(bufnr, parser, extended_mode)
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
                highlight_node_recursive(lang, extended_mode, root_node, #colors, 1)
        end)
end

local M = {}

function M.attach(bufnr, lang)
        local parser = parsers.get_parser(bufnr, lang)
        local config = configs.get_module("rainbow")
        -- register_predicates(config)

        local extended_mode = config.extended_mode or config.extended_mode[lang]
        local attachf, detachf = try_async(callbackfn, bufnr, parser, extended_mode)
        state_table[bufnr] = detachf
        callbackfn(bufnr, parser, extended_mode) -- do it on attach
        vim.api.nvim_buf_attach(bufnr, false, { on_lines = attachf }) --do it on every change
end

function M.detach(bufnr)
        local detachf = state_table[bufnr]
        detachf()
        local hlmap = vim.treesitter.highlighter.hl_map
        hlmap["punctuation.bracket"] = "TSPunctBracket"
        vim.api.nvim_buf_clear_namespace(bufnr, nsid, 0, -1)
end

return M
