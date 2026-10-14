# Bash completion for tinybackup
# Static: no repository access, so snapshot IDs are not completed

_tinybackup_reply() {
    mapfile -t COMPREPLY < <(compgen "${@}" -- "${cur}")
}

_tinybackup() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local commands='backup snapshot list ls restore cat mount policy check maintenance raw connect disconnect web-ui'
    local i=1

    # Command index: 1, or 3 after -c FILE
    if (( COMP_CWORD > 1 )); then
        case "${COMP_WORDS[1]}" in
            -c|--config) i=3 ;;
        esac
    fi

    if (( COMP_CWORD < i )); then
        compopt -o filenames
        _tinybackup_reply -f
    elif (( COMP_CWORD == i )); then
        (( i == 1 )) && commands+=' -c --config -h --help'
        _tinybackup_reply -W "${commands}"
    else
        case "${COMP_WORDS[i]}:$(( COMP_CWORD - i ))" in
            list:1|ls:1)
                if [[ ${cur} == -* ]]; then
                    _tinybackup_reply -W '--all --host'
                else
                    compopt -o filenames
                    _tinybackup_reply -d
                fi ;;
            restore:2)
                compopt -o filenames
                _tinybackup_reply -f ;;
            mount:1)        _tinybackup_reply -W '--shell' ;;
            policy:1)       _tinybackup_reply -W '--update' ;;
            maintenance:1)  _tinybackup_reply -W '--confirm' ;;
        esac
    fi
}

complete -F _tinybackup tinybackup
