---
layout: post
status: publish
published: true
title: Future-proofing Software
author:
  display_name: fortuna
  login: admin
  email: fortuna@micronode.com
  url: ''
author_login: admin
author_email: fortuna@micronode.com
wordpress_id: 31
wordpress_url: http://blogs.modularity.net.au/thenextbigthing/?p=5
date: '2006-05-25 00:55:52 +1000'
date_gmt: '2006-05-24 14:55:52 +1000'
categories:
- Software
- Design
tags: []
comments: []
---

In the search for methodologies and patterns that help to build better quality software, we find that our methods continue to evolve at a blistering pace. Whether its the leap from procedural to object-oriented design, or the difference between the waterfall and prototyping approaches, all share the common goal of building robust, complex software systems. Whilst many great advances continue to be made, one thing that eludes us in the search for the perfect development strategy is how to future-proof a software architecture. We like to think that we will have all the requirements and intended uses of the software prior to design and implementation. In reality however, this is almost never the case. Requirements change, focus shifts, often to the point that the final requirements bear little resemblance to those the original design was based on. Ultimately a good design should be able to handle such a shift in requirements, however even the best designs will not cope with a major refactoring of the intended uses of a system.

So how can we protect our software designs from such a seachange in required functionality? In addition to accepted practices and methodologies, we should try to incorporate the following principles into our architecture:


* **Think Small** Usually when we design architectures the components tend to be large and provide support for a multitude of features. It is not uncommon to even have a single component representing the front end, back end, or business rules of a system. Combined with the principle that a good design will explicitly identify each component's roles and responsibilities, we find our components are too rigid and not really amenable to changes in these roles and responsibilities. The solution to this problem is to build smaller, more specific components. Rather than components handling many different tasks, we should design the architecture in such a way that each component is responsible for handling a single task. Such tasks may include support for a specific protocol or data format, a service used to access an external or legacy system, or even data structures specific to a particular feature in the system. The important thing to remember is that a component should only handle a single task rather than a collection of them as is the popular approach.




* **Separate APIs from Implementation** Another recognised good practice is the use of *Interfaces* when designing an API allowing components to communicate with each other. By using interfaces we are effectively defining the contract a component holds with the rest of the system, irregardless of the implementation details. Whilst this allows us to provide alternate implementations of the API without further changes to external components, we still generally need to provide an entirely new version of a component - even if the API itself has not changed. Although the API is not bound by the implementation, usually the entire API (interfaces and implementation) are bundled together anyway. The solution then is to separate the API definition from the implementation and provide them as two distinct components. By doing this the API specification does not require updating where only the implementation requires changes. Additionally, alternative implementations of the API may also be deployed independently, thus maximising the possible re-use of a component API.




* **Loose Coupling** A major contributing factor to the complexity of software are the dependencies each component has on its peers. Aside from the careful design decisions required to ensure no two components are dependent on each other (i.e. cyclic dependencies), typically where even a single dependency is not resolved the entire system will fail. To avoid architectures easily susceptible to such a catastrophic failure we need to maximise decoupling of components. This does not necessarily equate to minimising dependencies across components, but rather is more concerned with ensuring that such dependencies impose as little restrictions as possible. This is the promise of Loose Coupling, whereby individual components may operate independently or as a part of a larger system constructed of similarly loosely coupled components. One popular approach to incorporating Loose Coupling in software design is the Inversion Of Control pattern (also known as Dependency Injection). A number of frameworks based on the Inversion Of Control pattern are now available, which assist in the "wiring together" of individual components to construct a complete system. This encourages greater encapsulation in components and simplifies other aspects of quality assurance such as unit testing.



By adhering to these principles we are able to design software that can adapt to just about any change in direction required of it. No longer do we need to throw away an entire system and start from scratch, as we will be able to incrementally upgrade and replace individual components without detriment to the rest of the system. This approach also enables us to extend the functionality of the system by "wiring in" new components as required. Best of all, these principles ensure that the software architecture is built from clearly defined design contracts and encourages maximim re-use.
