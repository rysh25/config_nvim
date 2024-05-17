vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
    config = function()
      require "options"
    end,
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)


vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        -- 開いているファイルまたはディレクトリのパスを取得
        local path = vim.fn.argv(0)
        if vim.fn.isdirectory(path) == 1 then
            -- ディレクトリの場合、そのディレクトリをカレントディレクトリに設定
            vim.cmd('cd ' .. path)
        else
            -- ファイルの場合、そのファイルの親ディレクトリをカレントディレクトリに設定
            vim.cmd('cd ' .. vim.fn.fnamemodify(path, ':p:h'))
        end
    end,
    once = true,
})
