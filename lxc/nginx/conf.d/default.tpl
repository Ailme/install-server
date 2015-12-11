server {
    listen 0.0.0.0:80 default_server;
    server_name _ "";

    error_log /var/log/site.error.log;
    root /var/www/site/public;

    include include/php-fpm-5.6;
}
