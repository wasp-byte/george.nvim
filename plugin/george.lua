vim.api.nvim_create_user_command("GeorgeOpen", function()
  require("george").open_george()
end, {})
