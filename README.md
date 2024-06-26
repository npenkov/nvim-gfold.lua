# nvim-gfold.lua

`nvim` plugin for [gfold](https://github.com/npenkov/gfold) currently providing:

- A picker to change `cwd`.
  This uses `vim.ui.select`.
  To have a nice ui for example [dressing.nvim](https://github.com/stevearc/dressing.nvim) can be used.
- A function to get a summary that can be used in statuslines, eg [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim).

## Pictures

### Picker

![screenshot](doc/screenshot.png)

### Statusline

![gscreenshot_2022-02-26-140848](https://user-images.githubusercontent.com/23341710/155844731-13a82e4e-f74e-47a9-a677-7c696c731169.png)

## Install

### Packer

> NOTE requires [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

```lua
use {
  "npenkov/nvim-gfold.lua",
  config = function()
    require('gfold').setup()
  end,
}
```

### LazyVim

~/.config/nvim/lua/plugins/nvim-gfold.lua

```lua
return {
  "npenkov/nvim-gfold.lua",
  branch = "feature/unpulled",
  opts = {
    cwd = "~/src/oss",
  },
  keys = {
    {
      "<leader>fs",
      function()
        require("gfold").pick_repo()
      end,
      desc = "Choose repo",
    },
  },
}
```

## Config

Pass a table to `require('gfold').setup()`.
The following are the default values:

```lua
{
  -- base directory to look for repos
  -- defaults to home
  cwd = vim.fn.getenv('HOME'),

  -- if true, no error is shown if the call to gfold fails
  no_error = false,

	-- timeout for the call to gfold
	timeout = 3000,

  -- What symbols to use, for both picker and status
  status_symbols = {
    clean = '✔',
    unclean = '✘',
    unpushed = '',
    bare = '',
  },

  -- settings specific to the picker
  picker = {
    -- how to format an entry in the picker
    -- default will be something like:
    --   ✔ nvim-gfold.lua (/home/path/to/nvim-gfold.lua)
    format_item = function(repo)
      return string.format(
      '%s %s (%s)',
      require('gfold.settings').status_symbols[repo.status],
      repo.name,
      repo.path
      )
    end,

    -- what to do when selecting a repo
    -- by default changes cwd
    on_select = require('gfold.actions').change_cwd,
  },

  -- settings specific to the status(line)
  status = {
    -- if we should continuously update the summary
    enable = true,

    -- how long to wait in between querying repo statuses
    -- NOTE this is the time from the last process ran until starting it again
    -- so the interval will be whatever time it takes to run gfold plus this setting
    -- Default is 5 seconds but if for some reason you want this to be updated more frequently
    -- you can always make this value smaller.
    update_delay = 5000,

    -- What color of highlights to use
    -- Values are either:
    --   * string: a highlight group
    --   * table: eg `{fg = '#b8bb26'}`
    colors = {
      clean = {fg = '#b8bb26'},
      unclean = {fg = '#fb4934'},
      unpushed = {fg = '#fe8019'},
      bare = {fg = '#fabd2f'},
    },

    -- In which order to show the components of the summary
    order = {
      'clean',
      'unclean',
      'unpushed',
      'bare',
    },
  },
}
```

## Usage

### Picker

To pick a repo:

```vim
:lua require('gfold').pick_repo()
```

Optionally you can filter the repos you want to show by including a condition callback.
For example:

```lua
require('gfold').pick_repo(function(repo)
  return repo.status ~= 'clean'
end)
```

which would only include non-clean repos in the picker. `repo` is a table with the keys:

- `status`
- `path`
- `remote`
- `user`

Another example for unpulled repos and a customer function `on_select`:

```lua
    {
      "<leader>fsU",
      function()
        require("gfold").pick_repo_and(function(repo)
          return repo.status == "unpulled"
        end, function(repo, idx)
          if repo then
            print("Selected " .. repo.path .. " -> " .. idx)
          end
          local bdir = repo.path
          local tmux = require("harpoon.tmux")
          tmux.sendCommand(99, "cd " .. bdir .. "; nvim .; \n")
        end)
      end,
      desc = "Choose repo (unpulled)",
    },
```
which uses harpoon.tmux to create a new session and run `nvim` in it.

### Statusline

#### Lualine

To use `lualine` you can simply do eg:

```lua
require('lualine').setup({
  ...
  sections = {
    ...
    lualine_x = {
      ...
      'gfold',
      ...
    },
    ...
  },
  ...
})
```

#### Others

For other statuslines you can call `require('gfold').get_summary` which returns a table of the form:

```lua
{
  unclean = <int>,
  clean = <int>,
  bare = <int>,
  unpushed = <int>,
  unpulled = <int>,
}
```

which you can use to format a summary to your liking.

NOTE that `get_summary` does not update the current summary (ie does not trigger `gfold`), it just looks up the
current known information. This means `get_summary` is a quick function and you can easily call it often.
Instead, `nvim-gfold` will continuously update this information in the background, see [settings](https://github.com/npenkov/nvim-gfold.lua/tree/main/lua/gfold/settings.lua) for more information.

## Credits

Based on [AckslD/nvim-gfold](https://github.com/AckslD/nvim-gfold.lua)
