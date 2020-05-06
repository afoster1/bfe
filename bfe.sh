#!/bin/bash
# Backup Front-End

# Find out the scripts directory is
bfe.getScriptDirectory()
{
    local src="${BASH_SOURCE[0]}"
    local dirname_cmd=`which dirname 2> /dev/null`

    # resolve $src until the file is no longer a symlink
    while [ -h "${src}" ]
    do
        local dir="$( cd -P "$( ${dirname_cmd} "${src}" )" && pwd )"
        local src="$(readlink "${src}")"
        # if $src was a relative symlink, we need to resolve it relative to
        # the path where the symlink file was located
        [[ ${src} != /* ]] && src="${dir}/${src}"
    done

    echo "$( cd -P "$( ${dirname_cmd} "${src}" )" && pwd )"
}
bfe_script_directory_=`bfe.getScriptDirectory`

# Define all the types
. "${bfe_script_directory_}/bfe.types.sh"

# Read backup arguments
bfe.arguments args
args.parse "$@"
args.print

# Initialise system
bfe.system.init args
echo

# Create a backup descriptions object
bfe.descriptions descriptions args
descriptions.load

# Print each backup description (aka. group)
num_descriptions=`args.backupGroups count`
if [ "${num_descriptions}" -gt 0 ]
then
    # Construct a backup handler
    bfe.handler handler args descriptions

    e="declare -a description_names=`args.backupGroups`"
    eval "$e"
    for name in ${description_names[@]}
    do
        handler.process "${name}"
    done
fi
