FROM ubuntu:14.04
MAINTAINER Garth Cumming

run apt-get update

run echo mail > /etc/hostname

ENV DEBIAN_FRONTEND noninteractive

# Install Postfix.
run echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt
run echo "postfix postfix/mailname string mail.example.com" >> preseed.txt
run debconf-set-selections preseed.txt
run apt-get install -q -y postfix

# Install Courier
run apt-get install -q -y courier-pop
run mkdir -p /var/run/courier/authdaemon/

# Install Opendkim
run apt-get install -q -y opendkim
run mkdir /etc/opendkim/

# Install Supervisor
run apt-get install -y supervisor

# Configuration
COPY opendkim.private /etc/opendkim.private
COPY assets/opendkim.trusted /etc/opendkim.trusted
COPY assets/custom_replies /etc/postfix/custom_replies
run chmod 600 /etc/opendkim.private
run postconf -e "home_mailbox = Maildir/"
run postconf -e "milter_default_action = accept"
run postconf -e "smtpd_milters = inet:127.0.0.1:8891"
run postconf -e "non_smtpd_milters = inet:127.0.0.1:8891"
run postconf -e "mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 172.16.0.0/12"
run postconf -e "smtpd_recipient_restrictions = check_recipient_access regexp:/etc/postfix/custom_replies"
run echo "KeyFile /etc/opendkim.private" >> /etc/opendkim.conf
run echo "Canonicalization relaxed/relaxed" >> /etc/opendkim.conf
run echo "InternalHosts /etc/opendkim.trusted" >> /etc/opendkim.conf
run cp /etc/resolv.conf /var/spool/postfix/etc/  
run cp /etc/services /var/spool/postfix/etc/

COPY courier-access.txt /etc/courier/access.txt
run makedat -src=/etc/courier/access.txt -file=/etc/courier/access.gdbm -tmp=/tmp/makedat -cidr

COPY aliases.txt /etc/aliases
run newaliases

# Supervisor config
COPY assets/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY assets/start.sh /usr/local/bin/

EXPOSE 110 25

VOLUME ["/var/mail", "/home/"]

CMD ["/usr/local/bin/start.sh"]
