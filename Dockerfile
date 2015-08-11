# Kippo Dockerfile by MO 
#
# VERSION 0.43
FROM ubuntu:14.04.3
MAINTAINER MO

# Setup apt
RUN apt-get update -y
RUN apt-get dist-upgrade -y
ENV DEBIAN_FRONTEND noninteractive

# Install packages
RUN apt-get install -y supervisor python git python-twisted python-pycryptopp mysql-server python-mysqldb

# Install kippo from git
RUN git clone https://github.com/desaster/kippo.git /opt/kippo

# Setup user, groups and configs
RUN addgroup --gid 2000 tpot 
RUN adduser --system --no-create-home --shell /bin/bash --uid 2000 --disabled-password --disabled-login --gid 2000 tpot
RUN mkdir -p /data/kippo/log/tty/ /data/kippo/downloads/ /data/kippo/keys/ /data/kippo/misc/ /var/run/kippo/
#RUN echo "root:0:123456" > /data/kippo/misc/userdb.txt
ADD userdb.txt /data/kippo/misc/userdb.txt
RUN chmod 760 -R /data && chown tpot:tpot -R /data && chown tpot:tpot /var/run/kippo
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD kippo.cfg /opt/kippo/
ADD setup.sql /root/

# Setup mysql
RUN sed -i 's#127.0.0.1#0.0.0.0#' /etc/mysql/my.cnf
RUN service mysql start && /usr/bin/mysqladmin -u root password "gr8p4$w0rd" && /usr/bin/mysql -u root -p"gr8p4$w0rd" < /root/setup.sql

# Clean up 
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN rm /root/setup.sql

# Start supervisor
CMD ["/usr/bin/supervisord"]
