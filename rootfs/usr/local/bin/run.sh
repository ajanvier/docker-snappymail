#!/bin/sh

# Set attachment size limit
sed -i "s/<UPLOAD_MAX_SIZE>/$UPLOAD_MAX_SIZE/g" /etc/php82/php-fpm.conf /etc/nginx/nginx.conf
sed -i "s/<MEMORY_LIMIT>/$MEMORY_LIMIT/g" /etc/php82/php-fpm.conf

# Set log output to STDOUT if wanted (LOG_TO_STDOUT=true)
if [ "$LOG_TO_STDOUT" = true ]; then
  echo "[INFO] Logging to stdout activated"
  chmod o+w /dev/stdout
  sed -i "s/.*error_log.*$/error_log \/dev\/stdout warn;/" /etc/nginx/nginx.conf
  sed -i "s/.*error_log.*$/error_log = \/dev\/stdout/" /etc/php82/php-fpm.conf
fi

# Secure cookies
if [ "${SECURE_COOKIES}" = true ]; then
    echo "[INFO] Secure cookies activated"
        {
        	echo 'session.cookie_httponly = On';
        	echo 'session.cookie_secure = On';
        	echo 'session.use_only_cookies = On';
        } > /etc/php82/conf.d/cookies.ini;
fi

SNAPPYMAIL_CONFIG_FILE=/snappymail/data/_data_/_default_/configs/application.ini
if [ ! -f "$SNAPPYMAIL_CONFIG_FILE" ]; then
    echo "[INFO] Creating default Snappymail configuration"
    mkdir -p $(dirname $SNAPPYMAIL_CONFIG_FILE)
    cp /usr/local/include/application.ini $SNAPPYMAIL_CONFIG_FILE
fi

if [ "${LOG_TO_STDOUT}" = true ]; then
  sed -z 's/\; Enable logging\nenable = Off/\; Enable logging\nenable = On/' -i $SNAPPYMAIL_CONFIG_FILE
  sed 's/^filename = .*/filename = "errors.log"/' -i $SNAPPYMAIL_CONFIG_FILE
  sed 's/^write_on_error_only = .*/write_on_error_only = Off/' -i $SNAPPYMAIL_CONFIG_FILE
  sed 's/^write_on_php_error_only = .*/write_on_php_error_only = On/' -i $SNAPPYMAIL_CONFIG_FILE
else
    sed -z 's/\; Enable logging\nenable = On/\; Enable logging\nenable = Off/' -i $SNAPPYMAIL_CONFIG_FILE
fi
# Always enable snappymail Auth logging
sed 's/^auth_logging = .*/auth_logging = On/' -i $SNAPPYMAIL_CONFIG_FILE
sed 's/^auth_logging_filename = .*/auth_logging_filename = "auth.log"/' -i $SNAPPYMAIL_CONFIG_FILE
sed 's/^auth_logging_format = .*/auth_logging_format = "[{date:Y-m-d H:i:s}] Auth failed: ip={request:ip} user={imap:login} host={imap:host} port={imap:port}"/' -i $SNAPPYMAIL_CONFIG_FILE
# Redirect snappymail logs to stderr/stdout
mkdir -p /snappymail/data/_data_/_default_/logs/
# empty logs
cp /dev/null /snappymail/data/_data_/_default_/logs/errors.log
cp /dev/null /snappymail/data/_data_/_default_/logs/auth.log

# Fix permissions
chown -R $UID:$GID /snappymail/data /services /var/log /var/lib/nginx

# RUN !
exec su-exec $UID:$GID /bin/s6-svscan /services
