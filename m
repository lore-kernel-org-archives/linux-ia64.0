From: Lukas Bulwahn <lukas.bulwahn@gmail.com>
Date: Mon, 17 Feb 2020 08:15:58 +0000
Subject: [PATCH] tty/serial: cleanup after ioc*_serial driver removal
Message-Id: <20200217081558.10266-1-lukas.bulwahn@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>, Christoph Hellwig <hch@lst.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Joe Perches <joe@perches.com>, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, Lukas Bulwahn <lukas.bulwahn@gmail.com>

Commit 9c860e4cf708 ("tty/serial: remove the ioc3_serial driver") and
commit a017ef17cfd8 ("tty/serial: remove the ioc4_serial driver") removed
the ioc{3,4}_serial driver, but missed some files.

Fortunately, ./scripts/get_maintainer.pl --self-test complains:

  warning: no file matches F: drivers/tty/serial/ioc?_serial.c

The driver is gone, so remove the other obsolete files and maintainer
entry as well.

Signed-off-by: Lukas Bulwahn <lukas.bulwahn@gmail.com>
---
Christoph, please ack. Tony, please pick this patch.
applies cleanly on 5.6-rc2 and next-20200217
only sanity-grep for filenames and make htmldocs, no compile testing

 Documentation/ia64/index.rst  |   1 -
 Documentation/ia64/serial.rst | 165 ----------------------------------
 MAINTAINERS                   |   8 --
 include/linux/ioc3.h          |  93 -------------------
 4 files changed, 267 deletions(-)
 delete mode 100644 Documentation/ia64/serial.rst
 delete mode 100644 include/linux/ioc3.h

diff --git a/Documentation/ia64/index.rst b/Documentation/ia64/index.rst
index 0436e1034115..171e68725eea 100644
--- a/Documentation/ia64/index.rst
+++ b/Documentation/ia64/index.rst
@@ -14,5 +14,4 @@ IA-64 Architecture
    fsys
    irq-redir
    mca
-   serial
    xen
diff --git a/Documentation/ia64/serial.rst b/Documentation/ia64/serial.rst
deleted file mode 100644
index 1de70c305a79..000000000000
--- a/Documentation/ia64/serial.rst
+++ /dev/null
@@ -1,165 +0,0 @@
-=======
-Serial Devices
-=======
-
-Serial Device Naming
-==========
-
-    As of 2.6.10, serial devices on ia64 are named based on the
-    order of ACPI and PCI enumeration.  The first device in the
-    ACPI namespace (if any) becomes /dev/ttyS0, the second becomes
-    /dev/ttyS1, etc., and PCI devices are named sequentially
-    starting after the ACPI devices.
-
-    Prior to 2.6.10, there were confusing exceptions to this:
-
-	- Firmware on some machines (mostly from HP) provides an HCDP
-	  table[1] that tells the kernel about devices that can be used
-	  as a serial console.  If the user specified "console=ttyS0"
-	  or the EFI ConOut path contained only UART devices, the
-	  kernel registered the device described by the HCDP as
-	  /dev/ttyS0.
-
-	- If there was no HCDP, we assumed there were UARTs at the
-	  legacy COM port addresses (I/O ports 0x3f8 and 0x2f8), so
-	  the kernel registered those as /dev/ttyS0 and /dev/ttyS1.
-
-    Any additional ACPI or PCI devices were registered sequentially
-    after /dev/ttyS0 as they were discovered.
-
-    With an HCDP, device names changed depending on EFI configuration
-    and "console=" arguments.  Without an HCDP, device names didn't
-    change, but we registered devices that might not really exist.
-
-    For example, an HP rx1600 with a single built-in serial port
-    (described in the ACPI namespace) plus an MP[2] (a PCI device) has
-    these ports:
-
-      =====  =====     ======    ======   ===-      Type        MMIO           pre-2.6.10      pre-2.6.10     2.6.10+
-		  address
-				 (EFI console    (EFI console
-                                 on builtin)     on MP port)
-      =====  =====     ======    ======   ===-      builtin     0xff5e0000        ttyS0           ttyS1         ttyS0
-      MP UPS      0xf8031000        ttyS1           ttyS2         ttyS1
-      MP Console  0xf8030000        ttyS2           ttyS0         ttyS2
-      MP 2        0xf8030010        ttyS3           ttyS3         ttyS3
-      MP 3        0xf8030038        ttyS4           ttyS4         ttyS4
-      =====  =====     ======    ======   ===-
-Console Selection
-========-
-    EFI knows what your console devices are, but it doesn't tell the
-    kernel quite enough to actually locate them.  The DIG64 HCDP
-    table[1] does tell the kernel where potential serial console
-    devices are, but not all firmware supplies it.  Also, EFI supports
-    multiple simultaneous consoles and doesn't tell the kernel which
-    should be the "primary" one.
-
-    So how do you tell Linux which console device to use?
-
-	- If your firmware supplies the HCDP, it is simplest to
-	  configure EFI with a single device (either a UART or a VGA
-	  card) as the console.  Then you don't need to tell Linux
-	  anything; the kernel will automatically use the EFI console.
-
-	  (This works only in 2.6.6 or later; prior to that you had
-	  to specify "console=ttyS0" to get a serial console.)
-
-	- Without an HCDP, Linux defaults to a VGA console unless you
-	  specify a "console=" argument.
-
-    NOTE: Don't assume that a serial console device will be /dev/ttyS0.
-    It might be ttyS1, ttyS2, etc.  Make sure you have the appropriate
-    entries in /etc/inittab (for getty) and /etc/securetty (to allow
-    root login).
-
-Early Serial Console
-==========
-
-    The kernel can't start using a serial console until it knows where
-    the device lives.  Normally this happens when the driver enumerates
-    all the serial devices, which can happen a minute or more after the
-    kernel starts booting.
-
-    2.6.10 and later kernels have an "early uart" driver that works
-    very early in the boot process.  The kernel will automatically use
-    this if the user supplies an argument like "console=uart,io,0x3f8",
-    or if the EFI console path contains only a UART device and the
-    firmware supplies an HCDP.
-
-Troubleshooting Serial Console Problems
-===================-
-    No kernel output after elilo prints "Uncompressing Linux... done":
-
-	- You specified "console=ttyS0" but Linux changed the device
-	  to which ttyS0 refers.  Configure exactly one EFI console
-	  device[3] and remove the "console=" option.
-
-	- The EFI console path contains both a VGA device and a UART.
-	  EFI and elilo use both, but Linux defaults to VGA.  Remove
-	  the VGA device from the EFI console path[3].
-
-	- Multiple UARTs selected as EFI console devices.  EFI and
-	  elilo use all selected devices, but Linux uses only one.
-	  Make sure only one UART is selected in the EFI console
-	  path[3].
-
-	- You're connected to an HP MP port[2] but have a non-MP UART
-	  selected as EFI console device.  EFI uses the MP as a
-	  console device even when it isn't explicitly selected.
-	  Either move the console cable to the non-MP UART, or change
-	  the EFI console path[3] to the MP UART.
-
-    Long pause (60+ seconds) between "Uncompressing Linux... done" and
-    start of kernel output:
-
-	- No early console because you used "console=ttyS<n>".  Remove
-	  the "console=" option if your firmware supplies an HCDP.
-
-	- If you don't have an HCDP, the kernel doesn't know where
-	  your console lives until the driver discovers serial
-	  devices.  Use "console=uart,io,0x3f8" (or appropriate
-	  address for your machine).
-
-    Kernel and init script output works fine, but no "login:" prompt:
-
-	- Add getty entry to /etc/inittab for console tty.  Look for
-	  the "Adding console on ttyS<n>" message that tells you which
-	  device is the console.
-
-    "login:" prompt, but can't login as root:
-
-	- Add entry to /etc/securetty for console tty.
-
-    No ACPI serial devices found in 2.6.17 or later:
-
-	- Turn on CONFIG_PNP and CONFIG_PNPACPI.  Prior to 2.6.17, ACPI
-	  serial devices were discovered by 8250_acpi.  In 2.6.17,
-	  8250_acpi was replaced by the combination of 8250_pnp and
-	  CONFIG_PNPACPI.
-
-
-
-[1]
-    http://www.dig64.org/specifications/agreement
-    The table was originally defined as the "HCDP" for "Headless
-    Console/Debug Port."  The current version is the "PCDP" for
-    "Primary Console and Debug Port Devices."
-
-[2]
-    The HP MP (management processor) is a PCI device that provides
-    several UARTs.  One of the UARTs is often used as a console; the
-    EFI Boot Manager identifies it as "Acpi(HWP0002,700)/Pci(...)/Uart".
-    The external connection is usually a 25-pin connector, and a
-    special dongle converts that to three 9-pin connectors, one of
-    which is labelled "Console."
-
-[3]
-    EFI console devices are configured using the EFI Boot Manager
-    "Boot option maintenance" menu.  You may have to interrupt the
-    boot sequence to use this menu, and you will have to reset the
-    box after changing console configuration.
diff --git a/MAINTAINERS b/MAINTAINERS
index a0d86490c2c6..10463c6a9de6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -15043,14 +15043,6 @@ M:	Dimitri Sivanich <sivanich@sgi.com>
 S:	Maintained
 F:	drivers/misc/sgi-gru/
 
-SGI SN-IA64 (Altix) SERIAL CONSOLE DRIVER
-M:	Pat Gefre <pfg@sgi.com>
-L:	linux-ia64@vger.kernel.org
-S:	Supported
-F:	Documentation/ia64/serial.rst
-F:	drivers/tty/serial/ioc?_serial.c
-F:	include/linux/ioc?.h
-
 SGI XP/XPC/XPNET DRIVER
 M:	Cliff Whickman <cpw@sgi.com>
 M:	Robin Holt <robinmholt@gmail.com>
diff --git a/include/linux/ioc3.h b/include/linux/ioc3.h
deleted file mode 100644
index 38b286e9a46c..000000000000
--- a/include/linux/ioc3.h
+++ /dev/null
@@ -1,93 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (c) 2005 Stanislaw Skowronek <skylark@linux-mips.org>
- */
-
-#ifndef _LINUX_IOC3_H
-#define _LINUX_IOC3_H
-
-#include <asm/sn/ioc3.h>
-
-#define IOC3_MAX_SUBMODULES	32
-
-#define IOC3_CLASS_NONE		0
-#define IOC3_CLASS_BASE_IP27	1
-#define IOC3_CLASS_BASE_IP30	2
-#define IOC3_CLASS_MENET_123	3
-#define IOC3_CLASS_MENET_4	4
-#define IOC3_CLASS_CADDUO	5
-#define IOC3_CLASS_SERIAL	6
-
-/* One of these per IOC3 */
-struct ioc3_driver_data {
-	struct list_head list;
-	int id;				/* IOC3 sequence number */
-	/* PCI mapping */
-	unsigned long pma;		/* physical address */
-	struct ioc3 __iomem *vma;	/* pointer to registers */
-	struct pci_dev *pdev;		/* PCI device */
-	/* IRQ stuff */
-	int dual_irq;			/* set if separate IRQs are used */
-	int irq_io, irq_eth;		/* IRQ numbers */
-	/* GPIO magic */
-	spinlock_t gpio_lock;
-	unsigned int gpdr_shadow;
-	/* NIC identifiers */
-	char nic_part[32];
-	char nic_serial[16];
-	char nic_mac[6];
-	/* submodule set */
-	int class;
-	void *data[IOC3_MAX_SUBMODULES];	/* for submodule use */
-	int active[IOC3_MAX_SUBMODULES];	/* set if probe succeeds */
-	/* is_ir_lock must be held while
-	 * modifying sio_ie values, so
-	 * we can be sure that sio_ie is
-	 * not changing when we read it
-	 * along with sio_ir.
-	 */
-	spinlock_t ir_lock;	/* SIO_IE[SC] mod lock */
-};
-
-/* One per submodule */
-struct ioc3_submodule {
-	char *name;		/* descriptive submodule name */
-	struct module *owner;	/* owning kernel module */
-	int ethernet;		/* set for ethernet drivers */
-	int (*probe) (struct ioc3_submodule *, struct ioc3_driver_data *);
-	int (*remove) (struct ioc3_submodule *, struct ioc3_driver_data *);
-	int id;			/* assigned by IOC3, index for the "data" array */
-	/* IRQ stuff */
-	unsigned int irq_mask;	/* IOC3 IRQ mask, leave clear for Ethernet */
-	int reset_mask;		/* non-zero if you want the ioc3.c module to reset interrupts */
-	int (*intr) (struct ioc3_submodule *, struct ioc3_driver_data *, unsigned int);
-	/* private submodule data */
-	void *data;		/* assigned by submodule */
-};
-
-/**********************************
- * Functions needed by submodules *
- **********************************/
-
-#define IOC3_W_IES		0
-#define IOC3_W_IEC		1
-
-/* registers a submodule for all existing and future IOC3 chips */
-extern int ioc3_register_submodule(struct ioc3_submodule *);
-/* unregisters a submodule */
-extern void ioc3_unregister_submodule(struct ioc3_submodule *);
-/* enables IRQs indicated by irq_mask for a specified IOC3 chip */
-extern void ioc3_enable(struct ioc3_submodule *, struct ioc3_driver_data *, unsigned int);
-/* ackowledges specified IRQs */
-extern void ioc3_ack(struct ioc3_submodule *, struct ioc3_driver_data *, unsigned int);
-/* disables IRQs indicated by irq_mask for a specified IOC3 chip */
-extern void ioc3_disable(struct ioc3_submodule *, struct ioc3_driver_data *, unsigned int);
-/* atomically sets GPCR bits */
-extern void ioc3_gpcr_set(struct ioc3_driver_data *, unsigned int);
-/* general ireg writer */
-extern void ioc3_write_ireg(struct ioc3_driver_data *idd, uint32_t value, int reg);
-
-#endif
-- 
2.17.1
