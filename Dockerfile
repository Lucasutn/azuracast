FROM azuracast/azuracast:stable

ENV PUID=1000 \
    PGID=1000 \
    APPLICATION_ENV=production \
    AUTO_ASSIGN_PORT_MIN=8000 \
    AUTO_ASSIGN_PORT_MAX=8005 \
    PREFER_RELEASE_BUILDS=true \
    COMPOSER_PLUGIN_MODE=false \
    ENABLE_REDIS=false \
    ENABLE_WEB_UPDATER=false \
    INIT_BASE_URL=https://azuracast-production-0c14.up.railway.app \
    PORT=3000

EXPOSE 80
EXPOSE 8000-8005

# Configurar nginx para usar el puerto correcto
RUN mkdir -p /etc/nginx/conf.d && \
    echo "server { \n\
    listen 3000; \n\
    root /var/azuracast/www/web; \n\
    index index.php; \n\
    server_name _; \n\
    location / { \n\
        try_files \$uri \$uri/ /index.php?\$args; \n\
    } \n\
    location ~ \.php$ { \n\
        fastcgi_pass unix:/var/run/php-fpm.sock; \n\
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; \n\
        include fastcgi_params; \n\
    } \n\
}" > /etc/nginx/conf.d/default.conf

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/api/nowplaying_static/admin.json || exit 1

CMD ["/usr/local/bin/my_init"]
