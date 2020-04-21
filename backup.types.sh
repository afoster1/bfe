# Define all the types defined by the backup app

# Fake OO convention inspired by:
#    * http://hipersayanx.blogspot.com/2012/12/object-oriented-programming-in-bash.html?m=1 
#    * https://stackoverflow.com/a/40981277 

backup.obj(){
    local objName=$1
    local args=$2
    . <(sed "s/backup.obj/${objName}/g" backup.obj.class.sh)
    ${objName}.init ${args}
}

backup.descriptions(){
    local objName=$1
    local args=$2
    . <(sed "s/backup.descriptions/${objName}/g" backup.descriptions.class.sh)
    ${objName}.init ${args}
}

backup.description(){
    local objName=$1
    local args=$2
    . <(sed "s/backup.description/${objName}/g" backup.description.class.sh)
    ${objName}.init ${args}
}

backup.arguments()
{
    . <(sed "s/backup.arguments/$1/g" backup.arguments.class.sh)
}

. backup.os.commands.class.sh
. backup.system.class.sh
