## Share your terminal over the web
# Cf. https://github.com/tsl0922/ttyd
FROM dgricci/jessie:0.0.4
MAINTAINER Didier Richard <didier.richard@ign.fr>

## arguments
ARG LWS_VERSION
ENV LWS_VERSION ${LWS_VERSION:-2.1.1}
ARG TTYD_VERSION
ENV TTYD_VERSION ${TTYD_VERSION:-1.3.0}

COPY libwebsockets-${LWS_VERSION}.tgz /tmp/libwebsockets-${LWS_VERSION}.tgz
COPY ttyd-${TTYD_VERSION}.tgz /tmp/ttyd-${TTYD_VERSION}.tgz

# install dependencies for libwebsockets and ttypd
RUN \
    apt-get -qy update && \
    apt-get -qy --no-install-recommends install \
        libssl1.0.0 \
        zlib1g \
        libnghttp2-5 \
        libjson-c2 \
        vim-common && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    { \
        echo "REMINDER : these lines override installation of host graphics drivers in /usr/lib64 when executed in the host (not in the build of the image !)" ; \
        cd / ; \
        tar xzf /tmp/libwebsockets-${LWS_VERSION}.tgz ; \
        ln -s /usr/lib64/libwebsockets.so.9 /usr/lib/libwebsockets.so.9 ; \
        ln -s /usr/lib64/libwebsockets.so.9 /usr/lib/libwebsockets.so ; \
        ln -s /usr/lib64/libwebsockets.a /usr/lib/libwebsockets.a ; \
        ldconfig ; \
        rm -f /tmp/libwebsockets-${LWS_VERSION}.tgz ; \
        tar xzf /tmp/ttyd-${TTYD_VERSION}.tgz ; \
        rm -f /tmp/ttyd-${TTYD_VERSION}.tgz ; \
    }

EXPOSE 7681

CMD ["ttyd", "--version"]

