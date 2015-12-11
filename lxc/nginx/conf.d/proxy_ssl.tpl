server {
	listen      80;
	server_name DOMAIN_NAME;
	return 301  https://$server_name$request_uri;
}

server {
	listen 443 ssl;
	server_name DOMAIN_NAME;

	ssl_certificate /etc/letsencrypt/live/SSL_NAME/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/SSL_NAME/privkey.pem;

	location / {
		include include/proxy;
		proxy_pass https://CONTAINER_NAME:443;
	}		

}

