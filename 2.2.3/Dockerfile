FROM ubuntu:16.04

ENV OS_FAMILY ubuntu
ENV OS_VERSION 16.04

ENV RIAK_VERSION 2.2.3
ENV RIAK_HOME /usr/lib/riak
ENV RIAK_FLAVOR KV

#RUN apt-get update; apt-get upgrade -y; apt-get install -y curl

#RUN curl -s https://packagecloud.io/install/repositories/basho/riak/script.deb.sh | bash
#RUN apt-get -y install riak

# Install Riak
ARG DEBIAN_FRONTEND=noninteractive
# Better store in git-lfs rather than expecting another bankruptcy
#COPY 2.2.3/riak_2.2.3* ./
#RUN apt-get update && \
#    apt-get upgrade -y && \
#    apt-get install -y --no-install-recommends curl iproute2 sudo logrotate libssl1.0.0 && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/* && \
#    sha256sum -c riak_2.2.3-1_amd64.deb.sha && \
#    dpkg -i riak_2.2.3-1_amd64.deb && \
#    rm -fv riak_2.2.3-1_amd64.deb*

# Or, maybe not
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl iproute2 sudo logrotate libssl1.0.0 wget && \
    wget \
http://s3.amazonaws.com/downloads.basho.com/basho-internal/riak/2.2/2.2.3/ubuntu/xenial/riak_2.2.3-1_amd64.deb.sha \
http://s3.amazonaws.com/downloads.basho.com/basho-internal/riak/2.2/2.2.3/ubuntu/xenial/riak_2.2.3-1_amd64.deb && \
    sha256sum -c riak_2.2.3-1_amd64.deb.sha && \
    dpkg -i riak_2.2.3-1_amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* riak_2.2.3-1_amd64.deb*

# Expose default ports
EXPOSE 8087
EXPOSE 8098

# Expose volumes for data and logs
VOLUME /var/log/riak
VOLUME /var/lib/riak

# Copy riak startup script and configuration files
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY docker-riak.conf.sh /etc/riak/prestart.d/riak.conf.sh
COPY docker-riak-limits.conf.sh /etc/riak/prestart.d/riak.limits.conf.sh
COPY docker-advanced.config.sh /etc/riak/prestart.d/advanced.config.sh
COPY riak-env.sh /usr/lib/riak/lib/env.sh

# Prepare for bootstrapping schemas
RUN mkdir -p /etc/riak/schemas

# Clean up APT cache
RUN rm -rf /var/lib/apt/lists/* /tmp/*

WORKDIR /var/lib/riak

ENTRYPOINT ["/docker-entrypoint.sh"]
