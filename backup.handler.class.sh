# Class named "backup.handler"

# collection of property values
backup.handler_properties=()

# properties IDs
backup.handler_descriptionName=0

# fields
backup.handler_args_= # Command line arguments

backup.handler.init(){
    backup.handler_args_=$1

    backup.handler.descriptionName = $2
}

backup.handler.descriptionName() { backup.system.utils.propertyAccessor backup.handler_properties $1 $2
}

backup.handler.process()
{
    local dn=`backup.handler.descriptionName`
    type=`${dn}.type`
    ${ECHO_CMD} "Processing backup description: `${dn}.name`"

    # Instantiate the specific backup handler
    unset agent
    case ${type} in
        filesystem_restic)
            backup.restic_agent agent ${backup.handler_args_} ${dn}
            ;;

        git_mirror)
            # TODO
            ;;
    esac

    # If the backup handler has been created then process the backup.
    if [ ! -z ${agent+x} ]
    then
        local e="declare -a actions=`${backup.handler_args_}.actions`"
        eval "$e"
        for action in ${actions[@]}
        do
            ${ECHO_CMD} "-> Action: ${action}"

            # TODO handle all action types mount, unmount, defaul, stage, backup, restore, cleanup, verify, status
            case ${action} in
                mount)
                    agent.doMount
                    ;;
                *)
                    backup.system.log.error "Unable to process action '${action}'"
                    ;;
            esac
        done
    else
        backup.system.log.error "Unable to process backup type '${type}'"
    fi
}
