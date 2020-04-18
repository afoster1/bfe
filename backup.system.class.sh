backup.system.stdout.printMessageAndValue(){
    local msg=$1
    local varName=$2
    local varValue=$(${varName})

    shift 

    if [ ${#varValue} -gt 0 ]
    then
        echo "${msg}$($@)"
    fi
}

backup.system.stdout.printValue(){
    local varName=$1
    local varValue=$(${varName})

    if [ ${#varValue} -gt 0 ]
    then
        echo "${varName}: $($@)"
    fi
}

backup.system.stdout.printString(){
    echo $@
}

backup.system.stdout.printArray(){
    local msg=$1
    shift 1
    local a b
    a=$($@)
    a="declare -a b=${a#*=}"
    eval "$a"
    local list=""
    local first=true
    for i in "${b[@]}"
    do
        if ! ${first}; then list="${list}, "; fi
        if ${first}; then first=false; fi
        list="$list$i"
    done
    echo "${msg}${list}"
}

backup.system.utils.starts_with_any_of(){
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++))
    {
        if [[ "${value}" == "${!i}"* ]]
        then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

backup.system.utils.propertyAccessor()
{
    properties="$1"
    operation="$2"
    value="$3"

    # Find the array id that matches the property being set, using the name of the property function being used.
    object_name=${properties%_*}
    name=${object_name}_$(echo "${FUNCNAME[1]}" | sed "s/.*\.\(.*\)$/\1/g") 
    eval "id=\${${name}}"

    local arrayPrefixes=( "array" )
    if [ $(backup.system.utils.starts_with_any_of "${arrayPrefixes[@]}" "${id}") == "y" ]
    then
        # This is an array.
        if [ "${operation}" == "=" ]
        then
            local a="declare -ga ${name}Array=${value#*=}"
            eval "${a}"
        else
            declare -p ${name}Array
        fi
    else
        if [ "${operation}" == "=" ]
        then
            local a="declare -g ${properties}[${name}]=${value}"
            eval "${a}"
        else
            eval "printf '%s\n' \"\${${properties}[${name}]}\""
        fi
    fi
}
