#!/bin/bash

action="$1"
addr="$2"

# the server wan interface ens3, eth0... will be inserted by add_ipv6 script.
pubif="__server_wan_interface"


echo setting up ndp proxy action: $action addr: $addr pubif: $pubif

if [[ "${addr//:/}" == "$addr" ]]
then
    # not an ipv6 address
    exit
fi

case "$action" in
    add)
	echo  ip -6 neigh add proxy ${addr} dev ${pubif}
        ip -6 neigh add proxy ${addr} dev ${pubif}
        ;;
    update)
        ip -6 neigh replace proxy ${addr} dev ${pubif}
        ;;
    delete)
        ip -6 neigh del proxy ${addr} dev ${pubif}
        ;;
esac
