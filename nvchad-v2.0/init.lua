-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })

-- Use build as a make directory
vim.cmd [[ let &makeprg="(source /opt/toolchain-v4/activate && cd build && make -j16)" ]]
vim.cmd [[
   function! UpdateMakePrgBuildDir(path)
      let &makeprg="(cd ".a:path." && make -j16)"
   endfunction
]]
-- <leader>m is :make

-- Set some of the key maps
local function set_keymap(...) vim.api.nvim_set_keymap(...) end
local opts = { noremap=true, silent=true }
set_keymap('n', '<leader>gg', '<cmd>:Telescope live_grep<CR>', opts)
set_keymap('n', '<leader>j', '<cmd>:JABSOpen<CR>', opts)
set_keymap('n', '<leader>tg', '<cmd>:TagbarToggle<CR>', opts)
set_keymap('n', '<leader>m', '<cmd>:make<CR>', opts)
