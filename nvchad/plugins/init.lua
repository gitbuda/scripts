return {
   {
      "williamboman/nvim-lsp-installer",
   },
   {
      "folke/trouble.nvim",
      requires = "kyazdani42/nvim-web-devicons",
      config = function()
         require("trouble").setup {
         }
      end
   },
   {
      "~/Workspace/code/memgraph/memgraph/tools/vim-lcp"
   }
}
