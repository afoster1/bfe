# Class named "backup.obj" for bash Object

# collection of property values
backup.obj_properties=()

# properties IDs
filename=0

# fields
backup.obj_args= 

backup.obj.init(){
    backup.obj_args=$1
}

backup.obj.showDescription() {
    backup.system.stdout.printMessageAndValue "Backup Name: " ${backup.obj_args}.backupName
    # TODO ANFO Remove example below
    #local backupName=`${args_}.backupName`
}

backup.obj.filename() { backup.system.utils.propertyAccessor backup.obj_properties $1 $2
}
