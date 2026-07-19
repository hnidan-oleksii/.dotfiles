# suckless patches

dwm/st customizations as diffs against upstream

| Tool      | Base  | Patch       |
|-----------|-------|-------------|
| dwm       | 6.5   | `dwm.patch` |
| st        | 0.9.2 | `st.patch`  |
| dwmblocks | —     | unmodified (torrinfail/dwmblocks) |
| dmenu     | —     | unmodified (suckless) |

## Rebuild

```bash
cd ~/personal/builds/suckless
DOTS=~/personal/.dotfiles

git clone https://git.suckless.org/dwm && cd dwm
git checkout 6.5 && git apply $DOTS/suckless/dwm.patch
sudo make clean install && cd ..

git clone https://git.suckless.org/st && cd st
git checkout 0.9.2 && git apply $DOTS/suckless/st.patch
sudo make clean install && cd ..

git clone https://github.com/torrinfail/dwmblocks && cd dwmblocks
sudo make install && cd ..
```

## Regenerate a patch

```bash
git -C ~/personal/builds/suckless/dwm diff 7aa634e \
  -- . ':(exclude)*.o' ':(exclude)patches' > ~/personal/.dotfiles/suckless/dwm.patch
```
