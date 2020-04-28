# Class "bfe.arguments" responsible for reading the command line.

# property
bfe.arguments_properties=()

# properties IDs
bfe.arguments_configFilename=0
bfe.arguments_passphraseFilename=1
bfe.arguments_passphrase=2
bfe.arguments_emailPasswordFilename=3
bfe.arguments_emailPassword=4
bfe.arguments_backupDescriptionFilename=5
bfe.arguments_sendEmail=6
bfe.arguments_emailFrom=7
bfe.arguments_hostname=8
bfe.arguments_backupMedium=9
bfe.arguments_backupMediumLabel=10
bfe.arguments_workDir=11
bfe.arguments_backupMediumDir=12
bfe.arguments_stageSubDir=13
bfe.arguments_backupSubDir=14
bfe.arguments_restoreSubDir=15
bfe.arguments_logSubDir=16
bfe.arguments_backupName=17
bfe.arguments_actions=array18
bfe.arguments_backupGroups=array19
bfe.arguments_fullBackup=20
bfe.arguments_useLog=21
bfe.arguments_dryRun=22
bfe.arguments_certificateDatabase=23
bfe.arguments_verbose=24
bfe.arguments_auditFilelistFilename=25
bfe.arguments_auditHashesFilename=26

bfe.arguments_actionsArray=()
bfe.arguments_backupGroupsArray=()

bfe.arguments.configFilename() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.passphraseFilename() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.passphrase() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.emailPasswordFilename() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.emailPassword() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.backupDescriptionFilename() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.sendEmail() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.emailFrom() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.hostname() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.backupMedium() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.backupMediumLabel() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.workDir() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.backupMediumDir() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.stageSubDir() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.backupSubDir() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.restoreSubDir() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.logSubDir() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.backupName() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.actions() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.backupGroups() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.fullBackup() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
} 
bfe.arguments.useLog() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.dryRun() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.certificateDatabase() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.verbose() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.auditFilelistFilename() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}
bfe.arguments.auditHashesFilename() { bfe.system.utils.propertyAccessor bfe.arguments_properties $1 $2
}

bfe.arguments.init()
{
    bfe.arguments.dryRun = false
    bfe.arguments.useLog = false
    bfe.arguments.fullBackup = false
    bfe.arguments.sendEmail = false
}

bfe.arguments.parse()
{
    ARGS="$@"

    while getopts ":a:g:h:c:efvln:-:" option ${ARGS}
    do
      case $option in
        -)
            case ${OPTARG} in
                config-file)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments.configFilename = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                pf|passphrase-file)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments.passphraseFilename = ${!OPTIND}
                        bfe.arguments.passphrase = `cat $(bfe.arguments.passphraseFilename)`
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                epf|email-password-file)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments.emailPasswordFilename = ${!OPTIND}
                        bfe.arguments.emailPassword = `cat $(bfe.arguments.emailPasswordFilename)`
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                bdf|backup-description-file)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments.backupDescriptionFilename = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                send-email)
                    bfe.arguments.sendEmail = true
                    ;;
                email-from)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments.emailFrom = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                hostname)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments.hostname = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                bm|backup-medium)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments.backupMedium = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                bml|backup-medium-label)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments.backupMediumLabel = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                work-dir)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments.workDir = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                bmd|backup-medium-dir)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments.backupMediumDir = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                stage-subdir)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments.stageSubDir = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                backup-subdir)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments.backupSubDir = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                restore-subdir)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments.restoreSubDir = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                log-subdir)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments.logSubDir = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                name)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments.backupName = ${!OPTIND}
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                action)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments_actionsArray=("${bfe.arguments_actionsArray[@]}" "${!OPTIND}")
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                group)
                    if [ ! -z "${!OPTIND:0:1}" -a ! "${!OPTIND:0:1}" = "-" ]; then
                        bfe.arguments_backupGroupsArray=("${bfe.arguments_backupGroupsArray[@]}" "${!OPTIND}")
                        OPTIND=$(( ${OPTIND} + 1 ))
                    fi
                    ;;
                full-backup)
                    bfe.arguments.fullBackup = true
                    ;;
                log)
                    bfe.arguments.useLog = true
                    ;;
                dry-run)
                    bfe.arguments.dryRun = true
                    ;;
                verbose)
                    bfe.arguments.verbose = true
                    ;;
            esac
            ;;

        c) bfe.arguments.configFilename = ${OPTARG};;
        a) bfe.arguments_actionsArray=("${bfe.arguments_actionsArray[@]}" "${OPTARG}");;
        g) bfe.arguments_backupGroupsArray=("${bfe.arguments_backupGroupsArray[@]}" "${OPTARG}");;
        h) bfe.arguments.hostname = ${OPTARG};;
        n) bfe.arguments.backupName = ${OPTARG};;
        f) bfe.arguments.fullBackup = true;;
        e) bfe.arguments.sendEmail = true;;
        l) bfe.arguments.useLog = true;;
        v) bfe.arguments.verbose = true;;

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
        bfe.arguments.showUsage
        exit 1
    fi

    bfe.arguments.setDefaults
}

bfe.arguments.setDefaults()
{
    if [ -z "`bfe.arguments.hostname`" ]
    then
        bfe.arguments.hostname = `${HOSTNAME_CMD}`
    fi

    if [ -z "`bfe.arguments.configFilename`" ]
    then
        if [ -z "`bfe.arguments.workDir`" ]
        then
            bfe.arguments.configFilename = "backup.cfg"
        else
            bfe.arguments.configFilename = "`bfe.arguments.workDir`/backup.cfg"
        fi
    fi

    bfe.arguments.readConfigurationFile

    if [ -z "`bfe.arguments.workDir`" ]
    then
        bfe.arguments.workDir = `bfe.system.utils.getWorkingDirectory`
    fi


    if [ -z "`bfe.arguments.backupDescriptionFilename`" ]
    then
        bfe.arguments.backupDescriptionFilename = "`bfe.arguments.workDir`/backup-descriptions.txt"
    fi

    if [ -z "`bfe.arguments.stageSubDir`" ]
    then
        bfe.arguments.stageSubDir = stage
    fi

    if [ -z "`bfe.arguments.backupSubDir`" ]
    then
        bfe.arguments.backupSubDir = backup
    fi

    if [ -z "`bfe.arguments.restoreSubDir`" ]
    then
        bfe.arguments.restoreSubDir = restore
    fi

    if [ -z "`bfe.arguments.logSubDir`" ]
    then
        bfe.arguments.logSubDir = log
    fi

    if [ -z "`bfe.arguments.backupMediumDir`" ]
    then
        bfe.arguments.backupMediumDir = /media
    fi

    if [ ${#bfe.arguments_actionsArray[@]} -eq 0 ]
    then
        bfe.arguments.actions += default
    fi

    bfe.arguments.auditFilelistFilename = "audit_filelist.txt"
    bfe.arguments.auditHashesFilename = "audit_hashes.txt"
}

bfe.arguments.readConfigurationFile()
{
    local filename=`bfe.arguments.configFilename`

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
                    bfe.arguments.workDir = ${value}
                fi

                if [ "${name}" = "EMAIL_PASSWORD" ]
                then
                    bfe.arguments.emailPassword = ${value}
                fi

                if [ "${name}" = "PASSPHRASE" ]
                then
                    bfe.arguments.passphrase = ${value}
                fi

                if [ "${name}" = "EMAIL_FROM" ]
                then
                    bfe.arguments.emailFrom = ${value}
                fi

                if [ "${name}" = "BACKUP_DESCRIPTION_FILENAME" ]
                then
                    bfe.arguments.backupDescriptionFilename = ${value}
                fi

                if [ "${name}" = "CERTIFICATE_DATABASE" ]
                then
                    bfe.arguments.certificateDatabase = ${value}
                fi
            fi
        done < ${filename}
    fi
}

bfe.arguments.print()
{
    bfe.system.stdout.printMessageAndValue "Backup Name: " bfe.arguments.backupName
    bfe.system.stdout.printMessageAndValue "Configuration Filename: " bfe.arguments.configFilename
    bfe.system.stdout.printMessageAndValue "Passphrase Filename: " bfe.arguments.passphraseFilename
    bfe.system.stdout.printArray "Backup Groups: " bfe.arguments.backupGroups
    bfe.system.stdout.printArray "Backup Actions: " bfe.arguments.actions

    v=`bfe.arguments.verbose`
    if [ "${v}" = true ]
    then
        bfe.system.stdout.printValueObscured bfe.arguments.passphrase
        bfe.system.stdout.printValue bfe.arguments.emailPasswordFilename
        bfe.system.stdout.printValueObscured bfe.arguments.emailPassword
        bfe.system.stdout.printValue bfe.arguments.backupDescriptionFilename
        bfe.system.stdout.printValue bfe.arguments.sendEmail
        bfe.system.stdout.printValue bfe.arguments.emailFrom
        bfe.system.stdout.printValue bfe.arguments.hostname
        bfe.system.stdout.printValue bfe.arguments.backupMedium
        bfe.system.stdout.printValue bfe.arguments.backupMediumLabel
        bfe.system.stdout.printValue bfe.arguments.workDir
        bfe.system.stdout.printValue bfe.arguments.backupMediumDir
        bfe.system.stdout.printValue bfe.arguments.stageSubDir
        bfe.system.stdout.printValue bfe.arguments.backupSubDir
        bfe.system.stdout.printValue bfe.arguments.restoreSubDir
        bfe.system.stdout.printValue bfe.arguments.logSubDir
        bfe.system.stdout.printValue bfe.arguments.fullBackup
        bfe.system.stdout.printValue bfe.arguments.useLog
        bfe.system.stdout.printValue bfe.arguments.dryRun
        bfe.system.stdout.printValue bfe.arguments.certificateDatabase
    fi
}

bfe.arguments.showUsage()
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
               -v|--verbose
               --drop-caches
               --dry-run

    Examples:

        1. List the backup STATUS.
           ./bfe.sh -c backup.cfg -g [group] -a status
           Or: ./bfe.sh --drop-caches --bdf [path/to/backup-descriptions.txt] -g [group] -a status
           Eg.: ./bfe.sh --drop-caches --bdf /root/bin/backup-descriptions.txt -g [group] -a status

        2. Perform a COMPLETE BACKUP (ie. stage, backup, restore, verify, cleanup).
           ./bfe.sh --drop-caches -c backup.cfg -g [group]
           Or: ./bfe.sh --drop-caches --pf [/path/to/backup.passphrase] --bdf [path/to/backup-descriptions.txt] --work-dir [path/to/workdir] -g [group]
           Eg.: ./bfe.sh --drop-caches --pf /root/bin/backup.passphrase --bdf /root/bin/backup-descriptions.txt --work-dir /home/backup_data -g [group]

        3. Perform a FULL BACKUP (ie. not incremental).
           ./bfe.sh --drop-caches -c backup.cfg -g [group] -f
           Or: ./bfe.sh --drop-caches --pf [/path/to/backup.passphrase] --bdf [path/to/backup-descriptions.txt] --work-dir [path/to/workdir] -g [group] -f
           Eg.: ./bfe.sh --drop-caches --pf /root/bin/backup.passphrase --bdf /root/bin/backup-descriptions.txt --work-dir /home/backup_data -g [group] -f

        4. RESTORE a backup.
           ./bfe.sh --drop-caches -c backup.cfg -g [group] -a restore
           Or: ./bfe.sh --drop-caches --pf [/path/to/backup.passphrase] --bdf [path/to/backup-descriptions.txt] --work-dir [path/to/workdir] -g [group] -a restore
           Eg.: ./bfe.sh --drop-caches --pf /root/bin/backup.passphrase --bdf /root/bin/backup-descriptions.txt --work-dir /home/backup_data -g [group] -a restore

        5. VERIFY a backup.
           ./bfe.sh --drop-caches -c backup.cfg -g [group] -a verify

        6. CLEANUP a backup.
           ./bfe.sh --drop-caches -c backup.cfg -g [group] -a cleanup

___HERE
}
