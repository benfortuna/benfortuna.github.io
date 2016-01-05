---
layout: post
title: Local proxy server with Docker
---
There is a lot of useful software available, but sometimes the effort required to install and configure can outweigh the benefits. Web proxy servers can be useful for a number of reasons, not least of which is local caching of data to improve performance and reduce bandwidth consumption. Whilst web browsers may perform such data caching quite well, the browser is not the only application connecting to the Internet, and we can still realise benefits from running a local web proxy server.

Squid is a well-known web proxy in widespread use across many organisations. Whilst it can take some effort to configure Squid in a traditional sense, running in Docker is quite trivial:

```
$ docker run -d -p 3128:3128 --volume /tmp/squid:/var/spool/squid3 sameersbn/squid
```

You can then configure your proxy as `https://localhost:3128` and see instant results.
