local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options
  -- {
  --    "nvim-telescope/telescope.nvim",
  --    config = function()
  --       require("jabs").setup {
  --          defaults = { file_ignore_patterns = { "^./.git/", "^node_modules/", "^vendor/", "^target/" } }
  --       }
  --    end,
  -- },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- format & linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  {
    "matbme/JABS.nvim",
    lazy = false,
    config = function()
      require("jabs").setup {
        position = "center",
        width = 100,
        height = 20,
      }
    end,
  },

  {
    "majutsushi/tagbar",
    config = function()
      vim.cmd [[
        let g:tagbar_width = 75
      ]]
    end
  },

  {
    "Bryley/neoai.nvim",
    lazy = false,
    config = function()
      require("neoai").setup {
        ui = {
        output_popup_text = "NeoAI",
        input_popup_text = "Prompt",
        width = 30,      -- As percentage eg. 30%
        output_popup_height = 80, -- As percentage eg. 80%
      },
    }
    end,
    dependencies = { "MunifTanjim/nui.nvim" },
  },

}

return plugins
