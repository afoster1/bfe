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
numGroups=`args.backupGroups count`
if [ "${numGroups}" -gt 0 ]
then
    # Construct a backup handler
    bfe.handler handler args descriptions

    # Then get a list of backup descriptions first...
    a=()
    for((i=0; i < ${numGroups}; i++))
    {
        a=("${a[@]}" "`args.backupGroups [${i}]`")
    }
    # ...then process them separately
    for n in ${a[@]}
    do
        handler.process "${n}"
    done
fi
