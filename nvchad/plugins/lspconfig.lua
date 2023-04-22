-- A custom config for lsp-config plugin.
local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")
local servers = { "clangd", "html", "pyright", "rust_analyzer", "tsserver" }

for _, lsp in ipairs(servers) do
        local opts = {
                on_attach = attach,
                capabilities = capabilities,
        }
        if lsp == "clangd" then
                opts.filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "lcp" }
        end
        lspconfig[lsp].setup(opts)
end
