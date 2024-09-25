#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=~/logs/report-$folder
source ~/.bash_profile

chain=nillion-chain-testnet-1
network=testnet
tail=100000

cd ~/$folder/verifier

container=$(docker ps | grep $folder | awk '{print $NF}')
[ $container ] && docker_status=$(docker inspect $container | jq -r .[].State.Status)
last_challenge=$(docker logs --tail $tail $container | grep -a "Challenge sent to Nilchain" | awk '{print $1}' | tail -1 | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g")
[ -z $last_challenge ] && last_challenge_sec=never || last_challenge_sec="$(( $(date +%s) - $(date -d $last_challenge +%s) ))s"
local_height=$(docker logs --tail $tail $container | grep -a "Sent block @ height" | tail -1 | awk '{print $NF}')
is_accusing=$(docker logs --tail $tail $container | grep accusing | tail -1 | grep -c "Accuser IS accusing")
verifying=$(docker logs --tail $tail $container | grep "Verifying" | tail -1 | grep -c "Verifying: true")
sent=$(docker logs --tail $tail $container | grep -a "Challenges sent to Nilchain" | tail -1 | awk '{print $NF}')
#url=$(ps aux | grep nillion | grep -v grep | awk -F '--rpc-endpoint ' '{print $2}' | awk '{print $1}')
version=$(docker ps -a --no-trunc | grep $folder | awk -F 'verifier:' '{print $2}' | awk '{print $1}')

case $docker_status$verifying in
  running1) status=ok; message="last=$last_challenge, sent=$sent" ;;
  running0) status=warning; message="not verifying, sent=$sent" ;;
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
   "docker_status":"$docker_status",
   "local_height":"$local_height",
   "last_challenge_sec":"$last_challenge_sec",
   "sent":"$sent",
   "is_accusing":"$is_accusing",
   "verifying":"$verifying",
   "registered":"$registered",
   "url":"$url",
   "version":"$version"
  }
}
EOF

cat $json

# send data to influxdb
tag_count=$(cat $json | jq '.tags | length')
field_count=$(cat $json | jq '.fields | length')

data=$(cat $json | jq -r '.measurement')","

for (( i=0; i<$tag_count; i++ ))
do
 key=$(cat $json | jq .tags | jq -r keys[$i])
 value=$(cat $json | jq .tags | jq -r --arg a $key '.[$a]')
 data=$data$key"="$value
 [ $i -lt $(( tag_count - 1 )) ] && data=$data"," || data=$data" "
done

for (( i=0; i<$field_count; i++ ))
do
 key=$(cat $json | jq .fields | jq -r keys[$i])
 value=$(cat $json | jq .fields | jq -r --arg a $key '.[$a]')
 data=$data$key"=\""$value"\""
 [ $i -lt $(( field_count - 1 )) ] && data=$data"," || data=$data" "$(date +%s%N)
done

if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "$data"
fi
