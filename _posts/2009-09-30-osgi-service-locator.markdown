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
    Costin,\r\n\r\nThanks I probably should have made the point that the *Service
    Locator* pattern is possibly the least desirable mechanism for retrieving
    service references in an OSGi context, due to the dynamic nature of service availability
    that you mention.\r\n\r\nSometimes however (particularly when dealing with legacy
    code and third-party libraries), approaches such as the <a href=\"http://www.osgi.org/wiki/uploads/Links/whiteboard.pdf\"
    rel=\"nofollow\">whiteboard pattern</a> and/or *Dependency Injection*
    may not be applicable. In such cases a Service Locator may be considered (albeit
    with caution!).\r\n\r\nregards,\r\nben\r\n"
---

The Service Locator pattern is a well-established mechanism for accessing local and remote services in a consistent manner:

{% highlight java linenos %}

public interface ServiceLocator {
    <T> T findService(String serviceName) throws ServiceNotAvailableException;
}
{% endhighlight %}

Using a structured service name interface we can improve uniformity and reduce the potential for typos:

{% highlight java linenos %}

public enum ServiceName {
  SomeService("SomeService");

  private final String filter;
  ...

  /**
    * @return a filter string used to identify the service classification/location.
    */
  String getFilter();
}

public interface ServiceLocator {

    <T> T findService(ServiceName serviceName) throws ServiceNotAvailableException;
}
{% endhighlight %}

In an OSGi environment, the recommended approach for retrieving services is via the *org.osgi.util.tracker.ServiceTracker* class:

{% highlight java linenos %}

BundleContext context = ...
ServiceTracker tracker = new ServiceTracker(context, SomeService.class.getName(), null);
tracker.open();
SomeService service = (SomeService) tracker.getService();
{% endhighlight %}

We can combine these two patterns to provide a more familiar and manageable approach to locating services:

{% highlight java linenos %}

import java.util.HashMap;
import java.util.Map;
import org.osgi.framework.BundleContext;
import org.osgi.util.tracker.ServiceTracker;

public class OsgiServiceLocator implements ServiceLocator {
    private final BundleContext context;
    private final Map<ServiceName, ServiceTracker> serviceTrackers;

    /**
     * @param context the bundle context in which to find services
     */
    public OsgiServiceLocator(BundleContext context) {
        this.context = context;
        serviceTrackers = new HashMap<ServiceName, ServiceTracker>();
    }

    @SuppressWarnings("unchecked")
    public <T> T findService(ServiceName serviceName) throws ServiceNotAvailableException {
        ServiceTracker tracker = serviceTrackers.get(serviceName);
        if (tracker == null) {
            synchronized (serviceTrackers) {
                tracker = serviceTrackers.get(serviceName);
                if (tracker == null) {
                    tracker = new ServiceTracker(context, context.createFilter(serviceName.getFilter()), null);
                    tracker.open();
                    serviceTrackers.put(serviceName, tracker);
                }
            }
        }
        final T service = (T) tracker.getService();
        if (service == null) {
            throw new ServiceNotAvailableException("Service matching [" + serviceName.getFilter() + "] not found.");
        }
        return service;
    }
    
    /**
     * Clean up resources.
     */
    public void reset() {
        for (ServiceTracker tracker : serviceTrackers.values()) {
            tracker.close();
        }
        serviceTrackers.clear();
    }
}
{% endhighlight %}

An example usage might be something like this:

{% highlight java linenos %}
    
import org.osgi.framework.Constants;

public enum ServiceName {
  SomeService("(" + Constants.OBJECTCLASS + "=" + SomeService.class.toString() + ")");
  ...
}

BundleContext context = ...
ServiceLocator serviceLocator = new OsgiServiceLocator(context);
SomeService service = serviceLocator.findService(ServiceName.SomeService);
{% endhighlight %}

**Conclusion**

By implementing the Service Locator pattern in an OSGi context we provide consistency and familiarity for code that is not OSGi-aware. This reduces the dependency on OSGi and improves the maintainability of our code.
