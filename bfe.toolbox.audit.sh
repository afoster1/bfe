# Tools to help operations involving auditing files.

# Fields
bfe_toolbox_audit_args_= # Command line arguments

bfe.toolbox.audit.init()
{
    bfe_toolbox_audit_args_=$1
}

bfe.toolbox.audit.verify_audit_hashes()
{
    local source_dir=$1
    local audit_filelist_filename=$2
    local audit_hashes_filename=$3

    bfe.toolbox.utils.run "pushd ${source_dir}"
    bfe.toolbox.utils.run "rm -rf ${audit_filelist_filename}"

    # Audit the files against the filename hashes
    bfe.toolbox.audit.generate_audit_filelist "${source_dir}" "${FIND_CMD} . -type f" "${audit_filelist_filename}" "${audit_hashes_filename}"
    bfe.toolbox.utils.run "${HASHDEEP_CMD} -v -v -v -r -a -k ${audit_hashes_filename} -f ${audit_filelist_filename}"
    bfe.toolbox.utils.run "rm -rf ${audit_filelist_filename}"

    bfe.toolbox.utils.run "popd"
}

bfe.toolbox.audit.delete_audit_hashes()
{
    local source_dir=$1
    local audit_hashes_filename=$2

    local filename="${source_dir}/${audit_hashes_filename}"

    if [ -e "${filename}" ]
    then
        bfe.toolbox.utils.run "rm -rf ${filename}"
    fi
}

bfe.toolbox.audit.generate_audit_hashes_using_rsync()
{
    local source_dir=$1
    local filters=$2
    local dest_dir=$3
    local audit_filelist_filename=$4
    local audit_hashes_filename=$5

    bfe.toolbox.utils.run "pushd ${source_dir}"
    bfe.toolbox.utils.run "rm -rf ${audit_filelist_filename}"
    bfe.toolbox.utils.run "rm -rf ${audit_hashes_filename}"

    bfe.toolbox.audit.generate_audit_filelist "${source_dir}" "${RSYNC_CMD} -naic --protect-args --out-format=%n ${filters} ${source_dir} ${dest_dir}" "${audit_filelist_filename}" "${audit_hashes_filename}"

    # Generate the audit hashes from the filelist.
    bfe.toolbox.utils.run "${HASHDEEP_CMD} -l -f ${audit_filelist_filename} >${audit_hashes_filename}"
    bfe.toolbox.utils.run "rm -rf ${audit_filelist_filename}"
    bfe.toolbox.utils.run "popd"
}

bfe.toolbox.audit.generate_audit_hashes_using_find()
{
    local source_dir=$1
    local audit_filelist_filename=$2
    local audit_hashes_filename=$3

    bfe.toolbox.utils.run "pushd ${source_dir}"
    bfe.toolbox.utils.run "rm -rf ${audit_filelist_filename}"
    bfe.toolbox.utils.run "rm -rf ${audit_hashes_filename}"

    bfe.toolbox.audit.generate_audit_filelist "${source_dir}" "${FIND_CMD} . -type f" "${audit_filelist_filename}" "${audit_hashes_filename}"

    # Generate the audit hashes from the filelist.
    bfe.toolbox.utils.run "${HASHDEEP_CMD} -l -f ${audit_filelist_filename} >${audit_hashes_filename}"
    bfe.toolbox.utils.run "rm -rf ${audit_filelist_filename}"

    bfe.toolbox.utils.run "popd"
}

bfe.toolbox.audit.generate_audit_filelist()
{
    local source_dir=$1
    local cmd=$2
    local audit_filelist_filename=$3
    local audit_hashes_filename=$4

    local bdf=`${bfe_toolbox_audit_args_}.backupDescriptionFilename`
    local bdf=${bdf##*/}
    local bs=${BASH_SOURCE[0]#./*}

    bfe.toolbox.utils.run "pushd ${source_dir}"

    local filenames=$( ${cmd} )
    IFS=$'\n' read -rd '' -a filenames <<<"${filenames}"

    for ((i=0; i < ${#filenames[@]}; i++))
    do
        local filename=${filenames[$i]#\./}
        local file_basename=$( ${BASENAME_CMD} "${filename}" )

        # Adjust the top level directory such that "a/b/c.txt" becomes "b/c.txt"
        case "${source_dir}" in
            */) # Do not adjust the top level directory when the filename ends with a slash
                ;;
            *) # Adjust the top level directory when the filename does not end in a slash
               local filename=${filename#*/}
               ;;
        esac

        # Include the file in the audit if it is not one of the audit files
        # themselves or begins with a prefixes known to be problematic for
        # hashdeep
        local problematic_audit_prefixes=( "~$" )
        if [ ! $(bfe.toolbox.utils.starts_with_any_of "${problematic_audit_prefixes[@]}" "${file_basename}") == "y" ] &&
           [ ! "${filename}" = "${audit_filelist_filename}" ] &&
           [ ! "${filename}" = "${audit_hashes_filename}" ] &&
           [ ! "${file_basename}" = "${bdf}" ] &&
           [ ! "${file_basename}" = "${bs}" ]
        then
            eval "${ECHO_CMD} \"${filename}\" >>${audit_filelist_filename}"
        fi
    done

    bfe.toolbox.utils.run "popd"
}

