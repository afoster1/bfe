#!/bin/bash

# Define all the types
. backup.types.sh

# Read backup arguments
backup.arguments args
args.parse "$@"
args.print

# Initialise system
backup.system.init args
echo

# Create a backup descriptions object
backup.descriptions descriptions args
descriptions.load

# Print each backup description (aka. group)
numGroups=`args.backupGroups count`
if [ "${numGroups}" -gt 0 ]
then
    # Need to get a list of backup groups first...
    a=()
    for((i=0; i < ${numGroups}; i++))
    {
        a=("${a[@]}" "`args.backupGroups [${i}]`")
    }
    # ...then process them separately
    for n in ${a[@]}
    do
        descriptions.getBackupDescription description ${n}
        description.print
        ${ECHO_CMD}
    done
fi
