server {
    listen 80 default_server;
	listen 443 ssl;
    server_name _ "";

	ssl_certificate /usr/share/easy-rsa/keys/ca.crt;
	ssl_certificate_key /usr/share/easy-rsa/keys/ca.key;

    error_log /var/log/site.error.log;
    root /var/www/site/public;

    include include/php-fpm-5.6;
}
