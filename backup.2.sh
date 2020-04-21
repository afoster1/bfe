#!/bin/bash

# Define all the types
. backup.types.sh

# Read backup arguments
backup.arguments args
args.parse "$@"
args.print
echo

backup.system.init args

# create class object
backup.obj myobject args

# Create a backup descriptions object
backup.descriptions descriptions args
descriptions.load
descriptions.getBackupDescription description `args.backupName`
description.print
