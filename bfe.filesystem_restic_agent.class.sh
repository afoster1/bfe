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
    local description_object_name=`bfe.filesystem_restic_agent.descriptionName`
    local destination_dir=$(bfe.toolbox.utils.getStageDirectory "${description_object_name}")
    local destination_dir=$(bfe.toolbox.utils.getParentDirectoryOf "${destination_dir}")

    bfe.toolbox.filesystem.sync_and_audit "${description_object_name}" "${destination_dir}"
}

bfe.filesystem_restic_agent.backup()
{
    local description_object_name=`bfe.filesystem_restic_agent.descriptionName`
    local source_dir=$(bfe.toolbox.utils.getStageDirectory "${description_object_name}")
    local destination_dir=$(bfe.toolbox.utils.getBackupDirectory "${description_object_name}")
    local passphrase=`${bfe.filesystem_restic_agent_args_}.passphrase`

    bfe.toolbox.restic.backup "${source_dir}" "${destination_dir}" "${passphrase}"
}

bfe.filesystem_restic_agent.restore()
{
    local description_object_name=`bfe.filesystem_restic_agent.descriptionName`
    local source_dir=$(bfe.toolbox.utils.getBackupDirectory "${description_object_name}")
    local destination_dir=$(bfe.toolbox.utils.getRestoreDirectory "${description_object_name}")
    local passphrase=`${bfe.filesystem_restic_agent_args_}.passphrase`

    bfe.toolbox.restic.restore "${source_dir}" "${destination_dir}" "${passphrase}"
}

bfe.filesystem_restic_agent.verify()
{
    local description_object_name=`bfe.filesystem_restic_agent.descriptionName`
    local source_dir=$(bfe.toolbox.utils.getBackupDirectory "${description_object_name}")
    local restore_dir=$(bfe.toolbox.utils.getRestoreDirectory "${description_object_name}")
    local passphrase=`${bfe.filesystem_restic_agent_args_}.passphrase`

    bfe.toolbox.restic.verify "${source_dir}" "${restore_dir}" "${passphrase}"
}

bfe.filesystem_restic_agent.cleanup()
{
    local description_object_name=`bfe.filesystem_restic_agent.descriptionName`
    local source_dir=$(bfe.toolbox.utils.getBackupDirectory "${description_object_name}")
    local passphrase=`${bfe.filesystem_restic_agent_args_}.passphrase`
    local keep_full=`${description_object_name}.keepFull`

    bfe.toolbox.restic.cleanup "${source_dir}" "${passphrase}" "${keep_full}"
}

bfe.filesystem_restic_agent.status()
{
    local description_object_name=`bfe.filesystem_restic_agent.descriptionName`
    local source_dir=$(bfe.toolbox.utils.getBackupDirectory "${description_object_name}")
    local passphrase=`${bfe.filesystem_restic_agent_args_}.passphrase`

    bfe.system.utils.run "RESTIC_PASSWORD=${passphrase} ${RESTIC_CMD} snapshots --repo ${source_dir}"
}
