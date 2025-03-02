export LANG=en_US.utf8

source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='code'
fi

# Compilation flags
export ARCHFLAGS="-arch $(uname -m)"

source ~/.custom_aliases

export PATH="/opt/homebrew/opt/dotnet@8/bin:$PATH"
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
