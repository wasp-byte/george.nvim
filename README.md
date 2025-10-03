# George

In times when you are **curious** about the output of a code snippet. George gives you the ability to execute it or open in a playground.

## Installation

lazy.nvim
```lua
return {
    "wasp-byte/george.nvim",
    config = function()
        require("george").setup {}
        vim.keymap.set({"n", "v"}, "<leader>go", "<CMD>GeorgeOpen<CR>"),
        vim.keymap.set("v", "<leader>gr", "<CMD>GeorgeRun<CR>")
    end,
}
```
