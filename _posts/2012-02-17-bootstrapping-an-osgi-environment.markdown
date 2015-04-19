---
layout: post
status: publish
published: true
title: Bootstrapping an OSGi environment
author:
  display_name: fortuna
  login: admin
  email: fortuna@micronode.com
  url: ''
author_login: admin
author_email: fortuna@micronode.com
wordpress_id: 149
wordpress_url: http://basepatterns.org/?p=149
date: '2012-02-17 10:26:54 +1100'
date_gmt: '2012-02-16 23:26:54 +1100'
categories:
- Build
tags:
- patterns
- osgi
- groovy
comments: []
---

Something I have always lamented about OSGi is a lack of simple examples to get up and running quickly. So here is a simple example using Groovy:

First, dependencies are easily added via Maven, adding the following to your pom.xml should do it.

```

	<dependencies>

		<dependency>

			<groupId>org.codehaus.groovy</groupId>

			<artifactId>groovy-all</artifactId>

		</dependency>

		<dependency>

			<groupId>org.apache.felix</groupId>

			<artifactId>org.apache.felix.framework</artifactId>

			<version>4.0.2</version>

  		</dependency>

	</dependencies>

```

Then a simple Groovy script to start the OSGi framework and print a message.

```

import org.osgi.framework.BundleActivator

import org.osgi.framework.BundleContext

import org.osgi.framework.launch.Framework

import org.osgi.framework.launch.FrameworkFactory

FrameworkFactory osgiFactory = ServiceLoader.load(FrameworkFactory).find()

def configMap = ['felix.systembundle.activators': [new BundleActivator() {

	void start(BundleContext context) throws Exception {

		println "System bundle started"

	}

	void stop(BundleContext context) throws Exception {

		println "System bundle stopped"

	}

}]]

Framework osgi = osgiFactory.newFramework(configMap)

System.addShutdownHook {

	println "Shutting down"

	try {

		osgi.stop()

		osgi.waitForStop(0)

	}

	catch (Exception e) {

		e.printStackTrace()

	}

}

osgi.init()

osgi.start()

osgi.bundleContext.bundles.each {

	println "$it.bundleId $it.symbolicName $it.state"

}

System.exit(0)

```

Of course you need to load some bundles to do something useful, but this demonstrates that it isn't actually that hard to create an embedded OSGi runtime with a custom System Bundle Activator for accessing services from other bundles.
