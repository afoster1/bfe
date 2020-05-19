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

bfe.git_direct_agent.descriptionName() { bfe.toolbox.utils.propertyAccessor bfe.git_direct_agent_properties $1 $2
}

bfe.git_direct_agent.stage()
{
    local description_object_name=`bfe.git_direct_agent.descriptionName`
    local destination_dir=$(bfe.toolbox.utils.getStageDirectory "${description_object_name}")
    local audit_filelist_filename=`${bfe.git_direct_agent_args_}.auditFilelistFilename`
    local audit_hashes_filename=`${bfe.git_direct_agent_args_}.auditHashesFilename`

    bfe.toolbox.utils.run "${RM_CMD} -rf ${destination_dir}"
    bfe.toolbox.utils.run "${MKDIR_CMD} -p ${destination_dir}"

    e="declare -a bfe.git_direct_agent_urls=`${description_object_name}.data`"
    eval "$e"
    for url in ${bfe.git_direct_agent_urls[@]}
    do
        bfe.toolbox.git.mirror "${url}" "${destination_dir}"
    done

    bfe.toolbox.utils.copyBFE "${bfe_script_directory_}" "${destination_dir}"
    bfe.toolbox.audit.generate_audit_hashes_using_find "${destination_dir}" "${audit_filelist_filename}" "${audit_hashes_filename}"
}

bfe.git_direct_agent.backup()
{
    local description_object_name=`bfe.git_direct_agent.descriptionName`
    local source_dir=$(bfe.toolbox.utils.getStageDirectory "${description_object_name}")
    local destination_dir=$(bfe.toolbox.utils.getBackupDirectory "${description_object_name}")

    bfe.toolbox.rsync.transfer "${source_dir}" "" "${destination_dir}"
}

bfe.git_direct_agent.restore()
{
    local description_object_name=`bfe.git_direct_agent.descriptionName`
    local source_dir=$(bfe.toolbox.utils.getBackupDirectory "${description_object_name}")
    local destination_dir=$(bfe.toolbox.utils.getRestoreDirectory "${description_object_name}")
    local destination_dir=$(bfe.toolbox.utils.getParentDirectoryOf "${destination_dir}")

    bfe.toolbox.rsync.transfer "${source_dir}" "" "${destination_dir}"
}

bfe.git_direct_agent.verify()
{
    local description_object_name=`bfe.git_direct_agent.descriptionName`
    local source_dir=$(bfe.toolbox.utils.getRestoreDirectory "${description_object_name}")
    local audit_filelist_filename=`${bfe.git_direct_agent_args_}.auditFilelistFilename`
    local audit_hashes_filename=`${bfe.git_direct_agent_args_}.auditHashesFilename`

    bfe.toolbox.audit.verify_audit_hashes "${source_dir}" "${audit_filelist_filename}" "${audit_hashes_filename}"
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
