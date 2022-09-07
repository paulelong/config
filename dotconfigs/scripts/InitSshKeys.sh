#!/bin/bash

# Start the SSH agent (not needed if desktop environment starts it)

SSH_ENV="$HOME/.ssh/agent"
function start_agent {
    MASK=$(umask)
    umask 0077
    /usr/bin/ssh-agent |sed 's/^echo/#echo/' >"${SSH_ENV}"
    umask $MASK
    . "${SSH_ENV}" >/dev/null
}
if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" >/dev/null
    ps -ef |grep ${SSH_AGENT_PID} |grep ssh-agent$ >/dev/null || { start_agent; }
    # start if agent file exists but is stale
else
    start_agent;
    # start if agent file doesn't exist
fi

# Add keys (replace `key1 key2 keyN` with your actual keys)

ssh_keys=$(ssh-add -l)
for i in id_rsa id_rsa_github; do
    fp="$(ssh-keygen -lf "$HOME/.ssh/$i")"
    if ! echo "$ssh_keys" |grep -F "$fp" >/dev/null; then ssh-add "$HOME/.ssh/$i"; fi
done

# Print keys (optional)

ssh_keys=$(ssh-add -l)
if ! echo "$ssh_keys" |grep -F 'The agent has no identities' >/dev/null; then
    echo "\n\x1b[38;2;44;44;44m$(echo $ssh_keys |sed 's/^/* \`/' |sed 's/$/\`/')\x1b[0m"
fi
