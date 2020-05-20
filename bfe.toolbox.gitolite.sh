# Tools to help action backups with a gitolite server

bfe.toolbox.gitolite.clone()
{
    local description_object_name=$1
    local descriptions=$2
    local destination_dir=$3

    local description_name=`${description_object_name}.name`
    local ssh_user_id=`${description_object_name}.sshUserId`
    local ssh_server=`${description_object_name}.sshServer`
    local ssh_port=`${description_object_name}.sshPort`

    # Validate the parameters
    if [ -z "${ssh_user_id}" ]
    then
        local ssh_user_id=git
    fi
    if [ -z "${ssh_server}" ]
    then
        bfe.toolbox.log.error "Gitolite backup description [${description_name}] has no SSH_SERVER property."
    fi
    if [ -z "${ssh_port}" ]
    then
        bfe.toolbox.log.error "Gitolite backup description [${description_name}] has no SSH_PORT property."
    fi

    # Establish a list of repositories on the gitolite server
    local repositories=()
    while IFS= read line
    do
        local perm_read=$(${ECHO_CMD} "${line}" | ${CUT_CMD} -c 2)
        local repo=$(${ECHO_CMD} "${line}" | ${CUT_CMD} -c 6- | ${SED_CMD} 's/\r//g')

        if [ "${perm_read}" = "R" ]
        then
            local repositories=("${repositories[@]}" "${repo}")
        fi
    done < <(${SSH_CMD} -T ${ssh_user_id}@${ssh_server} -p ${ssh_port} info)

    # Using the backup description data, decide the rules for including/excluding repositories
    local include_repositories=()
    local exclude_repositories=()
    local include_exposed_repositories=false
    local e="declare -a data_array=`${object_name}.data`"
    eval "$e"
    for data in ${data_array[@]}
    do
        local filter_action=$(${ECHO_CMD} "${data}" | ${CUT_CMD} -c 1)
        local repo=$(${ECHO_CMD} "${data}" | ${CUT_CMD} -c 2-)
        if [ "${filter_action}" = "+" ]
        then
            local include_repositories=("${include_repositories[@]}" "${repo}")
        else
            if [ "${filter_action}" = "-" ]
            then
                local exclude_repositories=("${exclude_repositories[@]}" "${repo}")
            else
                # Note: "!" is a special action indicating the inclusion of any
                # repositories that are not already included in any other
                # backup descriptions. ie. a catch all, to safe-guard against
                # any repositories not being included in existing backups.
                if [ "${filter_action}" = "!" ]
                then
                    local include_exposed_repositories=true
                fi
            fi
        fi
    done

    # Stage the selected repositories.
    bfe.toolbox.utils.run "${RM_CMD} -rf ${destination_dir}"
    bfe.toolbox.utils.run "${MKDIR_CMD} -p ${destination_dir}"
    for repo in ${repositories[@]};
    do
        local include=false
        local exclude=false

        if [ ${#include_repositories[@]} -gt 0 ]
        then
            if [ $(bfe.toolbox.utils.starts_with_any_of "${include_repositories[@]}" "${repo}") == "y" ]
            then
                local include=true
            else
                local exclude=true
            fi
        fi
        if [ $(bfe.toolbox.utils.starts_with_any_of "${exclude_repositories[@]}" "${repo}") == "y" ]
        then
            local exclude=true
        fi
        if [ "${include_exposed_repositories}" = true ]
        then
            if [ $(bfe.toolbox.gitolite.is_exposed_repo "${ssh_server}" "${ssh_port}" "${repo}" "${descriptions}") == "y" ]
            then
                local include=true
            fi
        fi

        if [ "${include}" = true ] || [ "${include}" = false -a "${exclude}" = false -a "${include_exposed_repositories}" = false ]
        then
            local url="ssh://${ssh_user_id}@${ssh_server}:${ssh_port}/${repo%%.git}.git"
            bfe.toolbox.git.clone "${url}" "${destination_dir}"
        fi
    done
}

bfe.toolbox.gitolite.is_exposed_repo()
{
    local ssh_server=$1
    local ssh_port=$2
    local repository=$3
    local descriptions=$4
    local include_repositories=()
    local gitolite_backup_types=('gitolite')

    # search backup descriptions for "exposed" repositories
    local num_backup_descriptions=`descriptions.names count`
    if [ "${num_backup_descriptions}" -gt 0 ]
    then
        local e="declare -a description_names=`descriptions.names [@]`"
        eval "${e}"
        # TODO This loop isn't very efficient as it creates each backup
        # description in turn to scan its data.  Consider a better approach
        # that uses a helper method from the descriptions object
        for dn in ${description_names[@]}
        do
            local type_ok=false
            local ssh_server_ok=false
            local ssh_server_port_ok=false

            descriptions.getBackupDescription d "${dn}"
            if [ $(bfe.toolbox.utils.starts_with_any_of "${gitolite_backup_types[@]}" "`d.type`") == "y" ]
            then
                local type_ok=true
            fi
            if [ -n "`d.sshServer`" ]
            then
                local ssh_server_ok=true
            fi
            if [ -n "`d.sshPort`" ]
            then
                local ssh_server_port_ok=true
            fi

            if [ "${type_ok}" = true -a "${ssh_server_ok}" = true -a "${ssh_server_port_ok}" = true ]
            then
                local e="declare -a data_array=`d.data`"
                eval "$e"
                for data in ${data_array[@]}
                do
                    local action=$(${ECHO_CMD} "${data}" | ${CUT_CMD} -c 1)
                    local data=$(${ECHO_CMD} "${data}" | ${CUT_CMD} -c 2-)
                    if [ "${action}" = "+" ]
                    then
                        local include_repositories=("${include_repositories[@]}" "${data}")
                    fi
                done
            fi
        done
    fi

    if [ $(bfe.toolbox.utils.starts_with_any_of "${include_repositories[@]}" "${repository}") == "y" ]
    then
        ${ECHO_CMD} "n"
        return 0
    fi

    # This repository does not seem to be covered by any backup description.
    ${ECHO_CMD} "y"
    return 1
}
