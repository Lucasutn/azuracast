FROM azuracast/azuracast:stable

ENV PUID=1000 \
    PGID=1000 \
    APPLICATION_ENV=production \
    AUTO_ASSIGN_PORT_MIN=8000 \
    AUTO_ASSIGN_PORT_MAX=8005 \
    MYSQL_RANDOM_ROOT_PASSWORD=yes

EXPOSE 80
EXPOSE 443
EXPOSE 8000-8005

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/api/nowplaying_static/admin.json || exit 1

VOLUME ["/var/azuracast"]
