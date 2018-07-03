FROM debian:stable
ARG PROXYPASSWORD="$PROXYPASSWORD"
RUN apt-get update
RUN apt-get install task-web-server libapache2-mod-php openssl \
    php-curl php-gd php-gmp php-intl php-json php-mysqlnd php-xml php-mbstring \
    git -y
RUN git clone -b 1.2.x https://git.gnu.io/gnu/gnu-social.git /var/www/gnu-social
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
RUN cat /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite
RUN mv /var/www/gnu-social/htaccess.sample /var/www/gnu-social/.htaccess
RUN chown -R www-data:www-data /var/www/gnu-social
RUN chmod g+w /var/www/gnu-social/

RUN find /var/www/gnu-social/ -name default.php -exec sed -i "s|'proxy_host' => null|proxy_host => '172.82.82.5'|g" {} \;
RUN find /var/www/gnu-social/ -name default.php -exec sed -i "s|'proxy_port' => null|proxy_port => '8118'|g" {} \;

#RUN find /var/www/gnu-social/ -name default.php -exec sed -i "s|'proxy_user' => null|proxy_port => 'gnusocial'|g" {} \;
#RUN find /var/www/gnu-social/ -name default.php -exec sed -i "s|'proxy_password' => null|proxy_port => '$PROXYPASSWORD'|g" {} \;
#RUN find /var/www/gnu-social/ -name default.php -exec sed -i "s|'proxy_auth_scheme' => null|proxy_port => '8118'|g" {} \;

CMD . /etc/apache2/envvars && apache2ctl start; tail -f /var/log/apache2/*log
