---
layout: post
status: publish
published: true
title: Whiteboard Registry
author:
  display_name: fortuna
  login: admin
  email: fortuna@micronode.com
  url: ''
author_login: admin
author_email: fortuna@micronode.com
wordpress_id: 86
wordpress_url: http://basepatterns.org/?p=86
date: '2009-10-08 17:59:44 +1100'
date_gmt: '2009-10-08 06:59:44 +1100'
categories:
- Java
tags:
- patterns
- osgi
- whiteboard
- registry
comments: []
---
<p>In OSGi using a publisher&#47;subscriber design can be somewhat more complicated that traditional Java environments:</p>
<p>[java]<br />
public class SomeBundleActivator implements BundleActivator {</p>
<p>  private SomeService service = ...</p>
<p>  private ServiceRegistration registration;</p>
<p>  public void start(BundleContext context) {<br />
    registration = context.registerService(SomeService.class.getName(), service, null);<br />
  }<br />
  ...<br />
}</p>
<p>public class AnotherBundleActivator implements BundleActivator {</p>
<p>  private SomeServiceSubscriber subscriber = ...</p>
<p>  public void start(BundleContext context) {<br />
    ServiceLocator serviceLocator = new OsgiServiceLocator(context);<br />
    SomeService service = serviceLocator.findService(ServiceName.SomeService);</p>
<p>    &#47;&#47; XXX: what if service is not initialised here??<br />
    service.subscribe(subscriber);</p>
<p>    &#47;&#47; XXX: what if service is removed and&#47;or restarted after here???<br />
  }<br />
  ...<br />
}<br />
[&#47;java]</p>
<p>To overcome these hurdles the <a href="http:&#47;&#47;www.osgi.org&#47;wiki&#47;uploads&#47;Links&#47;whiteboard.pdf">Whiteboard Pattern<&#47;a> prescribes registering listeners in the service registry as opposed to services, whereby services can publish events to available listeners at the time of the event.</p>
<p>[java]<br />
public class SomeBundleActivator implements BundleActivator {</p>
<p>  private SomeService service = ...</p>
<p>  public void start(BundleContext context) {<br />
    ServiceLocator serviceLocator = new OsgiServiceLocator(context);</p>
<p>    service.subscribe(new ServiceSubscriber() {<br />
      public void onEvent(Event e) {<br />
        List<ServiceSubsriber> subscribers = serviceLocator.findServices(ServiceName.ServiceSubscriber);<br />
        for (ServiceSubscriber subscriber : subscribers) {<br />
          subsriber.onEvent(e);<br />
        }<br />
      }<br />
    });<br />
  }<br />
  ...<br />
}</p>
<p>public class AnotherBundleActivator implements BundleActivator {</p>
<p>  private SomeServiceSubscriber subscriber = ...</p>
<p>  private ServiceRegistration registration;</p>
<p>  public void start(BundleContext context) {<br />
    registration = context.registerService(ServiceSubscriber.class.getName(), subscriber, null);<br />
  }<br />
  ...<br />
}<br />
[&#47;java]</p>
<p>The problem with the <em>Whiteboard Pattern<&#47;em> is that it relies on the OSGi Service Registry to maintain the list of active subscribers. This means that publishers (i.e. services) must be either OSGi-aware, or events must be specifically handled and repeated to available subscribers.</p>
<p><strong>The Whiteboard Registry<&#47;strong></p>
<p>We can extend the Whiteboard Pattern further by creating a dedicated <em>Registry<&#47;em> that is responsible for wiring together specific publishers and subscribers:</p>
<p>[java]<br />
public class SomeServiceSubscriberRegistry {</p>
<p>  private final List<SomeService> publishers;</p>
<p>  private final List<SomeServiceSubscriber> subscribers;<br />
  ...<br />
  public void registerPublisher(SomeService publisher) {<br />
    for (SomeServiceSubscriber subscriber : subscribers) {<br />
      publisher.subscribe(subscriber);<br />
    }<br />
  }</p>
<p>  public void unregisterPublisher(SomeService publisher) {<br />
    ...<br />
  }</p>
<p>  public void registerSubscriber(SomeServiceSubscriber subscriber) {<br />
    for (SomeService publisher : publishers) {<br />
      publisher.subscribe(subscriber);<br />
    }<br />
  }</p>
<p>  public void unregisterSubscriber(SomeServiceSubscriber subscriber) {<br />
    ...<br />
  }<br />
}<br />
[&#47;java]</p>
<p>Using this registry publishers and subscribers are wired together as they are made available:</p>
<p>[java]<br />
public class WhiteboardRegistryBundleActivator implements BundleActivator {</p>
<p>  private final SomeServiceSubscriberRegistry registry = ...</p>
<p>  public void start(BundleContext context) {<br />
    context.addServiceListener(new ServiceListener() {<br />
      public void serviceChanged(ServiceEvent e) {<br />
        if (e.getType() == ServiceEvent.REGISTERED) {<br />
          registry.registerPublisher((SomeService) context.getService(e.getServiceReference()));<br />
        }<br />
        else if (e.getType() == ServiceEvent.UNREGISTERING) {<br />
          registry.unregisterPublisher((SomeService) context.getService(e.getServiceReference()));<br />
        }<br />
      }<br />
    }, "(objectClass=" + SomeService.class.getName + ")");</p>
<p>    context.addServiceListener(new ServiceListener() {<br />
      public void serviceChanged(ServiceEvent e) {<br />
        if (e.getType() == ServiceEvent.REGISTERED) {<br />
          registry.registerSubscriber((ServiceSubscriber) context.getService(e.getServiceReference()));<br />
        }<br />
        else if (e.getType() == ServiceEvent.UNREGISTERING) {<br />
          registry.unregisterSubscriber((ServiceSubscriber) context.getService(e.getServiceReference()));<br />
        }<br />
      }<br />
    }, "(objectClass=" + ServiceSubscriber.class.getName + ")");<br />
  }<br />
  ...<br />
}</p>
<p>public class SomeBundleActivator implements BundleActivator {</p>
<p>  private SomeService service = ...</p>
<p>  private ServiceRegistration registration;</p>
<p>  public void start(BundleContext context) {<br />
    registration = context.registerService(SomeService.class.getName(), service, null);<br />
  }<br />
  ...<br />
}</p>
<p>public class AnotherBundleActivator implements BundleActivator {</p>
<p>  private SomeServiceSubscriber subscriber = ...</p>
<p>  private ServiceRegistration registration;</p>
<p>  public void start(BundleContext context) {<br />
    registration = context.registerService(ServiceSubscriber.class.getName(), subscriber, null);<br />
  }<br />
  ...<br />
}<br />
[&#47;java]</p>
<p>The wiring can be made even simpler by using a Dependency Injection framework such as <a href="http:&#47;&#47;static.springsource.org&#47;osgi&#47;docs&#47;1.2.0&#47;reference&#47;html&#47;service-registry.html#service-registry:refs:dynamics">Spring DM<&#47;a>:</p>
<p>[xml]<br />
  ...<br />
    <bean id="SomeServiceSubscriberRegistry" class="org.mnode.example.whiteboard.SomeServiceSubscriberRegistry"&#47;></p>
<p>    <osgi:reference id="SomeServiceWiring" interface="org.mnode.example.whiteboard.SomeService"><br />
      <osgi:listener ref="SomeServiceSubscriberRegistry" bind-method="registerPublisher" unbind-method="unregisterPublisher" &#47;></p>
<p>    <osgi:reference id="ServiceSubscriberWiring" interface="org.mnode.example.whiteboard.ServiceSubscriber"><br />
      <osgi:listener ref="SomeServiceSubscriberRegistry" bind-method="registerSubscriber" unbind-method="unregisterSubscriber" &#47;><br />
  ...<br />
[&#47;xml]</p>
<p><strong>Conclusion<&#47;strong></p>
<p>By creating a <em>Whiteboard Registry<&#47;em> that is dedicated to wiring services and service subscribers, we can bring the benefits of the <em>Whiteboard Pattern<&#47;em> to event listener models and other publisher&#47;subscriber frameworks that are not OSGi-aware.</p>
