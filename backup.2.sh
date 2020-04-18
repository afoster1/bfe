#!/bin/bash

# Define all the types
. backup.types.sh

# Read backup arguments
backup.arguments args
args.parse "$@"
args.showArguments

# Example of setting an array from the script
# a=("sdf" "jkl")
# array="$(declare -p a)"
# args.actions = "\${array}"

# create class object
backup.obj myobject args
myobject.showDescription
myobject.filename = "file1"
echo `myobject.filename`

