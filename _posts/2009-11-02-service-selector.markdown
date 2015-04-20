---
layout: post
status: publish
published: true
title: Service Selector
author:
  display_name: fortuna
  login: admin
  email: fortuna@micronode.com
  url: ''
author_login: admin
author_email: fortuna@micronode.com
excerpt: "Sometimes we may have more than one implementation and/or instance of a
  service to which we need to route requests. Routing may be controlled by a number
  of different factors, such as the request type, request arguments, runtime configuration,
  etc.\r\n\r\nAn implementation of such routing might look something like this:\r\n\r\n[java]\r\npublic
  interface SomeService {\r\n  void someMethod();\r\n}\r\n\r\npublic class RoutingSomeService
  implements SomeService {\r\n\r\n  private Map<String, SomeService> delegates = ...\r\n\r\n
  \ private String activeDelegateId = ...\r\n\r\n  public void someMethod() {\r\n
  \   SomeService delegate = delegates.get(activeDelegateId);\r\n    if (delegate
  != null) {\r\n      delegate.someMethod();\r\n    }\r\n    else {\r\n      // XXX:
  throw runtime exception???\r\n    }\r\n  }\r\n}\r\n[/java]"
wordpress_id: 115
wordpress_url: http://basepatterns.org/?p=115
date: '2009-11-02 14:43:24 +1100'
date_gmt: '2009-11-02 03:43:24 +1100'
categories:
- Java
tags:
- patterns
- proxy
comments: []
---

Sometimes we may have more than one implementation and/or instance of a service to which we need to route requests. Routing may be controlled by a number of different factors, such as the request type, request arguments, runtime configuration, etc.

An implementation of such routing might look something like this:

{% highlight java linenos %}

public interface SomeService {

  void someMethod();

}

public class RoutingSomeService implements SomeService {

  private Map<String, SomeService> delegates = ...

  private String activeDelegateId = ...

  public void someMethod() {

    SomeService delegate = delegates.get(activeDelegateId);

    if (delegate != null) {

      delegate.someMethod();

    }

    else {

      // XXX: throw runtime exception???

    }

  }

}
{% endhighlight %}

The common elements here are:


* A collection of delegate services
* A mechanism (e.g. key) for identifying the appropriate delegate for a request



Using interfaces we can create a pattern for supporting different types of service selection:

{% highlight java linenos %}

public interface ServiceSelector<T> {

  T getService(Method method, Object[] args);

}

/**

 * A ServiceSelector that routes requests to the active service specified in an external configuration.

 */

public class ConfigurableServiceSelector implements ServiceSelector<SomeService> {

  private final Map<String, SomeService> services = ...

  private final Properties configuration = ...

  public SomeService getService(Method method, Object[] args) {

    return services.get(configuration.getProperty("someService.activeId"));

  }

}

/**

 * A ServiceSelector that supports routing of different methods based on an external configuration.

 */

public class MethodServiceSelector implements ServiceSelector<SomeService> {

  private final Map<Method, SomeService> services = ...

  public SomeService getService(Method method, Object[] args) {

    return services.get(method);

  }

}

...
{% endhighlight %}

So our implementation might then look like this:

{% highlight java linenos %}

public class RoutingSomeService implements SomeService {

  private ServiceSelector<SomeService> selector = ...

  public void someMethod() {

    SomeService delegate = selector.getService(getClass().getMethod("someMethod"), new Object[] {});

    if (delegate != null) {

      delegate.someMethod();

    }

    else {

      // XXX: throw runtime exception???

    }

}
{% endhighlight %}

As you can see this is actually quite an ugly piece of code. However, we can avoid writing this code altogether with the help of Java's proxy support.

**Ergo Proxy**

The use of proxies allows us to avoid writing the boilerplate code for service delegation:

{% highlight java linenos %}

import java.lang.reflect.InvocationHandler;

import java.lang.reflect.Method;

public class ServiceInvocationHandler implements InvocationHandler {

    private final ServiceSelector<?> selector;

    public ServiceInvocationHandler(ServiceSelector<?> selector) {

        this.selector = selector;

    }

    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {

        return method.invoke(selector.getService(method, args), args);

    }

}

public class ServiceConsumer {

  private final SomeService service;

  public ServiceConsumer(SomeService service) {

    this.service = service;

  }

  public static ServiceConsumer newInstance(SomeService service) {

    return new ServiceConsumer(service);

  }

  public static ServiceConsumer newInstance(ServiceSelector<SomeService> selector) {

    final InvocationHandler invocationHandler = new ServiceInvocationHandler(selector);

    return new ServiceConsumer((SomeService) Proxy.newProxyInstance(SomeService.class.getClassLoader(), new Class<?>[] {SomeService.class}, invocationHandler);

  }

}
{% endhighlight %}

**Conclusion**

Defining a standard interface for routing service requests provides us with a consistent and re-usable way of managing routing rules. Using proxies also ensures that service contracts are maintained and our client code doesn't need to change.
