---
layout: post
status: publish
published: true
title: The Return of the Architect
author:
  display_name: fortuna
  login: admin
  email: fortuna@micronode.com
  url: ''
author_login: admin
author_email: fortuna@micronode.com
wordpress_id: 37
wordpress_url: http://blogs.modularity.net.au/thenextbigthing/?p=14
date: '2007-03-23 13:35:08 +1100'
date_gmt: '2007-03-23 03:35:08 +1100'
categories:
- Software
- Design
tags: []
comments: []
---
<p>When designing a software architecture it is important to maintain a focus on the problem you are trying to solve. Without this focus you will most likely diverge from the original goals, resulting in a solution that may not represent the best approach to solving the problem at hand. Often is the case that JEE architects lose sight of the problem domain in favour of the technologies employed in the end solution.</p>
<p>The Java (2) Enterprise Edition (JEE) is partly to blame for this loss of focus due to the rigid structure defined in the specification. When a framework such as JEE imposes such tight control over application design, typically you will see every application implemented the same way. The primary goal of JEE was to provide a standard approach to enterprise application development that, whilst particularly useful for those unfamiliar with enterprise architectures, has resulted in a single "flavour" of application design that is not necessarily optimal for all problem domains.</p>
<p>Consider banking systems. Aircraft control systems. All of these problem domains will typically find certain architectures more favourable than others. Embedded systems obviously aren't interested in JEE-sized applications, whilst enterprise applications need enterprise-quality scalability. From this kind of logic has emerged the different flavours of Java: JSE as the basis for all things Java, the superset JEE, and the subset JME. Unfortunately this model brings an assumption that problem domains only differ in terms of size, power and scalability, which is clearly not the case. If we consider the needs of an insurance company, in terms of size, power and scalability it may not be very different from the needs of an online bookstore, however the architectures most optimal to each domain are bound to be quite different.</p>
<p>If we consider the online bookstore example, you might assume that they may require some kind of supply-chain management software to handle the placing of orders through to delivery of the product. In addition to the typical enterprise-scale requirements, such a system might also be centered around a messaging or ESB technology. Alternatively, if we look at the insurance company's requirements, we might find a need for a policy management system, responsible for generating premiums and managing renewal periods. While the policy management system may also depend on messaging technologies for communication with legacy systems, the focus of such a system is more likely to be the business logic and underwriting rules necessary for policy management. Now of course a JEE application can be implemented and deployed for each of these particular scenarios, however in doing so we lose focus on what is important to each of these systems. At the same time we are deploying technologies that aren't even used in the problem domain, simply because they come bundled with the application server, further increasing the "clutter" and distracting us from the end goal.</p>
<p>Without having a clear focus of the goals of a software system, we find ourselves simply "shoe-horning" the implementation into the simplest configuration of a JEE application. Of course some JEE architects do try to model the application on the problem domain, being so bold as to implement multiple EJB modules in a single enterprise application. Multiple web applications are less common, typically because inter-web application communication is so difficult (something that portals tries to rectify, however the fact that it was "taped on" as an afterthought isn't really optimal), which ultimately means that web applications are huge and unmanageable, even if the architect has the foresight to separate the business logic from the user interface.</p>
<p>In fact many JEE architects have discovered that the most configurable way to implement an enterprise application is as a collection of JEE applications. Each application might contain a single EJB module, or a web application, or web services. This approach will only become more prevalent with the popularity of Service Oriented Architectures (SOA). Assuming this trend does continue enterprise applications will ultimately become redundant, serving only as a defunct wrapper to the actual module contained within. Add this to the list of other failed technologies (Entity and Stateful EJBs), and JEE starts to become made up of more legacy technologies than useful ones.</p>
<p>There is a lesson to be learned from JEE, and that is if you try to be everything to everyone you will end up being not particularly useful to anyone. As this realisation is made more apparent with every new release of the JEE specification, we will ultimately see a rejection of JEE as a whole, instead being replaced with architectures employing only those technologies required to meet the goals of the project. Such architectures will not necessarily resemble a traditional JEE design, but will rather be designed specifically for the problem domain. With the resurgence of such architectures of many different flavours will come a renewed demand for <em>true<&#47;em> software architects, and will hopefully result in software designs more suited to the task at hand.</p>
