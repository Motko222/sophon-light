#!/bin/bash

folder=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
cd $folder

rpc=https://nillion-testnet-rpc.polkachu.com
#rpc=https://testnet-nillion-rpc.lavenderfive.com
#rpc=https://nillion-testnet.rpc.kjnodes.com

./stop.sh

read -p "Block? " block
docker run -d -v ~/nillion/accuser:/var/tmp nillion/retailtoken-accuser:v1.0.0 accuse --rpc-endpoint $rpc --block-start $block
container=$(docker ps | grep nillion | awk '{print $NF}')
docker logs -n 200 -f $container
