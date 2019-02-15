#!/bin/bash

CONTAINER="discourse_mail"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -e $DIR/config ]; then
  echo "File: $DIR/config is missing, please create one first, see config.sample" 
  exit 1
fi

source $DIR/config

echo "Using domain: $DOMAIN with selector: $DKIM_SELECTOR"

echo "Building..."
./build.sh

echo "Stopping existing instance..."
docker stop "$CONTAINER"

echo "Removing old instance..."
docker rm "$CONTAINER"

echo "Starting..."
docker run --init -d \
    -e "DOMAIN=$DOMAIN" \
    -e "SELECTOR=$DKIM_SELECTOR"  \
    -e "PASSWD=$POP3_PASS" \
    -e "SMTP_HOST=$SMTP_HOST" \
    -e "SMTP_USER=$SMTP_USER" \
    -e "SMTP_PASS=$SMTP_PASS" \
    -p 110:110 \
    -p 25:25 \
    -v $DIR/log:/var/log/supervisor \
    -v $DIR/mail:/var/mail \
    -v $DIR/home:/home \
    -v /etc/letsencrypt:/etc/letsencrypt \
    -v /var/lib/letsencrypt:/var/lib/letsencrypt \
    --restart=always \
    --name "$CONTAINER" vanhack/discourse_mail
