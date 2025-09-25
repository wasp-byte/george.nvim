local M = {}

local defaults = {
    languages = {
        rust = {
            extension = ".rs",
            template = [[fn main() {
                george
                println!("Hello World!");
            }]],
            command = "rustc /tmp/george.rs -o /tmp/george && /tmp/george"
        }
    }
}

local options = {
    languages = {
        rust = {
            extension = "",
            template = "",
            command = "",
        }
    }
}
local language = defaults

function M.setup(opts)
    options = vim.tbl_deep_extend("force", defaults, opts or {})

    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "george*",
        callback = function()
            local filetype = vim.bo.filetype
            language = options.languages[filetype]
            vim.cmd("!" .. language.command)
        end,
    })
end

function find_george(text)
    vim.cmd("%s/george/" .. text)
    vim.cmd("insert")
end

function M.open_george()
    local filetype = vim.bo.filetype
    local language = options.languages[filetype]
    vim.cmd("vsplit")
    vim.cmd("wincmd w")
    local buf = vim.api.nvim_create_buf(true, false)
    local lines = vim.split(language.template, "\n", true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_current_buf(buf)
    vim.cmd("save! /tmp/george" .. language.extension)
    vim.cmd("wincmd |")
    find_george("asdfsdf")
end

return M
