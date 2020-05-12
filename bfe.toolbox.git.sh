# Tools to help action backups with a git server

bfe.toolbox.git.clone()
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

bfe.toolbox.git.mirror()
{
    local url=$1
    local dest=$2

    # Determine the name of the repository
    local repo_name=${url%%/}
    local repo_name=${repo_name##file://*/}
    local repo_name=${repo_name##http://*/}
    local repo_name=${repo_name##https://*/}
    local repo_name=${repo_name##ssh://*/}
    local repo_name=${repo_name%%.git}
    if [ -z "${repo_name}" ]
    then
        bfe.system.log.error "Unable to determine the repository name from url \"${url}\""
    fi

    # Show clone details.
    bfe.system.log.info ",--[ ${repo_name} ]"
    bfe.system.log.info "| URL : ${url}"
    bfe.system.log.info "| Folder : ${dest}/${repo_name}"
    bfe.system.log.info "\`--"

    # Before we begin, ensure we are in the correct directory and that the git
    # clone directory doesn't already exist.
    bfe.system.utils.run "${MKDIR_CMD} -p ${dest}"
    bfe.system.utils.run "pushd ${dest}"
    bfe.system.utils.run "${RM_CMD} -rf \"./${repo_name}\""

    # Mirror the repo
    bfe.system.utils.run "${GIT_CMD} clone --mirror ${url} ${repo_name}"

    # Cleanup
    bfe.system.utils.run "cd ${repo_name}"
    bfe.system.utils.run "${GIT_CMD} gc" # Cleanup unnecessary files and optimize the local repository
    bfe.system.utils.run "${GIT_CMD} fsck --full" # Verify clone

    # Restore the original working directory
    bfe.system.utils.run "popd"
}
