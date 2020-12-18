FROM ubuntu
LABEL maintainers="ops@vanhack.ca"

RUN apt-get update

RUN echo mail > /etc/hostname

ENV DEBIAN_FRONTEND noninteractive

# Install rsyslog
RUN apt-get install -q -y rsyslog

# Install Postfix
RUN echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt &&\
    echo "postfix postfix/mailname string mail.example.com" >> preseed.txt &&\
    debconf-set-selections preseed.txt &&\
    apt-get install -q -y postfix

# Copy main.cf
COPY assets/main.cf /etc/postfix/main.cf

# Install Courier
RUN touch /usr/share/man/man5/maildir.courier.5.gz /usr/share/man/man7/maildirquota.courier.7.gz && apt-get install -q -y courier-pop
RUN mkdir -p /var/run/courier/authdaemon/

# Install Supervisor
RUN apt-get install -y supervisor

# Install SASL
RUN apt-get install -y sasl2-bin

# Configure Postfix
COPY assets/custom_replies /etc/postfix/custom_replies
COPY assets/virtual_addresses /etc/postfix/virtual_addresses
RUN postmap /etc/postfix/virtual_addresses

# Copy system files
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

# Startup script
COPY assets/bootstrap.sh /usr/local/bin/
COPY assets/docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 25 110 

VOLUME ["/var/mail", "/home/"]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord"]
