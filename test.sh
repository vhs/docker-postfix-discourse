#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ ! -e $DIR/config ]; then
  echo "File: $DIR/config is missing, please create one first, see config.sample" 
  exit 1
fi

echo "Stopping existing instance"
docker stop discourse_mail_test

echo "Removing old instance"
docker rm discourse_mail_test

source $DIR/config
echo "Building"
docker build -t vanhack/discourse_mail $DIR

echo "Starting"
docker run -i -t \
    -e "domain=$DOMAIN" \
    -e "selector=$DKIM_SELECTOR"  \
    -e "passwd=$POP3_PASS" \
    -e "SES_HOST=$SES_HOST" \
    -e "SES_USER=$SES_USER" \
    -e "SES_PASS=$SES_PASS" \
    -p 10110:110 \
    -p 10025:25 \
    -v $DIR/log:/var/log/supervisor \
    -v $DIR/mail:/var/mail \
    -v $DIR/home:/home \
    -v /etc/letsencrypt:/etc/letsencrypt \
    -v /var/lib/letsencrypt:/var/lib/letsencrypt \
    --name discourse_mail_test vanhack/discourse_mail \
    /usr/local/bin/test.sh
