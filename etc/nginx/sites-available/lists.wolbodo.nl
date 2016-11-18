server {
    listen       80;
    server_name  lists.wolbodo.nl;
    root         /home/sympa/bin;
    access_log   /var/log/nginx/lists.wolbodo.nl.access.log;   
    error_log    /var/log/nginx/lists.wolbodo.nl.error.log;         
    error_page   403 500 502 503 504 /50x.html;

    rewrite ^/$ http://lists.wolbodo.nl/sympa permanent;

    location /static-sympa {
        alias /home/sympa/static_content/;
        access_log off;
    }

    location /50x.html {
        root /usr/share/nginx/html;
    }

    location ~* \.(php|pl|py|jsp|asp|sh|cgi|bin|csh|ksh|out|run|o)$ {
        deny all;
    }

    location ~ /\.ht {
        deny all;
    }

    location / {
        include sympa_fcgi.conf;
    }
}
