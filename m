From: Roy Dragseth <Roy.Dragseth@cc.uit.no>
Date: Thu, 09 Jan 2003 08:30:55 +0000
Subject: [Linux-ia64] disabling nics using boot options.
Message-Id: <marc-linux-ia64-105590709805655@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello again.

Thanks for all the nice answers to my previous question about disabling=20
interfaces with efi.

As it seems to be impossible to disable the NICs in hardware, I want to try=
 to=20
make the linux kernel avoid probing the devices by using the reserve=3D boo=
t=20
option.  The problem is that I am unable to figure out the right parameters=
=20
for the Gbit NIC because /proc/pci doesn't contain any iobase information f=
or=20
this device.


I found an example in the BOOTPROMPT-HOWTO,=20
http://www.ibiblio.org/mdw/HOWTO/BootPrompt-HOWTO-3.html#ss3.4
and it works for the 10/100Mbit interface using the eepro100 module.

Here are what /proc/pci and /proc/iomem says about the relevant devices:

/proc/pci:
  Bus  0, device   3, function  0:
    Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 13).
      IRQ 53.
      Master Capable.  Latency=3D128.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0x80020000 [0x80020fff].
      I/O at 0xd00 [0xd3f].
      Non-prefetchable 32 bit memory at 0x80000000 [0x8001ffff].
  Bus 32, device   2, function  0:
    Ethernet controller: BROADCOM Corporation NetXtreme BCM5701 Gigabit=20
Ethernet (rev 21).
      IRQ 56.
      Master Capable.  Latency=3D192.  Min Gnt=3D64.
      Non-prefetchable 64 bit memory at 0x90800000 [0x9080ffff].
  Bus 128, device   1, function  0:
    Ethernet controller: BROADCOM Corporation NetXtreme BCM5701 Gigabit=20
Ethernet (#2) (rev 21).
      IRQ 65.
      Master Capable.  Latency=3D192.  Min Gnt=3D64.
      Non-prefetchable 64 bit memory at 0xc0000000 [0xc000ffff].

As one can see, the entry for the Ethernet Pro 100 nic has a line
      I/O at 0xd00 [0xd3f].
so the the reserve entry becomes 0xd00,64.  This works as expected, the dev=
ice=20
doesn't show up when I boot with=20
  reserve=3D0xd00,64
However, the entries for the Gbit interfaces don't have this information, d=
o=20
anyone know where I should look for the parameters for these devices?



r.

--=20

  The Computer Center, University of Troms=F8, N-9037 TROMS=D8, Norway.
	      phone:+47 77 64 41 07, fax:+47 77 64 41 00
     Roy Dragseth, High Performance Computing System Administrator
	 Direct call: +47 77 64 62 56. email: royd@cc.uit.no


