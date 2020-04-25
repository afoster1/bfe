# Define all the types defined by the backup front-end app

# Fake OO convention inspired by:
#    * http://hipersayanx.blogspot.com/2012/12/object-oriented-programming-in-bash.html?m=1 
#    * https://stackoverflow.com/a/40981277 

. bfe.os.commands.class.sh
. bfe.system.class.sh

bfe.arguments()
{
    . <(sed "s/bfe.arguments/$1/g" bfe.arguments.class.sh)
}

bfe.descriptions(){
    local objName=$1
    local args=$2
    . <(sed "s/bfe.descriptions/${objName}/g" bfe.descriptions.class.sh)
    ${objName}.init ${args}
}

bfe.description(){
    local objName=$1
    local args=$2
    local descriptionName=$3
    . <(sed "s/bfe.description/${objName}/g" bfe.description.class.sh)
    ${objName}.init ${args} ${descriptionName}
}

bfe.handler(){
    local objName=$1
    local args=$2
    local descriptionName=$3
    . <(sed "s/bfe.handler/${objName}/g" bfe.handler.class.sh)
    ${objName}.init ${args} ${descriptionName}
}

bfe.restic_agent(){
    local objName=$1
    local args=$2
    local descriptionName=$3
    . <(sed "s/bfe.restic_agent/${objName}/g" bfe.restic_agent.class.sh)
    ${objName}.init ${args} ${descriptionName}
}
