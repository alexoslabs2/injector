FROM alpine:latest

MAINTAINER Alexos Core Labs <alexoslabs@gmail.com>

RUN apk add --update python3 git

RUN git clone https://github.com/sqlmapproject/sqlmap.git

WORKDIR /sqlmap

ENTRYPOINT ["python", "sqlmap.py"]
