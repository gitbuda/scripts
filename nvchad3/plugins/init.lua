return {
  ["neovim/nvim-lspconfig"] = {
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.plugins.lspconfig"
    end,
  },
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
  ["majutsushi/tagbar"] = {
    config = function()
      vim.cmd [[
        let g:tagbar_width = 75
      ]]
    end
  },
}
