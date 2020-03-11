FROM ubuntu:16.04

ENV OS_FAMILY ubuntu
ENV OS_VERSION 16.04

ENV RIAK_VERSION 2.2.3
ENV RIAK_HOME /usr/lib/riak
ENV RIAK_FLAVOR KV

RUN apt-get update; apt-get upgrade -y; apt-get install -y curl

RUN curl -s https://packagecloud.io/install/repositories/basho/riak/script.deb.sh | bash
RUN apt-get -y install riak

# Expose default ports
EXPOSE 8087
EXPOSE 8098

# Expose volumes for data and logs
VOLUME /var/log/riak
VOLUME /var/lib/riak

# Copy riak startup script and configuration files
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY docker-riak.conf.sh /etc/riak/prestart.d/riak.conf.sh
COPY docker-advanced.config.sh /etc/riak/prestart.d/advanced.config.sh
COPY riak-env.sh /usr/lib/riak/lib/env.sh

# Prepare for bootstrapping schemas
RUN mkdir -p /etc/riak/schemas

# Clean up APT cache
RUN rm -rf /var/lib/apt/lists/* /tmp/*

WORKDIR /var/lib/riak

ENTRYPOINT ["/docker-entrypoint.sh"]