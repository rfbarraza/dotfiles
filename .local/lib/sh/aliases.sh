alias zshconfig="$EDITOR \"$HOME/.zshrc\""
alias ohmyzsh="$EDITOR \"$HOME/.oh-my-zsh\""
alias ssource="source \"$HOME/.zshrc\""

alias h="history"
alias c="cd"
alias g="git"
alias gp='g diff --color=never'
alias gs="git status"
alias gcm="git commit -m"
alias gbd="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias ka='killall -9'

alias currentdate='date "+%Y.%m.%d"'
alias td='echo $(date +%Y-%m-%d)'
alias ip="curl ipinfo.io/ip"
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"

alias ll1="tree --dirsfirst -ChFL 1"
alias ll2="tree --dirsfirst -ChFL 2"
alias ll3="tree --dirsfirst -ChFL 3"
alias ll4="tree --dirsfirst -ChFupDaL 1"
alias ll5="tree --dirsfirst -ChFupDaL 2"
alias ll6="tree --dirsfirst -ChFupDaL 3"

alias sake-home="sake -c ~/.config/sake/home/sake.yaml"
alias sake-wysd="sake -c ~/.config/sake/wysd/sake.yaml"

# (macOS specific)[http://xkcd.com/530/]
if [[ darwin_check ]]; then
  alias stfu="osascript -e 'set volume output muted true'"
  alias pumpitup="osascript -e 'set volume 10'"
fi
