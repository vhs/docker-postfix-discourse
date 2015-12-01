FROM ubuntu:14.04
MAINTAINER Garth Cumming

run DEBIAN_FRONTEND=noninteractive apt-get update && \

    echo mail > /etc/hostname && \
    
    echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt && \
    echo "postfix postfix/mailname string mail.example.com" >> preseed.txt && \
    debconf-set-selections preseed.txt && \
    
    apt-get install -q -y \
        postfix \
        courier-pop \
        opendkim \
        supervisor && \
    
    mkdir -p /var/run/courier/authdaemon/ && \
    mkdir /etc/opendkim/

# Configuration
COPY assets/etc /etc
COPY assets/bin /usr/local/bin
COPY opendkim.private /etc/opendkim.private

run chmod 600 /etc/opendkim.private && \
    postconf -e "home_mailbox = Maildir/" && \
    postmap /etc/postfix/virtual_addresses && \
    postconf -e "virtual_maps = hash:/etc/postfix/virtual_addresses" && \
    postconf -e "milter_default_action = accept" && \
    postconf -e "smtpd_milters = inet:127.0.0.1:8891" && \
    postconf -e "non_smtpd_milters = inet:127.0.0.1:8891" && \
    postconf -e "mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 172.16.0.0/12" && \
    postconf -e "smtpd_recipient_restrictions = check_recipient_access regexp:/etc/postfix/custom_replies" && \
    echo "KeyFile /etc/opendkim.private" >> /etc/opendkim.conf && \
    echo "Canonicalization relaxed/relaxed" >> /etc/opendkim.conf && \
    echo "InternalHosts /etc/opendkim.trusted" >> /etc/opendkim.conf && \
    cp /etc/resolv.conf /var/spool/postfix/etc/ && \
    cp /etc/services /var/spool/postfix/etc/ && \
    makedat -src=/etc/courier/access.txt -file=/etc/courier/access.gdbm -tmp=/tmp/makedat -cidr && \
    newaliases 

EXPOSE 110 25

VOLUME ["/var/mail", "/home/"]

CMD ["/usr/local/bin/start.sh"]
