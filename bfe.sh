#!/bin/bash
# Backup Front-End

# Define all the types
. bfe.types.sh

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
