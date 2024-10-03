#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
cd $path
source config

if [ -z $RPC ]
then 
      rpc=$(cat rpc | head -1 )
      echo "rpc defaulted to $rpc"
else
      rpc=$RPC
      echo "rpc fetched from config $rpc"
fi

./stop.sh

docker run -d --name $folder --restart always -v ~/$folder/verifier:/var/tmp nillion/verifier:$VERSION verify --rpc-endpoint $rpc
container=$(docker ps | grep $folder | awk '{print $NF}')
docker logs -n 200 -f $container
