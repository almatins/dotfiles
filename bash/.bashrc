# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Disable XON/XOFF flow control. Without this, C-s freezes the terminal instead of
# reaching the program: Neovim 0.11+ binds C-s to LSP signature help in insert mode,
# and the freeze looks exactly like a hang. C-q would unfreeze it, but nobody
# remembers that. Guarded to interactive shells, since stty needs a tty.
case $- in
    *i*) stty -ixon ;;
esac

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Flutter SDK
export PATH="$HOME/development/flutter/bin:$PATH"

# Go
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/emulator"

# Tunneling ESDM
alias tunnel-dev='ssh -f -N -L 6443:172.16.23.32:6443 adm-cpww@172.16.23.32'
alias tunnel-dev-stop='pkill -f "6443:172.16.23.32:6443"'

# Frontend testing (needs tunnel-dev running first — kubectl port-forward
# talks to the API server at 127.0.0.1:6443, which only tunnel-dev provides)
alias frontend-forward='KUBECONFIG="$HOME/.kube/config" kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80 > /tmp/simpel-frontend-forward.log 2>&1 &'
alias frontend-forward-stop='pkill -f "port-forward -n ingress-nginx svc/ingress-nginx-controller"'

# Synergy service recovery
alias synergy-fix='"$HOME/.local/bin/synergy-fix"'
alias nv='NVIM_APPNAME=nvim-view nvim'

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path bash)"

# opencode
export PATH=/home/almatins/.opencode/bin:$PATH

# Dart/Flutter global CLI tools
export PATH="$PATH":"$HOME/.pub-cache/bin"
