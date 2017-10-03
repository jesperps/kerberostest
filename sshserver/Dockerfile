FROM centos

ARG PROXY
ARG PW
ENV http_proxy=${PROXY} https_proxy=${PROXY}
RUN yum -y update \
    && yum -y install \
        krb5-workstation \
        openssh-server \
    && /usr/bin/ssh-keygen -A \
    && useradd testuser
