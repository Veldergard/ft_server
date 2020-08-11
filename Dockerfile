# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: olaurine <olaurine@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/08/01 22:16:08 by olaurine          #+#    #+#              #
#    Updated: 2020/08/11 18:22:32 by olaurine         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

RUN apt update && \
apt upgrade -y && \
apt install -y vim wget php7.3-fpm php7.3-common php7.3-mysql php7.3-gmp \
php7.3-curl php7.3-intl php7.3-mbstring php7.3-xmlrpc php7.3-gd php7.3-xml \
php7.3-cli php7.3-zip php7.3-soap php7.3-imap nginx mariadb-server openssl \
&& rm -rf /etc/nginx/sites-available/default \
&& rm -rf /etc/nginx/sites-enabled/default \
&& mkdir -p /var/www/olaurine

# config access
RUN chown -R www-data /var/www/* && chmod -R 755 /var/www/*

# ssl sertificate
RUN mkdir /etc/nginx/ssl
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out \
/etc/nginx/ssl/olaurine.pem -keyout /etc/nginx/ssl/olaurine.key -subj \
"/C=RU/ST=Kazan/L=Kazan/O=21 School/OU=olaurine/CN=olaurine"

# nginx configure
COPY srcs/olaurine /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/olaurine /etc/nginx/sites-enabled/olaurine

# database creation
RUN service mysql start
RUN echo "CREATE DATABASE wordpress;" | mysql -u root --skip-password
RUN echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' WITH GRANT OPTION;" | mysql -u root --skip-password
RUN echo "update mysql.user set plugin='mysql_native_password' where user='root';" | mysql -u root --skip-password
RUN echo "FLUSH PRIVILEGES;" | mysql -u root --skip-password

# phpmyadmin
RUN mkdir /var/www/olaurine/phpmyadmin
ADD srcs/phpMyAdmin.tar.gz /var/www/olaurine
COPY srcs/config.inc.php /var/www/olaurine/phpmyadmin

# adding phpmyadmin & wordpress
ADD srcs/wordpress-5.4.2.tar.gz /var/www/olaurine
COPY srcs/wp-config.php /var/www/olaurine/wordpress
RUN rm -rf /var/www/olaurine/phpmyadmin/config.sample.inc.php

EXPOSE 80 443

#server starter
COPY srcs/run_server.sh /var/
COPY srcs/autoindexing.sh /var/
CMD bash /var/run_server.sh
