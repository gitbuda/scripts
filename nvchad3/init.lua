-- Set some of the key maps
local function set_keymap(...) vim.api.nvim_set_keymap(...) end
local opts = { noremap=true, silent=true }
-- telescope live grep
set_keymap('n', '<leader>gg', '<cmd>:Telescope live_grep<CR>', opts)
set_keymap('n', '<leader>j', '<cmd>:JABSOpen<CR>', opts)
set_keymap('n', '<leader>tg', '<cmd>:TagbarToggle<CR>', opts)
set_keymap('n', '<leader>m', '<cmd>:make<CR>', opts)
