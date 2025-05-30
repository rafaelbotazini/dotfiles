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
      on_attach = function(client, bufnr)
        require('config.mappings').setup_lsp_keymaps(client, bufnr)
      end,
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

-- Setup neovim lua configuration
require('lazydev').setup()

-- Setup null-ls to provide diagnostics via LSP integration with other plugins
local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
    -- null_ls.builtins.diagnostics.eslint_d,
  },
})
