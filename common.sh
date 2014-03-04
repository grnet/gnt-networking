#!/bin/bash

source /etc/default/snf-network

function try {

  $1 &>/dev/null || true

}

function clear_routed_setup_ipv4 {

 arptables -D OUTPUT -o $INTERFACE --opcode request -j mangle
 while ip rule del dev $INTERFACE; do :; done
 iptables -D FORWARD -i $INTERFACE -p udp --dport 67 -j DROP

}

function clear_routed_setup_ipv6 {

 while ip -6 rule del dev $INTERFACE; do :; done

}

function delete_neighbor_proxy {

  if [ -z "$EUI64" -z -o "$UPLINK6" ]; then
    return
  fi

  $SNF_NETWORK_LOG $0 "ip -6 neigh del proxy $EUI64 dev $UPLINK6"
  ip -6 neigh del proxy $EUI64 dev $UPLINK6

}

function clear_routed_setup_firewall {

  for oldchain in protected unprotected limited; do
    iptables  -D FORWARD -o $INTERFACE -j $oldchain
    ip6tables -D FORWARD -o $INTERFACE -j $oldchain
  done

}

function clear_ebtables {

  runlocked $RUNLOCKED_OPTS ebtables -D FORWARD -i $INTERFACE -j $FROM
  runlocked $RUNLOCKED_OPTS ebtables -D INPUT -i $INTERFACE -j $FROM
  runlocked $RUNLOCKED_OPTS ebtables -D FORWARD -o $INTERFACE -j $TO
  runlocked $RUNLOCKED_OPTS ebtables -D OUTPUT -o $INTERFACE -j $TO

  runlocked $RUNLOCKED_OPTS ebtables -X $FROM
  runlocked $RUNLOCKED_OPTS ebtables -X $TO
}


function clear_nfdhcpd {

  rm $NFDHCPD_STATE_DIR/$INTERFACE

}


function routed_setup_ipv4 {

  if [ -z "$INTERFACE" -o -z "$NETWORK_GATEWAY" -o -z "$IP" -o -z "$TABLE" ]
  then
    return
  fi

	# mangle ARPs to come from the gw's IP
	arptables -A OUTPUT -o $INTERFACE --opcode request -j mangle --mangle-ip-s    "$NETWORK_GATEWAY"

	# route interface to the proper routing table
	ip rule add dev $INTERFACE table $TABLE

	# static route mapping IP -> INTERFACE
	ip route replace $IP proto static dev $INTERFACE table $TABLE

	# Enable proxy ARP
	echo 1 > /proc/sys/net/ipv4/conf/$INTERFACE/proxy_arp

}

function send_garp {

  if [ -z "$IP" -o -z "$UPLINK" ]; then
    return
  fi

  # Send GARP from host to upstream router
  echo 1 > /proc/sys/net/ipv4/ip_nonlocal_bind
  $SNF_NETWORK_LOG $0 "arpsend -U -i $IP -c1 $UPLINK"
  arpsend -U -i $IP -c1 $UPLINK
  echo 0 > /proc/sys/net/ipv4/ip_nonlocal_bind

}

function routed_setup_ipv6 {

  if [ -z "$EUI64" -o -z "$TABLE" -o -z "$INTERFACE" -o -z "$UPLINK6" ]
  then
    return
  fi
	# Add a routing entry for the eui-64
	ip -6 rule add dev $INTERFACE table $TABLE
	ip -6 ro replace $EUI64/128 dev $INTERFACE table $TABLE
	ip -6 neigh add proxy $EUI64 dev $UPLINK6

	# disable proxy NDP since we're handling this on userspace
	# this should be the default, but better safe than sorry
	echo 0 > /proc/sys/net/ipv6/conf/$INTERFACE/proxy_ndp

  # Send Unsolicited Neighbor Advertisement
  $SNF_NETWORK_LOG $0 "ndsend $EUI64 $UPLINK6"
  ndsend $EUI64 $UPLINK6

}

# pick a firewall profile per NIC, based on tags (and apply it)
function routed_setup_firewall {
	# for latest ganeti there is no need to check other but uuid
	ifprefixindex="synnefo:network:$INTERFACE_INDEX:"
	ifprefixname="synnefo:network:$INTERFACE_NAME:"
	ifprefixuuid="synnefo:network:$INTERFACE_UUID:"
	for tag in $TAGS; do
		tag=${tag#$ifprefixindex}
		tag=${tag#$ifprefixname}
		tag=${tag#$ifprefixuuid}
		case $tag in
		protected)
			chain=protected
		;;
		unprotected)
			chain=unprotected
		;;
		limited)
			chain=limited
		;;
		esac
	done

	if [ "x$chain" != "x" ]; then
		iptables  -A FORWARD -o $INTERFACE -j $chain
		ip6tables -A FORWARD -o $INTERFACE -j $chain
	fi
}

function init_ebtables {

  runlocked $RUNLOCKED_OPTS ebtables -N $FROM -P RETURN
  runlocked $RUNLOCKED_OPTS ebtables -A FORWARD -i $INTERFACE -j $FROM
  # This is needed for multicast packets
  runlocked $RUNLOCKED_OPTS ebtables -A INPUT -i $INTERFACE -j $FROM

  runlocked $RUNLOCKED_OPTS ebtables -N $TO -P RETURN
  runlocked $RUNLOCKED_OPTS ebtables -A FORWARD -o $INTERFACE -j $TO
  # This is needed for multicast packets
  runlocked $RUNLOCKED_OPTS ebtables -A OUTPUT -o $INTERFACE -j $TO

}


function setup_ebtables {

  # do not allow changes in ip-mac pair
  if [ -n "$IP" ]; then
    :; # runlocked $RUNLOCKED_OPTS ebtables -A $FROM --ip-source \! $IP -p ipv4 -j DROP
  fi
  runlocked $RUNLOCKED_OPTS ebtables -A $FROM -s \! $MAC -j DROP
  # accept dhcp responses from host (nfdhcpd)
  # this is actually not needed because nfdhcpd opens a socket and binds is with
  # tap interface so dhcp response does not go through bridge
  # INDEV_MAC=$(cat /sys/class/net/$INDEV/address)
  # runlocked $RUNLOCKED_OPTS ebtables -A $TO -s $INDEV_MAC -p ipv4 --ip-protocol=udp  --ip-destination-port=68 -j ACCEPT
  # allow only packets from the same mac prefix
  runlocked $RUNLOCKED_OPTS ebtables -A $TO -s \! $MAC/$MAC_MASK -j DROP
}

function setup_masq {

  # allow packets from/to router (for masquerading)
  # runlocked $RUNLOCKED_OPTS ebtables -A $TO -s $NODE_MAC -j ACCEPT
  # runlocked $RUNLOCKED_OPTS ebtables -A INPUT -i $INTERFACE -j $FROM
  # runlocked $RUNLOCKED_OPTS ebtables -A OUTPUT -o $INTERFACE -j $TO
  return

}

function setup_nfdhcpd {
	umask 022
  FILE=$NFDHCPD_STATE_DIR/$INTERFACE
  #IFACE is the interface from which the packet seems to arrive
  #needed in bridged mode where the packets seems to arrive from the
  #bridge and not from the tap
	cat >$FILE <<EOF
INDEV=$INDEV
IP=$IP
MAC=$MAC
HOSTNAME=$INSTANCE
TAGS="$TAGS"
GATEWAY=$NETWORK_GATEWAY
SUBNET=$NETWORK_SUBNET
GATEWAY6=$NETWORK_GATEWAY6
SUBNET6=$NETWORK_SUBNET6
EUI64=$EUI64
EOF

}

function get_uplink {

  local table=$1
  UPLINK=$(ip route list table $table | grep "default via" | awk '{print $5}')
  UPLINK6=$(ip -6 route list table $table | grep "default via" | awk '{print $5}')
  if [ -n "$UPLINK" -o -n "$UPLINK6" ]; then
    $SNF_NETWORK_LOG $0 "* Table $table: uplink -> $UPLINK, uplink6 -> $UPLINK6"
  fi

}

# Because we do not have IPv6 value in our environment
# we caclulate it based on the NIC's MAC and the IPv6 subnet (if any)
# first argument MAC second IPv6 subnet
# Changes global value EUI64
get_eui64 () {

  local mac=$1
  local prefix=$2

  if [ -z "$prefix" ]; then
    EUI64=
  else
    EUI64=$($MAC2EUI64 $mac $prefix)
    $SNF_NETWORK_LOG $0 "* $mac + $prefix -> $EUI64"
  fi

}


# DDNS related functions

# ommit zone statement
# nsupdate  will attempt determine the correct zone to update based on the rest of the input
send_command () {

  local command="$1"
  $SNF_NETWORK_LOG $0 "* $command"
  nsupdate -k $KEYFILE > /dev/null << EOF
  server $SERVER
  $command
  send
EOF

}


update_arecord () {

  local action=$1
  local command=
  if [ -n "$IP" ]; then
    command="update $action $GANETI_INSTANCE_NAME.$FZONE $TTL A $IP"
    send_command "$command"
  fi

}


update_aaaarecord () {

  local action=$1
  local command=
  if [ -n "$EUI64" ]; then
    command="update $action $GANETI_INSTANCE_NAME.$FZONE $TTL AAAA $EUI64"
    send_command "$command"
  fi

}


update_ptrrecord () {

  local action=$1
  local command=
  if [ -n "$IP" ]; then
    command="update $action $RLPART.$RZONE. $TTL PTR $GANETI_INSTANCE_NAME.$FZONE"
    send_command "$command"
  fi

}

update_ptr6record () {

  local action=$1
  local command=
  if [ -n "$EUI64" ]; then
    command="update $action $R6LPART$R6ZONE. $TTL PTR $GANETI_INSTANCE_NAME.$FZONE"
    send_command "$command"
  fi

}

update_all () {

  local action=$1
  $SNF_NETWORK_LOG $0 "Update ($action) dns for $GANETI_INSTANCE_NAME $IP $EUI64"
  update_arecord $action
  update_aaaarecord $action
  update_ptrrecord $action
  update_ptr6record $action

}


# first argument is an eui64 (IPv6)
# sets GLOBAL args R6REC, R6ZONE, R6LPART
# lets assume eui64=2001:648:2ffc:1::1
# the following commands produce:
# R6REC=1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.1.0.0.0.c.f.f.2.8.4.6.0.1.0.0.2.ip6.arpa
# R6ZONE=1.0.0.0.c.f.f.2.8.4.6.0.1.0.0.2.ip6.arpa
# R6LPART=1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.
get_rev6_info () {

  local eui64=$1
  if [ -z "$eui64" ]; then
    R6REC= ; R6ZONE= ; R6LPART= ;
  else
    R6REC=$(host $eui64 | egrep -o '([[:alnum:]]\.){32}ip6.arpa' )
    R6ZONE=$(echo $R6REC | awk -F. 'BEGIN{rpart="";} { for (i=32;i>16;i=i-1) rpart=$i "." rpart; } END{print rpart "ip6.arpa";}')
    R6LPART=$(echo $R6REC | awk -F. 'BEGIN{lpart="";} { for (i=16;i>0;i=i-1) lpart=$i "." lpart; } END{print lpart;}')
  fi

}


# first argument is an ipv4
# sets args RZONE, RLPART
# lets assume IP=203.0.113.1
# RZONE="113.0.203.in-add.arpa"
# RLPART="1"
get_rev4_info () {

  local ip=$1
  if [ -z "$ip" ]; then
    RZONE= ; RLPART= ;
  else
    OLDIFS=$IFS
    IFS=". "
    set -- $ip
    a=$1 ; b=$2; c=$3; d=$4;
    IFS=$OLDIFS
    RZONE="$c.$b.$a.in-addr.arpa"
    RLPART="$d"
  fi

}

get_ebtables_chains () {

  local iface=$1
  FROM=FROM${iface^^}
  TO=TO${iface^^}

}

get_instance_info () {

  if [ -z "$GANETI_INSTANCE_NAME" -a -n "$INSTANCE" ]; then
    GANETI_INSTANCE_NAME=$INSTANCE
  fi

}

get_mode_info () {

  local iface=$1
  local mode=$2
  local link=$3

  TABLE=
  INDEV=

  if [ "$mode" = "routed" ]; then
    TABLE=$link
    INDEV=$iface
  elif [ "$mode" = "bridged" ]; then
    INDEV=$link
  fi

}


# Use environment variables to calculate desired info
# IP, MAC, LINK, TABLE, BRIDGE,
# NETWORK_SUBNET, NETWORK_GATEWAY, NETWORK_SUBNET6, NETWORK_GATEWAY6
function get_info {

  $SNF_NETWORK_LOG $0 "Getting info for $INTERFACE of $GANETI_INSTANCE_NAME"
  get_instance_info
  get_mode_info $INTERFACE $MODE $LINK
  get_ebtables_chains $INTERFACE
  get_rev4_info $IP
  get_eui64 $MAC $NETWORK_SUBNET6
  get_rev6_info $EUI64
  get_uplink $TABLE

}


# Query nameserver for entries related to the specific instance
# An example output is the following:
# www.google.com has address 173.194.113.114
# www.google.com has address 173.194.113.115
# www.google.com has address 173.194.113.116
# www.google.com has address 173.194.113.112
# www.google.com has address 173.194.113.113
# www.google.com has IPv6 address 2a00:1450:4001:80b::1012
query_dns () {

  HOSTQ="host -s -R 3 -W 3"
  HOST_IP_ALL=$($HOSTQ $GANETI_INSTANCE_NAME.$FZONE $SERVER | sed -n 's/.*has address //p')
  HOST_IP6_ALL=$($HOSTQ $GANETI_INSTANCE_NAME.$FZONE $SERVER | sed -n 's/.*has IPv6 address //p')

}
