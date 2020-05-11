# Fields
bfe_system_args_= # Command line arguments
bfe_system_notifier_= # Status notifier
bfe_system_log_filename_= # The filename to be used for the log

bfe.system.init() {
    bfe_system_args_=$1
    bfe_system_notifier_=$2

    bfe.system.log.init
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
    local backupName=`${bfe_system_args_}.backupName`
    local workDir=`${bfe_system_args_}.workDir`
    local logSubDir=`${bfe_system_args_}.logSubDir`
    local hostname=`${bfe_system_args_}.hostname`

    if [ "`${bfe_system_args_}.useLog`" = true ]
    then
        if [ -n "${backupName}" ]
        then
            bfe_system_log_filename_=${workDir}/${logSubDir}/`date +%y%m%d_%H%M%S`_${hostname}_${backupName}
        else
            bfe_system_log_filename_=${workDir}/${logSubDir}/`date +%y%m%d_%H%M%S`_${hostname}
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

bfe.system.utils.starts_with_any_of(){
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

bfe.system.utils.contains()
{
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++))
    {
        if [[ "${value}" == "${!i}" ]]
        then
            ${ECHO_CMD} "y"
            return 0
        fi
    }
    ${ECHO_CMD} "n"
    return 1
}

bfe.system.utils.isOfflineMediaMounted()
{
    local label=$1

    # Discover the device id from the label.
    local device_id=$( ${BLKID_CMD} | ${GREP_CMD} \"${label}\" | ${CUT_CMD} -d : -f 1)
    if [ -z "${device_id}" ]
    then
        ${ECHO_CMD} "n"
        return 0
    fi

    # Check the device is mounted
    local device_is_mounted=`${GREP_CMD} ${device_id} /etc/mtab`
    if [ -z "${device_is_mounted}" ]
    then
        ${ECHO_CMD} "n"
        return 0
    fi

    ${ECHO_CMD} "y"
    return 1
}

bfe.system.utils.isOfflineMediaAvailable()
{
    local label=$1

    # Discover the device id from the label.
    local device_id=$( ${BLKID_CMD} | ${GREP_CMD} \"${label}\" | ${CUT_CMD} -d : -f 1)
    if [ -z "${device_id}" ]
    then
        ${ECHO_CMD} "n"
        return 0
    fi

    ${ECHO_CMD} "y"
    return 1
}

bfe.system.utils.mountOfflineMedia()
{
    local label=$1
    local medium_dir=$2
    local mount_dir="${medium_dir}/${label}"

    # Ensure the mount point exists
    if [ ! -d "${mount_dir}" ]
    then
         ${MKDIR_CMD} -p "${mount_dir}"
    fi
    if [ ! -d "${mount_dir}" ]
    then
        ${ECHO_CMD} "n"
        return 0
    fi

    # Discover the device id from the label.
    local device_id=$( ${BLKID_CMD} | ${GREP_CMD} \"${label}\" | ${CUT_CMD} -d : -f 1)
    if [ -z "${device_id}" ]
    then
        ${ECHO_CMD} "n"
        return 0
    fi

    # Mount the device
    #
    # If expecting thumbdrives, you probably want to avoid corruption.
    #      mount -t auto -o sync,noatime [...]
    #
    # If drive is VFAT/NFTS, this mounts the filesystem such that all files
    # are owned by a std user instead of by root.  Change to your user's UID
    # (listed in /etc/passwd).  You may also want "gid=1000" and/or "umask=022", eg:
    #      mount -t auto -o uid=1000,gid=1000 [...]
    #
    # Examples:
    #     ${MOUNT_CMD} -t vfat -o sync,noatime,uid=1000,gid=1000 ${device_id} "/${medium_dir}/${label}"
    #     # A good locale setting for ntfs
    #     ${MOUNT_CMD} -t auto -o sync,noatime,uid=1000,gid=1000,locale=en_US.UTF-8 ${device_id} "/${medium_dir}/${label}"
    #     # ext2/3/4 don't like uid option
    #     ${MOUNT_CMD} -t auto -o sync,noatime ${device_id} "/${medium_dir}/${label}"
    ${MOUNT_CMD} -t vfat -o sync,noatime,uid=1000,gid=1000 ${device_id} "/${medium_dir}/${label}"

    # Check the device is mounted
    local device_is_mounted=`${GREP_CMD} ${device_id} /etc/mtab`
    if [ -z "${device_is_mounted}" ]
    then
        ${ECHO_CMD} "n"
        return 0
    fi

    ${ECHO_CMD} "y"
    return 1
}

bfe.system.utils.unmountOfflineMedia()
{
    local label=$1
    local medium_dir=$2

    # Discover the device id from the label.
    local device_id=$( ${BLKID_CMD} | ${GREP_CMD} \"${label}\" | ${CUT_CMD} -d : -f 1)
    if [ -z "${device_id}" ]
    then
        ${ECHO_CMD} "n"
        return 0
    fi

    # Check the device is mounted
    local device_is_mounted=`${GREP_CMD} ${device_id} /etc/mtab`
    if [ -z "${device_is_mounted}" ]
    then
        ${ECHO_CMD} "n"
        return 0
    fi

    # Unmount the device
    ${UMOUNT_CMD} -l ${device_id}

    # Check the device is not mounted
    local device_is_mounted=`${GREP_CMD} ${device_id} /etc/mtab`
    if [ ! -z "${device_is_mounted}" ]
    then
        ${ECHO_CMD} "n"
        return 0
    fi

    ${ECHO_CMD} "y"
    return 1
}

bfe.system.utils.mountMedium()
{
    # Note: Returns 1 if this function has mounted the medium, 0 otherwise.
    local description_name=$1
    local medium_type=$2
    local medium_label=$3
    local medium_dir=$4

    if [ "${medium_type}" = "usbdrive" ]
    then
        if [ $(bfe.system.utils.isOfflineMediaMounted "${medium_label}") == "n" ]
        then
            if [ $(bfe.system.utils.isOfflineMediaAvailable "${medium_label}") == "n" ]
            then
                bfe.system.log.error "Backup description [${description_name}] requires backup medium labelled [${medium_label}] which is unavailable... (Note: May also need root access.)"
            else
                if [ $(bfe.system.utils.mountOfflineMedia "${medium_label}" "${medium_dir}") == "n" ]
                then
                    bfe.system.log.error "Backup description [${description_name}] requires backup medium labelled [${medium_label}] which is not mounted."
                else
                    bfe.system.log.info "Backup medium [${medium_label}] mounted."
                    return 1
                fi
            fi
        fi
    fi

    return 0
}

bfe.system.utils.unmountMedium()
{
    local description_name=$1
    local medium_type=$2
    local medium_label=$3
    local medium_dir=$4

    if [ "${medium_type}" = "usbdrive" ]
    then
        if [ $(bfe.system.utils.unmountOfflineMedia "${medium_label}" "${medium_dir}") == "n" ]
        then
            bfe.system.log.error "Backup description [${description_name}], unable to return to unmounted state for backup medium labelled [${medium_label}]."
        else
            bfe.system.log.info "Backup medium [${medium_label}] unmounted."
        fi
    fi
}

bfe.system.utils.run()
{
    # Strip out any confidential information from the command
    local cmd=`${ECHO_CMD} "$@" | ${SED_CMD} -r 's/^RESTIC_PASSWORD=[^ ]* /RESTIC_PASSWORD=**** /g'`
    local cmd=`${ECHO_CMD} "${cmd}" | ${SED_CMD} -r 's/^PASSPHRASE=[^ ]* /PASSPHRASE=**** /g'`
    local cmd=`${ECHO_CMD} "${cmd}" | ${SED_CMD} -r 's/smtp-auth-password=[^ ]* /smtp-auth-password=**** /g'`

    bfe.system.log.cmd "${cmd}"

    if ! `${bfe_system_args_}.dryRun`
    then
        if `${bfe_system_args_}.useLog`
        then
            eval "$@" >> ${bfe_system_log_filename_}.log 2>> ${bfe_system_log_filename_}.err
        else
            eval "$@"
        fi

        if [ $? -ne 0 ]
        then
            bfe.system.log.error "Command [${cmd}] returned [$?]."
        fi
    fi
}

# TODO run_noerror() and run() should be rolled into one as the functionality is so similar
bfe.system.utils.run_noerror()
{
    local cmd=`${ECHO_CMD} "$@" | ${SED_CMD} -r 's/^RESTIC_PASSWORD=[^ ]* /RESTIC_PASSWORD=**** /g'`
    local cmd=`${ECHO_CMD} "${cmd}" | ${SED_CMD} -r 's/^PASSPHRASE=[^ ]* /PASSPHRASE=**** /g'`
    local cmd=`${ECHO_CMD} "${cmd}" | ${SED_CMD} -r 's/smtp-auth-password=[^ ]* /smtp-auth-password=**** /g'`

    bfe.system.log.cmd "${cmd}"

    if ! `${bfe_system_args_}.dryRun`
    then
        if `${bfe_system_args_}.useLog`
        then
            eval "$@" >> ${LOG_FILENAME}.log 2>> ${LOG_FILENAME}.err
        else
            eval "$@"
        fi

        if [ $? -ne 0 ]
        then
            bfe.system.log.info "Command [${cmd}] returned [$?]."
        fi
    fi
}

bfe.system.utils.propertyAccessor()
{
    local properties="$1"
    local operation="$2"
    local parameter1="$3"

    # Find the array id that matches the property being set, using the name of the property function being used.
    local object_name=${properties%_*}
    local name=${object_name}_$(echo "${FUNCNAME[1]}" | sed "s/.*\.\(.*\)$/\1/g")
    eval "id=\${${name}}"

    local arrayPrefixes=( "array" )
    if [ $(bfe.system.utils.starts_with_any_of "${arrayPrefixes[@]}" "${id}") == "y" ]
    then
        # This is an array.
        if [ "${operation}" == "=" ]
        then
            # Set the property with the named array provided
            local parameter1=$(eval "printf '%s\n' \"\$${parameter1}\"")
            local a="declare -ga ${name}Array=${parameter1#*=}"
            eval "${a}"
        elif [ "${operation}" == "+=" ]
        then
            # Add the single value provided
            eval "${name}Array+=('${parameter1}')"
        elif [ "${operation}" == "count" ]
        then
            # Get the number of elements in the array
            local a="\${#${name}Array[@]}"
            eval "printf '%s\n' \"${a}\""
        elif [[ "${operation}" =~ ^\[[0-9]+\] ]]
        then
            # Get the array value at the index n. ie. "[n]"
            local a="\${${name}Array${BASH_REMATCH[0]}}"
            eval "printf '%s\n' \"${a}\""
        else
            # Get the array values, in a form that cal be used in a declare
            # statement for convenience
            local value="$(declare -p ${name}Array)"
            local value="${value#*=}"
            echo ${value}
        fi
    else
        if [ "${operation}" == "=" ]
        then
            # Set the poroperty value
            local a="declare -g ${properties}[${name}]=${parameter1}"
            eval "${a}"
        else
            # Get the property value
            eval "printf '%s\n' \"\${${properties}[${name}]}\""
        fi
    fi
}

bfe.system.utils.getWorkingDirectory()
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

bfe.system.utils.copyBFE()
{
    local source_dir=$1
    local destination_dir=$2

    bfe.system.utils.run "mkdir -p ${destination_dir}/bfe"
    bfe.system.utils.run "cp -f ${source_dir}/bfe.*.sh ${destination_dir}/bfe" # TODO Make this less fragile?
    bfe.system.utils.run "cp -f ${backup_description_filename} ${destination_dir}/bfe"
}

bfe.system.utils.sendEmail()
{
    # Note: To setup mailx to send emails via gmail some system configuration
    # is required to install certificates.
    # See the following link for more details:
    # https://serverfault.com/questions/498588/smtp-gmail-com-from-bash-gives-error-in-certificate-peers-certificate-issuer
    #
    # Disclaimer: I haven't succeeded to get steps 4-7 working.
    #
    # TLDR; Use the following:
    # 1. Choose a sub-directory to store a certificates database.
    # 2. Create a new certificates database: certutil -N -d [directory]
    #    Provide a password
    # 3. This should be all that is required, since the mailx command used
    #    below includes "-s ssl-verify=ignore".  If full verification is required,
    #    continue to step 4.
    # 4. Remove "-s ssl-verify=ignore" from the mailx command below.
    # 5. Download the certificates: openssl s_client </dev/null -showcerts -connect smtp.gmail.com:465
    # 6. Edit this file and store each certificate in its own file.
    # 7. Import each certificate into the database: certutil -A -n "Google Internet Authority" -t "C,," -d [directory] -i [Certificate filename]
    # 8. List the certificates database: certutil -L -d .
    local email_to=$1
    local email_from=`${bfe_system_args_}.emailFrom`
    local subject=$2
    local message=$3
    # local add_ip_address=$4
    local send_email=`${bfe_system_args_}.sendEmail`
    local email_password=`${bfe_system_args_}.emailPassword`
    local certificate_database=`${bfe_system_args_}.certificateDatabase`

    if [ "${send_email}" = true -a -n "${email_from}" ]
    then
        bfe.system.utils.run "${ECHO_CMD} \"${message}\" | ${MAILX_CMD} -v -S smtp-use-starttls -S smtp-auth=login -S smtp=smtp://smtp.gmail.com:587 -S from=${email_from} -S smtp-auth-user=${email_from} -S smtp-auth-password=${email_password} -S ssl-verify=ignore -S nss-config-dir=${certificate_database} -s \"${subject}\" ${email_to}"
    fi
}
