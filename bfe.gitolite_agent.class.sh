# Class named "bfe.gitolite_agent"

bfe.gitolite_agent=true

# collection of property values
bfe.gitolite_agent=()

# properties IDs
bfe.gitolite_agent_descriptionName=0

# fields
bfe.gitolite_agent_args_= # Command line arguments

bfe.gitolite_agent.init(){
    bfe.gitolite_agent_args_=$1

    bfe.gitolite_agent.descriptionName = $2
    bfe.gitolite_agent=true
}

bfe.gitolite_agent.descriptionName() { bfe.system.utils.propertyAccessor bfe.gitolite_agent_properties $1 $2
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

    echo "gitolie_agent"
    echo "include_repositories [${include_repositories[@]}]"
    echo "exclude_repositories [${exclude_repositories[@]}]"
    echo "exclude_exposed_repositories [${exclude_exposed_repositories}]"


    # TODO ANFO
    # Stage the selected repositories.
    # local destination_dir="${work_dir}/${stage_sub_dir}/${description_name}"
    # run "${RM_CMD} -rf ${destination_dir}"
    # run "${MKDIR_CMD} -p ${destination_dir}"
    # for repo in ${repositories[@]};
    # do
    #     local include=false
    #     local exclude=false
    #
    #     if [ ${#include_repositories[@]} -gt 0 ]
    #     then
    #         if [ $(bfe.system.utils.starts_with_any_of "${include_repositories[@]}" "${repo}") == "y" ]
    #         then
    #             local include=true
    #         else
    #             local exclude=true
    #         fi
    #     fi
    #     if [ $(bfe.system.starts_with_any_of "${exclude_repositories[@]}" "${repo}") == "y" ]
    #     then
    #         local exclude=true
    #     fi
    #     if [ "${include_exposed_repositories}" = true ]
    #     then
    #         if [ $(bfe.gitolite_agent.is_exposed_gitolite_repo "${ssh_server}" "${ssh_port}" "${repo}") == "y" ] # TODO ANFO
    #         then
    #             local include=true
    #         fi
    #     fi
    #
    #     if [ "${include}" = true ] || [ "${include}" = false -a "${exclude}" = false -a "${include_exposed_repositories}" = false ]
    #     then
    #         local url="ssh://${ssh_user_id}@${ssh_server}:${ssh_port}/${repo%%.git}.git"
    #         do_git_clone "${url}" "${DEST}" # TODO ANFO
    #     fi
    # done
}

# TODO ANFO Need to iterate over all the backup descriptions, so needs access to the descriptions...
# bfe.gitolite_agent.is_exposed_gitolite_repo()
# {
#     local ssh_server=$1
#     local ssh_port=$2
#     local repository=$3
#     local include_repositories=()
#
#     for group in ${read_backup_description_NAMES[@]} # List of description names...
#     do
#         backup_type_ok=false
#         ssh_server_ok=false
#         ssh_server_port_ok=false
#
#         # Check the properties of the backup group
#         properties_array_name=read_backup_description_${group}_PROPERTIES[@]
#         eval "properties_array_indexes=\${!${properties_array_name}}"
#
#         # ...TYPE
#         if [ $(contains ${properties_array_indexes[@]} "TYPE") == "y" ]
#         then
#             property_name=read_backup_description_${group}_PROPERTIES[TYPE]
#             eval "property_value=\${${property_name}}"
#             if [ "${property_value}" = "gitolite" ]
#             then
#                 backup_type_ok=true
#             fi
#         fi
#         # ...SSH_SERVER
#         if [ $(contains ${properties_array_indexes[@]} "SSH_SERVER") == "y" ]
#         then
#             property_name=read_backup_description_${group}_PROPERTIES[SSH_SERVER]
#             eval "property_value=\${${property_name}}"
#             if [ "${property_value}" = "${ssh_server}" ]
#             then
#                 ssh_server_ok=true
#             fi
#         fi
#         # ...SSH_PORT
#         if [ $(contains ${properties_array_indexes[@]} "SSH_PORT") == "y" ]
#         then
#             property_name=read_backup_description_${group}_PROPERTIES[SSH_PORT]
#             eval "property_value=\${${property_name}}"
#             if [ "${property_value}" == "${ssh_port}" ]
#             then
#                 ssh_server_port_ok=true
#             fi
#         fi
#
#         if [ "${backup_type_ok}" = true -a "${ssh_server_ok}" = true -a "${ssh_server_port_ok}" = true ]
#         then
#             data_array_name=read_backup_description_${group}_DATA[@]
#             eval "data_array_indexes=\${!${data_array_name}}"
#             for index in ${data_array_indexes}
#             do
#                 data_name=read_backup_description_${group}_DATA[${index}]
#                 eval "data_value=\${${data_name}}"
#
#                 action=$(${ECHO_CMD} "${data_value}" | ${CUT_CMD} -c 1)
#                 data=$(${ECHO_CMD} "${data_value}" | ${CUT_CMD} -c 2-)
#                 if [ "${action}" = "+" ]
#                 then
#                     include_repositories=("${include_repositories[@]}" "${data}")
#                 fi
#             done
#         fi
#     done
#
#     if [ $(starts_with_any_of "${include_repositories[@]}" "${repository}") == "y" ]
#     then
#         ${ECHO_CMD} "n"
#         return 0
#     fi
#
#     # This repository does not seem to be covered by any backup description.
#     ${ECHO_CMD} "y"
#     return 1
# }
