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

In OSGi using a publisher/subscriber design can be somewhat more complicated that traditional Java environments:

```java

public class SomeBundleActivator implements BundleActivator {

  private SomeService service = ...

  private ServiceRegistration registration;

  public void start(BundleContext context) {

    registration = context.registerService(SomeService.class.getName(), service, null);

  }

  ...

}

public class AnotherBundleActivator implements BundleActivator {

  private SomeServiceSubscriber subscriber = ...

  public void start(BundleContext context) {

    ServiceLocator serviceLocator = new OsgiServiceLocator(context);

    SomeService service = serviceLocator.findService(ServiceName.SomeService);

    // XXX: what if service is not initialised here??

    service.subscribe(subscriber);

    // XXX: what if service is removed and/or restarted after here???

  }

  ...

}

```

To overcome these hurdles the [Whiteboard Pattern] prescribes registering listeners in the service registry as opposed to services, whereby services can publish events to available listeners at the time of the event.

```java

public class SomeBundleActivator implements BundleActivator {

  private SomeService service = ...

  public void start(BundleContext context) {

    ServiceLocator serviceLocator = new OsgiServiceLocator(context);

    service.subscribe(new ServiceSubscriber() {

      public void onEvent(Event e) {

        List<ServiceSubsriber> subscribers = serviceLocator.findServices(ServiceName.ServiceSubscriber);

        for (ServiceSubscriber subscriber : subscribers) {

          subsriber.onEvent(e);

        }

      }

    });

  }

  ...

}

public class AnotherBundleActivator implements BundleActivator {

  private SomeServiceSubscriber subscriber = ...

  private ServiceRegistration registration;

  public void start(BundleContext context) {

    registration = context.registerService(ServiceSubscriber.class.getName(), subscriber, null);

  }

  ...

}

```

The problem with the *Whiteboard Pattern* is that it relies on the OSGi Service Registry to maintain the list of active subscribers. This means that publishers (i.e. services) must be either OSGi-aware, or events must be specifically handled and repeated to available subscribers.

**The Whiteboard Registry**

We can extend the Whiteboard Pattern further by creating a dedicated *Registry* that is responsible for wiring together specific publishers and subscribers:

```java

public class SomeServiceSubscriberRegistry {

  private final List<SomeService> publishers;

  private final List<SomeServiceSubscriber> subscribers;

  ...

  public void registerPublisher(SomeService publisher) {

    for (SomeServiceSubscriber subscriber : subscribers) {

      publisher.subscribe(subscriber);

    }

  }

  public void unregisterPublisher(SomeService publisher) {

    ...

  }

  public void registerSubscriber(SomeServiceSubscriber subscriber) {

    for (SomeService publisher : publishers) {

      publisher.subscribe(subscriber);

    }

  }

  public void unregisterSubscriber(SomeServiceSubscriber subscriber) {

    ...

  }

}

```

Using this registry publishers and subscribers are wired together as they are made available:

```java

public class WhiteboardRegistryBundleActivator implements BundleActivator {

  private final SomeServiceSubscriberRegistry registry = ...

  public void start(BundleContext context) {

    context.addServiceListener(new ServiceListener() {

      public void serviceChanged(ServiceEvent e) {

        if (e.getType() == ServiceEvent.REGISTERED) {

          registry.registerPublisher((SomeService) context.getService(e.getServiceReference()));

        }

        else if (e.getType() == ServiceEvent.UNREGISTERING) {

          registry.unregisterPublisher((SomeService) context.getService(e.getServiceReference()));

        }

      }

    }, "(objectClass=" + SomeService.class.getName + ")");

    context.addServiceListener(new ServiceListener() {

      public void serviceChanged(ServiceEvent e) {

        if (e.getType() == ServiceEvent.REGISTERED) {

          registry.registerSubscriber((ServiceSubscriber) context.getService(e.getServiceReference()));

        }

        else if (e.getType() == ServiceEvent.UNREGISTERING) {

          registry.unregisterSubscriber((ServiceSubscriber) context.getService(e.getServiceReference()));

        }

      }

    }, "(objectClass=" + ServiceSubscriber.class.getName + ")");

  }

  ...

}

public class SomeBundleActivator implements BundleActivator {

  private SomeService service = ...

  private ServiceRegistration registration;

  public void start(BundleContext context) {

    registration = context.registerService(SomeService.class.getName(), service, null);

  }

  ...

}

public class AnotherBundleActivator implements BundleActivator {

  private SomeServiceSubscriber subscriber = ...

  private ServiceRegistration registration;

  public void start(BundleContext context) {

    registration = context.registerService(ServiceSubscriber.class.getName(), subscriber, null);

  }

  ...

}

```

The wiring can be made even simpler by using a Dependency Injection framework such as [Spring DM]:

[xml]

  ...

    <bean id="SomeServiceSubscriberRegistry" class="org.mnode.example.whiteboard.SomeServiceSubscriberRegistry"/>

    <osgi:reference id="SomeServiceWiring" interface="org.mnode.example.whiteboard.SomeService">

      <osgi:listener ref="SomeServiceSubscriberRegistry" bind-method="registerPublisher" unbind-method="unregisterPublisher" />

    <osgi:reference id="ServiceSubscriberWiring" interface="org.mnode.example.whiteboard.ServiceSubscriber">

      <osgi:listener ref="SomeServiceSubscriberRegistry" bind-method="registerSubscriber" unbind-method="unregisterSubscriber" />

  ...

[/xml]

**Conclusion**

By creating a *Whiteboard Registry* that is dedicated to wiring services and service subscribers, we can bring the benefits of the *Whiteboard Pattern* to event listener models and other publisher/subscriber frameworks that are not OSGi-aware.

[Whiteboard Pattern]: http://www.osgi.org/wiki/uploads/Links/whiteboard.pdf
[Spring DM]: http://static.springsource.org/osgi/docs/1.2.0/reference/html/service-registry.html#service-registry:refs:dynamics
