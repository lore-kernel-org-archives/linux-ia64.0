From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 05 Mar 2002 00:36:19 +0000
Subject: [Linux-ia64] simeth problem...
Message-Id: <marc-linux-ia64-105590701905218@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
	I'm having problems with the simulated ethernet interface.

From within the simulator, I can ping any machine on the local network
except the machine the simulator is being hosted on.

I can ping the simulated ethernet from any machine on the network
except the one the simulator is hosted on.

I'm using kernel 2.4.18 in each case.

Does anyone have any ideas?

The simulator is running on the machine with address 192.168.77.9

sh-2.05a# ifconfig
Warning: cannot open /proc/net/dev (No such file or directory). Limited output.
eth0      Link encap:Ethernet  HWaddr 00:A0:CC:60:B4:87  
          inet addr:192.168.77.13  Bcast:192.168.77.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          Interrupt:49 

sh-2.05a# ping 192.168.77.9
PING 192.168.77.9 (192.168.77.9): 56 data bytes

--- 192.168.77.9 ping statistics ---
8 packets transmitted, 0 packets received, 100% packet loss
sh-2.05a# ping 192.168.77.10
PING 192.168.77.10 (192.168.77.10): 56 data bytes
64 bytes from 192.168.77.10: icmp_seq=0 ttl%5 time.7 ms
64 bytes from 192.168.77.10: icmp_seq=1 ttl%5 time=7.6 ms
64 bytes from 192.168.77.10: icmp_seq=2 ttl%5 time=7.6 ms
64 bytes from 192.168.77.10: icmp_seq=3 ttl%5 time=7.6 ms
64 bytes from 192.168.77.10: icmp_seq=4 ttl%5 time=7.6 ms

--- 192.168.77.10 ping statistics ---
5 packets transmitted, 5 packets received, 0% packet loss
round-trip min/avg/max = 7.6/9.0/14.7 ms
sh-2.05a# 

