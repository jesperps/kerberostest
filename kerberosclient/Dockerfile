FROM debian

ARG PROXY

ENV http_proxy=${PROXY} https_proxy=${PROXY}

RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        krb5-config \
        libkrb5-26-heimdal \
        heimdal-clients \
        heimdal-kcm \
   

