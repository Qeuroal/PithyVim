--{{{> Qeuroal
---@module "luassert"
---@module "lazy"

local Plugin = require("lazy.core.plugin")

_G.PithyVim = require("pithyvim.util")
require("pithyvim.config")
PithyVim.config.get_defaults()
PithyVim.plugin.setup()

describe("extras", function()
  local Config = require("lazy.core.config")
  assert(vim.tbl_count(Config.plugins) > 0, "lazy.nvim was not set up")

  local extras = vim.tbl_map(function(path)
    local modname = path:sub(5):gsub("%.lua$", ""):gsub("/", ".")
    return { modname = modname, modpath = path }
  end, vim.fs.find(function(name)
    return name:match("%.lua$")
  end, { limit = math.huge, type = "file", path = "lua/pithyvim/plugins/extras" }))

  local tree_spec = Plugin.Spec.new({
    import = "pithyvim.plugins.treesitter",
  }, { optional = true })
  local tree_opts = Plugin.values(tree_spec.plugins["nvim-treesitter"], "opts", false)
  local tree_defaults = tree_opts.ensure_installed

  assert(type(tree_defaults) == "table", "nvim-treesitter has no ensure_installed list")

  for _, extra in ipairs(extras) do
    local name = extra.modname:sub(#"pithyvim.plugins.extras" + 2)

    describe(name, function()
      local module = require(extra.modname)

      it("has a valid plugin spec", function()
        local spec = Plugin.Spec.new({
          { "mason-org/mason.nvim", opts = { ensure_installed = {} } },
          { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
          module,
        }, { optional = true })
        assert.are.equal(0, #spec.notifs, "Invalid spec: " .. vim.inspect(spec.notifs))
      end)

      if extra.modname:find("%.lang%.") then
        it("declares whether it is recommended", function()
          assert.is_not_nil(module.recommended, "`recommended` is missing from " .. extra.modname)
        end)
      end

      it("does not use renamed plugins", function()
        local spec = Plugin.Spec.new(module, { optional = true })
        for _, plugin in pairs(spec.plugins) do
          local source = plugin[1]
          if source then
            assert.is_nil(
              PithyVim.plugin.renames[source],
              source .. " was renamed to " .. (PithyVim.plugin.renames[source] or "")
            )
          end
        end
      end)

      it("does not repeat default Tree-sitter parsers", function()
        local spec = Plugin.Spec.new({
          { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
          module,
        }, { optional = true })
        local tree = spec.plugins["nvim-treesitter"]
        if not tree then
          return
        end

        local opts = Plugin.values(tree, "opts", false)
        local repeated = vim.tbl_filter(function(lang)
          return vim.tbl_contains(tree_defaults, lang)
        end, opts.ensure_installed or {})
        assert.same({}, repeated, "Remove default Tree-sitter parsers from " .. extra.modname)
      end)
    end)
  end
end)
--<}}}
