# Define all the types defined by the backup app

backup.obj(){
    . <(sed "s/backup.obj/$1/g" backup.obj.class.sh)
}

. backup.system.class.sh
