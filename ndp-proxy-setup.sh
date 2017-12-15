#!/bin/bash

action="$1"
addr="$2"
pubif="<server wan interface>"

if [[ "${addr//:/}" == "$addr" ]]
then
    # not an ipv6 address
    exit
fi

case "$action" in
    add)
        ip -6 neigh add proxy ${addr} dev ${pubif}
        ;;
    update)
        ip -6 neigh replace proxy ${addr} dev ${pubif}
        ;;
    delete)
        ip -6 neigh del proxy ${addr} dev ${pubif}
        ;;
esac
