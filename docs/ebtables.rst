.. _ebtables:

L2 isolation
------------

Since providing a single VLAN for each private network across the whole data
center is practically impossible (currently expensive switches provide less
than 1024 vlans trucked on all ports), L2 isolation can be achieved via
MAC filtering on a common bridge over a single VLAN.

To ensure isolation we should allow traffic coming from TAP to have specific
source MAC and at the same time allow traffic coming to TAP to have a source
MAC in the same MAC prefix. Applying those rules only in FORWARD chain will not
guarantee isolation. The reason is because packets with target MAC a `multicast
address <http://en.wikipedia.org/wiki/Multicast_address>`_ go through INPUT and
OUTPUT chains.

.. code-block:: console

  # Create new chains
  ebtables -t filter -N FROMTAP5 -P RETURN
  ebtables -t filter -N TOTAP5 -P RETURN

  # Filter multicast traffic from VM
  ebtables -t filter -A INPUT -i tap5 -j FROMTAP5

  # Filter multicast traffic to VM
  ebtables -t filter -A OUTPUT -o tap5 -j TOTAP5

  # Filter traffic from VM
  ebtables -t filter -A FORWARD -i tap5 -j FROMTAP5
  # Filter traffic to VM
  ebtables -t filter -A FORWARD -o tap5 -j TOTAP5

  # Allow only specific src MAC for outgoing traffic
  ebtables -t filter -A FROMTAP5 -s ! aa:55:66:1a:ae:82 -j DROP
  # Allow only specific src MAC prefix for incoming traffic
  ebtables -t filter -A TOTAP5 -s ! aa:55:60:0:0:0/ff:ff:f0:0:0:0 -j DROP
