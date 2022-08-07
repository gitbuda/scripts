local M = {}

M.plugins = {
   override = {
      ["nvim-treesitter/nvim-treesitter"] = {
         ensure_installed = {
            "vim",
            "html",
            "css",
            "javascript",
            "json",
            "toml",
            "markdown",
            "c",
            "cpp",
            "bash",
            "lua",
            "norg",
         }
      },
   },
   user = require "custom.plugins"
}

M.mappings = require "custom.mappings"

return M
