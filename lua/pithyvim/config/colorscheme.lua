return {
  ["default"] = "onedarkpro",
  ["schemes"] = {
    ["onedarkpro"] = {
      ["name"] = "onedark",
      ["moduleName"] = "onedarkpro",
      ["setup"] = {
        highlights = {
          Comment = { underline = false, italic=true, extend=true }, -- extend 用于保证注释颜色为深灰色
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


