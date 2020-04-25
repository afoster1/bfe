# Class named "bfe.restic_agent"

bfe.restic_agent=true

# collection of property values
bfe.restic_agent_properties=()

# properties IDs
bfe.restic_agent_descriptionName=0

# fields
bfe.restic_agent_args_= # Command line arguments

bfe.restic_agent.init(){
    bfe.restic_agent_args_=$1

    bfe.restic_agent.descriptionName = $2
}

bfe.restic_agent.descriptionName() { bfe.system.utils.propertyAccessor bfe.restic_agent_properties $1 $2
}

bfe.restic_agent.doMount()
{
    local object_name=`bfe.restic_agent.descriptionName`

    local description_name=`${object_name}.name`
    local medium_type=`${object_name}.medium`
    local medium_label=`${object_name}.mediumLabel`
    local medium_dir=`${bfe.restic_agent_args_}.backupMediumDir`
    bfe.system.utils.doMount "${description_name}"  "${medium_type}" "${medium_label}" "${medium_dir}"
}
