# shrepl.nvim
A Neovim plugin to execute shell commands from within Neovim and display the output inline.

## Features

- Execute the current line or visual selection in the shell.
- Optionally reselect the command after execution for easy re-execution.
- Optionally capture `stdout` and `stderr` separately.
- Configurable key mappings.

## Installation

Use your favorite plugin manager. For example, with Lazy.nvim:

```lua
{
  'Lingnik/shrepl.nvim',
  config = function()
    require('shell_repl').setup({
      reselection_enabled = true,
      capture_stderr_separately = true,
    })
  end,
}
```

## Configuration

The setup function accepts a table with the following options:
* `reselection_enabled` (boolean): Whether to reselect the command after execution in visual mode. Default is true. false = equivalent of hitting ESC after execution.
* `capture_stderr_separately` (boolean): Whether to capture stderr separately from stdout. Default is true. false = stdout and stderr will be inline.

## Usage

* **Normal Mode:** Press `<leader>x` to execute the current line in the shell.
* **Visual Mode:** Select lines and press `<leader>x` to execute them in the shell.

shrepl will insert the output of the command above the line/selection, allowing you to re-execute the command at your leisure, or edit it.
