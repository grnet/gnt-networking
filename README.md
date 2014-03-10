snf-network
===========

Overview
--------

This is snf-network, a set of scripts that handle the network configuration of
an instance inside a [Ganeti](http://code.google.com/p/ganeti) cluster.
It takes advantage of the variables that Ganeti exports to their execution
environment and issues all the necessary commands to ensure network
connectivity to the instance, based on the requested setup.

This package provides the following scripts:

* mac2eui64: Script for obtaining an EUI-64 address based on its 48-bit
  MAC address and an IPv6 prefix
* kvm-ifup-custom: Script invoked when an interface goes up (KVM version)
* kvm-ifdown-custom: Script invoked when an interface goes down (KVM version)
* vif-custom: Script invoked when an interface goes up (Xen version)
* snf-network-hook: The part of snf-network's functionality which is
  implemented as a Ganeti hook
* snf-network-log: Simple script for logging actions from inside Ganeti
  scripts/hooks
* snf-network-dnshook: Ganeti hook for updating dynamic DNS entries
* ifup-extra: Example script for extra, deployment-specific functionality
* common.sh: Common library, sourced by all above scripts.
* runlocked: Helper script which serializes the execution of commands
  on a host machine

Project Page
------------

Please see the [official Synnefo site](http://www.synnefo.org) and the
[latest snf-network docs](http://www.synnefo.org/docs/snf-network/latest/index.html)
for more information.


Copyright and license
=====================

Copyright 2012-2014 GRNET S.A. All rights reserved.

Redistribution and use in source and binary forms, with or
without modification, are permitted provided that the following
conditions are met:

  1. Redistributions of source code must retain the above
     copyright notice, this list of conditions and the following
     disclaimer.

  2. Redistributions in binary form must reproduce the above
     copyright notice, this list of conditions and the following
     disclaimer in the documentation and/or other materials
     provided with the distribution.

THIS SOFTWARE IS PROVIDED BY GRNET S.A. ``AS IS'' AND ANY EXPRESS
OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL GRNET S.A OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and
documentation are those of the authors and should not be
interpreted as representing official policies, either expressed
or implied, of GRNET S.A.
