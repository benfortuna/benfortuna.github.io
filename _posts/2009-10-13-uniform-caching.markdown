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
<p>Typically object caching in Java is managed by the container or framework in use. Occasionally however there is a need to manually cache domain-specific objects, whereby a <em>java.util.Map</em> implementation will not suffice.</p>
<p>Using the popular <a href="http://ehcache.org/">ehcache</a> framework as an example, the following pattern is typically observed:</p>
<p>[java]<br />
public class SomeClass {</p>
<p>  private final Cache cache = ...</p>
<p>  ...</p>
<p>  public void doSomethingWithObject(Object key) {<br />
    SomeObject o = getSomeObject(key);<br />
    o.doSomething();<br />
  }</p>
<p>  public SomeObject getSomeObject(Object key) {<br />
    SomeObject o = null;</p>
<p>    Element element = cache.get(key);<br />
    if (element != null) {<br />
      o = element.getValue();<br />
    }<br />
    else {<br />
      o = load(key);<br />
      cache.put(new Element(key, o));<br />
    }<br />
    return o;<br />
  }</p>
<p>  private Object load(Object key) {<br />
    ...<br />
  }<br />
}<br />
[/java]</p>
<p>The common aspects of this pattern are as follows:</p>
<ul>
<li>Cache - the cache instance</li>
<li>Key - the unique key of the cachable object</li>
<li><em>load()</em> - the mechanism for loading objects not in the cache</li><br />
</ul></p>
<p><strong>Key Uniformity</strong></p>
<p>As most caching frameworks will allow any object to be used as a key, there is potential for different types of errors, such as a value specified as a key, mixing object types in a single cache, added to the wrong cache instance, etc. We can avoid some of these problems by enforcing a uniform approach to defining cache keys:</p>
<p>[java]<br />
public enum CacheEntry {</p>
<p>  SomeObject("org.mnode.example.someObject.%s");</p>
<p>  private String key;</p>
<p>  public String getKey(Object uid) {<br />
    return String.format(key, uid);<br />
  }<br />
}</p>
<p>public class SomeClass {<br />
  ...</p>
<p>  public SomeObject getSomeObject(Object uid) {<br />
    SomeObject o = null;<br />
    String key = CacheEntry.SomeObject.getKey(uid);<br />
    ...<br />
  }<br />
}<br />
[/java]</p>
<p>As this approach enforces a key 'namespace' for specific object types, it also makes it easier to store mixed data in a single cache, thus simplifying the management of cached objects:</p>
<p>[java]<br />
public class SomeClass {<br />
  ...</p>
<p>  public <T> T get(CacheEntry entry, Object uid) {<br />
    T o = null;<br />
    String key = entry.getKey(uid);</p>
<p>    Element element = cache.get(key);<br />
    if (element != null) {<br />
      o = (T) element.getValue();<br />
    }<br />
    else {<br />
      o = (T) load(key);<br />
      cache.put(new Element(key, o));<br />
    }<br />
    return o;<br />
  }<br />
}<br />
[/java]</p>
<p><strong>Object Loading</strong></p>
<p>Different types of cached data will also usually require specific code for loading the data initially. We can refactor this to be defined as part of the <em>CacheEntry</em>:</p>
<p>[java]<br />
interface Loader<T> {<br />
  T load(Object...args);<br />
}</p>
<p>public enum CacheEntry {</p>
<p>  SomeObject("org.mnode.example.someObject.%s", new Loader<SomeObject> {<br />
    SomeObject load(Object...args) {<br />
      Object uid = args[0];<br />
      // load data from backing store..<br />
      ...<br />
    }<br />
  });</p>
<p>  private String key;</p>
<p>  private Loader<?> loader;</p>
<p>  public String getKey(Object...args) {<br />
    return String.format(key, args);<br />
  }</p>
<p>  public Object load(Object...args) {<br />
    loader.load(args);<br />
  }<br />
}<br />
[/java]</p>
<p>Using this combined object loader and key namespace support we can extract the caching logic to a generic adapter:</p>
<p>[java]<br />
public class CacheAdapter {</p>
<p>  private final Cache cache;</p>
<p>  public CacheAdapter(Cache cache) {<br />
    this.cache = cache;<br />
  }</p>
<p>  public <T> T get(CacheEntry entry, Object...args) {<br />
    T o = null;<br />
    String key = entry.getKey(args);</p>
<p>    Element element = cache.get(key);<br />
    if (element != null) {<br />
      o = (T) element.getValue();<br />
    }<br />
    else {<br />
      o = (T) entry.load(args);<br />
      if (o != null) {<br />
        cache.put(new Element(key, o));<br />
      }<br />
    }<br />
    return o;<br />
  }<br />
}</p>
<p>public class SomeClass {</p>
<p>  private final CacheAdapter cache = ...</p>
<p>  public void doSomethingWithObject(Object uid) {<br />
    SomeObject o = cache.get(CacheEntry.SomeObject, uid);<br />
    o.doSomething();<br />
  }</p>
<p>  public SomeObject getSomeObject(Object uid) {<br />
    return cache.get(CacheEntry.SomeObject, uid);<br />
  }<br />
}<br />
[/java]</p>
<p><strong>A Real Example</strong></p>
<p>Caching XMPP VCard objects:</p>
<p>[java]<br />
import org.jivesoftware.smack.XMPPConnection;<br />
import org.jivesoftware.smack.XMPPException;<br />
import org.jivesoftware.smackx.packet.VCard;</p>
<p>public enum CacheEntry {</p>
<p>  VCard("vcard.%s", new Loader<VCard> {<br />
    VCard load(Object...args) {<br />
      String user = (String) args[0];<br />
      XMPPConnection connection = (XMPPConnection) args[1];<br />
      try {<br />
        VCard card = new VCard();<br />
        card.load(connection, user);<br />
      } catch (XMPPException e) {<br />
        return null;<br />
      }<br />
    }<br />
  });<br />
}</p>
<p>public class AvatarRepository {</p>
<p>  private final CacheAdapater vcardCache = ...</p>
<p>  private final XMPPConnection connection = ...</p>
<p>  public Image getAvatar(String user) {<br />
    Image avatar = null;</p>
<p>    VCard vcard = vcardCache.get(CacheEntry.VCard, user, connection);<br />
    if (vcard != null) {<br />
      avatar = new ImageIcon(vcard.getAvatar()).getImage();<br />
    }</p>
<p>    return avatar;<br />
  }<br />
}<br />
[/java]</p>
<p><strong>Conclusion</strong></p>
<p>By defining a key namespace and object loading mechanism for cachable data types we can improve the manageability of object caching in the following ways:</p>
<ul>
<li>Improved support for mixed data type caching</li>
<li>Increased decoupling from the caching implementation</li>
<li>Uniformity in object loading and caching</li><br />
</ul></p>
