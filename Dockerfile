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

# Copy main.cf
COPY assets/main.cf /etc/postfix/main.cf

# Install Courier
run apt-get install -q -y courier-pop
run mkdir -p /var/run/courier/authdaemon/

# Install Opendkim
run apt-get install -q -y opendkim
run mkdir /etc/opendkim/

# Install Supervisor
run apt-get install -y supervisor

# Install SASL
run apt-get install -y sasl2-bin

# Copy certificates
COPY certs/vanhack.crt /etc/ssl/certs/vanhack.crt
COPY certs/vanhack.key /etc/ssl/private/vanhack.key
COPY certs/intermediate-vanhack.crt /etc/ssl/certs/intermediate-vanhack.crt

# Configure Postfix
COPY assets/virtual_addresses /etc/postfix/virtual_addresses
run postmap /etc/postfix/virtual_addresses
COPY assets/custom_replies /etc/postfix/custom_replies
COPY assets/virtual_addresses /etc/postfix/virtual_addresses

# Configure OpenDKIM
COPY opendkim.private /etc/opendkim.private
COPY assets/opendkim.trusted /etc/opendkim.trusted
run chmod 600 /etc/opendkim.private
run echo "KeyFile /etc/opendkim.private" >> /etc/opendkim.conf
run echo "Canonicalization relaxed/relaxed" >> /etc/opendkim.conf
run echo "InternalHosts /etc/opendkim.trusted" >> /etc/opendkim.conf

run cp /etc/resolv.conf /var/spool/postfix/etc/  
run cp /etc/services /var/spool/postfix/etc/

# Courier
COPY courier-access.txt /etc/courier/access.txt
run makedat -src=/etc/courier/access.txt -file=/etc/courier/access.gdbm -tmp=/tmp/makedat -cidr

# Aliases
COPY aliases.txt /etc/aliases
run newaliases

# Fix saslauthd permissions
run mkdir -p /var/run/saslauthd
run mkdir -p /var/spool/postfix/var/run/saslauthd
run chown root:sasl /var/run/saslauthd
run chmod 710 /var/run/saslauthd
run chmod --reference=/var/run/saslauthd /var/spool/postfix/var/run/saslauthd

# Ensure saslauthd start on boot
run sed -i "s/START=no/START=yes/" /etc/default/saslauthd
run sed -i 's/OPTIONS=.*/OPTIONS="-c -m /var/spool/postfix/var/run/saslauthd"/g' /etc/default/saslauthd

# Supervisor config
COPY assets/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY assets/start.sh /usr/local/bin/

EXPOSE 110 25

VOLUME ["/var/mail", "/home/"]

CMD ["/usr/local/bin/start.sh"]
