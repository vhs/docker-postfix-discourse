#!/bin/bash

if [ ! -e assets/virtual_addresses ] ; then
 echo "Missing virtual address file!"
 exit
fi

docker-compose build
