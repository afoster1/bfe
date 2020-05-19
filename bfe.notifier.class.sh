# Class "bfe.notifier" to handle notification of backup status, ie. via email.

bfe.notifier_msgs_=()

# fields
bfe.notifier_args_= # Command line arguments

bfe.notifier.init(){
    bfe.notifier_args_=$1
}

bfe.notifier.append()
{
    bfe.notifier_msgs_=("${bfe.notifier_msgs_[@]}" "${1}")
}

bfe.notifier.notify()
{
    local hostname=`${bfe.notifier_args_}.hostname`
    bfe.notifier.doNotify "Re: ${hostname} :)" 
}

bfe.notifier.notifyError()
{
    local hostname=`${bfe.notifier_args_}.hostname`
    bfe.notifier.doNotify "Re: ${hostname} :(" 
}

bfe.notifier.doNotify()
{
    local subject=$1
    local email_from=`${bfe.notifier_args_}.emailFrom`
    
    local notify_msg=
    for msg in "${bfe.notifier_msgs_[@]}"
    do
        local notify_msg="${notify_msg}
${msg}"
    done

    bfe.toolbox.utils.sendEmail "${email_from}" "${subject}" "${notify_msg}"
}
