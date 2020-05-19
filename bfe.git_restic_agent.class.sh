# Class that represents a backup agent with the responsibility to interact with
# git repositories directly via their url's and backup with restic.

bfe.git_restic_agent=true

# collection of property values
bfe.git_restic_agent=()

# properties IDs
bfe.git_restic_agent_descriptionName=0

# fields
bfe.git_restic_agent_args_= # Command line arguments
bfe.git_restic_agent_delegate_= # Composition relationship with restic_agent

bfe.git_restic_agent.init(){
    bfe.git_restic_agent_args_=$1
    bfe.git_restic_agent.descriptionName = $2

    # The git_restic_agent depends on the filesystem_restic_agent, using its functionality
    # for most tasks.  This object instance represents the composition
    # relationship.
    local backup_description_object_instance=`bfe.git_restic_agent.descriptionName`
    bfe.filesystem_restic_agent bfe.git_restic_agent_delegate_ "${bfe.git_restic_agent_args_}" "${backup_description_object_instance}"

    bfe.git_restic_agent=true
}

bfe.git_restic_agent.descriptionName() { bfe.toolbox.utils.propertyAccessor bfe.git_restic_agent_properties $1 $2
}

bfe.git_restic_agent.stage()
{
    local description_object_name=`bfe.git_restic_agent.descriptionName`
    local destination_dir=$(bfe.toolbox.utils.getStageDirectory "${description_object_name}")

    e="declare -a bfe.git_restic_agent_urls=`${description_object_name}.data`"
    eval "$e"
    for url in ${bfe.git_restic_agent_urls[@]}
    do
        bfe.toolbox.git.mirror "${url}" "${destination_dir}"
    done
}

bfe.git_restic_agent.backup()
{
    bfe.git_restic_agent_delegate_.backup
}

bfe.git_restic_agent.restore()
{
    bfe.git_restic_agent_delegate_.restore
}

bfe.git_restic_agent.verify()
{
    local description_object_name=`bfe.git_restic_agent.descriptionName`
    local source_dir=$(bfe.toolbox.utils.getBackupDirectory "${description_object_name}")
    local passphrase=`${bfe.git_restic_agent_args_}.passphrase`

    # Verify the backup data first.
    bfe.toolbox.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} --repo ${source_dir} check --read-data"

    # TODO ANFO Improve the verification by adapting the audit hashes
    # verification functionality to compare the staged repos against the
    # restored repos
}

bfe.git_restic_agent.cleanup()
{
    bfe.git_restic_agent_delegate_.cleanup
}

bfe.git_restic_agent.status()
{
    bfe.git_restic_agent_delegate_.status
}
