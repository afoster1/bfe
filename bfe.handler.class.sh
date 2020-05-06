# Class named "bfe.handler"

# fields
bfe.handler_args_= # Command line arguments
bfe.handler_descriptions_= # Backup descriptions

bfe.handler.init(){
    bfe.handler_args_=$1
    bfe.handler_descriptions_=$2
}

bfe.handler.process()
{
    local description_name=$1
    local descriptions=${bfe.handler_descriptions_}

    ${ECHO_CMD} "Processing backup description: ${description_name}"

    descriptions.getBackupDescription backup_description "${description_name}"
    local type=`backup_description.type`

    # TODO Handle other agents: filesystem_rsync, gitolite_direct
    # Instantiate the specific bfe.handler
    unset agent
    case ${type} in
        filesystem_restic)
            bfe.restic_agent agent ${bfe.handler_args_} backup_description
            ;;

        gitolite)
            bfe.gitolite_agent agent ${bfe.handler_args_} backup_description descriptions
            ;;

        gitolite_direct)
            bfe.gitolite_direct_agent agent ${bfe.handler_args_} backup_description descriptions
            ;;
    esac

    # TODO Ensure media is mounted/dismounted before and after the action if it
    # isn't already

    # If the bfe.handler has been created then process the backup.
    if [ ! -z ${agent+x} ]
    then
        local e="declare -a actions=`${bfe.handler_args_}.actions`"
        eval "$e"
        for action in ${actions[@]}
        do
            ${ECHO_CMD} "-> Action: ${action}"

            case ${action} in
                default)
                    bfe.handler.doStage backup_description agent
                    bfe.handler.doBackup backup_description agent
                    bfe.handler.doRestore backup_description agent
                    bfe.handler.doVerify backup_description agent
                    bfe.handler.doCleanup backup_description agent
                    ;;
                mount)
                    # The "mount" action is the same for all agents
                    local medium_type=`backup_description.medium`
                    local medium_label=`backup_description.mediumLabel`
                    local medium_dir=`${bfe.handler_args_}.backupMediumDir`
                    bfe.system.utils.doMount "${description_name}"  "${medium_type}" "${medium_label}" "${medium_dir}"
                    ;;
                unmount)
                    # The "unmount" action is the same for all agents
                    local medium_type=`backup_description.medium`
                    local medium_label=`backup_description.mediumLabel`
                    local medium_dir=`${bfe.handler_args_}.backupMediumDir`
                    bfe.system.utils.doUnmount "${description_name}"  "${medium_type}" "${medium_label}" "${medium_dir}"
                    ;;
                stage)
                    bfe.handler.doStage backup_description agent
                    ;;
                backup)
                    bfe.handler.doBackup backup_description agent
                    ;;
                restore)
                    bfe.handler.doRestore backup_description agent
                    ;;
                verify)
                    bfe.handler.doVerify backup_description agent
                    ;;
                cleanup)
                    bfe.handler.doCleanup backup_description agent
                    ;;
                status)
                    bfe.handler.doStatus backup_description agent
                    ;;
                *)
                    bfe.system.log.error "Unable to process action '${action}'"
                    ;;
            esac
        done
    else
        bfe.system.log.error "Unable to process backup type '${type}'"
    fi
}

bfe.handler.doStage()
{
    local object_name=$1
    local agent_name=$2
    local description_name=`${object_name}.name`

    bfe.system.log.highlight "Staging [${description_name}] - Started"
    ${agent_name}.stage
    bfe.system.log.highlight "Staging [${description_name}] - Completed"
}

bfe.handler.doBackup()
{
    local object_name=$1
    local agent_name=$2
    local description_name=`${object_name}.name`

    bfe.system.log.highlight "Backup [${description_name}] - Started"
    ${agent_name}.backup
    bfe.system.log.highlight "Backup [${description_name}] - Completed"
}

bfe.handler.doRestore()
{
    local object_name=$1
    local agent_name=$2
    local description_name=`${object_name}.name`

    bfe.system.log.highlight "Restore [${description_name}] - Started"
    ${agent_name}.restore
    bfe.system.log.highlight "Restore [${description_name}] - Completed"
}

bfe.handler.doVerify()
{
    local object_name=$1
    local agent_name=$2
    local description_name=`${object_name}.name`

    bfe.system.log.highlight "Verify [${description_name}] - Started"
    ${agent_name}.verify
    bfe.system.log.highlight "Verify [${description_name}] - Completed"
}

bfe.handler.doCleanup()
{
    local object_name=$1
    local agent_name=$2
    local description_name=`${object_name}.name`

    bfe.system.log.highlight "Cleanup [${description_name}] - Started"
    ${agent_name}.cleanup
    bfe.system.log.highlight "Cleanup [${description_name}] - Completed"
}

bfe.handler.doStatus()
{
    local object_name=$1
    local agent_name=$2
    local description_name=`${object_name}.name`

    bfe.system.log.highlight "Status [${description_name}] - Started"
    ${agent_name}.status
    bfe.system.log.highlight "Status [${description_name}] - Completed"
}
