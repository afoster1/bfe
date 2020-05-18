# Tools to help with general operations

# fields
bfe_toolbox_utils_args_= # Command line arguments

bfe.toolbox.utils.init(){
    bfe_toolbox_utils_args_=$1
}

bfe.toolbox.utils.getParentDirectoryOf()
{
    local dir=$1
    local parent_dir=$(${DIRNAME_CMD} "${dir}")
    ${ECHO_CMD} "${parent_dir}"
}

bfe.toolbox.utils.getStageDirectory()
{
    local description_object_name=$1
    local description_name=`${description_object_name}.name`
    local work_dir=`${bfe_toolbox_utils_args_}.workDir`
    local stage_sub_dir=`${bfe_toolbox_utils_args_}.stageSubDir`

    local dir="${work_dir}/${stage_sub_dir}/${description_name}/"
    ${ECHO_CMD} "${dir}"
}

bfe.toolbox.utils.getBackupDirectory()
{
    local description_object_name=$1
    local description_name=`${description_object_name}.name`
    local backup_medium=`${description_object_name}.medium`
    local backup_medium_label=`${description_object_name}.mediumLabel`
    local work_dir=`${bfe_toolbox_utils_args_}.workDir`
    local backup_sub_dir=`${bfe_toolbox_utils_args_}.backupSubDir`
    local backup_medium_dir=`${bfe_toolbox_utils_args_}.backupMediumDir`
    local hostname=`${bfe_toolbox_utils_args_}.hostname`

    local dir=
    case ${backup_medium} in
        local)
            local dir=${work_dir}/${backup_sub_dir}/${description_name}
            ;;
        usbdrive)
            local dir=${backup_medium_dir}/${backup_medium_label}/${hostname}/${description_name}
            ;;
    esac
    ${ECHO_CMD} "${dir}"
}

bfe.toolbox.utils.getRestoreDirectory()
{
    local description_object_name=$1
    local description_name=`${description_object_name}.name`
    local backup_medium=`${description_object_name}.medium`
    local backup_medium_label=`${description_object_name}.mediumLabel`
    local work_dir=`${bfe_toolbox_utils_args_}.workDir`
    local restore_sub_dir=`${bfe_toolbox_utils_args_}.restoreSubDir`

    local dir=
    case ${backup_medium} in
        local)
            local dir=${work_dir}/${restore_sub_dir}/${backup_medium}/${description_name}/
            ;;
        usbdrive)
            local dir=${work_dir}/${restore_sub_dir}/${backup_medium_label}/${description_name}/
            ;;
    esac
    ${ECHO_CMD} "${dir}"
}
