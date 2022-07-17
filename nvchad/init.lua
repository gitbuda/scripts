-- Use build as a make directory
vim.cmd [[ let &makeprg="(source /opt/toolchain-v4/activate && cd build && make -j8)" ]]
vim.cmd [[
   function! UpdateMakePrgBuildDir(path)
      let &makeprg="(cd ".a:path." && make -j8)"
   endfunction
]]

-- Set some of the key maps
local function set_keymap(...) vim.api.nvim_set_keymap(...) end
local opts = { noremap=true, silent=true }
-- telescope live grep
set_keymap('n', '<leader>gg', '<cmd>:Telescope live_grep<CR>', opts)

vim.diagnostic.disable()
