#!/bin/bash

# Define all the types
. backup.types.sh

# create class object
backup.obj myobject
myobject.sayHello
myobject.fileName = "file1"

backup.arguments args
args.parse "$@"

backup.system.stdout.printString "Configuration Filename"
backup.system.stdout.printValue args.configFilename

backup.system.stdout.printString "Passphrase Filename"
backup.system.stdout.printValue args.passphraseFilename

backup.system.stdout.printString "..."
backup.system.stdout.printValue args.sendEmail
