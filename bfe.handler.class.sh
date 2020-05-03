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

    descriptions.getBackupDescription description ${description_name}
    local type=`description.type`

    # TODO Handle other agents: filesystem_rsync, gitolite, gitolite_direct
    # Instantiate the specific bfe.handler
    unset agent
    case ${type} in
        filesystem_restic)
            bfe.restic_agent agent ${bfe.handler_args_} description
            ;;

        gitolite)
            bfe.gitolite_agent agent ${bfe.handler_args_} description
            ;;
    esac

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
                    bfe.handler.doStage description agent
                    bfe.handler.doBackup description agent
                    bfe.handler.doRestore description agent
                    bfe.handler.doVerify description agent
                    bfe.handler.doCleanup description agent
                    ;;
                mount)
                    # The "mount" action is the same for all agents
                    local medium_type=`description.medium`
                    local medium_label=`description.mediumLabel`
                    local medium_dir=`${bfe.handler_args_}.backupMediumDir`
                    bfe.system.utils.doMount "${description_name}"  "${medium_type}" "${medium_label}" "${medium_dir}"
                    ;;
                unmount)
                    # The "unmount" action is the same for all agents
                    local medium_type=`description.medium`
                    local medium_label=`description.mediumLabel`
                    local medium_dir=`${bfe.handler_args_}.backupMediumDir`
                    bfe.system.utils.doUnmount "${description_name}"  "${medium_type}" "${medium_label}" "${medium_dir}"
                    ;;
                stage)
                    bfe.handler.doStage description agent
                    ;;
                backup)
                    bfe.handler.doBackup description agent
                    ;;
                restore)
                    bfe.handler.doRestore description agent
                    ;;
                verify)
                    bfe.handler.doVerify description agent
                    ;;
                cleanup)
                    bfe.handler.doCleanup description agent
                    ;;
                status)
                    bfe.handler.doStatus description agent
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
