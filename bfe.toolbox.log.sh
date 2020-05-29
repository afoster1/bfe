# Tools to help with logging operations

# fields
bfe_toolbox_log_args_= # Command line arguments
bfe_toolbox_log_filename_= # The filename to be used for the log

bfe.toolbox.log.init()
{
    bfe_toolbox_log_args_=$1
    local backup_name=`${bfe_toolbox_log_args_}.backupName`
    local hostname=`${bfe_toolbox_log_args_}.hostname`
    local log_dir=`bfe.toolbox.utils.getLogDirectory`

    if [ "`${bfe_toolbox_log_args_}.useLog`" = true ]
    then
        bfe.toolbox.utils.run "${MKDIR_CMD} -p ${log_dir}"
        if [ -n "${backup_name}" ]
        then
            bfe_toolbox_log_filename_=${log_dir}`date +%y%m%d_%H%M%S`_${hostname}_${backup_name}
        else
            bfe_toolbox_log_filename_=${log_dir}`date +%y%m%d_%H%M%S`_${hostname}
        fi
    else
        unset bfe_toolbox_log_filename_
    fi

    if [ ${#bfe_toolbox_log_filename_} -gt 0 ]
    then
        ${ECHO_CMD} "Log filename: ${bfe_toolbox_log_filename_}"
    fi
}

bfe.toolbox.log.getLogFilename()
{
    ${ECHO_CMD} "${bfe_toolbox_log_filename_}.log"
}

bfe.toolbox.log.getErrorFilename()
{
    ${ECHO_CMD} "${bfe_toolbox_log_filename_}.err"
}

bfe.toolbox.log.cmd() {
    if [ "`${bfe_toolbox_log_args_}.useLog`" = true ]
    then
        ${ECHO_CMD} "CMD:$@" >> ${bfe_toolbox_log_filename_}.log
    else
        ${ECHO_CMD} "CMD:$@"
    fi
}

bfe.toolbox.log.highlight() {
    if [ "`${bfe_toolbox_log_args_}.useLog`" = true ]
    then
        ${ECHO_CMD} "===>:$@" >> ${bfe_toolbox_log_filename_}.log
        ${ECHO_CMD} "===>:$@" 1>&2 >> ${bfe_toolbox_log_filename_}.err
    else
        ${ECHO_CMD} "===>:$@"
    fi
}

bfe.toolbox.log.info() {
    if [ "`${bfe_toolbox_log_args_}.useLog`" = true ]
    then
        ${ECHO_CMD} "INFO:$@" >> ${bfe_toolbox_log_filename_}.log
    else
        ${ECHO_CMD} "INFO:$@"
    fi
}

bfe.toolbox.log.error() {
    ${ECHO_CMD} "ERROR:$@"
    if [ "`${bfe_toolbox_log_args_}.useLog`" = true ]
    then
        ${ECHO_CMD} "ERROR:$@" >> ${bfe_toolbox_log_filename_}.log
        ${ECHO_CMD} "ERROR:$@" 1>&2 >> ${bfe_toolbox_log_filename_}.err
    fi

    if [ "`${bfe_toolbox_log_args_}.sendEmail`" = true ]
    then
        ${bfe_system_notifier_}.append "ERROR: $@"
        ${bfe_system_notifier_}.notifyError
    fi
    exit 1
}
