# Class that represents a backup agent with the responsibility to interact with
# git repositories directly via their url's and backup with restic.

bfe.git_restic_agent=true

# collection of property values
bfe.git_restic_agent=()

# properties IDs
bfe.git_restic_agent_descriptionName=0
bfe.git_restic_agent_descriptions=1

# fields
bfe.git_restic_agent_args_= # Command line arguments
bfe.git_restic_agent_delegate_= # Composition relationship with restic_agent

bfe.git_restic_agent.init(){
    bfe.git_restic_agent_args_=$1
    bfe.git_restic_agent.descriptionName = $2
    bfe.git_restic_agent.descriptions = $3

    # The git_restic_agent depends on the filesystem_restic_agent, using its functionality
    # for most tasks.  This object instance represents the composition
    # relationship.
    local backup_description_object_instance=`bfe.git_restic_agent.descriptionName`
    bfe.filesystem_restic_agent bfe.git_restic_agent_delegate_ "${bfe.git_restic_agent_args_}" "${backup_description_object_instance}"

    bfe.git_restic_agent=true
}

bfe.git_restic_agent.descriptionName() { bfe.system.utils.propertyAccessor bfe.git_restic_agent_properties $1 $2
}
bfe.git_restic_agent.descriptions() { bfe.system.utils.propertyAccessor bfe.git_restic_agent_properties $1 $2
}

bfe.git_restic_agent.stage()
{
    local description_object_name=`bfe.git_restic_agent.descriptionName`
    local description_name=`${description_object_name}.name`
    local work_dir=`${bfe.git_restic_agent_args_}.workDir`
    local stage_sub_dir=`${bfe.git_restic_agent_args_}.stageSubDir`
    local descriptions=`bfe.git_restic_agent.descriptions`

    local destination_dir="${work_dir}/${stage_sub_dir}/${description_name}"

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
    local object_name=`bfe.git_restic_agent.descriptionName`
    local description_name=`${object_name}.name`
    local backup_medium=`${object_name}.medium`
    local backup_medium_label=`${object_name}.mediumLabel`
    local work_dir=`${bfe.git_restic_agent_args_}.workDir`
    local backup_sub_dir=`${bfe.git_restic_agent_args_}.backupSubDir`
    local backup_medium_dir=`${bfe.git_restic_agent_args_}.backupMediumDir`
    local hostname=`${bfe.git_restic_agent_args_}.hostname`
    local passphrase=`${bfe.git_restic_agent_args_}.passphrase`

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

bfe.git_restic_agent.cleanup()
{
    bfe.git_restic_agent_delegate_.cleanup
}

bfe.git_restic_agent.status()
{
    bfe.git_restic_agent_delegate_.status
}
