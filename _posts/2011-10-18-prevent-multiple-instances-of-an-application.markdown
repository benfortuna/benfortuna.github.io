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
<p>A simple way to prevent running of multiple instances of your application is to use  Socket communication. For example, in Groovy the first thing you would execute is something like this:</p>
<p>[code]<br />
try {<br />
    // choose a unique port (!!)<br />
    new Socket('localhost', 1337)<br />
    println 'Already running'<br />
    System.exit(0)<br />
}<br />
catch (Exception e) {<br />
}<br />
[/code]</p>
<p>Following this, another block of code initialises the server socket to indicate an instance is running:</p>
<p>[code]<br />
Thread.start {<br />
    ServerSocket server = [1337]<br />
    while(true) {<br />
        try {<br />
            server.accept {}<br />
        }<br />
        // extra actions such as bring window to front<br />
        // on the running app may be performed here..<br />
        finally {<br />
            ousia.doLater {<br />
                frame.visible = true<br />
            }<br />
        }<br />
    }<br />
}<br />
[/code]</p>
<p>Of course the same can be done in Java, just not in such a concise way. :)</p>
