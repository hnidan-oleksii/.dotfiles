# dotfiles

Fedora configs, managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level dir is a stow package mirroring `$HOME`

## Packages

| Package     | Target                                   |
|-------------|------------------------------------------|
| nvim        | `~/.config/nvim`                         |
| lf          | `~/.config/lf`                           |
| tmux        | `~/.tmux.conf`                           |
| bash        | `~/.bashrc`, `~/.bash_profile`           |
| bin         | `~/.local/bin`                           |
| alacritty   | `~/.config/alacritty.toml`               |
| git         | `~/.gitconfig`                           |
| fcitx5      | `~/.config/fcitx5`                       |
| mangohud    | `~/.config/MangoHud/MangoHud.conf`       |
| xorg        | `~/.xinitrc`, `~/.Xresources`            |
| dwm         | `~/.dwm/autostart.sh`                    |
| ssh         | `~/.ssh/config`                          |
| tauon       | `~/.var/app/…/TauonMusicBox/tauon.conf`  |
| wallpapers  | `~/Pictures/wallpapers`                  |

Not stowed: `packages/` (dnf/flatpak lists), `suckless/` (dwm/st patches), `floorp/` (userChrome/userContent CSS).

## Install

```bash
git clone git@github.com:hnidan-oleksii/.dotfiles.git ~/personal/.dotfiles
cd ~/personal/.dotfiles
./install.sh
./install.sh --packages
```

Stow refuses when a target already exists — remove/rename it, or adopt it with `./install.sh --adopt` (pulls the existing file in and replaces it with a symlink).

Unlink a package: `stow -D -t ~ <pkg>`. Re-link after edits: `stow -R -t ~ <pkg>`.

## Add a new config

```bash
mkdir -p foo/.config/foo && mv ~/.config/foo/* foo/.config/foo/
# add "foo" to PACKAGES in install.sh, then:
stow -t ~ foo
```

## suckless (dwm / st)

Patches are diffs against dwm 6.5 / st 0.9.2

```bash
git clone https://git.suckless.org/dwm && cd dwm
git checkout 6.5
git apply ~/personal/.dotfiles/suckless/dwm.patch
sudo make clean install
```

Same for st (tag `0.9.2`). dwmblocks and dmenu are unmodified upstream.
