#!/usr/bin/env bash

which() {
    local show_all=false
    if [ "${1:-}" = "-a" ]; then
        show_all=true
        shift
    fi

    if [ "$#" -eq 0 ]; then
        printf 'usage: which [-a] command ...\n' >&2
        return 2
    fi

    if [ -n "${ZSH_VERSION:-}" ]; then
        if [ "$show_all" = true ]; then
            whence -a "$@"
        else
            whence "$@"
        fi
    else
        if [ "$show_all" = true ]; then
            type -a "$@"
            return
        fi

        local name kind alias_output alias_value path
        for name in "$@"; do
            kind="$(type -t "$name" 2>/dev/null || true)"
            case "$kind" in
                alias)
                    alias_output="$(alias "$name")"
                    alias_value="${alias_output#alias "$name"=}"
                    alias_value="${alias_value#\'}"
                    alias_value="${alias_value%\'}"
                    printf '%s\n' "$alias_value"
                    ;;
                file)
                    type -P "$name"
                    ;;
                function|builtin|keyword)
                    printf '%s is a shell %s\n' "$name" "$kind"
                    ;;
                *)
                    path="$(command -v "$name" 2>/dev/null || true)"
                    if [ -n "$path" ]; then
                        printf '%s\n' "$path"
                    else
                        return 1
                    fi
                    ;;
            esac
        done
    fi
}
