FROM alpine:latest

EXPOSE 8118 9050

RUN echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' \
    >> /etc/apk/repositories && \
    apk --update add privoxy tor@testing runit@testing

COPY service /etc/service/

RUN chmod +x -v /etc/service/tor/run && chmod +x /etc/service/privoxy/run

CMD ["runsvdir", "/etc/service"]
