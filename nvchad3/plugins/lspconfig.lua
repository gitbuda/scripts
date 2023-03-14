local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = { "clangd", "rust_analyzer", "pyright" }

for _, lsp in ipairs(servers) do
  local opts = {
    on_attach = on_attach,
    capabilities = capabilities,
  }
  if lsp == "clangd" then
    opts.filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "lcp" }
    opts.cmd = {
      "clangd",
      "--clang-tidy",
    }
  end
  lspconfig[lsp].setup(opts)
end
