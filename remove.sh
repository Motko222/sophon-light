#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')

read -p "Are you sure? " sure
case $sure in y|Y|yes|YES|Yes) ;; *) exit ;; esac

#backup
[ -d /root/backup/$folder ] || mkdir -p /root/backup/$folder
cp /root/$folder/verifier/credentials.json /root/backup/$folder
cat /root/$folder/verifier/credentials.json
read -p "Backup your credentials... Continue? " sure
case $sure in y|Y|yes|YES|Yes) ;; *) exit ;; esac

echo "Stopping containers..."
container=$(docker ps | grep $folder | awk '{print $NF}')
docker stop $container

echo "Removing containers..."
container=$(docker ps -a | grep $folder | awk '{print $NF}')
docker rm $container 

echo "Removing images..."
docker image rm nillion/verifier:v1.0.0
docker image rm nillion/verifier:v1.0.1
docker image rm nillion/retailtoken-accuser:v1.0.0
docker image rm nillion/retailtoken-accuser:v1.0.1

echo "Deleting folder..."
rm -r /root/$folder

echo "Deleting scripts..."
rm -r /root/scripts/$folder

echo "Done..."


