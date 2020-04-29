# Class named "bfe.restic_agent"

bfe.restic_agent=true

# collection of property values
bfe.restic_agent_properties=()

# properties IDs
bfe.restic_agent_descriptionName=0

# fields
bfe.restic_agent_args_= # Command line arguments

bfe.restic_agent.init(){
    bfe.restic_agent_args_=$1

    bfe.restic_agent.descriptionName = $2
    bfe.restic_agent=true
}

bfe.restic_agent.descriptionName() { bfe.system.utils.propertyAccessor bfe.restic_agent_properties $1 $2
}

bfe.restic_agent.stage()
{
    local object_name=`bfe.restic_agent.descriptionName`
    local description_name=`${object_name}.name`
    local work_dir=`${bfe.restic_agent_args_}.workDir`
    local stage_sub_dir=`${bfe.restic_agent_args_}.stageSubDir`
    local audit_filelist_filename=`${bfe.restic_agent_args_}.auditFilelistFilename`
    local audit_hashes_filename=`${bfe.restic_agent_args_}.auditHashesFilename`

    local destination="${work_dir}/${stage_sub_dir}/${description_name}"
    bfe.system.utils.run "${RM_CMD} -rf ${destination}"
    bfe.system.utils.run "${MKDIR_CMD} -p ${destination}"

    local e="declare -a data_array=`${object_name}.data`"
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
                    bfe.restic_agent.generate_audit_hashes_using_rsync "${source_directory}" "${filters}" "${work_dir}/${stage_sub_dir}" "${audit_filelist_filename}" "${audit_hashes_filename}"
                    bfe.restic_agent.rsync_transfer "${source_directory}" "${filters}" "${work_dir}/${stage_sub_dir}/${description_name}"
                    local sub_dir=${source_directory%*/} # Remove trailing slash
                    local sub_dir=${source_directory##*/} # Remove upto last slash
                    bfe.restic_agent.verify_audit_hashes "${destination}/${sub_dir}/" "${audit_filelist_filename}" "${audit_hashes_filename}"
                    bfe.restic_agent.delete_audit_hashes "${destination}/${sub_dir}/" "${audit_hashes_filename}"
                fi
                local source_directory=${data}

                # Reset
                local filters=
            fi
        fi
    done
    if [ -n "${source_directory}" ]
    then
        bfe.restic_agent.generate_audit_hashes_using_rsync "${source_directory}" "${filters}" "${work_dir}/${stage_sub_dir}" "${audit_filelist_filename}" "${audit_hashes_filename}"
        bfe.restic_agent.rsync_transfer "${source_directory}" "${filters}" "${work_dir}/${stage_sub_dir}/${description_name}"
        local sub_dir=${source_directory%*/} # Remove trailing slash
        local sub_dir=${source_directory##*/} # Remove upto last slash
        bfe.restic_agent.verify_audit_hashes "${destination}/${sub_dir}/" "${audit_filelist_filename}" "${audit_hashes_filename}"
        bfe.restic_agent.delete_audit_hashes "${destination}/${sub_dir}/" "${audit_hashes_filename}"
    fi

    # Generate an audit hash for each file to be included in the audit.
    bfe.restic_agent.generate_audit_hashes_using_find "${destination}/" "${audit_filelist_filename}" "${audit_hashes_filename}"
}

bfe.restic_agent.backup()
{
    local object_name=`bfe.restic_agent.descriptionName`
    local description_name=`${object_name}.name`
    local backup_medium=`${object_name}.medium`
    local backup_medium_label=`${object_name}.mediumLabel`
    local work_dir=`${bfe.restic_agent_args_}.workDir`
    local stage_sub_dir=`${bfe.restic_agent_args_}.stageSubDir`
    local backup_sub_dir=`${bfe.restic_agent_args_}.backupSubDir`
    local backup_medium_dir=`${bfe.restic_agent_args_}.backupMediumDir`
    local hostname=`${bfe.restic_agent_args_}.hostname`
    local passphrase=`${bfe.restic_agent_args_}.passphrase`
    local backup_description_filename=`${bfe.restic_agent_args_}.backupDescriptionFilename`

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

    bfe.system.utils.run "${MKDIR_CMD} -p ${destination_dir}"

    if [ $(bfe.restic_agent.is_restic_repo_initialised "${destination_dir}" "${passphrase}") == "n" ]
    then
        bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} init --repo ${destination_dir}"
    fi

    bfe.system.utils.run "cd ${source_dir}"
    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} backup --repo ${destination_dir} backup . --verbose"

    bfe.system.utils.run "cd ${orig_dir}"
    bfe.system.utils.run "cp -f bfe.*.sh ${destination_dir}" # TODO Make this less fragile?
    bfe.system.utils.run "cp -f ${backup_description_filename} ${destination_dir}"
}

bfe.restic_agent.restore()
{
    local object_name=`bfe.restic_agent.descriptionName`
    local description_name=`${object_name}.name`
    local backup_medium=`${object_name}.medium`
    local backup_medium_label=`${object_name}.mediumLabel`
    local work_dir=`${bfe.restic_agent_args_}.workDir`
    local backup_sub_dir=`${bfe.restic_agent_args_}.backupSubDir`
    local restore_sub_dir=`${bfe.restic_agent_args_}.restoreSubDir`
    local backup_medium_dir=`${bfe.restic_agent_args_}.backupMediumDir`
    local hostname=`${bfe.restic_agent_args_}.hostname`
    local passphrase=`${bfe.restic_agent_args_}.passphrase`

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

    bfe.system.utils.run "${MKDIR_CMD} -p ${destination_dir}"
    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} restore latest --repo ${source_dir} --target ${destination_dir}/"
}

bfe.restic_agent.cleanup()
{
    local object_name=`bfe.restic_agent.descriptionName`
    local description_name=`${object_name}.name`
    local backup_medium=`${object_name}.medium`
    local backup_medium_label=`${object_name}.mediumLabel`
    local keep_full=`${object_name}.keepFull`
    local work_dir=`${bfe.restic_agent_args_}.workDir`
    local backup_sub_dir=`${bfe.restic_agent_args_}.backupSubDir`
    local backup_medium_dir=`${bfe.restic_agent_args_}.backupMediumDir`
    local hostname=`${bfe.restic_agent_args_}.hostname`
    local passphrase=`${bfe.restic_agent_args_}.passphrase`

    local source_dir=
    case ${backup_medium} in
        local)
            local source_dir=${work_dir}/${backup_sub_dir}/${description_name}/
            ;;
        usbdrive)
            local source_dir=${backup_medium_dir}/${backup_medium_label}/${hostname}/${description_name}/
            ;;
    esac

    # Run the cleanup
    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} --repo ${source_dir} snapshots"
    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} --repo ${source_dir} forget --keep-last ${keep_full} --prune"
    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} --repo ${source_dir} snapshots"
    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} --repo ${source_dir} check"
}

bfe.restic_agent.status()
{
    local object_name=`bfe.restic_agent.descriptionName`
    local description_name=`${object_name}.name`
    local backup_medium=`${object_name}.medium`
    local backup_medium_label=`${object_name}.mediumLabel`
    local work_dir=`${bfe.restic_agent_args_}.workDir`
    local backup_sub_dir=`${bfe.restic_agent_args_}.backupSubDir`
    local backup_medium_dir=`${bfe.restic_agent_args_}.backupMediumDir`
    local hostname=`${bfe.restic_agent_args_}.hostname`
    local passphrase=`${bfe.restic_agent_args_}.passphrase`

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

bfe.restic_agent.is_restic_repo_initialised()
{
    local repo_dir=$1
    local passphrase=$2

    local result=$( RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} --repo ${repo_dir} snapshots )
    if [ -z "${result}" ]
    then
        ${ECHO_CMD} "n"
        return 0
    fi

    ${ECHO_CMD} "y"
    return 1
}

bfe.restic_agent.generate_audit_hashes_using_rsync()
{
    local source_dir=$1
    local filters=$2
    local dest_dir=$3
    local audit_filelist_filename=$4
    local audit_hashes_filename=$5

    bfe.system.utils.run "pushd ${source_dir}"
    bfe.system.utils.run "rm -rf ${audit_filelist_filename}"
    bfe.system.utils.run "rm -rf ${audit_hashes_filename}"

    bfe.restic_agent.generate_audit_filelist "${source_dir}" "${RSYNC_CMD} -naic --protect-args --out-format=%n ${filters} ${source_dir} ${dest_dir}" "${audit_filelist_filename}" "${audit_hashes_filename}"

    # Generate the audit hashes from the filelist.
    bfe.system.utils.run "${HASHDEEP_CMD} -l -f ${audit_filelist_filename} >${audit_hashes_filename}"
    bfe.system.utils.run "rm -rf ${audit_filelist_filename}"
    bfe.system.utils.run "popd"
}

bfe.restic_agent.generate_audit_hashes_using_find()
{
    local source_dir=$1
    local audit_filelist_filename=$2
    local audit_hashes_filename=$3

    bfe.system.utils.run "pushd ${source_dir}"
    bfe.system.utils.run "rm -rf ${audit_filelist_filename}"
    bfe.system.utils.run "rm -rf ${audit_hashes_filename}"

    bfe.restic_agent.generate_audit_filelist "${source_dir}" "${FIND_CMD} . -type f" "${audit_filelist_filename}" "${audit_hashes_filename}"

    # Generate the audit hashes from the filelist.
    bfe.system.utils.run "${HASHDEEP_CMD} -l -f ${audit_filelist_filename} >${audit_hashes_filename}"
    bfe.system.utils.run "rm -rf ${audit_filelist_filename}"

    bfe.system.utils.run "popd"
}

bfe.restic_agent.generate_audit_filelist()
{
    local source_dir=$1
    local cmd=$2
    local audit_filelist_filename=$3
    local audit_hashes_filename=$4

    local bdf=`${bfe.restic_agent_args_}.backupDescriptionFilename`
    local bdf=${bdf##*/}
    local bs=${BASH_SOURCE[0]#./*}

    bfe.system.utils.run "pushd ${source_dir}"

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
        if [ ! $(bfe.system.utils.starts_with_any_of "${problematic_audit_prefixes[@]}" "${file_basename}") == "y" ] &&
           [ ! "${filename}" = "${audit_filelist_filename}" ] &&
           [ ! "${filename}" = "${audit_hashes_filename}" ] &&
           [ ! "${file_basename}" = "${bdf}" ] &&
           [ ! "${file_basename}" = "${bs}" ]
        then
            eval "${ECHO_CMD} \"${filename}\" >>${audit_filelist_filename}"
        fi
    done

    bfe.system.utils.run "popd"
}

bfe.restic_agent.rsync_transfer()
{
    local source_dir=$1
    local filters=$2
    local dest_dir=$3

    bfe.system.utils.run "${MKDIR_CMD} -p ${dest_dir}"
    # Note: --archive causes issues when copying to filesystems that do not
    # support it.  It is equivalent to -rlptgoD, so, dropping the -og resolves
    # the problems.
    bfe.system.utils.run "${RSYNC_CMD} --checksum --ignore-times --itemize-changes -rlptD --delete-after --copy-links --times --verbose ${filters} ${source_dir} ${dest_dir}"
}

bfe.restic_agent.verify_audit_hashes()
{
    local source_dir=$1
    local audit_filelist_filename=$2
    local audit_hashes_filename=$3

    bfe.system.utils.run "pushd ${source_dir}"
    bfe.system.utils.run "rm -rf ${audit_filelist_filename}"

    # Audit the files against the filename hashes
    bfe.restic_agent.generate_audit_filelist "${source_dir}" "${FIND_CMD} . -type f" "${audit_filelist_filename}" "${audit_hashes_filename}"
    bfe.system.utils.run "${HASHDEEP_CMD} -v -v -v -r -a -k ${audit_hashes_filename} -f ${audit_filelist_filename}"
    bfe.system.utils.run "rm -rf ${audit_filelist_filename}"

    bfe.system.utils.run "popd"
}

bfe.restic_agent.delete_audit_hashes()
{
    local source_dir=$1
    local audit_hashes_filename=$2

    local filename="${source_dir}/${audit_hashes_filename}"

    if [ -e "${filename}" ]
    then
        bfe.system.utils.run "rm -rf ${filename}"
    fi
}
