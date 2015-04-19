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
<p>Something I have always lamented about OSGi is a lack of simple examples to get up and running quickly. So here is a simple example using Groovy:</p>
<p>First, dependencies are easily added via Maven, adding the following to your pom.xml should do it.</p>
<p>[code]<br />
	<dependencies><br />
		<dependency><br />
			<groupId>org.codehaus.groovy</groupId><br />
			<artifactId>groovy-all</artifactId><br />
		</dependency><br />
		<dependency><br />
			<groupId>org.apache.felix</groupId><br />
			<artifactId>org.apache.felix.framework</artifactId><br />
			<version>4.0.2</version><br />
  		</dependency><br />
	</dependencies><br />
[/code]</p>
<p>Then a simple Groovy script to start the OSGi framework and print a message.</p>
<p>[code]<br />
import org.osgi.framework.BundleActivator<br />
import org.osgi.framework.BundleContext<br />
import org.osgi.framework.launch.Framework<br />
import org.osgi.framework.launch.FrameworkFactory</p>
<p>FrameworkFactory osgiFactory = ServiceLoader.load(FrameworkFactory).find()</p>
<p>def configMap = ['felix.systembundle.activators': [new BundleActivator() {<br />
	void start(BundleContext context) throws Exception {<br />
		println "System bundle started"<br />
	}<br />
	void stop(BundleContext context) throws Exception {<br />
		println "System bundle stopped"<br />
	}<br />
}]]<br />
Framework osgi = osgiFactory.newFramework(configMap)</p>
<p>System.addShutdownHook {<br />
	println "Shutting down"<br />
	try {<br />
		osgi.stop()<br />
		osgi.waitForStop(0)<br />
	}<br />
	catch (Exception e) {<br />
		e.printStackTrace()<br />
	}<br />
}</p>
<p>osgi.init()<br />
osgi.start()<br />
osgi.bundleContext.bundles.each {<br />
	println "$it.bundleId $it.symbolicName $it.state"<br />
}<br />
System.exit(0)<br />
[/code]</p>
<p>Of course you need to load some bundles to do something useful, but this demonstrates that it isn't actually that hard to create an embedded OSGi runtime with a custom System Bundle Activator for accessing services from other bundles.</p>
