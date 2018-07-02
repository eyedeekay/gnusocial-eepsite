FROM debian:stable
RUN apt-get update
RUN apt-get install task-web-server libapache2-mod-php openssl \
    php-curl php-gd php-gmp php-intl php-json php-mysqlnd php-xml php-mbstring \
    git -y
RUN git clone -b 1.2.x https://git.gnu.io/gnu/gnu-social.git /var/www/gnu-social
RUN echo 'ServerName 0.0.0.0:8080' > /etc/apache2/sites-available/000-default.conf
#RUN echo 'ServerName 172.82.82.4:8080' > /etc/apache2/sites-available/000-default.conf
RUN echo '    DocumentRoot /var/www/gnu-social' >> /etc/apache2/sites-available/000-default.conf
RUN echo '    <Directory /var/www/gnu-social/>' >> /etc/apache2/sites-available/000-default.conf
RUN echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf
RUN echo '        Order Deny,Allow' >> /etc/apache2/sites-available/000-default.conf
RUN echo '        Allow from all' >> /etc/apache2/sites-available/000-default.conf
RUN echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf
RUN cat /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite
RUN mv /var/www/gnu-social/htaccess.sample /var/www/gnu-social/.htaccess
RUN chown -R www-data:www-data /var/www/gnu-social
RUN chmod g+w /var/www/gnu-social/
RUN echo "<?php" > /var/www/proxy.php
RUN echo "stream_context_set_default(['http'=>['proxy'=>'172.82.82.3:9050']]);" >> /var/www/proxy.php
RUN echo "curl_setopt($handle, CURLOPT_PROXY, 172.82.82.3:9050);" >> /var/www/proxy.php
RUN echo "?>" >> /var/www/proxy.php
RUN find / -name php.ini -type f -exec echo "auto_prepend_file /var/www/proxy.php" >> {} \;
CMD . /etc/apache2/envvars && apache2ctl start; tail -f /var/log/apache2/*log
