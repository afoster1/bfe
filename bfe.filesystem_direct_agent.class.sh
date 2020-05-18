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
    local destination_dir=$(bfe.toolbox.utils.getStageDirectory "${description_object_name}")
    local destination_dir=$(bfe.toolbox.utils.getParentDirectoryOf "${destination_dir}")

    bfe.toolbox.filesystem.sync_and_audit "${description_object_name}" "${destination_dir}"
}

bfe.filesystem_direct_agent.backup()
{
    local description_object_name=`bfe.filesystem_direct_agent.descriptionName`
    local source_dir=$(bfe.toolbox.utils.getStageDirectory "${description_object_name}")
    local destination_dir=$(bfe.toolbox.utils.getBackupDirectory "${description_object_name}")
    local destination_dir=$(bfe.toolbox.utils.getParentDirectoryOf "${destination_dir}")

    bfe.toolbox.rsync.transfer "${source_dir}" "" "${destination_dir}"
}

bfe.filesystem_direct_agent.restore()
{
    local description_object_name=`bfe.filesystem_direct_agent.descriptionName`
    local source_dir=$(bfe.toolbox.utils.getBackupDirectory "${description_object_name}")
    local destination_dir=$(bfe.toolbox.utils.getRestoreDirectory "${description_object_name}")
    local destination_dir=$(bfe.toolbox.utils.getParentDirectoryOf "${destination_dir}")

    bfe.toolbox.rsync.transfer "${source_dir}" "" "${destination_dir}"
}

bfe.filesystem_direct_agent.verify()
{
    local description_object_name=`bfe.filesystem_direct_agent.descriptionName`
    local audit_filelist_filename=`${bfe.filesystem_direct_agent_args_}.auditFilelistFilename`
    local audit_hashes_filename=`${bfe.filesystem_direct_agent_args_}.auditHashesFilename`
    local source_dir=$(bfe.toolbox.utils.getRestoreDirectory "${description_object_name}")

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

