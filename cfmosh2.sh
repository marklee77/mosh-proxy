#!/bin/bash
# FIXME: pick local port from random available instead of reusing mosh port...
SSH_HOST=$1
TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"; kill 0' SIGINT SIGTERM EXIT
MOSH_INFO=$(ssh -t ${SSH_HOST} '
    MOSH_INFO="$(mosh-server new -i 127.0.0.1 2>/dev/null | grep "MOSH CONNECT")"
    MOSH_PORT=$(echo ${MOSH_INFO} | cut -d" " -f 3)
    MOSH_KEY=$(echo ${MOSH_INFO} | cut -d" " -f 4 | cut -c1-22) # 22 chars ONLY!
    TCP_PORT=8888
    socat tcp4-listen:${TCP_PORT},bind=127.0.0.1 udp4:127.0.0.1:${MOSH_PORT} &
    echo "MOSHT CONNECT ${TCP_PORT} ${MOSH_KEY}"
' 2>/dev/null)
REMOTE_TCP_PORT=$(echo ${MOSH_INFO} | cut -d" " -f 3)
MOSH_KEY=$(echo ${MOSH_INFO} | cut -d" " -f 4 | cut -c1-22) # 22 chars ONLY!
LOCAL_UDP_PORT=60001
LOCAL_TCP_PORT=8888
ssh -L ${LOCAL_TCP_PORT}:localhost:${REMOTE_TCP_PORT} ${SSH_HOST} -f -N
socat udp4-listen:${LOCAL_UDP_PORT},bind=127.0.0.1 tcp4:127.0.0.1:${LOCAL_TCP_PORT},forever &
MOSH_KEY="${MOSH_KEY}" mosh-client 127.0.0.1 ${LOCAL_UDP_PORT}
