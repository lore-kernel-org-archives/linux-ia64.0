From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 06 Nov 2001 06:59:53 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.14)
Message-Id: <marc-linux-ia64-105590698805446@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

An updated ia64 patch for 2.4.14 is now available at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/ in file:

        linux-2.4.14-ia64-011105.diff*

change log:

	- update for 2.4.14
	- support non-legacy serial ports via ACPI
	  (Khalid Aziz & Alex Williamson)
	- support 16MB as an alternate page size for the identity mapped region
	- export flush_tlb_range to modules, by popular request
	- in struct scatterlist, rename "orig_address" to "page" (yes,
	  that's cheesy, but SCSI insists on a zeroing a member with such a
	  name...)
	- increase IO_SPACE_LIMIT from 0xffff to ~0UL

This kernel has been tested with gcc-3.0 on Big Sur.  Both UP and MP
seem to compile fine.  As usual, your mileage may vary.

Enjoy,

	--david

diff -urN linux-davidm/Documentation/Configure.help lia64/Documentation/Configure.help
--- linux-davidm/Documentation/Configure.help	Mon Nov  5 21:43:07 2001
+++ lia64/Documentation/Configure.help	Mon Nov  5 21:02:05 2001
@@ -2589,6 +2589,14 @@
   say N here to save some memory. You can also say Y if you have an
   "intelligent" multiport card such as Cyclades, Digiboards, etc.
 
+Support for serial ports defined by ACPI tables
+CONFIG_SERIAL_ACPI
+  Legacy free machines may not have serial ports at the legacy COM1,
+  COM2 etc addresses. Serial ports on such machines are described by
+  the ACPI tables SPCR (Serial Port Console Redirection) table and
+  DBGP (Debug Port) table. Say Y here if you want to include support
+  for these serial ports.
+
 Support for sharing serial interrupts
 CONFIG_SERIAL_SHARE_IRQ
   Some serial boards have hardware support which allows multiple dumb
diff -urN linux-davidm/arch/ia64/config.in lia64/arch/ia64/config.in
--- linux-davidm/arch/ia64/config.in	Mon Nov  5 21:43:07 2001
+++ lia64/arch/ia64/config.in	Mon Nov  5 21:04:18 2001
@@ -256,6 +256,10 @@
 mainmenu_option next_comment
 comment 'Kernel hacking'
 
+choice 'Physical memory granularity'				\
+	"16MB			CONFIG_IA64_GRANULE_16MB	\
+	 64MB			CONFIG_IA64_GRANULE_64MB" 64MB
+
 bool 'Kernel debugging' CONFIG_DEBUG_KERNEL
 if [ "$CONFIG_DEBUG_KERNEL" != "n" ]; then
    bool '  Print possible IA64 hazards to console' CONFIG_IA64_PRINT_HAZARDS
diff -urN linux-davidm/arch/ia64/defconfig lia64/arch/ia64/defconfig
--- linux-davidm/arch/ia64/defconfig	Mon Nov  5 21:43:07 2001
+++ lia64/arch/ia64/defconfig	Mon Nov  5 22:26:13 2001
@@ -40,7 +40,7 @@
 CONFIG_IA64_PAGE_SIZE_16KB=y
 # CONFIG_IA64_PAGE_SIZE_64KB is not set
 CONFIG_IA64_BRL_EMU=y
-CONFIG_ITANIUM_BSTEP_SPECIFIC=y
+# CONFIG_ITANIUM_BSTEP_SPECIFIC is not set
 CONFIG_IA64_L1_CACHE_SHIFT=6
 CONFIG_IA64_MCA=y
 CONFIG_PM=y
@@ -95,6 +95,7 @@
 # CONFIG_IPV6 is not set
 # CONFIG_KHTTPD is not set
 # CONFIG_ATM is not set
+# CONFIG_VLAN_8021Q is not set
 
 #
 #  
@@ -127,7 +128,6 @@
 #
 # CONFIG_PNP is not set
 # CONFIG_ISAPNP is not set
-# CONFIG_PNPBIOS is not set
 
 #
 # Block devices
@@ -298,7 +298,6 @@
 # CONFIG_SCSI_INITIO is not set
 # CONFIG_SCSI_INIA100 is not set
 # CONFIG_SCSI_NCR53C406A is not set
-# CONFIG_SCSI_NCR_D700 is not set
 # CONFIG_SCSI_NCR53C7xx is not set
 # CONFIG_SCSI_NCR53C8XX is not set
 # CONFIG_SCSI_SYM53C8XX is not set
@@ -364,6 +363,7 @@
 # CONFIG_NE2K_PCI is not set
 # CONFIG_NE3210 is not set
 # CONFIG_ES3210 is not set
+# CONFIG_8139CP is not set
 # CONFIG_8139TOO is not set
 # CONFIG_8139TOO_PIO is not set
 # CONFIG_8139TOO_TUNE_TWISTER is not set
@@ -374,7 +374,6 @@
 # CONFIG_TLAN is not set
 # CONFIG_VIA_RHINE is not set
 # CONFIG_WINBOND_840 is not set
-# CONFIG_LAN_SAA9730 is not set
 # CONFIG_NET_POCKET is not set
 
 #
@@ -444,6 +443,7 @@
 CONFIG_VT_CONSOLE=y
 CONFIG_SERIAL=y
 CONFIG_SERIAL_CONSOLE=y
+# CONFIG_SERIAL_ACPI is not set
 # CONFIG_SERIAL_EXTENDED is not set
 # CONFIG_SERIAL_NONSTANDARD is not set
 CONFIG_UNIX98_PTYS=y
@@ -510,7 +510,6 @@
 # CONFIG_DTLK is not set
 # CONFIG_R3964 is not set
 # CONFIG_APPLICOM is not set
-# CONFIG_SONYPI is not set
 
 #
 # Ftape, the floppy tape device driver
@@ -596,11 +595,13 @@
 CONFIG_VFAT_FS=y
 # CONFIG_EFS_FS is not set
 # CONFIG_JFFS_FS is not set
+# CONFIG_JFFS2_FS is not set
 # CONFIG_CRAMFS is not set
 # CONFIG_TMPFS is not set
 # CONFIG_RAMFS is not set
 CONFIG_ISO9660_FS=y
 # CONFIG_JOLIET is not set
+# CONFIG_ZISOFS is not set
 # CONFIG_MINIX_FS is not set
 # CONFIG_VXFS_FS is not set
 # CONFIG_NTFS_FS is not set
@@ -643,6 +644,8 @@
 # CONFIG_NCPFS_SMALLDOS is not set
 # CONFIG_NCPFS_NLS is not set
 # CONFIG_NCPFS_EXTRAS is not set
+# CONFIG_ZISOFS_FS is not set
+# CONFIG_ZLIB_FS_INFLATE is not set
 
 #
 # Partition Types
@@ -755,12 +758,14 @@
 #
 CONFIG_USB_DEVICEFS=y
 # CONFIG_USB_BANDWIDTH is not set
+# CONFIG_USB_LONG_TIMEOUT is not set
 
 #
 # USB Controllers
 #
-CONFIG_USB_UHCI_ALT=y
-CONFIG_USB_OHCI=y
+CONFIG_USB_UHCI=m
+# CONFIG_USB_UHCI_ALT is not set
+# CONFIG_USB_OHCI is not set
 
 #
 # USB Device Class drivers
@@ -768,15 +773,24 @@
 # CONFIG_USB_AUDIO is not set
 # CONFIG_USB_BLUETOOTH is not set
 # CONFIG_USB_STORAGE is not set
+# CONFIG_USB_STORAGE_DEBUG is not set
+# CONFIG_USB_STORAGE_DATAFAB is not set
+# CONFIG_USB_STORAGE_FREECOM is not set
+# CONFIG_USB_STORAGE_ISD200 is not set
+# CONFIG_USB_STORAGE_DPCM is not set
+# CONFIG_USB_STORAGE_HP8200e is not set
+# CONFIG_USB_STORAGE_SDDR09 is not set
+# CONFIG_USB_STORAGE_JUMPSHOT is not set
 # CONFIG_USB_ACM is not set
 # CONFIG_USB_PRINTER is not set
 
 #
 # USB Human Interface Devices (HID)
 #
-# CONFIG_USB_HID is not set
-CONFIG_USB_KBD=y
-CONFIG_USB_MOUSE=y
+CONFIG_USB_HID=m
+CONFIG_USB_HIDDEV=y
+CONFIG_USB_KBD=m
+CONFIG_USB_MOUSE=m
 # CONFIG_USB_WACOM is not set
 
 #
@@ -786,11 +800,12 @@
 # CONFIG_USB_MDC800 is not set
 # CONFIG_USB_SCANNER is not set
 # CONFIG_USB_MICROTEK is not set
+# CONFIG_USB_HPUSBSCSI is not set
 
 #
 # USB Multimedia devices
 #
-CONFIG_USB_IBMCAM=y
+# CONFIG_USB_IBMCAM is not set
 # CONFIG_USB_OV511 is not set
 # CONFIG_USB_PWC is not set
 # CONFIG_USB_SE401 is not set
@@ -801,9 +816,9 @@
 # USB Network adaptors
 #
 # CONFIG_USB_PEGASUS is not set
+# CONFIG_USB_KAWETH is not set
 # CONFIG_USB_CATC is not set
 # CONFIG_USB_CDCETHER is not set
-# CONFIG_USB_KAWETH is not set
 # CONFIG_USB_USBNET is not set
 
 #
@@ -815,9 +830,33 @@
 # USB Serial Converter support
 #
 # CONFIG_USB_SERIAL is not set
+# CONFIG_USB_SERIAL_GENERIC is not set
+# CONFIG_USB_SERIAL_BELKIN is not set
+# CONFIG_USB_SERIAL_WHITEHEAT is not set
+# CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
+# CONFIG_USB_SERIAL_EMPEG is not set
+# CONFIG_USB_SERIAL_FTDI_SIO is not set
+# CONFIG_USB_SERIAL_VISOR is not set
+# CONFIG_USB_SERIAL_IR is not set
+# CONFIG_USB_SERIAL_EDGEPORT is not set
+# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
+# CONFIG_USB_SERIAL_KEYSPAN is not set
+# CONFIG_USB_SERIAL_KEYSPAN_USA28 is not set
+# CONFIG_USB_SERIAL_KEYSPAN_USA28X is not set
+# CONFIG_USB_SERIAL_KEYSPAN_USA28XA is not set
+# CONFIG_USB_SERIAL_KEYSPAN_USA28XB is not set
+# CONFIG_USB_SERIAL_KEYSPAN_USA19 is not set
+# CONFIG_USB_SERIAL_KEYSPAN_USA18X is not set
+# CONFIG_USB_SERIAL_KEYSPAN_USA19W is not set
+# CONFIG_USB_SERIAL_KEYSPAN_USA49W is not set
+# CONFIG_USB_SERIAL_MCT_U232 is not set
+# CONFIG_USB_SERIAL_PL2303 is not set
+# CONFIG_USB_SERIAL_CYBERJACK is not set
+# CONFIG_USB_SERIAL_XIRCOM is not set
+# CONFIG_USB_SERIAL_OMNINET is not set
 
 #
-# USB misc drivers
+# USB Miscellaneous drivers
 #
 # CONFIG_USB_RIO500 is not set
 
@@ -829,6 +868,8 @@
 #
 # Kernel hacking
 #
+# CONFIG_IA64_GRANULE_16MB is not set
+CONFIG_IA64_GRANULE_64MB=y
 CONFIG_DEBUG_KERNEL=y
 CONFIG_IA64_PRINT_HAZARDS=y
 # CONFIG_DISABLE_VHPT is not set
diff -urN linux-davidm/arch/ia64/ia32/ia32_traps.c lia64/arch/ia64/ia32/ia32_traps.c
--- linux-davidm/arch/ia64/ia32/ia32_traps.c	Mon Nov  5 21:43:07 2001
+++ lia64/arch/ia64/ia32/ia32_traps.c	Mon Nov  5 21:04:32 2001
@@ -4,7 +4,7 @@
  * Copyright (C) 2000 Asit K. Mallick <asit.k.mallick@intel.com>
  * Copyright (C) 2001 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
-/*
+ *
  * 06/16/00	A. Mallick	added siginfo for most cases (close to IA32)
  * 09/29/00	D. Mosberger	added ia32_intercept()
  */
diff -urN linux-davidm/arch/ia64/kernel/acpi.c lia64/arch/ia64/kernel/acpi.c
--- linux-davidm/arch/ia64/kernel/acpi.c	Mon Nov  5 21:43:07 2001
+++ lia64/arch/ia64/kernel/acpi.c	Mon Nov  5 21:04:58 2001
@@ -23,6 +23,9 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/irq.h>
+#ifdef CONFIG_SERIAL_ACPI
+#include <linux/acpi_serial.h>
+#endif
 
 #include <asm/acpi-ext.h>
 #include <asm/acpikcfg.h>
@@ -44,6 +47,7 @@
 void (*pm_idle) (void);
 void (*pm_power_off) (void);
 
+asm (".weak iosapic_register_irq");
 asm (".weak iosapic_register_legacy_irq");
 asm (".weak iosapic_register_platform_irq");
 asm (".weak iosapic_init");
@@ -397,6 +401,7 @@
 # ifdef CONFIG_ACPI
 	acpi_xsdt_t *xsdt;
 	acpi_desc_table_hdr_t *hdrp;
+	acpi_madt_t *madt;
 	int tables, i;
 
 	if (strncmp(rsdp20->signature, ACPI_RSDP_SIG, ACPI_RSDP_SIG_LEN)) {
@@ -438,9 +443,76 @@
 			ACPI_MADT_SIG, ACPI_MADT_SIG_LEN) != 0)
 			continue;
 
-		acpi20_parse_madt((acpi_madt_t *) hdrp);
+		/* Save MADT pointer for later */
+		madt = (acpi_madt_t *) hdrp;
+		acpi20_parse_madt(madt);
 	}
 
+#ifdef CONFIG_SERIAL_ACPI
+	/*
+	 * Now we're interested in other tables.  We want the iosapics already
+	 * initialized, so we do it in a separate loop.
+	 */
+	for (i = 0; i < tables; i++) {
+		hdrp = (acpi_desc_table_hdr_t *) __va(readl_unaligned(&xsdt->entry_ptrs[i]));
+		/*
+		 * search for SPCR and DBGP table entries so we can enable
+		 * non-pci interrupts to IO-SAPICs.
+		 */
+		if (!strncmp(hdrp->signature, ACPI_SPCRT_SIG, ACPI_SPCRT_SIG_LEN) ||
+		    !strncmp(hdrp->signature, ACPI_DBGPT_SIG, ACPI_DBGPT_SIG_LEN))
+		{
+			acpi_ser_t *spcr = (void *)hdrp;
+			unsigned long global_int;
+
+			setup_serial_acpi(hdrp);
+
+			/*
+			 * ACPI is able to describe serial ports that live at non-standard
+			 * memory space addresses and use SAPIC interrupts.  If not also
+			 * PCI devices, there would be no interrupt vector information for
+			 * them.  This checks for and fixes that situation.
+			 */
+			if (spcr->length < sizeof(acpi_ser_t))
+				/* table is not long enough for full info, thus no int */
+				break;
+
+			/*
+			 * If the device is not in PCI space, but uses a SAPIC interrupt,
+			 * we need to program the SAPIC so that serial can autoprobe for
+			 * the IA64 interrupt vector later on.  If the device is in PCI
+			 * space, it should already be setup via the PCI vectors
+			 */
+			if (spcr->base_addr.space_id != ACPI_SERIAL_PCICONF_SPACE &&
+			    spcr->int_type = ACPI_SERIAL_INT_SAPIC)
+			{
+				u32 irq_base;
+				char *iosapic_address;
+				int vector;
+
+				/* We have a UART in memory space with a SAPIC interrupt */
+				global_int = (  (spcr->global_int[3] << 24)
+					      | (spcr->global_int[2] << 16)
+					      | (spcr->global_int[1] << 8)
+					      | spcr->global_int[0]);
+
+				if (!iosapic_register_irq)
+					continue;
+
+				/* which iosapic does this IRQ belong to? */
+				if (acpi20_which_iosapic(global_int, madt, &irq_base,
+							 &iosapic_address) = 0)
+				{
+					vector = iosapic_register_irq(global_int,
+					                              1, /* active high polarity */
+					                              1, /* edge triggered */
+					                              irq_base,
+					                              iosapic_address);
+				}
+			}
+		}
+	}
+#endif
 	acpi_cf_terminate();
 
 #  ifdef CONFIG_SMP
diff -urN linux-davidm/arch/ia64/kernel/efi.c lia64/arch/ia64/kernel/efi.c
--- linux-davidm/arch/ia64/kernel/efi.c	Mon Nov  5 21:43:07 2001
+++ lia64/arch/ia64/kernel/efi.c	Mon Nov  5 21:05:27 2001
@@ -6,8 +6,8 @@
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
  * Copyright (C) 1999-2001 Hewlett-Packard Co.
- * Copyright (C) 1999 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 1999-2001 Stephane Eranian <eranian@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ *	Stephane Eranian <eranian@hpl.hp.com>
  *
  * All EFI Runtime Services are not implemented yet as EFI only
  * supports physical mode addressing on SoftSDV. This is to be fixed
@@ -234,7 +234,7 @@
 		 * The only ITLB entry in region 7 that is used is the one installed by
 		 * __start().  That entry covers a 64MB range.
 		 */
-		mask  = ~((1 << KERNEL_PG_SHIFT) - 1);
+		mask  = ~((1 << KERNEL_TR_PAGE_SHIFT) - 1);
 		vaddr = PAGE_OFFSET + md->phys_addr;
 
 		/*
@@ -242,29 +242,32 @@
 		 * mapping.
 		 *
 		 * PAL code is guaranteed to be aligned on a power of 2 between 4k and
-		 * 256KB.  Also from the documentation, it seems like there is an implicit
-		 * guarantee that you will need only ONE ITR to map it. This implies that
-		 * the PAL code is always aligned on its size, i.e., the closest matching
-		 * page size supported by the TLB. Therefore PAL code is guaranteed never
-		 * to cross a 64MB unless it is bigger than 64MB (very unlikely!).  So for
+		 * 256KB and that only one ITR is needed to map it. This implies that the
+		 * PAL code is always aligned on its size, i.e., the closest matching page
+		 * size supported by the TLB. Therefore PAL code is guaranteed never to
+		 * cross a 64MB unless it is bigger than 64MB (very unlikely!).  So for
 		 * now the following test is enough to determine whether or not we need a
 		 * dedicated ITR for the PAL code.
 		 */
 		if ((vaddr & mask) = (KERNEL_START & mask)) {
-			printk(__FUNCTION__ " : no need to install ITR for PAL code\n");
+			printk(__FUNCTION__ ": no need to install ITR for PAL code\n");
 			continue;
 		}
 
+		if (md->num_pages << 12 > IA64_GRANULE_SIZE)
+			panic("Woah!  PAL code size bigger than a granule!");
+
+		mask  = ~((1 << IA64_GRANULE_SHIFT) - 1);
 		printk("CPU %d: mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
 		       smp_processor_id(), md->phys_addr, md->phys_addr + (md->num_pages << 12),
-		       vaddr & mask, (vaddr & mask) + KERNEL_PG_SIZE);
+		       vaddr & mask, (vaddr & mask) + IA64_GRANULE_SIZE);
 
 		/*
 		 * Cannot write to CRx with PSR.ic=1
 		 */
 		ia64_clear_ic(flags);
 		ia64_itr(0x1, IA64_TR_PALCODE, vaddr & mask,
-			 pte_val(mk_pte_phys(md->phys_addr, PAGE_KERNEL)), KERNEL_PG_SHIFT);
+			 pte_val(mk_pte_phys(md->phys_addr, PAGE_KERNEL)), IA64_GRANULE_SHIFT);
 		local_irq_restore(flags);
 		ia64_srlz_i();
 	}
diff -urN linux-davidm/arch/ia64/kernel/entry.S lia64/arch/ia64/kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Mon Nov  5 21:43:07 2001
+++ lia64/arch/ia64/kernel/entry.S	Mon Nov  5 21:06:38 2001
@@ -140,15 +140,14 @@
 	dep r20=0,in0,61,3		// physical address of "current"
 	;;
 	st8 [r22]=sp			// save kernel stack pointer of old task
-	shr.u r26=r20,KERNEL_PG_SHIFT
-	mov r16=KERNEL_PG_NUM
+	shr.u r26=r20,IA64_GRANULE_SHIFT
+	shr.u r17=r20,KERNEL_TR_PAGE_SHIFT
 	;;
-	cmp.ne p6,p7=r26,r16		// check whether r26 != KERNEL_PG_NUM
+	cmp.ne p6,p7=KERNEL_TR_PAGE_NUM,r17
 	adds r21=IA64_TASK_THREAD_KSP_OFFSET,in0
 	;;
 	/*
-	 * If we've already mapped this task's page, we can skip doing it
-	 * again.
+	 * If we've already mapped this task's page, we can skip doing it again.
 	 */
 (p6)	cmp.eq p7,p6=r26,r27
 (p6)	br.cond.dpnt .map
@@ -176,7 +175,7 @@
 	;;
 	srlz.d
 	or r23=r25,r20			// construct PA | page properties
-	mov r25=KERNEL_PG_SHIFT<<2
+	mov r25=IA64_GRANULE_SHIFT<<2
 	;;
 	mov cr.itir=r25
 	mov cr.ifa=in0			// VA of next task...
diff -urN linux-davidm/arch/ia64/kernel/head.S lia64/arch/ia64/kernel/head.S
--- linux-davidm/arch/ia64/kernel/head.S	Mon Nov  5 21:43:07 2001
+++ lia64/arch/ia64/kernel/head.S	Mon Nov  5 21:06:50 2001
@@ -63,17 +63,17 @@
 	 * that maps the kernel's text and data:
 	 */
 	rsm psr.i | psr.ic
-	mov r16=((ia64_rid(IA64_REGION_ID_KERNEL, PAGE_OFFSET) << 8) | (KERNEL_PG_SHIFT << 2))
+	mov r16=((ia64_rid(IA64_REGION_ID_KERNEL, PAGE_OFFSET) << 8) | (IA64_GRANULE_SHIFT << 2))
 	;;
 	srlz.i
-	mov r18=KERNEL_PG_SHIFT<<2
-	movl r17=PAGE_OFFSET + KERNEL_PG_NUM*KERNEL_PG_SIZE
+	mov r18=KERNEL_TR_PAGE_SHIFT<<2
+	movl r17=KERNEL_START
 	;;
 	mov rr[r17]=r16
 	mov cr.itir=r18
 	mov cr.ifa=r17
 	mov r16=IA64_TR_KERNEL
-	movl r18=(KERNEL_PG_NUM*KERNEL_PG_SIZE | PAGE_KERNEL)
+	movl r18=((1 << KERNEL_TR_PAGE_SHIFT) | PAGE_KERNEL)
 	;;
 	srlz.i
 	;;
@@ -112,7 +112,7 @@
 	;;
 
 #ifdef CONFIG_IA64_EARLY_PRINTK
-	mov r3=(6<<8) | (KERNEL_PG_SHIFT<<2)
+	mov r3=(6<<8) | (IA64_GRANULE_SHIFT<<2)
 	movl r2=6<<61
 	;;
 	mov rr[r2]=r3
@@ -145,6 +145,7 @@
 	cmp4.ne isAP,isBP=r3,r0
 	;;			// RAW on r2
 	extr r3=r2,0,61		// r3 = phys addr of task struct
+	mov r16=KERNEL_TR_PAGE_NUM
 	;;
 
 	// load the "current" pointer (r13) and ar.k6 with the current task
@@ -152,7 +153,7 @@
 	mov IA64_KR(CURRENT)=r3		// Physical address
 
 	// initialize k4 to a safe value (64-128MB is mapped by TR_KERNEL)
-	mov IA64_KR(CURRENT_STACK)=1
+	mov IA64_KR(CURRENT_STACK)=r16
 	/*
 	 * Reserve space at the top of the stack for "struct pt_regs".  Kernel threads
 	 * don't store interesting values in that structure, but the space still needs
diff -urN linux-davidm/arch/ia64/kernel/ia64_ksyms.c lia64/arch/ia64/kernel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Mon Nov  5 21:43:07 2001
+++ lia64/arch/ia64/kernel/ia64_ksyms.c	Mon Nov  5 21:07:03 2001
@@ -69,6 +69,8 @@
 
 #include <asm/pgalloc.h>
 
+EXPORT_SYMBOL(flush_tlb_range);
+
 #ifdef CONFIG_SMP
 
 EXPORT_SYMBOL(smp_flush_tlb_all);
diff -urN linux-davidm/arch/ia64/kernel/mca.c lia64/arch/ia64/kernel/mca.c
--- linux-davidm/arch/ia64/kernel/mca.c	Mon Nov  5 21:43:07 2001
+++ lia64/arch/ia64/kernel/mca.c	Mon Nov  5 21:07:13 2001
@@ -1575,7 +1575,9 @@
 ia64_log_proc_dev_err_info_print (sal_log_processor_info_t  *slpi,
                                   prfunc_t                  prfunc)
 {
+#ifdef MCA_PRT_XTRA_DATA
 	size_t  d_len = slpi->header.len - sizeof(sal_log_section_hdr_t);
+#endif
 	sal_processor_static_info_t *spsi;
 	int                         i;
 	sal_log_mod_error_info_t    *p_data;
diff -urN linux-davidm/arch/ia64/lib/swiotlb.c lia64/arch/ia64/lib/swiotlb.c
--- linux-davidm/arch/ia64/lib/swiotlb.c	Tue Jul 31 10:30:08 2001
+++ lia64/arch/ia64/lib/swiotlb.c	Mon Nov  5 22:17:35 2001
@@ -398,7 +398,7 @@
 		BUG();
 
 	for (i = 0; i < nelems; i++, sg++) {
-		sg->orig_address = sg->address;
+		sg->page = sg->address;
 		if ((virt_to_phys(sg->address) & ~hwdev->dma_mask) != 0) {
 			sg->address = map_single(hwdev, sg->address, sg->length, direction);
 		}
@@ -419,9 +419,9 @@
 		BUG();
 
 	for (i = 0; i < nelems; i++, sg++)
-		if (sg->orig_address != sg->address) {
+		if (sg->page != sg->address) {
 			unmap_single(hwdev, sg->address, sg->length, direction);
-			sg->address = sg->orig_address;
+			sg->address = sg->page;
 		} else if (direction = PCI_DMA_FROMDEVICE)
 			mark_clean(sg->address, sg->length);
 }
@@ -442,7 +442,7 @@
 		BUG();
 
 	for (i = 0; i < nelems; i++, sg++)
-		if (sg->orig_address != sg->address)
+		if (sg->page != sg->address)
 			sync_single(hwdev, sg->address, sg->length, direction);
 }
 
diff -urN linux-davidm/arch/ia64/mm/init.c lia64/arch/ia64/mm/init.c
--- linux-davidm/arch/ia64/mm/init.c	Mon Nov  5 21:43:07 2001
+++ lia64/arch/ia64/mm/init.c	Mon Nov  5 21:07:35 2001
@@ -276,7 +276,7 @@
 	ia64_clear_ic(flags);
 
 	rid = ia64_rid(IA64_REGION_ID_KERNEL, __IA64_UNCACHED_OFFSET);
-	ia64_set_rr(__IA64_UNCACHED_OFFSET, (rid << 8) | (KERNEL_PG_SHIFT << 2));
+	ia64_set_rr(__IA64_UNCACHED_OFFSET, (rid << 8) | (IA64_GRANULE_SHIFT << 2));
 
 	rid = ia64_rid(IA64_REGION_ID_KERNEL, VMALLOC_START);
 	ia64_set_rr(VMALLOC_START, (rid << 8) | (PAGE_SHIFT << 2) | 1);
diff -urN linux-davidm/arch/ia64/mm/tlb.c lia64/arch/ia64/mm/tlb.c
--- linux-davidm/arch/ia64/mm/tlb.c	Mon Nov  5 21:43:07 2001
+++ lia64/arch/ia64/mm/tlb.c	Wed Oct 24 21:27:13 2001
@@ -79,7 +79,7 @@
 	flush_tlb_all();
 }
 
-static void
+static inline void
 ia64_global_tlb_purge (unsigned long start, unsigned long end, unsigned long nbits)
 {
 	static spinlock_t ptcg_lock = SPIN_LOCK_UNLOCKED;
diff -urN linux-davidm/drivers/acpi/hardware/hwacpi.c lia64/drivers/acpi/hardware/hwacpi.c
--- linux-davidm/drivers/acpi/hardware/hwacpi.c	Mon Nov  5 21:43:07 2001
+++ lia64/drivers/acpi/hardware/hwacpi.c	Mon Nov  5 21:08:40 2001
@@ -221,11 +221,14 @@
 
 	/* Give the platform some time to react */
 
-	acpi_os_stall (20000);
+	while (retries-- > 0) {
+		acpi_os_stall (20000);
 
-	if (acpi_hw_get_mode () = mode) {
-		ACPI_DEBUG_PRINT ((ACPI_DB_INFO, "Mode %X successfully enabled\n", mode));
-		status = AE_OK;
+		if (acpi_hw_get_mode () = mode) {
+			ACPI_DEBUG_PRINT ((ACPI_DB_INFO, "Mode %X successfully enabled\n", mode));
+			status = AE_OK;
+			break;
+		}
 	}
 
 	return_ACPI_STATUS (status);
diff -urN linux-davidm/drivers/acpi/include/acutils.h lia64/drivers/acpi/include/acutils.h
--- linux-davidm/drivers/acpi/include/acutils.h	Mon Nov  5 21:43:07 2001
+++ lia64/drivers/acpi/include/acutils.h	Mon Nov  5 21:08:49 2001
@@ -402,7 +402,7 @@
 acpi_status
 acpi_ut_execute_CID (
 	acpi_namespace_node     *device_node,
-	ACPI_DEVICE_ID          *cid);
+	acpi_device_id          *cid);
 
 acpi_status
 acpi_ut_execute_HID (
diff -urN linux-davidm/drivers/acpi/namespace/nsxfobj.c lia64/drivers/acpi/namespace/nsxfobj.c
--- linux-davidm/drivers/acpi/namespace/nsxfobj.c	Mon Nov  5 21:43:07 2001
+++ lia64/drivers/acpi/namespace/nsxfobj.c	Mon Nov  5 21:08:57 2001
@@ -548,6 +548,7 @@
 	acpi_namespace_node     *node;
 	u32                     flags;
 	acpi_device_id          device_id;
+	acpi_device_id          compatible_id;
 	acpi_get_devices_info   *info;
 
 
diff -urN linux-davidm/drivers/acpi/utilities/uteval.c lia64/drivers/acpi/utilities/uteval.c
--- linux-davidm/drivers/acpi/utilities/uteval.c	Mon Nov  5 21:43:07 2001
+++ lia64/drivers/acpi/utilities/uteval.c	Mon Nov  5 21:09:07 2001
@@ -132,7 +132,7 @@
 acpi_status
 acpi_ut_execute_CID (
 	acpi_namespace_node     *device_node,
-	ACPI_DEVICE_ID          *cid)
+	acpi_device_id          *cid)
 {
 	acpi_operand_object     *obj_desc;
 	acpi_status             status;
diff -urN linux-davidm/drivers/block/loop.c lia64/drivers/block/loop.c
--- linux-davidm/drivers/block/loop.c	Mon Nov  5 18:28:46 2001
+++ lia64/drivers/block/loop.c	Mon Nov  5 21:09:16 2001
@@ -207,7 +207,6 @@
 		index++;
 		pos += size;
 		UnlockPage(page);
-		deactivate_page(page);
 		page_cache_release(page);
 	}
 	return 0;
@@ -218,7 +217,6 @@
 	kunmap(page);
 unlock:
 	UnlockPage(page);
-	deactivate_page(page);
 	page_cache_release(page);
 fail:
 	return -1;
diff -urN linux-davidm/drivers/char/Config.in lia64/drivers/char/Config.in
--- linux-davidm/drivers/char/Config.in	Mon Nov  5 21:43:07 2001
+++ lia64/drivers/char/Config.in	Mon Nov  5 21:09:27 2001
@@ -16,6 +16,9 @@
       tristate '   Dual serial port support' CONFIG_DUALSP_SERIAL
    fi
 fi
+if [ "$CONFIG_ACPI" = "y" ]; then
+   bool '  Support for serial ports defined by ACPI tables' CONFIG_SERIAL_ACPI
+fi
 dep_mbool 'Extended dumb serial driver options' CONFIG_SERIAL_EXTENDED $CONFIG_SERIAL
 if [ "$CONFIG_SERIAL_EXTENDED" = "y" ]; then
    bool '  Support more than 4 serial ports' CONFIG_SERIAL_MANY_PORTS
diff -urN linux-davidm/drivers/char/Makefile lia64/drivers/char/Makefile
--- linux-davidm/drivers/char/Makefile	Mon Nov  5 21:43:07 2001
+++ lia64/drivers/char/Makefile	Mon Nov  5 21:09:36 2001
@@ -126,6 +126,7 @@
 
 obj-$(CONFIG_VT) += vt.o vc_screen.o consolemap.o consolemap_deftbl.o $(CONSOLE) selection.o
 obj-$(CONFIG_SERIAL) += $(SERIAL)
+obj-$(CONFIG_SERIAL_ACPI) += acpi_serial.o
 obj-$(CONFIG_SERIAL_21285) += serial_21285.o
 obj-$(CONFIG_SERIAL_SA1100) += serial_sa1100.o
 obj-$(CONFIG_SERIAL_AMBA) += serial_amba.o
diff -urN linux-davidm/drivers/char/acpi_serial.c lia64/drivers/char/acpi_serial.c
--- linux-davidm/drivers/char/acpi_serial.c	Wed Dec 31 16:00:00 1969
+++ lia64/drivers/char/acpi_serial.c	Mon Nov  5 21:09:45 2001
@@ -0,0 +1,194 @@
+/*
+ *  linux/drivers/char/acpi_serial.c
+ *
+ *  Copyright (C) 2000  Hewlett-Packard Co.
+ *  Copyright (C) 2000  Khalid Aziz <khalid_aziz@hp.com>
+ *
+ *  Detect and initialize the headless console serial port defined in 
+ *  SPCR table and debug serial port defined in DBGP table
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/pci.h>
+#include <linux/pm.h>
+#include <linux/acpi.h>
+#include <linux/init.h>
+#include <linux/serial.h>
+#include <asm/serial.h>
+#include <asm/io.h>
+#include <linux/acpi_serial.h>
+/*#include <asm/acpi-ext.h>*/
+
+#undef SERIAL_DEBUG_ACPI
+
+/*
+ * Query ACPI tables for a debug and a headless console serial
+ * port. If found, add them to rs_table[]. A pointer to either SPCR
+ * or DBGP table is passed as parameter. This function should be called 
+ * before serial_console_init() is called to make sure the SPCR serial 
+ * console will be available for use. IA-64 kernel calls this function
+ * from within acpi.c when it encounters SPCR or DBGP tables as it parses 
+ * the ACPI 2.0 tables during bootup.
+ *
+ */
+void __init setup_serial_acpi(void *tablep) 
+{
+	acpi_ser_t *acpi_ser_p;
+	struct serial_struct serial_req;
+	unsigned long iobase;
+	int global_sys_irq;
+
+#ifdef SERIAL_DEBUG_ACPI
+	printk("Entering setup_serial_acpi()\n");
+#endif
+
+	/* Now get the table */
+	if (tablep = NULL) {
+		return;
+	}
+
+	acpi_ser_p = (acpi_ser_t *)tablep;
+
+	/*
+	 * Perform a sanity check on the table. Table should have a 
+	 * signature of "SPCR" or "DBGP" and it should be atleast 52 bytes
+	 * long.
+	 */
+	if ((strncmp(acpi_ser_p->signature, ACPI_SPCRT_SIGNATURE, 
+					ACPI_SIG_LEN) != 0) && 
+		(strncmp(acpi_ser_p->signature, ACPI_DBGPT_SIGNATURE, 
+					ACPI_SIG_LEN) != 0)) {
+		return;
+	}
+	if (acpi_ser_p->length < 52) {
+		return;
+	}
+
+	iobase = (((u64) acpi_ser_p->base_addr.addrh) << 32) | acpi_ser_p->base_addr.addrl;
+	global_sys_irq = (acpi_ser_p->global_int[3] << 24) | 
+			(acpi_ser_p->global_int[2] << 16) |
+			(acpi_ser_p->global_int[1] << 8) |
+			acpi_ser_p->global_int[0];
+
+#ifdef SERIAL_DEBUG_ACPI
+	printk("setup_serial_acpi(): table pointer = 0x%p\n", acpi_ser_p);
+	printk("                     sig = '%c%c%c%c'\n",
+			acpi_ser_p->signature[0],
+			acpi_ser_p->signature[1],
+			acpi_ser_p->signature[2],
+			acpi_ser_p->signature[3]);
+	printk("                     length = %d\n", acpi_ser_p->length);
+	printk("                     Rev = %d\n", acpi_ser_p->rev);
+	printk("                     Interface type = %d\n", acpi_ser_p->intfc_type);
+	printk("                     Base address = 0x%lX\n", iobase);
+	printk("                     IRQ = %d\n", acpi_ser_p->irq);
+	printk("                     Global System Int = %d\n", global_sys_irq);
+	printk("                     Baud rate = ");
+	switch (acpi_ser_p->baud) {
+		case ACPI_SERIAL_BAUD_9600:
+			printk("9600\n");
+			break;
+
+		case ACPI_SERIAL_BAUD_19200:
+			printk("19200\n");
+			break;
+
+		case ACPI_SERIAL_BAUD_57600:
+			printk("57600\n");
+			break;
+
+		case ACPI_SERIAL_BAUD_115200:
+			printk("115200\n");
+			break;
+
+		default:
+			printk("Huh (%d)\n", acpi_ser_p->baud);
+			break;
+
+	}
+	if (acpi_ser_p->base_addr.space_id = ACPI_SERIAL_PCICONF_SPACE) {
+		printk("                     PCI serial port:\n");
+		printk("                         Bus %d, Device %d, Vendor ID 0x%x, Dev ID 0x%x\n",
+		acpi_ser_p->pci_bus, acpi_ser_p->pci_dev,
+		acpi_ser_p->pci_vendor_id, acpi_ser_p->pci_dev_id);
+	}
+#endif
+
+	/* 
+	 * Now build a serial_req structure to update the entry in
+	 * rs_table for the headless console port.
+	 */
+	switch (acpi_ser_p->intfc_type) {
+ 		case ACPI_SERIAL_INTFC_16550:
+			serial_req.type = PORT_16550;
+			serial_req.baud_base = BASE_BAUD;
+			break;
+
+ 		case ACPI_SERIAL_INTFC_16450:
+			serial_req.type = PORT_16450;
+			serial_req.baud_base = BASE_BAUD;
+			break;
+
+		default:
+			serial_req.type = PORT_UNKNOWN;
+			break;
+	}
+	if (strncmp(acpi_ser_p->signature, ACPI_SPCRT_SIGNATURE,
+					ACPI_SIG_LEN) = 0) {
+		serial_req.line = ACPI_SERIAL_CONSOLE_PORT;
+	}
+	else if (strncmp(acpi_ser_p->signature, ACPI_DBGPT_SIGNATURE, 
+					ACPI_SIG_LEN) = 0) {
+		serial_req.line = ACPI_SERIAL_DEBUG_PORT;
+	}
+	/*
+	 * Check if this is an I/O mapped address or a memory mapped address
+	 */
+	if (acpi_ser_p->base_addr.space_id = ACPI_SERIAL_MEM_SPACE) {
+		serial_req.port = 0;
+		serial_req.port_high = 0;
+		serial_req.iomem_base = (void *)ioremap(iobase, 64);
+		serial_req.io_type = SERIAL_IO_MEM;
+	}
+	else if (acpi_ser_p->base_addr.space_id = ACPI_SERIAL_IO_SPACE) {
+		serial_req.port = (unsigned long) iobase & 0xffffffff;
+		serial_req.port_high = (unsigned long)(((u64)iobase) >> 32);
+		serial_req.iomem_base = NULL;
+		serial_req.io_type = SERIAL_IO_PORT;
+	}
+	else if (acpi_ser_p->base_addr.space_id = ACPI_SERIAL_PCICONF_SPACE) {
+		printk("WARNING: No support for PCI serial console\n");
+		return;
+	}
+
+	/*
+	 * If the table does not have IRQ information, use 0 for IRQ. 
+	 * This will force rs_init() to probe for IRQ. 
+	 */
+	if (acpi_ser_p->length < 53) {
+		serial_req.irq = 0;
+	}
+	else {
+		if (acpi_ser_p->int_type & 
+			(ACPI_SERIAL_INT_APIC | ACPI_SERIAL_INT_SAPIC)) {
+			serial_req.irq = global_sys_irq;
+		}
+		else if (acpi_ser_p->int_type & ACPI_SERIAL_INT_PCAT) {
+			serial_req.irq = acpi_ser_p->irq;
+		}
+	}
+
+	serial_req.flags = ASYNC_SKIP_TEST | ASYNC_BOOT_AUTOCONF | ASYNC_AUTO_IRQ;
+	serial_req.xmit_fifo_size = serial_req.custom_divisor = 0;
+	serial_req.close_delay = serial_req.hub6 = serial_req.closing_wait = 0;
+	serial_req.iomem_reg_shift = 0;
+	if (early_serial_setup(&serial_req) < 0) {
+		printk("early_serial_setup() for ACPI serial console port failed\n");
+		return;
+	}
+
+#ifdef SERIAL_DEBUG_ACPI
+	printk("Leaving setup_serial_acpi()\n");
+#endif
+}
diff -urN linux-davidm/drivers/char/serial.c lia64/drivers/char/serial.c
--- linux-davidm/drivers/char/serial.c	Mon Nov  5 18:28:47 2001
+++ lia64/drivers/char/serial.c	Mon Nov  5 21:11:43 2001
@@ -85,6 +85,11 @@
  * SERIAL_PARANOIA_CHECK
  * 		Check the magic number for the async_structure where
  * 		ever possible.
+ *
+ * CONFIG_SERIAL_ACPI
+ *		Enable support for serial console port and serial 
+ *		debug port as defined by the SPCR and DBGP tables in 
+ *		ACPI 2.0.
  */
 
 #include <linux/config.h>
@@ -113,6 +118,10 @@
 #endif
 #endif
 
+#ifdef CONFIG_SERIAL_ACPI
+#define ENABLE_SERIAL_ACPI
+#endif
+
 #if defined(CONFIG_ISAPNP)|| (defined(CONFIG_ISAPNP_MODULE) && defined(MODULE))
 #ifndef ENABLE_SERIAL_PNP
 #define ENABLE_SERIAL_PNP
@@ -2355,7 +2364,7 @@
 
 	autoconfig(info->state);
 	if ((info->state->flags & ASYNC_AUTO_IRQ) &&
-	    (info->state->port != 0) &&
+	    (info->state->port != 0  || info->state->iomem_base != 0) &&
 	    (info->state->type != PORT_UNKNOWN)) {
 		irq = detect_uart_irq(info->state);
 		if (irq > 0)
@@ -3384,6 +3393,10 @@
        " ISAPNP"
 #define SERIAL_OPT
 #endif
+#ifdef ENABLE_SERIAL_ACPI
+       " SERIAL_ACPI"
+#define SERIAL_OPT
+#endif
 #ifdef SERIAL_OPT
        " enabled\n";
 #else
@@ -5475,13 +5488,22 @@
 			continue;
 		if (   (state->flags & ASYNC_BOOT_AUTOCONF)
 		    && (state->flags & ASYNC_AUTO_IRQ)
-		    && (state->port != 0))
+		    && (state->port != 0 || state->iomem_base != 0))
 			state->irq = detect_uart_irq(state);
-		printk(KERN_INFO "ttyS%02d%s at 0x%04lx (irq = %d) is a %s\n",
-		       state->line + SERIAL_DEV_OFFSET,
-		       (state->flags & ASYNC_FOURPORT) ? " FourPort" : "",
-		       state->port, state->irq,
-		       uart_config[state->type].name);
+		if (state->io_type = SERIAL_IO_MEM) {
+			printk(KERN_INFO"ttyS%02d%s at 0x%px (irq = %d) is a %s\n",
+	 		       state->line + SERIAL_DEV_OFFSET,
+			       (state->flags & ASYNC_FOURPORT) ? " FourPort" : "",
+			       state->iomem_base, state->irq,
+			       uart_config[state->type].name);
+		}
+		else {
+			printk(KERN_INFO "ttyS%02d%s at 0x%04lx (irq = %d) is a %s\n",
+	 		       state->line + SERIAL_DEV_OFFSET,
+			       (state->flags & ASYNC_FOURPORT) ? " FourPort" : "",
+			       state->port, state->irq,
+			       uart_config[state->type].name);
+		}
 		tty_register_devfs(&serial_driver, 0,
 				   serial_driver.minor_start + state->line);
 		tty_register_devfs(&callout_driver, 0,
diff -urN linux-davidm/drivers/scsi/scsi_merge.c lia64/drivers/scsi/scsi_merge.c
--- linux-davidm/drivers/scsi/scsi_merge.c	Mon Nov  5 18:29:00 2001
+++ lia64/drivers/scsi/scsi_merge.c	Mon Nov  5 22:18:02 2001
@@ -942,6 +942,7 @@
 			}
 		}
 		count++;
+		memset(sgpnt + count - 1, 0, sizeof(*sgpnt));
 		sgpnt[count - 1].address = bh->b_data;
 		sgpnt[count - 1].page = NULL;
 		sgpnt[count - 1].length += bh->b_size;
diff -urN linux-davidm/drivers/video/fbmem.c lia64/drivers/video/fbmem.c
--- linux-davidm/drivers/video/fbmem.c	Wed Oct 24 10:17:32 2001
+++ lia64/drivers/video/fbmem.c	Mon Nov  5 21:12:42 2001
@@ -609,6 +609,8 @@
 	vma->vm_flags |= VM_IO;
 #elif defined(__sh__)
 	pgprot_val(vma->vm_page_prot) &= ~_PAGE_CACHABLE;
+#elif defined(__ia64__)
+	vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
 #else
 #warning What do we have to do here??
 #endif
diff -urN linux-davidm/include/asm-ia64/io.h lia64/include/asm-ia64/io.h
--- linux-davidm/include/asm-ia64/io.h	Mon Nov  5 21:43:09 2001
+++ lia64/include/asm-ia64/io.h	Mon Nov  5 21:37:14 2001
@@ -14,7 +14,7 @@
  * mistake somewhere.
  *
  * Copyright (C) 1998-2001 Hewlett-Packard Co
- * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999 Asit Mallick <asit.k.mallick@intel.com>
  * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
  */
@@ -25,7 +25,12 @@
 
 #define __IA64_UNCACHED_OFFSET	0xc000000000000000	/* region 6 */
 
-#define IO_SPACE_LIMIT 0xffff
+/*
+ * The legacy I/O space defined by the ia64 architecture supports only 65536 ports, but
+ * large machines may have multiple other I/O spaces so we can't place any a priori limit
+ * on IO_SPACE_LIMIT.  These additional spaces are described in ACPI.
+ */
+#define IO_SPACE_LIMIT		0xffffffffffffffffUL
 
 # ifdef __KERNEL__
 
diff -urN linux-davidm/include/asm-ia64/pci.h lia64/include/asm-ia64/pci.h
--- linux-davidm/include/asm-ia64/pci.h	Mon Nov  5 21:43:09 2001
+++ lia64/include/asm-ia64/pci.h	Mon Nov  5 22:18:23 2001
@@ -60,7 +60,7 @@
 #define pci_map_page(dev,pg,off,size,dir)				\
 	pci_map_single((dev), page_address(pg) + (off), (size), (dir))
 #define pci_unmap_page(dev,dma_addr,size,dir)				\
-	pci_unmap_single((dev), (dma_addr), (size), (dir)
+	pci_unmap_single((dev), (dma_addr), (size), (dir))
 
 /* The ia64 platform always supports 64-bit addressing. */
 #define pci_dac_dma_supported(pci_dev, mask)	(1)
diff -urN linux-davidm/include/asm-ia64/pgtable.h lia64/include/asm-ia64/pgtable.h
--- linux-davidm/include/asm-ia64/pgtable.h	Tue Jul 31 10:30:09 2001
+++ lia64/include/asm-ia64/pgtable.h	Mon Nov  5 21:37:16 2001
@@ -9,7 +9,7 @@
  * in <asm/page.h> (currently 8192).
  *
  * Copyright (C) 1998-2001 Hewlett-Packard Co
- * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
 #include <linux/config.h>
@@ -466,11 +466,21 @@
 # endif /* !__ASSEMBLY__ */
 
 /*
- * Identity-mapped regions use a large page size.  KERNEL_PG_NUM is the
- * number of the (large) page frame that mapps the kernel.
+ * Identity-mapped regions use a large page size.  We'll call such large pages
+ * "granules".  If you can think of a better name that's unambiguous, let me
+ * know...
+ */
+#if defined(CONFIG_IA64_GRANULE_64MB)
+# define IA64_GRANULE_SHIFT	_PAGE_SIZE_64M
+#elif defined(CONFIG_IA64_GRANULE_16MB)
+# define IA64_GRANULE_SHIFT	_PAGE_SIZE_16M
+#endif
+#define IA64_GRANULE_SIZE	(1 << IA64_GRANULE_SHIFT)
+/*
+ * log2() of the page size we use to map the kernel image (IA64_TR_KERNEL):
  */
-#define KERNEL_PG_SHIFT		_PAGE_SIZE_64M
-#define KERNEL_PG_SIZE		(1 << KERNEL_PG_SHIFT)
-#define KERNEL_PG_NUM		((KERNEL_START - PAGE_OFFSET) / KERNEL_PG_SIZE)
+#define KERNEL_TR_PAGE_SHIFT	_PAGE_SIZE_64M
+#define KERNEL_TR_PAGE_SIZE	(1 << KERNEL_TR_PAGE_SHIFT)
+#define KERNEL_TR_PAGE_NUM	((KERNEL_START - PAGE_OFFSET) / KERNEL_TR_PAGE_SIZE)
 
 #endif /* _ASM_IA64_PGTABLE_H */
diff -urN linux-davidm/include/asm-ia64/scatterlist.h lia64/include/asm-ia64/scatterlist.h
--- linux-davidm/include/asm-ia64/scatterlist.h	Wed Oct 24 10:18:00 2001
+++ lia64/include/asm-ia64/scatterlist.h	Mon Nov  5 22:17:49 2001
@@ -2,13 +2,13 @@
 #define _ASM_IA64_SCATTERLIST_H
 
 /*
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998, 1999, 2001 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
 struct scatterlist {
 	char *address;		/* location data is to be transferred to */
-	char *orig_address;	/* Save away the original buffer address (used by pci-dma.c) */
+	void *page;		/* stupid: SCSI code insists on a member of this name... */
 	unsigned int length;	/* buffer length */
 };
 
diff -urN linux-davidm/include/linux/acpi_serial.h lia64/include/linux/acpi_serial.h
--- linux-davidm/include/linux/acpi_serial.h	Wed Dec 31 16:00:00 1969
+++ lia64/include/linux/acpi_serial.h	Mon Nov  5 21:14:00 2001
@@ -0,0 +1,103 @@
+/*
+ *  linux/include/linux/acpi_serial.h
+ *
+ *  Copyright (C) 2000  Hewlett-Packard Co.
+ *  Copyright (C) 2000  Khalid Aziz <khalid_aziz@hp.com>
+ *
+ *  Definitions for ACPI defined serial ports (headless console and 
+ *  debug ports)
+ *
+ */
+
+extern void setup_serial_acpi(void *);
+
+/* ACPI table signatures */
+#define ACPI_SPCRT_SIGNATURE	"SPCR"
+#define ACPI_DBGPT_SIGNATURE	"DBGP"
+
+/* Interface type as defined in ACPI serial port tables */
+#define ACPI_SERIAL_INTFC_16550	0
+#define ACPI_SERIAL_INTFC_16450	1
+
+/* Interrupt types for ACPI serial port tables */
+#define ACPI_SERIAL_INT_PCAT	0x01
+#define ACPI_SERIAL_INT_APIC	0x02
+#define ACPI_SERIAL_INT_SAPIC	0x04
+
+/* Baud rates as defined in ACPI serial port tables */
+#define ACPI_SERIAL_BAUD_9600		3
+#define ACPI_SERIAL_BAUD_19200		4
+#define ACPI_SERIAL_BAUD_57600		6
+#define ACPI_SERIAL_BAUD_115200		7
+
+/* Parity as defined in ACPI serial port tables */
+#define ACPI_SERIAL_PARITY_NONE		0
+
+/* Flow control methods as defined in ACPI serial port tables */
+#define ACPI_SERIAL_FLOW_DCD	0x01
+#define ACPI_SERIAL_FLOW_RTS	0x02
+#define ACPI_SERIAL_FLOW_XON	0x04
+
+/* Terminal types as defined in ACPI serial port tables */
+#define ACPI_SERIAL_TERM_VT100		0
+#define ACPI_SERIAL_TERM_VT100X	1
+
+/* PCI Flags as defined by SPCR table */
+#define ACPI_SERIAL_PCIFLAG_PNP	0x00000001
+
+/* Space ID as defined in base address structure in ACPI serial port tables */
+#define ACPI_SERIAL_MEM_SPACE		0
+#define ACPI_SERIAL_IO_SPACE		1
+#define ACPI_SERIAL_PCICONF_SPACE	2
+
+/* 
+ * Generic Register Address Structure - as defined by Microsoft 
+ * in http://www.microsoft.com/hwdev/onnow/download/LFreeACPI.doc
+ *
+*/
+typedef struct {
+	u8  space_id;
+	u8  bit_width;
+	u8  bit_offset;
+	u8  resv;
+	u32 addrl;
+	u32 addrh;
+} gen_regaddr;
+
+/* Space ID for generic register address structure */
+#define REGADDR_SPACE_SYSMEM	0
+#define REGADDR_SPACE_SYSIO	1
+#define REGADDR_SPACE_PCICONFIG	2
+
+/* Serial Port Console Redirection and Debug Port Table formats */
+typedef struct {
+	u8 signature[4];
+	u32 length;
+	u8  rev;
+	u8  chksum;
+	u8  oemid[6];
+	u8  oem_tabid[8];
+	u32 oem_rev;
+	u8  creator_id[4];
+	u32 creator_rev;
+	u8  intfc_type;
+	u8  resv1[3];
+	gen_regaddr base_addr;
+	u8  int_type;
+	u8  irq;
+	u8  global_int[4];
+	u8  baud;
+	u8  parity;
+	u8  stop_bits;
+	u8  flow_ctrl;
+	u8  termtype;
+	u8  language;
+	u16 pci_dev_id;
+	u16 pci_vendor_id;
+	u8  pci_bus;
+	u8  pci_dev;
+	u8  pci_func;
+	u8  pci_flags[4];
+	u8  pci_seg;
+	u32 resv2;
+} acpi_ser_t;
diff -urN linux-davidm/include/linux/serial.h lia64/include/linux/serial.h
--- linux-davidm/include/linux/serial.h	Fri Aug 10 18:13:47 2001
+++ lia64/include/linux/serial.h	Mon Nov  5 21:37:52 2001
@@ -182,5 +182,11 @@
 /* Allow complicated architectures to specify rs_table[] at run time */
 extern int early_serial_setup(struct serial_struct *req);
 
+#ifdef CONFIG_ACPI
+/* tty ports reserved for the ACPI serial console port and debug port */
+#define ACPI_SERIAL_CONSOLE_PORT        4
+#define ACPI_SERIAL_DEBUG_PORT          5
+#endif
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SERIAL_H */
diff -urN linux-davidm/kernel/printk.c lia64/kernel/printk.c
--- linux-davidm/kernel/printk.c	Mon Nov  5 21:43:09 2001
+++ lia64/kernel/printk.c	Mon Nov  5 21:16:22 2001
@@ -25,11 +25,10 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/interrupt.h>			/* For in_interrupt() */
-#include <linux/config.h>
 
 #include <asm/uaccess.h>
 
-#ifdef CONFIG_MULTIQUAD
+#if defined(CONFIG_MULTIQUAD) || defined(CONFIG_IA64)
 #define LOG_BUF_LEN	(65536)
 #elif defined(CONFIG_SMP)
 #define LOG_BUF_LEN	(32768)
diff -urN linux-davidm/mm/memory.c lia64/mm/memory.c
--- linux-davidm/mm/memory.c	Mon Nov  5 21:43:09 2001
+++ lia64/mm/memory.c	Mon Nov  5 21:16:33 2001
@@ -1338,7 +1338,7 @@
 	if (pmd) {
 		pte_t * pte = pte_alloc(mm, pmd, address);
 		if (pte)
-			return handle_pte_fault(mm, vma, address, write_access, pte);
+			return handle_pte_fault(mm, vma, address, access_type, pte);
 	}
 	spin_unlock(&mm->page_table_lock);
 	return -1;

