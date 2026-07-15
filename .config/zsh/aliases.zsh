# ~/.config/zsh/aliases.zsh
#
# Where does he get those wonderful toys??

# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.tar.xz)    tar xJf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias tree='eza --tree --icons'

alias cat='bat'

alias grep='grep --color=auto'
alias vim='nvim'
alias p='sudo pacman'

alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'

alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias du='du -h'                          #human-readable sizes
alias feh='feh --scale-down'

alias sysf='systemctl --failed'
alias jrnlf='sudo journalctl -p 3 -xb'

# git magic
alias g='git'
alias gaa='git add .'
alias gb='git branch'
alias gcmsg='git commit -m'
alias gcob='git checkout -b'
alias gd='git diff'
alias glo='git log --oneline --decorate --color'
alias glog='git log --oneline --decorate --color --graph'
alias glod='git pull origin develop'
alias gst='git status'
alias gsub='git submodule update --init'
alias gsubr='git submodule foreach git submodule update --init'

# k8
alias kgp='kubectl get pods'
alias kgpo='kubectl get pods -o wide'
alias k8='kubectl.exe '

