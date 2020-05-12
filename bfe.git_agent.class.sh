# Class that represents a backup agent with the responsibility to interact with
# git repositories directly via their url's.

bfe.git_agent=true

# collection of property values
bfe.git_agent=()

# properties IDs
bfe.git_agent_descriptionName=0
bfe.git_agent_descriptions=1

# fields
bfe.git_agent_args_= # Command line arguments
bfe.git_agent_delegate_= # Composition relationship with restic_agent

bfe.git_agent.init(){
    bfe.git_agent_args_=$1
    bfe.git_agent.descriptionName = $2
    bfe.git_agent.descriptions = $3

    # The git_agent depends on the restic_agent, using its functionality
    # for most tasks.  This object instance represents the composition
    # relationship.
    local backup_description_object_instance=`bfe.git_agent.descriptionName`
    bfe.restic_agent bfe.git_agent_delegate_ "${bfe.git_agent_args_}" "${backup_description_object_instance}"

    bfe.git_agent=true
}

bfe.git_agent.descriptionName() { bfe.system.utils.propertyAccessor bfe.git_agent_properties $1 $2
}
bfe.git_agent.descriptions() { bfe.system.utils.propertyAccessor bfe.git_agent_properties $1 $2
}

bfe.git_agent.stage()
{
    local description_object_name=`bfe.git_agent.descriptionName`
    local description_name=`${description_object_name}.name`
    local work_dir=`${bfe.git_agent_args_}.workDir`
    local stage_sub_dir=`${bfe.git_agent_args_}.stageSubDir`
    local descriptions=`bfe.git_agent.descriptions`

    local destination_dir="${work_dir}/${stage_sub_dir}/${description_name}"

    e="declare -a bfe.git_agent_urls=`${description_object_name}.data`"
    eval "$e"
    for url in ${bfe.git_agent_urls[@]}
    do
        bfe.toolbox.git.mirror "${url}" "${destination_dir}"
    done
}

bfe.git_agent.backup()
{
    bfe.git_agent_delegate_.backup
}

bfe.git_agent.restore()
{
    bfe.git_agent_delegate_.restore
}

bfe.git_agent.verify()
{
    local object_name=`bfe.git_agent.descriptionName`
    local description_name=`${object_name}.name`
    local backup_medium=`${object_name}.medium`
    local backup_medium_label=`${object_name}.mediumLabel`
    local work_dir=`${bfe.git_agent_args_}.workDir`
    local backup_sub_dir=`${bfe.git_agent_args_}.backupSubDir`
    local backup_medium_dir=`${bfe.git_agent_args_}.backupMediumDir`
    local hostname=`${bfe.git_agent_args_}.hostname`
    local passphrase=`${bfe.git_agent_args_}.passphrase`

    local source_dir=
    case ${backup_medium} in
        local)
            local source_dir=${work_dir}/${backup_sub_dir}/${description_name}
            ;;
        usbdrive)
            local source_dir=${backup_medium_dir}/${backup_medium_label}/${hostname}/${description_name}
            ;;
    esac

    # Verify the backup data first.
    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} --repo ${source_dir} check --read-data"

    # TODO ANFO Improve the verification by adapting the audit hashes
    # verification functionality to compare the staged repos against the
    # restored repos
}

bfe.git_agent.cleanup()
{
    bfe.git_agent_delegate_.cleanup
}

bfe.git_agent.status()
{
    bfe.git_agent_delegate_.status
}
