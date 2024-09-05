#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')

container=$(docker ps -a | grep $folder | awk '{print $NF}')
docker logs -n 200 -f $container








