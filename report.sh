#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=/root/logs/report-$folder
source /root/.bash_profile
cd $path
source config

chain=sophon
network=mainnet

container=$(docker ps | grep $folder | awk '{print $NF}')
[ $container ] && docker_status=$(docker inspect $container | jq -r .[].State.Status)
#version=$(docker logs sophon-light-1 | grep "version:" | tail -1 | awk '{print $NF}')
version=$VERSION
status_json=$(curl -sX GET "https://monitor.sophon.xyz/nodes?operators=$OPERATOR" | jq )
operator=$(echo $status_json | jq -r .nodes[].operator) 
node_status=$(echo $status_json | jq -r .nodes[].status)
rewards=$(echo $status_json | jq -r .nodes[].rewards)
fee=$(echo $status_json | jq -r .nodes[].fee)%
uptime=$(echo $status_json | jq -r .nodes[].uptime | cut -d . -f 1 )%

case $docker_status in
  running) status=ok; message="uptime=$uptime rewards=$rewards" ;;
  restarting) status=warning; message="docker is restarting" ;;
  *) status="error"; message="docker not running" ;;
esac

cat >$json << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
   "id":"$folder",
   "machine":"$MACHINE",
   "grp":"node",
   "owner":"$OWNER"
  },
  "fields": {
   "network":"$network",
   "chain":"$chain",
   "status":"$status",
   "message":"$message",
   "operator":"$operator",
   "node_status":"$node_status",
   "rewards":"$rewards",
   "fee":"$fee",
   "uptime":"$uptime",
   "version":"$version"
  }
}
EOF

cat $json | jq


