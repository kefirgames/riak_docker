FROM debian:buster-slim AS builder

# Builder environment
ENV GIT_BRANCH_RIAK riak-2.9.1
ENV GIT_BRANCH_OTP basho-otp-16
ENV APT_RUNTIME_DEPS "git libodbc1 wget"
ENV APT_BUILD_DEPS "autoconf curl ca-certificates dpkg-dev gcc libncurses-dev make unixodbc-dev"
ENV APT_RIAK_DEPS "build-essential libc6-dev libpam0g-dev"
ENV OPENSSL_VERSION 1.0.2u

# Install dependencies
RUN apt-get update
RUN apt-get install -y --no-install-recommends $APT_RUNTIME_DEPS $APT_BUILD_DEPS $APT_RIAK_DEPS

# Build OpenSSL
RUN wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz; tar -xf openssl-${OPENSSL_VERSION}.tar.gz;
RUN cd openssl-${OPENSSL_VERSION}; \
	./config shared no-krb5 -fPIC; \
	make depend; \
	make; \
	make install

# Build Basho's Erlang OTP-16	
RUN	git clone -n -b $GIT_BRANCH_OTP 'https://github.com/basho/otp.git' $GIT_BRANCH_OTP
RUN	cd $GIT_BRANCH_OTP; git checkout -q $GIT_BRANCH_OTP; \
	./otp_build setup -a --prefix=/usr/local \
		 				 --enable-m64-build \
						 --with-ssl \
						 --without-odbc \
						 --disable-hipe \
						 --enable-smp-support \
						 --enable-threads \
						 --enable-kernel-poll; \
	make install

# Get riak sources
RUN git clone -n -b $GIT_BRANCH_RIAK https://github.com/basho/riak.git $GIT_BRANCH_RIAK;

# Build riak
RUN cd $GIT_BRANCH_RIAK; git checkout -q $GIT_BRANCH_RIAK; make rel

#####################################################################
# Riak image
FROM debian:buster-slim

ENV RIAK_HOME /usr/lib/riak
ENV RIAK_VERSION 2.9.0
ENV RIAK_SRC_PATH /riak-2.9.0p5

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
COPY --from=builder $RIAK_SRC_PATH/rel/riak/bin/riak* /usr/sbin/
COPY --from=builder $RIAK_SRC_PATH/rel/riak/erts-5.10.3 /usr/lib/riak/erts-5.10.3
COPY --from=builder $RIAK_SRC_PATH/rel/riak/lib /usr/lib/riak/lib
COPY --from=builder $RIAK_SRC_PATH/rel/riak/releases /usr/lib/riak/releases
COPY --from=builder /usr/local/ssl /usr/local/ssl


WORKDIR /var/lib/riak

ENTRYPOINT ["/docker-entrypoint.sh"]
