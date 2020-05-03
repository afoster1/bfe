# Class named "bfe.gitolite_agent"

bfe.gitolite_agent=true

# collection of property values
bfe.gitolite_agent=()

# properties IDs
bfe.gitolite_agent_descriptionName=0
bfe.gitolite_agent_descriptions=1

# fields
bfe.gitolite_agent_args_= # Command line arguments

bfe.gitolite_agent.init(){
    bfe.gitolite_agent_args_=$1
    bfe.gitolite_agent.descriptionName = $2
    bfe.gitolite_agent.descriptions = $3
    bfe.gitolite_agent=true
}

bfe.gitolite_agent.descriptionName() { bfe.system.utils.propertyAccessor bfe.gitolite_agent_properties $1 $2
}
bfe.gitolite_agent.descriptions() { bfe.system.utils.propertyAccessor bfe.gitolite_agent_properties $1 $2
}

bfe.gitolite_agent.stage()
{
    local object_name=`bfe.gitolite_agent.descriptionName`
    local description_name=`${object_name}.name`
    local ssh_user_id=`${object_name}.sshUserId`
    local ssh_server=`${object_name}.sshServer`
    local ssh_port=`${object_name}.sshPort`
    local work_dir=`${bfe.gitolite_agent_args_}.workDir`
    local stage_sub_dir=`${bfe.gitolite_agent_args_}.stageSubDir`

    # Validate the parameters
    if [ -z "${ssh_user_id}" ]
    then
        local ssh_user_id=git
    fi
    if [ -z "${ssh_server}" ]
    then
        bfe.system.log.error "Gitolite backup description [${description_name}] has no SSH_SERVER property."
    fi
    if [ -z "${ssh_port}" ]
    then
        bfe.system.log.error "Gitolite backup description [${description_name}] has no SSH_PORT property."
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
    local destination_dir="${work_dir}/${stage_sub_dir}/${description_name}"
    bfe.system.utils.run "${RM_CMD} -rf ${destination_dir}"
    bfe.system.utils.run "${MKDIR_CMD} -p ${destination_dir}"
    for repo in ${repositories[@]};
    do
        local include=false
        local exclude=false

        if [ ${#include_repositories[@]} -gt 0 ]
        then
            if [ $(bfe.system.utils.starts_with_any_of "${include_repositories[@]}" "${repo}") == "y" ]
            then
                local include=true
            else
                local exclude=true
            fi
        fi
        if [ $(bfe.system.utils.starts_with_any_of "${exclude_repositories[@]}" "${repo}") == "y" ]
        then
            local exclude=true
        fi
        if [ "${include_exposed_repositories}" = true ]
        then
            if [ $(bfe.gitolite_agent.is_exposed_gitolite_repo "${ssh_server}" "${ssh_port}" "${repo}" "${descriptions}") == "y" ]
            then
                local include=true
            fi
        fi

        if [ "${include}" = true ] || [ "${include}" = false -a "${exclude}" = false -a "${include_exposed_repositories}" = false ]
        then
            local url="ssh://${ssh_user_id}@${ssh_server}:${ssh_port}/${repo%%.git}.git"
            bfe.gitolite_agent.do_git_clone "${url}" "${destination_dir}"
        fi
    done
}

bfe.gitolite_agent.do_git_clone()
{
    local url=$1
    local destination_dir=$2

    # Determine the name of the repository
    local repo_name=${url##file://*/}
    local repo_name=${repo_name##http://*/}
    local repo_name=${repo_name##https://*/}
    local repo_name=${repo_name##ssh://*/}
    local repo_name=${repo_name%%.git}
    if [ -z "${repo_name}" ]
    then
        bfe.system.log.error "Unable to establish the repository name from url \"${url}\""
    fi

    # Show clone details.
    bfe.system.log.info ",--[ ${repo_name} ]"
    bfe.system.log.info "| URL : ${url}"
    bfe.system.log.info "| Folder : ${destination_dir}/${repo_name}"
    bfe.system.log.info "\`--"

    # Before we begin, ensure we are in the correct directory and that the git
    # clone directory doesn't already exist.
    bfe.system.utils.run "${MKDIR_CMD} -p ${destination_dir}"
    bfe.system.utils.run "pushd ${destination_dir}"
    bfe.system.utils.run "${RM_CMD} -rf \"./${repo_name}\""

    # Clone the repos and go into the folder
    bfe.system.utils.run "${GIT_CMD} clone ${url} ${repo_name}"
    bfe.system.utils.run "cd ${repo_name}"

    # Pull all branches
    bfe.system.utils.run "${GIT_CMD} branch -r | ${GREP_CMD} -v HEAD | ${GREP_CMD} -v master | while read branch; do ${GIT_CMD} branch --track \${branch#*/} \$branch; done"

    # Pull all remote data and tags
    bfe.system.utils.run "${GIT_CMD} fetch --all"
    bfe.system.utils.run "${GIT_CMD} fetch --tags"
    bfe.system.utils.run_noerror "${GIT_CMD} pull --all" # This can fail if an empty repository is cloned.
    bfe.system.utils.run "${GIT_CMD} gc" # Cleanup unnecessary files and optimize the local repository
    bfe.system.utils.run "${GIT_CMD} fsck --full" # Verify clone

    # Restore the original working directory
    bfe.system.utils.run "popd"
}

bfe.gitolite_agent.is_exposed_gitolite_repo()
{
    local ssh_server=$1
    local ssh_port=$2
    local repository=$3
    local descriptions=$4
    local include_repositories=()

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
            if [ "`d.type`" == "gitolite" ]
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

    if [ $(bfe.system.utils.starts_with_any_of "${include_repositories[@]}" "${repository}") == "y" ]
    then
        ${ECHO_CMD} "n"
        return 0
    fi

    # This repository does not seem to be covered by any backup description.
    ${ECHO_CMD} "y"
    return 1
}
