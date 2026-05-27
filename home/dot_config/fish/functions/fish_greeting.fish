function fish_greeting
    set -l cols (tput cols)
    set -l width (math --scale=0 "$cols * 0.65")
    if command -q cowsay; and command -q fortune
        fortune | cowsay -W $width
    else if command -q cowsay
        cowsay -W $width "Hi 🐟"
    else
        echo "Hi 🐟"
    end
end
