return {
  ["default"] = "tokyonight",
  ["schemes"] = {
    ["onedarkpro"] = {
      ["name"] = "onedark",
      ["moduleName"] = "onedarkpro",
      ["setup"] = {
        colors = {
          -- -- git diff
          -- git_add = "#014431",
          -- git_delete = "#501b20",
          -- git_change = "#454566",
          -- git_text = "#637592",

          -- diff
          diff_add = "#014431",
          diff_delete = "#501b20",
          diff_change = "#454566",
          diff_text =  "#7c3000",     -- #5654a2, #7c3000, #00688b, #637592, #017271, #5f686f
        },
        highlights = {
          Comment = { underline = false, italic = true, extend = true }, -- extend 用于保证注释颜色为深灰色
          Directory = { bold = true },
          ErrorMsg = { italic = true, bold = true },
          CursorLine = { bg = "#3b3b49", }, -- bg = "#31353f" (正常的)
          -- 括号颜色
          MatchParen = { bold = true, underline = true, fg = "#FFFF00" }, -- #B22222, #FF4500, #FFFF00, #DC143C
          -- NonText = { fg="#5c6370" },
          -- LineNr = { fg = "#495162" },
          ["@markup.list.checked"] = { fg = "#98c379" }, -- #73DACA
          ["@markup.list.unchecked"] = { fg = "#FF4500" }, -- #7AA2F7
          ["RenderMarkdownCodeInline"] = { fg = "#f1948a" } -- #8B7500, #340000
        },
        options = {
          cursorline = true,
          transparency = false,
          nobackground = true,
          -- highlight inactive
          highlight_inactive_windows = true,
          lualine_transparency = false, -- Center bar transparency?
        },
        plugins = {
          indentline = true,
        },
      },
    },
    ["tokyonight"] = {
      ["name"] = "tokyonight",
      ["moduleName"] = "tokyonight",
      ["setup"] = {
        style = "storm",
        on_colors = function (color)
          color.diff.add = "#014431"
          color.diff.delete = "#501b20"
          color.diff.change = "#800000"
          color.diff.ignore =  "#7c3000"
          color.bg_visual = "#414878" -- #414858, #2e3c64
        end
      },
    },
    ["everforest"] = {
      ["name"] = "everforest",
      ["moduleName"] = "everforest",
      ["setup"] = {
      },
    },
  },
}


