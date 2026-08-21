# What's new?

本文按照 `lua/pithyvim/config/init.lua` 中的 `M.version` 版本节点整理。
同一版本内按功能归类，合并提交和纯同步提交不单独列出。

## 1.15.0

当前版本：`lua/pithyvim/config/init.lua:6`

### 核心配置与兼容性

- 增加 Neovim 0.13 兼容处理和 gopls semantic token 更新。
- 重构 extras 注册系统，改进 TypeScript LSP 和 monorepo root 检测。
- 增加系统剪贴板、保存退出、折叠方式、Zoom/Zen、终端和 LSP 快捷键。
- 增加 `:CamelToSnake`、`:SnakeToCamel`、复制路径和 EditorConfig 查看命令/快捷键。
- 默认关闭自动格式化和诊断，调整换行、缩进、fold marker、diff 和 undo 配置。

### UI、主题与 Picker

- Catppuccin 成为默认主题，支持 OneDarkPro、TokyoNight 和 Everforest 注册表。
- 增加 Catppuccin `WinSeparator` 高亮、WhichKey 图标、Neovide 字体和缩放配置。
- Bufferline 按目录和文件排序，文件优先于目录。
- Snacks、Telescope、FzfLua 和 Neo-tree 增加 cwd/root、诊断、隐藏文件、布局和快捷键定制。
- 增加 mini.align、align.nvim、ANSI renderer、Tmux 导航和 UndoTree。
- Snacks Scroll 默认关闭，需要时用 `<leader>uS` 开启。

### Completion、AI 与语言支持

- Blink、nvim-cmp 和 LuaSnip 统一补全快捷键，并支持 PithyVim 自定义 snippet 目录。
- 修复函数补全行尾括号越界和已有括号重复插入问题。
- Copilot 增加敏感文件黑名单，并改为合并 Blink provider 配置。
- Copilot 达到 completions limit 时自动禁用 Sidekick NES，并只提示一次。
- 增加 Jupyter Notebook（`ipynb`）支持，接入 Tree-sitter、LSP、Markdown 和图片渲染。
- Markdown 使用 Snacks 渲染图片和 LaTeX 数学公式，支持多行公式源码展开。
- 仅在 Tree-sitter CLI >= 0.26.1 时安装 LaTeX parser，规避旧 ABI 和 GLIBC 错误。
- TeX extra 检测 `latexmk`，使用 VimTeX/Skim，并定制 conceal、补全和 quickfix。
- Python extra 在系统存在 `python` 或 `python3` 时自动推荐。

### Tree-sitter 与测试

- 直接从 runtimepath 检测 Tree-sitter parser，避免重复安装提示。
- 合并并发 Tree-sitter CLI 安装回调，避免 Mason “Package is already installing”错误。
- 增加 Makefile、离线 mini.test 测试入口、功能契约测试和回归测试。
- 测试覆盖达到 442 cases，包含补全、parser、Markdown、Tree-sitter CLI 和 Jupyter 条件。

## 1.14.0

版本提交：2026-03-07，`6bc2a27`。

- 更新插件配置、LSP 命令和版本管理。
- 增加系统剪贴板、折叠方式切换和新的终端 focus 行为。
- 重构 extras 默认项注册和 TypeScript 支持。
- 调整文本自动换行、`formatoptions` 和 `textwidth`。
- 增加 Snacks picker 隐藏文件、布局、git status/diff 自定义按键。
- 切换 OneDarkPro 官方主题仓库，完善 VimTeX conceal、补全和反向搜索配置。
- 增加 Neovide 配置和 mini.align 插件。

## 1.10.0

版本提交：2025-10-21，`a60a09e`。

- 增加 Snacks.nvim 集成、AI 插件、Blink 补全和 Tmux pane 导航。
- 增加 Tree-sitter 健康检查、错误处理、折叠配置和缩进范围显示。
- 增加 Copilot 条件检查、LuaSnip 自定义片段和 mini.surround 配置。
- 重构 LSP 配置、LSP 调用层次导航和格式化器设置。
- 增加 Makefile、测试脚本、markdownlint 配置和 gitmerge 工作流。
- 更新 Neovim 最低版本要求至 0.11.2。
- 增加 ANSI renderer、系统剪贴板和 LSP 重启快捷键。

## 1.9.0

版本提交：2025-10-20，`e13a9c6`。

- 优化多个插件配置和 AI/LSP 集成。
- 增强代码补全和语言支持的条件检测。
- 开始将个人插件配置迁移到 PithyVim extras 结构。
