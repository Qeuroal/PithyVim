return {
  ["default"] = "catppuccin",
  ["schemes"] = {
    --{{{> Qeuroal: Catppuccin 的 setup 统一由插件最终 opts 执行一次，避免随后覆盖 integrations 和自定义高亮
    ["catppuccin"] = {
      ["name"] = "catppuccin",
      ["moduleName"] = "catppuccin",
    },
    --<}}}
  },
}
