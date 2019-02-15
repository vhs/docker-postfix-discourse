#!/bin/bash

#Set postconf options
postconf -e myhostname="$DOMAIN"
postconf -e mydomain="$DOMAIN"
postconf -e myorigin="$DOMAIN"
postconf -e mydestination="$DOMAIN, localhost.localdomain, localhost"

echo $DOMAIN > /etc/mailname
echo Selector $SELECTOR >> /etc/opendkim.conf
echo Domain $DOMAIN >> /etc/opendkim.conf

# Add Account for discourse
/usr/sbin/useradd discourse
echo discourse:$PASSWD | chpasswd
mkdir -p /home/discourse/Maildir/cur
chown -R discourse:discourse /home/discourse

# Set SASL SMTP
echo "[$SMTP_HOST]:$SMTP_PORT $SMTP_USER:$SMTP_PASS" > /etc/postfix/sasl_passwd
chmod 600 /etc/postfix/sasl_passwd
postmap hash:/etc/postfix/sasl_passwd
postconf -e "relayhost = [$SMTP_HOST]:$SMTP_PORT"

postconf compatibility_level=2

service rsyslog restart
