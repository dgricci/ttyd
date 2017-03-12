% Share your terminal over the web
% Didier Richard
% 12/03/2017

---

revision:
    - 0.0.1 : 12/03/2017

---

Based on https://github.com/tsl0922/ttyd

# Building #

```bash
$ docker build -t dgricci/ttyd:$(< VERSION) .
$ docker tag dgricci/ttyd:$(< VERSION) dgricci/ttyd:latest
```

## Behind a proxy (e.g. 10.0.4.2:3128) ##

```bash
$ docker build \
    --build-arg http_proxy=http://10.0.4.2:3128/ \
    --build-arg https_proxy=http://10.0.4.2:3128/ \
    -t dgricci/ttyd:$(< VERSION) .
$ docker tag dgricci/ttyd:$(< VERSION) dgricci/ttyd:latest
```

# Use #

See `dgricci/jessie` README for handling permissions with dockers volumes.

```bash
$ docker run -it --rm -p 8080:7681 dgricci/ttyd:$(< VERSION) bash -x
$ firefox http://localhost:8080/
```

_Et voilà !_

_fin du document[^pandoc_gen]_

[^pandoc_gen]: document généré via $ `pandoc -V fontsize=10pt -V geometry:"top=2cm, bottom=2cm, left=1cm, right=1cm" -s -N --toc -o mapserver-ws.pdf README.md`{.bash}

