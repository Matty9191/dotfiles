VERSION=95
# Author: Matty < matty91 at gmail dot com >
# Last Updated: 02-03-2020
# License: 
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more detai

# History settings
export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/games:/opt/VSCode-linux-x64::/snap/bin:$HOME/bin
export HISTFILESIZE=100000
export HISTSIZE=100000
export HISTCONTROL=ignoreboth
export HISTTIMEFORMAT="%F %T "

# Git shell configuration
export GIT_PROMPT_FETCH_REMOTE_STATUS="1"
export GIT_PROMPT_END="$ "
export FZF_DEFAULT_OPTS='--height=70% --preview="cat {}" --preview-window=right:60%:wrap'
export FZF_DEFAULT_COMMAND='rg --files'
export FZF_CTRL_T_COMMAND='$FZF_DEFAULT_COMMAND'

# Make PS 1 useful
export KUBE_PS1_PREFIX=''
export KUBE_PS1_SUFFIX=''
export KUBE_PS1_SYMBOL_ENABLE='false'
export KUBE_PS1_CTX_COLOR=''
export KUBE_PS1_NS_COLOR=''

prompt() {
    export PS1="${CUSTOM_PS1:-\n[\u@$(hostname -f)][RC:$?][\w][$(kube_ps1)]$ }"
}
PROMPT_COMMAND=prompt

# Append to the history file
shopt -s histappend

# Terminal settings
shopt -s checkwinsize

# Default location to place virtual environments
export WORKON_HOME=/home/matty/virtualenv
export PROJECT_HOME=/home/matty/virtualenv

# GO workspace path
GOPATH=$HOME/go

devme() {
    if [[ ! -f "${HOME}/.vimrc"  ]]; then
        sudo yum -y install git tmux vim python3 python3-pip curl
        git config --global user.email "matty91@gmail.com"
        git config --global user.name "Matty"
        git clone https://github.com/Matty9191/dotfiles.git "${HOME}/dotfiles"
        git clone https://github.com/Matty9191/bash-git-prompt.git "${HOME}/.bash-git-prompt"
        mv "${HOME}/dotfiles/.bashrc" "${HOME}/.bashrc"
        mv "${HOME}/dotfiles/.tmux.conf" "${HOME}/.tmux.conf"
        mv "${HOME}/dotfiles/.vimrc" "${HOME}/.vimrc"
        pip3 install --user powerline-status --user
    fi

    if [[ -d "${HOME}/dotfiles" ]]; then
        rm -rf "${HOME}/dotfiles"
    fi

    if [[ ! -d "${HOME}/bin" ]]; then
        mkdir "${HOME}/bin"
        curl -o "${HOME}/bin/fzf" https://prefetch.net/bin/fzf
        curl -o "${HOME}/bin/rg" https://prefetch.net/bin/rg
        chmod 700 "${HOME}/bin/fzf" "${HOME}/bin/rg"
    fi
}

# View markdown files from the command line
vmd() {
    pandoc "${1}" | lynx --stdin
}

# Create a new GO workspace if it doesn't exist
gows() {
    if [ ! -d "${GOPATH}" ]; then
        echo "Setting up a go workspace in ${GOPATH}"
        mkdir -p ${GOPATH} ${GOPATH}/src ${GOPATH}/bin ${GOPATH}/pkg
        mkdir -p ${GOPATH}/src/github.com/Matty9191
    fi
}

# Update bashrc to a newer version
update() {
    bashrc_source="https://raw.githubusercontent.com/Matty9191/dotfiles/master/.bashrc"
    temp_file=$(mktemp /tmp/bash_auto_update_XXXXXXXX)

    curl -s -o ${temp_file} ${bashrc_source}
    RC=$?

    if [ ${RC} -eq 0 ]; then
        version=$(head -1 ${temp_file} | awk -F'=' '/VERSION/ {print $2}')

        if [ "${version}" -gt "${VERSION}" ]; then
            # Code to offer options rather than auto-updating
            # echo 'There is a new version of .bashrc; see the changes with:'
            # echo '   cmp .bashrc ${temp_file}'
            # echo 'Install changes with:'
            # echo '   cp ${temp_file} .bashrc
            echo "Upgrading bashrc from version ${VERSION} to ${version}"
            cp ${HOME}/.bashrc ${HOME}/.bashrc.$(/bin/date "+%Y%m%d.%H%M%S")
            mv -f ${temp_file} ${HOME}/.bashrc
        fi
    else
        echo "Unable to retrieve a bashrc from ${bashrc_source}"
        rm ${temp_file}
    fi
}

dict() {
        if [[ "${1}" != "" ]]; then
                lynx -cfg=/dev/null -dump "http://www.dictionary.com/cgi-bin/dict.pl?term=$1" | more
        else
                echo "USAGE: dict word"
        fi
}

nrange() {
        lo=$1
        hi=$2
        while [[ $lo -le $hi ]]; do
                echo -n $lo " "
                lo=`expr $lo + 1`
        done
}

dnsfinger() {
   domain=${1}

   grep -F ${domain} /var/named/chroot/logs/named.queries | awk -F'[()]+' '{print $2}' | sort | uniq
}

malloc() {
    bytes=$((${1} * 1024*1024))
    echo "Allocating ${bytes}-bytes of memory"
    yes | tr \\n x | head -c ${bytes} | grep n
}

# Uncompress the file passed as an argument (thanks stackoverflow)
extract () {
   if [ -f $1 ] ; then
       case $1 in
           *.tar.bz2)   tar        xvjf $1   ;;
           *.tar.gz)    tar        xvzf $1   ;;
           *.bz2)       bunzip2         $1   ;;
           *.rar)       unrar      x    $1   ;;
           *.gz)        gunzip          $1   ;;
           *.tar)       tar        xvf  $1   ;;
           *.tbz2)      tar        xvjf $1   ;;
           *.tgz)       tar        xvzf $1   ;;
           *.zip)       unzip           $1   ;;
           *.Z)         uncompress      $1   ;;
           *.7z)        7z         x    $1   ;;
           *)           echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file!"
   fi
}

# Run the last command with sudo  (thanks stackoverflow)
ss() {
    if [[ $# == 0 ]]; then
       sudo $(history -p '!!')
    else
       sudo "$@"
    fi
}

# Remove comments from a file
rc() {
    egrep "^#" ${1}
}

# Have some fun
if [ -x /bin/cowsay ] && [ -x /bin/fortune ] ||
   [ -x /usr/games/cowsay ] && [ /usr/games/fortune ]; then
       fortune | cowsay
fi

# User specific aliases and functions
alias webshare="python -m SimpleHTTPServer 8000"
alias smtptestserver="python -m smtpd -c DebuggingServer -n localhost:8025"
alias uup="apt update && apt upgrade && apt dist-upgrade"
alias cup="yum -y update"
alias rd="/usr/bin/rdesktop -g 1024x768 ${1}:3389"
alias record="/usr/bin/cdrecord -v speed=8 dev=/dev/dvd ${1}"
alias ecat="cat -vet ${1}"
alias syncsystime="hwclock --set --date="`date "+%Y-%m-%d %H:%M:%S"`" --utc"
alias k="kubectl"
alias shot="gnome-screenshot -i"
alias dracut_updatekernel="dracut -f –v"
alias iptables-all="iptables -vL -t filter && iptables -vL -t nat && iptables -vL mange && iptables -vL -t raw && iptables -vL -t security"
alias iptables-clean="iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X"
alias ipconfig="ip -c a"
alias dockerc='docker rm $(docker ps -a -q)'
alias dockeric='docker rmi $(docker images | grep "^<none>" | awk "{print $3}")'
alias conntrackt="cat /proc/sys/net/netfilter/nf_conntrack_count"

if [ ! -S ~/.ssh/ssh_auth_sock ]; then
    eval `ssh-agent`
    ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
    export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
    ssh-add -l > /dev/null || ssh-add
fi

# Source the kubectl auto completion functions
if [[ -x "$(command -v kubectl)" ]]; then
    eval "$(kubectl completion bash)"
fi

# Use direnv to add variables to the environment
if [[ -x "$(command -v direnv)" ]]; then
    eval "$(direnv hook bash)"
fi

# Add a git prompt if inside a git repository
if [[ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source $HOME/.bash-git-prompt/gitprompt.sh
fi

# Add fzf to the toolkit
if [[ -f ~/.fzf.bash ]]; then
    source "${HOME}/.fzf.bash"
fi

# Add Kubernetes context and namespace to PS1
if [[ -f "$(command -v kube-ps1)" ]]; then
    source "$(command -v kube-ps1)"
fi

# Add private settings
if [[ -f ${HOME}/.private ]]; then
    source ${HOME}/.private
fi
