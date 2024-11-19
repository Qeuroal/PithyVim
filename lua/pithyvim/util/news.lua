---@class pithyvim.util.news
local M = {}

function M.hash(file)
  local stat = vim.uv.fs_stat(file)
  if not stat then
    return
  end
  return stat.size .. ""
end

function M.setup()
  vim.schedule(function()
    if PithyVim.config.news.pithyvim then
      if not PithyVim.config.json.data.news["NEWS.md"] then
        M.welcome()
      end
      M.pithyvim(true)
    end
    if PithyVim.config.news.neovim then
      M.neovim(true)
    end
  end)
end

function M.welcome()
  PithyVim.info("Welcome to PithyVim!")
end

function M.changelog()
  M.open("CHANGELOG.md", { plugin = "PithyVim" })
end

function M.pithyvim(when_changed)
  M.open("NEWS.md", { plugin = "PithyVim", when_changed = when_changed })
end

function M.neovim(when_changed)
  M.open("doc/news.txt", { rtp = true, when_changed = when_changed })
end

---@param file string
---@param opts? {plugin?:string, rtp?:boolean, when_changed?:boolean}
function M.open(file, opts)
  local ref = file
  opts = opts or {}
  if opts.plugin then
    local plugin = require("lazy.core.config").plugins[opts.plugin] --[[@as LazyPlugin?]]
    if not plugin then
      return PithyVim.error("plugin not found: " .. opts.plugin)
    end
    file = plugin.dir .. "/" .. file
  elseif opts.rtp then
    file = vim.api.nvim_get_runtime_file(file, false)[1]
  end

  if not file then
    return PithyVim.error("File not found")
  end

  if opts.when_changed then
    local is_new = not PithyVim.config.json.data.news[ref]
    local hash = M.hash(file)
    if hash == PithyVim.config.json.data.news[ref] then
      return
    end
    PithyVim.config.json.data.news[ref] = hash
    PithyVim.json.save()
    -- don't open if file has never been opened
    if is_new then
      return
    end
  end

  Snacks.config.style("news", {
    width = 0.6,
    height = 0.6,
    wo = {
      spell = false,
      wrap = false,
      signcolumn = "yes",
      statuscolumn = " ",
      conceallevel = 3,
    },
  })

  local float = Snacks.win({
    file = file,
    style = "news",
  })

  if vim.diagnostic.enable then
    pcall(vim.diagnostic.enable, false, { bufnr = float.buf })
  else
    pcall(vim.diagnostic.disable, float.buf)
  end
end

return M
