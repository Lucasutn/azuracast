FROM azuracast/azuracast:stable

# Variables de entorno básicas
ENV PUID=1000 \
    PGID=1000 \
    APPLICATION_ENV=production \
    AUTO_ASSIGN_PORT_MIN=8000 \
    AUTO_ASSIGN_PORT_MAX=8005 \
    PREFER_RELEASE_BUILDS=true \
    ENABLE_REDIS=false \
    ENABLE_WEB_UPDATER=false \
    INIT_BASE_URL=https://azuracast-production-0c14.up.railway.app \
    PORT=8080

# Limpiar configuraciones existentes
RUN rm -rf /etc/supervisor/conf.d/* && \
    rm -rf /etc/nginx/sites-enabled/* && \
    rm -rf /etc/nginx/conf.d/*

# Configurar supervisord
COPY <<-"EOF" /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true
user=root
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid

[unix_http_server]
file=/var/run/supervisor.sock
chmod=0700

[rpcinterface:supervisor]
supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock

[program:nginx]
command=/usr/sbin/nginx -g 'daemon off;'
autostart=true
autorestart=true
priority=10
stdout_events_enabled=true
stderr_events_enabled=true
EOF

# Configurar nginx
COPY <<-"EOF" /etc/nginx/conf.d/default.conf
server {
    listen 8080;
    server_name _;
    root /var/azuracast/www/web;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
EOF

EXPOSE 8080
EXPOSE 8000-8005

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/api/nowplaying_static/admin.json || exit 1

CMD ["/usr/local/bin/my_init"]
