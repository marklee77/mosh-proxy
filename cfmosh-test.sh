#!/bin/bash
trap "kill 0" SIGINT SIGTERM EXIT
#read -a MOSH_INFO <<< "$(ssh -t senbazuru-01 mosh-server 2>/dev/null | grep "MOSH CONNECT")"
MOSH_PORT=60001
nc -lu 60001 | ssh -q hpclogin-1 netcat -u senbazuru-01.soe.cranfield.ac.uk ${MOSH_PORT} &
echo "everything should be set up..."
sleep 5
nc -u localhost 60001 < $0
