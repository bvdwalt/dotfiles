export LANG=en_US.utf8

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)


# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='code'
fi

# Compilation flags
export ARCHFLAGS="-arch $(uname -m)"

# source things
source $ZSH/oh-my-zsh.sh
source ~/.custom_aliases

export PATH="/opt/homebrew/opt/dotnet@8/bin:$PATH"
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

eval "$(starship init zsh)"