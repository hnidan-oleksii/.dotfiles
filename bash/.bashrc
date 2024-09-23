# .bashrc

# source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# user specific environment
if ! [[ "$path" =~ "$home/.local/bin:$home/bin:" ]]; then
    path="$home/.local/bin:$home/bin:$path"
fi
export path

# uncomment the following line if you don't like systemctl's auto-paging feature:
# export systemd_pager=

# user specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

export BASH="$HOME/.bash"

source $BASH/.bash_profile

# .net tools
export path="$path:/home/surikadt/.dotnet/tools"
export path="$path:/home/surikadt/.dotnet/"

# >>> conda initialize >>>
# !! contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/surikadt/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/surikadt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/surikadt/miniconda3/etc/profile.d/conda.sh"
    else
        export path="/home/surikadt/miniconda3/bin:$path"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
