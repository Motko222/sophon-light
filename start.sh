#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')

cd $path

echo "------------------------"
cat rpc | nl
echo "------------------------"
read -p "? " n

if [[ $n == ?(-)+([0-9]) ]]
  then
    rpc=$(cat rpc | head -$n | tail -1 )
  else 
    exit 1
fi

#rpc=https://nillion-testnet-rpc.polkachu.com
#rpc=https://testnet-nillion-rpc.lavenderfive.com
#rpc=https://nillion-testnet.rpc.kjnodes.com
#rpc=http://nillion.testnet.antares.zone:26657

./stop.sh

read -p "Block? " block
docker run -d --name $folder -v ~/$folder/accuser:/var/tmp nillion/retailtoken-accuser:v1.0.0 accuse --rpc-endpoint $rpc --block-start $block
container=$(docker ps | grep $folder | awk '{print $NF}')
docker logs -n 200 -f $container
