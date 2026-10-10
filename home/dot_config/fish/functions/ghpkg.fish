function ghpkg --description "Run a command with GITHUB_TOKEN scoped to GitHub Packages (nuget.pkg.github.com), without polluting gh's own auth"
    set -l token_file ~/.config/hadrian/github-packages-token
    if not test -f $token_file
        echo "ghpkg: missing $token_file (should contain a GitHub PAT with read:packages scope)" >&2
        return 1
    end
    env GITHUB_TOKEN=(cat $token_file) GITHUB_USERNAME=$GITHUB_USERNAME $argv
end
