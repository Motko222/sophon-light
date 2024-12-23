#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
cd $path
source config

read -p "Are you sure? " sure
case $sure in y|Y|yes|YES|Yes) ;; *) exit ;; esac

echo "Stopping containers..."
container=$(docker ps | grep $folder | awk '{print $NF}')
docker stop $container

echo "Removing containers..."
container=$(docker ps -a | grep $folder | awk '{print $NF}')
docker rm $container 

echo "Removing images..."
docker image rm sophonhub/sophon-light-node:$VERSION

echo "Deleting scripts..."
rm -r /root/scripts/$folder
echo /root/scripts/$folder

echo "Done..."


