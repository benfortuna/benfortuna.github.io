---
layout: post
status: publish
published: true
title: Prevent multiple instances of an application
author:
  display_name: fortuna
  login: admin
  email: fortuna@micronode.com
  url: ''
author_login: admin
author_email: fortuna@micronode.com
wordpress_id: 143
wordpress_url: http://basepatterns.org/?p=143
date: '2011-10-18 14:11:38 +1100'
date_gmt: '2011-10-18 03:11:38 +1100'
categories:
- Uncategorized
tags:
- groovy
- sockets
- application
comments: []
---

A simple way to prevent running of multiple instances of your application is to use  Socket communication. For example, in Groovy the first thing you would execute is something like this:

```

try {

    // choose a unique port (!!)

    new Socket('localhost', 1337)

    println 'Already running'

    System.exit(0)

}

catch (Exception e) {

}

```

Following this, another block of code initialises the server socket to indicate an instance is running:

```

Thread.start {

    ServerSocket server = [1337]

    while(true) {

        try {

            server.accept {}

        }

        // extra actions such as bring window to front

        // on the running app may be performed here..

        finally {

            ousia.doLater {

                frame.visible = true

            }

        }

    }

}

```

Of course the same can be done in Java, just not in such a concise way. :)
