# syke

`syke` is a small CLI tool that reads a configuration written in lua to describe
the state of your system. This allows for using a very simple programming
language to build a table representing the declaration of your system state.

It is intended to be used for Unix-like systems, though I only use it on Linux
and Mac.

## Usage

### Minimal example

`syke` looks for a configuration file in `~/.config/syke/syke.lua`.

A simple `syke.lua` could look somewhat like this.

```lua
return {
  symlinks = {
    {
      source = "/home/tommy/.dotfiles/config/bashrc",
      target = "/home/tommy/.bashrc",
    },
    {
      source = "/home/tommy/.dotfiles/config/profile",
      target = "/home/tommy/.profile",
    },
  }
}
```

This would tell `syke` to set a symlink from the `bashrc` and `profile` in my
dot files to the appropriate places in my home directory.

Since we're using lua, we can simplify this config a little bit:

```lua
local home = "/home/tommy"
local myconfig = home .. "/.dotfiles/config"
return {
  symlinks = {
    {
      source = myconfig .. "/bashrc",
      target = home .. "/.bashrc",
    },
    {
      source = myconfig .. "/profile",
      target = home .. "/.profile",
    },
  }
}
```

### Using the lua stdlib

Before parsing your lua configuration, `syke` opens the lua standard library,
so you can use modules like `os` and `io`. This way, you can easily tweak your
config depending on the host:

```lua
local uname = io.popen("uname -s", "r"):read("*l")
local home = os.getenv("HOME")
local myconfig = home .. "/.dotfiles/config"

local symlinks = {
  {
    source = myconfig .. "/bashrc",
    target = home .. "/.bashrc",
  },
  {
    source = myconfig .. "/profile",
    target = home .. "/.profile",
  },
}

-- on my mac, I want to also link my aerospace config
if uname == "Darwin" then
  symlinks[#symlinks + 1] = {
    source = myconfig .. "/aerospace.toml",
    target = home .. "/.config/aerospace.toml",
  }
end

return { symlinks = symlinks }
```

### Splitting your config into modules

`syke` gives you the option to split your configuration into multiple files.
You may add a `lua` directory next to your `syke.lua`, and any `.lua` files in
there are automatically added to the package path, so you can simply `require`
them.

Let's say that the `symlink` config from earlier starts growing too large, so you
want to split it into a different module named `symlinks`. For this example, you
may create a file structure like this:

```
~/.config/syke/
  |- syke.lua
  |- lua/
      |- symlinks.lua
```

The contents of `symlinks.lua` in this example would be:

```lua
-- ~/.config/syke/lua/symlinks.lua
local uname = io.popen("uname -s", "r"):read("*l")
local home = os.getenv("HOME")
local myconfig = home .. "/.dotfiles/config"

local symlinks = {
  {
    source = myconfig .. "/bashrc",
    target = home .. "/.bashrc",
  },
  {
    source = myconfig .. "/profile",
    target = home .. "/.profile",
  },
}

-- on my mac, I want to also link my aerospace config
if uname == "Darwin" then
  symlinks[#symlinks + 1] = {
    source = myconfig .. "/aerospace.toml",
    target = home .. "/.config/aerospace.toml",
  }
end

return symlinks
```

And then you can require this module in your `syke.lua` like this:

```lua
-- ~/.config/syke/syke.lua
return {
  symlinks = require("symlinks"),
}
```

Splitting your configuration like this can be very useful, once you use many
different `syke` features, and defining the full table in just one file could
be pretty unwieldy.

## TODO / planned feature scope

I plan on making `syke` the one tool I use to make my systems as reproducible
and their configuration as declarative as possible. For that purpose, these are
some of the planned features:

- [x] declare symlinks you want to have set
- [x] declare git repositories you want to have cloned and synced
- [ ] run arbitrary shell commands at various points during a `syke` run (at the beginning, before or after certain subcommands, or at the very end)
- [ ] declare packages you want to have installed via various package managers (including removing packages you remove from your config)
  - [ ] homebrew
  - [ ] pacman
  - [ ] paru (or maybe I'll implement my own small aur helper system)
- [ ] declare regexes, lines, or blocks of text in textfiles

## License

See the `LICENSE` text file for licensing information.
