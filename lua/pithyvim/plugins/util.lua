-- Terminal Mappings
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

--{{{> Qeuroal: 延迟加载 Snacks 图片模块，避免图片和公式默认关闭时增加启动耗时
local snacks_image_state = { images = false, math = false }
local snacks_image_modules

local function refresh_snacks_images(buf)
  local image = Snacks.image
  if not vim.b[buf].snacks_image_attached then
    if image.config.enabled and image.config.doc.enabled then
      local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
      if vim.tbl_contains(image.langs(), lang) then
        image.doc.attach(buf)
      end
    end
    return
  end

  -- Refresh only the Snacks handlers so other plugins do not see synthetic buffer events.
  local inline_group = "snacks.image.inline." .. buf
  if vim.fn.exists("#" .. inline_group .. "#BufWinEnter") == 1 then
    vim.api.nvim_exec_autocmds({ "BufWinEnter", "CursorMoved" }, { group = inline_group, buffer = buf, modeline = false })
  elseif buf == vim.api.nvim_get_current_buf() then
    local float_group = "snacks.image.doc." .. buf
    if vim.fn.exists("#" .. float_group .. "#CursorMoved") == 1 then
      vim.api.nvim_exec_autocmds("CursorMoved", { group = float_group, buffer = buf, modeline = false })
    end
  end
end

local function refresh_visible_snacks_images()
  local seen = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if not seen[buf] then
      seen[buf] = true
      refresh_snacks_images(buf)
    end
  end
end

local function load_snacks_image_modules()
  if snacks_image_modules then
    return snacks_image_modules
  end

  local Placement = require("snacks.image.placement")
  if not rawget(Placement, "_pithyvim_multiline_source") then
    rawset(Placement, "_pithyvim_multiline_source", true)
    local render = Placement._render

    function Placement:_render(extmarks)
      if self.hidden then
        for _, extmark in ipairs(extmarks) do
          extmark.conceal_lines = nil
        end
      end
      return render(self, extmarks)
    end
  end

  local Doc = require("snacks.image.doc")
  Doc._pithyvim_state = snacks_image_state

  if not rawget(Doc, "_pithyvim_filter_types") then
    rawset(Doc, "_pithyvim_filter_types", true)
    local image = Doc._img

    function Doc._img(ctx)
      local result = image(ctx)
      if result then
        local enabled
        if result.type == "math" then
          enabled = Doc._pithyvim_state.math
        else
          enabled = Doc._pithyvim_state.images
        end
        return enabled and result or nil
      end
    end
  end

  local Inline = require("snacks.image.inline")
  -- Snacks 当前把 1-based 的 `to` 直接作为 extmark 的 0-based 结束行, 导致查询额外包含下一行.
  -- 保存原方法并在运行时覆写 `Inline:get()`, 将结束行减一后再调用原实现.
  -- TODO: 更新 Snacks 后检查 `snacks/image/inline.lua`; 若上游已使用 `to - 1`, 删除此覆写.
  if not rawget(Inline, "_pithyvim_exact_line_ranges") then
    rawset(Inline, "_pithyvim_exact_line_ranges", true)
    local get = Inline.get

    function Inline:get(from, to)
      return get(self, from, to - 1)
    end
  end

  if not rawget(Inline, "_pithyvim_normal_mode_updates") then
    rawset(Inline, "_pithyvim_normal_mode_updates", true)
    local update = Inline.update

    function Inline:update()
      if Doc._pithyvim_state.math and vim.fn.mode():sub(1, 1):lower() == "i" then
        return
      end
      return update(self)
    end
  end

  local group = vim.api.nvim_create_augroup("pithyvim_snacks_image", { clear = true })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function(ev)
      if snacks_image_state.math and vim.b[ev.buf].snacks_image_attached then
        refresh_snacks_images(ev.buf)
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function(ev)
      if (snacks_image_state.images or snacks_image_state.math) and not vim.b[ev.buf].snacks_image_attached then
        refresh_snacks_images(ev.buf)
      end
    end,
  })

  snacks_image_modules = { placement = Placement, doc = Doc }
  return snacks_image_modules
end

local function set_snacks_image_type(kind, enabled)
  snacks_image_state[kind] = enabled
  local modules = load_snacks_image_modules()
  Snacks.image.config.math.enabled = snacks_image_state.math
  Snacks.image.config.enabled = snacks_image_state.images or snacks_image_state.math
  if Snacks.image.config.enabled then
    Snacks.image.setup()
  else
    modules.placement.clean()
    modules.doc.hover_close()
  end
  refresh_visible_snacks_images()
end
--<}}}

return {

  -- Snacks utils
  {
    "snacks.nvim",
    --{{{> Qeuroal: 控制 Snacks 图片与公式渲染；修正上一行误隐藏公式并暂停 Insert 模式重复渲染
    init = function()
      -- 图片模块延迟后全局 Snacks 尚未创建，仅加载轻量核心用于注册 toggle
      local snacks = Snacks or require("snacks")
      snacks.toggle({
        name = "Snacks Images",
        get = function()
          return snacks_image_state.images
        end,
        set = function(state)
          set_snacks_image_type("images", state)
        end,
      }):map("<leader>ti")
      snacks.toggle({
        name = "Snacks Math",
        get = function()
          return snacks_image_state.math
        end,
        set = function(state)
          set_snacks_image_type("math", state)
        end,
      }):map("<leader>tm")

    end,
    --<}}}
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      --{{{> Qeuroal
      image = {
        enabled = false,
        force = false,
        math = { enabled = false },
      },
      --<}}}
      terminal = {
        win = {
          keys = {
            nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
            nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
            nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
            nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
            hide_slash = { "<C-/>", "hide", desc = "Hide Terminal", mode = "t" },
            hide_underscore = { "<c-_>", "hide", desc = "which_key_ignore", mode = "t" },
          },
        },
      },
    },
    --{{{> Qeuroal: 从最终 opts 初始化 toggle；默认关闭时不加载图片模块，默认开启时仍立即生效
    config = function(_, opts)
      local images = opts.image.enabled
      local math = opts.image.math.enabled
      snacks_image_state.images = images
      snacks_image_state.math = math

      local setup_opts = vim.deepcopy(opts)
      setup_opts.image.enabled = images or math
      if setup_opts.image.enabled or snacks_image_modules then
        load_snacks_image_modules()
        Snacks.image.config.enabled = setup_opts.image.enabled
        Snacks.image.config.math.enabled = math
      end
      Snacks.setup(setup_opts)
    end,
    --<}}}
    -- stylua: ignore
    keys = {
      { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },
    },
  },

  -- Session management. This saves your session in the background,
  -- keeping track of open buffers, window arrangement, and more.
  -- You can restore sessions when returning through the dashboard.
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qS", function() require("persistence").select() end,desc = "Select Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },

  -- library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },
}
