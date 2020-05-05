# Define all the types defined by the backup front-end app

# Fake OO convention inspired by:
#    * http://hipersayanx.blogspot.com/2012/12/object-oriented-programming-in-bash.html?m=1
#    * https://stackoverflow.com/a/40981277

. bfe.os.commands.class.sh
. bfe.system.class.sh
. bfe.toolbox.gitolite.sh
. bfe.toolbox.git.sh

bfe.arguments()
{
    local obj_name=$1
    . <(sed "s/bfe.arguments/${obj_name}/g" bfe.arguments.class.sh)
    ${obj_name}.init
}

bfe.descriptions(){
    local obj_name=$1
    local args=$2
    . <(sed "s/bfe.descriptions/${obj_name}/g" bfe.descriptions.class.sh)
    ${obj_name}.init ${args}
}

bfe.description(){
    local obj_name=$1
    local args=$2
    local descriptionName=$3
    . <(sed "s/bfe.description/${obj_name}/g" bfe.description.class.sh)
    ${obj_name}.init ${args} ${descriptionName}
}

bfe.handler(){
    local obj_name=$1
    local args=$2
    local descriptions=$3
    . <(sed "s/bfe.handler/${obj_name}/g" bfe.handler.class.sh)
    ${obj_name}.init ${args} ${descriptions}
}

bfe.restic_agent(){
    local obj_name=$1
    local args=$2
    local descriptionName=$3
    . <(sed "s/bfe.restic_agent/${obj_name}/g" bfe.restic_agent.class.sh)
    ${obj_name}.init ${args} ${descriptionName}
}

bfe.gitolite_agent(){
    local obj_name=$1
    local args=$2
    local descriptionName=$3
    local descriptions=$4
    . <(sed "s/bfe.gitolite_agent/${obj_name}/g" bfe.gitolite_agent.class.sh)
    ${obj_name}.init ${args} ${descriptionName} ${descriptions}
}

bfe.gitolite_direct_agent(){
    local obj_name=$1
    local args=$2
    local description_name=$3
    local descriptions=$4
    . <(sed "s/bfe.gitolite_direct_agent/${obj_name}/g" bfe.gitolite_direct_agent.class.sh)
    ${obj_name}.init ${args} ${description_name} ${descriptions}
}
