#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')

echo "Stopping containers..."
container=$(docker ps | grep $folder | awk '{print $NF}')
docker stop $container
echo "Removing containers..."
container=$(docker ps -a | grep $folder | awk '{print $NF}')
docker rm $container
