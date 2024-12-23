#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=/root/logs/report-$folder
source /root/.bash_profile

chain=?
network=mainnet

container=$(docker ps | grep $folder | awk '{print $NF}')
[ $container ] && docker_status=$(docker inspect $container | jq -r .[].State.Status)
status_json=$(curl -X GET "https://monitor.sophon.xyz/nodes?operators=$OPERATOR")
operator=$(echo $status_json | jq -r .nodes[].operator)
node_status=$(echo $status_json | jq -r .nodes[].status)
rewards=$(echo $status_json | jq -r .nodes[].rewards)
fee=$(echo $status_json | jq -r .nodes[].fee)
uptime=$(echo $status_json | jq -r .nodes[].uptime)

case $docker_status in
  running) status=ok; message="." ;;
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


