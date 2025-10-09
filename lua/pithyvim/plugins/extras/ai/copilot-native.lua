---@diagnostic disable: missing-fields
if pithyvim_docs then
  -- Native inline completions don't support being shown as regular completions
  vim.g.ai_cmp = false
end

if PithyVim.has_extra("ai.copilot-native") then
  if not vim.lsp.inline_completion then
    PithyVim.error("You need Neovim >= 0.12 to use the `ai.copilot-native` extra.")
    return {}
  end
  if PithyVim.has_extra("ai.copilot") then
    PithyVim.error("Please disable the `ai.copilot` extra if you want to use `ai.copilot-native`")
    return {}
  end
end

vim.g.ai_cmp = false
local status = {} ---@type table<number, "ok" | "error" | "pending">

return {
  desc = "Native Copilot LSP integration. Requires Neovim >= 0.12",
  -- copilot-language-server
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        copilot = {
          -- stylua: ignore
          keys = {
            {
              "<M-]>",
              function() vim.lsp.inline_completion.select({ count = 1 }) end,
              desc = "Next Copilot Suggestion",
              mode = { "i", "n" },
            },
            {
              "<M-[>",
              function() vim.lsp.inline_completion.select({ count = -1 }) end,
              desc = "Prev Copilot Suggestion",
              mode = { "i", "n" },
            },
          },
        },
      },
      setup = {
        copilot = function()
          vim.schedule(function()
            vim.lsp.inline_completion.enable()
          end)
          -- Accept inline suggestions or next edits
          PithyVim.cmp.actions.ai_accept = function()
            return vim.lsp.inline_completion.get()
          end

          if not PithyVim.has_extra("ai.sidekick") then
            vim.lsp.config("copilot", {
              handlers = {
                didChangeStatus = function(err, res, ctx)
                  if err then
                    return
                  end
                  status[ctx.client_id] = res.kind ~= "Normal" and "error" or res.busy and "pending" or "ok"
                  if res.status == "Error" then
                    PithyVim.error("Please use `:LspCopilotSignIn` to sign in to Copilot")
                  end
                end,
              },
            })
          end
        end,
      },
    },
  },

  -- lualine
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      if PithyVim.has_extra("ai.sidekick") then
        return
      end
      table.insert(
        opts.sections.lualine_x,
        2,
        PithyVim.lualine.status(PithyVim.config.icons.kinds.Copilot, function()
          local clients = vim.lsp.get_clients({ name = "copilot", bufnr = 0 })
          return #clients > 0 and status[clients[1].id] or nil
        end)
      )
    end,
  },
}
