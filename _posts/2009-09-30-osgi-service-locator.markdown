---
layout: post
status: publish
published: true
title: OSGi Service Locator
author:
  display_name: fortuna
  login: admin
  email: fortuna@micronode.com
  url: ''
author_login: admin
author_email: fortuna@micronode.com
wordpress_id: 74
wordpress_url: http://basepatterns.org/?p=74
date: '2009-09-30 11:27:10 +1000'
date_gmt: '2009-09-30 01:27:10 +1000'
categories:
- Java
tags:
- patterns
- osgi
- service locator
comments:
- id: 21
  author: Costin Leau
  author_email: costin.leau@gmail.com
  author_url: http://twitter.com/costinl
  date: '2009-10-01 04:03:12 +1000'
  date_gmt: '2009-09-30 17:03:12 +1000'
  content: "One thing to add - one must not forget about the OSGi dynamics: a service
    can be unregistered at any time so ideally, on each call, the client would locate
    the service, invoke the methods needed and then discard the instance.\r\nOtherwise,
    if the service gets unregistered, any further invocations will lead to unpredictable
    behaviour.\r\n\r\nThere are frameworks that handle this case (among other features)
    in a non invasive fashion (using dependency injection) - I'll mention the ones
    I know best, namely Spring DM and OSGi Blueprint Services.\r\n\r\nCheers,\r\nCostin
    Leau\r\nLead, Spring Dynamic Modules\r\n"
- id: 27
  author: fortuna
  author_email: fortuna@micronode.com
  author_url: ''
  date: '2009-10-07 09:37:18 +1100'
  date_gmt: '2009-10-06 22:37:18 +1100'
  content: "<a href=\"#comment-21\" rel=\"nofollow\">@Costin Leau</a> \r\n\r\nHi
    Costin,\r\n\r\nThanks I probably should have made the point that the <em>Service
    Locator</em> pattern is possibly the least desirable mechanism for retrieving
    service references in an OSGi context, due to the dynamic nature of service availability
    that you mention.\r\n\r\nSometimes however (particularly when dealing with legacy
    code and third-party libraries), approaches such as the <a href=\"http://www.osgi.org/wiki/uploads/Links/whiteboard.pdf\"
    rel=\"nofollow\">whiteboard pattern</a> and/or <em>Dependency Injection</em>
    may not be applicable. In such cases a Service Locator may be considered (albeit
    with caution!).\r\n\r\nregards,\r\nben\r\n"
---
<p>The Service Locator pattern is a well-established mechanism for accessing local and remote services in a consistent manner:</p>
<p>[java]<br />
public interface ServiceLocator {</p>
<p>    <T> T findService(String serviceName) throws ServiceNotAvailableException;<br />
}<br />
[/java]</p>
<p>Using a structured service name interface we can improve uniformity and reduce the potential for typos:</p>
<p>[java]<br />
public enum ServiceName {</p>
<p>  SomeService("SomeService");</p>
<p>  private final String filter;<br />
  ...</p>
<p>  /**<br />
    * @return a filter string used to identify the service classification/location.<br />
    */<br />
  String getFilter();<br />
}</p>
<p>public interface ServiceLocator {</p>
<p>    <T> T findService(ServiceName serviceName) throws ServiceNotAvailableException;<br />
}<br />
[/java]</p>
<p>In an OSGi environment, the recommended approach for retrieving services is via the <em>org.osgi.util.tracker.ServiceTracker</em> class:</p>
<p>[java]<br />
...<br />
  BundleContext context = ...<br />
  ServiceTracker tracker = new ServiceTracker(context, SomeService.class.getName(), null);<br />
  tracker.open();</p>
<p>  SomeService service = (SomeService) tracker.getService();<br />
...<br />
[/java]</p>
<p>We can combine these two patterns to provide a more familiar and manageable approach to locating services:</p>
<p>[java]<br />
import java.util.HashMap;<br />
import java.util.Map;<br />
import org.osgi.framework.BundleContext;<br />
import org.osgi.util.tracker.ServiceTracker;</p>
<p>public class OsgiServiceLocator implements ServiceLocator {</p>
<p>    private final BundleContext context;</p>
<p>    private final Map<ServiceName, ServiceTracker> serviceTrackers;</p>
<p>    /**<br />
     * @param context the bundle context in which to find services<br />
     */<br />
    public OsgiServiceLocator(BundleContext context) {<br />
        this.context = context;<br />
        serviceTrackers = new HashMap<ServiceName, ServiceTracker>();<br />
    }</p>
<p>    @SuppressWarnings("unchecked")<br />
    public <T> T findService(ServiceName serviceName) throws ServiceNotAvailableException {<br />
        ServiceTracker tracker = serviceTrackers.get(serviceName);<br />
        if (tracker == null) {<br />
            synchronized (serviceTrackers) {<br />
                tracker = serviceTrackers.get(serviceName);<br />
                if (tracker == null) {<br />
                    tracker = new ServiceTracker(context, context.createFilter(serviceName.getFilter()), null);<br />
                    tracker.open();<br />
                    serviceTrackers.put(serviceName, tracker);<br />
                }<br />
            }<br />
        }<br />
        final T service = (T) tracker.getService();<br />
        if (service == null) {<br />
            throw new ServiceNotAvailableException("Service matching [" + serviceName.getFilter() + "] not found.");<br />
        }<br />
        return service;<br />
    }</p>
<p>    /**<br />
     * Clean up resources.<br />
     */<br />
    public void reset() {<br />
        for (ServiceTracker tracker : serviceTrackers.values()) {<br />
            tracker.close();<br />
        }<br />
        serviceTrackers.clear();<br />
    }<br />
}<br />
[/java]</p>
<p>An example usage might be something like this:</p>
<p>[java]<br />
import org.osgi.framework.Constants;</p>
<p>public enum ServiceName {</p>
<p>  SomeService("(" + Constants.OBJECTCLASS + "=" + SomeService.class.toString() + ")");<br />
  ...<br />
}</p>
<p>...<br />
  BundleContext context = ...<br />
  ServiceLocator serviceLocator = new OsgiServiceLocator(context);</p>
<p>  SomeService service = serviceLocator.findService(ServiceName.SomeService);<br />
...<br />
[/java]</p>
<p><strong>Conclusion</strong></p>
<p>By implementing the Service Locator pattern in an OSGi context we provide consistency and familiarity for code that is not OSGi-aware. This reduces the dependency on OSGi and improves the maintainability of our code.</p>
