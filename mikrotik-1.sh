/interface ethernet
set ether1 name=INTERNET
set ether2 name=LAN

/ip dhcp-client
add interface=INTERNET disabled=no

/ip address
add address=192.168.10.1/24 interface=LAN

/ip pool
add name=dhcp_pool ranges=192.168.10.10-192.168.10.100

/ip dhcp-server
add name=dhcp_lan interface=LAN address-pool=dhcp_pool disabled=no

/ip dhcp-server network
add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=8.8.8.8

/ip firewall nat
add chain=srcnat out-interface=INTERNET action=masquerade

/ip dhcp-client print
/ip dhcp-server lease print
/ip firewall nat print

