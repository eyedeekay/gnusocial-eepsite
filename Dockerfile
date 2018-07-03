FROM debian:stable
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
CMD . /etc/apache2/envvars && apache2ctl start; tail -f /var/log/apache2/*log
