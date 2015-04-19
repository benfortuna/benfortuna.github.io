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

Application logging always seems to become one of those [code smells], typically regarding [duplication of code], or conversely, non-uniform log messages.

There are many different ways to log a message in  Java, but variations on the following pattern are common:

    public class SomeClass {
      private static final Log LOG = LogFactory.getLog(SomeClass.class);
      ...
      public void someMethod() {
        if (LOG.isDebugEnabled()) {
          LOG.debug("Some message - someObject is: " + someObject);
        }
    
        try {
          ...
        } catch (SomeException e) {
          LOG.error("Unexpected error: " + e.getMessage(), e);
        }
      }
    }

The following information can be extracted from this pattern:


* Category - classification for log entries
* Level - the severity of a log entry
* Message - a log entry message
* Message arguments - variable components of a log message
* Exception - an exception for logging a stack trace



**Message Uniformity**

One problem with this pattern is that we tend to duplicate the same message strings when logging similar scenarios (e.g. unexpected exceptions).

Messages are also generally constructed by concatenating messages and message arguments - a practice that generally should be avoided if possible. We can solve these issues using message templates:

    import java.text.MessageFormat;
    
    public class SomeClass {
      private static final String UNEXPECTED_ERROR_MESSAGE = "Unexpected error: {0}";
      ...
      public void someMethod() {
        try {
          ...
        } catch (SomeException e) {
          LOG.error(MessageFormat.format(UNEXPECTED_ERROR_MESSAGE, e.getMessage()), e);
        }
      }
    }

Inconsistent log messages also result from having the message strings defined across multiple classes. Using message templates we can refactor these messages to be defined in a single location:

    public enum LogEntry {
      UnexpectedError("Unexpected Error: {0}");
    
      private final String message;
    
      public String getMessage(Object...args) {
        return MessageFormat.format(message, args);
      }
    }
    
    public class SomeClass {
      ...
    
      public void someMethod() {
        try {
          ...
        } catch (SomeException e) {
          LOG.error(LogEntry.UnexpectedError.getMessage(e.getMessage()), e);
        }
      }
    }

**Log Levels**

In the majority of cases, log entries that share the same message will also be logged at the same level. By associating a default log level with a log entry we can enforce uniformity of log levels:

    public enum LogLevel {
      Trace, Debug, Info, Warn, Error;
    }
    
    public enum LogEntry {
    
      UnexpectedError("Unexpected Error: {0}", LogLevel.Error);
      ...
    
      private final LogLevel level;
    
      public LogLevel getLevel() {
        return level;
      }
    }
    
    public class LogAdapter {
    
      private final Log log;
      ...
    
      public void log(LogEntry entry, Object...args) {
        if (entry.getLevel() == LogLevel.Error) {
          log.error(entry.getMessage(args));
        }
        else if (entry.getLevel() == LogLevel.Warn) {
          log.warn(entry.getMessage(args));
        }
        else ...
      }
    
      public void log(LogEntry entry, Throwable e, Object...args) {
        if (entry.getLevel() == LogLevel.Error) {
          log.error(entry.getMessage(args), e);
        }
        else if (entry.getLevel() == LogLevel.Warn) {
          log.warn(entry.getMessage(args), e);
        }
        else ...
      }
    }
    
    public class SomeClass {
    
      private static final LogAdapater LOG = new LogAdapter(LogFactory.getLog(SomeClass.class));
      ...
    
      public void someMethod() {
        try {
          ...
        } catch (SomeException e) {
          LOG.log(LogEntry.UnexpectedError, e, e.getMessage());
        }
      }
    }

To avoid the expensive construction of frequently logged message strings we use conditionals to check if a log level is enabled prior to message construction:

      ...
      if (LOG.isDebugEnabled()) {
        LOG.debug("Some message - someObject status is: " + someObject.expensiveMethod());
      }
      ...

Such conditionals are prone to error however, especially if the log level is changed:

      ...
      if (LOG.isDebugEnabled()) {
        LOG.warn("Some message - someObject status is: " + someObject.expensiveMethod());
      }
      ...

Uniform logging can help to avoid such mistakes:

    public enum LogEntry {
      SomeObjectStatus("Some message - someObject status is: {0}", LogLevel.Debug);
      ...
    }
    
    public class LogAdapter {
      ...
    
      public boolean isLoggable(LogEntry entry) {
        if (entry.getLevel() == LogLevel.Debug) {
          return log.isDebugEnabled();
        }
        ...
      }
    
      public void log(LogEntry entry, Object...args) {
        if (isLoggable(entry) {
          ...
        }
      }
    
      public void log(LogEntry entry, Throwable e, Object...args) {
        if (isLoggable(entry) {
          ...
        }
      }
    }
    
    public class SomeClass {
      ...
    
      public void someMethod() {
        if (LOG.isLoggable(SomeObjectStatus) {
          LOG.log(SomeObjectStatus, someObject.expensiveMethod());
        }
      }
    }

Note that a level check conditional is only required whereby an expensive method must be called to retrieve message arguments. The expense of the message string construction is handled by the *LogAdapter*.

**Conclusion**

Logging can be a repetitive, expensive and often error prone exercise. By centralising the log entries we reduce code duplication and potential for bugs through uniformity and re-use.

[code smells]: http://en.wikipedia.org/wiki/Code_smell
[duplication of code]: http://en.wikipedia.org/wiki/Duplicate_code
