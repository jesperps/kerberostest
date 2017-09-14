FROM debian

ARG PROXY
ARG REALM

ENV http_proxy=${PROXY} https_proxy=${PROXY}
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y heimdal-kdc heimdal-docs \
    && rm -f /var/lib/heimdal-kdc/heimdal.db /var/lib/heimdal-kdc/m-key \
    && kstash --random-key \
    && kadmin -l init --realm-max-ticket-life=unlimited --realm-max-renewable-life=unlimited ${REALM} \
    && kadmin -l add --max-ticket-life=1d --max-renewable-life=1w --pw-expiration-time=never --expiration-time=never --policy=default --password=password --attributes= testuser@${REALM} 
