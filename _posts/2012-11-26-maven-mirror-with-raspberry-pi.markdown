---
layout: post
status: publish
published: true
title: Maven Mirror with Raspberry Pi
author:
  display_name: fortuna
  login: admin
  email: fortuna@micronode.com
  url: ''
author_login: admin
author_email: fortuna@micronode.com
wordpress_id: 161
wordpress_url: http://basepatterns.org/?p=161
date: '2012-11-26 12:24:17 +1100'
date_gmt: '2012-11-26 01:24:17 +1100'
categories:
- Hardware
tags: []
comments:
- id: 301
  author: Stuart
  author_email: stuartstephen@hotmail.com
  author_url: ''
  date: '2013-04-27 05:47:51 +1000'
  date_gmt: '2013-04-26 19:47:51 +1000'
  content: "I tried to run Nexus on my Raspberry Pi, but I got an error:\r\n\r\nroot@raspbmc:/usr/local/nexus/bin#
    ./nexus\r\nMissing platform binary: /usr/local/nexus-2.4.0-09/bin/../bin/jsw/linux-armv6l-32/wrapper\r\n\r\nI'm
    running it on my XBMC install of Raspbian.\r\n\r\nNot really sure where to go
    from here as I'm a bit of a Linux newbie(ish)."
- id: 302
  author: Stuart
  author_email: stuartstephen@hotmail.com
  author_url: ''
  date: '2013-04-27 05:54:36 +1000'
  date_gmt: '2013-04-26 19:54:36 +1000'
  content: Apologies. I think I am just misunderstanding Nexus as a WAR application.
---

Since having multiple computers at home from which I tinker with Java development (desktop, laptops, etc.), I have found it extremely useful to configure a Maven Mirror on my home server to consolidate artifact downloads from Maven Central and other snapshot repositories. This was achieved using [Apache Archiva], but other tools such as Artifactory or [Sonatype Nexus] would be just as good (if not better). The only problem I found with this approach is that I had to ensure the server was running before doing any dev work.

So I had an idea to get a [Raspberry Pi] that I could connect to my router, and provide the same repository mirror functionality that I was currently getting from my home server. Surprisingly, it actually works really well!

I was a bit worried that it might be too under-powered to manage running a tomcat instance serving up Nexus, but whilst being quite a bit slower that my home server (a dual-core AMD system) it seems to manage ok. I was fortunate enough to get the R-Pi Model B (512Mb), as I think it might struggle with just the 256Mb of the original R-Pi.

I zapped an SD Card with the [Soft-float Debian "wheezy"] install, as apparently the JVM requires this version. Then it was just a matter of installing tomcat (sudo apt-get intall tomcat7 tomcat7-admin), downloading the Nexus WAR file and deploying.

The R-Pi distributor, element14, also provide a nice [enclosure] that fits quite snugly and mounts on the wall (right next to my router). I have wanted an "always-on" home server for a while, and whilst it probably won't be able to manage too much heavy lifting, the R-Pi (with a power draw of 0.7A * 5V) shouldn't be too taxing on the power bill.

Other notables:


* The R-Pi Model B firmware needs to be [flashed] to see the full 512Mb
* The install consumes a bit over 2Gb total, leaving about 5Gb of space on an 8Gb SD Card. I probably should have used a bigger card..
* Enabling SSHD from the R-Pi config menu is handy (!) when running headless


[Apache Archiva]: http://archiva.apache.org
[Sonatype Nexus]: http://www.sonatype.org/nexus
[Raspberry Pi]: http://raspberrypi.org
[Soft-float Debian "wheezy"]: http://www.raspberrypi.org/downloads
[enclosure]: http://au.element14.com/jsp/search/productListing.jsp?SKUS=2113799,2113798&COM=rasp-accessory-group
[flashed]: https://github.com/Hexxeh/rpi-update/
