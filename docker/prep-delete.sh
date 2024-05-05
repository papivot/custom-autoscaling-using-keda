#!/bin/bash
export tempvar=$(hostname|awk -F '-' '{print $NF}')
for f in /host-install-files/*.yaml
do 
    /usr/bin/envsubst < "$f" | kubectl delete -f - 
done