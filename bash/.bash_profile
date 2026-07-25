# system vars
export PATH="$PATH:/var/lib/flatpak/exports/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
export PATH=/usr/local/cuda-12.9/bin${PATH:+:${PATH}}
export LC_CTYPE=en_US.UTF-8
export LC_TIME=en_GB.UTF-8
export HISTFILESIZE=20000
export HISTSIZE=20000
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export ECORE_IMF_MODULE=xim
export XMODIFIERS=@im=none
export EDITOR=nvim
export BROWSER=one.ablaze.floorp
# history: drop dups and space-prefixed (secret) commands
export HISTCONTROL=ignoreboth

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
