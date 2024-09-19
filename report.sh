#!/bin/bash

source ~/.bash_profile
path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
json=~/logs/$folder-report

chain=nillion-chain-testnet-1
network=testnet
tail=100000

cd ~/$folder/accuser

container=$(docker ps | grep $folder | awk '{print $NF}')
[ $container ] && docker_status=$(docker inspect $container | jq -r .[].State.Status)
last_challenge=$(docker logs --tail $tail $container | grep -a "Challenges sent to chain" | awk '{print $1}' | tail -1 | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g")
[ -z $last_challenge ] && last_challenge_sec=never || last_challenge_sec="$(( $(date +%s) - $(date -d $last_challenge +%s) ))s"
local_height=$(docker logs --tail $tail $container | grep -a "Sent block @ height" | tail -1 | awk '{print $NF}')
is_accusing=$(docker logs --tail $tail $container | grep accusing | tail -1 | grep -c "Accuser IS accusing")
registered=$(docker logs --tail $tail $container | grep "Registered:" | tail -1 | grep -c "Registered: true")
sent=$(docker logs --tail $tail $container | grep -a "Challenges sent to Nilchain" | tail -1 | awk '{print $NF}')
url=$(docker ps -a --no-trunc | grep $folder | awk -F '--rpc-endpoint ' '{print $2}' | awk '{print $1}')
version=$(docker ps -a --no-trunc | grep $folder | awk -F 'accuser:' '{print $2}' | awk '{print $1}')

case $docker_status$is_accusing in
  running1) status=ok; message="last=$last_challenge_sec sent=$sent" ;;
  running0) status=warning; message="not accusing height=$local_height" ;;
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
   "status":"$status",
   "message":"$message",
   "docker_status":"$docker_status",
   "local_height":"$local_height",
   "last_challenge_sec":"$last_challenge_sec",
   "sent":"$sent",
   "is_accusing":"$is_accusing",
   "registered":"$registered",
   "url":"$url",
   "version":"$version"
  }
}
EOF

cat $json

# send data to influxdb
tag_count=$(echo $json | jq '.tags | length')
field_count=$(echo $json | jq '.fields | length')

data=$(echo $json | jq -r '.measurement')","

for (( i=0; i<$tag_count; i++ ))
do
 key=$(cat $json | jq -r keys[$i])
 value=$(cat $json | jq .tags | jq -r --arg a $key '.[$a]')
 data=$data$key"="$value
 [ $i -lt $(( tag_count - 1 )) ] && data=$data","
done

data=$data" "

for (( i=0; i<$field_count; i++ ))
do
 key=$(cat $json | jq -r keys[$i])
 value=$(cat $json | jq .fields | jq -r --arg a $key '.[$a]')
 data=$data$key"=\""$value"\""
 [ $i -lt $(( tag_count - 1 )) ] && data=$data","
done

echo $data

if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "$data"
fi
