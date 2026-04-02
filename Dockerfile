FROM alpine:3.23 AS docker-static
RUN apk --no-cache add curl tar \
    && curl -sSL https://download.docker.com/linux/static/stable/x86_64/docker-28.3.1.tgz | tar zx -C /tmp

FROM alpine:3.23
RUN apk --no-cache add bash dnsmasq incus-client=6.0.4-r2 ed
RUN mkdir -p /etc/dnsmasq-hosts.d
COPY --from=docker-static /tmp/docker/docker /usr/local/bin/docker
COPY run.sh /run.sh

LABEL org.opencontainers.image.source=https://github.com/johnnyxwan/container-dns
ENV INCUS_UPDATE_INTERVAL="300" DNS_DOMAIN="local." SUBNET="172.17.0.0/16" DOCKER_NETWORK="bridge"
EXPOSE 53/udp
ENTRYPOINT ["/run.sh"]
