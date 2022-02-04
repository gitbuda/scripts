-- Use build as a make directory
vim.cmd [[ let &makeprg="(cd build && make -j8)" ]]
vim.cmd [[
   function! UpdateMakePrgBuildDir(path)
      let &makeprg="(cd ".a:path." && make -j8)"
   endfunction
]]

-- Bruteforce lsp-config mappings because the buffer ones doesn't work for some reason
local function set_keymap(...) vim.api.nvim_set_keymap(...) end
local opts = { noremap=true, silent=true }
  -- See `:help vim.lsp.*` for documentation on any of the below functions
set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
