########################################
# RESET CONFIG (OPTIONAL UKK CLEAN)
########################################
/system reset-configuration no-defaults=yes skip-backup=yes

########################################
# INTERFACE NAME
########################################
/interface ethernet
set [find default-name=ether1] name=WAN
set [find default-name=ether2] name=LAN
set [find default-name=ether3] name=AP

########################################
# IP ADDRESS ROUTER (GANTI SESUAI SOAL)
########################################
/ip address
add address=192.168.10.1/24 interface=LAN
add address=192.168.20.1/24 interface=AP

########################################
# DHCP CLIENT (INTERNET)
########################################
/ip dhcp-client
add interface=WAN disabled=no

########################################
# DHCP SERVER LAN
########################################
/ip pool
add name=pool_lan ranges=192.168.10.10-192.168.10.100

/ip dhcp-server
add name=dhcp_lan interface=LAN address-pool=pool_lan lease-time=1h disabled=no

/ip dhcp-server network
add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=8.8.8.8

########################################
# NAT INTERNET
########################################
/ip firewall nat
add chain=srcnat out-interface=WAN action=masquerade

########################################
# ROUTING RIP (OPTIONAL UKK)
########################################
/routing rip interface
add interface=LAN
add interface=AP

########################################
# DNS
########################################
/ip dns
set servers=8.8.8.8,1.1.1.1 allow-remote-requests=yes

########################################
# TRAFFIC SHAPING
########################################
/queue simple
add name=LIMIT-LAN target=192.168.10.0/24 max-limit=5M/5M

########################################
# HOTSPOT (OPTIONAL UKK)
########################################
/ip hotspot profile
add name=hsprof hotspot-address=192.168.20.1 dns-name=login.ukk.local

/ip hotspot
add name=hotspot1 interface=AP address-pool=pool_lan profile=hsprof disabled=no

########################################
# USER HOTSPOT
########################################
/ip hotspot user
add name=ukk password=ukk123 profile=default

########################################
# SSH AKTIF
########################################
/ip service
set ssh disabled=no

########################################
# SECURITY BASIC
########################################
/user add name=ukk-admin password=ukk123 group=full
