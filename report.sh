#!/bin/bash

source ~/.bash_profile

id=$NILLION_ID
chain=nillion-chain-testnet-1
network=testnet
type=node
grp=node
owner=$OWNER

cd ~/nillion/accuser

container=$(docker ps | grep nillion | awk '{print $NF}')
[ $container ] && docker_status=$(docker inspect $container | jq -r .[].State.Status)
last_challenge=$(docker logs $container | grep -a "Challenges sent to chain" | awk '{print $1}' | tail -1 | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g")
last_challenge_sec=$(( $(date +%s) - $(date -d $last_challenge +%s) ))
local_height=$(docker logs $container | grep -a "Sent block @ height" | awk '{print $NF}')

version=?

case $docker_status in
  running) status=ok; message="last=$last_challenge_sec" ;;
  *) status="error"; message="docker not running" ;;
esac

cat << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": [   
   { "key":"id","value":"$id" },
   { "key":"machine","value":"$MACHINE" },
   { "key":"grp","value":"$grp" },
   { "key":"owner","value":"$owner" }
  ],
  "fields": [
   { "key":"status","value":"$status" },
   { "key":"message","value":"$message" },
   { "key":"docker_status","value":"$docker_status" },
   { "key":"local_height","value":"$local_height" },
   { "key":"last_challenge_sec","value":"$last_challenge_sec" }
  ]
}
EOF

# send data to influxdb
if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    report,id=$id,machine=$MACHINE,grp=$grp,owner=$owner status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\",network=\"$network\" $(date +%s%N) 
    "
fi
