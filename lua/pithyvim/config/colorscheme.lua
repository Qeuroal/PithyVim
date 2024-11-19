return {
  ["default"] = "onedarkpro",
  ["schemes"] = {
    ["onedarkpro"] = {
      ["name"] = "onedark",
      ["moduleName"] = "onedarkpro",
      ["setup"] = {
        highlights = {
          Comment = { underline = true, extend = true },
          Directory = { bold = true },
          ["CursorLine"] = {
            -- bg = "#31353f",  -- 正常的
            bg = "#3b3b49",
          },
        },
        options = {
          cursorline = true,
          transparency = false,
          highlight_inactive_windows = true,
        }
      },
    },
  },
}


