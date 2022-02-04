local M = {}
M.options, M.ui, M.mappings, M.plugins = {}, {}, {}, {}

local userPlugins = require "custom.plugins"
local userPluginsConfigs = require "custom.plugins.configs"

M.plugins = {
   options = {
      lspconfig = {
         setup_lspconf = "custom.plugins.lspconfig",
      },
   },
   default_plugin_config_replace = {
      nvim_treesitter = userPluginsConfigs.treesitter,
      nvim_tree = userPluginsConfigs.nvimtree,
   },
   install = userPlugins,
}

return M
