#!/bin/bash

echo -n "Waiting for secrets..."
while [ ! -f /run/secrets/DOMAIN ]
do
	echo -n "."
	sleep 1
done
echo "OK"

#Set postconf options
postconf -e myhostname="$(cat /run/secrets/DOMAIN)"
postconf -e mydomain="$(cat /run/secrets/DOMAIN)"
postconf -e myorigin="$(cat /run/secrets/DOMAIN)"
postconf -e mydestination="$(cat /run/secrets/DOMAIN), localhost.localdomain, localhost"

echo $(cat /run/secrets/DOMAIN) > /etc/mailname
echo Selector $(cat /run/secrets/DKIM_SELECTOR) >> /etc/opendkim.conf
echo Domain $(cat /run/secrets/DOMAIN) >> /etc/opendkim.conf

# Add Account for discourse
/usr/sbin/useradd discourse
echo discourse:$(cat /run/secrets/POP3_PASS) | chpasswd
mkdir -p /home/discourse/Maildir/cur
chown -R discourse:discourse /home/discourse

# Set SASL SMTP
echo "[$(cat /run/secrets/SMTP_HOST)]:$(cat /run/secrets/SMTP_PORT) $(cat /run/secrets/SMTP_USER):$(cat /run/secrets/SMTP_PASS)" > /etc/postfix/sasl_passwd
chmod 600 /etc/postfix/sasl_passwd
postmap hash:/etc/postfix/sasl_passwd
postconf -e "relayhost = [$(cat /run/secrets/SMTP_HOST)]:$(cat /run/secrets/SMTP_PORT)"

postconf compatibility_level=2

service rsyslog restart
