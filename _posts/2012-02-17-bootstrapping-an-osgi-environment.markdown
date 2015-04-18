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
	&lt;dependencies&gt;<br />
		&lt;dependency&gt;<br />
			&lt;groupId&gt;org.codehaus.groovy&lt;/groupId&gt;<br />
			&lt;artifactId&gt;groovy-all&lt;/artifactId&gt;<br />
		&lt;/dependency&gt;<br />
		&lt;dependency&gt;<br />
			&lt;groupId&gt;org.apache.felix&lt;/groupId&gt;<br />
			&lt;artifactId&gt;org.apache.felix.framework&lt;/artifactId&gt;<br />
			&lt;version&gt;4.0.2&lt;/version&gt;<br />
  		&lt;/dependency&gt;<br />
	&lt;/dependencies&gt;<br />
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
		println &quot;System bundle started&quot;<br />
	}<br />
	void stop(BundleContext context) throws Exception {<br />
		println &quot;System bundle stopped&quot;<br />
	}<br />
}]]<br />
Framework osgi = osgiFactory.newFramework(configMap)</p>
<p>System.addShutdownHook {<br />
	println &quot;Shutting down&quot;<br />
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
	println &quot;$it.bundleId $it.symbolicName $it.state&quot;<br />
}<br />
System.exit(0)<br />
[/code]</p>
<p>Of course you need to load some bundles to do something useful, but this demonstrates that it isn't actually that hard to create an embedded OSGi runtime with a custom System Bundle Activator for accessing services from other bundles.</p>
