#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')

cd ~
mkdir -p ~/$folder/accuser
docker run -v ~/$folder/accuser:/var/tmp nillion/retailtoken-accuser:v1.0.1 initialise
sudo cat ~/$folder/accuser/credentials.json
