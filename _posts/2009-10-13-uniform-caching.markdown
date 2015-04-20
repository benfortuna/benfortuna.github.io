---
layout: post
status: publish
published: true
title: Uniform Caching
author:
  display_name: fortuna
  login: admin
  email: fortuna@micronode.com
  url: ''
author_login: admin
author_email: fortuna@micronode.com
wordpress_id: 101
wordpress_url: http://basepatterns.org/?p=101
date: '2009-10-13 12:14:42 +1100'
date_gmt: '2009-10-13 01:14:42 +1100'
categories:
- Java
tags:
- patterns
- caching
- adapter
comments: []
---

Typically object caching in Java is managed by the container or framework in use. Occasionally however there is a need to manually cache domain-specific objects, whereby a *java.util.Map* implementation will not suffice.

Using the popular [ehcache] framework as an example, the following pattern is typically observed:

{% highlight java linenos %}

public class SomeClass {

  private final Cache cache = ...

  ...

  public void doSomethingWithObject(Object key) {

    SomeObject o = getSomeObject(key);

    o.doSomething();

  }

  public SomeObject getSomeObject(Object key) {

    SomeObject o = null;

    Element element = cache.get(key);

    if (element != null) {

      o = element.getValue();

    }

    else {

      o = load(key);

      cache.put(new Element(key, o));

    }

    return o;

  }

  private Object load(Object key) {

    ...

  }

}
{% endhighlight %}

The common aspects of this pattern are as follows:


* Cache - the cache instance
* Key - the unique key of the cachable object
* *load()* - the mechanism for loading objects not in the cache



**Key Uniformity**

As most caching frameworks will allow any object to be used as a key, there is potential for different types of errors, such as a value specified as a key, mixing object types in a single cache, added to the wrong cache instance, etc. We can avoid some of these problems by enforcing a uniform approach to defining cache keys:

{% highlight java linenos %}

public enum CacheEntry {

  SomeObject("org.mnode.example.someObject.%s");

  private String key;

  public String getKey(Object uid) {

    return String.format(key, uid);

  }

}

public class SomeClass {

  ...

  public SomeObject getSomeObject(Object uid) {

    SomeObject o = null;

    String key = CacheEntry.SomeObject.getKey(uid);

    ...

  }

}
{% endhighlight %}

As this approach enforces a key 'namespace' for specific object types, it also makes it easier to store mixed data in a single cache, thus simplifying the management of cached objects:

{% highlight java linenos %}

public class SomeClass {

  ...

  public <T> T get(CacheEntry entry, Object uid) {

    T o = null;

    String key = entry.getKey(uid);

    Element element = cache.get(key);

    if (element != null) {

      o = (T) element.getValue();

    }

    else {

      o = (T) load(key);

      cache.put(new Element(key, o));

    }

    return o;

  }

}
{% endhighlight %}

**Object Loading**

Different types of cached data will also usually require specific code for loading the data initially. We can refactor this to be defined as part of the *CacheEntry*:

{% highlight java linenos %}

interface Loader<T> {

  T load(Object...args);

}

public enum CacheEntry {

  SomeObject("org.mnode.example.someObject.%s", new Loader<SomeObject> {

    SomeObject load(Object...args) {

      Object uid = args[0];

      // load data from backing store..

      ...

    }

  });

  private String key;

  private Loader<?> loader;

  public String getKey(Object...args) {

    return String.format(key, args);

  }

  public Object load(Object...args) {

    loader.load(args);

  }

}
{% endhighlight %}

Using this combined object loader and key namespace support we can extract the caching logic to a generic adapter:

{% highlight java linenos %}

public class CacheAdapter {

  private final Cache cache;

  public CacheAdapter(Cache cache) {

    this.cache = cache;

  }

  public <T> T get(CacheEntry entry, Object...args) {

    T o = null;

    String key = entry.getKey(args);

    Element element = cache.get(key);

    if (element != null) {

      o = (T) element.getValue();

    }

    else {

      o = (T) entry.load(args);

      if (o != null) {

        cache.put(new Element(key, o));

      }

    }

    return o;

  }

}

public class SomeClass {

  private final CacheAdapter cache = ...

  public void doSomethingWithObject(Object uid) {

    SomeObject o = cache.get(CacheEntry.SomeObject, uid);

    o.doSomething();

  }

  public SomeObject getSomeObject(Object uid) {

    return cache.get(CacheEntry.SomeObject, uid);

  }

}
{% endhighlight %}

**A Real Example**

Caching XMPP VCard objects:

{% highlight java linenos %}

import org.jivesoftware.smack.XMPPConnection;

import org.jivesoftware.smack.XMPPException;

import org.jivesoftware.smackx.packet.VCard;

public enum CacheEntry {

  VCard("vcard.%s", new Loader<VCard> {

    VCard load(Object...args) {

      String user = (String) args[0];

      XMPPConnection connection = (XMPPConnection) args[1];

      try {

        VCard card = new VCard();

        card.load(connection, user);

      } catch (XMPPException e) {

        return null;

      }

    }

  });

}

public class AvatarRepository {

  private final CacheAdapater vcardCache = ...

  private final XMPPConnection connection = ...

  public Image getAvatar(String user) {

    Image avatar = null;

    VCard vcard = vcardCache.get(CacheEntry.VCard, user, connection);

    if (vcard != null) {

      avatar = new ImageIcon(vcard.getAvatar()).getImage();

    }

    return avatar;

  }

}
{% endhighlight %}

**Conclusion**

By defining a key namespace and object loading mechanism for cachable data types we can improve the manageability of object caching in the following ways:


* Improved support for mixed data type caching
* Increased decoupling from the caching implementation
* Uniformity in object loading and caching



[ehcache]: http://ehcache.org/