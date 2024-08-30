#!/bin/bash

container=$(docker ps | grep nillion | awk '{print $NF}')
docker logs -n 200 -f $container
