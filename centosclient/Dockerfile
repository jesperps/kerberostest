FROM centos

ARG PROXY

ENV http_proxy=${PROXY} https_proxy=${PROXY}
RUN yum -y update \
    && yum -y install krb5-workstation
