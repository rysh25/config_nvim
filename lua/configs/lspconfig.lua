local configs = require("nvchad.configs.lspconfig")

local on_init = configs.on_init
local capabilities = configs.capabilities


vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- 保存時に自動フォーマット
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = { "*.rs", "*.py", "*.ts", "*.go", "*.c", "*.h", "*.cpp", "*.hpp" },
      callback = function()
        vim.lsp.buf.format({
          buffer = ev.buf,
          timeout_ms = 200,
          filter = function(f_client)
            -- TypeScriptのようにNode.js, Deno, Bunのどれを使うかによって、
            -- none-ls (Biome, Prettier) の有無が変わる場合、none-ls の複数回実行を防止するため
            return f_client.name ~= "null-ls"
          end,
          async = false,
        })
      end,
    })
  end,
})

-- Set updatetime for CursorHold
-- 300ms of no cursor movement to trigger CursorHold
vim.opt.updatetime = 100

-- Show diagnostic popup on cursor hover
local diag_float_grp = vim.api.nvim_create_augroup("DiagnosticFloat", { clear = true })
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
  group = diag_float_grp,
})

local function set_keymap(client, buffer)
  local keymap_opts = { buffer = buffer }

  vim.keymap.set("n", "ga", vim.lsp.buf.code_action, keymap_opts)

  -- Goto previous/next diagnostic warning/error
  vim.keymap.set("n", "g[", vim.diagnostic.goto_prev, keymap_opts)
  vim.keymap.set("n", "g]", vim.diagnostic.goto_next, keymap_opts)
end

local function on_attach(client, buffer)
  require("nvchad.configs.lspconfig").on_attach(client, buffer)

  set_keymap(client, buffer)
end

local lspconfig = require "lspconfig"
local util = require "lspconfig/util"
local servers = { "html", "cssls" }

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

-- rust-analyzer
lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern("Cargo.toml", "rust-project.json"),
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy",
      },
    },
  },
})

-- typescript
lspconfig.tsserver.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}

-- golang
lspconfig.gopls.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  cmd = {"gopls"},
  filetypes = {"go", "gomod", "gowork", "gotmpl"},
  root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      }
    }
  },
}

-- clangd
lspconfig.clangd.setup {
  init_options = {
    fallbackFlags = {'--std=c++20'}
  }
}
