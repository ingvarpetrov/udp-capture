#!/bin/bash
set -e

USER_ID=${USER_ID:-1000}
GROUP_ID=${GROUP_ID:-1000}

if ! getent group $GROUP_ID >/dev/null; then
    groupadd -g $GROUP_ID hostgroup
fi

if ! getent passwd $USER_ID >/dev/null; then
    useradd -u $USER_ID -g $GROUP_ID -m hostuser
fi

export HOME=/home/hostuser

exec gosu $USER_ID:$GROUP_ID "$@" 