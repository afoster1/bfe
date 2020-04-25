# Class named "backup.descriptions" for bash Object

# collection of property values
backup.descriptions_properties=()

# properties IDs
backup.descriptions_filename=0

# fields
backup.descriptions_args_= # Command line arguments
backup.descriptions_backupDescriptionNames_=  # Names of backups contained in the description file

backup.descriptions.init(){
    backup.descriptions_args_=$1

    backup.descriptions.filename = `${backup.descriptions_args_}.backupDescriptionFilename`
}

backup.descriptions.filename() { backup.system.utils.propertyAccessor backup.descriptions_properties $1 $2
}

backup.descriptions.load()
{
    local filename=`backup.descriptions.filename`

    unset backup.descriptions_backupDescriptionNames_
    declare -g -a backup.descriptions_backupDescriptionNames_

    if [ -z "${filename}" ]
    then
        ${ECHO_CMD} "Backup description filename not provided."
    else
        if [ ! -e "${filename}" ]
        then
            ${ECHO_CMD} "Backup description filename [${filename}] does not exist."
        else
            ${ECHO_CMD} "Reading backup description filename [${filename}]."

            # Prepare a dictionary in which to store discovered propeties...
            new_property_block=true
            new_data_block=true
            name=

            # Read the description file
            while IFS= read line
            do
                action=$(${ECHO_CMD} "$line" | ${CUT_CMD} -c 1)
                value=$(${ECHO_CMD} "$line" | ${CUT_CMD} -c 2-)
                if [ ! "${action}" = "#" ]
                then
                    if [ "${action}" = ":" ]
                    then
                        new_data_block=true

                        property_name=
                        property_value=
                        IFS='=' read -r property_name property_value <<< "${value}"

                        if [ "${new_property_block}" = true ]
                        then
                            if [ "${property_name}" = "NAME" ]
                            then
                                new_property_block=false
                                unset backup.descriptions_backupDescriptionProperties${property_value}_
                                declare -g -A backup.descriptions_backupDescriptionProperties${property_value}_ # Associative array
                                backup.descriptions_backupDescriptionNames_=("${backup.descriptions_backupDescriptionNames_[@]}" "${property_value}")
                                name=${property_value}
                            else
                                name=
                                backup.system.log.error "Backup description does not start with NAME property."
                            fi
                        else
                            eval "backup.descriptions_backupDescriptionProperties${name}_+=([${property_name}]=${property_value})"
                        fi
                    else
                        new_property_block=true

                        if [ "${new_data_block}" = true ]
                        then
                            if [ -n "${name}" ]
                            then
                                new_data_block=false
                                unset backup.descriptions_backupDescriptionData${name}_
                                declare -g -a backup.descriptions_backupDescriptionData${name}_ # Indexed array
                            else
                                backup.system.log.error "Backup description does not start with NAME property."
                            fi
                        fi
                        eval "backup.descriptions_backupDescriptionData${name}_+=('${line}')"
                    fi
                else
                    new_property_block=true
                fi
            done < ${filename}
        fi
    fi
}

backup.descriptions.getBackupDescription()
{
    object_name=$1
    name=$2

    if [ $(backup.system.utils.contains "${backup.descriptions_backupDescriptionNames_[@]}" "${name}") == "n" ]
    then
        backup.system.log.error "Backup description [${name}] does not exist."
    else
        backup.description ${object_name} ${backup.descriptions_args_} ${name}

        # TODO ANFO Load all the data for the description from the arrays...

        # Read the details
        array_name=backup.descriptions_backupDescriptionProperties`${object_name}.name`_
        eval "array_keys=\${!${array_name}[@]}"
        for i in ${array_keys}
        do
            if [ "${i}" = "TYPE" ]
            then
                eval "value=\${${array_name}[${i}]}"
                ${object_name}.type = "${value}"
            fi

            if [ "${i}" = "MEDIUM" ]
            then
                eval "value=\${${array_name}[${i}]}"
                ${object_name}.medium = "${value}"
            fi

            if [ "${i}" = "MEDIUM_LABEL" ]
            then
                eval "value=\${${array_name}[${i}]}"
                ${object_name}.mediumLabel = "${value}"
            fi

            if [ "${i}" = "KEEP_FULL" ]
            then
                eval "value=\${${array_name}[${i}]}"
                ${object_name}.keepFull = "${value}"
            fi

            if [ "${i}" = "SSH_SERVER" ]
            then
                eval "value=\${${array_name}[${i}]}"
                ${object_name}.sshServer = "${value}"
            fi

            if [ "${i}" = "SSH_PORT" ]
            then
                eval "value=\${${array_name}[${i}]}"
                ${object_name}.sshPort = "${value}"
            fi

            if [ "${i}" = "SSH_USER_ID" ]
            then
                eval "value=\${${array_name}[${i}]}"
                ${object_name}.sshUserId = "${value}"
            fi
        done

        # Read the data
        data_name=backup.descriptions_backupDescriptionData`${object_name}.name`_
        eval "data_indexes=\${!${data_name}[@]}"
        local a=()
        for index in ${data_indexes}
        do
            eval "data_value=\${${data_name}[${index}]}"
            if [ ${#data_value} -gt 0 ]
            then
                ${object_name}.data += "${data_value}"
            fi
        done

        # TODO ANFO Maybe it would be simpler to create object instances for all backup descriptions loaded... instead of using the arrays??
    fi
}
