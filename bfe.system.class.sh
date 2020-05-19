# Fields
bfe_system_args_= # Command line arguments
bfe_system_notifier_= # Status notifier
bfe_system_log_filename_= # The filename to be used for the log

bfe.system.init() {
    bfe_system_args_=$1
    bfe_system_notifier_=$2

    bfe.system.log.init
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

bfe.system.log.init() {
    local backup_name=`${bfe_system_args_}.backupName`
    local hostname=`${bfe_system_args_}.hostname`
    local log_dir=`bfe.toolbox.utils.getLogDirectory`

    if [ "`${bfe_system_args_}.useLog`" = true ]
    then
        bfe.toolbox.utils.run "${MKDIR_CMD} -p ${log_dir}"
        if [ -n "${backup_name}" ]
        then
            bfe_system_log_filename_=${log_dir}`date +%y%m%d_%H%M%S`_${hostname}_${backup_name}
        else
            bfe_system_log_filename_=${log_dir}`date +%y%m%d_%H%M%S`_${hostname}
        fi
    else
        unset bfe_system_log_filename_
    fi

    if [ ${#bfe_system_log_filename_} -gt 0 ]
    then
        ${ECHO_CMD} "Log filename: ${bfe_system_log_filename_}"
    fi
}

bfe.system.log.cmd() {
    if [ "`${bfe_system_args_}.useLog`" = true ]
    then
        ${ECHO_CMD} "CMD:$@" >> ${bfe_system_log_filename_}.log
    else
        ${ECHO_CMD} "CMD:$@"
    fi
}

bfe.system.log.highlight() {
    if [ "`${bfe_system_args_}.useLog`" = true ]
    then
        ${ECHO_CMD} "===>:$@" >> ${bfe_system_log_filename_}.log
        ${ECHO_CMD} "===>:$@" 1>&2 >> ${bfe_system_log_filename_}.err
    else
        ${ECHO_CMD} "===>:$@"
    fi
}

bfe.system.log.info() {
    if [ "`${bfe_system_args_}.useLog`" = true ]
    then
        ${ECHO_CMD} "INFO:$@" >> ${bfe_system_log_filename_}.log
    else
        ${ECHO_CMD} "INFO:$@"
    fi
}

bfe.system.log.error() {
    ${ECHO_CMD} "ERROR:$@"
    if [ "`${bfe_system_args_}.useLog`" = true ]
    then
        ${ECHO_CMD} "ERROR:$@" >> ${bfe_system_log_filename_}.log
        ${ECHO_CMD} "ERROR:$@" 1>&2 >> ${bfe_system_log_filename_}.err
    fi

    if [ "`${bfe_system_args_}.sendEmail`" = true ]
    then
        ${bfe_system_notifier_}.append "ERROR: $@"
        ${bfe_system_notifier_}.notifyError
    fi
    exit 1
}
