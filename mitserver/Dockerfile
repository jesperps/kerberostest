FROM centos

ARG PROXY

ENV http_proxy=${PROXY} https_proxy=${PROXY}
RUN yum -y update \
    && yum -y install krb5-server \ 
        krb5-libs \
        krb5-auth-dialog \
        krb5-workstation \
        krb5-libs \
        krb5-auth-dialog \
        krb5-pkinit-openssl
