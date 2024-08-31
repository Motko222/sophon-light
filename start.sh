#!/bin/bash

container=$(docker ps | grep nillion | awk '{print $NF}')
docker stop $container
read -p "Block? " block
docker run -d -v ~/nillion/accuser:/var/tmp nillion/retailtoken-accuser:v1.0.0 accuse --rpc-endpoint "https://testnet-nillion-rpc.lavenderfive.com" --block-start $block
docker ps | grep nillion
