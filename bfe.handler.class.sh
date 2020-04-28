# Class named "bfe.handler"

# collection of property values
bfe.handler_properties=()

# properties IDs
bfe.handler_descriptionName=0

# fields
bfe.handler_args_= # Command line arguments

bfe.handler.init(){
    bfe.handler_args_=$1

    bfe.handler.descriptionName = $2
}

bfe.handler.descriptionName() { bfe.system.utils.propertyAccessor bfe.handler_properties $1 $2
}

bfe.handler.process()
{
    local object_name=`bfe.handler.descriptionName`
    local description_name=`${object_name}.name`
    local type=`${object_name}.type`
    ${ECHO_CMD} "Processing backup description: ${description_name}"

    # Instantiate the specific bfe.handler
    unset agent
    case ${type} in
        filesystem_restic)
            bfe.restic_agent agent ${bfe.handler_args_} ${object_name}
            ;;

        git_mirror)
            # TODO
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

            # TODO handle all action types default, stage, backup, restore, cleanup, verify, status
            case ${action} in
                mount)
                    # The "mount" action is the same for all agents
                    local medium_type=`${object_name}.medium`
                    local medium_label=`${object_name}.mediumLabel`
                    local medium_dir=`${bfe.handler_args_}.backupMediumDir`
                    bfe.system.utils.doMount "${description_name}"  "${medium_type}" "${medium_label}" "${medium_dir}"
                    ;;
                unmount)
                    # The "unmount" action is the same for all agents
                    local medium_type=`${object_name}.medium`
                    local medium_label=`${object_name}.mediumLabel`
                    local medium_dir=`${bfe.handler_args_}.backupMediumDir`
                    bfe.system.utils.doUnmount "${description_name}"  "${medium_type}" "${medium_label}" "${medium_dir}"
                    ;;
                stage)
                    bfe.handler.doStage "${object_name}" agent
                    ;;
                backup)
                    bfe.handler.doBackup "${object_name}" agent
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

    bfe.system.log.info "Staging [${description_name}]"
    ${agent_name}.stage
    bfe.system.log.info "Staging [${description_name}] - OK"
}

 bfe.handler.doBackup()
{
    local object_name=$1
    local agent_name=$2
    local description_name=`${object_name}.name`

    bfe.system.log.info "Backup [${description_name}]"
    ${agent_name}.backup
    bfe.system.log.info "Backup [${description_name}] - OK"
}
