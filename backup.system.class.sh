# Fields
backup_system_log_args_= # Command line arguments
backup_system_log_filename_= # The filename to be used for the log

backup.system.init() {
    backup_system_log_args_=$1

    backup.system.log.init
}

backup.system.stdout.printMessageAndValue(){
    local msg=$1
    local varName=$2
    local varValue=$(${varName})

    shift 

    if [ ${#varValue} -gt 0 ]
    then
        echo "${msg}$($@)"
    fi
}

backup.system.stdout.printValue(){
    local varName=$1
    local varValue=$(${varName})

    if [ ${#varValue} -gt 0 ]
    then
        echo "${varName}: $($@)"
    fi
}

backup.system.stdout.printString(){
    echo $@
}

backup.system.stdout.printArray(){
    local msg=$1
    shift 1
    local a b
    a=$($@)
    a="declare -a b=${a#*=}"
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

backup.system.log.init() {
    local backupName=`${backup_system_log_args_}.backupName`
    local workDir=`${backup_system_log_args_}.workDir`
    local logSubDir=`${backup_system_log_args_}.logSubDir`
    local hostname=`${backup_system_log_args_}.hostname`

    if [ "`${backup_system_log_args_}.useLog`" = true ]
    then
        if [ -n "${backupName}" ]
        then
            backup_system_log_filename_=${workDir}/${logSubDir}/`date +%y%m%d_%H%M%S`_${hostname}_${backupName}
        else
            backup_system_log_filename_=${workDir}/${logSubDir}/`date +%y%m%d_%H%M%S`_${hostname}
        fi
    else
        unset backup_system_log_filename_
    fi

    ${ECHO_CMD} "Log filename: ${backup_system_log_filename_}"
}

backup.system.log.info() {
    if [ "`${backup_system_log_args_}.useLog`" = true ]
    then
        ${ECHO_CMD} "INFO:$@" >> ${backup_system_log_filename_}.log
    else
        ${ECHO_CMD} "INFO:$@"
    fi
}

backup.system.log.error() {
    ${ECHO_CMD} "ERROR:$@"
    if [ "`${backup_system_log_args_}.useLog`" = true ]
    then
        ${ECHO_CMD} "ERROR:$@" >> ${backup_system_log_filename_}.log
        ${ECHO_CMD} "ERROR:$@" 1>&2 >> ${backup_system_log_filename_}.err
    fi

    # TODO ANFO Enable email notifications
    #     if [ "${OK_TO_SEND_EMAIL}" = true ]
    #     then
    #         OK_TO_SEND_EMAIL=false
    #         EMAIL_MSG="${EMAIL_MSG}
    # ERROR: $@"
    #         send_email ${EMAIL_FROM} "Re: ${HOSTNAME} :(" "${EMAIL_MSG}" true
    #         OK_TO_SEND_EMAIL=true
    #     fi
    exit 1
}

backup.system.utils.starts_with_any_of(){
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++))
    {
        if [[ "${value}" == "${!i}"* ]]
        then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

backup.system.utils.propertyAccessor()
{
    properties="$1"
    operation="$2"
    value="$3"

    # Find the array id that matches the property being set, using the name of the property function being used.
    object_name=${properties%_*}
    name=${object_name}_$(echo "${FUNCNAME[1]}" | sed "s/.*\.\(.*\)$/\1/g") 
    eval "id=\${${name}}"

    local arrayPrefixes=( "array" )
    if [ $(backup.system.utils.starts_with_any_of "${arrayPrefixes[@]}" "${id}") == "y" ]
    then
        # This is an array.
        if [ "${operation}" == "=" ]
        then
            local a="declare -ga ${name}Array=${value#*=}"
            eval "${a}"
        else
            declare -p ${name}Array
        fi
    else
        if [ "${operation}" == "=" ]
        then
            local a="declare -g ${properties}[${name}]=${value}"
            eval "${a}"
        else
            eval "printf '%s\n' \"\${${properties}[${name}]}\""
        fi
    fi
}

backup.system.utils.getWorkingDirectory()
{
    src="${BASH_SOURCE[0]}"

    # resolve $src until the file is no longer a symlink
    while [ -h "${src}" ]
    do
        dir="$( cd -P "$( ${DIRNAME_CMD} "${src}" )" && pwd )"
        src="$(readlink "${src}")"
        # if $src was a relative symlink, we need to resolve it relative to
        # the path where the symlink file was located
        [[ ${src} != /* ]] && src="${dir}/${src}"
    done

    echo "$( cd -P "$( ${DIRNAME_CMD} "${src}" )" && pwd )"
}
