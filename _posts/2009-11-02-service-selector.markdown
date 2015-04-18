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
<p>Sometimes we may have more than one implementation and&#47;or instance of a service to which we need to route requests. Routing may be controlled by a number of different factors, such as the request type, request arguments, runtime configuration, etc.</p>
<p>An implementation of such routing might look something like this:</p>
<p>[java]<br />
public interface SomeService {<br />
  void someMethod();<br />
}</p>
<p>public class RoutingSomeService implements SomeService {</p>
<p>  private Map<String, SomeService> delegates = ...</p>
<p>  private String activeDelegateId = ...</p>
<p>  public void someMethod() {<br />
    SomeService delegate = delegates.get(activeDelegateId);<br />
    if (delegate != null) {<br />
      delegate.someMethod();<br />
    }<br />
    else {<br />
      &#47;&#47; XXX: throw runtime exception???<br />
    }<br />
  }<br />
}<br />
[&#47;java]</p>
<p>The common elements here are:</p>
<ul>
<li>A collection of delegate services<&#47;li>
<li>A mechanism (e.g. key) for identifying the appropriate delegate for a request<&#47;li><br />
<&#47;ul></p>
<p>Using interfaces we can create a pattern for supporting different types of service selection:</p>
<p>[java]<br />
public interface ServiceSelector<T> {</p>
<p>  T getService(Method method, Object[] args);<br />
}</p>
<p>&#47;**<br />
 * A ServiceSelector that routes requests to the active service specified in an external configuration.<br />
 *&#47;<br />
public class ConfigurableServiceSelector implements ServiceSelector<SomeService> {</p>
<p>  private final Map<String, SomeService> services = ...</p>
<p>  private final Properties configuration = ...</p>
<p>  public SomeService getService(Method method, Object[] args) {<br />
    return services.get(configuration.getProperty("someService.activeId"));<br />
  }<br />
}</p>
<p>&#47;**<br />
 * A ServiceSelector that supports routing of different methods based on an external configuration.<br />
 *&#47;<br />
public class MethodServiceSelector implements ServiceSelector<SomeService> {</p>
<p>  private final Map<Method, SomeService> services = ...</p>
<p>  public SomeService getService(Method method, Object[] args) {<br />
    return services.get(method);<br />
  }<br />
}</p>
<p>...<br />
[&#47;java]</p>
<p>So our implementation might then look like this:</p>
<p>[java]<br />
public class RoutingSomeService implements SomeService {</p>
<p>  private ServiceSelector<SomeService> selector = ...</p>
<p>  public void someMethod() {<br />
    SomeService delegate = selector.getService(getClass().getMethod("someMethod"), new Object[] {});<br />
    if (delegate != null) {<br />
      delegate.someMethod();<br />
    }<br />
    else {<br />
      &#47;&#47; XXX: throw runtime exception???<br />
    }<br />
}<br />
[&#47;java]</p>
<p>As you can see this is actually quite an ugly piece of code. However, we can avoid writing this code altogether with the help of Java's proxy support.</p>
<p><strong>Ergo Proxy<&#47;strong></p>
<p>The use of proxies allows us to avoid writing the boilerplate code for service delegation:</p>
<p>[java]<br />
import java.lang.reflect.InvocationHandler;<br />
import java.lang.reflect.Method;</p>
<p>public class ServiceInvocationHandler implements InvocationHandler {</p>
<p>    private final ServiceSelector<?> selector;</p>
<p>    public ServiceInvocationHandler(ServiceSelector<?> selector) {<br />
        this.selector = selector;<br />
    }</p>
<p>    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {<br />
        return method.invoke(selector.getService(method, args), args);<br />
    }<br />
}</p>
<p>public class ServiceConsumer {</p>
<p>  private final SomeService service;</p>
<p>  public ServiceConsumer(SomeService service) {<br />
    this.service = service;<br />
  }</p>
<p>  public static ServiceConsumer newInstance(SomeService service) {<br />
    return new ServiceConsumer(service);<br />
  }</p>
<p>  public static ServiceConsumer newInstance(ServiceSelector<SomeService> selector) {<br />
    final InvocationHandler invocationHandler = new ServiceInvocationHandler(selector);<br />
    return new ServiceConsumer((SomeService) Proxy.newProxyInstance(SomeService.class.getClassLoader(), new Class<?>[] {SomeService.class}, invocationHandler);<br />
  }<br />
}<br />
[&#47;java]</p>
<p><strong>Conclusion<&#47;strong></p>
<p>Defining a standard interface for routing service requests provides us with a consistent and re-usable way of managing routing rules. Using proxies also ensures that service contracts are maintained and our client code doesn't need to change.</p>
