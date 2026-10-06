# 2026-10-04 15:21:57 by RouterOS 7.24.4
# system id = KpDl2TxzVpK
#
/interface bridge
add name=bridge-vlan vlan-filtering=yes
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
set [ find default-name=ether6 ] disable-running-check=no
set [ find default-name=ether7 ] disable-running-check=no
set [ find default-name=ether8 ] disable-running-check=no
/interface vlan
add interface=bridge-vlan name=vlan10-admin vlan-id=10
add interface=bridge-vlan name=vlan20-tecnicos vlan-id=20
add interface=bridge-vlan name=vlan30-invitados vlan-id=30
/ip pool
add name=pool-admin ranges=10.10.10.10-10.10.10.254
add name=pool-tecnicos ranges=10.10.20.10-10.10.20.254
add name=pool-invitados ranges=10.10.30.10-10.10.30.254
/ip dhcp-server
add address-pool=pool-admin interface=vlan10-admin name=dhcp-admin
add address-pool=pool-tecnicos interface=vlan20-tecnicos name=dhcp-tecnicos
add address-pool=pool-invitados interface=vlan30-invitados name=\
    dhcp-invitados
/interface bridge port
add bridge=bridge-vlan interface=ether2 pvid=10
/interface bridge vlan
add bridge=bridge-vlan untagged=ether2 vlan-ids=10
add bridge=bridge-vlan untagged=ether2 vlan-ids=20
add bridge=bridge-vlan untagged=ether2 vlan-ids=30
/ip address
add address=10.10.10.1/24 interface=vlan10-admin network=10.10.10.0
add address=10.10.20.1/24 interface=vlan20-tecnicos network=10.10.20.0
add address=10.10.30.1/24 interface=vlan30-invitados network=10.10.30.0
/ip dhcp-client
add interface=ether1 name=client1
/ip dhcp-server network
add address=10.10.10.0/24 dns-server=8.8.8.8 gateway=10.10.10.1
add address=10.10.20.0/24 dns-server=8.8.8.8 gateway=10.10.20.1
add address=10.10.30.0/24 dns-server=8.8.8.8 gateway=10.10.30.1
/ip firewall filter
add action=accept chain=input connection-state=established,related
add action=drop chain=input comment="Bloquear todo lo que venga de la WAN" \
    in-interface=ether1
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
