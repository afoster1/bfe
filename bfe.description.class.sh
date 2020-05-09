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
    bfe.system.log.info ",--[ `bfe.description.name` ]"
    bfe.system.log.info "|>Properties"
    bfe.system.log.info "| Type: `bfe.description.type`"
    bfe.system.log.info "| Medium: `bfe.description.medium`"
    bfe.system.log.info "| Medium Label: `bfe.description.mediumLabel`"
    bfe.system.log.info "| Keep Full: `bfe.description.keepFull`"
    bfe.system.log.info "| SSH Server Server: `bfe.description.sshServer`"
    bfe.system.log.info "| SSH Server Port: `bfe.description.sshPort`"
    bfe.system.log.info "| SSH Server ID: `bfe.description.sshUserId`"
    local count=`bfe.description.data count`
    if [ "${count}" -gt 0 ]
    then
        bfe.system.log.info "|>Data"
        for ((i=0;i < ${count};i++))
        {
            bfe.system.log.info "| `bfe.description.data [$i]`"
        }
    fi
    bfe.system.log.info "\`--"
}

