#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
cd $path
source config

sudo apt update
sudo apt upgrade -y
sudo apt install docker.io -y
sudo systemctl enable docker
docker pull sophonhub/sophon-light-node:$VERSION
