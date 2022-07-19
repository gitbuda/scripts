return {
   ["williamboman/nvim-lsp-installer"] = {},
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
   }
}
