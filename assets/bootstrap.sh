#!/bin/bash

#Set postconf options
postconf -e myhostname=$domain
postconf -e mydestination="$domain, localhost.localdomain, localhost"
echo $domain > /etc/mailname
echo Selector $selector >> /etc/opendkim.conf
echo Domain $domain >> /etc/opendkim.conf

# Add Account for discourse
/usr/sbin/useradd discourse
echo discourse:$passwd | chpasswd
mkdir -p /home/discourse/Maildir/cur
chown -R discourse:discourse /home/discourse

# Set SASL SMTP
echo "[$SES_HOST]:587 $SES_USER:$SES_PASS" > /etc/postfix/sasl_passwd
chmod 600 /etc/postfix/sasl_passwd
postmap hash:/etc/postfix/sasl_passwd
postconf -e "relayhost = [$SES_HOST]:587"

postconf compatibility_level=2

service rsyslog restart
