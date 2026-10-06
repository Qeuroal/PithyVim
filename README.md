# PithyVim Plugin

PithyVim is the plugin distribution used by PithyVimart. Its root `init.lua`
displays a warning and exits, so this repository is not a standalone Neovim
configuration.

Add `{ "Qeuroal/PithyVim", branch = "dev", import = "pithyvim.plugins" }`
to your existing lazy.nvim plugin specifications before your own plugin imports.
See [the getting started instructions](doc/PithyVim.txt#L55) for the setup example.
