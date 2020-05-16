# Tools to help operations involving restic backups.

# Fields
bfe_toolbox_restic_args_= # Command line arguments

bfe.toolbox.restic.init()
{
    bfe_toolbox_restic_args_=$1
}

bfe.toolbox.restic.is_repo_initialised()
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

bfe.toolbox.restic.backup()
{
    local source_dir=$1
    local destination_dir=$2
    local passphrase=$3

    bfe.system.utils.run "${MKDIR_CMD} -p ${destination_dir}"

    if [ $(bfe.toolbox.restic.is_repo_initialised "${destination_dir}" "${passphrase}") == "n" ]
    then
        bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} init --repo ${destination_dir}"
    fi

    bfe.system.utils.run "cd ${source_dir}"
    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} backup --repo ${destination_dir} backup . --verbose"

    bfe.system.utils.copyBFE "${bfe_script_directory_}" "${destination_dir}"
}

bfe.toolbox.restic.restore()
{
    local source_dir=$1
    local destination_dir=$2
    local passphrase=$3

    bfe.system.utils.run "${MKDIR_CMD} -p ${destination_dir}"
    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} restore latest --repo ${source_dir} --target ${destination_dir}/"
}

bfe.toolbox.restic.verify()
{
    local source_dir=$1
    local restore_dir=$2
    local passphrase=$3
    local audit_filelist_filename=`${bfe_toolbox_restic_args_}.auditFilelistFilename`
    local audit_hashes_filename=`${bfe_toolbox_restic_args_}.auditHashesFilename`

    # Verify the backup data first.
    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} --repo ${source_dir} check --read-data"

    # Audit the restored files against the filename hashes
    bfe.toolbox.audit.verify_audit_hashes "${restore_dir}/" "${audit_filelist_filename}" "${audit_hashes_filename}"
}

bfe.toolbox.restic.cleanup()
{
    local source_dir=$1
    local passphrase=$2
    local keep_full=$3

    # Run the cleanup
    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} --repo ${source_dir} snapshots"
    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} --repo ${source_dir} forget --keep-last ${keep_full} --prune"
    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} --repo ${source_dir} snapshots"
    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} --repo ${source_dir} check"
}
