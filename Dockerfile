FROM alpine:3.16

LABEL description "SnappyMail is a simple, modern, lightweight & fast web-based client"

ARG GPG_FINGERPRINT="1016 E470 7914 5542 F8BA  1335 4820 8BA1 3290 F3EB"

ENV UID=991 GID=991 UPLOAD_MAX_SIZE=25M LOG_TO_STDOUT=false MEMORY_LIMIT=128M

# Installing packages
RUN echo "@community https://dl-cdn.alpinelinux.org/alpine/v3.16/community" >> /etc/apk/repositories \
 && apk -U upgrade \
 && apk add -t build-dependencies \
    gnupg \
    wget \
    curl \
 && apk add \
    ca-certificates \
    nginx \
    s6 \
    su-exec \
    php81-fpm@community \
    php81-mbstring@community \
    php81-zlib@community \
    php81-json@community \
    php81-xml@community \
    php81-simplexml@community \
    php81-dom@community \
    php81-curl@community \
    php81-exif@community \
    php81-gd@community \
    php81-iconv@community \
    php81-intl@community \
    php81-ldap@community \
    php81-pdo_pgsql@community \
    php81-pdo_mysql@community \
    php81-pdo_sqlite@community \
    php81-sqlite3@community \
    php81-tidy \
    php81-pecl-uuid \
    php81-zip

# Downloading latest snappymail release
RUN cd /tmp \
 && SNAPPYMAIL_VER=$(basename $(curl -fs -o/dev/null -w %{redirect_url} https://github.com/the-djmaze/snappymail/releases/latest) | cut -c2-) \
 && SNAPPYMAIL_TGZ="snappymail-${SNAPPYMAIL_VER}.tar.gz" \
 && wget -q -O /usr/local/include/application.ini https://raw.githubusercontent.com/the-djmaze/snappymail/master/.docker/release/files/usr/local/include/application.ini \
 && wget -q -O snappymail-latest.tar.gz https://github.com/the-djmaze/snappymail/releases/download/v${SNAPPYMAIL_VER}/${SNAPPYMAIL_TGZ} \
 && wget -q -O snappymail-latest.tar.gz.asc https://github.com/the-djmaze/snappymail/releases/download/v${SNAPPYMAIL_VER}/${SNAPPYMAIL_TGZ}.asc \
 && wget -q https://raw.githubusercontent.com/the-djmaze/snappymail/master/build/SnappyMail.asc \
 && gpg --import SnappyMail.asc \
 && FINGERPRINT="$(LANG=C gpg --verify snappymail-latest.tar.gz.asc snappymail-latest.tar.gz 2>&1 \
  | sed -n "s#Primary key fingerprint: \(.*\)#\1#p")" \
 && if [ -z "${FINGERPRINT}" ]; then echo "ERROR: Invalid GPG signature!" && exit 1; fi \
 && if [ "${FINGERPRINT}" != "${GPG_FINGERPRINT}" ]; then echo "ERROR: Wrong GPG fingerprint!" && exit 1; fi \
 && mkdir /snappymail && tar xvf /tmp/snappymail-community-latest.zip -d /snappymail \
 && find /snappymail -type d -exec chmod 755 {} \; \
 && find /snappymail -type f -exec chmod 644 {} \;

# Removing install dependencies
RUN apk del build-dependencies wget curl \
 && rm -rf /tmp/* /var/cache/apk/* /root/.gnupg

COPY rootfs /
RUN chmod +x /usr/local/bin/run.sh /services/*/run /services/.s6-svscan/*
VOLUME /snappymail/data
EXPOSE 8888
CMD ["run.sh"]
