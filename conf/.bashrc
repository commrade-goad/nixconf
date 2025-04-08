export EDITOR="nvim"
export PYTHON_HISTORY="$HOME/.cache/py_hist"
export GOPATH="$HOME/.cache/go"
export GNUPGHOME="$HOME/.local/share/gnupg"
export npm_config_cache="$HOME/.cache/npm"
export CARGO_HOME="$HOME/.cache/cargo"
export RUSTUP_HOME="$HOME/.local/opt/rustup"
export MANPAGER='nvim +Man!'
export ACCENT_COLOR="A7C080"

PS1='[\[\e[1;32m\]\u\[\e[0m\]@\[\e[1;34m\]\h\[\e[0m\]:\[\e[1;35m\]\w\[\e[0m\]]\n\[\e[1;36m\]\$\[\e[0m\] '

if [[ -n "$NIX_GCROOT" ]]; then
    PS1='(nix-shell) '${PS1}
fi

eval "$(zoxide init bash)"

## fzf
eval "$(fzf --bash)"

## Alias setup
alias ls="eza -l --all --icons --header --git --group-directories-first"
alias lsd="eza -l --all --icons --header --git --group-directories-first --sort=date"
alias yt-dl="python3 '$HOME/Documents/dev/goad-yt-dlp-helper/src/yt-dlp-helper-v2-5.py'"
alias weather="curl wttr.in"
alias calendar="cal -3"
alias v="nvim"
alias sv="sudoedit"
alias touhou-playlist="mpv 'https://www.youtube.com/playlist?list=PLXZnhQ4xFkPXkPd0aiW3V12UMBFD38tXg' --no-video"
alias :wq="exit"
alias neofetch="fastfetch"
alias reload-waybar="pkill waybar && hyprctl dispatch -- exec waybar -s ~/.config/hypr/waybar/style.css -c ~/.config/hypr/waybar/config.jsonc"
alias m-build="meson build && cp ./build/compile_commands.json ./"
alias tarx="tar -xvzf"
alias grep="grep --color=always"
alias tm="tmux a || tmux"
alias rm="rm -I"
alias rsync="rsync -ah --info=progress2"
alias reloadmime="update-desktop-database ~/.local/share/applications/"
alias pyvenv="python -m venv ./ --system-site-packages"

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

if [ "$(tty)" = "/dev/tty1" ] && [ -z "$XDG_CURRENT_DESKTOP" ]; then
    Hyprland
fi
