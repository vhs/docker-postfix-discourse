#!/bin/bash

if [ ! -e assets/virtual_addresses ] ; then
 echo "Missing virtual address file!"
 exit
fi

docker build -t vanhack/discourse_mail .
