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
    local description_name=`${description_object_name}.name`
    local backup_medium=`${description_object_name}.medium`
    local backup_medium_label=`${description_object_name}.mediumLabel`
    local work_dir=`${bfe.gitolite_direct_agent_args_}.workDir`
    local backup_sub_dir=`${bfe.gitolite_direct_agent_args_}.backupSubDir`
    local backup_medium_dir=`${bfe.gitolite_direct_agent_args_}.backupMediumDir`
    local hostname=`${bfe.gitolite_direct_agent_args_}.hostname`
    local backup_description_filename=`${bfe.gitolite_direct_agent_args_}.backupDescriptionFilename`
    local orig_dir=$(pwd)

    local destination_dir=
    case ${backup_medium} in
        local)
            local destination_dir=${work_dir}/${backup_sub_dir}/${description_name}
            ;;
        usbdrive)
            local destination_dir=${backup_medium_dir}/${backup_medium_label}/${hostname}/${description_name}
            ;;
    esac

    bfe.toolbox.gitolite.clone "${description_object_name}" "${descriptions}" "${destination_dir}"

    # TODO This functionality is duplicated in the restic_agent.
    bfe.system.utils.run "cd ${orig_dir}"
    bfe.system.utils.run "mkdir -p ${destination_dir}/bfe"
    bfe.system.utils.run "cp -f bfe.*.sh ${destination_dir}/bfe" # TODO Make this less fragile?
    bfe.system.utils.run "cp -f ${backup_description_filename} ${destination_dir}/bfe"
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
