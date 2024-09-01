#!/bin/bash

read -p "Search? " search
container=$(docker ps | grep nillion | awk '{print $NF}')
docker logs $container | grep "$search"
