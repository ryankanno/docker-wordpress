#!/bin/bash

# TODO: Change me
NEW_ROOT="toor"

/usr/bin/mysqld_safe &

sleep 10

# configure / harden mysql
if [ ! -f /build/mysql-pw.log ]; then

    MYSQL_PASSWORD=$(pwgen -c -n -1 16)
    echo $MYSQL_PASSWORD > /build/mysql-pw.log

    mysqladmin -uroot password $MYSQL_PASSWORD
    mysql -uroot -p$MYSQL_PASSWORD -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1'); FLUSH PRIVILEGES";
    mysql -uroot -p$MYSQL_PASSWORD -e "DROP DATABASE test;"
    mysql -uroot -p$MYSQL_PASSWORD -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    mysql -uroot -p$MYSQL_PASSWORD -e "DELETE FROM mysql.user WHERE User=''; FLUSH PRIVILEGES;"
    mysql -uroot -p$MYSQL_PASSWORD -e "UPDATE mysql.user set user = '$NEW_ROOT' WHERE user = 'root'; FLUSH PRIVILEGES;"
fi

# configure wordpress
if [ ! -f /usr/share/nginx/www/wordpress/wp-config.php ]; then

    WORDPRESS_DB="wordpress"
    MYSQL_PASSWORD=$(cat /build/mysql-pw.log | tr -d '\n' | tr -d '\r')

    WORDPRESS_PASSWORD=$(pwgen -c -n -1 16)
    echo $WORDPRESS_PASSWORD > /build/wordpress-db-pw.txt

    sed -e "
    s/database_name_here/$WORDPRESS_DB/
    s/username_here/$WORDPRESS_DB/
    s/password_here/$WORDPRESS_PASSWORD/
    /'AUTH_KEY'/s/put your unique phrase here/$(pwgen -c -n -1 65)/
    /'SECURE_AUTH_KEY'/s/put your unique phrase here/$(pwgen -c -n -1 65)/
    /'LOGGED_IN_KEY'/s/put your unique phrase here/$(pwgen -c -n -1 65)/
    /'NONCE_KEY'/s/put your unique phrase here/$(pwgen -c -n -1 65)/
    /'AUTH_SALT'/s/put your unique phrase here/$(pwgen -c -n -1 65)/
    /'SECURE_AUTH_SALT'/s/put your unique phrase here/$(pwgen -c -n -1 65)/
    /'LOGGED_IN_SALT'/s/put your unique phrase here/$(pwgen -c -n -1 65)/
    /'NONCE_SALT'/s/put your unique phrase here/$(pwgen -c -n -1 65)/" /usr/share/nginx/www/wordpress/wp-config-sample.php > /usr/share/nginx/www/wordpress/wp-config.php

    chown www-data:www-data /usr/share/nginx/www/wordpress/wp-config.php

    mysql -u$NEW_ROOT -p$MYSQL_PASSWORD -e "CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY '$WORDPRESS_PASSWORD'; FLUSH PRIVILEGES;"
fi

killall mysqld

# start
/usr/bin/supervisord -n
