return {
  ["default"] = "catppuccin",
  ["schemes"] = {
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
          color.bg_visual = "#414878" -- #414858, #2e3c64, #424559, #414878, #5c6370
        end
      },
    },
    ["everforest"] = {
      ["name"] = "everforest",
      ["moduleName"] = "everforest",
      ["setup"] = {
      },
    },
    --{{{> Qeuroal: Catppuccin 的 setup 统一由插件最终 opts 执行一次，避免随后覆盖 integrations 和自定义高亮
    ["catppuccin"] = {
      ["name"] = "catppuccin",
      ["moduleName"] = "catppuccin",
    },
    --<}}}
  },
}
