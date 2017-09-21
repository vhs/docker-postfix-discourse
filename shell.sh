#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ ! -e $DIR/config ]; then
  echo "File: $DIR/config is missing, please create one first, see config.sample" 
  exit 1
fi

source $DIR/config
echo "Building"
docker build -t hackspace/discourse_mail $DIR

echo "Stopping existing instance"
docker stop discourse_mail_test

echo "Removing old instance"
docker rm discourse_mail_test

echo "Starting"
docker run -e "domain=$DOMAIN" -e "selector=$DKIM_SELECTOR" -e "passwd=$POP3_PASS" -i -t \
   -v $DIR/log:/var/log/supervisor \
   -v $DIR/mail:/var/mail \
   -v $DIR/home:/home \
   -v /etc/letsencrypt:/etc/letsencrypt \
   -v /var/lib/letsencrypt:/var/lib/letsencrypt \
   --name discourse_mail_test hackspace/discourse_mail /bin/bash
