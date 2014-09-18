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

# Install Supervisor
run apt-get install -y supervisor

# Configuration
run postconf -e "home_mailbox = Maildir/"
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
