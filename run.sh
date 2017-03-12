#!/bin/bash
LWSV="2.1.1"
TTYV="1.3.0"
I1="dgricci/ttyd:build"
I2="dgricci/ttyd:$(< VERSION)"
ID=$(docker images --format "{{.Repository}}:{{.Tag}};{{.ID}}" | grep "${I1}" | cut -d\; -s -f2)
[ ! -z "${ID}" ] && docker rmi ${ID}
docker build -t ${I1} -f Dockerfile-build --build-arg LWS_VERSION=${LWSV} --build-arg TTYD_VERSION=${TTYV} .
docker run --rm -a stdout ${I1} /bin/cat /libwebsockets-${LWSV}.tgz > ./libwebsockets-${LWSV}.tgz
docker run --rm -a stdout ${I1} /bin/cat /ttyd-${TTYV}.tgz > ./ttyd-${TTYV}.tgz
docker rmi ${I1}
ID=$(docker images --format "{{.Repository}}:{{.Tag}};{{.ID}}" | grep "${I2}" | cut -d\; -s -f2)
[ ! -z "${ID}" ] && docker rmi ${I2}
docker build -t dgricci/ttyd:$(< VERSION)  --build-arg LWS_VERSION=${LWSV} --build-arg TTYD_VERSION=${TTYV} .
docker tag dgricci/ttyd:$(< VERSION) dgricci/ttyd:latest
#
# $ ttyd -p 8080 bash -x
# $ firefox http://localhost:8080
#
exit 0

