#!/bin/bash

container=$(docker ps | grep nillion | awk '{print $NF}')
docker stop $container
docker rm $container
docker ps | grep nillion
