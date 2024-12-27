-- Some extras need to be loaded before others
local prios = {
  ["pithyvim.plugins.extras.test.core"] = 1,
  ["pithyvim.plugins.extras.dap.core"] = 1,
  ["pithyvim.plugins.extras.coding.nvim-cmp"] = 2,
  ["pithyvim.plugins.extras.ui.edgy"] = 2,
  ["pithyvim.plugins.extras.lang.typescript"] = 5,
  ["pithyvim.plugins.extras.coding.blink"] = 5,
  ["pithyvim.plugins.extras.formatting.prettier"] = 10,
  -- default priority is 50
  ["pithyvim.plugins.extras.editor.aerial"] = 100,
  ["pithyvim.plugins.extras.editor.outline"] = 100,
}

if vim.g.xtras_prios then
  prios = vim.tbl_deep_extend("force", prios, vim.g.xtras_prios or {})
end

---@type string[]
local extras = PithyVim.dedup(PithyVim.config.json.data.extras)

local version = vim.version()
local v = version.major .. "_" .. version.minor

local compat = { "0_9" }

PithyVim.plugin.save_core()
if vim.tbl_contains(compat, v) then
  table.insert(extras, 1, "pithyvim.plugins.compat.nvim-" .. v)
end
if vim.g.vscode then
  table.insert(extras, 1, "pithyvim.plugins.extras.vscode")
end

table.sort(extras, function(a, b)
  local pa = prios[a] or 50
  local pb = prios[b] or 50
  if pa == pb then
    return a < b
  end
  return pa < pb
end)

---@param extra string
return vim.tbl_map(function(extra)
  return { import = extra }
end, extras)
