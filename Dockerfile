FROM ubuntu
MAINTAINER Garth Cumming

RUN apt-get update

RUN echo mail > /etc/hostname

ENV DEBIAN_FRONTEND noninteractive

# Install Postfix.
RUN echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt
RUN echo "postfix postfix/mailname string mail.example.com" >> preseed.txt
RUN debconf-set-selections preseed.txt
RUN apt-get install -q -y postfix

# Copy main.cf
COPY assets/main.cf /etc/postfix/main.cf

# Install Courier
RUN apt-get install -q -y courier-pop
RUN mkdir -p /var/run/courier/authdaemon/

# Install Opendkim
RUN apt-get install -q -y opendkim
RUN mkdir /etc/opendkim/

# Install Supervisor
RUN apt-get install -y supervisor

# Install SASL
RUN apt-get install -y sasl2-bin

# Configure Postfix
COPY assets/virtual_addresses /etc/postfix/virtual_addresses
RUN postmap /etc/postfix/virtual_addresses
COPY assets/custom_replies /etc/postfix/custom_replies
COPY assets/virtual_addresses /etc/postfix/virtual_addresses

# Configure OpenDKIM
COPY opendkim.private /etc/opendkim.private
COPY assets/opendkim.trusted /etc/opendkim.trusted
RUN chmod 600 /etc/opendkim.private
RUN echo "KeyFile /etc/opendkim.private" >> /etc/opendkim.conf
RUN echo "Canonicalization relaxed/relaxed" >> /etc/opendkim.conf
RUN echo "InternalHosts /etc/opendkim.trusted" >> /etc/opendkim.conf

RUN cp /etc/resolv.conf /var/spool/postfix/etc/  
RUN cp /etc/services /var/spool/postfix/etc/

# Courier
COPY courier-access.txt /etc/courier/access.txt
RUN makedat -src=/etc/courier/access.txt -file=/etc/courier/access.gdbm -tmp=/tmp/makedat -cidr

# Aliases
COPY aliases.txt /etc/aliases
RUN newaliases

# Fix saslauthd permissions
RUN mkdir -p /var/run/saslauthd
RUN mkdir -p /var/spool/postfix/var/run/saslauthd
RUN chown root:sasl /var/run/saslauthd
RUN chmod 710 /var/run/saslauthd
RUN chmod --reference=/var/run/saslauthd /var/spool/postfix/var/run/saslauthd

# Ensure saslauthd start on boot
RUN sed -i "s/START=no/START=yes/" /etc/default/saslauthd
RUN sed -i 's/OPTIONS=.*/OPTIONS="-c -m \/var\/spool\/postfix\/var\/run\/saslauthd"/g' /etc/default/saslauthd

# Supervisor config
COPY assets/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY assets/start.sh /usr/local/bin/

EXPOSE 110 25

VOLUME ["/var/mail", "/home/"]

CMD ["/usr/local/bin/start.sh"]
