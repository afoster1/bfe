# Class named "backup.restic_agent"

backup.restic_agent=true

# collection of property values
backup.restic_agent_properties=()

# properties IDs
backup.restic_agent_descriptionName=0

# fields
backup.restic_agent_args_= # Command line arguments

backup.restic_agent.init(){
    backup.restic_agent_args_=$1

    backup.restic_agent.descriptionName = $2
}

backup.restic_agent.descriptionName() { backup.system.utils.propertyAccessor backup.restic_agent_properties $1 $2
}

backup.restic_agent.doMount()
{
    ${ECHO_CMD} "doMount"
}
