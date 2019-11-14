#!/bin/bash

export CONTAINER_NAME="discourse_mail_test"
export PUBLIC_SMTP_PORT=1025

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -e $DIR/config ]; then
  echo "File: $DIR/config is missing, please create one first, see config.sample" 
  exit 1
fi

source $DIR/config

echo "Using domain: $DOMAIN with selector: $DKIM_SELECTOR"

tools/mksecrets.sh

docker-compose run --rm discourse_mail /bin/bash
