# Class "backup.arguments" responsible for reading the command line.

# property
backup.arguments_properties=()

# properties IDs
backup.arguments_configFilename=0
backup.arguments_passphraseFilename=1
backup.arguments_passphrase=2
backup.arguments_emailPasswordFilename=3
backup.arguments_emailPassword=4
backup.arguments_backupDescriptionFilename=5
backup.arguments_sendEmail=6
backup.arguments_emailFrom=7
backup.arguments_hostname=8
backup.arguments_backupMedium=9
backup.arguments_backupMediumLabel=10
backup.arguments_workDir=11
backup.arguments_backupMediumDir=12
backup.arguments_stageSubDir=13
backup.arguments_backupSubDir=14
backup.arguments_restoreSubDir=15
backup.arguments_logSubDir=16
backup.arguments_backupName=17
backup.arguments_actions=array18
backup.arguments_backupGroups=array19
backup.arguments_fullBackup=20
backup.arguments_useLog=21
backup.arguments_dryRun=22
backup.arguments_certificateDatabase=23

backup.arguments_actionsArray=()
backup.arguments_backupGroupsArray=()

backup.arguments.configFilename() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.passphraseFilename() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.passphrase() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.emailPasswordFilename() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.emailPassword() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.backupDescriptionFilename() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.sendEmail() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.emailFrom() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.hostname() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.backupMedium() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.backupMediumLabel() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.workDir() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.backupMediumDir() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.stageSubDir() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.backupSubDir() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.restoreSubDir() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.logSubDir() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.backupName() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.actions() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.backupGroups() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.fullBackup() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
} 
backup.arguments.useLog() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.dryRun() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}
backup.arguments.certificateDatabase() { backup.system.utils.propertyAccessor backup.arguments_properties $1 $2
}

backup.arguments.parse()
{
    ARGS="$@"

    while getopts ":a:g:h:c:efln:-:" option ${ARGS}
    do
      case $option in
        -)
            case ${OPTARG} in
                config-file)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments.configFilename = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                pf|passphrase-file)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments.passphraseFilename = ${!OPTIND}
                        backup.arguments.passphrase = `cat $(backup.arguments.passphraseFilename)`
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                epf|email-password-file)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments.emailPasswordFilename = ${!OPTIND}
                        backup.arguments.emailPassword = `cat $(backup.arguments.emailPasswordFilename)`
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                bdf|backup-description-file)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments.backupDescriptionFilename = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                send-email)
                    backup.arguments.sendEmail = true
                    ;;
                email-from)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments.emailFrom = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                hostname)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments.hostname = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                bm|backup-medium)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments.backupMedium = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                bml|backup-medium-label)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments.backupMediumLabel = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                work-dir)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments.workDir = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                bmd|backup-medium-dir)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments.backupMediumDir = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                stage-subdir)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments.stageSubDir = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                backup-subdir)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments.backupSubDir = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                restore-subdir)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments.restoreSubDir = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                log-subdir)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments.logSubDir = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                name)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments.backupName = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                action)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments_actionsArray=("${backup.arguments_actionsArray[@]}" "${!OPTIND}")
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                group)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        backup.arguments_backupGroupsArray=("${backup.arguments_backupGroupsArray[@]}" "${!OPTIND}")
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                full-backup)
                    backup.arguments.fullBackup = true
                    ;;
                log)
                    backup.arguments.useLog = true
                    ;;
                dry-run)
                    backup.arguments.dryRun = true
                    ;;
            esac
            ;;

        c) backup.arguments.configFilename = ${OPTARG};;
        a) backup.arguments_actionsArray=("${backup.arguments_actionsArray[@]}" "${OPTARG}");;
        g) backup.arguments_backupGroupsArray=("${backup.arguments_backupGroupsArray[@]}" "${OPTARG}");;
        h) backup.arguments.hostname = ${OPTARG};;
        n) backup.arguments.backupName = ${OPTARG};;
        f) backup.arguments.fullBackup = true;;
        e) backup.arguments.sendEmail = true;;
        l) backup.arguments.useLog = true;;

        :)
          ${ECHO_CMD} "Option -${OPTARG} needs an argument." >&2
          USAGE_ERROR=true
        ;;
        \?)
          ${ECHO_CMD} "Invalid option: -${OPTARG}" >&2
          USAGE_ERROR=true
        ;;
        esac
    done

    if [ "${USAGE_ERROR}" = "true" ]
    then
        backup.arguments.showUsage
        exit 1
    fi

    backup.arguments.setDefaults
}

backup.arguments.setDefaults()
{
    if [ -z "`backup.arguments.hostname`" ]
    then
        backup.arguments.hostname = `${HOSTNAME_CMD}`
    fi

    if [ -z "`backup.arguments.configFilename`" ]
    then
        if [ -z "`backup.arguments.workDir`" ]
        then
            backup.arguments.configFilename = "backup.cfg"
        else
            backup.arguments.configFilename = "`backup.arguments.workDir`/backup.cfg"
        fi
    fi

    backup.arguments.readConfigurationFile

    if [ -z "`backup.arguments.workDir`" ]
    then
        backup.arguments.workDir = `backup.system.utils.getWorkingDirectory`
    fi


    if [ -z "`backup.arguments.backupDescriptionFilename`" ]
    then
        backup.arguments.backupDescriptionFilename = "`backup.arguments.workDir`/backup-descriptions.txt"
    fi

    if [ -z "`backup.arguments.stageSubDir`" ]
    then
        backup.arguments.stageSubDir = stage
    fi

    if [ -z "`backup.arguments.backupSubDir`" ]
    then
        backup.arguments.backupSubDir = backup
    fi

    if [ -z "`backup.arguments.restoreSubDir`" ]
    then
        backup.arguments.restoreSubDir = restore
    fi

    if [ -z "`backup.arguments.logSubDir`" ]
    then
        backup.arguments.logSubDir = log
    fi

    if [ -z "`backup.arguments.backupMediumDir`" ]
    then
        backup.arguments.backupMediumDir = /media
    fi

    if [ ${#backup.arguments_actionsArray[@]} -eq 0 ]
    then
        backup.arguments.actions += default
    fi
}

backup.arguments.readConfigurationFile()
{
    local filename=`backup.arguments.configFilename`

    if [ -f "${filename}" ];
    then
        # Read the configuration file
        while IFS= read line
        do
            name=${line%=*}
            value=${line#*=}

            if [ ${#name} -gt 0 ]
            then
                if [ "${name}" = "WORK_DIR" ]
                then
                    backup.arguments.workDir = ${value}
                fi

                if [ "${name}" = "EMAIL_PASSWORD" ]
                then
                    backup.arguments.emailPassword = ${value}
                fi

                if [ "${name}" = "PASSPHRASE" ]
                then
                    backup.arguments.passphrase = ${value}
                fi

                if [ "${name}" = "EMAIL_FROM" ]
                then
                    backup.arguments.emailFrom = ${value}
                fi

                if [ "${name}" = "BACKUP_DESCRIPTION_FILENAME" ]
                then
                    backup.arguments.backupDescriptionFilename = ${value}
                fi

                if [ "${name}" = "CERTIFICATE_DATABASE" ]
                then
                    backup.arguments.certificateDatabase = ${value}
                fi
            fi
        done < ${filename}
    fi
}

backup.arguments.print()
{
    backup.system.stdout.printMessageAndValue "Backup Name: " backup.arguments.backupName
    backup.system.stdout.printMessageAndValue "Configuration Filename: " backup.arguments.configFilename
    backup.system.stdout.printMessageAndValue "Passphrase Filename: " backup.arguments.passphraseFilename
    backup.system.stdout.printArray "Backup Groups: " backup.arguments.backupGroups
    backup.system.stdout.printArray "Backup Actions: " backup.arguments.actions

    echo
    echo "Arguments:"

    backup.system.stdout.printValueObscured backup.arguments.passphrase
    backup.system.stdout.printValue backup.arguments.emailPasswordFilename
    backup.system.stdout.printValueObscured backup.arguments.emailPassword
    backup.system.stdout.printValue backup.arguments.backupDescriptionFilename
    backup.system.stdout.printValue backup.arguments.sendEmail
    backup.system.stdout.printValue backup.arguments.emailFrom
    backup.system.stdout.printValue backup.arguments.hostname
    backup.system.stdout.printValue backup.arguments.backupMedium
    backup.system.stdout.printValue backup.arguments.backupMediumLabel
    backup.system.stdout.printValue backup.arguments.workDir
    backup.system.stdout.printValue backup.arguments.backupMediumDir
    backup.system.stdout.printValue backup.arguments.stageSubDir
    backup.system.stdout.printValue backup.arguments.backupSubDir
    backup.system.stdout.printValue backup.arguments.restoreSubDir
    backup.system.stdout.printValue backup.arguments.logSubDir
    backup.system.stdout.printValue backup.arguments.fullBackup
    backup.system.stdout.printValue backup.arguments.useLog
    backup.system.stdout.printValue backup.arguments.dryRun
    backup.system.stdout.printValue backup.arguments.certificateDatabase
}

backup.arguments.showUsage()
{
    cat <<-___HERE
    Usage: $0
               --c|--config-file [Configuration filename]
               --pf|--passphrase-file [passphrase filename]
               --epf|--email-password-file [email password filename]
               -e|--send-email
               --email-from [email address]
               -h|--hostname [hostname]
               --bm|backup-medium [local|usbdrive]
               --bml|backup-medium-label [id string]
               --bmd|backup-medium-dir [directory]
               --bdf|backup-description-file [filename]
               --work-dir [directory]
               --stage-subdir [directory]
               --backup-subdir [directory]
               --restore-subdir [directory]
               --log-subdir [directory]
               -a|--action [action]
               -g|--group [group]
               -n|--name [name]
               -f|--full-backup
               -l|--log
               --drop-caches
               --dry-run

    Examples:

        1. List the backup STATUS.
           ./backup.sh -c backup.cfg -g [group] -a status
           Or: ./backup.sh --drop-caches --bdf [path/to/backup-descriptions.txt] -g [group] -a status
           Eg.: ./backup.sh --drop-caches --bdf /root/bin/backup-descriptions.txt -g [group] -a status

        2. Perform a COMPLETE BACKUP (ie. stage, backup, restore, verify, cleanup).
           ./backup.sh --drop-caches -c backup.cfg -g [group]
           Or: ./backup.sh --drop-caches --pf [/path/to/backup.passphrase] --bdf [path/to/backup-descriptions.txt] --work-dir [path/to/workdir] -g [group]
           Eg.: ./backup.sh --drop-caches --pf /root/bin/backup.passphrase --bdf /root/bin/backup-descriptions.txt --work-dir /home/backup_data -g [group]

        3. Perform a FULL BACKUP (ie. not incremental).
           ./backup.sh --drop-caches -c backup.cfg -g [group] -f
           Or: ./backup.sh --drop-caches --pf [/path/to/backup.passphrase] --bdf [path/to/backup-descriptions.txt] --work-dir [path/to/workdir] -g [group] -f
           Eg.: ./backup.sh --drop-caches --pf /root/bin/backup.passphrase --bdf /root/bin/backup-descriptions.txt --work-dir /home/backup_data -g [group] -f

        4. RESTORE a backup.
           ./backup.sh --drop-caches -c backup.cfg -g [group] -a restore
           Or: ./backup.sh --drop-caches --pf [/path/to/backup.passphrase] --bdf [path/to/backup-descriptions.txt] --work-dir [path/to/workdir] -g [group] -a restore
           Eg.: ./backup.sh --drop-caches --pf /root/bin/backup.passphrase --bdf /root/bin/backup-descriptions.txt --work-dir /home/backup_data -g [group] -a restore

        5. VERIFY a backup.
           ./backup.sh --drop-caches -c backup.cfg -g [group] -a verify

        6. CLEANUP a backup.
           ./backup.sh --drop-caches -c backup.cfg -g [group] -a cleanup

___HERE
}
