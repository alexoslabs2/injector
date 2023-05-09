FROM alpine:latest

MAINTAINER Alexos Core Labs <alexoslabs@gmail.com>

ARG CACHEBUST=1

RUN apk add --update python3 git

RUN git clone https://github.com/sqlmapproject/sqlmap.git

WORKDIR /sqlmap

ENTRYPOINT ["python3", "sqlmap.py"]
