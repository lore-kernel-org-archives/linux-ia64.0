From: Roy Dragseth <royd@cc.uit.no>
Date: Thu, 09 Jan 2003 21:23:11 +0000
Subject: [Linux-ia64] Re: Re: disabling nics using boot options.
Message-Id: <marc-linux-ia64-105590709805662@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805661@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805661@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thursday 09 January 2003 21:48, Bill Nottingham wrote:
> Are there any error messages from the driver?

I find this in /var/log/messages

Jan  9 20:09:51 compute-1-1 kernel: Error seeking in /dev/kmem
Jan  9 20:09:51 compute-1-1 kernel: Symbol #tg3, value 001bc000
Jan  9 20:09:51 compute-1-1 kernel: Error adding kernel module table entry.

and this in dmesg:

tg3.c:v0.99 (Jun 11, 2002)
PCI: Found IRQ 56 for device 20:02.0
divert: allocating divert_blk for eth1
eth1: Tigon3 [partno(BCM95700A6) rev 0105 PHY(5701)] (PCI:66MHz:64-bit)=20
10/100/1
000BaseT Ethernet 00:30:6e:38:99:07
PCI: Found IRQ 65 for device 80:01.0
divert: allocating divert_blk for eth2
eth2: Tigon3 [partno(A6825-60101) rev 0105 PHY(5701)] (PCI:66MHz:64-bit)=20
10/100/
1000BaseT Ethernet 00:30:6e:2b:cc:05
eth2: Link is up at 1000 Mbps, full duplex.
eth2: Flow control is off for TX and off for RX.
ACPI: Power Button (FF) [PWRF]
ACPI: Sleep Button (FF) [SLPF]
eth2: Link is up at 1000 Mbps, full duplex.
eth2: Flow control is off for TX and off for RX.

I don't really know if these are real error messages.

r.

--=20

  The Computer Center, University of Troms=F8, N-9037 TROMS=D8, Norway.
	      phone:+47 77 64 41 07, fax:+47 77 64 41 00
     Roy Dragseth, High Performance Computing System Administrator
	 Direct call: +47 77 64 62 56. email: royd@cc.uit.no


