FROM azuracast/azuracast:stable

ENV PUID=1000 \
    PGID=1000 \
    APPLICATION_ENV=production \
    AUTO_ASSIGN_PORT_MIN=8000 \
    AUTO_ASSIGN_PORT_MAX=8005 \
    MYSQL_RANDOM_ROOT_PASSWORD=yes \
    INIT_BASE_URL=https://azuracast-production-0c14.up.railway.app \
    PREFER_RELEASE_BUILDS=true \
    COMPOSER_PLUGIN_MODE=false \
    ENABLE_REDIS=false \
    MYSQL_HOST=127.0.0.1 \
    MYSQL_PORT=3306 \
    MYSQL_USER=azuracast \
    MYSQL_PASSWORD=azur4c4st \
    MYSQL_DATABASE=azuracast \
    ENABLE_WEB_UPDATER=false \
    ACME_EMAIL=your-email@example.com \
    LETSENCRYPT_HOST=azuracast-production-0c14.up.railway.app

EXPOSE 80
EXPOSE 8000-8005

CMD ["/usr/local/bin/my_init"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/api/nowplaying_static/admin.json || exit 1
