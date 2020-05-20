# Fields
bfe_system_args_= # Command line arguments
bfe_system_notifier_= # Status notifier

bfe.system.init() {
    bfe_system_args_=$1
    bfe_system_notifier_=$2

    bfe.toolbox.log.init "${bfe_system_args_}"
    bfe.toolbox.utils.init "${bfe_system_args_}"
    bfe.toolbox.audit.init "${bfe_system_args_}"
    bfe.toolbox.filesystem.init "${bfe_system_args_}"
    bfe.toolbox.restic.init "${bfe_system_args_}"
}

bfe.system.stdout.printMessageAndValue(){
    local msg=$1
    local varName=$2
    local varValue=$(${varName})

    shift

    if [ ${#varValue} -gt 0 ]
    then
        echo "${msg}$($@)"
    fi
}

bfe.system.stdout.printValue(){
    local varName=$1
    local varValue=$(${varName})

    if [ ${#varValue} -gt 0 ]
    then
        echo "${varName}: $($@)"
    fi
}

bfe.system.stdout.printValueObscured(){
    local varName=$1
    local varValue=$(${varName})

    if [ ${#varValue} -gt 0 ]
    then
        echo "${varName}: ****"
    fi
}

bfe.system.stdout.printString(){
    echo $@
}

bfe.system.stdout.printArray(){
    local msg=$1
    shift 1
    local a b
    a="declare -a b=$($@)"
    eval "$a"
    local list=""
    local first=true
    for i in "${b[@]}"
    do
        if ! ${first}; then list="${list}, "; fi
        if ${first}; then first=false; fi
        list="$list$i"
    done
    echo "${msg}${list}"
}
