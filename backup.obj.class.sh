# Class named "backup.obj" for bash Object

# property
backup.obj_properties=()

# properties IDs
fileName=0
fileSize=1

backup.obj.sayHello(){
    echo Hello
}

backup.obj.property(){
    if [ "$2" == "=" ]
    then
        backup.obj_properties[$1]=$3
    else
        echo ${backup.obj_properties[$1]}
    fi
}

backup.obj.fileName(){
    if [ "$1" == "=" ]
    then
        backup.obj.property fileName = $2
    else
        backup.obj.property fileName
    fi
}
