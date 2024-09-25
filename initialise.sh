#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
cd $path
source config

cd ~
mkdir -p ~/$folder/verifier
docker run -v ~/$folder/verifier:/var/tmp nillion/verifier:$VERSION initialise
sudo cat ~/$folder/verifier/credentials.json
