# Class with responsibility of handling backup of git repositories from a gitolite server using restic.

bfe.gitolite_restic_agent=true

# collection of property values
bfe.gitolite_restic_agent=()

# properties IDs
bfe.gitolite_restic_agent_descriptionName=0
bfe.gitolite_restic_agent_descriptions=1

# fields
bfe.gitolite_restic_agent_args_= # Command line arguments
bfe.gitolite_restic_agent_delegate_= # Composition relationship with restic_agent

bfe.gitolite_restic_agent.init(){
    bfe.gitolite_restic_agent_args_=$1
    bfe.gitolite_restic_agent.descriptionName = $2
    bfe.gitolite_restic_agent.descriptions = $3

    # The gitolite_restic_agent depends on the filesystem_restic_agent, using its functionality
    # for most tasks.  This object instance represents the composition
    # relationship.
    local backup_description_object_instance=`bfe.gitolite_restic_agent.descriptionName`
    bfe.filesystem_restic_agent bfe.gitolite_restic_agent_delegate_ "${bfe.gitolite_restic_agent_args_}" "${backup_description_object_instance}"

    bfe.gitolite_restic_agent=true
}

bfe.gitolite_restic_agent.descriptionName() { bfe.toolbox.utils.propertyAccessor bfe.gitolite_restic_agent_properties $1 $2
}
bfe.gitolite_restic_agent.descriptions() { bfe.toolbox.utils.propertyAccessor bfe.gitolite_restic_agent_properties $1 $2
}

bfe.gitolite_restic_agent.stage()
{
    local description_object_name=`bfe.gitolite_restic_agent.descriptionName`
    local destination_dir=$(bfe.toolbox.utils.getStageDirectory "${description_object_name}")
    local descriptions=`bfe.gitolite_restic_agent.descriptions`

    bfe.toolbox.gitolite.clone "${description_object_name}" "${descriptions}" "${destination_dir}"
}

bfe.gitolite_restic_agent.backup()
{
    bfe.gitolite_restic_agent_delegate_.backup
}

bfe.gitolite_restic_agent.restore()
{
    bfe.gitolite_restic_agent_delegate_.restore
}

bfe.gitolite_restic_agent.verify()
{
    local description_object_name=`bfe.gitolite_restic_agent.descriptionName`
    local source_dir=$(bfe.toolbox.utils.getBackupDirectory "${description_object_name}")
    local passphrase=`${bfe.gitolite_restic_agent_args_}.passphrase`

    # Verify the backup data first.
    bfe.toolbox.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} --repo ${source_dir} check --read-data"

    # TODO ANFO Improve the verification by adapting the audit hashes
    # verification functionality to compare the staged repos against the
    # restored repos
}

bfe.gitolite_restic_agent.cleanup()
{
    bfe.gitolite_restic_agent_delegate_.cleanup
}

bfe.gitolite_restic_agent.status()
{
    bfe.gitolite_restic_agent_delegate_.status
}
