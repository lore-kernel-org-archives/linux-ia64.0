From: Grant Grundler <iod00d@hp.com>
Date: Fri, 23 Jan 2004 23:12:54 +0000
Subject: ethtool -d MCAs rx2600
Message-Id: <20040123231254.GC31911@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all.
This is just a warning: "Don't do this at home"
man ethtool says:

       -d     retrieves and prints a register dump for the specified
              ethernet device.

But it doesn't work so well on rx2600...I'll need to figure out why.
Or is it obvious to anyone?

This is with 2.6.1-rc1 on rx2600 talking to the built-in bcm5701.

hth,
grant

gsyprf3:~# ethtool eth1
Settings for eth1:
        Supported ports: [ MII ]
        Supported link modes:   10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Half 1000baseT/Full 
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Half 1000baseT/Full 
        Advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: d
        Current message level: 0x000000ff (255)
        Link detected: yes
gsyprf3:~# ethtool -d eth1
+CPU 1: SAL log contains MCA error record
+Err Record ID: 1    SAL Rev:  0.02
+Time: 01/23/2004 05:56:58    Severity 0

In case someone wants to dig more now, I've dropped the "errdump mca"
output on
	ftp://gsyprf10.external.hp.com/kernels/rx2600/mca_ethtool

(Matching vmlinuz, System.map, .config is also there 2.6.1-rc1.tgz)

thanks,
grant
