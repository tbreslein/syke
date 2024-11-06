return {
  foo = {
    bar = 42,
  },
  symlinks = {
    {
      source = "~/.dotfiles/config/alacritty/alacritty.toml",
      target = "~/.config/alacritty/alacritty.toml",
    },
    {
      source = "~/.dotfiles/config/direnv.toml",
      target = "~/.config/direnv/direnv.toml",
    },
  },
}
