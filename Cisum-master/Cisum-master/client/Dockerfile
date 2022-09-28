FROM ubuntu:18.04

ENV PATH=/opt/flutter/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt-get update && \
    apt-get install -y \
        xz-utils \
        git \
        openssh-client \
        curl && \
    rm -rf /var/cache/apt

RUN curl -L https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v1.7.8+hotfix.4-stable.tar.xz | tar -C /opt -xJ

WORKDIR /client
COPY . .

WORKDIR /client/workspace

RUN apt-get install unzip

RUN flutter channel beta
RUN flutter upgrade
RUN flutter config --enable-web
RUN flutter doctor
RUN flutter devices

EXPOSE 9999
CMD [ "flutter", "run", "-d", "web-server", "--web-hostname", "0.0.0.0", "--web-port", "9999" ]