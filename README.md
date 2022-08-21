# ajanvier/docker-snappymail
![Docker Image Size](https://img.shields.io/docker/image-size/ajanvier/snappymail)
![Docker Pulls](https://img.shields.io/docker/pulls/ajanvier/snappymail)
![Docker Latest Version](https://img.shields.io/docker/v/ajanvier/snappymail?sort=semver)


<img src="https://icons.duckduckgo.com/ip3/hub.docker.com.ico"  width="16px" /> Docker Hub : https://hub.docker.com/r/ajanvier/snappymail

![](https://snappymail.eu/static/img/logo-256x256.png)

### What is this ?

Snappymail is a simple, modern & fast web-based client. More details on the [official website](https://snappymail.eu/).

### Features

- Lightweight & secure image (no root process)
- Based on Alpine
- Latest Snappymail (stable)
- Contacts (DB) : sqlite, mysql or pgsql (server not built-in)
- With Nginx and PHP 8.1

### Build-time variables

- **GPG_FINGERPRINT** : fingerprint of signing key

### Ports

- **8888**

### Environment variables

| Variable | Description | Type | Default value |
| -------- | ----------- | ---- | ------------- |
| **UID** | snappymail user id | *optional* | 991
| **GID** | snappymail group id | *optional* | 991
| **UPLOAD_MAX_SIZE** | Attachment size limit | *optional* | 25M
| **LOG_TO_STDOUT** | Enable nginx, php and snappymail error logs to stdout | *optional* | false
| **MEMORY_LIMIT** | PHP memory limit | *optional* | 128M

### Docker-compose.yml

```yml
# Full example :
# https://github.com/mailserver2/mailserver/blob/master/docker-compose.sample.yml

snappymail:
  image: ajanvier/snappymail
  container_name: snappymail
  volumes:
    - /mnt/docker/snappymail:/snappymail/data
  depends_on:
    - mailserver
```
