# Class named "backup.description"

# collection of property values
backup.description_properties=()

# properties IDs
backup.description_name=0
backup.description_type=1
backup.description_medium=2
backup.description_mediumLabel=3
backup.description_keepFull=4
backup.description_sshServer=5
backup.description_sshPort=6
backup.description_sshUserId=7
backup.description_data=array8

backup.description_dataArray=()

# fields
backup.description_args_= # Command line arguments

backup.description.init(){
    backup.description_args_=$1

    backup.description.name = $2
}

backup.description.name() { backup.system.utils.propertyAccessor backup.description_properties $1 $2
}
backup.description.type() { backup.system.utils.propertyAccessor backup.description_properties $1 $2
}
backup.description.medium() { backup.system.utils.propertyAccessor backup.description_properties $1 $2
}
backup.description.mediumLabel() { backup.system.utils.propertyAccessor backup.description_properties $1 $2
}
backup.description.keepFull() { backup.system.utils.propertyAccessor backup.description_properties $1 $2
}
backup.description.sshServer() { backup.system.utils.propertyAccessor backup.description_properties $1 $2
}
backup.description.sshPort() { backup.system.utils.propertyAccessor backup.description_properties $1 $2
}
backup.description.sshUserId() { backup.system.utils.propertyAccessor backup.description_properties $1 $2
}
backup.description.data() { backup.system.utils.propertyAccessor backup.description_properties $1 $2
}

backup.description.print()
{
    backup.system.stdout.printMessageAndValue "Backup Description: " backup.description.name
    backup.system.stdout.printMessageAndValue "- Type: " backup.description.type
    backup.system.stdout.printMessageAndValue "- Medium: " backup.description.medium
    backup.system.stdout.printMessageAndValue "- Medium Label: " backup.description.mediumLabel
    backup.system.stdout.printMessageAndValue "- Keep Full: " backup.description.keepFull
    backup.system.stdout.printMessageAndValue "- SSH Server: " backup.description.sshServer
    backup.system.stdout.printMessageAndValue "- SSH Port: " backup.description.sshPort
    backup.system.stdout.printMessageAndValue "- SSH User ID: " backup.description.sshUserId
    count=`backup.description.data count`
    if [ "${count}" -gt 0 ]
    then
        echo "- Data:"
        for ((i=0;i < ${count};i++))
        {
            backup.system.stdout.printMessageAndValue "    " backup.description.data [$i]
        }
    fi
}

