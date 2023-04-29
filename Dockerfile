FROM php:8.0-apache

ENV HTML_DIR /var/www/html/crm

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y zip gzip libapache2-mod-php8.0 cron
RUN docker-php-ext-install bcmath bcmath cli common curl dev fpm gd imap mbstring mysql opcache readline soap xml zip

COPY docker-php-sugar-settings.ini /usr/local/etc/php/conf.d/docker-php-sugar-settings.ini

RUN find ${HTML_DIR} -type d -exec chmod 775 {} \\;
RUN find ${HTML_DIR} -type f -exec chmod 664 {} \\;
RUN find ${HTML_DIR} -maxdepth 2 -type f -name 'sugarcrm' -exec chmod 775 {} \\;

RUN (crontab -u www-data -l | grep -v "php -f cron.php") | crontab -u www-data -
RUN (crontab -u www-data -l; echo "*/5 * * * * cd ${HTML_DIR}; php -f cron.php > /dev/null 2>&1") | crontab -u www-data -

RUN systemctl start cron

EXPOSE 80 443
ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
