#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
source $path/config

curl -sX GET "https://monitor.sophon.xyz/nodes?operators=$OPERATOR" | jq
