#!/bin/bash

rpc=https://nillion-testnet-rpc.polkachu.com
#rpc=https://testnet-nillion-rpc.lavenderfive.com

container=$(docker ps | grep nillion | awk '{print $NF}')
docker stop $container
docker rm $container
read -p "Block? " block
docker run -d -v ~/nillion/accuser:/var/tmp nillion/retailtoken-accuser:v1.0.0 accuse --rpc-endpoint $rpc --block-start $block
container=$(docker ps | grep nillion | awk '{print $NF}')
docker logs -n 200 -f $container
