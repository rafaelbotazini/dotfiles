-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

local signs = { Error = "", Warn = "", Hint = "󰌶", Info = "" }

for type, icon in pairs(signs) do
  vim.fn.sign_define("DiagnosticSign" .. type, { text = icon })
end


-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Smooth scroll plugin
  -- { 'karb94/neoscroll.nvim', opts = {} },

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'sindrets/diffview.nvim',
  'nvim-tree/nvim-web-devicons',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Use Neovim as language server to inject diagnostics, code actions, and more
  'nvimtools/none-ls.nvim',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      {
        'williamboman/mason-lspconfig.nvim',
        version = "1.32.0",
      },
      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      {
        'j-hui/fidget.nvim',
        tag = "legacy",
        opts = {},
      },

      'hrsh7th/cmp-nvim-lsp',

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = {
      "zbirenbaum/copilot.lua",
    },
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
      require("copilot_cmp").setup()
    end
  },
  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          'rafamadriz/friendly-snippets',
          config = function()
            require('luasnip.loaders.from_vscode').lazy_load()
          end,
        },
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'onsails/lspkind.nvim',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require 'lspkind'

      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<C-m>'] = cmp.mapping.abort,
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            cmp.config.compare.offset,
            -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
            cmp.config.compare.exact,

            require("copilot_cmp.comparators").prioritize,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
        sources = {
          { name = 'copilot' },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = 'symbol', -- show only symbol annotations
            maxwidth = {
              -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
              -- can also be a function to dynamically calculate max width such as
              -- menu = function() return math.floor(0.45 * vim.o.columns) end,
              menu = 50,              -- leading text (labelDetails)
              abbr = 50,              -- actual suggestion item
            },
            ellipsis_char = '...',    -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
            show_labelDetails = true, -- show labelDetails in menu. Disabled by default
            symbol_map = { Copilot = "" }
          })
        }
      }
    end
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',  opts = {} },
  { -- Adds git releated signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add          = { text = '┃', },
        change       = { text = '┃' },
        delete       = { text = '┃' },
        topdelete    = { text = '┃' },
        changedelete = { text = '┃' },
        untracked    = { text = '┃' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          if opts.desc then
            opts.desc = 'Git: ' .. opts.desc
          end
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = 'Next change' })

        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = 'Prev change' })

        -- Actions
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset hunk' })
        map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
          { desc = 'Stage selected hunk' })
        map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
          { desc = 'Reset selected hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview hunk' })
        map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = 'Blame line' })
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'Toggle Line Blame' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'Diff this' })
        map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = 'Diff this ~' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'Toggle deleted' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'Toggle deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
      end
    },
  },
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
  --


  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },
  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim' }
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim" }
  },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
  },
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ["<C-p>"] = false,
        ["<C-a>"] = { "actions.preview", opts = { split = "belowright" } },
      }
    },
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  }
  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below automatically adds your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  --
  --    An additional note is that if you only copied in the `init.lua`, you can just comment this line
  --    to get rid of the warning telling you that there are not plugins in `lua/custom/plugins/`.
  -- { import = 'custom.plugins' },
  --
})

-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Disable line wrap
vim.o.wrap = false

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 100
vim.o.timeout = true
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- vim.o.foldcolumn = '4'
vim.opt.fillchars = "eob:~,fold:-,foldopen:󰛲,foldclose:,diff: "
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldenable = false

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, { pattern = { "*" }, command = "normal zR", })

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { noremap = true, silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set({ 'n', 'i' }, '<C-h>', ':nohl<CR>', { silent = true })
vim.keymap.set('n', 'ZA', ':quitall<CR>', { silent = true })

vim.keymap.set('n', '<leader>hv', ':DiffviewOpen<CR>', { desc = 'Git: Diff [V]iew' })
vim.keymap.set('n', '<leader>hc', ':DiffviewClose<CR>', { desc = 'Git: [C]lose Diff View' })
vim.keymap.set('n', '<leader>hh', ':DiffviewFileHistory<CR>', { desc = 'Git: View Current Branch File [H]istory' })
vim.keymap.set('n', '<leader>hH', ':DiffviewFileHistory %<CR>', { desc = 'Git: View Current File [H]istory' })

vim.keymap.set('n', '<a-h>', '<c-w>h', { desc = 'Window: move cursor to window at left side' })
vim.keymap.set('n', '<a-j>', '<c-w>j', { desc = 'Window: move cursor to window below' })
vim.keymap.set('n', '<a-k>', '<c-w>k', { desc = 'Window: move cursor to window above' })
vim.keymap.set('n', '<a-l>', '<c-w>l', { desc = 'Window: move cursor to window at right side' })

vim.keymap.set('n', '<a-s-h>', '<c-w><', { desc = 'Window: decrease width' })
vim.keymap.set('n', '<a-s-j>', '<c-w>+', { desc = 'Window: increase height' })
vim.keymap.set('n', '<a-s-k>', '<c-w>-', { desc = 'Window: decrease height' })
vim.keymap.set('n', '<a-s-l>', '<c-w>>', { desc = 'Window: increase width' })

vim.keymap.set('n', '<leader>Q', ':copen<CR>', { desc = '[Q]uickfix list: Open' })
vim.keymap.set('n', ']q', ':cnext<CR>', { desc = '[Q]uickfix list: Next item' })
vim.keymap.set('n', '[q', ':cprev<CR>', { desc = '[Q]uickfix list: Previous item' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  pickers = {
    find_files = {
      -- hidden = true
    },
    buffers = {
      mappings = {
        n = {
          ['<C-D>'] = require('telescope.actions').delete_buffer
        },
        i = {
          ['<C-D>'] = require('telescope.actions').delete_buffer
        },
      },
    },
  },
  extensions = {
    file_browser = {
      -- theme = "ivy",
      -- disables netrw and use telescope-file-browser in its place
      -- hijack_netrw = true,
    },
  },
}

-- Enable telescope fzf native, if installed
-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'file_browser')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', require('telescope.builtin').current_buffer_fuzzy_find,
  { desc = '[/] Fuzzily search in current buffer' })

-- vim.keymap.set('n', '<leader>/', function()
--   -- You can pass additional configuration to telescope to change theme, layout, etc.
--   require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
--     winblend = 10,
--     previewer = false,
--   })
-- end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<c-p>', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })

vim.keymap.set("n", "<space>fb", ':Oil<CR>', { noremap = true, desc = '[F]ile [browser]' })
vim.keymap.set("n", "<space>pf", require('oil.actions').open_cwd.callback, { noremap = true, desc = '[P]roject [F]iles' })
vim.keymap.set("n", "<C-f>", require('oil.actions').open_cwd.callback, { noremap = true, desc = '[P]roject [F]iles' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  modules = {},
  sync_install = false,
  ignore_install = {},
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'c',
    'cpp',
    'css',
    'go',
    -- 'help',
    'html',
    'lua',
    'python',
    'php',
    'rust',
    'scss',
    'tsx',
    'typescript',
    'javascript',
    'vim',
    'vue'
  },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,

  highlight = { enable = true },
  indent = { enable = true, disable = { 'python' } },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<c-backspace>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.

  local mmap = function(mode, keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    if (type(keys) ~= "table") then
      keys = { keys }
    end

    for _, k in pairs(keys) do
      vim.keymap.set(mode, k, func, { buffer = bufnr, desc = desc })
    end
  end

  local nmap = function(keys, func, desc)
    mmap('n', keys, func, desc)
  end


  nmap({ '<leader>rn', '<F2>' }, vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('gh', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
    '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
    vim.lsp.buf.format({
      timeout_ms = 10000,
      filter = function(client)
        -- print(client.name)
        -- ignore volar, eslint and ts_ls formatting
        -- js related files will be formatted using prettier
        return client.name ~= 'volar' and client.name ~= 'eslint' and client.name ~= 'ts_ls'
      end
    })
  end, { desc = 'Format current buffer with LSP', })

  mmap({ 'n', 'v' }, '<leader>ff', ':Format<CR>', 'LSP: [F]ormat current buffer')
  mmap({ 'n', 'v' }, '<leader>oo', ':OrganizeImports<CR>', 'LSP: [O]rganize imports')
end



-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--  https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
local servers = {
  -- clangd = {},
  gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  eslint = {},
  volar = {
    on_attach = function(client, bufnr)
      client.server_capabilities.documentFormattingProvider = false
      -- vim.api.nvim_create_autocmd("BufWritePre", {
      --   buffer = bufnr,
      --   command = "OrganizeImports",
      -- })
    end,
  },
  ts_ls = {
    init_options = {
      plugins = {
        {
          name = "@vue/typescript-plugin",
          location = '/home/rafael/.asdf/installs/nodejs/20.18.2/lib/node_modules/@vue/typescript-plugin',
          languages = { "javascript", "typescript", "vue" },
        },
      },
    },
    filetypes = {
      'typescript',
      'javascript',
      'javascriptreact',
      'typescriptreact',
      'vue',
    },
    commands = {
      OrganizeImports = {
        function()
          local params = {
            command = "_typescript.organizeImports",
            arguments = { vim.api.nvim_buf_get_name(0) },
            title = "",
          }
          vim.lsp.buf.execute_command(params)
        end,
        description = "Organize Imports",
      },
    },
  },
  html = {
    filetypes = {
      "html",
    },
  },
  emmet_ls = {
    filetypes = {
      "css",
      "eruby",
      "javascriptreact",
      "typescriptreact",
      "less",
      "sass",
      "scss",
      "svelte",
      "vue"
    },
  },
  -- vtsls = {},
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    }
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
  automatic_installation = false
}

mason_lspconfig.setup_handlers {
  function(server_name)
    local options = {
      capabilities = capabilities,
      on_attach = on_attach,
    }
    local settings = servers[server_name]

    if (settings) then
      for k, v in pairs(settings) do
        options[k] = v
      end
    end

    require('lspconfig')[server_name].setup(options)
  end,
}


-- Setup null-ls to provide diagnostics via LSP integration with other plugins
local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
    -- null_ls.builtins.diagnostics.eslint_d,
  },
})

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
})

-- nvim-cmp setup

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
