#!/bin/bash

# Define all the types
. backup.types.sh

# create class object
backup.obj myobject
myobject.sayHello
myobject.fileName = "file1"

backup.system.stdout.printString "value is"
backup.system.stdout.printValue myobject.fileName
