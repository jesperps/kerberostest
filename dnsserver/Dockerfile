FROM centos

ARG PROXY

ENV BIND_USER=bind \
    DATA_DIR=/data \
    http_proxy=${PROXY} https_proxy=${PROXY}

RUN yum update -y \
 && yum install bind bind-utils -y
