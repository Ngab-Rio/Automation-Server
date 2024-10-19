FROM debian:10

RUN apt-get update && \
    apt-get install -y \
    bind9 \
    nginx \
    proftpd \
    samba \
    openssl \
    sudo \
    vim


RUN openssl req -x509 -days 365 -nodes -newkey rsa:2048 -keyout /home/myCA/certs/smkth18760.lab.key -out /home/myCA/private/smkth18760.lab.crt && openssl req -x509 -days 365 -nodes -newkey rsa:2048 -keyout /home/myCA/certs/uki.smkth18760.lab.key -out /home/myCA/private/uki.smkth18760.lab.crt

COPY setup_services.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

CMD ["/usr/local/bin/setup.sh"]
