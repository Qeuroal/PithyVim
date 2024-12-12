return {
  ["default"] = "onedarkpro",
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
          diff_text =  "#7c3000"     -- "#00688b", #637592, #017271, #5f686f
        },
        highlights = {
          Comment = { underline = false, italic = true, extend = true }, -- extend 用于保证注释颜色为深灰色
          Directory = { bold = true },
          ErrorMsg = { italic = true, bold = true },
          ["CursorLine"] = {
            -- bg = "#31353f",  -- 正常的
            bg = "#3b3b49",
          },
        },
        options = {
          cursorline = true,
          transparency = false,
          highlight_inactive_windows = true,
          lualine_transparency = false, -- Center bar transparency?
        },
        plugins = {
          indentline = true,
        },
      },
    },
  },
}


