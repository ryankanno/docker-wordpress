FROM ubuntu:12.04

MAINTAINER Ryan Kanno <ryankanno@localkinegrinds.com>

ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -y upgrade

# install ssh
RUN (apt-get -y install openssh-server && mkdir /var/run/sshd)

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

# configure nginx
RUN rm /etc/nginx/sites-enabled/default
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# install php
RUN apt-get -y install php5-fpm php5-mysql

# configure php5-fpm
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 20M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 20M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf

# install wordpress
RUN apt-get -y install php5-curl php-pear php5-imagick php5-imap php5-mcrypt
ADD http://wordpress.org/latest.tar.gz /usr/share/nginx/www/latest.tar.gz
RUN cd /usr/share/nginx/www/ && tar xvzf latest.tar.gz && rm latest.tar.gz
RUN chown -R www-data:www-data /usr/share/nginx/www/wordpress

# configure
ADD ./etc/nginx/wordpress.conf /etc/nginx/sites-available/wordpress.conf
RUN ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/wordpress.conf
ADD ./etc/supervisor/wordpress.conf /etc/supervisor/conf.d/wordpress.conf
RUN rm /etc/mysql/conf.d/mysqld_safe_syslog.cnf
ADD ./etc/mysql/my.cnf /etc/mysql/conf.d/my_wordpress.cnf

RUN mkdir -p /root/.ssh
ADD ./authorized_keys /root/.ssh/
RUN (chmod 700 /root && chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys)
RUN chown -R root /root

# add configure scripts
ADD ./scripts/configure_and_start.sh /build/scripts/configure_and_start.sh
RUN chmod 755 /build/scripts/configure_and_start.sh

EXPOSE 22 80

CMD ["/build/scripts/configure_and_start.sh"]
