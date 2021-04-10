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
local extended_languages = {
        'bash',
        'html',
        'jsx',
        'latex',
        'lua',
        'ocaml',
        'ruby',
        'verilog',
        'json',
        'yaml'
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

MATCHES = {}

-- get the rainbow level nodes for a specific syntax
local function get_rainbow_matches(bufnr, query, root, lang)
        local _matches = queries.get_capture_matches(bufnr, query, 'rainbow', root, lang)
        local matches = {}
        for _, node in pairs(_matches) do
                table.insert(MATCHES, tostring(node.node))
                matches[node.node:type()] = true
        end

        return matches
end

local function highlight_node_recursive(bufnr, node, levels, parens, len, count)
        for child in node:iter_children() do
                if levels[child:type()] then
                        highlight_node_recursive(bufnr, child, levels, parens, len, count + 1)
                        -- try_async(highlight_node_recursive, bufnr, child, levels, parens, len, count + 1)
                else
                        highlight_node_recursive(bufnr, child, levels, parens, len, count)
                        -- try_async(highlight_node_recursive, bufnr, child, levels, parens, len, count)
                end
                if parens[child:type()] then
                        -- table.insert(DEBUG, child:type())
                        color_node(bufnr, child, len, count)
                end
        end
end

local callbackfn = function(bufnr, parser)
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
                local levels = get_rainbow_matches(bufnr, '@rainbow.level', root_node, lang)
                local parens = get_rainbow_matches(bufnr, '@rainbow.paren', root_node, lang)
                -- PARENS = parens
                -- LEVELS = levels
                highlight_node_recursive(bufnr, root_node, levels, parens, #colors, 0)
        end)
end

local function register_predicates(config)
        for _, lang in pairs(extended_languages) do
                local enable_extended_mode
                if type(config.extended_mode) == "table" then
                        enable_extended_mode = config.extended_mode[lang]
                else
                        enable_extended_mode = config.extended_mode
                end
                nvim_query.add_predicate(lang .. "-extended-rainbow-mode?", function()
                        return enable_extended_mode
                end, true)
        end
end

local M = {}

function M.attach(bufnr, lang)
        local parser = parsers.get_parser(bufnr, lang)
        local config = configs.get_module("rainbow")
        register_predicates(config)

        local attachf, detachf = try_async(callbackfn, bufnr, parser)
        state_table[bufnr] = detachf
        callbackfn(bufnr, parser) -- do it on attach
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
