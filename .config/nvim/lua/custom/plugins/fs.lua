return {
  {
    'stevearc/oil.nvim',
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
    config = function()
      ---@module 'oil'
      ---@type oil.SetupOpts
      local opts = {
        view_options = {
          show_hidden = true,
        },
        keymaps = {
          ["<C-p>"] = false,
          ["<C-a>"] = { "actions.preview", opts = { split = "belowright" } },
        }
      }

      require('oil').setup(opts)

      local actions = require('oil.actions')

      vim.keymap.set("n", "<space>fb", ':Oil<CR>', { noremap = true, desc = '[F]ile [browser]' })
      vim.keymap.set("n", "<space>pf", actions.open_cwd.callback, { noremap = true, desc = '[P]roject [F]iles' })
      vim.keymap.set("n", "<C-f>", actions.open_cwd.callback, { noremap = true, desc = '[P]roject [F]iles' })
    end,
  }
}
