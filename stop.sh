#!/bin/bash

container=$(docker ps | grep nillion | awk '{print $NF}')
docker stop $container
docker ps | grep nillion
