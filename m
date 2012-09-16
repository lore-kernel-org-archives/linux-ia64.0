From: Stephan Schreiber <info@fs-driver.org>
Date: Sun, 16 Sep 2012 16:39:14 +0000
Subject: [RFC/PATCH] ia64, SR870, EFI bug breaks ata_piix, uninitialized ICH4 IDE EXBAR mem resource
Message-Id: <20120916183914.Horde._TGALdjz9kRQVgCy6ATxxJA@webmail.df.eu>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: alan@lxorguk.ukuu.org.uk, linux-pci@vger.kernel.org, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, 679545@bugs.debian.org, jrnieder@gmail.com

Hello,
please could you add some comments about the problem or review the  
proposed patch?

Kernel 3.2.23 with Debian patches (Debian Wheezy, testing)
Debian bug#679545 (http://bugs.debian.org/cgi-bin/bugreport.cgi?bugg9545)

Machine: Dell PowerEdge 3250 (equivalent with Intel SR870BH2)
Processor: 2x Itanium Madison 1.5GHz 6M
Memory: 4GB

Intel ICH4 (82801DB), IDE host adapter. The ata_piix module fails to  
initialize.

A snippet from dmesg:
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.2.0-3-mckinley (Debian 3.2.23-1)  
(debian-kernel@lists.debian.org) (gcc version 4.6.3 (Debian 4.6.3-8) )  
#1 SMP Mon Jul 23 09:01:02 UTC 2012
...
[    0.065516] pci 0000:00:1f.1: [8086:24cb] type 0 class 0x000101
[    0.065530] pci 0000:00:1f.1: reg 10: [io  0x0000-0x0007]
[    0.065541] pci 0000:00:1f.1: reg 14: [io  0x0000-0x0003]
[    0.065552] pci 0000:00:1f.1: reg 18: [io  0x0000-0x0007]
[    0.065563] pci 0000:00:1f.1: reg 1c: [io  0x0000-0x0003]
[    0.065574] pci 0000:00:1f.1: reg 20: [io  0x1000-0x100f]
[    0.065585] pci 0000:00:1f.1: reg 24: [mem 0x00000000-0x000003ff]
...
[    1.640965] libata version 3.00 loaded.
[    1.641656] ata_piix 0000:00:1f.1: version 2.13
[    1.641671] ata_piix 0000:00:1f.1: device not available (can't  
reserve [mem 0x00000000-0x000003ff])
[    1.641747] ata_piix: probe of 0000:00:1f.1 failed with error -22
...

lspci -vvxxx reports:

00:1f.1 IDE interface: Intel Corporation 82801DB (ICH4) IDE Controller  
(rev 02) (prog-if 8a [Master SecP PriP])
	Subsystem: Intel Corporation Device 3404
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-  
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 0
	Region 0: I/O ports at 01f0 [size=8]
	Region 1: I/O ports at 03f4 [size=1]
	Region 2: I/O ports at 0170 [size=8]
	Region 3: I/O ports at 0374 [size=1]
	Region 4: I/O ports at 1000 [size]
00: 86 80 cb 24 05 00 80 02 02 8a 01 01 00 00 00 00
10: 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00
20: 01 10 00 00 00 00 00 00 00 00 00 00 86 80 04 34
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00
40: 03 a3 00 80 00 00 00 00 01 00 02 00 00 00 00 00
50: 00 00 00 00 00 04 00 00 00 00 00 00 00 00 00 00
60: 08 00 00 00 00 00 00 00 08 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 60 0f 00 00 00 00 00 00


You can read in the "Intel 82801DB I/O Controller Hub 4 (ICH4)" datasheet
(http://www.intel.com/content/dam/www/public/us/en/documents/datasheets/82801db-io-controller-hub-4-datasheet.pdf)
about the EXBAR register at offset 0x24 (4 bytes):
"EXBAR register
This is a memory mapped BAR that requires 1 KB of DWord-aligned memory  
that is Intel reserved
for future functionality. BIOS needs to program the base address for a  
1-KB memory space."

The dump shows that EXBAR is 0x0000, equal to the default value after  
reset; EFI doesn't initialize it.

ata_piix uses pcim_enable_device() which enables this along with the  
I/O BARs. In systems based on the Intel SR870 platform the firmware  
does not initialize the EXBAR and pcim_enable_device() fails because  
the memory region 0x0-0x3FF cannot be allocated.

The proposed patch adds ia64 arch-specific 'pci quirk' code.
Since the patched Kernel doesn't see any memory resource of IDE  
hostadapter, it doesn't set the PCI_COMMAND_MEMORY bit in the CMD  
register; the EXBAR resource is *not* visible in the memeory space at  
all.

A snippet of the dmesg output on the patched Kernel:
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.2.0-3-mckinley (Debian 3.2.23-1)  
(debian-kernel@lists.debian.org) (gcc version 4.6.3 (Debian 4.6.3-8) )  
#1 SMP Sun Sep 16 15:16:55 CEST 2012
...
[    0.065491] pci 0000:00:1f.1: [8086:24cb] type 0 class 0x000101
[    0.065505] pci 0000:00:1f.1: reg 10: [io  0x0000-0x0007]
[    0.065516] pci 0000:00:1f.1: reg 14: [io  0x0000-0x0003]
[    0.065527] pci 0000:00:1f.1: reg 18: [io  0x0000-0x0007]
[    0.065537] pci 0000:00:1f.1: reg 1c: [io  0x0000-0x0003]
[    0.065548] pci 0000:00:1f.1: reg 20: [io  0x1000-0x100f]
[    0.065559] pci 0000:00:1f.1: reg 24: [mem 0x00000000-0x000003ff]
[    0.065574] pci 0000:00:1f.1: SR870 EFI bug workaround; hide EXBAR  
memory resource.
...
[    1.391942] libata version 3.00 loaded.
[    1.392567] ata_piix 0000:00:1f.1: version 2.13
[    1.392807] ata_piix 0000:00:1f.1: can't derive routing for PCI INT A
[    1.399383] scsi0 : ata_piix
[    1.402505] scsi1 : ata_piix
[    1.402609] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x1000 irq 34
[    1.402658] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x1008 irq 33
[    1.565703] ata1.00: ATAPI: HL-DT-ST DVDRAM GSA-T40N, JR03, max UDMA/33
[    1.581571] ata1.00: configured for UDMA/33
[    1.587075] scsi 0:0:0:0: CD-ROM            HL-DT-ST DVDRAM  
GSA-T40N  JR03 PQ: 0 ANSI: 5
[    1.598796] sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw  
xa/form2 cdda tray
[    1.598863] cdrom: Uniform CD-ROM driver Revision: 3.20
[    1.599263] sr 0:0:0:0: Attached scsi CD-ROM sr0
[    1.601972] sr 0:0:0:0: Attached scsi generic sg0 type 5
...


(Note: The patch of this posting differs slightly from the one which I  
have posted on Debian bug#679545 - just cosmetic improvements.)

Kind regards,
Stephan Schreiber



--- linux-3.2.23/arch/ia64/pci/fixup.c.orig	2012-09-16  
11:23:30.000000000 +0200
+++ linux-3.2.23/arch/ia64/pci/fixup.c	2012-09-16 11:52:13.000000000 +0200
@@ -67,3 +67,40 @@ static void __devinit pci_fixup_video(st
  	}
  }
  DECLARE_PCI_FIXUP_HEADER(PCI_ANY_ID, PCI_ANY_ID, pci_fixup_video);
+
+
+/*
+ * Fixup the EFI bug of Intel's SR870 platform
+ *
+ * The EFI of Intel's SR870BH2 and SR870BN4 including their OEM  
equivalents by
+ * Fujitsu and Dell doesn't initialize the memory resource of the ICH4 IDE
+ * hostadapter. The memory resource has the default after reset: 0x0-0x3FF.
+ * The ata_piix driver uses pcim_enable_device() which attempts to  
enable this
+ * along with the I/O BARs and pcim_enable_device() fails because the memory
+ * region 0x0-0x3FF cannot be allocated.
+ * The memory resource is the 6th resource of the ICH4 IDE hostadapter;
+ * Intel's datasheet "Intel 82801DB I/O Controller Hub 4 (ICH4)" (Document
+ * Number: 290744-001) states in section "10.1.15 EXBAR - Expansion Base
+ * Address Register (IDE-D31:F1)" on page 389:
+ * "This is a memory mapped BAR ... that is Intel reserved for future
+ * functionality. BIOS needs to program the base address for a 1-KB memory
+ * space."
+ * Since nothing uses the EXBAR, we hide it so that only the I/O BARs will be
+ * enabled.
+ */
+
+static void __devinit pci_fixup_sr870_ich4(struct pci_dev *dev)
+{
+	struct resource *r;
+
+	r = &dev->resource[5];
+	if ((r->flags & IORESOURCE_MEM)
+	&& r->start = 0 && r->end != 0) {
+		dev_info(&dev->dev,
+			"SR870 EFI bug workaround; hide EXBAR memory resource.\n");
+		r->flags = 0;
+		r->end = 0;
+	}
+}
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82801DB_11,
+						pci_fixup_sr870_ich4);

Signed-off-by: Stephan Schreiber <info@fs-driver.org>


