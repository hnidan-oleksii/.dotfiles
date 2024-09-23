# git
alias gpo="git push origin"
alias ga="git add"
alias gcm="git commit -m"
alias gss="git status"

# sklauncher
alias sk="find -name "sklauncher" -exec java -jar {} \;"

# soulseek
alias sls="find -name "soulseekqt.appimage" -exec ./{} \;"

# youtube music
alias ytm="find -name "youtubemusic.appimage" -exec ./{} \;"

# fzf and create sessions
bind '"\C-a\C-f":"tmxs\n"'

# jupyter notebook
function jp() {
    if [ "$#" -eq 0 ]; then
	ENV="def"
    else
	ENV="$1"
    fi

    conda activate $ENV
    jupyter notebook
}

# tmux sessionizer
tmxs() {
    $HOME/.local/bin/tmux-sessionizer
}
