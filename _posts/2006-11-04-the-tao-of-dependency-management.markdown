---
layout: post
status: publish
published: true
title: The Tao of Dependency Management
author:
  display_name: fortuna
  login: admin
  email: fortuna@micronode.com
  url: ''
author_login: admin
author_email: fortuna@micronode.com
wordpress_id: 33
wordpress_url: http://blogs.modularity.net.au/thenextbigthing/?p=15
date: '2006-11-04 01:10:39 +1100'
date_gmt: '2006-11-03 15:10:39 +1100'
categories:
- Software
- Build
tags: []
comments: []
---
<p>Increasingly we see the use of dependency management tools becoming a part of mainstream software development. A core feature of many dependency management tools is the use of a repository (or set of repositories) that provide access to published artifacts. Perl has CPAN, PHP has PEAR, and Java has Maven.</p>
<p>Maven solves a number of problems that become more visible as projects become larger and more complex. First, there is the issue of managing an increasing number of dependencies. As a Java developer today you would be crazy not to make use of the large number of Open Source libraries available, however it does come with the challenge of managing all of those libraries - especially as there are frequently new versions released. Maven simplifies such management by allowing you to describe the dependencies (artifact id and version) from which it can automatically download and include in your classpath. Upgrading to a new version can be as simple as updating the version number in your project descriptor.</p>
<p>Not only does Maven improve the management of third-party dependencies, but it also provides an improved approach to generating internal artifacts and dependencies. In the past source code repositories have been somewhat misused as storage for dependencies also (e.g. JARs). Maven helps to move both internal and third-party artifacts out of the source code repository into a common artifact repository. This reduces the burden on your SCM system allowing it to focus solely on source artifacts rather than build artifacts.</p>
<p>Another, perhaps intangible benefit of a dependency management tool such as Maven is that it can be used to encourage regular commits to source repositories. Modern IDEs allow cross-project references in the workspace, which means that you can code for days in multiple projects without needing to commit anything to your SCM repository. The reasons why this is bad should be reasonably obvious (especially in multi-developer teams), so I won't go into details. Maven can help to discourage this practice by restricting the use of cross-project workspace references and relying solely on build artifacts from the repository. If these artifacts are built by an automated build tool (e.g. cruisecontrol), developers will be forced to commit individual project changes in order to build the artifacts and use the changes for work in other projects. This may seem counter-productive, and it would probably not be prudent to enforce this with an iron fist, but it will help developers to focus on fully testing project changes without being distracted by work in other projects.</p>
<p>There has always been resistance to change of the status quo, and the introduction of dependency management tools is no different. Many still argue that Ant is sufficient for doing whatever you want in a Java development environment, and that tools such as Maven are too restrictive and impose too many rules on build processes (I know because I once held these views myself). However once you become more familiar with dependency management tools you begin to see the bigger picture, in that where Ant provides a small piece of the puzzle (namely building), tools such as Maven aim to help manage much more of the entire development process.</p>
