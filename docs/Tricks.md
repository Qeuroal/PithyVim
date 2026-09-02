
# `<leader>/` 两阶段搜索

`<leader>/` 使用 Snacks Picker 在当前工作目录搜索，分为两个阶段：

1. 默认使用 ripgrep 实时搜索文件内容，输入采用正则语法。
2. 按 `<C-g>` 关闭 Live 模式，在已有结果中使用兼容 FZF 语法的 Snacks matcher 过滤。

**流程**: ripgrep 获取结果 → Snacks 使用 FZF 兼容语法过滤结果

## ripgrep 示例

```text
foo             匹配 foo
foo|bar         匹配 foo 或 bar
^local          匹配行首 local
TODO$           匹配行尾 TODO
foo -- -w       只匹配完整单词 foo
foo -- -g=*.lua 只搜索 Lua 文件
```

按 `<A-r>` 可切换正则与纯文本搜索。

## FZF 兼容语法

按 `<C-g>` 后可使用：

```text
foo bar   同时包含 foo 和 bar
'foo      精确包含 foo
^foo      以 foo 开头
bar$      以 bar 结尾
!test     排除 test
foo | bar 匹配 foo 或 bar
```

再次按 `<C-g>` 可返回 Live Grep。
