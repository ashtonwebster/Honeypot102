#!/bin/sh -e
#
# Super fancy Firewall 
#

# Clean the firewall 
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Some firewall variables
tcp_ports='22 80 514' 
udp_ports=''

hp_tcp='22'
hp_udp=''

dataVM_ip='192.168.1.21'
hpIPs='128.8.37.119 128.8.37.118'

# Collector IP, do not change. 
collector='192.168.1.254'

# Default policy
/sbin/iptables -F INPUT
/sbin/iptables -P INPUT DROP
/sbin/iptables -F FORWARD
/sbin/iptables -P FORWARD DROP
/sbin/iptables -A FORWARD -s 0.0.0.0/0.0.0.0 -d 0.0.0.0/0.0.0.0 -m state --state INVALID -j DROP
/sbin/iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -F OUTPUT
/sbin/iptables -P OUTPUT ACCEPT


####
## HP VM 
####

# Allow loopback
/sbin/iptables -A INPUT -i lo -j ACCEPT

# Allow TCP port listed in tcp_ports 
for i in $tcp_ports;
do
	/sbin/iptables -A INPUT -s $dataVM_ip -i eth0 -p tcp --dport $i -m state --state NEW -j ACCEPT
done

# Allow UDP port listed in udp_ports
for i in $udp_ports;
do
	/sbin/iptables -A INPUT -i eth0 -s $dataVM_ip -p udp -m udp --dport $i -j ACCEPT
done

# Allow collector to SSH into the HP VM (please do not remove)
/sbin/iptables -A INPUT -s $collector -i eth0 -p tcp --dport 22 -m state --state NEW -j ACCEPT

# Allow related/established connections
/sbin/iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

####
## Honeypot Incoming Traffic 
####

# READ THAT! 
# Case 1: Allow everything, just uncomment the lines right after "allow everything"  
# Case 2: Only few services (such as SSH), comment "allow everything" lines and uncomment all the lines after "Allow only certains ports" till the Rate Limiting section
#
# To block som traffic for one honeypot, use the -d <HP Public IP> parameter 
# for example: /sbin/iptables -A FORWARD -i br0 -d 128.8.37.122 -p tcp --dport 22 -j DROP  (will block SSH traffic to 128.8.37.122) 

# CASE 1: Allow everything on br0 (to the Honeypots Containers) 
#for i in $hpIPs;
#do
#        /sbin/iptables -A FORWARD -d $hpIPs -i br0 -j ACCEPT
#done

# CASE 2: Allow only certain ports
for i in $hp_tcp;
do
	for j in $hpIPs;
	do
	        /sbin/iptables -A FORWARD -i br0 -d $j -p tcp --dport $i -m state --state NEW -j ACCEPT
	done
done

for i in $hp_upd;
do
       for j in $hpIPs;
       do
        	/sbin/iptables -A FORWARD -i br0 -p udp -d $j -m udp --dport $i -j ACCEPT
	done 
done

# Allow Ping 
/sbin/iptables -A FORWARD -i br0 -p icmp -m icmp --icmp-type any -j ACCEPT


####
## Rate Limiting 
####

# Create a Table syn_flod in iptables (table of actions) 
/sbin/iptables -N syn_flood 
/sbin/iptables -A syn_flood -m limit --limit 10/s --limit-burst 10 -j RETURN 
# Log in SYSLOG: /sbin/iptables -A syn_flood -j LOG --log-level info --log-prefix "[FW] Rate Limit Reached: " 
/sbin/iptables -A syn_flood -j DROP 

for i in $hpIPs;
do
	# Traffic matching UDP/TCP flood goes to the table
	/sbin/iptables -A FORWARD -o br0 -s $i -p udp -j syn_flood 
	/sbin/iptables -A FORWARD -o br0 -s $i -p tcp --syn -j syn_flood 

	# SSH limitations
	/sbin/iptables -A FORWARD -o br0 -s $i -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH 
	# Log in SYSLOG: /sbin/iptables -A FORWARD -o br0 -s $i -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 8 --rttl --name SSH -j LOG --log-level info --log-prefix \"[FW] SSH SCAN blocked: \" 
	/sbin/iptables -A FORWARD -o br0 -s $i -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 8 --rttl --name SSH -j DROP 

	# RDP limitations
	/sbin/iptables -A FORWARD -o br0 -s $i -p tcp --dport 3389 -m state --state NEW -m recent --set --name RDP 
	# Log in SYSLOG:/sbin/iptables -A FORWARD -o br0 -s $i -p tcp --dport 3389 -m state --state NEW -m recent --update --seconds 60 --hitcount 8 --rttl --name RDP -j LOG --log-level info --log-prefix \"[FW] RDP SCAN blocked: \" 
	/sbin/iptables -A FORWARD -o br0 -s $i -p tcp --dport 3389 -m state --state NEW -m recent --update --seconds 60 --hitcount 8 --rttl --name RDP -j DROP  

	# HTTP limits
	/sbin/iptables  -A FORWARD -o br0 -s $i -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT 
done

# Allow all other HP outgoing traffic
for i in $hpIPs;
do
	/sbin/iptables -A FORWARD -s $i -o br0 -j ACCEPT
done

exit 0
