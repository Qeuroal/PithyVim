vim.uv = vim.uv or vim.loop

local M = {}

---@param opts? PithyVimConfig
function M.setup(opts)
  require("pithyvim.config").setup(opts)
end

return M
