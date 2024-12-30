---@class pithyvim.util.ui
local M = {}

-- foldtext for Neovim < 0.10.0
function M.foldtext()
  return vim.api.nvim_buf_get_lines(0, vim.v.lnum - 1, vim.v.lnum, false)[1]
end

-- optimized treesitter foldexpr for Neovim >= 0.10.0
function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].ts_folds == nil then
    -- as long as we don't have a filetype, don't bother
    -- checking if treesitter is available (it won't)
    if vim.bo[buf].filetype == "" then
      return "0"
    end
    if vim.bo[buf].filetype:find("dashboard") then
      vim.b[buf].ts_folds = false
    else
      vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
    end
  end
  return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

--{{{> Qeuroal: fold
function M.toggleFoldmethod()
    -- 获取当前的 foldmethod
    local current_method = vim.o.foldmethod -- 检查当前的 foldmethod 并切换
    if current_method == 'expr' then
        vim.o.foldmethod = 'marker'
    elseif current_method == 'marker' then
        vim.o.foldmethod = 'expr'
    else
        -- 如果既不是 'expr' 也不是 'marker'，则设置为 'expr'
        vim.o.foldmethod = 'expr'
    end
end
--<}}}

return M
