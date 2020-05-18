# Class named "bfe.gitolite_direct_agent"

bfe.gitolite_direct_agent=true

# collection of property values
bfe.gitolite_direct_agent_properties=()

# properties IDs
bfe.gitolite_direct_agent_descriptionName=0
bfe.gitolite_direct_agent_descriptions=1

# fields
bfe.gitolite_direct_agent_args_= # Command line arguments

bfe.gitolite_direct_agent.init(){
    bfe.gitolite_direct_agent_args_=$1
    bfe.gitolite_direct_agent.descriptionName = $2
    bfe.gitolite_direct_agent.descriptions = $3
    bfe.gitolite_direct_agent=true
}

bfe.gitolite_direct_agent.descriptionName() { bfe.system.utils.propertyAccessor bfe.gitolite_direct_agent_properties $1 $2
}
bfe.gitolite_direct_agent.descriptions() { bfe.system.utils.propertyAccessor bfe.gitolite_direct_agent_properties $1 $2
}

bfe.gitolite_direct_agent.stage()
{
    # Nothing to do
    local nop=
}

bfe.gitolite_direct_agent.backup()
{
    local description_object_name=`bfe.gitolite_direct_agent.descriptionName`
    local descriptions=`bfe.gitolite_direct_agent.descriptions`
    local destination_dir=$(bfe.toolbox.utils.getBackupDirectory "${description_object_name}")

    bfe.toolbox.gitolite.clone "${description_object_name}" "${descriptions}" "${destination_dir}"
    bfe.system.utils.copyBFE "${bfe_script_directory_}" "${destination_dir}"
}

bfe.gitolite_direct_agent.restore()
{
    # Nothing to do
    local nop=
}

bfe.gitolite_direct_agent.verify()
{
    # Nothing to do
    local nop=
}

bfe.gitolite_direct_agent.cleanup()
{
    # Nothing to do
    local nop=
}

bfe.gitolite_direct_agent.status()
{
    # Nothing to do
    local nop=

    # TODO ANFO Perhaps this should list the last 10 commits in each repository
    # in a compact format.
}
