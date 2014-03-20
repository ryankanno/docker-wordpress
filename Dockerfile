FROM ubuntu:12.04

MAINTAINER Ryan Kanno <ryankanno@localkinegrinds.com>

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list

RUN apt-get update  # TIME
RUN apt-get upgrade -y

# install python
RUN apt-get install -y python-dev python-pip

# install supervisord
RUN pip install supervisor

# install mysql
RUN apt-get install -y mysql-server libmysqlclient-dev

# install nginx
RUN apt-get install -y python-software-properties
RUN apt-get update
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get install -y nginx
RUN rm /etc/nginx/sites-enabled/default
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# install wordpress

# configure
ADD ./etc/supervisord.conf /etc/supervisord/supervisord.conf
ADD ./etc/nginx-wordpress.conf /etc/nginx/sites-available/wordpress.conf
RUN ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/wordpress.conf

EXPOSE 80

CMD ["/usr/local/bin/supervisord", "-n", "-c", "/etc/supervisord/supervisord.conf"]
