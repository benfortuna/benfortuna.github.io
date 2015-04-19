---
layout: post
status: publish
published: true
title: In the beginning..
author:
  display_name: fortuna
  login: admin
  email: fortuna@micronode.com
  url: ''
author_login: admin
author_email: fortuna@micronode.com
wordpress_id: 38
wordpress_url: http://blogs.modularity.net.au/thenextbigthing/?p=26
date: '2008-02-17 23:31:38 +1100'
date_gmt: '2008-02-17 13:31:38 +1100'
categories:
- Software
- Design
tags: []
comments: []
---

Ok, so it's been a while since I paid any attention to this blog - not that I have nothing to say, but rather that I couldn't decide what demands the most attention. I also want to ease up on the hostility expressed in a number of previous posts, as there's probably enough people complaining about the industry without me making more noise.. :)

So I think what I need to do is focus on a single topic for posting about, and ~~in the spirit of this blog's title~~ I have decided to document my experiences creating the *Next Big Thing* in software. ;)

For quite a number of years (perhaps as far back as the beginning of my career about ten years ago) I have been particularly unimpressed with the features provided by the second most ubiquitous software category (the web browser being the first), the email client. Over the years this dissatisfaction has grown to include all so-called "groupware" clients, notably infamous among these being Microsoft Outlook. So in my spare time over the years I have explored and experimented with what it would take to write an *Outlook killer* (for want of a better term). Being that I have used Java almost exclusively for my entire career, I had confidence in language features and the growing list of third-party libraries to be able to produce a complex rich client.

With an attention span challenged at the best of times, often my focus has spun off on tangents - particularly when Java proved to be too immature for certain critical features of an email client (a situation that may be argued still exists today). Occasionally these tangents have proved to be not a total waste of time, with projects such as [iCal4j] and [mstor] resulting from these divergences.

The long-term goal however, remained, and in the last couple of years a number of developments have arisen within the Java community that I believe have been of critical importance to developing complex rich client Java applications:


* First, there have been dramatic improvements with desktop Java performance in Java 5, and even more so in Java 6. Hopefully we can expect even greater performance from the upcoming Java 6 Update N, and Java 7
* Second, I believe modularisation plays a key part in building complex systems, whether they be client- or server-side. Taking modularisation to the next level is the Open Services Gateway Initiative (OSGi), which I think could change the way we develop applications in the future
* Finally, and I really mean finally (!!), we now have a better way to build Swing GUI interfaces in JavaFX Script. Admittedly this technology is still very new, and to be honest the implementation is not even finished yet, however with my limited exposure I am already feeling much more comfortable with writing complex rich client interfaces



And so armed with a new set of technologies, I am once again attempting to make progress on this *Next Big Thing*. Along the way I will be documenting progress, insights and frustrations, in the hope that something of value may find it's way into this blog. Stay tuned. :)

[iCal4j]: http://ical4j.sourceforge.net/
[mstor]: http://mstor.sourceforge.net/
