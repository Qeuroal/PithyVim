return {
  recommended = function()
    return PithyVim.extras.wants({
      ft = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      },
      root = { "tsconfig.json", "package.json", "jsconfig.json" },
    })
  end,

  -- correctly setup lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        ---@type lspconfig.settings.tsgo
        tsgo = {
          -- explicitly add default filetypes, so that we can extend
          -- them in related extras
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          settings = {
            typescript = {
              inlayHints = {
                parameterNames = {
                  enabled = "literals",
                  suppressWhenArgumentMatchesName = true,
                },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = false },
                enumMemberValues = { enabled = true },
              },
            },
          },
        },
      },
    },
  },
  -- correctly setup lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = {},
  },
}
