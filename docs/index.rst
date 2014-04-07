.. snf-network documentation master file, created by
   sphinx-quickstart on Wed Feb 12 20:00:16 2014.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to snf-network's documentation!
=======================================

snf-network is a set of scripts that handles the network configuration
of an instance inside a Ganeti cluster. It takes advantage of the
variables that Ganeti exports to its execution environment and issues
all the necessary commands to ensure network connectivity to the
instance based on the requested setup (see :ref:`below <setups>`).


Ganeti Mechanism
----------------

Each instance in Ganeti has NICs. Each NIC has the ip, mac, mode and
link options. Since the introduction of `IP pool management
<http://docs.ganeti.org/ganeti/master/html/design-network.html>`_, the
end-user can define networks and put NICs inside them (via the new
`network` option). In such a case the mode and link options are
inherited by the network's setup, set when the network was connected to
a nodegroup. So the basic procedure looks like this:

.. code-block:: console

  # gnt-network add --network 192.0.2.0/24 test
  # gnt-network connect test bridged br100
  # gnt-instance add --net 0:ip=pool,network=test ... inst

The instance will then have a NIC with ip=192.0.2.1 (picked
automatically from the subnet), mode=bridged, link=br100. In order for
Ganeti to actually ensure each NIC's connectivity it invokes certain
scripts. Those can be divided in two categories:

1. The ones invoked upon NIC creation/removal. Those are explicitly
   invoked by the node daemon which exports the exact NIC's info that is
   to be (un)configured to the scripts' execution environment.

2. The ones invoked by the Ganeti Hooks Manager before or after an
   opcode execution. The info exported there is the whole instance's
   configuration. The big difference from the previous ones is that
   instance configuration (from the master perspective) might vary or be
   totally different from the one that a running VM's NIC has. The
   reason is that some modifications can take place without hotplugging,
   which results to inconsistencies between runtime and config data.

The official Ganeti package ships the `kvm-ifup`, `kvm-ifdown`, and
`vif-ganeti` scripts. Those are more or less example files as they
ensure nothing more than a very basic configuration setup.


.. _environment:

Exported Environment
^^^^^^^^^^^^^^^^^^^^

The scripts that are about to configure the NIC's setup get all needed
info from their execution context, via environment variables. Ganeti
exports the following variables:

* IP
* MAC
* MODE
* LINK

If the NIC resides inside a network the additional variables are exported:

* NETWORK_NAME
* NETWORK_SUBNET
* NETWORK_GATEWAY
* NETWORK_MAC_PREFIX
* NETWORK_TAGS
* NETWORK_SUBNET6
* NETWORK_GATEWAY6

In case of hooks these variables are prefixed with
"GANETI_INSTANCE_NIC<idx>\_" where <idx> is each NIC's index.


kvm-ifup
^^^^^^^^

Upon instance startup and NIC hotplugging, Ganeti creates a TAP device
for each instance's NIC. For each TAP the `kvm-ifup` script is
explicitly invoked with the TAP name as the first argument and with the
environment mentioned :ref:`above <environment>`.

This script first searches for a user provided script
`/etc/ganeti/kvm-ifup-custom` and, if found, executes it instead.


vif-ganeti (Xen's kvm-ifup)
^^^^^^^^^^^^^^^^^^^^^^^^^^^

In case of Xen, Ganeti provides a hypervisor parameter that defines the
script to be executed per NIC upon instance startup: `vif-script`.
Ganeti provides and example `vif-ganeti` script which executes
`/etc/xen/scripts/vif-custom` if found.


kvm-ifdown
^^^^^^^^^^

In order to cleanup or modify the node's setup or the configuration of
an external component, Ganeti upon instance shutdown, successful
instance migration on source node or NIC hot-unplug, explicitly invokes
the `kvm-ifdown` script with the TAP name as its first argument and a
boolean second argument denoting whether we want to do a local cleanup
only (in case of instance migration) or totally unconfigure the
interface along with e.g., any DNS entries (in case of NIC hot-unplug).
This script searches for a user provided script under
`/etc/ganeti/kvm-ifdown-custom` and executes it instead, if found.


snf-network's scripts
---------------------

Here we briefly describe all scripts provided by the snf-network
package. Those scripts are needed to support the setups mentioned
:ref:`below <setups>`.


Scripts
^^^^^^^

snf-network includes the following NIC configuration scripts. As
mentioned before those scripts are indirectly executed by the ones
shipped with Ganeti (`kvm-ifup`, `kvm-ifdown`, `vif-ganeti`) to apply
the requested setup.


kvm-ifup-custom
"""""""""""""""

Installed under `/etc/ganeti/kvm-ifup-custom`. It gets the exported
environment, and based on the tags found acts accordingly. Specifically
it cleans up all stale rules for the specific interface, and then based
on NIC's mode, network's and instance's tags issues various rules
(brctl, ip, iptables, etc.). Finally if executes the :ref:`extra
<extra>` script if found.

.. _vif-custom:

vif-custom (Xen's kvm-ifup-custom)
""""""""""""""""""""""""""""""""""

Installed under `/etc/xen/scripts/vif-custom`. It sources the
appropriate file under `/var/run/ganeti/xen-hypervisor/nic/<idx>` which
is created by Ganeti and includes all the necessary info. Just like all
Xen scripts it calls the `success` method of `vif-common.sh` to notify
Xen that the configuration has succeeded. Besides that it does exactly
what `kvm-ifup-custom` does.


.. _extra:

ifup-extra
""""""""""

Usually admins want to apply several rules that are tailored to their
deployment.  In order to provide such functionality, the scripts that
bring the interfaces up (kvm-ifup-custom, vif-custom), before exiting
invoke a custom script (defined by the IFUP_EXTRA_SCRIPT variable of
`/etc/default/snf-network`) if found.  snf-network package provides an
example of this script `/etc/ganeti/ifup-extra`. It defines two
functions; setup_extra() and clean_extra().  Since snf-network is not
aware of the rules added by this script, the admin is responsible for
cleaning up any stale rule found due to a previous invocation. In other
words clean_extra() should wipe out every possible rule that setup_extra
might add and should run always no matter the instance's tags.

In an big data center it is reasonable to drop outgoing traffic to
mailservers so that user do not use the cloud for spamming. Still some
trusted instances could be allowed to connect to SMTP servers on port
25. The example script searches for an instance tag named with prefix
`some-prefix` and suffix `mail` and applies the desired rules. Note
that if no NIC identifier is given, rules will be added for all
interfaces of the instance. With other words to treat an instance as
a trusted one do:

.. code-block:: console

  # gnt-instance add-tags instance1 some-prefix:mail
  # gnt-instance modify --net 0: --hotplug instance1


kvm-ifdown-custom
"""""""""""""""""

Installed under `/etc/ganeti/kvm-ifdown-custom`. This is currently used
on a best effort basis and tries to cleanup node local setup related to
the interfaces that is being brought down.


Hooks
^^^^^

The snf-network includes two hooks that are installed under
`/etc/ganeti/hooks`.


snf-network-hook
""""""""""""""""

Installed under `instance-stop-post.d`, `instance-failover-post.d`,
`instance-remove-post.d` and `instance-migrate-post.d` hook dirs.

This hook gets all static info related to an instance from environment
variables and issues any commands needed. Before ifdown script was
supported, it was used to fix the node's setup upon migration. Now it
does nothing. Specifically it was used on a routed setup to delete the
neighbor proxy entry related to an instance's IPv6 on the source node.
Otherwise the traffic would continue to go via the source node since
there would be two nodes proxy-ing this IP.


snf-network-dnshook
"""""""""""""""""""

Installed under `instance-stop-post.d`, `instance-rename-post.d` and
`instance-remove-post.d` hook dirs.

This hook updates an external `DDNS <https://wiki.debian.org/DDNS>`_
setup via ``nsupdate``. Since we add/remove entries during ifup/ifdown
scripts, we use this only during instance remove/shutdown/rename. It
does not rely on exported environment but it queries first the DNS
server to obtain current entries and then it invokes the necessary
commands to remove them (and the relevant reverse ones too).


.. _setups:

Supported Setups
----------------

Currently, since NICs in Ganeti are not taggable objects, we use the
network's tags to customize each NIC configuration. If a NIC resides
inside a network, its tags are inherited and exported as the
NETWORK_TAGS environment variable. In the following subsections we will
mention all supported tags and their reflected underline setup. To
add a tag to a network run:

.. code-block:: console

  gnt-network add-tags <network-name> <tag1> <tag2> ...

Besides that, please see :ref:`here <configure>` how setup snf-network.

ip-less-routed
^^^^^^^^^^^^^^

This setup has the following characteristics:

* An external gateway on the same collision domain with all nodes on
  some interface (e.g. eth1, eth0.200) is needed.
* Each node is a router for the hosted VMs.
* The node itself does not have an IP inside the routed network.
* The node does proxy ARP for IPv4 networks.
* The node does proxy NDP for IPv6 networks while RA and NA are
  served locally by `nfdhcpd`_ since the VMs are not on the same link
  with the router.

Please see :ref:`here <routed-conf>` on how to configure it, and
:ref:`here <routed-traffic>` how it actually works.

.. _nfdhcpd: http://www.synnefo.org/docs/nfdhcpd/latest/index.html

mac-filtered
^^^^^^^^^^^^

In order to provide L2 isolation among several VMs we can use ebtables
on a **single** bridge. The infrastructure must provide a physical VLAN
or separate interface shared among all nodes in the cluster. All virtual
interfaces will be bridged on a common bridge (e.g. ``prv0``) and
filtering will be done via ebtables and MAC prefix. The concept is that
all interfaces on the same L2 should have the same MAC prefix. MAC
prefix uniqueness is guaranteed by the upper layers (e.g., Synnefo) and
passed to Ganeti as a network option.

For further info and implementation details please see :ref:`here
<ebtables>`.


physical-vlan
^^^^^^^^^^^^^

L2 isolation can be ensured also with one dedicated physical VLAN per
network. Each VLAN must be pre-provisioned and bridged on a separate
bridge. So this tag actually does nothing more that bridging the TAP
interface to the corresponding bridge (found through the LINK variable).

Please note that a one-to-one relationship between bridges, vlans, and
network should be guaranteed by the end-user or some other external
component on the upper layers (e.g., Synnefo).


.. _dns:

dns
^^^

snf-network can update an external `DDNS
<https://wiki.debian.org/DDNS>`_ server. If the `dns` network tag is
found, `snf-network-dnshook` will use `nsupdate` and add/remove entries
related to the interface that is being managed. To enable it the admin
must set the SERVER (the IP of the DNS server), FZONE (the domain of the
instances), KEYFILE (the .private file created by dnssec-keygen)
variables found in `/etc/default/snf-network`. Please note that
currenlty only one domain is supported for the instances.


nfdhcpd
^^^^^^^

snf-network creates binding files with all info required under
`/var/lib/nfdhcpd/` directory so that `nfdhcpd`_ can reply to DHCP, NS,
RS, DHCPv6 and thus instances get properly configured.


Firewall
--------

snf-network defines three security levels: protected, limited, and
unprotected.

- Protected means that traffic requesting new connections will be
  dropped, DNS responses (dport 53) will be accepted, ICMP protocol
  (ping) will be accepted and everything else dropped.

- Limited additionally allows SSH (dport 22) and RDP (dport 3389).

- Unprotected accepts everything.

Adding a network tag to define NICs' firewalling would force all NICs
inside the same network to have the same firewall configuration. Since
that would be very limiting, instead of network tags we use instance
tags in the following format:

synnefo:network:<ident>:<profile>

`ident` is the NIC identifier (index, uuid or name).
`profile` is one of the above security levels.

snf-network package provides `/etc/ferm/snf-network.ferm` which defines
the corresponding iptables chains with the proper rules.

mode=routed
^^^^^^^^^^^

In case the NIC's mode is routed, the node is actually the router for
the VMs, and the traffic gets through FORWARD chain. So if a tag is
found we add the following rule:

.. code-block:: console

  # iptables -t filter -I FORWARD -o $INTERFACE -j $chain


mode=bridged
^^^^^^^^^^^^

In case the NIC's mode is bridged, the traffic goes through a bridge and
thus we need physdev module of iptables:

.. code-block:: console

  # iptables -t filter -I FORWARD -m physdev --physdev-out $INTERFACE -j $chain


.. _configure:


Configure
---------

`snf-network` exports a set of configuration variables to the admin in
`/etc/default/snf-network`. In this section we explain how to use each
one of them.

 - ``STATE_DIR`` dir to backup each interface's configuration
 - ``LOGFILE`` path to file used to log snf-network related actions
 - ``IFUP_EXTRA_SCRIPT`` path to extra script provided by the admin for
   added/custom functionality (see :ref:`here <extra>`)
 - ``MAC_MASK`` applied to MAC in order to get the MAC prefix that
   guarantees L2 isolation (see :ref:`here <ebtables>`)
 - ``TAP_CONSTANT_MAC`` is the MAC that all routed TAPs will obtain
 - ``MAC2EUI64`` is an external script for converting a MAC to EUI64
   based on an IPv6 prefix
 - ``NFDHCPD_STATE_DIR`` the path to store binding files for nfdhcpd
   (see `nfdhcpd`_)
 - ``GANETI_NIC_DIR`` dir to find NIC information in case of Xen (see
   :ref:`here <vif-custom>`)
 - ``*_TAG`` network tags related to supported setups (see :ref:`here
   <setups>`)
 - ``RUNLOCKED_OPTS`` options for runlocked helper script used as a
   wrapper for ebtables
 - ``SERVER`` the IP/FQDN of the name server
 - ``FZONE`` the domain that the VMs will reside in
 - ``KEYFILE`` path to file used with -k option of nsupdate
 - ``TTL`` defines the duration in seconds that a DNS record may be cached


.. toctree::
  :hidden:

  routed
  ebtables
