#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ ! -e $DIR/config ]; then
  echo "File: $DIR/config is missing, please create one first, see config.sample" 
  exit 1
fi

source $DIR/config
echo Using domain: $DOMAIN with selector: $DKIM_SELECTOR 
echo "Building"
docker build -t hackspace/discourse_mail $DIR

echo "Stopping existing instance"
docker stop discourse_mail

echo "Removing old instance"
docker rm discourse_mail

echo "Starting"
docker run -e "domain=$DOMAIN" -e "selector=$DKIM_SELECTOR" -e "passwd=$POP3_PASS" -d \
   -p 110:110 \
   -p 25:25 \
   -v $DIR/log:/var/log/supervisor \
   -v $DIR/mail:/var/mail \
   -v $DIR/home:/home \
   --restart=always \
   --name discourse_mail hackspace/discourse_mail
