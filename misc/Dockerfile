FROM alpine:3.20.0

ENV FTP_USER=foo \
    FTP_PASS=bar \
    GID=1000 \
    UID=1000

RUN apk add --no-cache --update \
    vsftpd==3.0.5-r2 \
    inotify-tools \
    util-linux \
    e2fsprogs \
    file

COPY [ "/src/vsftpd.conf", "/etc" ]
COPY [ "/src/docker-entrypoint.sh", "/" ]
COPY [ "monitor.sh", "/usr/local/bin/monitor.sh" ]
COPY [ "mount.sh", "/usr/local/bin/mount.sh" ]
COPY [ "flag", "/flag"]

RUN chmod +x /docker-entrypoint.sh /usr/local/bin/monitor.sh /usr/local/bin/mount.sh
RUN mkdir -p /var/log && touch /var/log/monitor.log /var/log/mount.log /var/log/monitor_error.log && chmod 666 /var/log/monitor.log /var/log/mount.log /var/log/monitor_error.log

RUN addgroup -g ${GID} ftpgroup
RUN adduser -D -h /home/${FTP_USER} -G ftpgroup -s /sbin/nologin -u ${UID} ${FTP_USER}
RUN echo "${FTP_USER}:${FTP_PASS}" | chpasswd

RUN mkdir -p /home/${FTP_USER}
RUN chown -R ${FTP_USER}:ftpgroup /home/${FTP_USER}
RUN chmod 555 /home/${FTP_USER}
RUN chmod 755 /home/${FTP_USER}

ENTRYPOINT [ "/docker-entrypoint.sh" ]
EXPOSE 20/tcp 21/tcp 40000-40009/tcp
HEALTHCHECK CMD netstat -lnt | grep :21 || exit 1
