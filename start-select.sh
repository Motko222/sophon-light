#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
cd $path
source config

echo "------------------------"
for (( i=1;i<5;i++ ))
do
   rpc=$(cat rpc | head -$i | tail -1)
   printf "%s %-60s %s \n" $i $rpc $(curl -s $rpc/status | jq -r .result.sync_info.latest_block_height)
done

echo "------------------------"
read -p "? " n

if [[ $n == ?(-)+([0-9]) ]]
  then
    rpc=$(cat rpc | head -$n | tail -1 )
  else 
    exit 1
fi

./stop.sh

docker run -d --name $folder --restart always -v ~/$folder/verifier:/var/tmp nillion/verifier:$VERSION verify --rpc-endpoint $rpc 
container=$(docker ps | grep $folder | awk '{print $NF}')
docker logs -n 200 -f $container
