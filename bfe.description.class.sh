# Class named "bfe.description"

# collection of property values
bfe.description_properties=()

# properties IDs
bfe.description_name=0
bfe.description_type=1
bfe.description_medium=2
bfe.description_mediumLabel=3
bfe.description_keepFull=4
bfe.description_sshServer=5
bfe.description_sshPort=6
bfe.description_sshUserId=7
bfe.description_data=array8

bfe.description_dataArray=()

# fields
bfe.description_args_= # Command line arguments

bfe.description.init(){
    bfe.description_args_=$1

    bfe.description.name = $2
}

bfe.description.name() { bfe.system.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.type() { bfe.system.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.medium() { bfe.system.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.mediumLabel() { bfe.system.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.keepFull() { bfe.system.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.sshServer() { bfe.system.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.sshPort() { bfe.system.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.sshUserId() { bfe.system.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.data() { bfe.system.utils.propertyAccessor bfe.description_properties $1 $2
}

bfe.description.print()
{
    bfe.system.stdout.printMessageAndValue "bfe.description: " bfe.description.name
    bfe.system.stdout.printMessageAndValue "- Type: " bfe.description.type
    bfe.system.stdout.printMessageAndValue "- Medium: " bfe.description.medium
    bfe.system.stdout.printMessageAndValue "- Medium Label: " bfe.description.mediumLabel
    bfe.system.stdout.printMessageAndValue "- Keep Full: " bfe.description.keepFull
    bfe.system.stdout.printMessageAndValue "- SSH Server: " bfe.description.sshServer
    bfe.system.stdout.printMessageAndValue "- SSH Port: " bfe.description.sshPort
    bfe.system.stdout.printMessageAndValue "- SSH User ID: " bfe.description.sshUserId
    count=`bfe.description.data count`
    if [ "${count}" -gt 0 ]
    then
        echo "- Data:"
        for ((i=0;i < ${count};i++))
        {
            bfe.system.stdout.printMessageAndValue "    " bfe.description.data [$i]
        }
    fi
}

