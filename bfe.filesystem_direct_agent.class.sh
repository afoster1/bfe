# A backup agent with the responsibility of handling the backup of a filesystem
# directly and staged files verified after restore via file hashes.  As no
# encryption would occur, this agent would not be suitable to backup sensitive
# data.

bfe.filesystem_direct_agent=true

# collection of property values
bfe.filesystem_direct_agent=()

# properties IDs
bfe.filesystem_direct_agent_descriptionName=0

# fields
bfe.filesystem_direct_agent_args_= # Command line arguments

bfe.filesystem_direct_agent.init(){
    bfe.filesystem_direct_agent_args_=$1
    bfe.filesystem_direct_agent.descriptionName = $2

    bfe.filesystem_direct_agent=true
}

bfe.filesystem_direct_agent.descriptionName() { bfe.system.utils.propertyAccessor bfe.filesystem_direct_agent_properties $1 $2
}

bfe.filesystem_direct_agent.stage()
{
    local description_object_name=`bfe.filesystem_direct_agent.descriptionName`
    local work_dir=`${bfe.filesystem_direct_agent_args_}.workDir`
    local stage_sub_dir=`${bfe.filesystem_direct_agent_args_}.stageSubDir`
    local destination_dir="${work_dir}/${stage_sub_dir}"

    bfe.toolbox.filesystem.sync_and_audit "${description_object_name}" "${destination_dir}"
}

bfe.filesystem_direct_agent.backup()
{
    local description_object_name=`bfe.filesystem_direct_agent.descriptionName`
    local description_name=`${description_object_name}.name`
    local backup_medium=`${description_object_name}.medium`
    local backup_medium_label=`${description_object_name}.mediumLabel`
    local work_dir=`${bfe.filesystem_direct_agent_args_}.workDir`
    local backup_sub_dir=`${bfe.filesystem_direct_agent_args_}.backupSubDir`
    local stage_sub_dir=`${bfe.filesystem_direct_agent_args_}.stageSubDir`
    local backup_medium_dir=`${bfe.filesystem_direct_agent_args_}.backupMediumDir`
    local hostname=`${bfe.filesystem_direct_agent_args_}.hostname`

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

bfe.filesystem_direct_agent.restore()
{
    local description_object_name=`bfe.filesystem_direct_agent.descriptionName`
    local description_name=`${description_object_name}.name`
    local backup_medium=`${description_object_name}.medium`
    local backup_medium_label=`${description_object_name}.mediumLabel`
    local work_dir=`${bfe.filesystem_direct_agent_args_}.workDir`
    local backup_sub_dir=`${bfe.filesystem_direct_agent_args_}.backupSubDir`
    local stage_sub_dir=`${bfe.filesystem_direct_agent_args_}.stageSubDir`
    local restore_sub_dir=`${bfe.filesystem_direct_agent_args_}.restoreSubDir`
    local backup_medium_dir=`${bfe.filesystem_direct_agent_args_}.backupMediumDir`
    local hostname=`${bfe.filesystem_direct_agent_args_}.hostname`

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

bfe.filesystem_direct_agent.verify()
{
    local description_object_name=`bfe.filesystem_direct_agent.descriptionName`
    local description_name=`${description_object_name}.name`
    local backup_medium=`${description_object_name}.medium`
    local backup_medium_label=`${description_object_name}.mediumLabel`
    local work_dir=`${bfe.filesystem_direct_agent_args_}.workDir`
    local restore_sub_dir=`${bfe.filesystem_direct_agent_args_}.restoreSubDir`
    local audit_filelist_filename=`${bfe.filesystem_direct_agent_args_}.auditFilelistFilename`
    local audit_hashes_filename=`${bfe.filesystem_direct_agent_args_}.auditHashesFilename`

    local source_dir=
    case ${backup_medium} in
        local)
            local source_dir=${work_dir}/${restore_sub_dir}/${backup_medium}/${description_name}/
            ;;
        usbdrive)
            local source_dir=${work_dir}/${restore_sub_dir}/${backup_medium_label}/${description_name}/
            ;;
    esac

    bfe.toolbox.audit.verify_audit_hashes "${source_dir}" "${audit_filelist_filename}" "${audit_hashes_filename}"
}

bfe.filesystem_direct_agent.cleanup()
{
    # Nothing to do
    local nop=
}

bfe.filesystem_direct_agent.status()
{
    # Nothing to do
    local nop=
}

