local mappings = {}

mappings.setup = function()
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

  -- Diagnostic keymaps
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
end

mappings.setup_lsp_keymaps = function(_, bufnr)
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

return mappings
