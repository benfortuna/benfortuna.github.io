---
layout: post
title: Cloud-native or Cloud-agnostic?
date: '2017-07-27 22:57:02 +1000'
---

Cloud-native applications are designed
for deployment to Cloud infrastructure. As more organisations are going "all-in" on
the Cloud, they are committing their application designs to an assumption
of cloud infrastructure. Such assumptions can reduce complexity by removing the
constraints of fixed infrastructure resources, leaving developers free to conceptualise
designs that are more scalable and modular in design.

The biggest impediment to such liberal thinking is cost. Organisations are
quickly discovering that all those little pieces of the infrastructure puzzle quickly add up
to a large monthly infrastructure bill. Two approaches to Cloud architecture that have cost-optimisation in mind
are Platform-as-a-Service (PaaS) and Serverless architectures.

The promise of PaaS is that Cloud companies can leverage their experience of running
large scalable infrastructure to provide a platform that will meet the needs of the majority of
software architectures whilst reducing the overhead of managing complex designs. PaaS platforms offer
reduced complexity and optimised resource management at the expense of flexibility to evolve and adapt
the architecture. Historically we know all-in-one platforms, such as Java EE, can suffer from becoming
out-dated very quickly and can discourage architecture evolution. Whilst a modern PaaS can appear to
offer great flexibility through containerisation, etc. the ever-accelerating pace of change in DevOps
can mean committing to a PaaS is a risk.

Serverless architectures, whilst offering greater flexibility of design, still ultimately must commit
to a platform on which to base the architecture. In this way it can be even more risky than
containerisation in a PaaS as you may not have the option of migrating a serverless architecture
of it is heavily integrated with a PaaS.
