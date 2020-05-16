# Define all the types defined by the backup front-end app

# Fake OO convention inspired by:
#    * http://hipersayanx.blogspot.com/2012/12/object-oriented-programming-in-bash.html?m=1
#    * https://stackoverflow.com/a/40981277

. "${bfe_script_directory_}/bfe.os.commands.class.sh"
. "${bfe_script_directory_}/bfe.system.class.sh"
. "${bfe_script_directory_}/bfe.toolbox.gitolite.sh"
. "${bfe_script_directory_}/bfe.toolbox.git.sh"
. "${bfe_script_directory_}/bfe.toolbox.hashing.sh"
. "${bfe_script_directory_}/bfe.toolbox.restic.sh"
. "${bfe_script_directory_}/bfe.toolbox.rsync.sh"
. "${bfe_script_directory_}/bfe.toolbox.filesystem.sh"

bfe.arguments()
{
    local obj_name=$1
    . <(sed "s/bfe.arguments/${obj_name}/g" "${bfe_script_directory_}/bfe.arguments.class.sh")
    ${obj_name}.init
}

bfe.descriptions(){
    local obj_name=$1
    local args=$2
    . <(sed "s/bfe.descriptions/${obj_name}/g" "${bfe_script_directory_}/bfe.descriptions.class.sh")
    ${obj_name}.init ${args}
}

bfe.description(){
    local obj_name=$1
    local args=$2
    local description_name=$3
    . <(sed "s/bfe.description/${obj_name}/g" "${bfe_script_directory_}/bfe.description.class.sh")
    ${obj_name}.init ${args} ${description_name}
}

bfe.handler(){
    local obj_name=$1
    local args=$2
    local descriptions=$3
    local notifier=$4
    . <(sed "s/bfe.handler/${obj_name}/g" "${bfe_script_directory_}/bfe.handler.class.sh")
    ${obj_name}.init "${args}" "${descriptions}" "${notifier}"
}

bfe.notifier(){
    local obj_name=$1
    local args=$2
    . <(sed "s/bfe.notifier/${obj_name}/g" "${bfe_script_directory_}/bfe.notifier.class.sh")
    ${obj_name}.init "${args}"
}

bfe.filesystem_restic_agent(){
    local obj_name=$1
    local args=$2
    local description_name=$3
    . <(sed "s/bfe.filesystem_restic_agent/${obj_name}/g" "${bfe_script_directory_}/bfe.filesystem_restic_agent.class.sh")
    ${obj_name}.init ${args} ${description_name}
}

bfe.gitolite_restic_agent(){
    local obj_name=$1
    local args=$2
    local description_name=$3
    local descriptions=$4
    . <(sed "s/bfe.gitolite_restic_agent/${obj_name}/g" "${bfe_script_directory_}/bfe.gitolite_restic_agent.class.sh")
    ${obj_name}.init ${args} ${description_name} ${descriptions}
}

bfe.gitolite_direct_agent(){
    local obj_name=$1
    local args=$2
    local description_name=$3
    local descriptions=$4
    . <(sed "s/bfe.gitolite_direct_agent/${obj_name}/g" "${bfe_script_directory_}/bfe.gitolite_direct_agent.class.sh")
    ${obj_name}.init ${args} ${description_name} ${descriptions}
}

bfe.git_restic_agent(){
    local obj_name=$1
    local args=$2
    local description_name=$3
    . <(sed "s/bfe.git_restic_agent/${obj_name}/g" "${bfe_script_directory_}/bfe.git_restic_agent.class.sh")
    ${obj_name}.init "${args}" "${description_name}"
}

bfe.git_direct_agent(){
    local obj_name=$1
    local args=$2
    local description_name=$3
    . <(sed "s/bfe.git_direct_agent/${obj_name}/g" "${bfe_script_directory_}/bfe.git_direct_agent.class.sh")
    ${obj_name}.init "${args}" "${description_name}"
}
