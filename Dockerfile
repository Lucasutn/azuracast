FROM azuracast/azuracast:stable

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

# Modificar la configuración de supervisord para evitar conflictos de puerto
RUN sed -i 's/^port=.*/port=127.0.0.1:9001/' /etc/supervisor/supervisord.conf && \
    # Crear directorio para logs de supervisord
    mkdir -p /var/log/supervisor && \
    # Asegurarse de que nginx use el puerto correcto
    sed -i 's/listen 80/listen 8080/g' /etc/nginx/sites-enabled/default

EXPOSE 8080
EXPOSE 8000-8005

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/api/nowplaying_static/admin.json || exit 1

CMD ["/usr/local/bin/my_init"]
