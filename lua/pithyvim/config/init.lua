_G.PithyVim = require("pithyvim.util")

---@class PithyVimConfig: PithyVimOptions
local M = {}

M.version = "15.7.1" -- x-release-please-version
PithyVim.config = M

---@class PithyVimOptions
local defaults = {
  --{{{> Qeuroal: default color config
  colorSetting = require("pithyvim.config.colorscheme"),
  -- colorscheme can be a string like `catppuccin` or a function that will load the colorscheme
  ---@type string|fun()
  colorscheme = function()
    local scheme = M.colorSetting["default"]
    local schemeOpt = M.colorSetting.schemes[scheme]
    if (type(schemeOpt) ~= "table") then
      PithyVim.warn("the default don't exist!!!")
      require("tokyonight").load()
    end
    local setup = schemeOpt.setup
    local moduleName = schemeOpt["moduleName"] or scheme
    local name = schemeOpt["name"] or scheme
    if (setup) then
      require(moduleName).setup(setup)
      vim.cmd.colorscheme(name)
    else
      require(moduleName).load()
    end
  end,
  --<}}}

  -- load the default settings
  defaults = {
    autocmds = true, -- pithyvim.config.autocmds
    keymaps = true, -- pithyvim.config.keymaps
    -- pithyvim.config.options can't be configured here since that's loaded before pithyvim setup
    -- if you want to disable loading options, add `package.loaded["pithyvim.config.options"] = true` to the top of your init.lua
  },
  news = {
    -- When enabled, NEWS.md will be shown when changed.
    -- This only contains big new features and breaking changes.
    pithyvim = true,
    -- Same but for Neovim's news.txt
    neovim = false,
  },
  -- icons used by other plugins
  -- stylua: ignore
  icons = {
    misc = {
      dots = "󰇘",
    },
    ft = {
      octo = "",
    },
    dap = {
      Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint          = " ",
      BreakpointCondition = " ",
      BreakpointRejected  = { " ", "DiagnosticError" },
      LogPoint            = ".>",
    },
    diagnostics = {
      Error = " ",
      Warn  = " ",
      Hint  = " ",
      Info  = " ",
    },
    git = {
      added    = " ",
      modified = " ",
      removed  = " ",
    },
    kinds = {
      Array         = " ",
      Boolean       = "󰨙 ",
      Class         = " ",
      Codeium       = "󰘦 ",
      Color         = " ",
      Control       = " ",
      Collapsed     = " ",
      Constant      = "󰏿 ",
      Constructor   = " ",
      Copilot       = " ",
      Enum          = " ",
      EnumMember    = " ",
      Event         = " ",
      Field         = " ",
      File          = " ",
      Folder        = " ",
      Function      = "󰊕 ",
      Interface     = " ",
      Key           = " ",
      Keyword       = " ",
      Method        = "󰊕 ",
      Module        = " ",
      Namespace     = "󰦮 ",
      Null          = " ",
      Number        = "󰎠 ",
      Object        = " ",
      Operator      = " ",
      Package       = " ",
      Property      = " ",
      Reference     = " ",
      Snippet       = "󱄽 ",
      String        = " ",
      Struct        = "󰆼 ",
      Supermaven    = " ",
      TabNine       = "󰏚 ",
      Text          = " ",
      TypeParameter = " ",
      Unit          = " ",
      Value         = " ",
      Variable      = "󰀫 ",
    },
  },
  ---@type table<string, string[]|boolean>?
  kind_filter = {
    default = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      "Package",
      "Property",
      "Struct",
      "Trait",
    },
    markdown = false,
    help = false,
    -- you can specify a different filter for each filetype
    lua = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      -- "Package", -- remove package since luals uses it for control flow structures
      "Property",
      "Struct",
      "Trait",
    },
  },
}

M.json = {
  version = 8,
  loaded = false,
  path = vim.g.pithyvim_json or vim.fn.stdpath("config") .. "/pithyvim.json",
  data = {
    version = nil, ---@type number?
    install_version = nil, ---@type number?
    news = {}, ---@type table<string, string>
    extras = {}, ---@type string[]
  },
}

function M.json.load()
  M.json.loaded = true
  local f = io.open(M.json.path, "r")
  if f then
    local data = f:read("*a")
    f:close()
    local ok, json = pcall(vim.json.decode, data, { luanil = { object = true, array = true } })
    if ok then
      M.json.data = vim.tbl_deep_extend("force", M.json.data, json or {})
      if M.json.data.version ~= M.json.version then
        PithyVim.json.migrate()
      end
    end
  else
    M.json.data.install_version = M.json.version
  end
end

---@type PithyVimOptions
local options
local lazy_clipboard

---@param opts? PithyVimOptions
function M.setup(opts)
  options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}

  -- autocmds can be loaded lazily when not opening a file
  local lazy_autocmds = vim.fn.argc(-1) == 0
  if not lazy_autocmds then
    M.load("autocmds")
  end

  local group = vim.api.nvim_create_augroup("PithyVim", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = function()
      if lazy_autocmds then
        M.load("autocmds")
      end
      M.load("keymaps")
      if lazy_clipboard ~= nil then
        vim.opt.clipboard = lazy_clipboard
      end

      PithyVim.format.setup()
      PithyVim.news.setup()
      PithyVim.root.setup()

      vim.api.nvim_create_user_command("LazyExtras", function()
        PithyVim.extras.show()
      end, { desc = "Manage PithyVim extras" })

      vim.api.nvim_create_user_command("LazyHealth", function()
        vim.cmd([[Lazy! load all]])
        vim.cmd([[checkhealth]])
      end, { desc = "Load all plugins and run :checkhealth" })

      local health = require("lazy.health")
      vim.list_extend(health.valid, {
        "recommended",
        "desc",
        "vscode",
      })

      if vim.g.pithyvim_check_order == false then
        return
      end

      -- Check lazy.nvim import order
      local imports = require("lazy.core.config").spec.modules
      local function find(pat, last)
        for i = last and #imports or 1, last and 1 or #imports, last and -1 or 1 do
          if imports[i]:find(pat) then
            return i
          end
        end
      end
      local pithyvim_plugins = find("^pithyvim%.plugins$")
      local extras = find("^pithyvim%.plugins%.extras%.", true) or pithyvim_plugins
      local plugins = find("^plugins$") or math.huge
      if pithyvim_plugins ~= 1 or extras > plugins then
        local msg = {
          "The order of your `lazy.nvim` imports is incorrect:",
          "- `pithyvim.plugins` should be first",
          "- followed by any `pithyvim.plugins.extras`",
          "- and finally your own `plugins`",
          "",
          "If you think you know what you're doing, you can disable this check with:",
          "```lua",
          "vim.g.pithyvim_check_order = false",
          "```",
        }
        vim.notify(table.concat(msg, "\n"), "warn", { title = "PithyVim" })
      end
    end,
  })

  PithyVim.track("colorscheme")
  PithyVim.try(function()
    if type(M.colorscheme) == "function" then
      M.colorscheme()
    else
      vim.cmd.colorscheme(M.colorscheme)
    end
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg)
      PithyVim.error(msg)
      vim.cmd.colorscheme("habamax")
    end,
  })
  PithyVim.track()
end

---@param buf? number
---@return string[]?
function M.get_kind_filter(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local ft = vim.bo[buf].filetype
  if M.kind_filter == false then
    return
  end
  if M.kind_filter[ft] == false then
    return
  end
  if type(M.kind_filter[ft]) == "table" then
    return M.kind_filter[ft]
  end
  ---@diagnostic disable-next-line: return-type-mismatch
  return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

---@param name "autocmds" | "options" | "keymaps"
function M.load(name)
  local function _load(mod)
    if require("lazy.core.cache").find(mod)[1] then
      PithyVim.try(function()
        require(mod)
      end, { msg = "Failed loading " .. mod })
    end
  end
  local pattern = "PithyVim" .. name:sub(1, 1):upper() .. name:sub(2)
  -- always load pithyvim, then user file
  if M.defaults[name] or name == "options" then
    _load("pithyvim.config." .. name)
    vim.api.nvim_exec_autocmds("User", { pattern = pattern .. "Defaults", modeline = false })
  end
  _load("config." .. name)
  if vim.bo.filetype == "lazy" then
    -- HACK: PithyVim may have overwritten options of the Lazy ui, so reset this here
    vim.cmd([[do VimResized]])
  end
  vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
end

M.did_init = false
M._options = {} ---@type vim.wo|vim.bo

function M.init()
  if M.did_init then
    return
  end
  M.did_init = true
  local plugin = require("lazy.core.config").spec.plugins.PithyVim
  if plugin then
    vim.opt.rtp:append(plugin.dir)
  end

  package.preload["pithyvim.plugins.lsp.format"] = function()
    PithyVim.deprecate([[require("pithyvim.plugins.lsp.format")]], [[PithyVim.format]])
    return PithyVim.format
  end

  -- delay notifications till vim.notify was replaced or after 500ms
  PithyVim.lazy_notify()

  -- load options here, before lazy init while sourcing plugin modules
  -- this is needed to make sure options will be correctly applied
  -- after installing missing plugins
  M.load("options")

  -- save some options to track defaults
  M._options.indentexpr = vim.o.indentexpr
  M._options.foldmethod = vim.o.foldmethod
  M._options.foldexpr = vim.o.foldexpr

  -- defer built-in clipboard handling: "xsel" and "pbcopy" can be slow
  lazy_clipboard = vim.opt.clipboard:get()
  vim.opt.clipboard = ""

  if vim.g.deprecation_warnings == false then
    vim.deprecate = function() end
  end

  PithyVim.plugin.setup()
  M.json.load()
end

---@alias PithyVimDefault {name: string, extra: string, enabled?: boolean, origin?: "global" | "default" | "extra" }

local default_extras ---@type table<string, PithyVimDefault>
function M.get_defaults()
  if default_extras then
    return default_extras
  end
  ---@type table<string, PithyVimDefault[]>
  local checks = {
    picker = {
      { name = "snacks", extra = "editor.snacks_picker" },
      { name = "fzf", extra = "editor.fzf" },
      { name = "telescope", extra = "editor.telescope" },
    },
    cmp = {
      { name = "blink.cmp", extra = "coding.blink" },
      { name = "nvim-cmp", extra = "coding.nvim-cmp" },
    },
    explorer = {
      --{{{> Qeuroal
      -- snacks_explorer has question that keymap <c-j> isn't switch windows and grep error
      -- { name = "neo-tree", extra = "editor.neo-tree" },
      --<}}}
      { name = "snacks", extra = "editor.snacks_explorer" },
      { name = "neo-tree", extra = "editor.neo-tree" },
    },
    --{{{> Qeuroal
    snip = {
      { name = "luasnip", extra = "coding.luasnip" },
    },
    indent_ui = {
      { name = "mini-indentscope", extra = "ui.mini-indentscope" },
    },
    --<}}}
  }

  -- existing installs keep their defaults
  if (PithyVim.config.json.data.install_version or 7) < 8 then
    table.insert(checks.picker, 1, table.remove(checks.picker, 2))
    table.insert(checks.explorer, 1, table.remove(checks.explorer, 2))
  end

  default_extras = {}
  for name, check in pairs(checks) do
    local valid = {} ---@type string[]
    for _, extra in ipairs(check) do
      if extra.enabled ~= false then
        valid[#valid + 1] = extra.name
      end
    end
    local origin = "default"
    local use = vim.g["pithyvim_" .. name]
    use = vim.tbl_contains(valid, use or "auto") and use or nil
    origin = use and "global" or origin
    for _, extra in ipairs(use and {} or check) do
      if extra.enabled ~= false and PithyVim.has_extra(extra.extra) then
        use = extra.name
        break
      end
    end
    origin = use and "extra" or origin
    use = use or valid[1]
    for _, extra in ipairs(check) do
      local import = "pithyvim.plugins.extras." .. extra.extra
      extra = vim.deepcopy(extra)
      extra.enabled = extra.name == use
      if extra.enabled then
        extra.origin = origin
      end
      default_extras[import] = extra
    end
  end
  return default_extras
end

setmetatable(M, {
  __index = function(_, key)
    if options == nil then
      return vim.deepcopy(defaults)[key]
    end
    ---@cast options PithyVimConfig
    return options[key]
  end,
})

return M
