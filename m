From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 22 May 2002 01:43:36 +0000
Subject: [Linux-ia64] linux 2.5.17 --- acpi-related hang on boot?
Message-Id: <marc-linux-ia64-105590701905590@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
	With the small pfn_to_pte  patch I sent here last week, Linux
2.5.17 builds and boots on the HP simulator.  But on a real i2000 it
hangs during boot. 

I enabled verbose ACPI debug output by changing ACPI_DEBUG_LOW to
ACPI_DEBUG_HIGH in acpi_bus.c

The last printout on the screen is:

exregion-0321 [0001] [39] Ex_pci_config_space_ha PCI_config 0 (8)
Seg(0000) Bus(0000) Dev(0010) Func(0000) Reg(0040)

According to /proc/pci on a working kernel, bus 0 device 16 func 0 is
the host bridge:

Bus 0, device 16, function 0:
  Host bridge: Intel Corp, 460GX - 84460GX System Address Controlled
(SAC) (rev 3)

 How can I go on from here?  


Peter C

