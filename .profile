alias ls="ls -laG"

export http_proxy=http://proxy.inet.bloomberg.com:81
export https_proxy=http://proxy.inet.bloomberg.com:81 
export HTTP_PROXY=http://proxy.inet.bloomberg.com:81
export HTTPS_PROXY=http://proxy.inet.bloomberg.com:81

# Git function to change email based on directory
function updateGitName {

    if [[ $# != 1 ]];then
        return 1
    fi

    local WORK_DIR="$HOME/workspace"
    local PERSONAL_DIR="$HOME/workspace/personal"

    local current=`pwd`
    
    # Check if directory finishes with ".git" if so scrap it
    local file=$1
    if [[ "${file: -4}" == ".git" ]]; then
        file="${file%.git}"
    fi

    # Go to new directory
    cd $file

    case $current in
        "$WORK_DIR")
            command git config user.email "jbouchard8@bloomberg.net"
            ;;
        "$PERSONAL_DIR")
            command git config user.email "jim@polarcoordinates.org"
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
