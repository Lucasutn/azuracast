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

# Asegurarse de que supervisord use los puertos correctos
RUN sed -i 's/80:80/3000:80/' /etc/nginx/conf.d/default.conf

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/api/nowplaying_static/admin.json || exit 1

CMD ["/usr/local/bin/my_init"]
