FROM alpine:3.19

LABEL description "SnappyMail is a simple, modern, lightweight & fast web-based client"

ARG SNAPPYMAIL_VER
ARG REPOSITORY="the-djmaze/snappymail"
ARG GPG_FINGERPRINT="1016 E470 7914 5542 F8BA  1335 4820 8BA1 3290 F3EB"

ENV UID=991 GID=991 UPLOAD_MAX_SIZE=25M LOG_TO_STDOUT=false MEMORY_LIMIT=128M

# Installing packages
RUN echo "@community https://dl-cdn.alpinelinux.org/alpine/v3.19/community" >> /etc/apk/repositories \
  && apk update \
 && apk -U upgrade \
 && apk add -t build-dependencies \
    gnupg \
    wget \
    curl \
 && apk add \
    sed \
    ca-certificates \
    nginx \
    s6 \
    su-exec \
    php82-fpm@community \
    php82-curl@community \
    php82-ctype@community \
    php82-dom@community \
    php82-exif@community \
    php82-gd@community \
    php82-fileinfo@community \
    php82-iconv@community \
    php82-intl@community \
    php82-json@community \
    php82-ldap@community \
    php82-mbstring@community \
    php82-opcache@community \
    php82-pdo_mysql@community \
    php82-pdo_pgsql@community \
    php82-pdo_sqlite@community \
    php82-pecl-uuid@community \
    php82-phar@community \
    php82-simplexml@community \
    php82-sqlite3@community \
    php82-tidy@community \
    php82-xml@community \
    php82-zip@community \
    php82-zlib@community

# Downloading latest snappymail release
RUN cd /tmp \
 && SNAPPYMAIL_TGZ="snappymail-${SNAPPYMAIL_VER}.tar.gz" \
 && wget -q -O snappymail-latest.tar.gz https://github.com/$REPOSITORY/releases/download/v${SNAPPYMAIL_VER}/${SNAPPYMAIL_TGZ} \
 && wget -q -O snappymail-latest.tar.gz.asc https://github.com/$REPOSITORY/releases/download/v${SNAPPYMAIL_VER}/${SNAPPYMAIL_TGZ}.asc \
 && wget -q https://raw.githubusercontent.com/$REPOSITORY/master/build/SnappyMail.asc \
 && gpg --import SnappyMail.asc \
 && FINGERPRINT="$(LANG=C gpg --verify snappymail-latest.tar.gz.asc snappymail-latest.tar.gz 2>&1 \
  | sed -n 's#Primary key fingerprint: \(.*\)#\1#p')" \
 && if [ -z "${FINGERPRINT}" ]; then echo "ERROR: Invalid GPG signature!" && exit 1; fi \
 && if [ "${FINGERPRINT}" != "${GPG_FINGERPRINT}" ]; then echo "ERROR: Wrong GPG fingerprint!" && exit 1; fi \
 && mkdir /snappymail && tar xf /tmp/snappymail-latest.tar.gz -C /snappymail \
 && find /snappymail -type d -exec chmod 755 {} \; \
 && find /snappymail -type f -exec chmod 644 {} \;

# Removing install dependencies
RUN apk del build-dependencies curl \
 && rm -rf /tmp/* /var/cache/apk/* /root/.gnupg

COPY rootfs /
RUN chmod +x /usr/local/bin/run.sh /services/*/run /services/.s6-svscan/*
VOLUME /snappymail/data
EXPOSE 8888
CMD ["run.sh"]
