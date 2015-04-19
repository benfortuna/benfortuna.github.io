---
layout: post
status: publish
published: true
title: Building a Groovy web application from scratch
author:
  display_name: fortuna
  login: admin
  email: fortuna@micronode.com
  url: ''
author_login: admin
author_email: fortuna@micronode.com
wordpress_id: 153
wordpress_url: http://basepatterns.org/?p=153
date: '2012-04-04 10:26:58 +1000'
date_gmt: '2012-04-04 00:26:58 +1000'
categories:
- Build
- Groovy
tags:
- groovy
- application
- web
comments: []
---

There are many frameworks available for building Java or Groovy-based web applications, with the most popular Groovy options being [Grails] or [Gaelyk] for Google App Engine development. Fortunately however, a lot of the functionality required for building simple web applications is built into the Groovy library itself.

**Groovy Servlets**

Support for executing arbitrary Groovy scripts is provided by the [GroovyServlet]. This servlet provides bindings for common servlet variables and functions, and is useful to provide Controller-style functionality.

**Groovy Templates**

HTML templates are supported via the [TemplateServlet]. With native support for including HTML fragments, a flexible solution promoting code reuse can be developed.

**Variable Binding**

Both the GroovyServlet and TemplateServlet include support for binding variables to the Groovy execution environment. Whilst this is disabled by default, by extending these classes you can implement powerful extension support that includes injecting variables and closures for use in your templates and groovy scripts.

**Routing**

Whilst there is no native solution for routing requests in Groovy (although a case could be made for including the Gaelyk routing functionality in the core library), a number of other solutions exist for routing in Java-based web applications. One of these options is the [UrlRewriteFilter] which provides features similar to the Apache mod_rewrite module. This can be used to good effect for providing features such as SEO-friendly urls.

**Web Application Layout**

Using the features above, the bulk of the application can be stored under the *WEB-INF* directory of the application archive. A suggested approach could be as follows:


* groovy - controllers
* pages - HTML page templates
* includes - HTML code fragments
* extensions - reusable variables and closures



By default the GroovyServlet will recognise scripts in the *groovy* directory. To configure the TemplateServlet to load HTML page templates from the *pages* directory you can add the following to your *web.xml* configuration:

```

...

<servlet>

<servlet-name>Template</servlet-name>

   <servlet-class>groovy.servlet.TemplateServlet</servlet-class>

<init-param>
<param-name>resource.name.regex</param-name>
<param-value>(.*\.html)</param-value>

</init-param>

<init-param>
<param-name>resource.name.replacement</param-name>
<param-value>WEB-INF/pages$1</param-value>

</init-param>

 </servlet>

...

```

Including HTML fragments in your page templates is as simple as JSP incudes:

```

<% include '/WEB-INF/includes/header.gtpl' %>

```

Configuring variable binding requires a little more work, in that you must extend the servlet classes to override the *setVariables(ServletBinding)* method. You can choose to reload bindings for each request, but perhaps it is wiser to cache the configuration across multiple requests. A simple example of loading a single binding configuration (on each request) is as follows:

```

class MyTemplateServlet extends TemplateServlet {

@Override

protected void setVariables(ServletBinding binding) {

super.setVariables(binding);

     ConfigSlurper extensionLoader = []

     ConfigObject extensions = []

String extensionScript = binding.context.getResource('/WEB-INF/extensions/default.groovy').text

extensions.merge(extensionLoader.parse(extensionScript))

extensions.entrySet().each {

binding.setVariable(it.key, it.value)

     }

}

}

```

So whilst frameworks can often help to encourage good web application principles, such as separation of concerns, Model-View-Controller, etc., if you are comfortable with these principles you can avoid framework overhead, or even design your own, using core Groovy functionality.

[Grails]: http://grails.org
[Gaelyk]: http://gaelyk.appspot.com
[GroovyServlet]: http://groovy.codehaus.org/Groovlets
[TemplateServlet]: http://groovy.codehaus.org/Groovy+Templates#GroovyTemplates-SimpleTemplateEngine
[UrlRewriteFilter]: http://code.google.com/p/urlrewritefilter/
