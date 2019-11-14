#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -e $DIR/config ]; then
  echo "File: $DIR/config is missing, please create one first, see config.sample" 
  exit 1
fi

source $DIR/config

echo "Using domain: $DOMAIN with selector: $DKIM_SELECTOR"

tools/mksecrets.sh

docker-compose up -d
