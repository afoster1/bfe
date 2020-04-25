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
    local dn=`bfe.handler.descriptionName`
    type=`${dn}.type`
    ${ECHO_CMD} "Processing backup description: `${dn}.name`"

    # Instantiate the specific bfe.handler
    unset agent
    case ${type} in
        filesystem_restic)
            bfe.restic_agent agent ${bfe.handler_args_} ${dn}
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

            # TODO handle all action types mount, unmount, defaul, stage, backup, restore, cleanup, verify, status
            case ${action} in
                mount)
                    agent.doMount
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
