# Language settings
set -gx LANG en_US.utf8

# Editor configuration
if test -n "$SSH_CONNECTION"
    set -gx EDITOR nano
else
    set -gx EDITOR code
end

# Architecture flags
set -gx ARCHFLAGS "-arch (uname -m)"

# PATH configuration for Homebrew and other tools
# Add Homebrew to PATH first
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin

# Other PATH additions
fish_add_path /opt/homebrew/opt/dotnet-sdk/bin
fish_add_path /opt/homebrew/opt/libpq/bin
fish_add_path /opt/homebrew/opt/node@18/bin
fish_add_path ~/go/bin

# 1Password SSH configuration
set -gx SSH_AUTH_SOCK ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

source ~/.custom_aliases
source ~/.extra_env_vars

# zoxide init command for a better cd
zoxide init fish | source

# Interactive session specific commands
if status is-interactive
    # kubectl completion (if kubectl is available)
    if command -q kubectl
        kubectl completion fish | source
    end

    # Docker completions (if docker is available)
    if command -q docker
        if test -d ~/.docker/completions
            # Fish will automatically load completions from ~/.config/fish/completions/
            # Copy docker completions if they exist
            if test -f ~/.docker/completions/docker.fish
                source ~/.docker/completions/docker.fish
            end
        end
    end
end
