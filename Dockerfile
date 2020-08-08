# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: olaurine <olaurine@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/08/01 22:16:08 by olaurine          #+#    #+#              #
#    Updated: 2020/08/08 02:30:41 by olaurine         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

RUN apt update && \
apt upgrade -y && \
apt install -y vim wget php7.3-fpm php7.3-common php7.3-mysql php7.3-gmp \
php7.3-curl php7.3-intl php7.3-mbstring php7.3-xmlrpc php7.3-gd php7.3-xml \
php7.3-cli php7.3-zip php7.3-soap php7.3-imap nginx mariadb-server openssl \
rm -rf /etc/nginx/sites-available/default \
&& rm -rf /etc/nginx/sites-enabled/default \
&& mkdir -p /var/www/olaurine

# ssl sertificate
RUN mkdir /etc/nginx/ssl
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out \
/etc/nginx/ssl/olaurine.pem -keyout /etc/nginx/ssl/olaurine.key -subj \
"/C=RU/ST=Kazan/L=Kazan/O=21 School/OU=olaurine/CN=olaurine"


#adding phpmyadmin & wordpress
RUN chown -R www-data /var/www/* && chmod -R 755 /var/www/*
ADD srcs/wordpress-5.4.2-ru_RU.tar.gz /var/www/olaurine
ADD srcs/phpMyAdmin-4.9.5-all-languages.tar.gz /var/www/olaurine
RUN mv /var/www/olaurine/phpMyAdmin-4.9.5-all-languages /var/www/olaurine/phpmyadmin
COPY srcs/wp-config.php /var/www/olaurine/wordpress
COPY srcs/config.inc.php /var/www/olaurine/phpmyadmin
RUN rm /var/www/olaurine/phpmyadmin/config.sample.inc.php

#nginx configure
COPY srcs/wp_nginx /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/wp_nginx /etc/nginx/sites-enabled/wp_nginx


#database creation
COPY srcs/database_creation.sh /var/
RUN bash /var/database_creation.sh

EXPOSE 80 443

#server starter
COPY srcs/run_server.sh /var/
COPY srcs/autoindexing.sh /var/
CMD bash /var/run_server.sh
