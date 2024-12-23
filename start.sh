#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
cd $path
source config

./stop.sh

docker run -d --name $folder \
    -e OPERATOR_ADDRESS=$OPERATOR \
    -e DESTINATION_ADDRESS=$DESTINATION \
    -e PERCENTAGE=1.00 \
    -e PUBLIC_DOMAIN=http://$IP:7007 \
    -e PORT=7007 \
    -e AUTO_UPGRADE=true \
    -p 7007:7007 \
    --restart unless-stopped \
    sophonhub/sophon-light-node

container=$(docker ps | grep $folder | awk '{print $NF}')
docker logs -n 200 -f $container
