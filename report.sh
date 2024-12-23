#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=~/logs/report-$folder
source ~/.bash_profile

chain=?
network=mainnet
tail=100000

cd ~/$folder/verifier

container=$(docker ps | grep $folder | awk '{print $NF}')
[ $container ] && docker_status=$(docker inspect $container | jq -r .[].State.Status)
#last_challenge=$(docker logs --tail $tail $container | grep -a "challenged secret, tx hash:" | awk '{print $1}' | tail -1 | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g")
#[ -z $last_challenge ] && last_challenge_h=never || last_challenge_h="$(( ( $(date +%s) - $(date -d $last_challenge +%s) ) / ( 60*60 )))h"
#local_height=$(docker logs --tail $tail $container | grep -a "Processed block" | tail -1 | awk -F 'Processed block' '{print $NF}' | awk '{print $1}' | sed 's/://g' )
#sent=$(docker logs --tail $tail $container | grep -a "Challenges sent to Nilchain" | tail -1 | awk '{print $NF}')
#url=$(docker ps -a --no-trunc | grep $folder | awk -F '--rpc-endpoint' '{print $2}' | awk '{print $1}' | sed 's/\"//g')
#version=$(docker ps -a --no-trunc | grep $folder | awk -F 'verifier:' '{print $2}' | awk '{print $1}')
#verifier_add=$(docker logs --tail $tail $container | grep -a "Verifier account id:" | tail -1 | awk '{print $NF}')
#registered_to=$(docker logs --tail $tail $container | grep -a "Verifier registered to:" | tail -1 | awk '{print $NF}')
#no_gas=$(docker logs --tail 100 $container | grep -a "insufficient funds" | tail -1 | awk -F 'insufficient funds: ' '{print $NF}')

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
   "version":"$version"
  }
}
EOF

cat $json | jq


