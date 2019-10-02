FROM debian:buster-slim AS builder
# Builder environment

# Install dependencies
RUN set -xe; \
	runtimeDeps=' \
		libodbc1 \
		wget \
		git \
	'; \
	buildDeps=' \
		curl \
		ca-certificates \
		autoconf \
		dpkg-dev \
		gcc \
		make \
		libncurses-dev \
		unixodbc-dev \
	'; \
	riakDeps=' \
		build-essential \
		libc6-dev \
		libpam0g-dev \
	'; \
	apt-get update; \
	apt-get install -y --no-install-recommends $runtimeDeps $buildDeps $riakDeps

# Build OpenSSL 1.0.2 
RUN wget https://www.openssl.org/source/openssl-1.0.2t.tar.gz; tar -xf openssl-1.0.2t.tar.gz; \
	cd openssl-1.0.2t; ./config shared no-krb5 -fPIC; \
	make depend; \
	make; \
	make install

# Build Basho's Erlang OTP-16	
RUN	git clone -b 'basho-otp-16' 'https://github.com/basho/otp.git' 'otp-16'
RUN	cd otp-16; \
	./otp_build setup -a --prefix=/usr/local \
		 				 --enable-m64-build \
						 --with-ssl \
						 --without-odbc \
						 --disable-hipe \
						 --enable-smp-support \
						 --enable-threads \
						 --enable-kernel-poll

RUN cd otp-16; make install

# Build riak
RUN wget https://github.com/basho/riak/archive/riak-2.9.0p3.tar.gz; \
	tar -xf riak-2.9.0p3.tar.gz
RUN cd riak-riak-2.9.0p3; make rel

#####################################################################
# Riak image
FROM debian:buster-slim

ENV RIAK_HOME /usr/lib/riak
ENV RIAK_VERSION 2.9.0
ENV RIAK_SRC_PATH riak-riak-2.9.0p3

# Expose default ports
EXPOSE 8087
EXPOSE 8098

# Prepare directrories
RUN mkdir -p /etc/riak/schemas /etc/riak/prestart.d /etc/riak/poststart.d /usr/lib/riak/ /var/lib/riak /var/log/riak

# Create riak user/group
RUN groupadd -g 105 riak; \
	useradd -u 102 -g 105 -c "Riak user" -d /var/lib/riak riak; \
	chown -R riak:riak /var/lib/riak /var/log/riak

# Install riak deps
RUN apt-get update; \
	apt-get install -y libncurses6; \
	apt-get clean; \
	rm -rf /var/lib/apt/lists/*

# Copy riak startup script and configuration files
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY docker-riak.conf.sh /etc/riak/prestart.d/riak.conf.sh
COPY docker-advanced.config.sh /etc/riak/prestart.d/advanced.config.sh
COPY riak-env.sh /usr/lib/env.sh

# Copy riak sources
COPY --from=builder /$RIAK_SRC_PATH/rel/riak/bin/riak* /usr/sbin/
COPY --from=builder /$RIAK_SRC_PATH/rel/riak/erts-5.10.3 /usr/lib/riak/erts-5.10.3
COPY --from=builder /$RIAK_SRC_PATH/rel/riak/lib /usr/lib/riak/lib
COPY --from=builder /$RIAK_SRC_PATH/rel/riak/releases /usr/lib/riak/releases

WORKDIR /var/lib/riak

ENTRYPOINT ["/docker-entrypoint.sh"]
