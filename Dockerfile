FROM ubuntu:12.04

MAINTAINER Ryan Kanno <ryankanno@localkinegrinds.com>

ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -y upgrade

# install basic
RUN apt-get -y install curl unzip pwgen

# install supervisor
RUN apt-get -y install supervisor

# install mysql
RUN apt-get -y install mysql-server mysql-client

# install nginx
RUN apt-get -y install python-software-properties
RUN apt-get update
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get -y install nginx
RUN rm /etc/nginx/sites-enabled/default
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# install php
RUN apt-get -y install php5-fpm php5-mysql

# install wordpress
RUN apt-get -y install php5-curl php-pear php5-imagick php5-imap php5-mcrypt
ADD http://wordpress.org/latest.tar.gz /usr/share/nginx/www/latest.tar.gz
RUN cd /usr/share/nginx/www/ && tar xvzf latest.tar.gz && rm latest.tar.gz

# configure
ADD ./etc/nginx/wordpress.conf /etc/nginx/sites-available/wordpress.conf
RUN ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/wordpress.conf
ADD ./etc/supervisor/wordpress.conf /etc/supervisor/conf.d/wordpress.conf

EXPOSE 80

ENTRYPOINT ["/usr/bin/supervisord"]
# CMD ["/usr/bin/supervisord"]
