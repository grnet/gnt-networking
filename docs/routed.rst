.. _routed:

Routed Setup
------------

In the following section we are going to describe how we can achieve a routed
setup for a specific subnet across the data center. We distinguish here
two ways to do that:

1) All nodes are going to host VMs (VMC) and one separate node will be the
   external router (Gateway).

2) All nodes are going to host VMs (VMC) and one of them will also be the
   external router (Gateway).

Whether the external router will do NAT or not depends on whether we have
a public route-able subnet available or just a single node with internet
access.

For the next examples we assume that the route-able subnet will be
``192.0.2.0/24``, the gateway ``192.0.2.1``, nodes' primary interface will
be ``eth0`` while VM traffic will go through ``eth0.500`` physical VLAN.
Of course ``eth0.500`` can be substituted with a separate physical interface
(e.g. ``eth1``). All examples use `/etc/networ/interfaces` file, the
common way for configuring static interfaces under Debian.

.. _routed-conf:


Configuration
^^^^^^^^^^^^^

For a VMC that will just forward traffic to an external router the proposed
setup is:

.. code-block:: console

  auto eth0.500
  iface eth0.500 inet manual
      up ip link set dev eth0.500 up
      # Host can reach VMs in other hosts
      up ip route add 192.0.2.0/24 dev eth0.500
      # Incoming traffic will be routed via extra table
      up ip rule add iif eth0.500 lookup 500
      # VM-to-VM traffic will go direct through VLAN
      up ip route add 192.0.2.0/24 dev eth0.500 table 500
      # Outgoing VM traffic will go through external router on VLAN
      up ip route add default via 192.0.2.1 dev eth0.500 table 500
      # Enable proxy ARP and forwarding
      up echo 1 > /proc/sys/net/ipv4/conf/eth0.500/proxy_arp
      up echo 1 > /proc/sys/net/ipv4/conf/eth0.500/forwarding
      # Mangle ARP request originating from the host
      up arptables -A OUTPUT -o eth0.500 --opcode request -j mangle --mangle-ip-s 192.0.2.254
      down arptables -D OUTPUT -o eth0.500 --opcode request -j mangle
      down ip rule del iif eth0.500 lookup 500


Of course instead of `500` routing table we could alias it with a more
reasonable name (e.g. `routed_net`):

.. code-block:: console

  echo 500 routed_net >> /etc/iproute2/rt_tables

For a node that acts **only** as a router we have:

.. code-block:: console

  auto eth0.500
  iface eth0.500 inet manual
      up ip link set eth0.500 up
      # Add gateway address to the interface
      up ip addr add 192.0.2.1/24 dev eth0.500
      # Enable forwarding and NAT
      up echo 1 > /proc/sys/net/ipv4/conf/eth0.500/forwarding
      up iptables -t nat -I POSTROUTING -o eth0 -s 192.0.2.0/24 -j MASQUERADE
      down iptables -t nat -I POSTROUTING -o eth0 -s 192.0.2.0/24 -j MASQUERADE


For a node that acts both as a router and a VMC we have:

.. code-block:: console

  auto eth0.500
  iface eth0.500 inet manual
      up ip link set eth0.500 up
      # Outgoing VM traffic is routed via extra table
      up ip rule add iif eth0.500 lookup 500
      # Host-to-VM traffic is routed via extra table
      up ip rule add to 192.0.2.0/24 lookup 500
      # VM-to-VM and Router-to-VM traffic will go direct through VLAN
      up ip route add 192.0.2.0/24 dev eth0.500 table 500
      # Add gateway address to the interface
      up ip addr add 192.0.2.1 dev eth0.500
      up echo 1 > /proc/sys/net/ipv4/conf/eth0.500/proxy_arp
      up echo 1 > /proc/sys/net/ipv4/conf/eth0.500/forwarding
      up iptables -t nat -I POSTROUTING -o eth0 -s 192.0.2.0/24 -j MASQUERADE
      down iptables -t nat -I POSTROUTING -o eth0 -s 192.0.2.0/24 -j MASQUERADE
      down ip rule del to 192.0.2.0/24 lookup 500


In order to use a more compact `interfaces` file, custom scripts should be
used for ifup/ifdown since this setup is not a common practice. 
Please see `interfaces` example along with `vmrouter.ifup` and `vmrouter.ifdown` that
are placed in /etc/network/if-up.d and /etc/network/if-down.d respectively.

.. _routed-traffic:

Routed Traffic
^^^^^^^^^^^^^^

Here we break down all stages of networking and analyze how we connectivity
is actually achieved. To do so let's first assume the following:

* ``IP`` is the instance's IP
* ``GW_IP`` is the external router's IP
* ``NODE_IP`` is the node's IP
* ``ARP_IP`` is a dummy IP inside the network needed for proxy ARP

* ``MAC`` is the instance's MAC
* ``TAP_MAC`` is the TAP's MAC
* ``DEV_MAC`` is the host's DEV MAC
* ``GW_MAC`` is the external router's MAC

* ``DEV`` is the node's device that the router is visible from
* ``TAP`` is the host interface connected with the instance's eth0


Proxy ARP
"""""""""

Since we suppose to be on the same link with the router, ARP takes place first:

1) The VM wants to know the GW_MAC. Since the traffic is routed we do proxy ARP.

 - ARP, Request who-has GW_IP tell IP
 - ARP, Reply GW_IP is-at TAP_MAC ``echo 1 > /proc/sys/net/conf/TAP/proxy_arp``
 - So `arp -na` inside the VM shows: ``(GW_IP) at TAP_MAC [ether] on eth0``

2) The host wants to know the GW_MAC. Since the node does **not** have an IP
   inside the network we use the dummy one specified above.

 - ARP, Request who-has GW_IP tell ARP_IP (Created by DEV)
   ``arptables -I OUTPUT -o DEV --opcode 1 -j mangle --mangle-ip-s ARP_IP``
 - ARP, Reply GW_IP is-at GW_MAC

3) The host wants to know MAC so that it can proxy it.

 - We simulate here that the VM sees **only** GW on the link.
 - ARP, Request who-has IP tell GW_IP (Created by TAP)
   ``arptables -I OUTPUT -o TAP --opcode 1 -j mangle --mangle-ip-s GW_IP``
 - So `arp -na` inside the host shows:
   ``(GW_IP) at GW_MAC [ether] on DEV, (IP) at MAC on TAP``

4) GW wants to know who does proxy for IP.

 - ARP, Request who-has IP tell GW_IP
 - ARP, Reply IP is-at DEV_MAC (Created by host's DEV)

When an interface gets up inside a host we should invalidate all entries
related to its IP among other nodes and the router. Specifically we use:
``arpsend -U -c 1 -i IP DEV``.


L3 Routing
""""""""""

With the above we have a working proxy ARP configuration. The rest is done
via simple L3 routing. We assume the following:

* ``TABLE`` is the extra routing table
* ``SUBNET`` is the IPv4 subnet where the VM's IP resides

1) Outgoing traffic:

 - Traffic coming out of TAP is routed via TABLE
   ``ip rule add dev TAP table TABLE``
 - TABLE states that default route is GW_IP via DEV
   ``ip route add default via GW_IP dev DEV``

2) Incoming traffic:

 - Packet arrives at router
 - Router knows from proxy ARP that the IP is at DEV_MAC.
 - Router sends Ethernet packet with tgt DEV_MAC
 - Host receives the packet from DEV interface
 - Traffic coming out DEV is routed via TABLE
   ``ip rule add dev DEV table TABLE``
 - Traffic targeting IP is routed to TAP
   ``ip route add IP dev TAP``

3) Host to VM traffic:

 - Impossible if the VM resides in the host
 - If router is also VMC there is a rule for it: ``ip rule to SUBNET lookup TABLE``
 - Otherwise there is a route for it: ``ip route add SUBNET dev DEV``

IPv6
^^^^

The IPv6 setup is pretty similar but instead of proxy ARP we have proxy NDP
and RS and NS coming from TAP are served by nfdhpcd. RA contain network's
prefix and have M flag unset in order the VM to obtain its IP6 via SLAAC, and
O flag set to obtain static info (nameservers, domain search list) via DHCPv6
(also served by nfdhcpd).

Again the VM sees only the TAP interface as router and the only neighbor on its
link local space. The host must proxy the VM's IPv6
``ip -6 neigh add EUI64 dev DEV``.

When an interface gets up inside a host we should invalidate all entries
related to its IPv6 among other nodes and the router. Specifically we use:
``ndsend EUI64 DEV`` .

An example interface file for the case where host is only VMC could be:

.. code-block:: console

  auto eth0.500
  iface eth0.500 inet6 manual
    up ip link set eth0.500 up
    up ip -6 route add 2001:db8::/64 dev eth0.500
    up ip -6 route add 2001:db8::/64 dev eth0.500 table 500
    up ip -6 route add default via 2001:db8::1 dev eth0.500 table 500
    up ip -6 rule add iif eth0.500 lookup 500
    up echo 1 > /proc/sys/net/ipv6/conf/eth0.500/proxy_ndp
    down ip -6 rule del iif eth0.500 lookup 500
