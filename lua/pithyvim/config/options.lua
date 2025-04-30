-- This file is automatically loaded by plugins.core
vim.g.mapleader = " "
--{{{> Qeuroal
-- vim.g.maplocalleader = "\\"
vim.g.maplocalleader = ";"
--<}}}

-- PithyVim auto format
vim.g.autoformat = false

-- Snacks animations
-- Set to `false` to globally disable all snacks animations
vim.g.snacks_animate = true

-- PithyVim picker to use.
-- Can be one of: telescope, fzf
-- Leave it to "auto" to automatically use the picker
-- enabled with `:LazyExtras`
vim.g.pithyvim_picker = "auto"

-- PithyVim completion engine to use.
-- Can be one of: nvim-cmp, blink.cmp
-- Leave it to "auto" to automatically use the completion engine
-- enabled with `:LazyExtras`
vim.g.pithyvim_cmp = "auto"

-- if the completion engine supports the AI source,
-- use that instead of inline suggestions
vim.g.ai_cmp = true

-- PithyVim root dir detection
-- Each entry can be:
-- * the name of a detector function like `lsp` or `cwd`
-- * a pattern or array of patterns like `.git` or `lua`.
-- * a function with signature `function(buf) -> string|string[]`
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- Optionally setup the terminal to use
-- This sets `vim.o.shell` and does some additional configuration for:
-- * pwsh
-- * powershell
-- PithyVim.terminal.setup("pwsh")

-- Set LSP servers to be ignored when used with `util.root.detectors.lsp`
-- for detecting the LSP root
vim.g.root_lsp_ignore = { "copilot" }

-- Hide deprecation warnings
vim.g.deprecation_warnings = false

-- Show the current document symbols location from Trouble in lualine
-- You can disable this for a buffer by setting `vim.b.trouble_lualine = false`
vim.g.trouble_lualine = true

--{{{> Qeuroal
-- encoding
vim.g.encoding = "UTF-8"

-- EditorConfig is enabled by default. 
-- Nvim searches all parent directories of that file for ".editorconfig" files,
-- parses them, and applies any properties that match the opened file. 
vim.g.editorconfig = true
--<}}}

--{{{> Qeuroal
local undodir = PithyVim.join_paths(get_cache_dir(), "undo")
if not PithyVim.is_directory(undodir) then
  vim.fn.mkdir(undodir, "p")
end
local space = "·"
--<}}}

local opt = vim.opt

opt.backup = false             -- creates a backup file
opt.cmdheight = 1              -- more space in the neovim command line for displaying messages
opt.hidden = true              -- required to keep multiple buffers and open multiple buffers
opt.swapfile = false           -- creates a swapfile
opt.undodir = undodir          -- set an undo directory
opt.title = true               -- set the title of window to the value of the titlestring
opt.titlestring = "%<%F%=%l/%L - nvim"   -- what the title of the window will be set to
-- opt.fileencoding = "utf-8"     -- the encoding written to a file
opt.writebackup = false        -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
opt.numberwidth = 4            -- set number column width to 2 {default 4}
opt.hlsearch = true            -- highlight all matches on previous search pattern

opt.autowrite = true            -- Enable auto write
-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"     -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"   -- 补全时默认不选择第1项
-- opt.wildmenu = true             -- 补全增强, 但是目前并不清楚有什么用
opt.conceallevel = 2            -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true              -- Confirm to save changes before exiting modified buffer
opt.cursorline = true           -- Enable highlighting of the current line
opt.expandtab = true            -- Use spaces instead of tabs
opt.fillchars = {
    foldopen = "",
    foldclose = "",
    fold = " ",
    foldsep = " ",
    diff = "╱",
    eob = " ",
}
opt.formatexpr = "v:lua.require'pithyvim.util'.format.formatexpr()"
opt.formatoptions = "jcroqlnt"      -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true               -- Ignore case
opt.inccommand = "nosplit"          -- preview incremental substitute
opt.jumpoptions = "stack"           -- modify style of the jumplist to stack
opt.laststatus = 3                  -- global statusline
opt.linebreak = false               -- Wrap lines at convenient points
opt.list = false                    -- Show some invisible characters (tabs...
opt.mouse = ""                      -- allow the mouse to be used in neovim
-- opt.guicursor = "a:block"           -- set block for any mode
opt.number = true                   -- Print line number
opt.pumblend = 10                   -- Popup blend
opt.pumheight = 10                  -- Maximum number of entries in a popup
opt.relativenumber = true           -- Relative line numbers
opt.ruler = false                   -- Disable the default ruler
opt.scrolloff = 0                   -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true               -- Round indent
opt.shiftwidth = 4                  -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false                -- Dont show mode since we have a statusline
opt.showcmd = true                  -- 显示按键
opt.sidescrolloff = 8               -- Columns of context
opt.sidescroll = 10                 -- 设置向右滚动字符数
opt.signcolumn = "yes"              -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true                -- Don't ignore case with capitals
opt.smartindent = true              -- Insert indents automatically
opt.spelllang = { "en", "cjk" }     -- 设置拼写检查的语种, 其中: "cjk" 能够保证检查英文时, 不在中文下面设置下滑线
                                    -- 可通过快捷键 <leader>us 设置拼写检查开启/关闭
opt.splitbelow = true               -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true               -- Put new windows right of current
opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
opt.autoindent = true               -- 设置自动缩进
opt.cindent = true                  -- 设置使用C/C++语言的自动缩进方式
-- opt.cinoptions=":0,g0,N-s,(0,w1"    -- 设置C/C++语言的具体缩进方式
                                    -- :0 表示 switch 下面的 case 语句不进行额外缩进
                                    -- g0 代表作用域声明(public:、private: 等)不额外缩进
                                    -- (0 和 w1 配合代表没结束的圆括号里的内容折行时不额外缩进
opt.tabstop = 4                     -- Number of spaces tabs count for
opt.softtabstop = 4                 -- 设置4个空格为制表符, 即"软"制表符宽度.
                                    -- softtabstop看成"虚拟"的tapstop, 一旦设置了这个选项为非零值，再键入<Tab>和<BS>(退格键)
                                    -- 你就感觉像设置了这个宽度的 tabstop 一样, " 实际插入的仍受expandtab和tabstop两个选项控制
opt.termguicolors = true            -- True color support
opt.timeoutlen = vim.g.vscode and 1000 or 300   -- Lower than default (1000) to quickly trigger which-key
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200                -- Save swap file and trigger CursorHold
opt.virtualedit = { "block", "onemore" }        -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full"  -- Command-line completion mode
opt.winminwidth = 5                 -- Minimum window width
opt.wrap = true                     -- Disable line wrap
opt.listchars:append {
    tab = "│─",
    multispace = "│---",
    leadmultispace = "│---",
    lead = "-",
    trail = space,
    nbsp = "%",
    eol = '⤶',
    extends = '◀',
    precedes = '▶',
    -- ahead = space,
}
-- opt.whichwrap = opt.whichwrap + "<,>,h,l"    -- 设置光标键跨行
if vim.fn.has("nvim-0.10") == 1 then
    opt.smoothscroll = true
    opt.foldexpr = "v:lua.require'pithyvim.util'.ui.foldexpr()"
    opt.foldmethod = "expr"
    opt.foldtext = ""
else
    opt.foldmethod = "indent"
    opt.foldtext = "v:lua.require'pithyvim.util'.ui.foldtext()"
end
opt.foldmarker = "{{{>,<}}}"
opt.foldlevel = 99                      -- 0: 键入 zm 可以折叠, 但是只会折叠一层, 必须使用zR设置层次折叠
                                        -- 99: 键入 zm 不可以折叠, 只能先使用 zM 将 foldlevel 设置为0
opt.foldenable = false                  -- 默认不折叠


-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- disable diagnostic, enter "<leader>ud" to toggle the option
-- default enable: pcall (vim.diagnostic.enable)
pcall(vim.diagnostic.enable, false)

--{{{> diffopt
vim.o.diffopt = vim.o.diffopt .. ",followwrap"
vim.o.diffopt = vim.o.diffopt .. ",context:3"
vim.o.diffopt = vim.o.diffopt .. ",algorithm:patience"
vim.o.diffopt = vim.o.diffopt .. ",indent-heuristic"
--<}}}

--{{{> Qeuroal: wrap and linebreak
opt.breakindentopt = { "shift:2", "sbr" }   -- 设置折行时的缩进量为 2 个字符，并启用 showbreak
opt.showbreak = "↪"                         -- 可选：自定义 showbreak 的提示符
opt.linebreak = false
-- opt.breakat = "^I!@*-+;:,./?"               -- 当 vim.opt.linebreak = true 时有效, 将选择合适的地方折行.
--                                             -- 合适的地方, 是由breakat选项中的字符来确定的.
--                                             -- 在默认的情况下, 这些字符是 “^I!@*-+_;:,./?” 
--                                             -- (Note: 在 Pithyvim 中默认为 “^I!@*-+;:,./?”)

--<}}}

--{{{> Qeuroal: shada
-- opt.shada = string.gsub(opt.shada._value, "'100", "'0")   -- 将 '100 设置为 '0, 以此保证 jumplist 不共享且不保存,
--                                                           -- 从而在每次打开 neovim 后, jumplist 都为空

--<}}}

--{{{> Qeuroal: gui
vim.o.guifont = "JetBrainsMonoNL Nerd Font:h20"

--<}}}


