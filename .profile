# Git function to change email based on directory
function updateGitName {

    if [[ $# != 1 ]];then
        return 1
    fi

    local WORK_DIR="$HOME/workspace"
    local PERSONAL_DIR="$HOME/workspace/personal"

    local current=`pwd`
    # Go to new directory
    cd $1

    case $current in
        "$WORK_DIR")
            command git config user.email "<work email>"
            ;;
        "$PERSONAL_DIR")
            command git config user.email "<personal email>"
            ;;
        *)
            ;;
    esac

    cd ..
}

git() {

    if [[ $1 == "clone" ]]; then
        command git "$@"

        # Get last word of command (so either the repo or the chain leading to the repo
        local repo=$(echo "$@" | awk '{print $NF}')

        # If we didn't set a specific name.. get the repo name that follows the last slash
        if [[ $repo == */* ]]; then
            repo=${repo##*/}
        fi

        # Get result of command
        if [[ $? == 0 ]]; then
            updateGitName $repo
        fi
    else
        command git "$@"
    fi
}
