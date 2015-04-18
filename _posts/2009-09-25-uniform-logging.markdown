---
layout: post
status: publish
published: true
title: Uniform Logging
author:
  display_name: fortuna
  login: admin
  email: fortuna@micronode.com
  url: ''
author_login: admin
author_email: fortuna@micronode.com
wordpress_id: 45
wordpress_url: http://basepatterns.org/?p=45
date: '2009-09-25 12:37:46 +1000'
date_gmt: '2009-09-25 02:37:46 +1000'
categories:
- Java
tags:
- logging
- patterns
- adapter
comments: []
---
<p>Application logging always seems to become one of those <a href="http:&#47;&#47;en.wikipedia.org&#47;wiki&#47;Code_smell">code smells<&#47;a>, typically regarding <a href="http:&#47;&#47;en.wikipedia.org&#47;wiki&#47;Duplicate_code">duplication of code<&#47;a>, or conversely, non-uniform log messages.</p>
<p>There are many different ways to log a message in  Java, but variations on the following pattern are common:</p>
<p>[java]<br />
public class SomeClass {</p>
<p>  private static final Log LOG = LogFactory.getLog(SomeClass.class);</p>
<p>  ...</p>
<p>  public void someMethod() {<br />
    if (LOG.isDebugEnabled()) {<br />
      LOG.debug("Some message - someObject is: " + someObject);<br />
    }</p>
<p>    try {<br />
      ...<br />
    } catch (SomeException e) {<br />
      LOG.error("Unexpected error: " + e.getMessage(), e);<br />
    }<br />
  }<br />
}<br />
[&#47;java]</p>
<p>The following information can be extracted from this pattern:</p>
<ul>
<li>Category - classification for log entries<&#47;li>
<li>Level - the severity of a log entry<&#47;li>
<li>Message - a log entry message<&#47;li>
<li>Message arguments - variable components of a log message<&#47;li>
<li>Exception - an exception for logging a stack trace<&#47;li><br />
<&#47;ul><br />
<strong>Message Uniformity<&#47;strong></p>
<p>One problem with this pattern is that we tend to duplicate the same message strings when logging similar scenarios (e.g. unexpected exceptions).</p>
<p>Messages are also generally constructed by concatenating messages and message arguments - a practice that generally should be avoided if possible. We can solve these issues using message templates:</p>
<p>[java]<br />
import java.text.MessageFormat;</p>
<p>public class SomeClass {</p>
<p>  private static final String UNEXPECTED_ERROR_MESSAGE = "Unexpected error: {0}";</p>
<p>  ...</p>
<p>  public void someMethod() {</p>
<p>    try {<br />
      ...<br />
    } catch (SomeException e) {<br />
      LOG.error(MessageFormat.format(UNEXPECTED_ERROR_MESSAGE, e.getMessage()), e);<br />
    }<br />
  }<br />
}<br />
[&#47;java]</p>
<p>Inconsistent log messages also result from having the message strings defined across multiple classes. Using message templates we can refactor these messages to be defined in a single location:</p>
<p>[java]<br />
public enum LogEntry {<br />
  UnexpectedError("Unexpected Error: {0}");</p>
<p>  private final String message;</p>
<p>  public String getMessage(Object...args) {<br />
    return MessageFormat.format(message, args);<br />
  }<br />
}</p>
<p>public class SomeClass {</p>
<p>  ...</p>
<p>  public void someMethod() {</p>
<p>    try {<br />
      ...<br />
    } catch (SomeException e) {<br />
      LOG.error(LogEntry.UnexpectedError.getMessage(e.getMessage()), e);<br />
    }<br />
  }<br />
}<br />
[&#47;java]</p>
<p><strong>Log Levels<&#47;strong></p>
<p>In the majority of cases, log entries that share the same message will also be logged at the same level. By associating a default log level with a log entry we can enforce uniformity of log levels:</p>
<p>[java]<br />
public enum LogLevel {<br />
  Trace, Debug, Info, Warn, Error;<br />
}</p>
<p>public enum LogEntry {<br />
  UnexpectedError("Unexpected Error: {0}", LogLevel.Error);</p>
<p>  ...</p>
<p>  private final LogLevel level;</p>
<p>  public LogLevel getLevel() {<br />
    return level;<br />
  }<br />
}</p>
<p>public class LogAdapter {<br />
  private final Log log;</p>
<p>  ...</p>
<p>  public void log(LogEntry entry, Object...args) {<br />
    if (entry.getLevel() == LogLevel.Error) {<br />
      log.error(entry.getMessage(args));<br />
    }<br />
    else if (entry.getLevel() == LogLevel.Warn) {<br />
      log.warn(entry.getMessage(args));<br />
    }<br />
    else ...<br />
  }</p>
<p>  public void log(LogEntry entry, Throwable e, Object...args) {<br />
    if (entry.getLevel() == LogLevel.Error) {<br />
      log.error(entry.getMessage(args), e);<br />
    }<br />
    else if (entry.getLevel() == LogLevel.Warn) {<br />
      log.warn(entry.getMessage(args), e);<br />
    }<br />
    else ...<br />
  }<br />
}</p>
<p>public class SomeClass {</p>
<p>  private static final LogAdapater LOG = new LogAdapter(LogFactory.getLog(SomeClass.class));<br />
  ...</p>
<p>  public void someMethod() {</p>
<p>    try {<br />
      ...<br />
    } catch (SomeException e) {<br />
      LOG.log(LogEntry.UnexpectedError, e, e.getMessage());<br />
    }<br />
  }<br />
}<br />
[&#47;java]</p>
<p>To avoid the expensive construction of frequently logged message strings we use conditionals to check if a log level is enabled prior to message construction:</p>
<p>[java]<br />
  ...<br />
  if (LOG.isDebugEnabled()) {<br />
    LOG.debug("Some message - someObject status is: " + someObject.expensiveMethod());<br />
  }<br />
  ...<br />
[&#47;java]</p>
<p>Such conditionals are prone to error however, especially if the log level is changed:</p>
<p>[java]<br />
  ...<br />
  if (LOG.isDebugEnabled()) {<br />
    LOG.warn("Some message - someObject status is: " + someObject.expensiveMethod());<br />
  }<br />
  ...<br />
[&#47;java]</p>
<p>Uniform logging can help to avoid such mistakes:</p>
<p>[java]<br />
public enum LogEntry {<br />
  SomeObjectStatus("Some message - someObject status is: {0}", LogLevel.Debug);<br />
  ...<br />
}</p>
<p>public class LogAdapter {<br />
  ...</p>
<p>  public boolean isLoggable(LogEntry entry) {<br />
    if (entry.getLevel() == LogLevel.Debug) {<br />
      return log.isDebugEnabled();<br />
    }<br />
    ...<br />
  }</p>
<p>  public void log(LogEntry entry, Object...args) {<br />
    if (isLoggable(entry) {<br />
      ...<br />
    }<br />
  }</p>
<p>  public void log(LogEntry entry, Throwable e, Object...args) {<br />
    if (isLoggable(entry) {<br />
      ...<br />
    }<br />
  }<br />
}</p>
<p>public class SomeClass {<br />
  ...</p>
<p>  public void someMethod() {<br />
    if (LOG.isLoggable(SomeObjectStatus) {<br />
      LOG.log(SomeObjectStatus, someObject.expensiveMethod());<br />
    }<br />
  }<br />
}<br />
[&#47;java]</p>
<p>Note that a level check conditional is only required whereby an expensive method must be called to retrieve message arguments. The expense of the message string construction is handled by the <em>LogAdapter<&#47;em>.</p>
<p><strong>Conclusion<&#47;strong></p>
<p>Logging can be a repetitive, expensive and often error prone exercise. By centralising the log entries we reduce code duplication and potential for bugs through uniformity and re-use.</p>
