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

#Start Supervisor
/usr/bin/supervisord
