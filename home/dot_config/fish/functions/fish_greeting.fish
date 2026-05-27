function fish_greeting
    if command -q cowsay; and command -q fortune
        fortune | cowsay
    else if command -q cowsay
        cowsay "Hi 🐟"
    else
        echo "Hi 🐟"
    end
end
