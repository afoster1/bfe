# Tools to help operations involving rsync

bfe.toolbox.rsync.transfer()
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
