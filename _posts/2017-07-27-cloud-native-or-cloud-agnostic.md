---
layout: post
title: Cloud-native or Cloud-agnostic?
date: '2017-07-27 22:57:02 +1000'
---

[astronaut architecture]: https://www.joelonsoftware.com/2001/04/21/dont-let-architecture-astronauts-scare-you/

As more organisations are going "all-in" on the Cloud, they are committing their application designs
to an assumption of cloud-based infrastructure. These Cloud-native applications are designed with scalability
and high availability in mind, free from the constraints of finite infrastructure design and planning.

There are, however, risks associated with Cloud, two of which are spiraling complexity and cost. Somewhat
counter-intuitively, it is possible to have too much freedom when it comes to software design.
Even very smart people can fall into the [astronaut architecture] trap.

The promise of Platform-as-a-Service (PaaS) is that Cloud companies can leverage their experience of running
large scalable infrastructure to provide a platform that will meet the needs of the majority of
software architectures whilst reducing the overhead of managing complex designs. PaaS platforms offer
reduced complexity and optimised resource management at the expense of flexibility to evolve and adapt
the architecture. Historically we know all-in-one platforms, such as Java Enterprise Edition, can suffer from becoming
out-dated very quickly and discourage architecture evolution. Whilst a modern PaaS can appear to
offer greater flexibility through containerisation, etc. the ever-accelerating pace of change in DevOps
can still mean that committing to a PaaS is a risk.

Serverless architectures, whilst offering greater flexibility of design, still must commit
to a platform on which to base the architecture. In this way it can be even more risky than
containerisation in a PaaS as you may not have the option of migrating a serverless architecture
of it is heavily integrated with a PaaS.

Ultimately the decision build for a specific cloud platform or remain Cloud-agnostic will depend on the
application, but focusing on a modular, standards-based design can help to avoid architecture lock-in.
