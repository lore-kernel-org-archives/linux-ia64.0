From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 13 Dec 2003 09:18:58 +0000
Subject: making allyesconfig compile
Message-Id: <marc-linux-ia64-107130727823563@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since I had a need to compile as many kernel files as possible, I
hacked the Kconfig files a bit to get things to the point where the
kernel gets linked.  The actual link blows up because the kernel is
too big and exhausts the global-offset-table, but still, I thought I'd
post the patch in case anyone cares for it.  I don't know most of the
drivers in question and just putting an !IA64 or !ISA dependency may
not be the right thing, but at least it does show what's causing
compile-time failures.

Enjoy,

	--david

=== drivers/block/Kconfig 1.15 vs edited ==--- 1.15/drivers/block/Kconfig	Thu Oct  9 07:53:10 2003
+++ edited/drivers/block/Kconfig	Fri Dec 12 22:25:11 2003
@@ -6,7 +6,7 @@
 
 config BLK_DEV_FD
 	tristate "Normal floppy disk support"
-	depends on !X86_PC9800 && !ARCH_S390
+	depends on !X86_PC9800 && !ARCH_S390 && !IA64
 	---help---
 	  If you want to use the floppy disk drive(s) of your PC under Linux,
 	  say Y. Information about this driver, especially important for IBM
=== drivers/char/Kconfig 1.25 vs edited ==--- 1.25/drivers/char/Kconfig	Tue Oct 21 22:10:32 2003
+++ edited/drivers/char/Kconfig	Fri Dec 12 22:27:49 2003
@@ -214,7 +214,7 @@
 
 config SYNCLINK
 	tristate "Microgate SyncLink card support"
-	depends on SERIAL_NONSTANDARD
+	depends on SERIAL_NONSTANDARD && ISA
 	help
 	  Provides support for the SyncLink ISA and PCI multiprotocol serial
 	  adapters. These adapters support asynchronous and HDLC bit
@@ -616,6 +616,7 @@
 
 config QIC02_TAPE
 	tristate "QIC-02 tape support"
+	depends on ISA
 	help
 	  If you have a non-SCSI tape drive like that, say Y.
 
@@ -716,7 +717,7 @@
 
 config HW_RANDOM
 	tristate "Intel/AMD/VIA HW Random Number Generator support"
-	depends on (X86 || IA64) && PCI
+	depends on X86 && PCI
 	---help---
 	  This driver provides kernel-side support for the Random Number
 	  Generator hardware found on Intel i8xx-based motherboards,
@@ -731,6 +732,7 @@
 
 config NVRAM
 	tristate "/dev/nvram support"
+	depends on !IA64
 	---help---
 	  If you say Y here and create a character special file /dev/nvram
 	  with major number 10 and minor number 144 using mknod ("man mknod"),
@@ -782,7 +784,7 @@
 
 config GEN_RTC
 	tristate "Generic /dev/rtc emulation"
-	depends on RTC!=y
+	depends on RTC!=y && !IA64
 	---help---
 	  If you say Y here and create a character special file /dev/rtc with
 	  major number 10 and minor number 135 using mknod ("man mknod"), you
@@ -883,7 +885,7 @@
 
 config FTAPE
 	tristate "Ftape (QIC-80/Travan) support"
-	depends on BROKEN_ON_SMP
+	depends on BROKEN_ON_SMP && ISA
 	---help---
 	  If you have a tape drive that is connected to your floppy
 	  controller, say Y here.
=== drivers/message/i2o/Kconfig 1.5 vs edited ==--- 1.5/drivers/message/i2o/Kconfig	Thu Sep 11 20:19:35 2003
+++ edited/drivers/message/i2o/Kconfig	Fri Dec 12 22:37:06 2003
@@ -46,7 +46,7 @@
 
 config I2O_SCSI
 	tristate "I2O SCSI OSM"
-	depends on I2O && SCSI
+	depends on I2O && SCSI && !64BIT
 	help
 	  Allows direct SCSI access to SCSI devices on a SCSI or FibreChannel
 	  I2O controller. You can use both the SCSI and Block OSM together if
=== drivers/mtd/Kconfig 1.2 vs edited ==--- 1.2/drivers/mtd/Kconfig	Wed May 28 08:01:01 2003
+++ edited/drivers/mtd/Kconfig	Fri Dec 12 22:38:26 2003
@@ -70,7 +70,7 @@
 
 config MTD_CMDLINE_PARTS
 	tristate "Command line partition table parsing"
-	depends on MTD_PARTITIONS
+	depends on MTD_PARTITIONS && !IA64
 	---help---
 	  Allow generic configuration of the MTD paritition tables via the kernel
 	  command line. Multiple flash resources are supported for hardware where
=== drivers/net/irda/Kconfig 1.12 vs edited ==--- 1.12/drivers/net/irda/Kconfig	Wed Sep 24 20:39:20 2003
+++ edited/drivers/net/irda/Kconfig	Fri Dec 12 22:42:17 2003
@@ -284,7 +284,7 @@
 
 config VLSI_FIR
 	tristate "VLSI 82C147 SIR/MIR/FIR (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && IRDA && PCI
+	depends on EXPERIMENTAL && IRDA && PCI && !IA64
 	help
 	  Say Y here if you want to build support for the VLSI 82C147
 	  PCI-IrDA Controller. This controller is used by the HP OmniBook 800
=== drivers/net/tokenring/Kconfig 1.11 vs edited ==--- 1.11/drivers/net/tokenring/Kconfig	Thu Sep 25 17:20:37 2003
+++ edited/drivers/net/tokenring/Kconfig	Fri Dec 12 22:43:38 2003
@@ -84,7 +84,7 @@
 
 config TMS380TR
 	tristate "Generic TMS380 Token Ring ISA/PCI adapter support"
-	depends on TR && (PCI || ISA)
+	depends on TR && (PCI || ISA) && !IA64
 	---help---
 	  This driver provides generic support for token ring adapters
 	  based on the Texas Instruments TMS380 series chipsets.  This
=== drivers/parport/Kconfig 1.6 vs edited ==--- 1.6/drivers/parport/Kconfig	Thu Sep 11 20:19:35 2003
+++ edited/drivers/parport/Kconfig	Fri Dec 12 22:53:25 2003
@@ -9,6 +9,7 @@
 
 config PARPORT
 	tristate "Parallel port support"
+	depends on !IA64
 	---help---
 	  If you want to use devices connected to your machine's parallel port
 	  (the connector at the computer with 25 holes), e.g. printer, ZIP
=== drivers/pnp/Kconfig 1.6 vs edited ==--- 1.6/drivers/pnp/Kconfig	Tue Aug  5 14:21:26 2003
+++ edited/drivers/pnp/Kconfig	Fri Dec 12 22:56:58 2003
@@ -6,6 +6,7 @@
 
 config PNP
 	bool "Plug and Play support"
+	depends on !IA64
 	---help---
 	  Plug and Play (PnP) is a standard for peripherals which allows those
 	  peripherals to be configured by software, e.g. assign IRQ's or other
=== drivers/scsi/Kconfig 1.43 vs edited ==--- 1.43/drivers/scsi/Kconfig	Thu Oct 30 14:11:07 2003
+++ edited/drivers/scsi/Kconfig	Fri Dec 12 23:05:38 2003
@@ -457,7 +457,7 @@
 
 config SCSI_BUSLOGIC
 	tristate "BusLogic SCSI support"
-	depends on (PCI || ISA || MCA) && SCSI
+	depends on (PCI || ISA || MCA) && SCSI && !IA64
 	---help---
 	  This is support for BusLogic MultiMaster and FlashPoint SCSI Host
 	  Adapters. Consult the SCSI-HOWTO, available from
@@ -509,7 +509,7 @@
 
 config SCSI_EATA
 	tristate "EATA ISA/EISA/PCI (DPT and generic EATA/DMA-compliant boards) support"
-	depends on (ISA || EISA || PCI) && SCSI
+	depends on (ISA || EISA || PCI) && SCSI && !IA64
 	---help---
 	  This driver supports all EATA/DMA-compliant SCSI host adapters.  DPT
 	  ISA and all EISA I/O addresses are probed looking for the "EATA"
@@ -571,7 +571,7 @@
 
 config SCSI_FUTURE_DOMAIN
 	tristate "Future Domain 16xx SCSI/AHA-2920A support"
-	depends on (ISA || PCI) && SCSI
+	depends on (ISA || PCI) && SCSI && !IA64
 	---help---
 	  This is support for Future Domain's 16-bit SCSI host adapters
 	  (TMC-1660/1680, TMC-1650/1670, TMC-3260, TMC-1610M/MER/MEX) and
=== drivers/scsi/aic7xxx/Kconfig.aic79xx 1.8 vs edited ==--- 1.8/drivers/scsi/aic7xxx/Kconfig.aic79xx	Mon Mar 10 16:57:17 2003
+++ edited/drivers/scsi/aic7xxx/Kconfig.aic79xx	Fri Dec 12 23:03:54 2003
@@ -4,7 +4,7 @@
 #
 config SCSI_AIC79XX
 	tristate "Adaptec AIC79xx U320 support"
-	depends on PCI
+	depends on PCI && !IA64
 	help
 	This driver supports all of Adaptec's Ultra 320 PCI-X
 	based SCSI controllers.
=== drivers/scsi/aic7xxx/Kconfig.aic7xxx 1.11 vs edited ==--- 1.11/drivers/scsi/aic7xxx/Kconfig.aic7xxx	Thu Sep 11 20:19:35 2003
+++ edited/drivers/scsi/aic7xxx/Kconfig.aic7xxx	Fri Dec 12 23:00:54 2003
@@ -4,6 +4,7 @@
 #
 config SCSI_AIC7XXX
 	tristate "Adaptec AIC7xxx Fast -> U160 support (New Driver)"
+	depends on !IA64
 	---help---
 	This driver supports all of Adaptec's Fast through Ultra 160 PCI
 	based SCSI controllers as well as the aic7770 based EISA and VLB
=== sound/oss/Kconfig 1.16 vs edited ==--- 1.16/sound/oss/Kconfig	Thu Oct 16 13:57:19 2003
+++ edited/sound/oss/Kconfig	Fri Dec 12 23:00:11 2003
@@ -132,7 +132,7 @@
 
 config SOUND_EMU10K1
 	tristate "Creative SBLive! (EMU10K1)"
-	depends on SOUND_PRIME!=n && SOUND && PCI
+	depends on SOUND_PRIME!=n && SOUND && PCI && !IA64
 	---help---
 	  Say Y or M if you have a PCI sound card using the EMU10K1 chipset,
 	  such as the Creative SBLive!, SB PCI512 or Emu-APS.
@@ -535,7 +535,7 @@
 
 config SOUND_VIA82CXXX
 	tristate "VIA 82C686 Audio Codec"
-	depends on SOUND_PRIME!=n && PCI
+	depends on SOUND_PRIME!=n && PCI && !IA64
 	help
 	  Say Y here to include support for the audio codec found on VIA
 	  82Cxxx-based chips. Typically these are built into a motherboard.
@@ -555,7 +555,7 @@
 
 config SOUND_OSS
 	tristate "OSS sound modules"
-	depends on SOUND_PRIME!=n && SOUND
+	depends on SOUND_PRIME!=n && SOUND && !IA64
 	help
 	  OSS is the Open Sound System suite of sound card drivers.  They make
 	  sound programming easier since they provide a common API.  Say Y or
@@ -668,7 +668,7 @@
 
 config SOUND_GUS
 	tristate "Gravis Ultrasound support"
-	depends on SOUND_OSS
+	depends on SOUND_OSS && ISA
 	help
 	  Say Y here for any type of Gravis Ultrasound card, including the GUS
 	  or GUS MAX.  See also <file:Documentation/sound/oss/ultrasound> for more
=== sound/oss/dmasound/Kconfig 1.4 vs edited ==--- 1.4/sound/oss/dmasound/Kconfig	Sun Sep 28 03:05:48 2003
+++ edited/sound/oss/dmasound/Kconfig	Fri Dec 12 22:51:10 2003
@@ -56,3 +56,4 @@
 
 config DMASOUND
 	tristate
+	depends on !IA64
