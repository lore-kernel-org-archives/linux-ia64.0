From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 23 Jan 2004 00:36:47 +0000
Subject: Kconfig cleanups
Message-Id: <200401221736.47850.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040114065742.GG10711@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040114065742.GG10711@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel-janitors@vger.kernel.org

I've been playing with "make allmodconfig" on ia64 and found lots of
nits.  Many of them are addressed by your kconfig cleanups patch I
found on the kernel janitors list.

Here are a few more.  If you want to incorporate them with yours,
that's fine, or I'm open to other suggestions.

HW_RANDOM - looks like the hardware is on Tiger, so maybe should be
    made to work eventually; currently it requires x86 asm()
NVRAM - arch depends below reflect #error analysis in driver
GEN_RTC - requires "asm/rtc.h", which we don't have
I2O_SCSI - depends !64BIT reflects #error in driver
VLSI_FIR - depends X86 reflects #error in vlsi_ir.h
SCSI_BUSLOGIC - I don't see any mention of MCA in the driver, but I
    could be missing it

PARPORT_PC - shouldn't we have a !IA64 as well?

SYNCLINK, TMS380TR, SCSI_BUSLOGIC, SCSI_EATA, SCSI_FUTURE_DOMAIN -
    these all require both ISA && PCI.  Or at least, they use bits of
    the ISA inteface (isa_virt_to_bus, request_dma, etc), that are not
    available on ia64, and they don't use CONFIG_ISA to conditionally
    compile those references.

=== drivers/char/Kconfig 1.26 vs edited ==--- 1.26/drivers/char/Kconfig	Thu Jan 15 03:34:16 2004
+++ edited/drivers/char/Kconfig	Thu Jan 22 13:26:06 2004
@@ -214,7 +214,7 @@
 
 config SYNCLINK
 	tristate "Microgate SyncLink card support"
-	depends on SERIAL_NONSTANDARD
+	depends on SERIAL_NONSTANDARD && ISA && PCI
 	help
 	  Provides support for the SyncLink ISA and PCI multiprotocol serial
 	  adapters. These adapters support asynchronous and HDLC bit
@@ -714,7 +715,7 @@
 
 config HW_RANDOM
 	tristate "Intel/AMD/VIA HW Random Number Generator support"
-	depends on (X86 || IA64) && PCI
+	depends on X86 && PCI
 	---help---
 	  This driver provides kernel-side support for the Random Number
 	  Generator hardware found on Intel i8xx-based motherboards,
@@ -729,6 +730,7 @@
 
 config NVRAM
 	tristate "/dev/nvram support"
+	depends on ATARI || X86 || X86_64 || ARM
 	---help---
 	  If you say Y here and create a character special file /dev/nvram
 	  with major number 10 and minor number 144 using mknod ("man mknod"),
@@ -780,7 +782,7 @@
 
 config GEN_RTC
 	tristate "Generic /dev/rtc emulation"
-	depends on RTC!=y
+	depends on RTC!=y && !IA64
 	---help---
 	  If you say Y here and create a character special file /dev/rtc with
 	  major number 10 and minor number 135 using mknod ("man mknod"), you
=== drivers/message/i2o/Kconfig 1.5 vs edited ==--- 1.5/drivers/message/i2o/Kconfig	Thu Sep 11 21:19:35 2003
+++ edited/drivers/message/i2o/Kconfig	Wed Jan 21 17:25:17 2004
@@ -46,7 +46,7 @@
 
 config I2O_SCSI
 	tristate "I2O SCSI OSM"
-	depends on I2O && SCSI
+	depends on I2O && SCSI && !64BIT
 	help
 	  Allows direct SCSI access to SCSI devices on a SCSI or FibreChannel
 	  I2O controller. You can use both the SCSI and Block OSM together if
=== drivers/net/irda/Kconfig 1.12 vs edited ==--- 1.12/drivers/net/irda/Kconfig	Wed Sep 24 21:39:20 2003
+++ edited/drivers/net/irda/Kconfig	Thu Jan 22 12:38:26 2004
@@ -284,7 +284,7 @@
 
 config VLSI_FIR
 	tristate "VLSI 82C147 SIR/MIR/FIR (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && IRDA && PCI
+	depends on EXPERIMENTAL && IRDA && PCI && X86
 	help
 	  Say Y here if you want to build support for the VLSI 82C147
 	  PCI-IrDA Controller. This controller is used by the HP OmniBook 800
=== drivers/net/tokenring/Kconfig 1.12 vs edited ==--- 1.12/drivers/net/tokenring/Kconfig	Sat Dec 20 19:37:05 2003
+++ edited/drivers/net/tokenring/Kconfig	Thu Jan 22 13:27:21 2004
@@ -84,7 +84,7 @@
 
 config TMS380TR
 	tristate "Generic TMS380 Token Ring ISA/PCI adapter support"
-	depends on TR && (PCI || ISA)
+	depends on TR && PCI && ISA
 	---help---
 	  This driver provides generic support for token ring adapters
 	  based on the Texas Instruments TMS380 series chipsets.  This
=== drivers/scsi/Kconfig 1.48 vs edited ==--- 1.48/drivers/scsi/Kconfig	Thu Jan 15 03:18:55 2004
+++ edited/drivers/scsi/Kconfig	Thu Jan 22 14:57:37 2004
@@ -457,15 +457,13 @@
 
 config SCSI_BUSLOGIC
 	tristate "BusLogic SCSI support"
-	depends on (PCI || ISA || MCA) && SCSI
+	depends on PCI && ISA && SCSI
 	---help---
 	  This is support for BusLogic MultiMaster and FlashPoint SCSI Host
 	  Adapters. Consult the SCSI-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>, and the files
 	  <file:Documentation/scsi/BusLogic.txt> and
-	  <file:Documentation/scsi/FlashPoint.txt> for more information. If this
-	  driver does not work correctly without modification, please contact
-	  the author, Leonard N. Zubkoff, by email to lnz@dandelion.com.
+	  <file:Documentation/scsi/FlashPoint.txt> for more information.
 
 	  To compile this driver as a module, choose M here: the
 	  module will be called BusLogic.
@@ -509,7 +507,7 @@
 
 config SCSI_EATA
 	tristate "EATA ISA/EISA/PCI (DPT and generic EATA/DMA-compliant boards) support"
-	depends on (ISA || EISA || PCI) && SCSI
+	depends on ISA && (EISA || PCI) && SCSI
 	---help---
 	  This driver supports all EATA/DMA-compliant SCSI host adapters.  DPT
 	  ISA and all EISA I/O addresses are probed looking for the "EATA"
@@ -571,7 +569,7 @@
 
 config SCSI_FUTURE_DOMAIN
 	tristate "Future Domain 16xx SCSI/AHA-2920A support"
-	depends on (ISA || PCI) && SCSI
+	depends on ISA && PCI && SCSI
 	---help---
 	  This is support for Future Domain's 16-bit SCSI host adapters
 	  (TMC-1660/1680, TMC-1650/1670, TMC-3260, TMC-1610M/MER/MEX) and

