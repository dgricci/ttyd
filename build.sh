#!/bin/bash

# Exit on any non-zero status.
trap 'exit' ERR
set -E

echo "Compiling LWS${LWS_VERSION}..."
01-install.sh
apt-get -qy --no-install-recommends install \
    libssl-dev \
    zlib1g-dev \
    libnghttp2-dev \
    unzip

# Compiling LBS_WITH_HTTP_PROXY implies installing hubbub : http://www.netsurf-browser.org/projects/hubbub/
# Compiling WITH_IPV6 generates :
# /tmp/libwebsockets-2.1.1/lib/libwebsockets.c:645:4: error: too many arguments for format [-Werror=format-extra-args]
#   lwsl_err("inet_ntop", strerror(LWS_ERRNO));                                                                                                                         
#   ^                                                                                                                                                                   
# Compiling WITH_SMTP generates :
#/tmp/libwebsockets-2.1.1/lib/smtp.c: In function ‘lwsgs_email_on_connect’:
#/tmp/libwebsockets-2.1.1/lib/smtp.c:149:29: error: passing argument 2 of ‘uv_read_start’ from incompatible pointer type [-Werror]
#  uv_read_start(req->handle, alloc_buffer, lwsgs_email_read);
#                             ^
#In file included from /tmp/libwebsockets-2.1.1/lib/private-libwebsockets.h:201:0,
#                 from /tmp/libwebsockets-2.1.1/lib/smtp.c:22:
# Compiling WITH_LIBUV generates :
#/usr/include/uv.h:599:15: note: expected ‘uv_alloc_cb’ but argument is of type ‘void (*)(struct uv_handle_t *, size_t,  struct uv_buf_t *)’
# UV_EXTERN int uv_read_start(uv_stream_t*, uv_alloc_cb alloc_cb,
#               ^
#/tmp/libwebsockets-2.1.1/lib/smtp.c:149:43: error: passing argument 3 of ‘uv_read_start’ from incompatible pointer type [-Werror]
#  uv_read_start(req->handle, alloc_buffer, lwsgs_email_read);
#                                           ^
#In file included from /tmp/libwebsockets-2.1.1/lib/private-libwebsockets.h:201:0,
#                 from /tmp/libwebsockets-2.1.1/lib/smtp.c:22:
#/usr/include/uv.h:599:15: note: expected ‘uv_read_cb’ but argument is of type ‘void (*)(struct uv_stream_s *, ssize_t,  const struct uv_buf_t *)’
# UV_EXTERN int uv_read_start(uv_stream_t*, uv_alloc_cb alloc_cb,
#               ^
#/tmp/libwebsockets-2.1.1/lib/smtp.c: In function ‘uv_timeout_cb_email’:
#/tmp/libwebsockets-2.1.1/lib/smtp.c:175:7: error: too many arguments to function ‘uv_ip4_addr’
#   if (uv_ip4_addr(email->email_smtp_ip, 25, &req_addr)) {
#       ^
#In file included from /tmp/libwebsockets-2.1.1/lib/private-libwebsockets.h:201:0,
#                 from /tmp/libwebsockets-2.1.1/lib/smtp.c:22:
#/usr/include/uv.h:1800:30: note: declared here
# UV_EXTERN struct sockaddr_in uv_ip4_addr(const char* ip, int port);
#                              ^
#/tmp/libwebsockets-2.1.1/lib/smtp.c:175:7: error: used struct type value where scalar is required
#   if (uv_ip4_addr(email->email_smtp_ip, 25, &req_addr)) {
#       ^
#/tmp/libwebsockets-2.1.1/lib/smtp.c:185:3: error: incompatible type for argument 3 of ‘uv_tcp_connect’
#   uv_tcp_connect(&email->email_connect_req, &email->email_client,
#   ^
#In file included from /tmp/libwebsockets-2.1.1/lib/private-libwebsockets.h:201:0,
#                 from /tmp/libwebsockets-2.1.1/lib/smtp.c:22:
#/usr/include/uv.h:726:15: note: expected ‘struct sockaddr_in’ but argument is of type ‘struct sockaddr *’
# UV_EXTERN int uv_tcp_connect(uv_connect_t* req, uv_tcp_t* handle,
#               ^
# Removing LWS_WITH_LIBUV implies removal of LWS_WITH_PLUGINS and LWS_WITH_GENERIC_SESSIONS
# then LWS_WITH_SQLITE3 becomes also useless ...

NPROC=$(nproc)
curl -fsSL "$LWS_DOWNLOAD_URL" -o lws.zip
unzip lws.zip
rm -f lws.zip
{
    cd libwebsockets-$LWS_VERSION/ ; \
    mkdir build ; \
    cd build ; \
    cmake \
        -DCMAKE_INSTALL_PREFIX:PATH=/usr \
        -DCMAKE_C_FLAGS="" \
        -DLIB_SUFFIX=64 \
        -DLWS_WITH_STATIC=ON \
        -DLWS_WITH_SHARED=ON \
        -DLWS_WITH_SSL=ON \
        -DLWS_USE_CYASSL=OFF \
        -DLWS_USE_WOLFSSL=OFF \
        -DLWS_WITH_ZLIB=ON \
        -DLWS_WITH_LIBEV=OFF \
        -DLWS_WITH_LIBUV=OFF \
        -DLWS_SSL_CLIENT_USE_OS_CA_CERTS=ON \
        -DLWS_WITHOUT_BUILTIN_GETIFADDRS=OFF \
        -DLWS_WITHOUT_BUILTIN_SHA1=OFF \
        -DLWS_WITHOUT_CLIENT=OFF \
        -DLWS_WITHOUT_SERVER=OFF \
        -DLWS_LINK_TESTAPPS_DYNAMIC=OFF \
        -DLWS_WITHOUT_TESTAPPS=OFF \
        -DLWS_WITHOUT_TEST_SERVER=OFF \
        -DLWS_WITHOUT_TEST_SERVER_EXTPOLL=OFF \
        -DLWS_WITHOUT_TEST_PING=OFF \
        -DLWS_WITHOUT_TEST_ECHO=OFF \
        -DLWS_WITHOUT_TEST_CLIENT=OFF \
        -DLWS_WITHOUT_TEST_FRAGGLE=OFF \
        -DLWS_WITHOUT_EXTENSIONS=OFF \
        -DLWS_WITH_LATENCY=OFF \
        -DLWS_WITHOUT_DAEMONIZE=ON \
        -DLWS_IPV6=OFF \
        -DLWS_UNIX_SOCK=ON \
        -DLWS_WITH_HTTP2=ON \
        -DLWS_MBED3=OFF \
        -DLWS_SSL_SERVER_WITH_ECDH_CERT=OFF \
        -DLWS_WITH_CGI=ON \
        -DLWS_WITH_HTTP_PROXY=OFF \
        -DLWS_WITH_LWSWS=OFF \
        -DLWS_WITH_PLUGINS=OFF \
        -DLWS_WITH_ACCESS_LOG=OFF \
        -DLWS_WITH_SERVER_STATUS=OFF \
        -DLWS_WITH_LEJP=OFF \
        -DLWS_WITH_LEJP_CONF=OFF \
        -DLWS_WITH_GENERIC_SESSIONS=OFF \
        -DLWS_WITH_SQLITE3=OFF \
        -DLWS_WITH_SMTP=OFF \
        -DLWS_WITH_ESP8266=OFF \
        -DLWS_WITH_NO_LOGS=OFF \
        -DLWS_STATIC_PIC=OFF \
        .. && \
        make -j$NPROC > make.log 2>&1 && \
        make install ; \
    ldconfig ; \
    ln -s /usr/lib64/libwebsockets.so.9 /usr/lib/libwebsockets.so.9 ; \
    ln -s /usr/lib64/libwebsockets.so.9 /usr/lib/libwebsockets.so ; \
    ln -s /usr/lib64/libwebsockets.a /usr/lib/libwebsockets.a ; \
    tar czf /libwebsockets-${LWS_VERSION}.tgz /usr/lib64/libwebsockets.* /usr/include/libwebsockets.h /usr/include/lws_config.h ; \
    cd ../.. ; \
    rm -fr libwebsockets-$LWS_VERSION/ ; \
}

# install dependencies for ttyd :
# warning : as we have compiled libwebsockets, the package will not be found !
apt-get -qy --no-install-recommends install \
        libjson-c-dev \
        vim-common
curl -fsSL "$TTYD_DOWNLOAD_URL" -o ttyd.zip
unzip ttyd.zip
rm -f ttyd.zip
{ \
    cd ttyd-$TTYD_VERSION/ ; \
    mkdir build ; \
    cd build ; \
    sed -i -e 's/\(pkg_check_modules(Libwebsockets\)/#\1/' ../CMakeLists.txt ; \
    cmake \
        -DCMAKE_INSTALL_PREFIX:PATH=/usr \
        -DLIB_SUFFIX=64 \
        -DLIBWEBSOCKETS_INCLUDEDIR=/usr/include \
        -DLIBWEBSOCKETS_LIBDIR=/usr/lib \
        .. && \
    make -j$NPROC > make.log 2>&1 && \
    make install ; \
    ldconfig ; \
    tar czf /ttyd-${TTYD_VERSION}.tgz /usr/bin/ttyd ; \
    cd ../.. ; \
    rm -fr ttyd-$TTYD_VERSION/ ; \
}

# uninstall :
# removal of :
#        libev-dev \
#        libuv0.10-dev \
#        libsqlite3-dev \
apt-get purge -y --auto-remove \
    libssl-dev \
    zlib1g-dev \
    libnghttp2-dev \
    unzip
01-uninstall.sh y

exit 0

