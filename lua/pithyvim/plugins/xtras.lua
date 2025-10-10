-- Some extras need to be loaded before others
local prios = {
  ["pithyvim.plugins.extras.test.core"] = 1,
  ["pithyvim.plugins.extras.dap.core"] = 1,
  ["pithyvim.plugins.extras.coding.nvim-cmp"] = 2,
  ["pithyvim.plugins.extras.editor.neo-tree"] = 2,
  ["pithyvim.plugins.extras.ui.edgy"] = 3,
  ["pithyvim.plugins.extras.ai.copilot-native"] = 4,
  ["pithyvim.plugins.extras.coding.blink"] = 5,
  ["pithyvim.plugins.extras.lang.typescript"] = 5,
  ["pithyvim.plugins.extras.formatting.prettier"] = 10,
  -- default core extra priority is 20
  -- default priority is 50
  ["pithyvim.plugins.extras.editor.aerial"] = 100,
  ["pithyvim.plugins.extras.editor.outline"] = 100,
  ["pithyvim.plugins.extras.ui.alpha"] = 19,
  ["pithyvim.plugins.extras.ui.dashboard-nvim"] = 19,
  ["pithyvim.plugins.extras.ui.mini-starter"] = 19,
}

if vim.g.xtras_prios then
  prios = vim.tbl_deep_extend("force", prios, vim.g.xtras_prios or {})
end

local extras = {} ---@type string[]
local defaults = PithyVim.config.get_defaults()

-- Add extras from LazyExtras that are not disabled
for _, extra in ipairs(PithyVim.config.json.data.extras) do
  local def = defaults[extra]
  if not (def and def.enabled == false) then
    extras[#extras + 1] = extra
  end
end

-- Add default extras
for name, extra in pairs(defaults) do
  if extra.enabled then
    prios[name] = prios[name] or 20
    extras[#extras + 1] = name
  end
end

---@type string[]
extras = PithyVim.dedup(extras)

PithyVim.plugin.save_core()
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
