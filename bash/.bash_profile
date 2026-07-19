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

# system
alias sdu="sudo dnf upgrade --refresh"
alias fu="flatpak update"

# tooling
alias glog="git log --oneline --graph"
alias lzd="lazydocker"

# python venv
function va() {
    if [ "$#" -eq 0 ]; then
	ENV=".venv"
    else
	ENV="$1"
    fi

	source $ENV/bin/activate
}

# fzf and create sessions
bind '"\C-a\C-f":"tmxs\n"'

# jupyter notebook
function jp() {
	va
    jupyter notebook
}

# tmux sessionizer
tmxs() {
    $HOME/.local/bin/tmux-sessionizer
}
. "$HOME/.cargo/env"


. "/home/surikadt/.local/share/bob/env/env.sh"

# direnv
eval "$(direnv hook bash)"
