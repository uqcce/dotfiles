if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_prompt
    set -l accent '#2ae88a'

    set_color $accent
    printf '%s' $USER

    set_color normal
    printf '@'
    printf '%s' (prompt_hostname)
    printf ' '

    set_color $accent
    printf '%s' (prompt_pwd)

    set_color normal
    printf ' ❯ '
end

set -g fish_color_option 4aaa6a
set -g fish_color_param 4aaa6a
