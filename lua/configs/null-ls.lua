local null_ls = require("null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.rustfmt,
    null_ls.builtins.formatting.gofmt,
  },
  debug = true,

})

