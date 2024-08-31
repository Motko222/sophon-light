#!/bin/bash

container=$(docker ps | grep nillion | awk '{print $NF}')
docker logs -n 2000 -f $container | grep ERROR
