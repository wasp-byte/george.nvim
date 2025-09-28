local M = {}

local defaults = {
    languages = {
        rust = {
            extension = ".rs",
            template = 'fn main() {\n\tgeorge\n\tprintln!("Hello World!");\n}',
            command = "rustc %s -o %s && %s"
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

function M.setup(opts)
    options = vim.tbl_deep_extend("force", defaults, opts or {})

    vim.api.nvim_create_user_command("GeorgeOpen", function(opts)
        local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
        local text = table.concat(lines, "\n")
        open_george(text)
    end, {range=true})

    vim.api.nvim_create_user_command("GeorgeCompile", function(opts)
        local filetype = vim.bo.filetype
        local language = options.languages[filetype]
        local tempname = vim.fn.tempname()
        local tempfile = tempname .. language.extension
        local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
        local text = table.concat(lines, "\n")
        text = replace_george(language.template, text)
        vim.fn.writefile(vim.fn.split(text, "\n"), tempfile)
        vim.cmd("!" .. string.format(language.command, tempfile, tempname, tempname))
    end, {range=true})
end

function replace_george(template, text)
    return string.gsub(template, "george", text)
end

function open_george(text)
    local filetype = vim.bo.filetype
    local language = options.languages[filetype]
    local tempname = vim.fn.tempname()
    local tempfile = tempname .. language.extension
    text = replace_george(language.template, text)
    vim.fn.writefile(vim.fn.split(text, "\n"), tempfile)
    vim.cmd("vsplit")
    vim.cmd("wincmd w")
    vim.cmd("edit" .. tempfile)
    vim.cmd("wincmd |")

    local group = vim.api.nvim_create_augroup("George", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function()
            vim.cmd("!" .. string.format(language.command, tempfile, tempname, tempname))
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd("BufLeave", {
        callback = function()
            vim.api.nvim_del_augroup_by_id(group)
        end,
        group = group,
    })
end

function M.select()
    local text = get_visual_selection()
    open_george(text)
end

return M
