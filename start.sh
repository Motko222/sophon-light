#!/bin/bash

container=$(docker ps | grep nillion | awk '{print $NF}')
docker stop $container
docker run -d -v ~/nillion/accuser:/var/tmp nillion/retailtoken-accuser:v1.0.0 accuse --rpc-endpoint "https://testnet-nillion-rpc.lavenderfive.com" --block-start 5163501
