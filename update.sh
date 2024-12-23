#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
cd $path
source config

docker pull sophonhub/sophon-light-node:$VERSION
