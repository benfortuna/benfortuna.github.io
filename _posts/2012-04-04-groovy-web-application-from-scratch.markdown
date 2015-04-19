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
<p>There are many frameworks available for building Java or Groovy-based web applications, with the most popular Groovy options being <a title="Grails Framework" href="http://grails.org" target="_blank">Grails</a>&Acirc;&nbsp;or <a title="Gaelyk for Google App Engine" href="http://gaelyk.appspot.com" target="_blank">Gaelyk</a>&Acirc;&nbsp;for Google App Engine development. Fortunately however, a lot of the functionality required for building simple web applications is built into the Groovy library itself.</p>
<p><strong>Groovy Servlets</strong></p>
<p>Support for executing arbitrary Groovy scripts is provided by the <a title="Groovlets" href="http://groovy.codehaus.org/Groovlets" target="_blank">GroovyServlet</a>. This servlet provides bindings for common servlet variables and functions, and is useful to provide Controller-style functionality.</p>
<p><strong>Groovy Templates</strong></p>
<p>HTML templates are supported via the <a title="Groovy Templates" href="http://groovy.codehaus.org/Groovy+Templates#GroovyTemplates-SimpleTemplateEngine" target="_blank">TemplateServlet</a>. With native support for including HTML fragments, a flexible solution promoting code reuse can be developed.</p>
<p><strong>Variable Binding</strong></p>
<p>Both the GroovyServlet and TemplateServlet include support for binding variables to the Groovy execution environment. Whilst this is disabled by default, by extending these classes you can implement powerful extension support that includes injecting variables and closures for use in your templates and groovy scripts.</p>
<p><strong>Routing</strong></p>
<p>Whilst there is no native solution for routing requests&Acirc;&nbsp;in Groovy (although a case could be made for including the Gaelyk routing functionality in the core library), a number of other solutions exist for routing in Java-based web applications. One of these options is the <a title="UrlRewriteFilter" href="http://code.google.com/p/urlrewritefilter/" target="_blank">UrlRewriteFilter</a>&Acirc;&nbsp;which provides features similar to the Apache mod_rewrite module. This can be used to good effect for providing features such as SEO-friendly urls.</p>
<p><strong>Web Application Layout</strong></p>
<p>Using the features above, the bulk of the application can be stored under the <em>WEB-INF</em>&Acirc;&nbsp;directory of the application archive. A suggested approach could be as follows:</p>
<ul>
<li>groovy - controllers</li>
<li>pages - HTML page templates</li>
<li>includes - HTML code fragments</li>
<li>extensions - reusable variables and closures</li><br />
</ul><br />
By default the GroovyServlet will recognise scripts in the <em>groovy</em>&Acirc;&nbsp;directory. To configure the TemplateServlet to load HTML page templates from the <em>pages</em>&Acirc;&nbsp;directory you can add the following to your <em>web.xml</em>&Acirc;&nbsp;configuration:</p>
<p>[code]</p>
<p>...</p>
<p><servlet><br />
<servlet-name>Template</servlet-name><br />
 &Acirc;&nbsp;&Acirc;&nbsp;<servlet-class>groovy.servlet.TemplateServlet</servlet-class><br />
<init-param></p>
<param-name>resource.name.regex</param-name></p>
<param-value>(.*\.html)</param-value><br />
</init-param><br />
<init-param></p>
<param-name>resource.name.replacement</param-name></p>
<param-value>WEB-INF/pages$1</param-value><br />
</init-param><br />
 </servlet></p>
<p>...</p>
<p>[/code]</p>
<p>Including HTML fragments in your page templates is as simple as JSP incudes:</p>
<p>[code]</p>
<p><% include '/WEB-INF/includes/header.gtpl' %></p>
<p>[/code]</p>
<p>Configuring variable binding requires a little more work, in that you must extend the servlet classes to override the <em>setVariables(ServletBinding)</em>&Acirc;&nbsp;method. You can choose to reload bindings for each request, but perhaps it is wiser to cache the configuration across multiple requests. A simple example of loading a single binding configuration (on each request) is as follows:</p>
<p>[code]</p>
<p>class MyTemplateServlet extends TemplateServlet {</p>
<p>@Override<br />
protected void setVariables(ServletBinding binding) {<br />
super.setVariables(binding);</p>
<p> &Acirc;&nbsp; &Acirc;&nbsp;&Acirc;&nbsp;ConfigSlurper extensionLoader = []<br />
 &Acirc;&nbsp; &Acirc;&nbsp;&Acirc;&nbsp;ConfigObject extensions = []<br />
String extensionScript = binding.context.getResource('/WEB-INF/extensions/default.groovy').text<br />
extensions.merge(extensionLoader.parse(extensionScript))<br />
extensions.entrySet().each {<br />
binding.setVariable(it.key, it.value)<br />
 &Acirc;&nbsp; &Acirc;&nbsp;&Acirc;&nbsp;}<br />
}</p>
<p>}</p>
<p>[/code]</p>
<p>So whilst frameworks can often help to encourage good web application principles, such as separation of concerns, Model-View-Controller, etc., if you are comfortable with these principles you can avoid framework overhead, or even design your own, using core Groovy functionality.</p>
