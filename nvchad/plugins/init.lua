return {
   ["neovim/nvim-lspconfig"] = {
      config = function()
         require "plugins.configs.lspconfig"
         require "custom.plugins.lspconfig"
       end,
   },
   ["folke/trouble.nvim"] = {
      requires = "kyazdani42/nvim-web-devicons",
      config = function()
         require("trouble").setup {}
      end
   },
   ["~/Workspace/code/memgraph/memgraph/tools/vim-lcp"] = {},
   ["matbme/JABS.nvim"] = {
      cmd = "JABSOpen",
      config = function()
         require("jabs").setup {
            position = "center",
            width = 100,
            height = 20,
         }
      end,
   },
   ["romgrk/nvim-treesitter-context"] = {
      config = function()
         require("treesitter-context").setup {
            enable = true,
            zindex = 1000,
            mode = "topline",
         }
      end
   },
   ["majutsushi/tagbar"] = {
      config = function()
         vim.cmd [[
            let g:tagbar_width = 75
         ]]
      end
   },
   ["airblade/vim-gitgutter"] = {
      config = function()
         vim.cmd [[
           let g:gitgutter_diff_base = 'HEAD~3'
         ]]
      end
   },
   ["tpope/vim-fugitive"] = {},
   ["https://git.sr.ht/~whynothugo/lsp_lines.nvim"] = {
      config = function()
         require("lsp_lines").setup {}
      end
   },
}
