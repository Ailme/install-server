server {
    listen 0.0.0.0:80;
    server_name DOMAIN_NAME;

    location / {
        include /etc/nginx/include/proxy;
        proxy_pass http://CONTAINER_NAME/;
    }
}
