#!/bin/bash

container=$(docker ps | grep nillion | awk '{print $NF}')
docker logs -n 1000 -f $container
