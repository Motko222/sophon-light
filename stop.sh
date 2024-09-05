#!/bin/bash

echo "Stopping containers..."
container=$(docker ps | grep nillion | awk '{print $NF}')
docker stop $container
echo "Removing containers..."
container=$(docker ps -a | grep nillion | awk '{print $NF}')
docker rm $container
