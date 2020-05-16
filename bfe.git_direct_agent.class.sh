# Class that represents a backup agent with the responsibility to interact with
# git repositories via their url's and backup directly to the destination.  As
# no encryption would occur, this agent would not be suitable to backup
# sensitive data.

bfe.git_direct_agent=true

# collection of property values
bfe.git_direct_agent=()

# properties IDs
bfe.git_direct_agent_descriptionName=0

# fields
bfe.git_direct_agent_args_= # Command line arguments

bfe.git_direct_agent.init(){
    bfe.git_direct_agent_args_=$1
    bfe.git_direct_agent.descriptionName = $2

    bfe.git_direct_agent=true
}

bfe.git_direct_agent.descriptionName() { bfe.system.utils.propertyAccessor bfe.git_direct_agent_properties $1 $2
}

bfe.git_direct_agent.stage()
{
    local description_object_name=`bfe.git_direct_agent.descriptionName`
    local description_name=`${description_object_name}.name`
    local work_dir=`${bfe.git_direct_agent_args_}.workDir`
    local stage_sub_dir=`${bfe.git_direct_agent_args_}.stageSubDir`
    local audit_filelist_filename=`${bfe.git_direct_agent_args_}.auditFilelistFilename`
    local audit_hashes_filename=`${bfe.git_direct_agent_args_}.auditHashesFilename`

    local destination_dir="${work_dir}/${stage_sub_dir}/${description_name}/"
    bfe.system.utils.run "${RM_CMD} -rf ${destination_dir}"
    bfe.system.utils.run "${MKDIR_CMD} -p ${destination_dir}"

    e="declare -a bfe.git_direct_agent_urls=`${description_object_name}.data`"
    eval "$e"
    for url in ${bfe.git_direct_agent_urls[@]}
    do
        bfe.toolbox.git.mirror "${url}" "${destination_dir}"
    done

    bfe.system.utils.copyBFE "${bfe_script_directory_}" "${destination_dir}"
    bfe.toolbox.hashing.generate_audit_hashes_using_find "${destination_dir}" "${audit_filelist_filename}" "${audit_hashes_filename}"
}

bfe.git_direct_agent.backup()
{
    local description_object_name=`bfe.git_direct_agent.descriptionName`
    local description_name=`${description_object_name}.name`
    local backup_medium=`${description_object_name}.medium`
    local backup_medium_label=`${description_object_name}.mediumLabel`
    local work_dir=`${bfe.git_direct_agent_args_}.workDir`
    local backup_sub_dir=`${bfe.git_direct_agent_args_}.backupSubDir`
    local stage_sub_dir=`${bfe.git_direct_agent_args_}.stageSubDir`
    local backup_medium_dir=`${bfe.git_direct_agent_args_}.backupMediumDir`
    local hostname=`${bfe.git_direct_agent_args_}.hostname`

    local source_dir="${work_dir}/${stage_sub_dir}/${description_name}"
    local destination_dir=
    case ${backup_medium} in
        local)
            local destination_dir=${work_dir}/${backup_sub_dir}
            ;;
        usbdrive)
            local destination_dir=${backup_medium_dir}/${backup_medium_label}/${hostname}
            ;;
    esac

    bfe.toolbox.rsync.rsync_transfer "${source_dir}" "" "${destination_dir}"
}

bfe.git_direct_agent.restore()
{
    local description_object_name=`bfe.git_direct_agent.descriptionName`
    local description_name=`${description_object_name}.name`
    local backup_medium=`${description_object_name}.medium`
    local backup_medium_label=`${description_object_name}.mediumLabel`
    local work_dir=`${bfe.git_direct_agent_args_}.workDir`
    local backup_sub_dir=`${bfe.git_direct_agent_args_}.backupSubDir`
    local stage_sub_dir=`${bfe.git_direct_agent_args_}.stageSubDir`
    local restore_sub_dir=`${bfe.git_direct_agent_args_}.restoreSubDir`
    local backup_medium_dir=`${bfe.git_direct_agent_args_}.backupMediumDir`
    local hostname=`${bfe.git_direct_agent_args_}.hostname`

    local source_dir=
    local destination_dir=
    case ${backup_medium} in
        local)
            local source_dir=${work_dir}/${backup_sub_dir}/${description_name}
            local destination_dir=${work_dir}/${restore_sub_dir}/${backup_medium}
            ;;
        usbdrive)
            local source_dir=${backup_medium_dir}/${backup_medium_label}/${hostname}/${description_name}
            local destination_dir=${work_dir}/${restore_sub_dir}/${backup_medium_label}
            ;;
    esac

    bfe.toolbox.rsync.rsync_transfer "${source_dir}" "" "${destination_dir}"
}

bfe.git_direct_agent.verify()
{
    local description_object_name=`bfe.git_direct_agent.descriptionName`
    local description_name=`${description_object_name}.name`
    local backup_medium=`${description_object_name}.medium`
    local backup_medium_label=`${description_object_name}.mediumLabel`
    local work_dir=`${bfe.git_direct_agent_args_}.workDir`
    local restore_sub_dir=`${bfe.git_direct_agent_args_}.restoreSubDir`
    local audit_filelist_filename=`${bfe.git_direct_agent_args_}.auditFilelistFilename`
    local audit_hashes_filename=`${bfe.git_direct_agent_args_}.auditHashesFilename`

    local source_dir=
    case ${backup_medium} in
        local)
            local source_dir=${work_dir}/${restore_sub_dir}/${backup_medium}/${description_name}/
            ;;
        usbdrive)
            local source_dir=${work_dir}/${restore_sub_dir}/${backup_medium_label}/${description_name}/
            ;;
    esac

    bfe.toolbox.hashing.verify_audit_hashes "${source_dir}" "${audit_filelist_filename}" "${audit_hashes_filename}"
}

bfe.git_direct_agent.cleanup()
{
    # Nothing to do
    local nop=
}

bfe.git_direct_agent.status()
{
    # Nothing to do
    local nop=
}
