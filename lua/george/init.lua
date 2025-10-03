local M = {}

local defaults = {
    languages = {
        rust = {
            extension = ".rs",
            template = 'fn main() {\n\tgeorge\n\tprintln!("Hello World!");\n}',
            command = "rustc %s -o %s && %s"
        },
        c = {
            extension = ".c",
            template = '#include <stdio.h>\n\nint main() {\n\tgeorge\n\tprintf("Hello World!\n");\n\treturn 0;\n}',
            command = "cc %s -o %s && %s"
        },
        javascript = {
            extension = ".js",
            template = 'george\nconsole.log("Hello World!");',
            command = "node %s -o %s && %s"
        },
        python = {
            extension = ".py",
            template = 'george\nprint("Hello World!")',
            command = "python3 %s"
        },
        shell = {
            extension = ".sh",
            template = 'george\necho "Hello World!"',
            command = "sh %s"
        },
        bash = {
            extension = ".sh",
            template = 'george\necho "Hello World!"',
            command = "bash %s"
        },
        java = {
            extension = ".java",
            template = 'class George {\n\tpublic static void main(String[] args){\n\t\tgeorge\n\t\tSystem.out.println("Hello World!");\n\t}\n}',
            command = "javac %s -o %s && java %s"
        },
        chashtag = {
            extension = ".cs",
            template = 'public class George {\n\tpublic static void Main(string[] args){\n\t\tgeorge\n\t\tSystem.Console.println("Hello World!");\n\t}\n}',
            command = "csc %s"
        },
        cpp = {
            extension = ".cpp",
            template = '#include <iostream>\n\nint main(){\n\tgeorge\n\tstd::cout << "Hello World!" << std::endl;\n\treturn 0;\n}',
            command = "g++ %s -o %s && %s"
        },
        lua = {
            extension = ".lua",
            template = 'george\nprint("Hello World")',
            command = "lua %s"
        },
    }
}

local options = {}

-- taken from https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/utils.lua
-- MIT license
function get_visual_selection()
    local _, csrow, cscol, cerow, cecol
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" or mode == "" then
        _, csrow, cscol, _ = unpack(vim.fn.getpos("."))
        _, cerow, cecol, _ = unpack(vim.fn.getpos("v"))
        if mode == "V" then
            cscol, cecol = 0, 999
        end
    else
        return ""
    end
    if cerow < csrow then csrow, cerow = cerow, csrow end
    if cecol < cscol then cscol, cecol = cecol, cscol end
    local lines = vim.fn.getline(csrow, cerow)
    local n = #lines
    if n <= 0 then return "" end
    lines[n] = string.sub(lines[n], 1, cecol)
    lines[1] = string.sub(lines[1], cscol)
    return table.concat(lines, "\n"), {
        start   = { line = csrow, char = cscol },
        ["end"] = { line = cerow, char = cecol },
    }
end

function M.setup(opts)
    options = vim.tbl_deep_extend("force", defaults, opts or {})

    vim.api.nvim_create_user_command("GeorgeOpen", function(opts)
        local text = get_visual_selection()
        open_george(text)
    end, {range=true})

    vim.api.nvim_create_user_command("GeorgeRun", function(opts)
        local filetype = vim.bo.filetype
        local language = options.languages[filetype]
        local tempname = vim.fn.tempname()
        local tempfile = tempname .. language.extension
        local text = get_visual_selection()
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

return M
