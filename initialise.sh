#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
cd $path
source config

cd ~
mkdir -p ~/$folder/accuser
docker run -v ~/$folder/accuser:/var/tmp nillion/retailtoken-accuser:$VERSION initialise
sudo cat ~/$folder/accuser/credentials.json
