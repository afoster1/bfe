# Class with responsibility of handling backup of a filesystem using restic.

bfe.filesystem_restic_agent=true

# collection of property values
bfe.filesystem_restic_agent_properties=()

# properties IDs
bfe.filesystem_restic_agent_descriptionName=0

# fields
bfe.filesystem_restic_agent_args_= # Command line arguments

bfe.filesystem_restic_agent.init(){
    bfe.filesystem_restic_agent_args_=$1

    bfe.filesystem_restic_agent.descriptionName = $2
    bfe.filesystem_restic_agent=true
}

bfe.filesystem_restic_agent.descriptionName() { bfe.system.utils.propertyAccessor bfe.filesystem_restic_agent_properties $1 $2
}

bfe.filesystem_restic_agent.stage()
{
    local object_name=`bfe.filesystem_restic_agent.descriptionName`
    local work_dir=`${bfe.filesystem_restic_agent_args_}.workDir`
    local stage_sub_dir=`${bfe.filesystem_restic_agent_args_}.stageSubDir`
    local destination_dir="${work_dir}/${stage_sub_dir}"

    bfe.toolbox.filesystem.sync_and_audit "${object_name}" "${destination_dir}"
}

bfe.filesystem_restic_agent.backup()
{
    local object_name=`bfe.filesystem_restic_agent.descriptionName`
    local description_name=`${object_name}.name`
    local backup_medium=`${object_name}.medium`
    local backup_medium_label=`${object_name}.mediumLabel`
    local work_dir=`${bfe.filesystem_restic_agent_args_}.workDir`
    local stage_sub_dir=`${bfe.filesystem_restic_agent_args_}.stageSubDir`
    local backup_sub_dir=`${bfe.filesystem_restic_agent_args_}.backupSubDir`
    local backup_medium_dir=`${bfe.filesystem_restic_agent_args_}.backupMediumDir`
    local hostname=`${bfe.filesystem_restic_agent_args_}.hostname`
    local passphrase=`${bfe.filesystem_restic_agent_args_}.passphrase`

    local orig_dir=$(pwd)
    local source_dir=${work_dir}/${stage_sub_dir}/${description_name}
    case "${backup_medium}" in
        local)
            local destination_dir="${work_dir}/${backup_sub_dir}/${hostname}/${description_name}"
            ;;
        usbdrive)
            local destination_dir="${backup_medium_dir}/${backup_medium_label}/${hostname}/${description_name}"
            ;;
    esac

    bfe.toolbox.restic.backup "${source_dir}" "${destination_dir}" "${passphrase}"
}

bfe.filesystem_restic_agent.restore()
{
    local object_name=`bfe.filesystem_restic_agent.descriptionName`
    local description_name=`${object_name}.name`
    local backup_medium=`${object_name}.medium`
    local backup_medium_label=`${object_name}.mediumLabel`
    local work_dir=`${bfe.filesystem_restic_agent_args_}.workDir`
    local backup_sub_dir=`${bfe.filesystem_restic_agent_args_}.backupSubDir`
    local restore_sub_dir=`${bfe.filesystem_restic_agent_args_}.restoreSubDir`
    local backup_medium_dir=`${bfe.filesystem_restic_agent_args_}.backupMediumDir`
    local hostname=`${bfe.filesystem_restic_agent_args_}.hostname`
    local passphrase=`${bfe.filesystem_restic_agent_args_}.passphrase`

    local source_dir=
    local destination_dir=
    case ${backup_medium} in
        local)
            local source_dir=${work_dir}/${backup_sub_dir}/${description_name}
            local destination_dir=${work_dir}/${restore_sub_dir}/${backup_medium}/${description_name}
            ;;
        usbdrive)
            local source_dir=${backup_medium_dir}/${backup_medium_label}/${hostname}/${description_name}
            local destination_dir=${work_dir}/${restore_sub_dir}/${backup_medium_label}/${description_name}
            ;;
    esac

    bfe.toolbox.restic.restore "${source_dir}" "${destination_dir}" "${passphrase}"
}

bfe.filesystem_restic_agent.verify()
{
    local object_name=`bfe.filesystem_restic_agent.descriptionName`
    local description_name=`${object_name}.name`
    local backup_medium=`${object_name}.medium`
    local backup_medium_label=`${object_name}.mediumLabel`
    local work_dir=`${bfe.filesystem_restic_agent_args_}.workDir`
    local backup_sub_dir=`${bfe.filesystem_restic_agent_args_}.backupSubDir`
    local restore_sub_dir=`${bfe.filesystem_restic_agent_args_}.restoreSubDir`
    local backup_medium_dir=`${bfe.filesystem_restic_agent_args_}.backupMediumDir`
    local hostname=`${bfe.filesystem_restic_agent_args_}.hostname`
    local passphrase=`${bfe.filesystem_restic_agent_args_}.passphrase`
    local audit_filelist_filename=`${bfe.filesystem_restic_agent_args_}.auditFilelistFilename`
    local audit_hashes_filename=`${bfe.filesystem_restic_agent_args_}.auditHashesFilename`

    local source_dir=
    local restore_dir=
    case ${backup_medium} in
        local)
            local source_dir=${work_dir}/${backup_sub_dir}/${description_name}
            local restore_dir=${work_dir}/${restore_sub_dir}/${backup_medium}/${description_name}
            ;;
        usbdrive)
            local source_dir=${backup_medium_dir}/${backup_medium_label}/${hostname}/${description_name}
            local restore_dir=${work_dir}/${restore_sub_dir}/${backup_medium_label}/${description_name}
            ;;
    esac

    bfe.toolbox.restic.verify "${source_dir}" "${restore_dir}" "${passphrase}"
}

bfe.filesystem_restic_agent.cleanup()
{
    local object_name=`bfe.filesystem_restic_agent.descriptionName`
    local description_name=`${object_name}.name`
    local backup_medium=`${object_name}.medium`
    local backup_medium_label=`${object_name}.mediumLabel`
    local keep_full=`${object_name}.keepFull`
    local work_dir=`${bfe.filesystem_restic_agent_args_}.workDir`
    local backup_sub_dir=`${bfe.filesystem_restic_agent_args_}.backupSubDir`
    local backup_medium_dir=`${bfe.filesystem_restic_agent_args_}.backupMediumDir`
    local hostname=`${bfe.filesystem_restic_agent_args_}.hostname`
    local passphrase=`${bfe.filesystem_restic_agent_args_}.passphrase`

    local source_dir=
    case ${backup_medium} in
        local)
            local source_dir=${work_dir}/${backup_sub_dir}/${description_name}/
            ;;
        usbdrive)
            local source_dir=${backup_medium_dir}/${backup_medium_label}/${hostname}/${description_name}/
            ;;
    esac

    bfe.toolbox.restic.cleanup "${source_dir}" "${passphrase}" "${keep_full}"
}

bfe.filesystem_restic_agent.status()
{
    local object_name=`bfe.filesystem_restic_agent.descriptionName`
    local description_name=`${object_name}.name`
    local backup_medium=`${object_name}.medium`
    local backup_medium_label=`${object_name}.mediumLabel`
    local work_dir=`${bfe.filesystem_restic_agent_args_}.workDir`
    local backup_sub_dir=`${bfe.filesystem_restic_agent_args_}.backupSubDir`
    local backup_medium_dir=`${bfe.filesystem_restic_agent_args_}.backupMediumDir`
    local hostname=`${bfe.filesystem_restic_agent_args_}.hostname`
    local passphrase=`${bfe.filesystem_restic_agent_args_}.passphrase`

    local source_dir=
    case ${backup_medium} in
        local)
            local source_dir=${work_dir}/${backup_sub_dir}/${description_name}/
            ;;
        usbdrive)
            local source_dir=${backup_medium_dir}/${backup_medium_label}/${hostname}/${description_name}/
            ;;
    esac

    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} snapshots --repo ${source_dir}"
}
