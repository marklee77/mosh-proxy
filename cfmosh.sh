#!/bin/bash
# FIXME: pick local port from random available instead of reusing mosh port...
TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"; kill 0' SIGINT SIGTERM EXIT
UDPFIFO="${TMPDIR}/udp"
mkfifo ${UDPFIFO}
MOSH_INFO="$(ssh -t senbazuru-01 mosh-server 2>/dev/null | grep "MOSH CONNECT")"
MOSH_PORT=$(echo ${MOSH_INFO} | cut -d" " -f 3)
MOSH_KEY=$(echo ${MOSH_INFO} | cut -d" " -f 4 | cut -c1-22) # 22 chars ONLY!
exec 3<>${UDPFIFO}
nc -lu 127.0.0.1 ${MOSH_PORT} <&3 | ssh -q hpclogin-1 netcat -u senbazuru-01.soe.cranfield.ac.uk ${MOSH_PORT} >&3 2>/dev/null &
MOSH_KEY="${MOSH_KEY}" mosh-client 127.0.0.1 ${MOSH_PORT}
