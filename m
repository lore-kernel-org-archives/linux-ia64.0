From: "Pimenov, Sergei" <sergei.pimenov@intel.com>
Date: Thu, 02 Nov 2000 10:39:39 +0000
Subject: RE: [Linux-ia64] kernel update (relative to 2.4.0-test10)
Message-Id: <marc-linux-ia64-105590678205645@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The URL is broken, correct one is

ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/linux-2.4.0-test10-ia64-001101.diff.gz

p.s.



-----Original Message-----
From: David Mosberger [mailto:davidm@hpl.hp.com]
Sent: Thursday, November 02, 2000 11:51 AM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] kernel update (relative to 2.4.0-test10)


The patch at:

 ftp://ftp.kernel.org/pub/linux/kernel/port/pub/linux/kernel/ports/ia64/linux-2.4.0-test10-ia64-001101.diff.gz

contains the latest IA-64 kernel diff relative to Linus' 2.4.0-test10.  There are
only few new things:

 - bring IA-64 support in sync with 2.4.0-test10
 - added EFI partition support by Matt (my apologies to Matt for
   missing his patch the last time round...)
 - small fix to the PCI DMA support by Asit
 - drop evil CONFIG_SKB_BELOW_4GB
 - make simserial.c and simeth.c use ia64_alloc_irq() to obtain an
   available interrupt vector

That should be it.  This kernel is known to build and work on Big Sur,
Lion, and the HP Ski simulator.

Enjoy,

	--david


diff -urN linux-davidm/Documentation/Configure.help linux-2.4.0-test10-lia/Documentation/Configure.help
--- linux-davidm/Documentation/Configure.help	Thu Nov  2 00:16:39 2000
+++ linux-2.4.0-test10-lia/Documentation/Configure.help	Wed Nov  1 23:05:34 2000
@@ -11365,6 +11365,12 @@
   Say Y here if you would like to be able to read the hard disk
   partition table format used by SGI machines.
 
+Intel EFI GUID partition support
+CONFIG_EFI_PARTITION
+  Say Y here if you would like to use hard disks under Linux which
+  were partitioned using EFI GPT.  Presently only useful on the
+  IA-64 platform.
+
 ADFS file system support (EXPERIMENTAL)
 CONFIG_ADFS_FS
   The Acorn Disc Filing System is the standard file system of the
diff -urN linux-davidm/Makefile linux-2.4.0-test10-lia/Makefile
--- linux-davidm/Makefile	Thu Nov  2 00:16:39 2000
+++ linux-2.4.0-test10-lia/Makefile	Thu Nov  2 00:23:09 2000
@@ -206,7 +206,7 @@
 		$(LIBS) \
 		--end-group \
 		-o vmlinux
-	$(NM) vmlinux | grep -v '\(compiled\)\|\(\.o$$\)\|\( [aU] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | sort > System.map
+	$(NM) vmlinux | grep -v '\(compiled\)\|\(\.o$$\)\|\( [aUw] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | sort > System.map
 
 symlinks:
 	rm -f include/asm
diff -urN linux-davidm/arch/ia64/config.in linux-2.4.0-test10-lia/arch/ia64/config.in
--- linux-davidm/arch/ia64/config.in	Thu Nov  2 00:16:39 2000
+++ linux-2.4.0-test10-lia/arch/ia64/config.in	Thu Nov  2 00:24:09 2000
@@ -45,14 +45,14 @@
 	bool '  Enable Itanium B-step specific code' CONFIG_ITANIUM_BSTEP_SPECIFIC
 	if [ "$CONFIG_ITANIUM_BSTEP_SPECIFIC" = "y" ]; then
 	  bool '   Enable Itanium B0-step specific code' CONFIG_ITANIUM_B0_SPECIFIC
+	  bool '   Enable Itanium B1-step specific code' CONFIG_ITANIUM_B1_SPECIFIC
+	  bool '   Enable Itanium B2-step specific code' CONFIG_ITANIUM_B2_SPECIFIC
 	fi
 	bool '  Force interrupt redirection' CONFIG_IA64_HAVE_IRQREDIR
 	bool '  Enable use of global TLB purge instruction (ptc.g)' CONFIG_ITANIUM_PTCG
 	bool '  Enable SoftSDV hacks' CONFIG_IA64_SOFTSDV_HACKS
 	bool '  Enable AzusA hacks' CONFIG_IA64_AZUSA_HACKS
 	bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
-	bool '  Force socket buffers below 4GB?' CONFIG_SKB_BELOW_4GB
-
 	bool '  ACPI kernel configuration manager (EXPERIMENTAL)' CONFIG_ACPI_KERNEL_CONFIG
 	if [ "$CONFIG_ACPI_KERNEL_CONFIG" = "y" ]; then
 	  define_bool CONFIG_PM y
diff -urN linux-davidm/arch/ia64/dig/dig_irq.c linux-2.4.0-test10-lia/arch/ia64/dig/dig_irq.c
--- linux-davidm/arch/ia64/dig/dig_irq.c	Thu Nov  2 00:16:39 2000
+++ linux-2.4.0-test10-lia/arch/ia64/dig/dig_irq.c	Wed Dec 31 16:00:00 1969
@@ -1,10 +0,0 @@
-void
-dig_irq_init (void)
-{
-	/*
-	 * Disable the compatibility mode interrupts (8259 style), needs IN/OUT support
-	 * enabled.
-	 */
-	outb(0xff, 0xA1);
-	outb(0xff, 0x21);
-}
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.4.0-test10-lia/arch/ia64/kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Thu Nov  2 00:16:39 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/entry.S	Wed Nov  1 23:12:22 2000
@@ -503,7 +503,7 @@
 	;;
 	ld4 r2=[r2]
 	;;
-	shl r2=r2,SMP_LOG_CACHE_BYTES	// can't use shladd here...
+	shl r2=r2,SMP_CACHE_SHIFT	// can't use shladd here...
 	;;
 	add r3=r2,r3
 #else
diff -urN linux-davidm/arch/ia64/kernel/pci-dma.c linux-2.4.0-test10-lia/arch/ia64/kernel/pci-dma.c
--- linux-davidm/arch/ia64/kernel/pci-dma.c	Thu Nov  2 00:16:39 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/pci-dma.c	Wed Nov  1 23:13:06 2000
@@ -125,12 +125,16 @@
 		BUG();
 
 	/*
-	 * Find suitable number of IO TLB entries size that will fit this request and allocate a buffer
-	 * from that IO TLB pool.
+	 * Find suitable number of IO TLB entries size that will fit this request and
+	 * allocate a buffer from that IO TLB pool.
 	 */
 	spin_lock_irqsave(&io_tlb_lock, flags);
 	{
 		wrap = index = ALIGN(io_tlb_index, stride);
+
+		if (index >= io_tlb_nslabs) 
+			index = 0;
+
 		do {
 			/*
 			 * If we find a slot that indicates we have 'nslots' number of 
diff -urN linux-davidm/arch/ia64/kernel/pci.c linux-2.4.0-test10-lia/arch/ia64/kernel/pci.c
--- linux-davidm/arch/ia64/kernel/pci.c	Thu Nov  2 00:16:39 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/pci.c	Wed Nov  1 23:55:29 2000
@@ -123,10 +123,9 @@
  * Initialization. Uses the SAL interface
  */
 void __init 
-pcibios_init(void)
+pcibios_init (void)
 {
 #	define PCI_BUSES_TO_SCAN 255
-	struct pci_ops *ops = NULL;
 	int i;
 
 	printk("PCI: Probing PCI hardware\n");
@@ -141,14 +140,14 @@
  *  are examined.
  */
 void __init
-pcibios_fixup_bus(struct pci_bus *b)
+pcibios_fixup_bus (struct pci_bus *b)
 {
 	return;
 }
 
 void __init
-pcibios_update_resource(struct pci_dev *dev, struct resource *root,
-			struct resource *res, int resource)
+pcibios_update_resource (struct pci_dev *dev, struct resource *root,
+			 struct resource *res, int resource)
 {
         unsigned long where, size;
         u32 reg;
@@ -163,7 +162,7 @@
 }
 
 void __init
-pcibios_update_irq(struct pci_dev *dev, int irq)
+pcibios_update_irq (struct pci_dev *dev, int irq)
 {
 	pci_write_config_byte(dev, PCI_INTERRUPT_LINE, irq);
 
@@ -190,9 +189,9 @@
  * PCI BIOS setup, always defaults to SAL interface
  */
 char * __init 
-pcibios_setup(char *str)
+pcibios_setup (char *str)
 {
-	pci_probe =  PCI_NO_CHECKS;
+	pci_probe = PCI_NO_CHECKS;
 	return NULL;
 }
 
diff -urN linux-davidm/arch/ia64/kernel/ptrace.c linux-2.4.0-test10-lia/arch/ia64/kernel/ptrace.c
--- linux-davidm/arch/ia64/kernel/ptrace.c	Thu Nov  2 00:16:39 2000
+++ linux-2.4.0-test10-lia/arch/ia64/kernel/ptrace.c	Wed Nov  1 23:13:25 2000
@@ -617,7 +617,6 @@
 	struct switch_stack *sw;
 	struct unw_frame_info info;
 	struct pt_regs *pt;
-	unsigned long pmd_tmp;
 
 	pt = ia64_task_regs(child);
 	sw = (struct switch_stack *) (child->thread.ksp + 16);
diff -urN linux-davidm/arch/ia64/lib/memcpy.S linux-2.4.0-test10-lia/arch/ia64/lib/memcpy.S
--- linux-davidm/arch/ia64/lib/memcpy.S	Thu Nov  2 00:16:39 2000
+++ linux-2.4.0-test10-lia/arch/ia64/lib/memcpy.S	Wed Nov  1 23:14:24 2000
@@ -29,7 +29,14 @@
 	mov in0=in1
 	;;
 	mov in1=r8
-	;;
+	// gas doesn't handle control flow across procedures, so it doesn't
+	// realize that a stop bit is needed before the "alloc" instruction
+	// below
+{
+	nop.m 0
+	nop.f 0
+	nop.i 0
+}	;;
 END(bcopy)
 	// FALL THROUGH
 GLOBAL_ENTRY(memcpy)
diff -urN linux-davidm/drivers/char/simserial.c linux-2.4.0-test10-lia/drivers/char/simserial.c
--- linux-davidm/drivers/char/simserial.c	Thu Nov  2 00:16:40 2000
+++ linux-2.4.0-test10-lia/drivers/char/simserial.c	Wed Nov  1 23:18:55 2000
@@ -36,7 +36,6 @@
 #undef SIMSERIAL_DEBUG	/* define this to get some debug information */
 
 #define KEYBOARD_INTR	3	/* must match with simulator! */
-#define SIMSERIAL_IRQ	0xee
 
 #define NR_PORTS	1	/* only one port for now */
 #define SERIAL_INLINE	1
@@ -78,7 +77,7 @@
  */
 static struct serial_state rs_table[NR_PORTS]={
   /* UART CLK   PORT IRQ     FLAGS        */
-  { 0, BASE_BAUD, 0x3F8, SIMSERIAL_IRQ, STD_COM_FLAGS,0,PORT_16550 }  /* ttyS0 */ 
+  { 0, BASE_BAUD, 0x3F8, 0, STD_COM_FLAGS,0,PORT_16550 }  /* ttyS0 */ 
 };
 
 /*
@@ -1013,10 +1012,7 @@
 	struct serial_state	*state;
 
 	show_serial_version();
-
-	/* connect the platform's keyboard interrupt to SIMSERIAL_IRQ */
-	ia64_ssc_connect_irq(KEYBOARD_INTR, SIMSERIAL_IRQ);
-
+	
 	/* Initialize the tty_driver structure */
 	
 	memset(&serial_driver, 0, sizeof(struct tty_driver));
@@ -1063,6 +1059,11 @@
 	for (i = 0, state = rs_table; i < NR_PORTS; i++,state++) {
 
 		if (state->type = PORT_UNKNOWN) continue;
+
+		if (!state->irq) {
+			state->irq = ia64_alloc_irq();
+			ia64_ssc_connect_irq(KEYBOARD_INTR, state->irq);
+		}
 
 		printk(KERN_INFO "ttyS%02d at 0x%04lx (irq = %d) is a %s\n",
 		       state->line,
diff -urN linux-davidm/drivers/net/simeth.c linux-2.4.0-test10-lia/drivers/net/simeth.c
--- linux-davidm/drivers/net/simeth.c	Thu Nov  2 00:16:40 2000
+++ linux-2.4.0-test10-lia/drivers/net/simeth.c	Wed Nov  1 23:19:29 2000
@@ -27,7 +27,6 @@
 #include <asm/irq.h>
 
 
-#define SIMETH_IRQ	0xed
 #define SIMETH_RECV_MAX	10
 
 /*
@@ -213,11 +212,8 @@
 		return -ENOMEM;
 
 	memcpy(dev->dev_addr, mac_addr, sizeof(mac_addr));
-	/*
-	 * XXX Fix me
-	 * does not support more than one card !
-	 */
-	dev->irq = SIMETH_IRQ;
+
+	dev->irq = ia64_alloc_irq();
 
 	/*
 	 * attach the interrupt in the simulator, this does enable interrupts
diff -urN linux-davidm/fs/partitions/Config.in linux-2.4.0-test10-lia/fs/partitions/Config.in
--- linux-davidm/fs/partitions/Config.in	Sun Jul  9 22:21:41 2000
+++ linux-2.4.0-test10-lia/fs/partitions/Config.in	Wed Nov  1 23:20:37 2000
@@ -23,6 +23,7 @@
       bool '    BSD disklabel (FreeBSD partition tables) support' CONFIG_BSD_DISKLABEL
       bool '    Solaris (x86) partition table support' CONFIG_SOLARIS_X86_PARTITION
       bool '    Unixware slices support' CONFIG_UNIXWARE_DISKLABEL
+      bool '    EFI GUID Partition support' CONFIG_EFI_PARTITION
    fi
    bool '  SGI partition support' CONFIG_SGI_PARTITION
    bool '  Ultrix partition table support' CONFIG_ULTRIX_PARTITION
diff -urN linux-davidm/fs/partitions/Makefile linux-2.4.0-test10-lia/fs/partitions/Makefile
--- linux-davidm/fs/partitions/Makefile	Tue Jul 18 22:49:47 2000
+++ linux-2.4.0-test10-lia/fs/partitions/Makefile	Wed Nov  1 23:20:52 2000
@@ -20,6 +20,7 @@
 obj-$(CONFIG_SUN_PARTITION) += sun.o
 obj-$(CONFIG_ULTRIX_PARTITION) += ultrix.o
 obj-$(CONFIG_IBM_PARTITION) += ibm.o
+obj-$(CONFIG_EFI_PARTITION) += efi.o
 
 O_OBJS += $(obj-y)
 M_OBJS += $(obj-m)
diff -urN linux-davidm/fs/partitions/check.c linux-2.4.0-test10-lia/fs/partitions/check.c
--- linux-davidm/fs/partitions/check.c	Mon Oct 16 12:58:51 2000
+++ linux-2.4.0-test10-lia/fs/partitions/check.c	Wed Nov  1 23:21:07 2000
@@ -32,6 +32,7 @@
 #include "sun.h"
 #include "ibm.h"
 #include "ultrix.h"
+#include "efi.h"
 
 extern void device_init(void);
 extern int *blk_size[];
@@ -71,6 +72,9 @@
 #endif
 #ifdef CONFIG_IBM_PARTITION
 	ibm_partition,
+#endif
+#ifdef CONFIG_EFI_PARTITION
+	efi_partition,
 #endif
 	NULL
 };
diff -urN linux-davidm/fs/partitions/efi.c linux-2.4.0-test10-lia/fs/partitions/efi.c
--- linux-davidm/fs/partitions/efi.c	Wed Dec 31 16:00:00 1969
+++ linux-2.4.0-test10-lia/fs/partitions/efi.c	Wed Nov  1 23:21:21 2000
@@ -0,0 +1,646 @@
+/************************************************************
+ * EFI GUID Partition Table handling
+ * Per Intel EFI Specification v0.99
+ * http://developer.intel.com/technology/efi/efi.htm
+ * efi.[ch] by Matt Domsch <Matt_Domsch@dell.com> 
+ *   Copyright 2000 Dell Computer Corporation
+ * CRC routines taken from the EFI Sample Implementation,
+ *   1999.12.31, lib/crc.c
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ * 
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ * 
+ * TODO:
+ *
+ * Changelog:
+ * Wed Oct 25 2000 Matt Domsch <Matt_Domsch@dell.com>
+ * - Fixed the LastLBA() call to return the proper last block
+ * 
+ * Thu Oct 12 2000 Matt Domsch <Matt_Domsch@dell.com>
+ * - Thanks to Andries Brouwer for his debugging assistance.
+ * - Code works, detects all the partitions.
+ *
+ ************************************************************/
+#include <linux/config.h>
+#include <linux/fs.h>
+#include <linux/genhd.h>
+#include <linux/kernel.h>
+#include <linux/major.h>
+#include <linux/string.h>
+#include <linux/blk.h>
+#include <linux/malloc.h>
+#include <linux/smp_lock.h>
+#include <asm/system.h>
+#include <asm/efi.h>
+
+#include "check.h"
+#include "efi.h"
+
+#if CONFIG_BLK_DEV_MD && CONFIG_AUTODETECT_RAID
+extern void md_autodetect_dev(kdev_t dev);
+#endif
+
+
+#undef EFI_DEBUG
+#ifdef EFI_DEBUG
+static char *efi_printk_level = KERN_DEBUG;
+#define debug_printk printk
+#else
+#define debug_printk(...)
+#endif
+
+/* CRC routines taken from the EFI Sample Implementation,
+ *   1999.12.31, lib/crc.c
+ *
+ * Note, the EFI Specification, v0.99, has a reference to
+ * Dr. Dobbs Journal, May 1994 (actually it's in May 1992)
+ * but that isn't the CRC function being used by EFI.
+ */
+
+static u32 CRCTable[256] = {
+	0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F,
+	0xE963A535, 0x9E6495A3, 0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988,
+	0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91, 0x1DB71064, 0x6AB020F2,
+	0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7,
+	0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9,
+	0xFA0F3D63, 0x8D080DF5, 0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172,
+	0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B, 0x35B5A8FA, 0x42B2986C,
+	0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59,
+	0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423,
+	0xCFBA9599, 0xB8BDA50F, 0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924,
+	0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D, 0x76DC4190, 0x01DB7106,
+	0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433,
+	0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D,
+	0x91646C97, 0xE6635C01, 0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E,
+	0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457, 0x65B0D9C6, 0x12B7E950,
+	0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65,
+	0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7,
+	0xA4D1C46D, 0xD3D6F4FB, 0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0,
+	0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9, 0x5005713C, 0x270241AA,
+	0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F,
+	0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81,
+	0xB7BD5C3B, 0xC0BA6CAD, 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A,
+	0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683, 0xE3630B12, 0x94643B84,
+	0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1,
+	0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB,
+	0x196C3671, 0x6E6B06E7, 0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC,
+	0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5, 0xD6D6A3E8, 0xA1D1937E,
+	0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B,
+	0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55,
+	0x316E8EEF, 0x4669BE79, 0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236,
+	0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F, 0xC5BA3BBE, 0xB2BD0B28,
+	0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D,
+	0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F,
+	0x72076785, 0x05005713, 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38,
+	0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21, 0x86D3D2D4, 0xF1D4E242,
+	0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777,
+	0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69,
+	0x616BFFD3, 0x166CCF45, 0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2,
+	0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB, 0xAED16A4A, 0xD9D65ADC,
+	0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9,
+	0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693,
+	0x54DE5729, 0x23D967BF, 0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94,
+	0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D 
+};
+
+static u32
+CalculateCrc (void *_pt, u32 Size)
+{
+	u8 *pt = (u8 *)_pt;
+	register u32 Crc;
+
+	/*  compute crc */
+	Crc = 0xffffffff;
+	while (Size) {
+		Crc = (Crc >> 8) ^ CRCTable[(__u8) Crc ^ *pt];
+		pt += 1;
+		Size -= 1;
+	}
+	Crc = Crc ^ 0xffffffff;
+	return Crc;
+}
+
+
+
+/************************************************************
+ * IsLegacyMBRValid()
+ * Requires:
+ *  - mbr is a pointer to a legacy mbr structure
+ * Modifies: nothing
+ * Returns:
+ *  1 on true
+ *  0 on false
+ ************************************************************/
+static inline int
+IsLegacyMBRValid(LegacyMBR_t *mbr)
+{
+	return (mbr ? (mbr->Signature = MSDOS_MBR_SIGNATURE) : 0);
+}
+
+
+
+/************************************************************
+ * LastLBA()
+ * Requires:
+ *  - struct gendisk hd
+ *  - kdev_t dev
+ * Modifies: nothing
+ * Returns:
+ *  Last LBA value on success.  This is stored (by sd and
+ *  ide-geometry) in 
+ *  the part[0] entry for this disk, and is the number of
+ *  physical sectors available on the disk.
+ *  0 on error
+ ************************************************************/
+u64
+LastLBA(struct gendisk *hd, kdev_t dev)
+{
+  if (!hd || !hd->part) return 0;
+  return hd->part[MINOR(dev)].nr_sects - 1;
+}
+
+
+/************************************************************
+ * ReadLBA()
+ * Requires:
+ *  - hd is our disk device.
+ *  - dev is our device major number
+ *  - lba is the logical block address desired (disk hardsector number)
+ *  - buffer is a buffer of size size into which data copied
+ *  - size_t count is size of the read (in bytes)
+ * Modifies:
+ *  - buffer
+ * Returns:
+ *  - count of bytes read
+ *  - 0 on error
+ * Bugs:
+ *  - bread() takes second argument as a signed int, not a u64.
+ *    This is because getblk() takes the block number as a signed int.
+ *    This overflow is known on l-k.   We overflow at about 1TB.
+ *
+ ************************************************************/
+
+static size_t
+ReadLBA(struct gendisk *hd, kdev_t dev, u64 _lba, u8 *buffer, size_t count)
+{
+	struct buffer_head *bh;
+	size_t totalreadcount = 0, bytesread;
+	int lba = (_lba & 0x7FFFFFFF), i, blockstoread, blocksize;
+	debug_printk(efi_printk_level "ReadLBA(%p,%s,%x,%p,%x)\n",
+		     hd, kdevname(dev), lba, buffer, count);
+  
+	if (!hd || !buffer || !count) return 0;
+  
+  
+	blocksize = get_hardblocksize(dev);
+	if (!blocksize) blocksize = 512;
+	blockstoread = count / blocksize;
+	if (count % blocksize) blockstoread += 1;
+	debug_printk(efi_printk_level "about to read %d blocks\n",
+		     blockstoread);
+  
+  
+	for (i=0; i<blockstoread; i++) {
+		bh = bread(dev, lba+i, blocksize);
+		if (!bh) {
+			/* We hit the end of the disk */
+			debug_printk(efi_printk_level
+				     "bread returned NULL.\n");
+			return totalreadcount;
+		}
+    
+		bytesread = (count > bh->b_size ? bh->b_size : count);
+		memcpy(buffer, bh->b_data, bytesread);
+    
+		buffer += bytesread;         /* Advance the buffer pointer */
+		totalreadcount += bytesread; /* Advance the total read count */
+		count -= bytesread;         /* Subtract bytesread from count */
+    
+		brelse(bh); 
+	}
+  
+	return totalreadcount;
+}
+
+void
+PrintGuidPartitionTableHeader(GuidPartitionTableHeader_t *gpt)
+{
+	debug_printk(efi_printk_level "GUID Partition Table Header\n");
+	if (!gpt) return;
+	debug_printk(efi_printk_level "Signature      : %lx\n",
+		     gpt->Signature);
+	debug_printk(efi_printk_level "Revision       : %x\n",
+		     gpt->Revision);
+	debug_printk(efi_printk_level "HeaderSize     : %x\n",
+		     gpt->HeaderSize);
+	debug_printk(efi_printk_level "HeaderCRC32    : %x\n",
+		     gpt->HeaderCRC32);
+	debug_printk(efi_printk_level "MyLBA          : %lx\n",
+		     gpt->MyLBA);
+	debug_printk(efi_printk_level "AlternateLBA   : %lx\n",
+		     gpt->AlternateLBA);
+	debug_printk(efi_printk_level "FirstUsableLBA : %lx\n",
+		     gpt->FirstUsableLBA);
+	debug_printk(efi_printk_level "LastUsableLBA  : %lx\n",
+		     gpt->LastUsableLBA);
+  
+	debug_printk(efi_printk_level "PartitionEntryLBA : %lx\n",
+		     gpt->PartitionEntryLBA);
+	debug_printk(efi_printk_level "NumberOfPartitionEntries : %x\n",
+		     gpt->NumberOfPartitionEntries);
+	debug_printk(efi_printk_level "SizeOfPartitionEntry : %x\n",
+		     gpt->SizeOfPartitionEntry);
+	debug_printk(efi_printk_level "PartitionEntryArrayCRC32 : %x\n",
+		     gpt->PartitionEntryArrayCRC32);
+  
+	return;
+}
+
+
+
+/************************************************************
+ * ReadGuidPartitionEntries()
+ * Requires:
+ *  - filedes is an open file descriptor, suitable for reading
+ *  - lba is the Logical Block Address of the partition table
+ *  - gpt is a buffer into which the GPT will be put  
+ * Modifies:
+ *  - filedes file and pointer
+ *  - gpt
+ * Returns:
+ *   pte on success
+ *   NULL on error
+ * Notes: remember to free pte when you're done!
+ ************************************************************/
+GuidPartitionEntry_t *
+ReadGuidPartitionEntries(struct gendisk *hd, kdev_t dev,
+			 GuidPartitionTableHeader_t *gpt)
+{
+	size_t count;
+	GuidPartitionEntry_t *pte;
+	if (!hd || !gpt) return NULL;
+  
+	count = gpt->NumberOfPartitionEntries * gpt->SizeOfPartitionEntry;
+	debug_printk(efi_printk_level "ReadGPTEs() kmallocing %x bytes\n",
+		     count);
+	if (!count) return NULL;
+	pte = kmalloc(count, GFP_KERNEL);
+	if (!pte)  return NULL;
+	memset(pte, 0, count);
+  
+	if (ReadLBA(hd, dev, gpt->PartitionEntryLBA, (u8 *)pte,
+		    count) < count) {
+		kfree(pte);
+		return NULL;
+	}
+	return pte;
+}
+
+
+
+/************************************************************
+ * ReadGuidPartitionTableHeader()
+ * Requires:
+ *  - hd is our struct gendisk
+ *  - dev is our device major number
+ *  - lba is the Logical Block Address of the partition table
+ *  - gpt is a buffer into which the GPT will be put  
+ *  - pte is a buffer into which the PTEs will be put  
+ * Modifies:
+ *  - gpt and pte
+ * Returns:
+ *   1 on success
+ *   0 on error
+ ************************************************************/
+
+GuidPartitionTableHeader_t *
+ReadGuidPartitionTableHeader(struct gendisk *hd, kdev_t dev, u64 lba)
+     
+{
+	GuidPartitionTableHeader_t *gpt;
+	if (!hd) return NULL;
+  
+	gpt = kmalloc(sizeof(GuidPartitionTableHeader_t), GFP_KERNEL);
+	if (!gpt) return NULL;
+	memset(gpt, 0, sizeof(GuidPartitionTableHeader_t));
+  
+	debug_printk(efi_printk_level "GPTH() calling ReadLBA().\n");
+	if (ReadLBA(hd, dev, lba, (u8 *)gpt,
+		    sizeof(GuidPartitionTableHeader_t)) <
+	    sizeof(GuidPartitionTableHeader_t)) {
+		debug_printk(efi_printk_level "ReadGPTH(%lx) read failed.\n",
+			     lba);
+		kfree(gpt);
+		return NULL;
+	}
+	PrintGuidPartitionTableHeader(gpt);
+  
+	return gpt;
+}
+
+
+
+/************************************************************
+ * IsGuidPartitionTableValid()
+ * Requires:
+ *  - gd points to our struct gendisk
+ *  - dev is our device major number
+ *  - lba is the logical block address of the GPTH to test
+ *  - gpt is a GPTH if it's valid
+ *  - ptes is a PTEs if it's valid
+ * Modifies:
+ *  - gpt and ptes
+ * Returns:
+ *   1 if valid
+ *   0 on error
+ ************************************************************/
+static int
+IsGuidPartitionTableValid(struct gendisk *hd, kdev_t dev, u64 lba, 
+                          GuidPartitionTableHeader_t **gpt,
+                          GuidPartitionEntry_t **ptes)
+{
+	u32 crc, origcrc;
+  
+	if (!hd || !gpt || !ptes) return 0;
+	if (!(*gpt = ReadGuidPartitionTableHeader(hd, dev, lba))) return 0;
+  
+	/* Check the GUID Partition Table Signature */
+	if ((*gpt)->Signature != GUID_PT_HEADER_SIGNATURE) {
+		debug_printk(efi_printk_level "GUID Partition Table Header Signature is wrong: %x != %x\n", (*gpt)->Signature, GUID_PT_HEADER_SIGNATURE);
+		kfree(*gpt);
+		*gpt = NULL;
+		return 0;
+	}
+  
+	/* Check the GUID Partition Table CRC */
+	origcrc = (*gpt)->HeaderCRC32;
+	(*gpt)->HeaderCRC32 = 0;
+	crc = CalculateCrc(*gpt, (*gpt)->HeaderSize);
+  
+  
+	if (crc != origcrc) {
+		debug_printk(efi_printk_level "GUID Partition Table Header CRC is wrong: %x != %x\n", (*gpt)->HeaderCRC32, origcrc);
+		kfree(*gpt);
+		*gpt = NULL;
+		return 0;
+	}
+	(*gpt)->HeaderCRC32 = origcrc;
+  
+	/* Check that the MyLBA entry points to the LBA that contains
+	 * the GUID Partition Table */
+	if ((*gpt)->MyLBA != lba) {
+		debug_printk(efi_printk_level "GPT MyLBA incorrect: %lx != %lx\n", (*gpt)->MyLBA, lba);
+		kfree(*gpt);
+		*gpt = NULL;
+		return 0;
+	}
+  
+	if (!(*ptes = ReadGuidPartitionEntries(hd, dev, *gpt))) {
+		debug_printk(efi_printk_level "read PTEs failed.\n");
+		kfree(*gpt);
+		*gpt = NULL;
+		return 0;
+	}
+  
+	/* Check the GUID Partition Entry Array CRC */
+	crc = CalculateCrc(*ptes, (*gpt)->NumberOfPartitionEntries *
+			   (*gpt)->SizeOfPartitionEntry);
+  
+	if (crc != (*gpt)->PartitionEntryArrayCRC32)  {
+		debug_printk(efi_printk_level "GUID Partitition Entry Array CRC check failed.\n");
+		kfree(*gpt);
+		*gpt = NULL;
+		kfree(*ptes);
+		*ptes = NULL;
+		return 0;
+	}
+  
+  
+	/* We're done, all's well */
+	return 1;
+}
+
+
+
+/************************************************************
+ * FindValidGPT()
+ * Requires:
+ *  - gd points to our struct gendisk
+ *  - dev is our device major number
+ *  - gpt is a GPTH if it's valid
+ *  - ptes is a PTE
+ * Modifies:
+ *  - gpt & ptes
+ * Returns:
+ *   1 if valid
+ *   0 on error
+ ************************************************************/
+static int
+FindValidGPT(struct gendisk *hd, kdev_t dev,
+             GuidPartitionTableHeader_t **gpt,
+             GuidPartitionEntry_t **ptes)
+{
+	int rc = 0;
+	GuidPartitionTableHeader_t *pgpt = NULL, *agpt = NULL;
+	GuidPartitionEntry_t *pptes = NULL, *aptes = NULL;
+	u64 lastlba;
+	if (!hd || !gpt || !ptes) return 0;
+
+	lastlba = LastLBA(hd, dev);
+	/* Check the Primary GPT */
+	rc = IsGuidPartitionTableValid(hd, dev, 1, &pgpt, &pptes);
+	if (rc) {
+		/* Primary GPT is OK, check the alternate and warn if bad */
+		rc = IsGuidPartitionTableValid(hd, dev, pgpt->AlternateLBA,
+					       &agpt, &aptes);    
+		if (!rc){
+			printk(KERN_WARNING "Alternate GPT is invalid, using primary GPT.\n");
+		}
+    
+		*gpt = pgpt;
+		*ptes = pptes;
+		if (agpt)  kfree(agpt);
+		if (aptes) kfree(aptes);
+		return 1;
+	} /* if primary is valid */
+	else {
+		/* Primary GPT is bad, check the Alternate GPT */
+		rc = IsGuidPartitionTableValid(hd, dev, lastlba,
+					       &agpt, &aptes);    
+		if (rc) {
+			/* Primary is bad, alternate is good.
+			   Return values from the alternate and warn.
+			*/
+			printk(KERN_WARNING "Primary GPT is invalid, using alternate GPT.\n");
+			*gpt = agpt;
+			*ptes = aptes;
+			return 1;
+		}
+		else {
+			/* Primary is bad, alternate is bad, try "other"
+			 * alternate.  This is necessary because if we
+			 * have an odd-sized disk, user-space might
+			 * have put the alternate in block lastlba-1.
+			 */
+			if (!(lastlba & 1)) {
+				lastlba--;
+				rc = IsGuidPartitionTableValid(hd, dev,
+							       lastlba,
+							       &agpt, &aptes);
+				if (rc) {
+					/* Primary is bad, alternate is good.
+					 * Return values from the alternate
+					 * and warn.
+					 */
+					printk("Primary GPT is invalid, using alternate GPT.\n");
+					*gpt = agpt;
+					*ptes = aptes;
+					return 1;
+				}
+			}
+		}
+	}
+	/* Both primary and alternate GPTs are bad.
+	 * This isn't our disk, return 0.
+	 */
+	return 0;
+}
+
+
+
+/*
+ * Create devices for each entry in the GUID Partition Table Entries.
+ * The first block of each partition is a Legacy MBR.
+ *
+ * We do not create a Linux partition for GPT, but
+ * only for the actual data partitions.
+ * Returns:
+ * -1 if unable to read the partition table
+ *  0 if this isn't our partition table
+ *  1 if successful
+ *
+ */
+
+static int
+add_gpt_partitions(struct gendisk *hd, kdev_t dev, int nextminor)
+{
+	GuidPartitionTableHeader_t *gpt = NULL;
+	GuidPartitionEntry_t *ptes = NULL;
+	u32 i, nummade=0;
+
+	efi_guid_t unusedGuid = UNUSED_ENTRY_GUID;
+#if CONFIG_BLK_DEV_MD && CONFIG_AUTODETECT_RAID
+	efi_guid_t raidGuid = PARTITION_LINUX_RAID_GUID;
+#endif
+
+	if (!hd) return -1;
+  
+	if (!FindValidGPT(hd, dev, &gpt, &ptes) || 
+	    !gpt || !ptes) {
+		if (gpt) kfree(gpt);
+		if (ptes) kfree(ptes);
+		return 0;
+	}
+  
+	debug_printk(efi_printk_level "GUID Partition Table is valid!  Yea!\n");
+	for (i = 0; i < gpt->NumberOfPartitionEntries &&
+		     nummade < (hd->max_p - 1); i++) {
+		if (!efi_guidcmp(unusedGuid, ptes[i].PartitionTypeGuid))
+			continue;
+
+		add_gd_partition(hd, nextminor, ptes[i].StartingLBA,
+				 (ptes[i].EndingLBA-ptes[i].StartingLBA + 1));
+
+		/* If there's this is a RAID volume, tell md */
+#if CONFIG_BLK_DEV_MD && CONFIG_AUTODETECT_RAID
+		if (!efi_guidcmp(raidGuid, ptes[i].PartitionTypeGuid)) {
+			md_autodetect_dev(MKDEV(MAJOR(dev),nextminor));
+		}
+#endif
+		nummade++;
+		nextminor++;
+
+	}
+	kfree(ptes);
+	kfree(gpt);
+	printk("\n");
+	return 1;
+  
+}
+
+
+/* 
+ * efi_partition()
+ *
+ * If the first block on the disk is a legacy MBR,
+ * it got handled already by msdos_partition().
+ * If it's a Protective MBR, we'll handle it here.
+ *
+ * Returns:
+ * -1 if unable to read the partition table
+ *  0 if this isn't our partitoin table
+ *  1 if successful
+ *
+ */
+
+int
+efi_partition(struct gendisk *hd, kdev_t dev,
+              unsigned long first_sector, int first_part_minor) {
+	int hardblocksize = get_hardblocksize(dev);
+	int orig_blksize_size = BLOCK_SIZE;
+	int rc = 0;
+  
+  /* not good, but choose something! */
+	if (!hardblocksize) hardblocksize = 512;
+  
+	/* Need to change the block size that the block layer uses */
+	if (blksize_size[MAJOR(dev)]){
+		orig_blksize_size = blksize_size[MAJOR(dev)][MINOR(dev)];
+	}
+  
+	if (orig_blksize_size != hardblocksize)
+		set_blocksize(dev, hardblocksize);
+  
+	rc = add_gpt_partitions(hd, dev, first_part_minor);
+  
+	/* change back */
+	if (orig_blksize_size != hardblocksize)
+		set_blocksize(dev, orig_blksize_size);
+  
+	return rc;
+}
+
+
+/*
+ * Overrides for Emacs so that we follow Linus's tabbing style.
+ * Emacs will notice this stuff at the end of the file and automatically
+ * adjust the settings for this buffer only.  This must remain at the end
+ * of the file.
+ * ---------------------------------------------------------------------------
+ * Local variables:
+ * c-indent-level: 4 
+ * c-brace-imaginary-offset: 0
+ * c-brace-offset: -4
+ * c-argdecl-indent: 4
+ * c-label-offset: -4
+ * c-continued-statement-offset: 4
+ * c-continued-brace-offset: 0
+ * indent-tabs-mode: nil
+ * tab-width: 8
+ * End:
+ */
+
+
+
diff -urN linux-davidm/fs/partitions/efi.h linux-2.4.0-test10-lia/fs/partitions/efi.h
--- linux-davidm/fs/partitions/efi.h	Wed Dec 31 16:00:00 1969
+++ linux-2.4.0-test10-lia/fs/partitions/efi.h	Wed Nov  1 23:35:07 2000
@@ -0,0 +1,154 @@
+/************************************************************
+ * EFI GUID Partition Table
+ * Per Intel EFI Specification v0.99
+ * http://developer.intel.com/technology/efi/efi.htm
+ *
+ * By Matt Domsch <Matt_Domsch@dell.com>  Fri Sep 22 22:15:56 CDT 2000  
+ *   Copyright 2000 Dell Computer Corporation
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ * 
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * 
+ ************************************************************/
+
+#ifndef FS_PART_EFI_H_INCLUDED
+#define FS_PART_EFI_H_INCLUDED
+
+#include <linux/types.h>
+#include <asm/efi.h>
+
+#include <linux/config.h>
+#include <linux/fs.h>
+#include <linux/genhd.h>
+#include <linux/kernel.h>
+#include <linux/major.h>
+#include <linux/string.h>
+#include <linux/blk.h>
+
+#define MSDOS_MBR_SIGNATURE 0xaa55
+#define EFI_PMBR_OSTYPE_EFI 0xEF
+#define EFI_PMBR_OSTYPE_EFI_GPT 0xEE
+
+#define GUID_PT_BLOCK_SIZE 512
+
+#define GUID_PT_HEADER_SIGNATURE 0x5452415020494645L
+#define GUID_PT_HEADER_REVISION_V1 0x00010000
+#define GUID_PT_HEADER_REVISION_V0_99 0x00000099
+#define UNUSED_ENTRY_GUID    \
+    ((efi_guid_t) { 0x00000000, 0x0000, 0x0000, { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }})
+#define PARTITION_SYSTEM_GUID \
+((efi_guid_t) { 0xC12A7328, 0xF81F, 0x11d2, { 0xBA, 0x4B, 0x00, 0xA0, 0xC9, 0x3E, 0xC9, 0x3B }})
+#define LEGACY_MBR_PARTITION_GUID \
+    ((efi_guid_t) { 0x024DEE41, 0x33E7, 0x11d3, { 0x9D, 0x69, 0x00, 0x08, 0xC7, 0x81, 0xF3, 0x9F }})
+#define PARTITION_MSFT_RESERVED_GUID \
+    ((efi_guid_t) { 0xE3C9E316, 0x0B5C, 0x4DB8, { 0x81, 0x7D, 0xF9, 0x2D, 0xF0, 0x02, 0x15, 0xAE }})
+#define PARTITION_BASIC_DATA_GUID \
+    ((efi_guid_t) { 0xEBD0A0A2, 0xB9E5, 0x4433, { 0x87, 0xC0, 0x68, 0xB6, 0xB7, 0x26, 0x99, 0xC7 }})
+#define PARTITION_LINUX_RAID_GUID \
+    ((efi_guid_t) { 0xa19d880f, 0x05fc, 0x4d3b, { 0xa0, 0x06, 0x74, 0x3f, 0x0f, 0x84, 0x91, 0x1e  }})
+#define PARTITION_LINUX_SWAP_GUID \
+    ((efi_guid_t) { 0x0657fd6d, 0xa4ab, 0x43c4, { 0x84, 0xe5, 0x09, 0x33, 0xc8, 0x4b, 0x4f, 0x4f  }})
+
+typedef struct _GuidPartitionTableHeader_t {
+  u64 Signature;
+  u32 Revision;
+  u32 HeaderSize;
+  u32 HeaderCRC32;
+  u32 Reserved1;
+  u64 MyLBA;
+  u64 AlternateLBA;
+  u64 FirstUsableLBA;
+  u64 LastUsableLBA;
+  efi_guid_t DiskGUID;
+  u64 PartitionEntryLBA;
+  u32 NumberOfPartitionEntries;
+  u32 SizeOfPartitionEntry;
+  u32 PartitionEntryArrayCRC32;
+  u8 Reserved2[GUID_PT_BLOCK_SIZE - 92];
+} GuidPartitionTableHeader_t;
+
+typedef struct _GuidPartitionEntryAttributes_t {
+  __u64 RequiredToFunction:1;
+  __u64 Reserved:63;
+} GuidPartitionEntryAttributes_t;
+
+typedef struct _GuidPartitionEntry_t {
+  efi_guid_t PartitionTypeGuid;
+  efi_guid_t UniquePartitionGuid;
+  u64 StartingLBA;
+  u64 EndingLBA;
+  GuidPartitionEntryAttributes_t Attributes;
+  efi_char16_t PartitionName[72/sizeof(efi_char16_t)];
+} GuidPartitionEntry_t;
+
+
+
+typedef struct _PartitionRecord_t {
+  u8 BootIndicator;  /* Not used by EFI firmware. Set to 0x80 to indicate that this
+                        is the bootable legacy partition. */
+  u8 StartHead;      /* Start of partition in CHS address, not used by EFI firmware. */
+  u8 StartSector;    /* Start of partition in CHS address, not used by EFI firmware. */
+  u8 StartTrack;     /* Start of partition in CHS address, not used by EFI firmware. */
+  u8 OSType;         /* OS type. A value of 0xEF defines an EFI system partition.
+                        Other values are reserved for legacy operating systems, and
+                        allocated independently of the EFI specification. */
+  u8 EndHead;        /* End of partition in CHS address, not used by EFI firmware. */
+  u8 EndSector;      /* End of partition in CHS address, not used by EFI firmware. */
+  u8 EndTrack;       /* End of partition in CHS address, not used by EFI firmware. */
+  u32 StartingLBA;   /* Starting LBA address of the partition on the disk. Used by
+                        EFI firmware to define the start of the partition. */
+  u32 SizeInLBA;     /* Size of partition in LBA. Used by EFI firmware to determine
+                        the size of the partition. */
+} PartitionRecord_t;
+
+typedef struct _LegacyMBR_t {
+  u8 BootCode[440];
+  u32 UniqueMBRSignature;
+  u16 Unknown;
+  PartitionRecord_t PartitionRecord[4];
+  u16 Signature;
+} __attribute__ ((packed)) LegacyMBR_t;
+
+
+
+#define EFI_GPT_PRIMARY_PARTITION_TABLE_LBA 1
+
+/* Functions */
+extern int
+efi_partition(struct gendisk *hd, kdev_t dev,
+              unsigned long first_sector, int first_part_minor);
+
+
+
+
+#endif
+
+/*
+ * Overrides for Emacs so that we follow Linus's tabbing style.
+ * Emacs will notice this stuff at the end of the file and automatically
+ * adjust the settings for this buffer only.  This must remain at the end
+ * of the file.
+ * --------------------------------------------------------------------------
+ * Local variables:
+ * c-indent-level: 4 
+ * c-brace-imaginary-offset: 0
+ * c-brace-offset: -4
+ * c-argdecl-indent: 4
+ * c-label-offset: -4
+ * c-continued-statement-offset: 4
+ * c-continued-brace-offset: 0
+ * indent-tabs-mode: nil
+ * tab-width: 8
+ * End:
+ */
diff -urN linux-davidm/fs/partitions/msdos.c linux-2.4.0-test10-lia/fs/partitions/msdos.c
--- linux-davidm/fs/partitions/msdos.c	Tue Jul 18 23:29:16 2000
+++ linux-2.4.0-test10-lia/fs/partitions/msdos.c	Thu Nov  2 00:10:33 2000
@@ -36,6 +36,10 @@
 #include "check.h"
 #include "msdos.h"
 
+#ifdef CONFIG_EFI_PARTITION
+#include "efi.h"
+#endif
+
 #if CONFIG_BLK_DEV_MD && CONFIG_AUTODETECT_RAID
 extern void md_autodetect_dev(kdev_t dev);
 #endif
@@ -378,6 +382,16 @@
 		bforget(bh);
 		return 0;
 	}
+#ifdef CONFIG_EFI_PARTITION
+	p = (struct partition *) (0x1be + data);
+	for (i=1 ; i<=4 ; i++,p++) {
+		/* If this is an EFI GPT disk, msdos should ignore it. */
+		if (SYS_IND(p) = EFI_PMBR_OSTYPE_EFI_GPT) {
+			bforget(bh);
+			return 0;
+		}
+	}
+#endif
 	p = (struct partition *) (0x1be + data);
 
 #ifdef CONFIG_BLK_DEV_IDE
diff -urN linux-davidm/include/asm-ia64/cache.h linux-2.4.0-test10-lia/include/asm-ia64/cache.h
--- linux-davidm/include/asm-ia64/cache.h	Fri Apr 21 15:21:24 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/cache.h	Wed Nov  1 23:32:05 2000
@@ -9,11 +9,11 @@
  */
 
 /* Bytes per L1 (data) cache line.  */
-#define LOG_L1_CACHE_BYTES	6
-#define L1_CACHE_BYTES		(1 << LOG_L1_CACHE_BYTES)
+#define L1_CACHE_SHIFT		6
+#define L1_CACHE_BYTES		(1 << L1_CACHE_SHIFT)
 
 #ifdef CONFIG_SMP
-# define SMP_LOG_CACHE_BYTES	LOG_L1_CACHE_BYTES
+# define SMP_CACHE_SHIFT	L1_CACHE_SHIFT
 # define SMP_CACHE_BYTES	L1_CACHE_BYTES
 #else
   /*
@@ -21,7 +21,7 @@
    * safe and provides an easy way to avoid wasting space on a
    * uni-processor:
    */
-# define SMP_LOG_CACHE_BYTES	3
+# define SMP_CACHE_SHIFT	3
 # define SMP_CACHE_BYTES	(1 << 3)
 #endif
 
diff -urNdiff -urN linux-davidm/include/asm-ia64/machvec_dig.h linux-2.4.0-test10-lia/include/asm-ia64/machvec_dig.h
--- linux-davidm/include/asm-ia64/machvec_dig.h	Thu Nov  2 00:16:41 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/machvec_dig.h	Wed Nov  1 23:22:49 2000
@@ -5,6 +5,7 @@
 extern ia64_mv_irq_init_t dig_irq_init;
 extern ia64_mv_pci_fixup_t dig_pci_fixup;
 extern ia64_mv_map_nr_t map_nr_dense;
+extern ia64_mv_pci_fixup_t iosapic_pci_fixup;
 
 /*
  * This stuff has dual use!
diff -urN linux-davidm/include/asm-ia64/module.h linux-2.4.0-test10-lia/include/asm-ia64/module.h
--- linux-davidm/include/asm-ia64/module.h	Thu Nov  2 00:16:41 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/module.h	Wed Nov  1 23:53:20 2000
@@ -75,10 +75,10 @@
 	/*
 	 * Pointers are reasonable, add the module unwind table
 	 */
-	archdata->unw_table = unw_add_unwind_table(mod->name, archdata->segment_base,
+	archdata->unw_table = unw_add_unwind_table(mod->name,
+						   (unsigned long) archdata->segment_base,
 						   (unsigned long) archdata->gp,
-						   (unsigned long) archdata->unw_start,
-						   (unsigned long) archdata->unw_end);
+						   archdata->unw_start, archdata->unw_end);
 #endif /* CONFIG_IA64_NEW_UNWIND */
 	return 0;
 }
@@ -98,7 +98,7 @@
 		archdata = (struct archdata *)(mod->archdata_start);
 
 		if (archdata->unw_table != NULL)
-			unw_remove_unwind_table(archdata->unw_table);
+			unw_remove_unwind_table((void *) archdata->unw_table);
 	}
 #endif /* CONFIG_IA64_NEW_UNWIND */
 
diff -urN linux-davidm/include/asm-ia64/pgalloc.h linux-2.4.0-test10-lia/include/asm-ia64/pgalloc.h
--- linux-davidm/include/asm-ia64/pgalloc.h	Thu Nov  2 00:16:41 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/pgalloc.h	Wed Nov  1 23:32:10 2000
@@ -196,13 +196,6 @@
 extern int do_check_pgt_cache (int, int);
 
 /*
- * This establishes kernel virtual mappings (e.g., as a result of a
- * vmalloc call).  Since ia-64 uses a separate kernel page table,
- * there is nothing to do here... :)
- */
-#define set_pgdir(vmaddr, entry)	do { } while(0)
-
-/*
  * Now for some TLB flushing routines.  This is the kind of stuff that
  * can be very expensive, so try to avoid them whenever possible.
  */
diff -urN linux-davidm/include/asm-ia64/pgtable.h linux-2.4.0-test10-lia/include/asm-ia64/pgtable.h
--- linux-davidm/include/asm-ia64/pgtable.h	Thu Nov  2 00:16:41 2000
+++ linux-2.4.0-test10-lia/include/asm-ia64/pgtable.h	Wed Nov  1 23:32:30 2000
@@ -24,6 +24,9 @@
  * matches the VHPT short format, the firt doubleword of the VHPD long
  * format, and the first doubleword of the TLB insertion format.
  */
+#define _PAGE_A_BIT		5
+#define _PAGE_D_BIT		6
+
 #define _PAGE_P			(1 <<  0)	/* page present bit */
 #define _PAGE_MA_WB		(0x0 <<  2)	/* write back memory attribute */
 #define _PAGE_MA_UC		(0x4 <<  2)	/* uncacheable memory attribute */
@@ -46,8 +49,8 @@
 #define _PAGE_AR_X_RX		(7 <<  9)	/* exec & promote / read & exec */
 #define _PAGE_AR_MASK		(7 <<  9)
 #define _PAGE_AR_SHIFT		9
-#define _PAGE_A			(1 <<  5)	/* page accessed bit */
-#define _PAGE_D			(1 <<  6)	/* page dirty bit */
+#define _PAGE_A			(1 << _PAGE_A_BIT)	/* page accessed bit */
+#define _PAGE_D			(1 << _PAGE_D_BIT)	/* page dirty bit */
 #define _PAGE_PPN_MASK		(((__IA64_UL(1) << IA64_MAX_PHYS_BITS) - 1) & ~0xfffUL)
 #define _PAGE_ED		(__IA64_UL(1) << 52)	/* exception deferral */
 #define _PAGE_PROTNONE		(__IA64_UL(1) << 63)
@@ -186,34 +189,12 @@
 } while (0)
 
 /* Quick test to see if ADDR is a (potentially) valid physical address. */
-static __inline__ long
+static inline long
 ia64_phys_addr_valid (unsigned long addr)
 {
 	return (addr & (my_cpu_data.unimpl_pa_mask)) = 0;
 }
 
-/* Quick test to see if ADDR is a (potentially) valid physical address. */
-static __inline__ long
-ia64_phys_addr_valid (unsigned long addr)
-{
-	return (addr & (my_cpu_data.unimpl_pa_mask)) = 0;
-}
-
-/*
- * kern_addr_valid(ADDR) tests if ADDR is pointing to valid kernel
- * memory.  For the return value to be meaningful, ADDR must be >- * PAGE_OFFSET.  This operation can be relatively expensive (e.g.,
- * require a hash-, or multi-level tree-lookup or something of that
- * sort) but it guarantees to return TRUE only if accessing the page
- * at that address does not cause an error.  Note that there may be
- * addresses for which kern_addr_valid() returns FALSE even though an
- * access would not cause an error (e.g., this is typically true for
- * memory mapped I/O regions.
- *
- * XXX Need to implement this for IA-64.
- */
-#define kern_addr_valid(addr)	(1)
-
 /*
  * kern_addr_valid(ADDR) tests if ADDR is pointing to valid kernel
  * memory.  For the return value to be meaningful, ADDR must be >@@ -340,7 +321,7 @@
 /*
  * Return the region index for virtual address ADDRESS.
  */
-static __inline__ unsigned long
+static inline unsigned long
 rgn_index (unsigned long address)
 {
 	ia64_va a;
@@ -352,7 +333,7 @@
 /*
  * Return the region offset for virtual address ADDRESS.
  */
-static __inline__ unsigned long
+static inline unsigned long
 rgn_offset (unsigned long address)
 {
 	ia64_va a;
@@ -364,7 +345,7 @@
 #define RGN_SIZE	(1UL << 61)
 #define RGN_KERNEL	7
 
-static __inline__ unsigned long
+static inline unsigned long
 pgd_index (unsigned long address)
 {
 	unsigned long region = address >> 61;
@@ -375,7 +356,7 @@
 
 /* The offset in the 1-level directory is given by the 3 region bits
    (61..63) and the seven level-1 bits (33-39).  */
-static __inline__ pgd_t*
+static inline pgd_t*
 pgd_offset (struct mm_struct *mm, unsigned long address)
 {
 	return mm->pgd + pgd_index(address);
@@ -394,6 +375,49 @@
 #define pte_offset(dir,addr) \
 	((pte_t *) pmd_page(*(dir)) + (((addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)))
 
+/* atomic versions of the some PTE manipulations: */
+
+static inline int
+ptep_test_and_clear_young (pte_t *ptep)
+{
+	return test_and_clear_bit(_PAGE_A_BIT, ptep);
+}
+
+static inline int
+ptep_test_and_clear_dirty (pte_t *ptep)
+{
+	return test_and_clear_bit(_PAGE_D_BIT, ptep);
+}
+
+static inline pte_t
+ptep_get_and_clear (pte_t *ptep)
+{
+	return __pte(xchg((long *) ptep, 0));
+}
+
+/* XXX this should be called ptep_set_wrprotect!!! */
+static inline void
+ptep_clear_wrprotect (pte_t *ptep)
+{
+	unsigned long new, old;
+
+	do {
+		old = pte_val(*ptep);
+		new = pte_val(pte_wrprotect(__pte (old)));
+	} while (cmpxchg((unsigned long *) ptep, old, new) != old);
+}
+
+static inline void
+ptep_mkdirty (pte_t *ptep)
+{
+	set_bit(_PAGE_D_BIT, ptep);
+}
+
+static inline int
+pte_same (pte_t a, pte_t b)
+{
+	return pte_val(a) = pte_val(b);
+}
 
 extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
 extern void paging_init (void);
@@ -459,8 +483,6 @@
  */
 extern unsigned long empty_zero_page[PAGE_SIZE/sizeof(unsigned long)];
 #define ZERO_PAGE(vaddr) (virt_to_page(empty_zero_page))
-
-#include <asm-generic/pgtable.h>
 
 # endif /* !__ASSEMBLY__ */
 
diff -urN linux-davidm/include/linux/skbuff.h linux-2.4.0-test10-lia/include/linux/skbuff.h
--- linux-davidm/include/linux/skbuff.h	Thu Nov  2 00:16:42 2000
+++ linux-2.4.0-test10-lia/include/linux/skbuff.h	Wed Nov  1 23:33:21 2000
@@ -896,11 +896,7 @@
 {
 	struct sk_buff *skb;
 
-#ifdef CONFIG_SKB_BELOW_4GB
-	skb = alloc_skb(length+16, GFP_ATOMIC | GFP_DMA);
-#else
 	skb = alloc_skb(length+16, GFP_ATOMIC);
-#endif
 	if (skb)
 		skb_reserve(skb,16);
 	return skb;

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


