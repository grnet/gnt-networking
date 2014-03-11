.. snf-network documentation master file, created by
   sphinx-quickstart on Wed Feb 12 20:00:16 2014.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to snf-network's documentation!
=======================================

snf-network is a set of scripts that handle the network configuration of
an instance inside a Ganeti cluster. It takes advantage of the
variables that Ganeti exports to their execution environment and issue
all the necessary commands to ensure network connectivity to the instance
based on the requested setup.

Environment
-----------

Ganeti supports `IP pool management
<http://docs.ganeti.org/ganeti/master/html/design-network.html>`_
so that end-user can put instances inside networks and get all information
related to the network in scripts. Specifically the following options are
exported:

* IP
* MAC
* MODE
* LINK

are per NIC specific, whereas:

* NETWORK_SUBNET
* NETWORK_GATEWAY
* NETWORK_MAC_PREFIX
* NETWORK_TAGS
* NETWORK_SUBNET6
* NETWORK_GATEWAY6

are inherited by the network in which a NIC resides (optional).

Scripts
-------

The scripts can be divided into two categories:

1. The scripts that are invoked explicitly by Ganeti upon NIC creation.

2. The scripts that are invoked by Ganeti Hooks Manager before or after an
   opcode execution.

The first group has the exact NIC info that is about to be configured where
the latter one has the info of the whole instance. The big difference is that
instance configuration (from the master perspective) might vary or be total
different from the one that is currently running. The reason is that some
modifications can take place without hotplugging.


kvm-ifup-custom
^^^^^^^^^^^^^^^

Ganeti upon instance startup and NIC hotplugging creates the TAP devices to
reflect to the instance's NICs. After that it invokes the Ganeti's `kvm-ifup`
script with the TAP name as first argument and an environment including
all NIC's and the corresponding network's info. This script searches for
a user provided one under `/etc/ganeti/kvm-ifup-custom` and executes it
instead.


vif-custom
^^^^^^^^^^

In case of Xen, Ganeti provides a hypervisor parameter that defines the script
to be executed per NIC upon instance startup: `vif-script`. Ganeti provides
`vif-ganeti` as example script which executes `/etc/xen/scripts/vif-custom` if
found.


ifup-extra
^^^^^^^^^^

Usually admins want to apply several rules that are tailored to each
deployment.  In order to provide such functionality, the scripts that bring the
interfaces up (kvm-ifup-custom, vif-custom), before exiting invoke a custom
script (defined by IFUP_EXTRA_SCRIPT variable of `/etc/default/snf-network`) if
found.  snf-network package provides an example of this script
`/etc/ganeti/ifup-extra`.  As you can see it defines two functions;
setup_extra() and clean_extra().  Since snf-network is not aware of the rules
added by this script, the admin is responsible of cleaning up any stale rule
found due to a previous invocation. In other words clean_extra() should wipe
out every possible rule that setup_extra might add and should run always
no matter the instance's tags.

In an big data center it is reasonable to drop outgoing traffic to mailservers
so that user do not use the cloud for spamming. Still some trusted
instances could be allowed to connect to SMTP servers on port 25. The
example script search for an instance tag named with prefix `some-prefix`
and suffix `mail` and applies the desired rules. Note that if no NIC
identifier is given, rules will be added for all interfaces of the
instance. With other words to treat an instance as a trusted one do:

.. code-block:: console

  # gnt-instance add-tags instance1 some-prefix:mail
  # gnt-instance modify --net 0: --hotplug instance1



kvm-ifdown-custom
^^^^^^^^^^^^^^^^^

In order to cleanup or modify the node's setup or the configuration of an
external component, Ganeti upon instance shutdown, successful instance
migration on source node and NIC hot-unplug invokes `kvm-ifdown` script
with the TAP name as first argument and a boolean second argument pointing
whether we want to do local cleanup only (in case of instance migration) or
totally unconfigure the interface along with e.g., any DNS entries (in case
of NIC hot-unplug). This script searches for a user provided one under
`/etc/ganeti/kvm-ifdown-custom` and executes it instead.


snf-network-hook
^^^^^^^^^^^^^^^^

This hook gets all static info related to an instance from environment
variables and issues any commands needed. It was used to fix node's setup upon
migration when ifdown script was not supported but now it does nothing.
Specifically it was used on a routed setup to delete the neighbor proxy entry
related to an instance's IPv6 on the source node. Otherwise the traffic
would continue to go via the source node since there would be two nodes
proxy-ing this IP.


snf-network-dnshook
^^^^^^^^^^^^^^^^^^^

This hook updates an external `DDNS <https://wiki.debian.org/DDNS>`_ setup via
``nsupdate``. Since we add/remove entries during ifup/ifdown scripts, we use
this only during instance remove/shutdown/rename. It does not rely on exported
environment but it queries first the DNS server to obtain current entries and
then it invokes the necessary commands to remove them (and the relevant
reverse ones too).


Supported Setups
----------------

Currently since NICs in Ganeti are not taggable objects, we use network's and
instance's tags to customize each NIC configuration. NIC inherits the network's
tags (if attached to any) and further customization can be achieved with
instance tags e.g. <tag prefix>:<NIC's UUID or name>:<tag>. In the following
subsections we will mention all supported tags and their reflected underline
setup.


ip-less-routed
^^^^^^^^^^^^^^

This setup has the following characteristics:

* An external gateway on the same collision domain with all nodes on some
  interface (e.g. eth1, eth0.200) is needed.
* Each node is a router for the hosted VMs
* The node itself does not have an IP inside the routed network
* The node does proxy ARP for IPv4 networks
* The node does proxy NDP for IPv6 networks while RA and NA are
* RS and NS are served locally by
  `nfdhcpd <http://www.synnefo.org/docs/nfdhcpd/latest/index.html>`_
  since the VMs are not on the same link with the router.


Please see :ref:`here <routed-conf>` how to configure it, and :ref:`here
<routed-traffic>` how it actually works.


private-filtered
^^^^^^^^^^^^^^^^

In order to provide L2 isolation among several VMs we can use ebtables on a
**single** bridge. The infrastructure must provide a physical VLAN or separate
interface shared among all nodes in the cluster. All virtual interfaces will
be bridged on a common bridge (e.g. ``prv0``) and filtering will be done via
ebtables and MAC prefix. The concept is that all interfaces on the same L2
should have the same MAC prefix. MAC prefix uniqueness is guaranteed by
Synnefo and passed to Ganeti as a network option.

For further info and implementation details please see :ref:`here <ebtables>`.


dns
^^^

snf-network can update an external `DDNS <https://wiki.debian.org/DDNS>`_
server.  `ifup` and `ifdown` scripts, if `dns` network tag is found, will use
`nsupdate` and add/remove entries related to the interface that is being
managed.


nfdhcpd
^^^^^^^

snf-network creates binding files with all info required under
`/var/lib/nfdhcpd/` directory so that `nfdhcpd
<http://www.synnefo.org/docs/nfdhcpd/latest/index.html>`_ can reply
to DHCP, NS, RS, DHCPv6 and thus instances get properly configured.



Firewall
--------

Synnefo defines three security levels: protected, limited, and unprotected.

- Protected means that traffic requesting new connections will be dropped,
  DNS responses (dport 53) will be accepted, icmp protocol (ping) will be
  accepted and everything else dropped.

- Limited additionally allows SSH (dport 22) and RDP (dport 3389).

- Unprotected accepts everything.

This firewall profile is defined per NIC. Since NICs are not taggable objects
in Ganeti we tag instances instead. The tag should be of the following
format:

synnefo:network:<ident>:<profile>

`ident` is the NIC identifier (index, uuid or name).
`profile` is one of the above security levels.

snf-network package provides `/etc/ferm/snf-network.ferm` which defines
the corresponding iptables chains with the proper rules.

routed setup
^^^^^^^^^^^^

Since the node is the router for the VMs, the traffic gets through FORWARD
chain. So if a tag is found we add the following rule:

.. code-block:: console

  # iptables -t filter -I FORWARD -o $INTERFACE -j $chain


bridged setup
^^^^^^^^^^^^^

In case traffic goes through a bridge we need physdev module of iptables:

.. code-block:: console

  # iptables -t filter -I FORWARD -m physdev --physdev-out $INTERFACE -j $chain
