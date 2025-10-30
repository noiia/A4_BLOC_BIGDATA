FROM alpine:3.20

RUN apk add --no-cache bash curl

RUN curl -L -o /usr/local/bin/garage \
    https://garagehq.deuxfleurs.fr/_releases/v2.1.0/x86_64-unknown-linux-musl/garage \
    && chmod +x /usr/local/bin/garage


COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
