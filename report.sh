#!/bin/bash

source ~/.bash_profile

id=$NILLION_ID
chain=nillion-chain-testnet-1
network=testnet
type=node
group=node
owner=$OWNER

cd ~/nillion/accuser

container=$(docker ps | grep nillion | awk '{print $NF}')
[ $container ] && docker_status=$(docker inspect $container | jq -r .[].State.Status)

version=?

case $docker_status in
  running) status=ok ;;
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
   { "key":"node_rpc","value":"$node_rpc" },
   { "key":"docker_status","value":"$docker_status" }
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
    report,id=$id,machine=$MACHINE,grp=$group,owner=$owner status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\",network=\"$network\" $(date +%s%N) 
    "
fi
