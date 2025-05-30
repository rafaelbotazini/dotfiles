local signs = { Error = "", Warn = "", Hint = "󰌶", Info = "" }

for type, icon in pairs(signs) do
  vim.fn.sign_define("DiagnosticSign" .. type, { text = icon })
end

return {
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup({
        '*',
        css = { css = true, },
      }, {
        mode = 'background',
      })
    end,
  },

  { -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = true,
        theme = 'gruvbox-material',
        -- theme = 'vscode',
        -- theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_c = {
          { 'filename', path = 1 }
        },
      }
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },

  -- Smooth scrolling
  -- { 'karb94/neoscroll.nvim', opts = {} },

  {
    -- Adds scrollbar
    'dstein64/nvim-scrollview',
    config = function()
      vim.g.scrollview_diagnostics_info_symbol = signs.Info
      vim.g.scrollview_diagnostics_hint_symbol = signs.Hint
      vim.g.scrollview_diagnostics_warn_symbol = signs.Warn
      vim.g.scrollview_diagnostics_error_symbol = signs.Error
      require('scrollview.contrib.gitsigns').setup()
    end,
    dependencies = {
      'lewis6991/gitsigns.nvim',
    }
  },
  {
    'f4z3r/gruvbox-material.nvim',
    name = 'gruvbox-material',
    lazy = false,
    priority = 1000,
    opts = {
      contrast = 'hard',
      signs = {
        highlight = false
      }
    },
  },
  -- {
  --   'Mofiqul/vscode.nvim',
  --   priority = 1000,
  --   config = function()
  --     require('vscode').setup {
  --       transparent = true
  --     }
  --     vim.cmd.colorscheme 'vscode'
  --   end,
  -- },
  -- { -- Theme inspired by Atom
  --  'navarasu/onedark.nvim',
  --  priority = 1000,
  --  config = function()
  --    require('onedark').setup {
  --      style = 'warmer'
  --    }
  --    vim.cmd.colorscheme 'onedark'
  --  end,
  -- },

  -- { -- Add indentation guides even on blank lines
  --   'lukas-reineke/indent-blankline.nvim',
  --   -- Enable `lukas-reineke/indent-blankline.nvim`
  --   -- See `:help indent_blankline.txt`
  --   opts = {
  --     indent = {
  --       char = '▏'
  --
  --     },
  --     whitespace = {
  --       remove_blankline_trail = false,
  --     },
  --   },
  --   main = 'ibl',
  -- },
}
