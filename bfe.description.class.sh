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

bfe.description.name() { bfe.toolbox.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.type() { bfe.toolbox.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.medium() { bfe.toolbox.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.mediumLabel() { bfe.toolbox.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.keepFull() { bfe.toolbox.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.sshServer() { bfe.toolbox.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.sshPort() { bfe.toolbox.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.sshUserId() { bfe.toolbox.utils.propertyAccessor bfe.description_properties $1 $2
}
bfe.description.data() { bfe.toolbox.utils.propertyAccessor bfe.description_properties $1 $2
}

bfe.description.print()
{
    bfe.toolbox.log.info ",--[ `bfe.description.name` ]"
    bfe.toolbox.log.info "|>Properties"
    bfe.toolbox.log.info "| Type: `bfe.description.type`"
    bfe.toolbox.log.info "| Medium: `bfe.description.medium`"
    bfe.toolbox.log.info "| Medium Label: `bfe.description.mediumLabel`"
    bfe.toolbox.log.info "| Keep Full: `bfe.description.keepFull`"
    bfe.toolbox.log.info "| SSH Server Server: `bfe.description.sshServer`"
    bfe.toolbox.log.info "| SSH Server Port: `bfe.description.sshPort`"
    bfe.toolbox.log.info "| SSH Server ID: `bfe.description.sshUserId`"
    local count=`bfe.description.data count`
    if [ "${count}" -gt 0 ]
    then
        bfe.toolbox.log.info "|>Data"
        for ((i=0;i < ${count};i++))
        {
            bfe.toolbox.log.info "| `bfe.description.data [$i]`"
        }
    fi
    bfe.toolbox.log.info "\`--"
}

