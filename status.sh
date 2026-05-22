#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
source /root/.bash_profile
cd $path
source config

chain=sophon
network=mainnet

curl -sX GET "https://monitor.sophon.xyz/nodes?operators=$OPERATOR" | jq
