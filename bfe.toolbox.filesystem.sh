# Tools to help operations involving a filesystem.

# Fields
bfe_toolbox_filesystem_args_= # Command line arguments

bfe.toolbox.filesystem.init()
{
    bfe_toolbox_filesystem_args_=$1
}

bfe.toolbox.filesystem.sync_and_audit()
{
    local description_instance_name=$1
    local destination_dir=$2
    local description_name=`${description_instance_name}.name`
    local audit_filelist_filename=`${bfe_toolbox_filesystem_args_}.auditFilelistFilename`
    local audit_hashes_filename=`${bfe_toolbox_filesystem_args_}.auditHashesFilename`

    bfe.system.utils.run "${RM_CMD} -rf ${destination_dir}/${description_name}"
    bfe.system.utils.run "${MKDIR_CMD} -p ${destination_dir}/${description_name}"

    local e="declare -a data_array=`${description_instance_name}.data`"
    eval "$e"
    local filters=()
    local source_directory=
    for data in ${data_array[@]}
    do
        local action=$(${ECHO_CMD} "${data}" | ${CUT_CMD} -c 1)
        local value=$(${ECHO_CMD} "${data}" | ${CUT_CMD} -c 2-)

        if [ "${action}" = "+" ]
        then
            local filters="${filters} --include=${value}"
        else
            if [ "${action}" = "-" ]
            then
                local filters="${filters} --exclude=${value}"
            else
                if [ -n "${source_directory}" ]
                then
                    bfe.toolbox.audit.generate_audit_hashes_using_rsync "${source_directory}" "${filters}" "${destination_dir}" "${audit_filelist_filename}" "${audit_hashes_filename}"
                    bfe.toolbox.rsync.transfer "${source_directory}" "${filters}" "${destination_dir}/${description_name}"
                    local sub_dir=${source_directory%*/} # Remove trailing slash
                    local sub_dir=${source_directory##*/} # Remove upto last slash
                    bfe.toolbox.audit.verify_audit_hashes "${destination_dir}/${description_name}/${sub_dir}/" "${audit_filelist_filename}" "${audit_hashes_filename}"
                    bfe.toolbox.audit.delete_audit_hashes "${destination_dir}/${description_name}/${sub_dir}/" "${audit_hashes_filename}"
                fi
                local source_directory=${data}

                # Reset
                local filters=
            fi
        fi
    done
    if [ -n "${source_directory}" ]
    then
        bfe.toolbox.audit.generate_audit_hashes_using_rsync "${source_directory}" "${filters}" "${destination_dir}" "${audit_filelist_filename}" "${audit_hashes_filename}"
        bfe.toolbox.rsync.transfer "${source_directory}" "${filters}" "${destination_dir}/${description_name}"
        local sub_dir=${source_directory%*/} # Remove trailing slash
        local sub_dir=${source_directory##*/} # Remove upto last slash
        bfe.toolbox.audit.verify_audit_hashes "${destination_dir}/${description_name}/${sub_dir}/" "${audit_filelist_filename}" "${audit_hashes_filename}"
        bfe.toolbox.audit.delete_audit_hashes "${destination_dir}/${description_name}/${sub_dir}/" "${audit_hashes_filename}"
    fi
    bfe.system.utils.copyBFE "${bfe_script_directory_}" "${destination_dir}"

    # Generate an audit hash for each file to be included in the audit.
    bfe.toolbox.audit.generate_audit_hashes_using_find "${destination_dir}/${description_name}/" "${audit_filelist_filename}" "${audit_hashes_filename}"
}
