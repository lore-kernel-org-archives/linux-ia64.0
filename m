From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 10 Apr 2002 21:42:02 +0000
Subject: [Linux-ia64] new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905427@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The latest ia64 patch relative to 2.4.18 is now available
at ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/
in file:

	linux-2.4.18-ia64-020410.diff.gz

Changelog is below, along with an approximate diff compared to the
last version (except for the changes to drivers/acpi, which are big).

I hope I didn't forget or misattribute any patches.

Enjoy,

	--david


	o Big ACPI update (Paul Diefenbaugh)
	o Added support for HP's zx1 McKinley platform (Alex Williamson,
	  Bjorn Helgaas, et al).
	o Fix GENERIC build (Bjorn Helgaas)
	o Fix GCC version-detection for cross-compilation (Gary Hade)
	o Make loopback device and ram disk support available for HP Ski
	  simulator (Peter Chubb)
	o Correct IA-32 Loacked Data reference fault from 3 to 4
	  (NOMURA, Jun'ichi)
	o Update efivars from v0.04 to v0.05 (Matt Domsch)
	o Tune stacked-register clearing loop for McKinley.
	o Make __ia64_init_fpu() both smaller and faster.
	o Tweak memset() to call __bzero() if we can determine at compile time
	  that the value is zero.
	o Update perfmon to latest version (Stephane Eranian).
	o Fix ia64_iobase initialization on APs (Bjorn Helgaas), clean up code
	  to use ioremap() (me).
	o Fix VGA legacy initialization (Bjorn Helgaas, Alex Williamson).
	o Fix bug which prevent mmap() at the very end of the
	  page-table-mapped space. Bug reported by Peter A. Buhr.
	o Consolidate exception handling with SEARCH_EXCEPTION_TABLE() macro
	  (Keith Owens).
	o McKinley-tuned clear_page() (Ken Chen)
	o McKinley-tuned copy_page().
	o Fix softare I/O TLB to return <4GB addresses for coherent buffers
	  (reported by Dave Miller).
	o AGP/DRM cleanup (Bjorn Helgaas)
	o Make PC keyboard handle graciously the case where no legacy keyboard
	  exists (Alex Williamson, I think)
	o EFI update and clean up (Matt Domsch)
	o Don't fail on kernel modules with no unwind data (Andreas Schwab)
	o Add back flush_icache_page() for easier compatibility with vanilla
	  2.4 kernel.
	o Drop include/linux/crc32.h and lib/crc32.c (suggested by
	  Matt Domsch).

diff -urN linux-davidm/Documentation/Configure.help lia64-2.4/Documentation=
/Configure.help
--- linux-davidm/Documentation/Configure.help	Wed Apr 10 13:24:24 2002
+++ lia64-2.4/Documentation/Configure.help	Fri Apr  5 16:44:44 2002
@@ -14978,24 +14978,6 @@
   were partitioned using EFI GPT.  Presently only useful on the
   IA-64 platform.
=20
-/dev/guid support (EXPERIMENTAL)
-CONFIG_DEVFS_GUID
-  Say Y here if you would like to access disks and partitions by
-  their Globally Unique Identifiers (GUIDs) which will appear as
-  symbolic links in /dev/guid.
-
-Intel EFI GUID partition support
-CONFIG_EFI_PARTITION
-  Say Y here if you would like to use hard disks under Linux which
-  were partitioned using EFI GPT.  Presently only useful on the
-  IA-64 platform.
-
-/dev/guid support (EXPERIMENTAL)
-CONFIG_DEVFS_GUID
-  Say Y here if you would like to access disks and partitions by
-  their Globally Unique Identifiers (GUIDs) which will appear as
-  symbolic links in /dev/guid.
-
 Ultrix partition table support
 CONFIG_ULTRIX_PARTITION
   Say Y here if you would like to be able to read the hard disk
@@ -23805,12 +23787,18 @@
=20
   HP-simulator   For the HP simulator
                  (<http://software.hp.com/ia64linux/>).
+  HP-zx1         For HP zx1 Platforms.
   SN1            For SGI SN1 Platforms.
   SN2            For SGI SN2 Platforms.
   DIG-compliant  For DIG ("Developer's Interface Guide") compliant
-                 system.
+                 systems.
=20
   If you don't know what to do, choose "generic".
+
+CONFIG_IA64_HP_ZX1
+  Build a kernel that runs on HP zx1-based systems.  This adds support
+  for the zx1 IOMMU and makes root bus bridges appear in PCI config space
+  (required for zx1 agpgart support).
=20
 CONFIG_IA64_SGI_SN_SIM
   Build a kernel that runs on both the SGI simulator AND on hardware.
diff -urN linux-davidm/Makefile lia64-2.4/Makefile
--- linux-davidm/Makefile	Tue Feb 26 11:03:51 2002
+++ lia64-2.4/Makefile	Fri Apr  5 20:31:50 2002
@@ -88,7 +88,7 @@
=20
 CPPFLAGS :=3D -D__KERNEL__ -I$(HPATH)
=20
-CFLAGS :=3D $(CPPFLAGS) -Wall -Wstrict-prototypes -Wno-trigraphs -O2 \
+CFLAGS :=3D $(CPPFLAGS) -Wall -Wstrict-prototypes -Wno-trigraphs -g -O2 \
 	  -fomit-frame-pointer -fno-strict-aliasing -fno-common
 AFLAGS :=3D -D__ASSEMBLY__ $(CPPFLAGS)
=20
diff -urN linux-davidm/arch/ia64/Makefile lia64-2.4/arch/ia64/Makefile
--- linux-davidm/arch/ia64/Makefile	Wed Apr 10 13:24:24 2002
+++ lia64-2.4/arch/ia64/Makefile	Sat Apr  6 00:29:08 2002
@@ -22,7 +22,7 @@
 # -ffunction-sections
 CFLAGS_KERNEL :=3D -mconstant-gp
=20
-GCC_VERSION=3D$(shell $(CROSS_COMPILE)$(HOSTCC) -v 2>&1 | fgrep 'gcc versi=
on' | cut -f3 -d' ' | cut -f1 -d'.')
+GCC_VERSION=3D$(shell $(CC) -v 2>&1 | fgrep 'gcc version' | cut -f3 -d' ' =
| cut -f1 -d'.')
=20
 ifneq ($(GCC_VERSION),2)
 	CFLAGS +=3D -frename-registers --param max-inline-insns 00
@@ -33,16 +33,11 @@
 endif
=20
 ifdef CONFIG_IA64_GENERIC
-	CORE_FILES      :=3D      arch/$(ARCH)/hp/hp.a	\
-				arch/$(ARCH)/sn/sn.o	\
-				arch/$(ARCH)/dig/dig.a	\
-				arch/$(ARCH)/sn/io/sgiio.o \
+	CORE_FILES      :=3D      arch/$(ARCH)/hp/hp.o			\
+				arch/$(ARCH)/dig/dig.a			\
 				$(CORE_FILES)
 	SUBDIRS		:=3D	arch/$(ARCH)/hp		\
-				arch/$(ARCH)/sn/sn1	\
-				arch/$(ARCH)/sn		\
 				arch/$(ARCH)/dig	\
-				arch/$(ARCH)/sn/io	\
 				$(SUBDIRS)
=20
 else # !GENERIC
@@ -50,7 +45,16 @@
 ifdef CONFIG_IA64_HP_SIM
         SUBDIRS         :=3D      arch/$(ARCH)/hp		\
                                 $(SUBDIRS)
-        CORE_FILES      :=3D      arch/$(ARCH)/hp/hp.a	\
+        CORE_FILES      :=3D      arch/$(ARCH)/hp/hp.o	\
+                                $(CORE_FILES)
+endif
+
+ifdef CONFIG_IA64_HP_ZX1
+        SUBDIRS         :=3D      arch/$(ARCH)/hp				\
+				arch/$(ARCH)/dig			\
+                                $(SUBDIRS)
+        CORE_FILES      :=3D      arch/$(ARCH)/hp/hp.o			\
+				arch/$(ARCH)/dig/dig.a			\
                                 $(CORE_FILES)
 endif
=20
diff -urN linux-davidm/arch/ia64/config.in lia64-2.4/arch/ia64/config.in
--- linux-davidm/arch/ia64/config.in	Wed Apr 10 13:24:24 2002
+++ lia64-2.4/arch/ia64/config.in	Fri Apr  5 16:49:19 2002
@@ -41,6 +41,7 @@
 	"generic		CONFIG_IA64_GENERIC		\
 	 DIG-compliant		CONFIG_IA64_DIG			\
 	 HP-simulator		CONFIG_IA64_HP_SIM		\
+	 HP-zx1			CONFIG_IA64_HP_ZX1		\
 	 SGI-SN1		CONFIG_IA64_SGI_SN1		\
 	 SGI-SN2		CONFIG_IA64_SGI_SN2" generic
=20
@@ -68,7 +69,8 @@
 	fi
 fi
=20
-if [ "$CONFIG_IA64_DIG" =3D "y" ]; then
+if [ "$CONFIG_IA64_GENERIC" =3D "y" ] || [ "$CONFIG_IA64_DIG" =3D "y" ] \
+   || [ "$CONFIG_IA64_HP_ZX1" =3D "y" ]; then
 	bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
 	define_bool CONFIG_PM y
 fi
@@ -152,6 +154,17 @@
 fi
 endmenu
=20
+else # ! HP_SIM
+mainmenu_option next_comment
+comment 'Block devices'
+tristate 'Loopback device support' CONFIG_BLK_DEV_LOOP
+dep_tristate 'Network block device support' CONFIG_BLK_DEV_NBD $CONFIG_NET
+
+tristate 'RAM disk support' CONFIG_BLK_DEV_RAM
+if [ "$CONFIG_BLK_DEV_RAM" =3D "y" -o "$CONFIG_BLK_DEV_RAM" =3D "m" ]; then
+   int '  Default RAM disk size' CONFIG_BLK_DEV_RAM_SIZE 4096
+fi
+endmenu
 fi # !HP_SIM
=20
 mainmenu_option next_comment
diff -urN linux-davidm/arch/ia64/defconfig lia64-2.4/arch/ia64/defconfig
--- linux-davidm/arch/ia64/defconfig	Wed Apr 10 13:24:24 2002
+++ lia64-2.4/arch/ia64/defconfig	Thu Mar 28 16:11:08 2002
@@ -672,7 +672,6 @@
 # CONFIG_SOLARIS_X86_PARTITION is not set
 # CONFIG_UNIXWARE_DISKLABEL is not set
 CONFIG_EFI_PARTITION=3Dy
-# CONFIG_DEVFS_GUID is not set
 # CONFIG_LDM_PARTITION is not set
 # CONFIG_SGI_PARTITION is not set
 # CONFIG_ULTRIX_PARTITION is not set
diff -urN linux-davidm/arch/ia64/dig/setup.c lia64-2.4/arch/ia64/dig/setup.c
--- linux-davidm/arch/ia64/dig/setup.c	Thu Apr  5 12:51:47 2001
+++ lia64-2.4/arch/ia64/dig/setup.c	Wed Apr 10 11:04:02 2002
@@ -33,8 +33,7 @@
  * is sufficient (the IDE driver will autodetect the drive geometry).
  */
 char drive_info[4*16];
-
-unsigned char aux_device_present =3D 0xaa;	/* XXX remove this when legacy =
I/O is gone */
+extern int pcat_compat;
=20
 void __init
 dig_setup (char **cmdline_p)
@@ -81,13 +80,7 @@
 	screen_info.orig_video_ega_bx =3D 3;	/* XXX fake */
 }
=20
-void
+void __init
 dig_irq_init (void)
 {
-	/*
-	 * Disable the compatibility mode interrupts (8259 style), needs IN/OUT s=
upport
-	 * enabled.
-	 */
-	outb(0xff, 0xA1);
-	outb(0xff, 0x21);
 }
diff -urN linux-davidm/arch/ia64/hp/Makefile lia64-2.4/arch/ia64/hp/Makefile
--- linux-davidm/arch/ia64/hp/Makefile	Thu Jan  4 12:50:17 2001
+++ lia64-2.4/arch/ia64/hp/Makefile	Fri Apr  5 16:44:44 2002
@@ -1,17 +1,15 @@
-#
-# ia64/platform/hp/Makefile
-#
-# Copyright (C) 1999 Silicon Graphics, Inc.
-# Copyright (C) Srinivasa Thirumalachar (sprasad@engr.sgi.com)
-#
+# arch/ia64/hp/Makefile
+# Copyright (c) 2002 Matthew Wilcox for Hewlett Packard
=20
-all: hp.a
+ALL_SUB_DIRS :=3D sim zx1 common
=20
-O_TARGET :=3D hp.a
+O_TARGET :=3D hp.o
=20
-obj-y :=3D hpsim_console.o hpsim_irq.o hpsim_setup.o
-obj-$(CONFIG_IA64_GENERIC) +=3D hpsim_machvec.o
+subdir-$(CONFIG_IA64_GENERIC) +=3D $(ALL_SUB_DIRS)
+subdir-$(CONFIG_IA64_HP_SIM) +=3D sim
+subdir-$(CONFIG_IA64_HP_ZX1) +=3D zx1 common
=20
-clean::
+SUB_DIRS :=3D $(subdir-y)
+obj-y +=3D $(join $(subdir-y),$(subdir-y:%=3D/%.o))
=20
 include $(TOPDIR)/Rules.make
diff -urN linux-davidm/arch/ia64/hp/common/Makefile lia64-2.4/arch/ia64/hp/=
common/Makefile
--- linux-davidm/arch/ia64/hp/common/Makefile	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/arch/ia64/hp/common/Makefile	Fri Apr  5 16:44:44 2002
@@ -0,0 +1,14 @@
+#
+# ia64/platform/hp/common/Makefile
+#
+# Copyright (C) 2002 Hewlett Packard
+# Copyright (C) Alex Williamson (alex_williamson@hp.com)
+#
+
+O_TARGET :=3D common.o
+
+export-objs :=3D sba_iommu.o
+
+obj-y :=3D sba_iommu.o
+
+include $(TOPDIR)/Rules.make
diff -urN linux-davidm/arch/ia64/hp/common/sba_iommu.c lia64-2.4/arch/ia64/=
hp/common/sba_iommu.c
--- linux-davidm/arch/ia64/hp/common/sba_iommu.c	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/arch/ia64/hp/common/sba_iommu.c	Fri Apr  5 23:28:59 2002
@@ -0,0 +1,1850 @@
+/*
+**  IA64 System Bus Adapter (SBA) I/O MMU manager
+**
+**	(c) Copyright 2002 Alex Williamson
+**	(c) Copyright 2002 Hewlett-Packard Company
+**
+**	Portions (c) 2000 Grant Grundler (from parisc I/O MMU code)
+**	Portions (c) 1999 Dave S. Miller (from sparc64 I/O MMU code)
+**
+**	This program is free software; you can redistribute it and/or modify
+**	it under the terms of the GNU General Public License as published by
+**      the Free Software Foundation; either version 2 of the License, or
+**      (at your option) any later version.
+**
+**
+** This module initializes the IOC (I/O Controller) found on HP
+** McKinley machines and their successors.
+**
+*/
+
+#include <linux/config.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/spinlock.h>
+#include <linux/slab.h>
+#include <linux/init.h>
+#include <linux/mm.h>
+#include <linux/string.h>
+#include <linux/pci.h>
+#include <linux/proc_fs.h>
+
+#include <asm/delay.h>		/* ia64_get_itc() */
+#include <asm/io.h>
+#include <asm/page.h>		/* PAGE_OFFSET */
+#include <asm/efi.h>
+
+
+#define DRIVER_NAME "SBA"
+
+#ifndef CONFIG_IA64_HP_PROTO
+#define ALLOW_IOV_BYPASS
+#endif
+#define ENABLE_MARK_CLEAN
+/*
+** The number of debug flags is a clue - this code is fragile.
+*/
+#undef DEBUG_SBA_INIT
+#undef DEBUG_SBA_RUN
+#undef DEBUG_SBA_RUN_SG
+#undef DEBUG_SBA_RESOURCE
+#undef ASSERT_PDIR_SANITY
+#undef DEBUG_LARGE_SG_ENTRIES
+#undef DEBUG_BYPASS
+
+#define SBA_INLINE	__inline__
+/* #define SBA_INLINE */
+
+#ifdef DEBUG_SBA_INIT
+#define DBG_INIT(x...)	printk(x)
+#else
+#define DBG_INIT(x...)
+#endif
+
+#ifdef DEBUG_SBA_RUN
+#define DBG_RUN(x...)	printk(x)
+#else
+#define DBG_RUN(x...)
+#endif
+
+#ifdef DEBUG_SBA_RUN_SG
+#define DBG_RUN_SG(x...)	printk(x)
+#else
+#define DBG_RUN_SG(x...)
+#endif
+
+
+#ifdef DEBUG_SBA_RESOURCE
+#define DBG_RES(x...)	printk(x)
+#else
+#define DBG_RES(x...)
+#endif
+
+#ifdef DEBUG_BYPASS
+#define DBG_BYPASS(x...)	printk(x)
+#else
+#define DBG_BYPASS(x...)
+#endif
+
+#ifdef ASSERT_PDIR_SANITY
+#define ASSERT(expr) \
+        if(!(expr)) { \
+                printk( "\n" __FILE__ ":%d: Assertion " #expr " failed!\n"=
,__LINE__); \
+                panic(#expr); \
+        }
+#else
+#define ASSERT(expr)
+#endif
+
+#define KB(x) ((x) * 1024)
+#define MB(x) (KB (KB (x)))
+#define GB(x) (MB (KB (x)))
+
+/*
+** The number of pdir entries to "free" before issueing
+** a read to PCOM register to flush out PCOM writes.
+** Interacts with allocation granularity (ie 4 or 8 entries
+** allocated and free'd/purged at a time might make this
+** less interesting).
+*/
+#define DELAYED_RESOURCE_CNT	16
+
+#define DEFAULT_DMA_HINT_REG	0
+
+#define ZX1_FUNC_ID_VALUE    ((PCI_DEVICE_ID_HP_ZX1_SBA << 16) | PCI_VENDO=
R_ID_HP)
+#define ZX1_MC_ID    ((PCI_DEVICE_ID_HP_ZX1_MC << 16) | PCI_VENDOR_ID_HP)
+
+#define SBA_FUNC_ID	0x0000	/* function id */
+#define SBA_FCLASS	0x0008	/* function class, bist, header, rev... */
+
+#define SBA_FUNC_SIZE	0x10000   /* SBA configuration function reg set */
+
+unsigned int __initdata zx1_func_offsets[] =3D {0x1000, 0x4000, 0x8000,
+                                              0x9000, 0xa000, -1};
+
+#define SBA_IOC_OFFSET	0x1000
+
+#define MAX_IOC		1	/* we only have 1 for now*/
+
+#define IOC_IBASE	0x300	/* IO TLB */
+#define IOC_IMASK	0x308
+#define IOC_PCOM	0x310
+#define IOC_TCNFG	0x318
+#define IOC_PDIR_BASE	0x320
+
+#define IOC_IOVA_SPACE_BASE	0x40000000 /* IOVA ranges start at 1GB */
+
+/*
+** IOC supports 4/8/16/64KB page sizes (see TCNFG register)
+** It's safer (avoid memory corruption) to keep DMA page mappings
+** equivalently sized to VM PAGE_SIZE.
+**
+** We really can't avoid generating a new mapping for each
+** page since the Virtual Coherence Index has to be generated
+** and updated for each page.
+**
+** IOVP_SIZE could only be greater than PAGE_SIZE if we are
+** confident the drivers really only touch the next physical
+** page iff that driver instance owns it.
+*/
+#define IOVP_SIZE	PAGE_SIZE
+#define IOVP_SHIFT	PAGE_SHIFT
+#define IOVP_MASK	PAGE_MASK
+
+struct ioc {
+	unsigned long	ioc_hpa;	/* I/O MMU base address */
+	char		*res_map;	/* resource map, bit =3D pdir entry */
+	u64		*pdir_base;	/* physical base address */
+	unsigned long	ibase;		/* pdir IOV Space base */
+	unsigned long	imask;		/* pdir IOV Space mask */
+
+	unsigned long	*res_hint;	/* next avail IOVP - circular search */
+	spinlock_t	res_lock;
+	unsigned long	hint_mask_pdir;	/* bits used for DMA hints */
+	unsigned int	res_bitshift;	/* from the RIGHT! */
+	unsigned int	res_size;	/* size of resource map in bytes */
+	unsigned int	hint_shift_pdir;
+	unsigned long	dma_mask;
+#if DELAYED_RESOURCE_CNT > 0
+	int saved_cnt;
+	struct sba_dma_pair {
+		dma_addr_t	iova;
+		size_t		size;
+	} saved[DELAYED_RESOURCE_CNT];
+#endif
+
+#ifdef CONFIG_PROC_FS
+#define SBA_SEARCH_SAMPLE	0x100
+	unsigned long avg_search[SBA_SEARCH_SAMPLE];
+	unsigned long avg_idx;	/* current index into avg_search */
+	unsigned long used_pages;
+	unsigned long msingle_calls;
+	unsigned long msingle_pages;
+	unsigned long msg_calls;
+	unsigned long msg_pages;
+	unsigned long usingle_calls;
+	unsigned long usingle_pages;
+	unsigned long usg_calls;
+	unsigned long usg_pages;
+#ifdef ALLOW_IOV_BYPASS
+	unsigned long msingle_bypass;
+	unsigned long usingle_bypass;
+	unsigned long msg_bypass;
+#endif
+#endif
+
+	/* STUFF We don't need in performance path */
+	unsigned int	pdir_size;	/* in bytes, determined by IOV Space size */
+};
+
+struct sba_device {
+	struct sba_device	*next;	/* list of SBA's in system */
+	const char 		*name;
+	unsigned long		sba_hpa; /* base address */
+	spinlock_t		sba_lock;
+	unsigned int		flags;  /* state/functionality enabled */
+	unsigned int		hw_rev;  /* HW revision of chip */
+
+	unsigned int		num_ioc;  /* number of on-board IOC's */
+	struct ioc		ioc[MAX_IOC];
+};
+
+
+static struct sba_device *sba_list;
+static int sba_count;
+static int reserve_sba_gart =3D 1;
+
+#define sba_sg_iova(sg) (sg->address)
+#define sba_sg_len(sg) (sg->length)
+#define sba_sg_buffer(sg) (sg->orig_address)
+
+/* REVISIT - fix me for multiple SBAs/IOCs */
+#define GET_IOC(dev) (sba_list->ioc)
+#define SBA_SET_AGP(sba_dev) (sba_dev->flags |=3D 0x1)
+#define SBA_GET_AGP(sba_dev) (sba_dev->flags & 0x1)
+
+/*
+** DMA_CHUNK_SIZE is used by the SCSI mid-layer to break up
+** (or rather not merge) DMA's into managable chunks.
+** On parisc, this is more of the software/tuning constraint
+** rather than the HW. I/O MMU allocation alogorithms can be
+** faster with smaller size is (to some degree).
+*/
+#define DMA_CHUNK_SIZE  (BITS_PER_LONG*PAGE_SIZE)
+
+/* Looks nice and keeps the compiler happy */
+#define SBA_DEV(d) ((struct sba_device *) (d))
+
+#define ROUNDUP(x,y) ((x + ((y)-1)) & ~((y)-1))
+
+/************************************
+** SBA register read and write support
+**
+** BE WARNED: register writes are posted.
+**  (ie follow writes which must reach HW with a read)
+**
+*/
+#define READ_REG(addr)       __raw_readq(addr)
+#define WRITE_REG(val, addr) __raw_writeq(val, addr)
+
+#ifdef DEBUG_SBA_INIT
+
+/**
+ * sba_dump_tlb - debugging only - print IOMMU operating parameters
+ * @hpa: base address of the IOMMU
+ *
+ * Print the size/location of the IO MMU PDIR.
+ */
+static void
+sba_dump_tlb(char *hpa)
+{
+	DBG_INIT("IO TLB at 0x%p\n", (void *)hpa);
+	DBG_INIT("IOC_IBASE    : %016lx\n", READ_REG(hpa+IOC_IBASE));
+	DBG_INIT("IOC_IMASK    : %016lx\n", READ_REG(hpa+IOC_IMASK));
+	DBG_INIT("IOC_TCNFG    : %016lx\n", READ_REG(hpa+IOC_TCNFG));
+	DBG_INIT("IOC_PDIR_BASE: %016lx\n", READ_REG(hpa+IOC_PDIR_BASE));
+	DBG_INIT("\n");
+}
+#endif
+
+
+#ifdef ASSERT_PDIR_SANITY
+
+/**
+ * sba_dump_pdir_entry - debugging only - print one IOMMU PDIR entry
+ * @ioc: IO MMU structure which owns the pdir we are interested in.
+ * @msg: text to print ont the output line.
+ * @pide: pdir index.
+ *
+ * Print one entry of the IO MMU PDIR in human readable form.
+ */
+static void
+sba_dump_pdir_entry(struct ioc *ioc, char *msg, uint pide)
+{
+	/* start printing from lowest pde in rval */
+	u64 *ptr =3D &(ioc->pdir_base[pide  & ~(BITS_PER_LONG - 1)]);
+	unsigned long *rptr =3D (unsigned long *) &(ioc->res_map[(pide >>3) & ~(s=
izeof(unsigned long) - 1)]);
+	uint rcnt;
+
+	/* printk(KERN_DEBUG "SBA: %s rp %p bit %d rval 0x%lx\n", */
+	printk("SBA: %s rp %p bit %d rval 0x%lx\n",
+		 msg, rptr, pide & (BITS_PER_LONG - 1), *rptr);
+
+	rcnt =3D 0;
+	while (rcnt < BITS_PER_LONG) {
+		printk("%s %2d %p %016Lx\n",
+			(rcnt =3D (pide & (BITS_PER_LONG - 1)))
+				? "    -->" : "       ",
+			rcnt, ptr, *ptr );
+		rcnt++;
+		ptr++;
+	}
+	printk("%s", msg);
+}
+
+
+/**
+ * sba_check_pdir - debugging only - consistency checker
+ * @ioc: IO MMU structure which owns the pdir we are interested in.
+ * @msg: text to print ont the output line.
+ *
+ * Verify the resource map and pdir state is consistent
+ */
+static int
+sba_check_pdir(struct ioc *ioc, char *msg)
+{
+	u64 *rptr_end =3D (u64 *) &(ioc->res_map[ioc->res_size]);
+	u64 *rptr =3D (u64 *) ioc->res_map;	/* resource map ptr */
+	u64 *pptr =3D ioc->pdir_base;	/* pdir ptr */
+	uint pide =3D 0;
+
+	while (rptr < rptr_end) {
+		u64 rval;
+		int rcnt; /* number of bits we might check */
+
+		rval =3D *rptr;
+		rcnt =3D 64;
+
+		while (rcnt) {
+			/* Get last byte and highest bit from that */
+			u32 pde =3D ((u32)((*pptr >> (63)) & 0x1));
+			if ((rval & 0x1) ^ pde)
+			{
+				/*
+				** BUMMER!  -- res_map !=3D pdir --
+				** Dump rval and matching pdir entries
+				*/
+				sba_dump_pdir_entry(ioc, msg, pide);
+				return(1);
+			}
+			rcnt--;
+			rval >>=3D 1;	/* try the next bit */
+			pptr++;
+			pide++;
+		}
+		rptr++;	/* look at next word of res_map */
+	}
+	/* It'd be nice if we always got here :^) */
+	return 0;
+}
+
+
+/**
+ * sba_dump_sg - debugging only - print Scatter-Gather list
+ * @ioc: IO MMU structure which owns the pdir we are interested in.
+ * @startsg: head of the SG list
+ * @nents: number of entries in SG list
+ *
+ * print the SG list so we can verify it's correct by hand.
+ */
+static void
+sba_dump_sg( struct ioc *ioc, struct scatterlist *startsg, int nents)
+{
+	while (nents-- > 0) {
+		printk(" %d : %08lx/%05x %p\n",
+				nents,
+				(unsigned long) sba_sg_iova(startsg),
+				sba_sg_len(startsg),
+				sba_sg_buffer(startsg));
+		startsg++;
+	}
+}
+static void
+sba_check_sg( struct ioc *ioc, struct scatterlist *startsg, int nents)
+{
+	struct scatterlist *the_sg =3D startsg;
+	int the_nents =3D nents;
+
+	while (the_nents-- > 0) {
+		if (sba_sg_buffer(the_sg) =3D 0x0UL)
+			sba_dump_sg(NULL, startsg, nents);
+		the_sg++;
+	}
+}
+
+#endif /* ASSERT_PDIR_SANITY */
+
+
+
+
+/**************************************************************
+*
+*   I/O Pdir Resource Management
+*
+*   Bits set in the resource map are in use.
+*   Each bit can represent a number of pages.
+*   LSbs represent lower addresses (IOVA's).
+*
+***************************************************************/
+#define PAGES_PER_RANGE 1	/* could increase this to 4 or 8 if needed */
+
+/* Convert from IOVP to IOVA and vice versa. */
+#define SBA_IOVA(ioc,iovp,offset,hint_reg) ((ioc->ibase) | (iovp) | (offse=
t) | ((hint_reg)<<(ioc->hint_shift_pdir)))
+#define SBA_IOVP(ioc,iova) (((iova) & ioc->hint_mask_pdir) & ~(ioc->ibase))
+
+/* FIXME : review these macros to verify correctness and usage */
+#define PDIR_INDEX(iovp)   ((iovp)>>IOVP_SHIFT)
+
+#define RESMAP_MASK(n)    ~(~0UL << (n))
+#define RESMAP_IDX_MASK   (sizeof(unsigned long) - 1)
+
+
+/**
+ * sba_search_bitmap - find free space in IO PDIR resource bitmap
+ * @ioc: IO MMU structure which owns the pdir we are interested in.
+ * @bits_wanted: number of entries we need.
+ *
+ * Find consecutive free bits in resource bitmap.
+ * Each bit represents one entry in the IO Pdir.
+ * Cool perf optimization: search for log2(size) bits at a time.
+ */
+static SBA_INLINE unsigned long
+sba_search_bitmap(struct ioc *ioc, unsigned long bits_wanted)
+{
+	unsigned long *res_ptr =3D ioc->res_hint;
+	unsigned long *res_end =3D (unsigned long *) &(ioc->res_map[ioc->res_size=
]);
+	unsigned long pide =3D ~0UL;
+
+	ASSERT(((unsigned long) ioc->res_hint & (sizeof(unsigned long) - 1UL)) =
=3D 0);
+	ASSERT(res_ptr < res_end);
+	if (bits_wanted > (BITS_PER_LONG/2)) {
+		/* Search word at a time - no mask needed */
+		for(; res_ptr < res_end; ++res_ptr) {
+			if (*res_ptr =3D 0) {
+				*res_ptr =3D RESMAP_MASK(bits_wanted);
+				pide =3D ((unsigned long)res_ptr - (unsigned long)ioc->res_map);
+				pide <<=3D 3;	/* convert to bit address */
+				break;
+			}
+		}
+		/* point to the next word on next pass */
+		res_ptr++;
+		ioc->res_bitshift =3D 0;
+	} else {
+		/*
+		** Search the resource bit map on well-aligned values.
+		** "o" is the alignment.
+		** We need the alignment to invalidate I/O TLB using
+		** SBA HW features in the unmap path.
+		*/
+		unsigned long o =3D 1 << get_order(bits_wanted << PAGE_SHIFT);
+		uint bitshiftcnt =3D ROUNDUP(ioc->res_bitshift, o);
+		unsigned long mask;
+
+		if (bitshiftcnt >=3D BITS_PER_LONG) {
+			bitshiftcnt =3D 0;
+			res_ptr++;
+		}
+		mask =3D RESMAP_MASK(bits_wanted) << bitshiftcnt;
+
+		DBG_RES("%s() o %ld %p", __FUNCTION__, o, res_ptr);
+		while(res_ptr < res_end)
+		{=20
+			DBG_RES("    %p %lx %lx\n", res_ptr, mask, *res_ptr);
+			ASSERT(0 !=3D mask);
+			if(0 =3D ((*res_ptr) & mask)) {
+				*res_ptr |=3D mask;     /* mark resources busy! */
+				pide =3D ((unsigned long)res_ptr - (unsigned long)ioc->res_map);
+				pide <<=3D 3;	/* convert to bit address */
+				pide +=3D bitshiftcnt;
+				break;
+			}
+			mask <<=3D o;
+			bitshiftcnt +=3D o;
+			if (0 =3D mask) {
+				mask =3D RESMAP_MASK(bits_wanted);
+				bitshiftcnt=3D0;
+				res_ptr++;
+			}
+		}
+		/* look in the same word on the next pass */
+		ioc->res_bitshift =3D bitshiftcnt + bits_wanted;
+	}
+
+	/* wrapped ? */
+	if (res_end <=3D res_ptr) {
+		ioc->res_hint =3D (unsigned long *) ioc->res_map;
+		ioc->res_bitshift =3D 0;
+	} else {
+		ioc->res_hint =3D res_ptr;
+	}
+	return (pide);
+}
+
+
+/**
+ * sba_alloc_range - find free bits and mark them in IO PDIR resource bitm=
ap
+ * @ioc: IO MMU structure which owns the pdir we are interested in.
+ * @size: number of bytes to create a mapping for
+ *
+ * Given a size, find consecutive unmarked and then mark those bits in the
+ * resource bit map.
+ */
+static int
+sba_alloc_range(struct ioc *ioc, size_t size)
+{
+	unsigned int pages_needed =3D size >> IOVP_SHIFT;
+#ifdef CONFIG_PROC_FS
+	unsigned long itc_start =3D ia64_get_itc();
+#endif
+	unsigned long pide;
+
+	ASSERT(pages_needed);
+	ASSERT((pages_needed * IOVP_SIZE) <=3D DMA_CHUNK_SIZE);
+	ASSERT(pages_needed <=3D BITS_PER_LONG);
+	ASSERT(0 =3D (size & ~IOVP_MASK));
+
+	/*
+	** "seek and ye shall find"...praying never hurts either...
+	*/
+
+	pide =3D sba_search_bitmap(ioc, pages_needed);
+	if (pide >=3D (ioc->res_size << 3)) {
+		pide =3D sba_search_bitmap(ioc, pages_needed);
+		if (pide >=3D (ioc->res_size << 3))
+			panic(__FILE__ ": I/O MMU @ %lx is out of mapping resources\n", ioc->io=
c_hpa);
+	}
+
+#ifdef ASSERT_PDIR_SANITY
+	/* verify the first enable bit is clear */
+	if(0x00 !=3D ((u8 *) ioc->pdir_base)[pide*sizeof(u64) + 7]) {
+		sba_dump_pdir_entry(ioc, "sba_search_bitmap() botched it?", pide);
+	}
+#endif
+
+	DBG_RES("%s(%x) %d -> %lx hint %x/%x\n",
+		__FUNCTION__, size, pages_needed, pide,
+		(uint) ((unsigned long) ioc->res_hint - (unsigned long) ioc->res_map),
+		ioc->res_bitshift );
+
+#ifdef CONFIG_PROC_FS
+	{
+		unsigned long itc_end =3D ia64_get_itc();
+		unsigned long tmp =3D itc_end - itc_start;
+		/* check for roll over */
+		itc_start =3D (itc_end < itc_start) ?  -(tmp) : (tmp);
+	}
+	ioc->avg_search[ioc->avg_idx++] =3D itc_start;
+	ioc->avg_idx &=3D SBA_SEARCH_SAMPLE - 1;
+
+	ioc->used_pages +=3D pages_needed;
+#endif
+
+	return (pide);
+}
+
+
+/**
+ * sba_free_range - unmark bits in IO PDIR resource bitmap
+ * @ioc: IO MMU structure which owns the pdir we are interested in.
+ * @iova: IO virtual address which was previously allocated.
+ * @size: number of bytes to create a mapping for
+ *
+ * clear bits in the ioc's resource map
+ */
+static SBA_INLINE void
+sba_free_range(struct ioc *ioc, dma_addr_t iova, size_t size)
+{
+	unsigned long iovp =3D SBA_IOVP(ioc, iova);
+	unsigned int pide =3D PDIR_INDEX(iovp);
+	unsigned int ridx =3D pide >> 3;	/* convert bit to byte address */
+	unsigned long *res_ptr =3D (unsigned long *) &((ioc)->res_map[ridx & ~RES=
MAP_IDX_MASK]);
+
+	int bits_not_wanted =3D size >> IOVP_SHIFT;
+
+	/* 3-bits "bit" address plus 2 (or 3) bits for "byte" =3D bit in word */
+	unsigned long m =3D RESMAP_MASK(bits_not_wanted) << (pide & (BITS_PER_LON=
G - 1));
+
+	DBG_RES("%s( ,%x,%x) %x/%lx %x %p %lx\n",
+		__FUNCTION__, (uint) iova, size,
+		bits_not_wanted, m, pide, res_ptr, *res_ptr);
+
+#ifdef CONFIG_PROC_FS
+	ioc->used_pages -=3D bits_not_wanted;
+#endif
+
+	ASSERT(m !=3D 0);
+	ASSERT(bits_not_wanted);
+	ASSERT((bits_not_wanted * IOVP_SIZE) <=3D DMA_CHUNK_SIZE);
+	ASSERT(bits_not_wanted <=3D BITS_PER_LONG);
+	ASSERT((*res_ptr & m) =3D m); /* verify same bits are set */
+	*res_ptr &=3D ~m;
+}
+
+
+/**************************************************************
+*
+*   "Dynamic DMA Mapping" support (aka "Coherent I/O")
+*
+***************************************************************/
+
+#define SBA_DMA_HINT(ioc, val) ((val) << (ioc)->hint_shift_pdir)
+
+
+/**
+ * sba_io_pdir_entry - fill in one IO PDIR entry
+ * @pdir_ptr:  pointer to IO PDIR entry
+ * @vba: Virtual CPU address of buffer to map
+ *
+ * SBA Mapping Routine
+ *
+ * Given a virtual address (vba, arg1) sba_io_pdir_entry()
+ * loads the I/O PDIR entry pointed to by pdir_ptr (arg0).
+ * Each IO Pdir entry consists of 8 bytes as shown below
+ * (LSB =3D bit 0):
+ *
+ *  63                    40                                 11    7      =
  0
+ * +-+---------------------+----------------------------------+----+------=
--+
+ * |V|        U            |            PPN[39:12]            | U  |   FF =
  |
+ * +-+---------------------+----------------------------------+----+------=
--+
+ *
+ *  V  =3D Valid Bit
+ *  U  =3D Unused
+ * PPN =3D Physical Page Number
+ *
+ * The physical address fields are filled with the results of virt_to_phys=
()
+ * on the vba.
+ */
+
+#if 1
+#define sba_io_pdir_entry(pdir_ptr, vba) *pdir_ptr =3D ((vba & ~0xE0000000=
00000FFFULL) | 0x80000000000000FFULL)
+#else
+void SBA_INLINE
+sba_io_pdir_entry(u64 *pdir_ptr, unsigned long vba)
+{
+	*pdir_ptr =3D ((vba & ~0xE000000000000FFFULL) | 0x80000000000000FFULL);
+}
+#endif
+
+#ifdef ENABLE_MARK_CLEAN
+/**
+ * Since DMA is i-cache coherent, any (complete) pages that were written v=
ia
+ * DMA can be marked as "clean" so that update_mmu_cache() doesn't have to
+ * flush them when they get mapped into an executable vm-area.
+ */
+static void
+mark_clean (void *addr, size_t size)
+{
+	unsigned long pg_addr, end;
+
+	pg_addr =3D PAGE_ALIGN((unsigned long) addr);
+	end =3D (unsigned long) addr + size;
+	while (pg_addr + PAGE_SIZE <=3D end) {
+		struct page *page =3D virt_to_page(pg_addr);
+		set_bit(PG_arch_1, &page->flags);
+		pg_addr +=3D PAGE_SIZE;
+	}
+}
+#endif
+
+/**
+ * sba_mark_invalid - invalidate one or more IO PDIR entries
+ * @ioc: IO MMU structure which owns the pdir we are interested in.
+ * @iova:  IO Virtual Address mapped earlier
+ * @byte_cnt:  number of bytes this mapping covers.
+ *
+ * Marking the IO PDIR entry(ies) as Invalid and invalidate
+ * corresponding IO TLB entry. The PCOM (Purge Command Register)
+ * is to purge stale entries in the IO TLB when unmapping entries.
+ *
+ * The PCOM register supports purging of multiple pages, with a minium
+ * of 1 page and a maximum of 2GB. Hardware requires the address be
+ * aligned to the size of the range being purged. The size of the range
+ * must be a power of 2. The "Cool perf optimization" in the
+ * allocation routine helps keep that true.
+ */
+static SBA_INLINE void
+sba_mark_invalid(struct ioc *ioc, dma_addr_t iova, size_t byte_cnt)
+{
+	u32 iovp =3D (u32) SBA_IOVP(ioc,iova);
+
+	int off =3D PDIR_INDEX(iovp);
+
+	/* Must be non-zero and rounded up */
+	ASSERT(byte_cnt > 0);
+	ASSERT(0 =3D (byte_cnt & ~IOVP_MASK));
+
+#ifdef ASSERT_PDIR_SANITY
+	/* Assert first pdir entry is set */
+	if (!(ioc->pdir_base[off] >> 60)) {
+		sba_dump_pdir_entry(ioc,"sba_mark_invalid()", PDIR_INDEX(iovp));
+	}
+#endif
+
+	if (byte_cnt <=3D IOVP_SIZE)
+	{
+		ASSERT(off < ioc->pdir_size);
+
+		iovp |=3D IOVP_SHIFT;     /* set "size" field for PCOM */
+
+		/*
+		** clear I/O PDIR entry "valid" bit
+		** Do NOT clear the rest - save it for debugging.
+		** We should only clear bits that have previously
+		** been enabled.
+		*/
+		ioc->pdir_base[off] &=3D ~(0x80000000000000FFULL);
+	} else {
+		u32 t =3D get_order(byte_cnt) + PAGE_SHIFT;
+
+		iovp |=3D t;
+		ASSERT(t <=3D 31);   /* 2GB! Max value of "size" field */
+
+		do {
+			/* verify this pdir entry is enabled */
+			ASSERT(ioc->pdir_base[off]  >> 63);
+			/* clear I/O Pdir entry "valid" bit first */
+			ioc->pdir_base[off] &=3D ~(0x80000000000000FFULL);
+			off++;
+			byte_cnt -=3D IOVP_SIZE;
+		} while (byte_cnt > 0);
+	}
+
+	WRITE_REG(iovp, ioc->ioc_hpa+IOC_PCOM);
+}
+
+/**
+ * sba_map_single - map one buffer and return IOVA for DMA
+ * @dev: instance of PCI owned by the driver that's asking.
+ * @addr:  driver buffer to map.
+ * @size:  number of bytes to map in driver buffer.
+ * @direction:  R/W or both.
+ *
+ * See Documentation/DMA-mapping.txt
+ */
+dma_addr_t
+sba_map_single(struct pci_dev *dev, void *addr, size_t size, int direction)
+{
+	struct ioc *ioc;
+	unsigned long flags;=20
+	dma_addr_t iovp;
+	dma_addr_t offset;
+	u64 *pdir_start;
+	int pide;
+#ifdef ALLOW_IOV_BYPASS
+	unsigned long pci_addr =3D virt_to_phys(addr);
+#endif
+
+	ioc =3D GET_IOC(dev);
+	ASSERT(ioc);
+
+#ifdef ALLOW_IOV_BYPASS
+	/*
+ 	** Check if the PCI device can DMA to ptr... if so, just return ptr
+ 	*/
+	if ((pci_addr & ~dev->dma_mask) =3D 0) {
+		/*
+ 		** Device is bit capable of DMA'ing to the buffer...
+		** just return the PCI address of ptr
+ 		*/
+#ifdef CONFIG_PROC_FS
+		spin_lock_irqsave(&ioc->res_lock, flags);
+		ioc->msingle_bypass++;
+		spin_unlock_irqrestore(&ioc->res_lock, flags);
+#endif
+		DBG_BYPASS("sba_map_single() bypass mask/addr: 0x%lx/0x%lx\n",
+		           dev->dma_mask, pci_addr);
+		return pci_addr;
+	}
+#endif
+
+	ASSERT(size > 0);
+	ASSERT(size <=3D DMA_CHUNK_SIZE);
+
+	/* save offset bits */
+	offset =3D ((dma_addr_t) (long) addr) & ~IOVP_MASK;
+
+	/* round up to nearest IOVP_SIZE */
+	size =3D (size + offset + ~IOVP_MASK) & IOVP_MASK;
+
+	spin_lock_irqsave(&ioc->res_lock, flags);
+#ifdef ASSERT_PDIR_SANITY
+	if (sba_check_pdir(ioc,"Check before sba_map_single()"))
+		panic("Sanity check failed");
+#endif
+
+#ifdef CONFIG_PROC_FS
+	ioc->msingle_calls++;
+	ioc->msingle_pages +=3D size >> IOVP_SHIFT;
+#endif
+	pide =3D sba_alloc_range(ioc, size);
+	iovp =3D (dma_addr_t) pide << IOVP_SHIFT;
+
+	DBG_RUN("%s() 0x%p -> 0x%lx\n",
+		__FUNCTION__, addr, (long) iovp | offset);
+
+	pdir_start =3D &(ioc->pdir_base[pide]);
+
+	while (size > 0) {
+		ASSERT(((u8 *)pdir_start)[7] =3D 0); /* verify availability */
+		sba_io_pdir_entry(pdir_start, (unsigned long) addr);
+
+		DBG_RUN("     pdir 0x%p %lx\n", pdir_start, *pdir_start);
+
+		addr +=3D IOVP_SIZE;
+		size -=3D IOVP_SIZE;
+		pdir_start++;
+	}
+	/* form complete address */
+#ifdef ASSERT_PDIR_SANITY
+	sba_check_pdir(ioc,"Check after sba_map_single()");
+#endif
+	spin_unlock_irqrestore(&ioc->res_lock, flags);
+	return SBA_IOVA(ioc, iovp, offset, DEFAULT_DMA_HINT_REG);
+}
+
+/**
+ * sba_unmap_single - unmap one IOVA and free resources
+ * @dev: instance of PCI owned by the driver that's asking.
+ * @iova:  IOVA of driver buffer previously mapped.
+ * @size:  number of bytes mapped in driver buffer.
+ * @direction:  R/W or both.
+ *
+ * See Documentation/DMA-mapping.txt
+ */
+void sba_unmap_single(struct pci_dev *dev, dma_addr_t iova, size_t size,
+		int direction)
+{
+	struct ioc *ioc;
+#if DELAYED_RESOURCE_CNT > 0
+	struct sba_dma_pair *d;
+#endif
+	unsigned long flags;=20
+	dma_addr_t offset;
+
+	ioc =3D GET_IOC(dev);
+	ASSERT(ioc);
+
+#ifdef ALLOW_IOV_BYPASS
+	if ((iova & ioc->imask) !=3D ioc->ibase) {
+		/*
+		** Address does not fall w/in IOVA, must be bypassing
+		*/
+#ifdef CONFIG_PROC_FS
+		spin_lock_irqsave(&ioc->res_lock, flags);
+		ioc->usingle_bypass++;
+		spin_unlock_irqrestore(&ioc->res_lock, flags);
+#endif
+		DBG_BYPASS("sba_unmap_single() bypass addr: 0x%lx\n", iova);
+
+#ifdef ENABLE_MARK_CLEAN
+		if (direction =3D PCI_DMA_FROMDEVICE) {
+			mark_clean(phys_to_virt(iova), size);
+		}
+#endif
+		return;
+	}
+#endif
+	offset =3D iova & ~IOVP_MASK;
+
+	DBG_RUN("%s() iovp 0x%lx/%x\n",
+		__FUNCTION__, (long) iova, size);
+
+	iova ^=3D offset;        /* clear offset bits */
+	size +=3D offset;
+	size =3D ROUNDUP(size, IOVP_SIZE);
+
+	spin_lock_irqsave(&ioc->res_lock, flags);
+#ifdef CONFIG_PROC_FS
+	ioc->usingle_calls++;
+	ioc->usingle_pages +=3D size >> IOVP_SHIFT;
+#endif
+
+#if DELAYED_RESOURCE_CNT > 0
+	d =3D &(ioc->saved[ioc->saved_cnt]);
+	d->iova =3D iova;
+	d->size =3D size;
+	if (++(ioc->saved_cnt) >=3D DELAYED_RESOURCE_CNT) {
+		int cnt =3D ioc->saved_cnt;
+		while (cnt--) {
+			sba_mark_invalid(ioc, d->iova, d->size);
+			sba_free_range(ioc, d->iova, d->size);
+			d--;
+		}
+		ioc->saved_cnt =3D 0;
+		READ_REG(ioc->ioc_hpa+IOC_PCOM);	/* flush purges */
+	}
+#else /* DELAYED_RESOURCE_CNT =3D 0 */
+	sba_mark_invalid(ioc, iova, size);
+	sba_free_range(ioc, iova, size);
+	READ_REG(ioc->ioc_hpa+IOC_PCOM);	/* flush purges */
+#endif /* DELAYED_RESOURCE_CNT =3D 0 */
+#ifdef ENABLE_MARK_CLEAN
+	if (direction =3D PCI_DMA_FROMDEVICE) {
+		u32 iovp =3D (u32) SBA_IOVP(ioc,iova);
+		int off =3D PDIR_INDEX(iovp);
+		void *addr;
+
+		if (size <=3D IOVP_SIZE) {
+			addr =3D phys_to_virt(ioc->pdir_base[off] &
+					    ~0xE000000000000FFFULL);
+			mark_clean(addr, size);
+		} else {
+			size_t byte_cnt =3D size;
+
+			do {
+				addr =3D phys_to_virt(ioc->pdir_base[off] &
+				                    ~0xE000000000000FFFULL);
+				mark_clean(addr, min(byte_cnt, IOVP_SIZE));
+				off++;
+				byte_cnt -=3D IOVP_SIZE;
+
+			   } while (byte_cnt > 0);
+		}
+	}
+#endif
+	spin_unlock_irqrestore(&ioc->res_lock, flags);
+
+	/* XXX REVISIT for 2.5 Linux - need syncdma for zero-copy support.
+	** For Astro based systems this isn't a big deal WRT performance.
+	** As long as 2.4 kernels copyin/copyout data from/to userspace,
+	** we don't need the syncdma. The issue here is I/O MMU cachelines
+	** are *not* coherent in all cases.  May be hwrev dependent.
+	** Need to investigate more.
+	asm volatile("syncdma");=09
+	*/
+}
+
+
+/**
+ * sba_alloc_consistent - allocate/map shared mem for DMA
+ * @hwdev: instance of PCI owned by the driver that's asking.
+ * @size:  number of bytes mapped in driver buffer.
+ * @dma_handle:  IOVA of new buffer.
+ *
+ * See Documentation/DMA-mapping.txt
+ */
+void *
+sba_alloc_consistent(struct pci_dev *hwdev, size_t size, dma_addr_t *dma_h=
andle)
+{
+	void *ret;
+
+	if (!hwdev) {
+		/* only support PCI */
+		*dma_handle =3D 0;
+		return 0;
+	}
+
+        ret =3D (void *) __get_free_pages(GFP_ATOMIC, get_order(size));
+
+	if (ret) {
+		memset(ret, 0, size);
+		*dma_handle =3D sba_map_single(hwdev, ret, size, 0);
+	}
+
+	return ret;
+}
+
+
+/**
+ * sba_free_consistent - free/unmap shared mem for DMA
+ * @hwdev: instance of PCI owned by the driver that's asking.
+ * @size:  number of bytes mapped in driver buffer.
+ * @vaddr:  virtual address IOVA of "consistent" buffer.
+ * @dma_handler:  IO virtual address of "consistent" buffer.
+ *
+ * See Documentation/DMA-mapping.txt
+ */
+void sba_free_consistent(struct pci_dev *hwdev, size_t size, void *vaddr,
+		dma_addr_t dma_handle)
+{
+	sba_unmap_single(hwdev, dma_handle, size, 0);
+	free_pages((unsigned long) vaddr, get_order(size));
+}
+
+
+/*
+** Since 0 is a valid pdir_base index value, can't use that
+** to determine if a value is valid or not. Use a flag to indicate
+** the SG list entry contains a valid pdir index.
+*/
+#define PIDE_FLAG 0x1UL
+
+#ifdef DEBUG_LARGE_SG_ENTRIES
+int dump_run_sg =3D 0;
+#endif
+
+
+/**
+ * sba_fill_pdir - write allocated SG entries into IO PDIR
+ * @ioc: IO MMU structure which owns the pdir we are interested in.
+ * @startsg:  list of IOVA/size pairs
+ * @nents: number of entries in startsg list
+ *
+ * Take preprocessed SG list and write corresponding entries
+ * in the IO PDIR.
+ */
+
+static SBA_INLINE int
+sba_fill_pdir(
+	struct ioc *ioc,
+	struct scatterlist *startsg,
+	int nents)
+{
+	struct scatterlist *dma_sg =3D startsg;	/* pointer to current DMA */
+	int n_mappings =3D 0;
+	u64 *pdirp =3D 0;
+	unsigned long dma_offset =3D 0;
+
+	dma_sg--;
+	while (nents-- > 0) {
+		int     cnt =3D sba_sg_len(startsg);
+		sba_sg_len(startsg) =3D 0;
+
+#ifdef DEBUG_LARGE_SG_ENTRIES
+		if (dump_run_sg)
+			printk(" %2d : %08lx/%05x %p\n",
+				nents,
+				(unsigned long) sba_sg_iova(startsg), cnt,
+				sba_sg_buffer(startsg)
+		);
+#else
+		DBG_RUN_SG(" %d : %08lx/%05x %p\n",
+				nents,
+				(unsigned long) sba_sg_iova(startsg), cnt,
+				sba_sg_buffer(startsg)
+		);
+#endif
+		/*
+		** Look for the start of a new DMA stream
+		*/
+		if ((u64)sba_sg_iova(startsg) & PIDE_FLAG) {
+			u32 pide =3D (u64)sba_sg_iova(startsg) & ~PIDE_FLAG;
+			dma_offset =3D (unsigned long) pide & ~IOVP_MASK;
+			sba_sg_iova(startsg) =3D 0;
+			dma_sg++;
+			sba_sg_iova(dma_sg) =3D (char *)(pide | ioc->ibase);
+			pdirp =3D &(ioc->pdir_base[pide >> IOVP_SHIFT]);
+			n_mappings++;
+		}
+
+		/*
+		** Look for a VCONTIG chunk
+		*/
+		if (cnt) {
+			unsigned long vaddr =3D (unsigned long) sba_sg_buffer(startsg);
+			ASSERT(pdirp);
+
+			/* Since multiple Vcontig blocks could make up
+			** one DMA stream, *add* cnt to dma_len.
+			*/
+			sba_sg_len(dma_sg) +=3D cnt;
+			cnt +=3D dma_offset;
+			dma_offset=3D0;	/* only want offset on first chunk */
+			cnt =3D ROUNDUP(cnt, IOVP_SIZE);
+#ifdef CONFIG_PROC_FS
+			ioc->msg_pages +=3D cnt >> IOVP_SHIFT;
+#endif
+			do {
+				sba_io_pdir_entry(pdirp, vaddr);
+				vaddr +=3D IOVP_SIZE;
+				cnt -=3D IOVP_SIZE;
+				pdirp++;
+			} while (cnt > 0);
+		}
+		startsg++;
+	}
+#ifdef DEBUG_LARGE_SG_ENTRIES
+	dump_run_sg =3D 0;
+#endif
+	return(n_mappings);
+}
+
+
+/*
+** Two address ranges are DMA contiguous *iff* "end of prev" and
+** "start of next" are both on a page boundry.
+**
+** (shift left is a quick trick to mask off upper bits)
+*/
+#define DMA_CONTIG(__X, __Y) \
+	(((((unsigned long) __X) | ((unsigned long) __Y)) << (BITS_PER_LONG - PAG=
E_SHIFT)) =3D 0UL)
+
+
+/**
+ * sba_coalesce_chunks - preprocess the SG list
+ * @ioc: IO MMU structure which owns the pdir we are interested in.
+ * @startsg:  list of IOVA/size pairs
+ * @nents: number of entries in startsg list
+ *
+ * First pass is to walk the SG list and determine where the breaks are
+ * in the DMA stream. Allocates PDIR entries but does not fill them.
+ * Returns the number of DMA chunks.
+ *
+ * Doing the fill seperate from the coalescing/allocation keeps the
+ * code simpler. Future enhancement could make one pass through
+ * the sglist do both.
+ */
+static SBA_INLINE int
+sba_coalesce_chunks( struct ioc *ioc,
+	struct scatterlist *startsg,
+	int nents)
+{
+	struct scatterlist *vcontig_sg;    /* VCONTIG chunk head */
+	unsigned long vcontig_len;         /* len of VCONTIG chunk */
+	unsigned long vcontig_end;
+	struct scatterlist *dma_sg;        /* next DMA stream head */
+	unsigned long dma_offset, dma_len; /* start/len of DMA stream */
+	int n_mappings =3D 0;
+
+	while (nents > 0) {
+		unsigned long vaddr =3D (unsigned long) (startsg->address);=20
+
+		/*
+		** Prepare for first/next DMA stream
+		*/
+		dma_sg =3D vcontig_sg =3D startsg;
+		dma_len =3D vcontig_len =3D vcontig_end =3D sba_sg_len(startsg);
+		vcontig_end +=3D  vaddr;
+		dma_offset =3D vaddr & ~IOVP_MASK;
+
+		/* PARANOID: clear entries */
+		sba_sg_buffer(startsg) =3D sba_sg_iova(startsg);
+		sba_sg_iova(startsg) =3D 0;
+		sba_sg_len(startsg) =3D 0;
+
+		/*
+		** This loop terminates one iteration "early" since
+		** it's always looking one "ahead".
+		*/
+		while (--nents > 0) {
+			unsigned long vaddr;	/* tmp */
+
+			startsg++;
+
+			/* catch brokenness in SCSI layer */
+			ASSERT(startsg->length <=3D DMA_CHUNK_SIZE);
+
+			/*
+			** First make sure current dma stream won't
+			** exceed DMA_CHUNK_SIZE if we coalesce the
+			** next entry.
+			*/
+			if (((dma_len + dma_offset + startsg->length + ~IOVP_MASK) & IOVP_MASK)=
 > DMA_CHUNK_SIZE)
+				break;
+
+			/*
+			** Then look for virtually contiguous blocks.
+			**
+			** append the next transaction?
+			*/
+			vaddr =3D (unsigned long) sba_sg_iova(startsg);
+			if  (vcontig_end =3D vaddr)
+			{
+				vcontig_len +=3D sba_sg_len(startsg);
+				vcontig_end +=3D sba_sg_len(startsg);
+				dma_len     +=3D sba_sg_len(startsg);
+				sba_sg_buffer(startsg) =3D (char *)vaddr;
+				sba_sg_iova(startsg) =3D 0;
+				sba_sg_len(startsg) =3D 0;
+				continue;
+			}
+
+#ifdef DEBUG_LARGE_SG_ENTRIES
+			dump_run_sg =3D (vcontig_len > IOVP_SIZE);
+#endif
+
+			/*
+			** Not virtually contigous.
+			** Terminate prev chunk.
+			** Start a new chunk.
+			**
+			** Once we start a new VCONTIG chunk, dma_offset
+			** can't change. And we need the offset from the first
+			** chunk - not the last one. Ergo Successive chunks
+			** must start on page boundaries and dove tail
+			** with it's predecessor.
+			*/
+			sba_sg_len(vcontig_sg) =3D vcontig_len;
+
+			vcontig_sg =3D startsg;
+			vcontig_len =3D sba_sg_len(startsg);
+
+			/*
+			** 3) do the entries end/start on page boundaries?
+			**    Don't update vcontig_end until we've checked.
+			*/
+			if (DMA_CONTIG(vcontig_end, vaddr))
+			{
+				vcontig_end =3D vcontig_len + vaddr;
+				dma_len +=3D vcontig_len;
+				sba_sg_buffer(startsg) =3D (char *)vaddr;
+				sba_sg_iova(startsg) =3D 0;
+				continue;
+			} else {
+				break;
+			}
+		}
+
+		/*
+		** End of DMA Stream
+		** Terminate last VCONTIG block.
+		** Allocate space for DMA stream.
+		*/
+		sba_sg_len(vcontig_sg) =3D vcontig_len;
+		dma_len =3D (dma_len + dma_offset + ~IOVP_MASK) & IOVP_MASK;
+		ASSERT(dma_len <=3D DMA_CHUNK_SIZE);
+		sba_sg_iova(dma_sg) =3D (char *) (PIDE_FLAG=20
+			| (sba_alloc_range(ioc, dma_len) << IOVP_SHIFT)
+			| dma_offset);
+		n_mappings++;
+	}
+
+	return n_mappings;
+}
+
+
+/**
+ * sba_map_sg - map Scatter/Gather list
+ * @dev: instance of PCI owned by the driver that's asking.
+ * @sglist:  array of buffer/length pairs
+ * @nents:  number of entries in list
+ * @direction:  R/W or both.
+ *
+ * See Documentation/DMA-mapping.txt
+ */
+int sba_map_sg(struct pci_dev *dev, struct scatterlist *sglist, int nents,
+		int direction)
+{
+	struct ioc *ioc;
+	int coalesced, filled =3D 0;
+	unsigned long flags;
+#ifdef ALLOW_IOV_BYPASS
+	struct scatterlist *sg;
+#endif
+
+	DBG_RUN_SG("%s() START %d entries\n", __FUNCTION__, nents);
+	ioc =3D GET_IOC(dev);
+	ASSERT(ioc);
+
+#ifdef ALLOW_IOV_BYPASS
+	if (dev->dma_mask >=3D ioc->dma_mask) {
+		for (sg =3D sglist ; filled < nents ; filled++, sg++){
+			sba_sg_buffer(sg) =3D sba_sg_iova(sg);
+			sba_sg_iova(sg) =3D (char *)virt_to_phys(sba_sg_buffer(sg));
+		}
+#ifdef CONFIG_PROC_FS
+		spin_lock_irqsave(&ioc->res_lock, flags);
+		ioc->msg_bypass++;
+		spin_unlock_irqrestore(&ioc->res_lock, flags);
+#endif
+		return filled;
+	}
+#endif
+	/* Fast path single entry scatterlists. */
+	if (nents =3D 1) {
+		sba_sg_buffer(sglist) =3D sba_sg_iova(sglist);
+		sba_sg_iova(sglist) =3D (char *)sba_map_single(dev,
+						sba_sg_buffer(sglist),
+						sba_sg_len(sglist), direction);
+#ifdef CONFIG_PROC_FS
+		/*
+		** Should probably do some stats counting, but trying to
+		** be precise quickly starts wasting CPU time.
+		*/
+#endif
+		return 1;
+	}
+
+	spin_lock_irqsave(&ioc->res_lock, flags);
+
+#ifdef ASSERT_PDIR_SANITY
+	if (sba_check_pdir(ioc,"Check before sba_map_sg()"))
+	{
+		sba_dump_sg(ioc, sglist, nents);
+		panic("Check before sba_map_sg()");
+	}
+#endif
+
+#ifdef CONFIG_PROC_FS
+	ioc->msg_calls++;
+#endif
+
+	/*
+	** First coalesce the chunks and allocate I/O pdir space
+	**
+	** If this is one DMA stream, we can properly map using the
+	** correct virtual address associated with each DMA page.
+	** w/o this association, we wouldn't have coherent DMA!
+	** Access to the virtual address is what forces a two pass algorithm.
+	*/
+	coalesced =3D sba_coalesce_chunks(ioc, sglist, nents);
+=20
+	/*
+	** Program the I/O Pdir
+	**
+	** map the virtual addresses to the I/O Pdir
+	** o dma_address will contain the pdir index
+	** o dma_len will contain the number of bytes to map=20
+	** o address contains the virtual address.
+	*/
+	filled =3D sba_fill_pdir(ioc, sglist, nents);
+
+#ifdef ASSERT_PDIR_SANITY
+	if (sba_check_pdir(ioc,"Check after sba_map_sg()"))
+	{
+		sba_dump_sg(ioc, sglist, nents);
+		panic("Check after sba_map_sg()\n");
+	}
+#endif
+
+	spin_unlock_irqrestore(&ioc->res_lock, flags);
+
+	ASSERT(coalesced =3D filled);
+	DBG_RUN_SG("%s() DONE %d mappings\n", __FUNCTION__, filled);
+
+	return filled;
+}
+
+
+/**
+ * sba_unmap_sg - unmap Scatter/Gather list
+ * @dev: instance of PCI owned by the driver that's asking.
+ * @sglist:  array of buffer/length pairs
+ * @nents:  number of entries in list
+ * @direction:  R/W or both.
+ *
+ * See Documentation/DMA-mapping.txt
+ */
+void sba_unmap_sg(struct pci_dev *dev, struct scatterlist *sglist, int nen=
ts,
+		int direction)
+{
+	struct ioc *ioc;
+#ifdef ASSERT_PDIR_SANITY
+	unsigned long flags;
+#endif
+
+	DBG_RUN_SG("%s() START %d entries,  %p,%x\n",
+		__FUNCTION__, nents, sba_sg_buffer(sglist), sglist->length);
+
+	ioc =3D GET_IOC(dev);
+	ASSERT(ioc);
+
+#ifdef CONFIG_PROC_FS
+	ioc->usg_calls++;
+#endif
+
+#ifdef ASSERT_PDIR_SANITY
+	spin_lock_irqsave(&ioc->res_lock, flags);
+	sba_check_pdir(ioc,"Check before sba_unmap_sg()");
+	spin_unlock_irqrestore(&ioc->res_lock, flags);
+#endif
+
+	while (sba_sg_len(sglist) && nents--) {
+
+		sba_unmap_single(dev, (dma_addr_t)sba_sg_iova(sglist),
+		                 sba_sg_len(sglist), direction);
+#ifdef CONFIG_PROC_FS
+		/*
+		** This leaves inconsistent data in the stats, but we can't
+		** tell which sg lists were mapped by map_single and which
+		** were coalesced to a single entry.  The stats are fun,
+		** but speed is more important.
+		*/
+		ioc->usg_pages +=3D (((u64)sba_sg_iova(sglist) & ~IOVP_MASK) + sba_sg_le=
n(sglist) + IOVP_SIZE - 1) >> PAGE_SHIFT;
+#endif
+		++sglist;
+	}
+
+	DBG_RUN_SG("%s() DONE (nents %d)\n", __FUNCTION__,  nents);
+
+#ifdef ASSERT_PDIR_SANITY
+	spin_lock_irqsave(&ioc->res_lock, flags);
+	sba_check_pdir(ioc,"Check after sba_unmap_sg()");
+	spin_unlock_irqrestore(&ioc->res_lock, flags);
+#endif
+
+}
+
+unsigned long
+sba_dma_address (struct scatterlist *sg)
+{
+	return ((unsigned long)sba_sg_iova(sg));
+}
+
+/**************************************************************
+*
+*   Initialization and claim
+*
+***************************************************************/
+
+
+static void
+sba_ioc_init(struct sba_device *sba_dev, struct ioc *ioc, int ioc_num)
+{
+	u32 iova_space_size, iova_space_mask;
+	void * pdir_base;
+	int pdir_size, iov_order, tcnfg;
+
+	/*
+	** Firmware programs the maximum IOV space size into the imask reg
+	*/
+	iova_space_size =3D ~(READ_REG(ioc->ioc_hpa + IOC_IMASK) & 0xFFFFFFFFUL) =
+ 1;
+#ifdef CONFIG_IA64_HP_PROTO
+	if (!iova_space_size)
+		iova_space_size =3D GB(1);
+#endif
+
+	/*
+	** iov_order is always based on a 1GB IOVA space since we want to
+	** turn on the other half for AGP GART.
+	*/
+	iov_order =3D get_order(iova_space_size >> (IOVP_SHIFT-PAGE_SHIFT));
+	ioc->pdir_size =3D pdir_size =3D (iova_space_size/IOVP_SIZE) * sizeof(u64=
);
+
+	DBG_INIT("%s() hpa 0x%lx IOV %dMB (%d bits) PDIR size 0x%0x\n",
+		__FUNCTION__, ioc->ioc_hpa, iova_space_size>>20,
+		iov_order + PAGE_SHIFT, ioc->pdir_size);
+
+	/* FIXME : DMA HINTs not used */
+	ioc->hint_shift_pdir =3D iov_order + PAGE_SHIFT;
+	ioc->hint_mask_pdir =3D ~(0x3 << (iov_order + PAGE_SHIFT));
+
+	ioc->pdir_base +	pdir_base =3D (void *) __get_free_pages(GFP_KERNEL, get_=
order(pdir_size));
+	if (NULL =3D pdir_base)
+	{
+		panic(__FILE__ ":%s() could not allocate I/O Page Table\n", __FUNCTION__=
);
+	}
+	memset(pdir_base, 0, pdir_size);
+
+	DBG_INIT("%s() pdir %p size %x hint_shift_pdir %x hint_mask_pdir %lx\n",
+		__FUNCTION__, pdir_base, pdir_size,
+		ioc->hint_shift_pdir, ioc->hint_mask_pdir);
+
+	ASSERT((((unsigned long) pdir_base) & PAGE_MASK) =3D (unsigned long) pdir=
_base);
+	WRITE_REG(virt_to_phys(pdir_base), ioc->ioc_hpa + IOC_PDIR_BASE);
+
+	DBG_INIT(" base %p\n", pdir_base);
+
+	/* build IMASK for IOC and Elroy */
+	iova_space_mask =3D  0xffffffff;
+	iova_space_mask <<=3D (iov_order + PAGE_SHIFT);
+
+#ifdef CONFIG_IA64_HP_PROTO
+	/*
+	** REVISIT - this is a kludge, but we won't be supporting anything but
+	** zx1 2.0 or greater for real.  When fw is in shape, ibase will
+	** be preprogrammed w/ the IOVA hole base and imask will give us
+	** the size.
+	*/
+	if ((sba_dev->hw_rev & 0xFF) < 0x20) {
+		DBG_INIT("%s() Found SBA rev < 2.0, setting IOVA base to 0.  This device=
 will not be supported in the future.\n", __FUNCTION__);
+		ioc->ibase =3D 0x0;
+	} else
+#endif
+	ioc->ibase =3D READ_REG(ioc->ioc_hpa + IOC_IBASE) & 0xFFFFFFFEUL;
+
+	ioc->imask =3D iova_space_mask;	/* save it */
+
+	DBG_INIT("%s() IOV base 0x%lx mask 0x%0lx\n",
+		__FUNCTION__, ioc->ibase, ioc->imask);
+
+	/*
+	** FIXME: Hint registers are programmed with default hint
+	** values during boot, so hints should be sane even if we
+	** can't reprogram them the way drivers want.
+	*/
+
+	WRITE_REG(ioc->imask, ioc->ioc_hpa+IOC_IMASK);
+
+	/*
+	** Setting the upper bits makes checking for bypass addresses
+	** a little faster later on.
+	*/
+	ioc->imask |=3D 0xFFFFFFFF00000000UL;
+
+	/* Set I/O PDIR Page size to system page size */
+	switch (PAGE_SHIFT) {
+		case 12: /* 4K */
+			tcnfg =3D 0;
+			break;
+		case 13: /* 8K */
+			tcnfg =3D 1;
+			break;
+		case 14: /* 16K */
+			tcnfg =3D 2;
+			break;
+		case 16: /* 64K */
+			tcnfg =3D 3;
+			break;
+	}
+	WRITE_REG(tcnfg, ioc->ioc_hpa+IOC_TCNFG);
+
+	/*
+	** Program the IOC's ibase and enable IOVA translation
+	** Bit zero =3D enable bit.
+	*/
+	WRITE_REG(ioc->ibase | 1, ioc->ioc_hpa+IOC_IBASE);
+
+	/*
+	** Clear I/O TLB of any possible entries.
+	** (Yes. This is a bit paranoid...but so what)
+	*/
+	WRITE_REG(0 | 31, ioc->ioc_hpa+IOC_PCOM);
+
+	/*
+	** If an AGP device is present, only use half of the IOV space
+	** for PCI DMA.  Unfortunately we can't know ahead of time
+	** whether GART support will actually be used, for now we
+	** can just key on an AGP device found in the system.
+	** We program the next pdir index after we stop w/ a key for
+	** the GART code to handshake on.
+	*/
+	if (SBA_GET_AGP(sba_dev)) {
+		DBG_INIT("%s() AGP Device found, reserving 512MB for GART support\n", __=
FUNCTION__);
+		ioc->pdir_size /=3D 2;
+		((u64 *)pdir_base)[PDIR_INDEX(iova_space_size/2)] =3D 0x0000badbadc0ffee=
ULL;
+	}
+
+	DBG_INIT("%s() DONE\n", __FUNCTION__);
+}
+
+
+
+/**************************************************************************
+**
+**   SBA initialization code (HW and SW)
+**
+**   o identify SBA chip itself
+**   o FIXME: initialize DMA hints for reasonable defaults
+**
+**************************************************************************/
+
+static void
+sba_hw_init(struct sba_device *sba_dev)
+{=20
+	int i;
+	int num_ioc;
+	u64 dma_mask;
+	u32 func_id;
+
+	/*
+	** Identify the SBA so we can set the dma_mask.  We can make a virtual
+	** dma_mask of the memory subsystem such that devices not implmenting
+	** a full 64bit mask might still be able to bypass efficiently.
+	*/
+	func_id =3D READ_REG(sba_dev->sba_hpa + SBA_FUNC_ID);
+
+	if (func_id =3D ZX1_FUNC_ID_VALUE) {
+		dma_mask =3D 0xFFFFFFFFFFUL;
+	} else {
+		dma_mask =3D 0xFFFFFFFFFFFFFFFFUL;
+	}
+
+	DBG_INIT("%s(): ioc->dma_mask =3D 0x%lx\n", __FUNCTION__, dma_mask);
+=09
+	/*
+	** Leaving in the multiple ioc code from parisc for the future,
+	** currently there are no muli-ioc mckinley sbas
+	*/
+	sba_dev->ioc[0].ioc_hpa =3D SBA_IOC_OFFSET;
+	num_ioc =3D 1;
+
+	sba_dev->num_ioc =3D num_ioc;
+	for (i =3D 0; i < num_ioc; i++) {
+		sba_dev->ioc[i].dma_mask =3D dma_mask;
+		sba_dev->ioc[i].ioc_hpa +=3D sba_dev->sba_hpa;
+		sba_ioc_init(sba_dev, &(sba_dev->ioc[i]), i);
+	}
+}
+
+static void
+sba_common_init(struct sba_device *sba_dev)
+{
+	int i;
+
+	/* add this one to the head of the list (order doesn't matter)
+	** This will be useful for debugging - especially if we get coredumps
+	*/
+	sba_dev->next =3D sba_list;
+	sba_list =3D sba_dev;
+	sba_count++;
+
+	for(i=3D0; i< sba_dev->num_ioc; i++) {
+		int res_size;
+
+		/* resource map size dictated by pdir_size */
+		res_size =3D sba_dev->ioc[i].pdir_size/sizeof(u64); /* entries */
+		res_size >>=3D 3;  /* convert bit count to byte count */
+		DBG_INIT("%s() res_size 0x%x\n",
+			__FUNCTION__, res_size);
+
+		sba_dev->ioc[i].res_size =3D res_size;
+		sba_dev->ioc[i].res_map =3D (char *) __get_free_pages(GFP_KERNEL, get_or=
der(res_size));
+
+		if (NULL =3D sba_dev->ioc[i].res_map)
+		{
+			panic(__FILE__ ":%s() could not allocate resource map\n", __FUNCTION__ =
);
+		}
+
+		memset(sba_dev->ioc[i].res_map, 0, res_size);
+		/* next available IOVP - circular search */
+		if ((sba_dev->hw_rev & 0xFF) >=3D 0x20) {
+			sba_dev->ioc[i].res_hint =3D (unsigned long *)
+			    sba_dev->ioc[i].res_map;
+		} else {
+			u64 reserved_iov;
+		=09
+			/* Yet another 1.x hack */
+			printk("zx1 1.x: Starting resource hint offset into IOV space to avoid =
initial zero value IOVA\n");
+			sba_dev->ioc[i].res_hint =3D (unsigned long *)
+			    &(sba_dev->ioc[i].res_map[L1_CACHE_BYTES]);
+
+			sba_dev->ioc[i].res_map[0] =3D 0x1;
+			sba_dev->ioc[i].pdir_base[0] =3D 0x8000badbadc0ffeeULL;
+
+			for (reserved_iov =3D 0xA0000 ; reserved_iov < 0xC0000 ; reserved_iov +=
=3D IOVP_SIZE) {
+				u64 *res_ptr =3D sba_dev->ioc[i].res_map;
+				int index =3D PDIR_INDEX(reserved_iov);
+				int res_word;
+				u64 mask;
+
+				res_word =3D (int)(index / BITS_PER_LONG);
+				mask =3D  0x1UL << (index - (res_word * BITS_PER_LONG));
+				res_ptr[res_word] |=3D mask;
+				sba_dev->ioc[i].pdir_base[PDIR_INDEX(reserved_iov)] =3D (0x80000000000=
000FFULL | reserved_iov);
+
+			}
+		}
+
+#ifdef ASSERT_PDIR_SANITY
+		/* Mark first bit busy - ie no IOVA 0 */
+		sba_dev->ioc[i].res_map[0] =3D 0x1;
+		sba_dev->ioc[i].pdir_base[0] =3D 0x8000badbadc0ffeeULL;
+#endif
+
+		DBG_INIT("%s() %d res_map %x %p\n", __FUNCTION__,
+		         i, res_size, (void *)sba_dev->ioc[i].res_map);
+	}
+
+	sba_dev->sba_lock =3D SPIN_LOCK_UNLOCKED;
+}
+
+#ifdef CONFIG_PROC_FS
+static int sba_proc_info(char *buf, char **start, off_t offset, int len)
+{
+	struct sba_device *sba_dev =3D sba_list;
+	struct ioc *ioc =3D &sba_dev->ioc[0];	/* FIXME: Multi-IOC support! */
+	int total_pages =3D (int) (ioc->res_size << 3); /* 8 bits per byte */
+	unsigned long i =3D 0, avg =3D 0, min, max;
+
+	sprintf(buf, "%s rev %d.%d\n",
+		"Hewlett Packard zx1 SBA",
+		((sba_dev->hw_rev >> 4) & 0xF),
+		(sba_dev->hw_rev & 0xF)
+		);
+	sprintf(buf, "%sIO PDIR size    : %d bytes (%d entries)\n",
+		buf,
+		(int) ((ioc->res_size << 3) * sizeof(u64)), /* 8 bits/byte */
+		total_pages);
+
+	sprintf(buf, "%sIO PDIR entries : %ld free  %ld used (%d%%)\n", buf,
+		total_pages - ioc->used_pages, ioc->used_pages,
+		(int) (ioc->used_pages * 100 / total_pages));
+=09
+	sprintf(buf, "%sResource bitmap : %d bytes (%d pages)\n",=20
+		buf, ioc->res_size, ioc->res_size << 3);   /* 8 bits per byte */
+
+	min =3D max =3D ioc->avg_search[0];
+	for (i =3D 0; i < SBA_SEARCH_SAMPLE; i++) {
+		avg +=3D ioc->avg_search[i];
+		if (ioc->avg_search[i] > max) max =3D ioc->avg_search[i];
+		if (ioc->avg_search[i] < min) min =3D ioc->avg_search[i];
+	}
+	avg /=3D SBA_SEARCH_SAMPLE;
+	sprintf(buf, "%s  Bitmap search : %ld/%ld/%ld (min/avg/max CPU Cycles)\n",
+		buf, min, avg, max);
+
+	sprintf(buf, "%spci_map_single(): %12ld calls  %12ld pages (avg %d/1000)\=
n",
+		buf, ioc->msingle_calls, ioc->msingle_pages,
+		(int) ((ioc->msingle_pages * 1000)/ioc->msingle_calls));
+#ifdef ALLOW_IOV_BYPASS
+	sprintf(buf, "%spci_map_single(): %12ld bypasses\n",
+	        buf, ioc->msingle_bypass);
+#endif
+
+	sprintf(buf, "%spci_unmap_single: %12ld calls  %12ld pages (avg %d/1000)\=
n",
+		buf, ioc->usingle_calls, ioc->usingle_pages,
+		(int) ((ioc->usingle_pages * 1000)/ioc->usingle_calls));
+#ifdef ALLOW_IOV_BYPASS
+	sprintf(buf, "%spci_unmap_single: %12ld bypasses\n",
+	        buf, ioc->usingle_bypass);
+#endif
+
+	sprintf(buf, "%spci_map_sg()    : %12ld calls  %12ld pages (avg %d/1000)\=
n",
+		buf, ioc->msg_calls, ioc->msg_pages,
+		(int) ((ioc->msg_pages * 1000)/ioc->msg_calls));
+#ifdef ALLOW_IOV_BYPASS
+	sprintf(buf, "%spci_map_sg()    : %12ld bypasses\n",
+	        buf, ioc->msg_bypass);
+#endif
+
+	sprintf(buf, "%spci_unmap_sg()  : %12ld calls  %12ld pages (avg %d/1000)\=
n",
+		buf, ioc->usg_calls, ioc->usg_pages,
+		(int) ((ioc->usg_pages * 1000)/ioc->usg_calls));
+
+	return strlen(buf);
+}
+
+static int
+sba_resource_map(char *buf, char **start, off_t offset, int len)
+{
+	struct ioc *ioc =3D sba_list->ioc;	/* FIXME: Multi-IOC support! */
+	unsigned int *res_ptr =3D (unsigned int *)ioc->res_map;
+	int i;
+
+	buf[0] =3D '\0';
+	for(i =3D 0; i < (ioc->res_size / sizeof(unsigned int)); ++i, ++res_ptr) {
+		if ((i & 7) =3D 0)
+		    strcat(buf,"\n   ");
+		sprintf(buf, "%s %08x", buf, *res_ptr);
+	}
+	strcat(buf, "\n");
+
+	return strlen(buf);
+}
+#endif
+
+/*
+** Determine if sba should claim this chip (return 0) or not (return 1).
+** If so, initialize the chip and tell other partners in crime they
+** have work to do.
+*/
+void __init sba_init(void)
+{
+	struct sba_device *sba_dev;
+	u32 func_id, hw_rev;
+	u32 *func_offset =3D NULL;
+	int i, agp_found =3D 0;
+	static char sba_rev[6];
+	struct pci_dev *device =3D NULL;
+	u64 hpa =3D 0;
+
+	if (!(device =3D pci_find_device(PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_ZX1_S=
BA, NULL)))
+		return;
+
+	for (i =3D 0; i < PCI_NUM_RESOURCES; i++) {
+		if (pci_resource_flags(device, i) =3D IORESOURCE_MEM) {
+			hpa =3D ioremap(pci_resource_start(device, i),
+				pci_resource_len(device, i));
+			break;
+		}
+	}
+
+	func_id =3D READ_REG(hpa + SBA_FUNC_ID);
+
+	if (func_id =3D ZX1_FUNC_ID_VALUE) {
+		(void)strcpy(sba_rev, "zx1");
+		func_offset =3D zx1_func_offsets;
+	} else {
+		return;
+	}
+
+	/* Read HW Rev First */
+	hw_rev =3D READ_REG(hpa + SBA_FCLASS) & 0xFFUL;
+
+	/*
+	 * Not all revision registers of the chipset are updated on every
+	 * turn.  Must scan through all functions looking for the highest rev
+	 */
+	if (func_offset) {
+		for (i =3D 0 ; func_offset[i] !=3D -1 ; i++) {
+			u32 func_rev;
+
+			func_rev =3D READ_REG(hpa + SBA_FCLASS + func_offset[i]) & 0xFFUL;
+			DBG_INIT("%s() func offset: 0x%x rev: 0x%x\n",
+			         __FUNCTION__, func_offset[i], func_rev);
+			if (func_rev > hw_rev)
+				hw_rev =3D func_rev;
+		}
+	}
+
+	printk(KERN_INFO "%s found %s %d.%d at %s, HPA 0x%lx\n", DRIVER_NAME,
+	       sba_rev, ((hw_rev >> 4) & 0xF), (hw_rev & 0xF),
+	       device->slot_name, hpa);
+
+	if ((hw_rev & 0xFF) < 0x20) {
+		printk(KERN_INFO "%s WARNING rev 2.0 or greater will be required for IO =
MMU support in the future\n", DRIVER_NAME);
+#ifndef CONFIG_IA64_HP_PROTO
+		panic("%s: CONFIG_IA64_HP_PROTO MUST be enabled to support SBA rev less =
than 2.0", DRIVER_NAME);
+#endif
+	}
+
+	sba_dev =3D kmalloc(sizeof(struct sba_device), GFP_KERNEL);
+	if (NULL =3D sba_dev) {
+		printk(KERN_ERR DRIVER_NAME " - couldn't alloc sba_device\n");
+		return;
+	}
+
+	memset(sba_dev, 0, sizeof(struct sba_device));
+
+	for(i=3D0; i<MAX_IOC; i++)
+		spin_lock_init(&(sba_dev->ioc[i].res_lock));
+
+	sba_dev->hw_rev =3D hw_rev;
+	sba_dev->sba_hpa =3D hpa;
+
+	/*
+	 * We need to check for an AGP device, if we find one, then only
+	 * use part of the IOVA space for PCI DMA, the rest is for GART.
+	 * REVISIT for multiple IOC.
+	 */
+	pci_for_each_dev(device)
+		agp_found |=3D pci_find_capability(device, PCI_CAP_ID_AGP);
+
+	if (agp_found && reserve_sba_gart)
+		SBA_SET_AGP(sba_dev);
+
+	sba_hw_init(sba_dev);
+	sba_common_init(sba_dev);
+
+#ifdef CONFIG_PROC_FS
+	{
+		struct proc_dir_entry * proc_mckinley_root;
+
+		proc_mckinley_root =3D proc_mkdir("bus/mckinley",0);
+		create_proc_info_entry(sba_rev, 0, proc_mckinley_root, sba_proc_info);
+		create_proc_info_entry("bitmap", 0, proc_mckinley_root, sba_resource_map=
);
+	}
+#endif
+}
+
+static int __init
+nosbagart (char *str)
+{
+	reserve_sba_gart =3D 0;
+	return 1;
+}
+
+__setup("nosbagart",nosbagart);
+
+EXPORT_SYMBOL(sba_init);
+EXPORT_SYMBOL(sba_map_single);
+EXPORT_SYMBOL(sba_unmap_single);
+EXPORT_SYMBOL(sba_map_sg);
+EXPORT_SYMBOL(sba_unmap_sg);
+EXPORT_SYMBOL(sba_dma_address);
+EXPORT_SYMBOL(sba_alloc_consistent);
+EXPORT_SYMBOL(sba_free_consistent);
diff -urN linux-davidm/arch/ia64/hp/hpsim_console.c lia64-2.4/arch/ia64/hp/=
hpsim_console.c
--- linux-davidm/arch/ia64/hp/hpsim_console.c	Thu Oct 12 14:20:48 2000
+++ lia64-2.4/arch/ia64/hp/hpsim_console.c	Wed Dec 31 16:00:00 1969
@@ -1,74 +0,0 @@
-/*
- * Platform dependent support for HP simulator.
- *
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 1999 Vijay Chander <vijay@engr.sgi.com>
- */
-#include <linux/init.h>
-#include <linux/kernel.h>
-#include <linux/param.h>
-#include <linux/string.h>
-#include <linux/types.h>
-#include <linux/kdev_t.h>
-#include <linux/console.h>
-
-#include <asm/delay.h>
-#include <asm/irq.h>
-#include <asm/pal.h>
-#include <asm/machvec.h>
-#include <asm/pgtable.h>
-#include <asm/sal.h>
-
-#include "hpsim_ssc.h"
-
-static int simcons_init (struct console *, char *);
-static void simcons_write (struct console *, const char *, unsigned);
-static int simcons_wait_key (struct console *);
-static kdev_t simcons_console_device (struct console *);
-
-struct console hpsim_cons =3D {
-	name:		"simcons",
-	write:		simcons_write,
-	device:		simcons_console_device,
-	wait_key:	simcons_wait_key,
-	setup:		simcons_init,
-	flags:		CON_PRINTBUFFER,
-	index:		-1,
-};
-
-static int
-simcons_init (struct console *cons, char *options)
-{
-	return 0;
-}
-
-static void
-simcons_write (struct console *cons, const char *buf, unsigned count)
-{
-	unsigned long ch;
-
-	while (count-- > 0) {
-		ch =3D *buf++;
-		ia64_ssc(ch, 0, 0, 0, SSC_PUTCHAR);
-		if (ch =3D '\n')
-		  ia64_ssc('\r', 0, 0, 0, SSC_PUTCHAR);
-	}
-}
-
-static int
-simcons_wait_key (struct console *cons)
-{
-	char ch;
-
-	do {
-		ch =3D ia64_ssc(0, 0, 0, 0, SSC_GETCHAR);
-	} while (ch =3D '\0');
-	return ch;
-}
-
-static kdev_t
-simcons_console_device (struct console *c)
-{
-	return MKDEV(TTY_MAJOR, 64 + c->index);
-}
diff -urN linux-davidm/arch/ia64/hp/hpsim_irq.c lia64-2.4/arch/ia64/hp/hpsi=
m_irq.c
--- linux-davidm/arch/ia64/hp/hpsim_irq.c	Thu Apr  5 12:51:47 2001
+++ lia64-2.4/arch/ia64/hp/hpsim_irq.c	Wed Dec 31 16:00:00 1969
@@ -1,46 +0,0 @@
-/*
- * Platform dependent support for HP simulator.
- *
- * Copyright (C) 1998-2001 Hewlett-Packard Co
- * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
- */
-
-#include <linux/init.h>
-#include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/irq.h>
-
-static unsigned int
-hpsim_irq_startup (unsigned int irq)
-{
-	return 0;
-}
-
-static void
-hpsim_irq_noop (unsigned int irq)
-{
-}
-
-static struct hw_interrupt_type irq_type_hp_sim =3D {
-	typename:	"hpsim",
-	startup:	hpsim_irq_startup,
-	shutdown:	hpsim_irq_noop,
-	enable:		hpsim_irq_noop,
-	disable:	hpsim_irq_noop,
-	ack:		hpsim_irq_noop,
-	end:		hpsim_irq_noop,
-	set_affinity:	(void (*)(unsigned int, unsigned long)) hpsim_irq_noop,
-};
-
-void __init
-hpsim_irq_init (void)
-{
-	irq_desc_t *idesc;
-	int i;
-
-	for (i =3D 0; i < NR_IRQS; ++i) {
-		idesc =3D irq_desc(i);
-		if (idesc->handler =3D &no_irq_type)
-			idesc->handler =3D &irq_type_hp_sim;
-	}
-}
diff -urN linux-davidm/arch/ia64/hp/hpsim_machvec.c lia64-2.4/arch/ia64/hp/=
hpsim_machvec.c
--- linux-davidm/arch/ia64/hp/hpsim_machvec.c	Fri Aug 11 19:09:06 2000
+++ lia64-2.4/arch/ia64/hp/hpsim_machvec.c	Wed Dec 31 16:00:00 1969
@@ -1,2 +0,0 @@
-#define MACHVEC_PLATFORM_NAME	hpsim
-#include <asm/machvec_init.h>
diff -urN linux-davidm/arch/ia64/hp/hpsim_setup.c lia64-2.4/arch/ia64/hp/hp=
sim_setup.c
--- linux-davidm/arch/ia64/hp/hpsim_setup.c	Tue Jul 31 10:30:08 2001
+++ lia64-2.4/arch/ia64/hp/hpsim_setup.c	Wed Dec 31 16:00:00 1969
@@ -1,58 +0,0 @@
-/*
- * Platform dependent support for HP simulator.
- *
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 1999 Vijay Chander <vijay@engr.sgi.com>
- */
-#include <linux/init.h>
-#include <linux/kernel.h>
-#include <linux/param.h>
-#include <linux/string.h>
-#include <linux/types.h>
-#include <linux/kdev_t.h>
-#include <linux/console.h>
-
-#include <asm/delay.h>
-#include <asm/irq.h>
-#include <asm/pal.h>
-#include <asm/machvec.h>
-#include <asm/pgtable.h>
-#include <asm/sal.h>
-
-#include "hpsim_ssc.h"
-
-extern struct console hpsim_cons;
-
-/*
- * Simulator system call.
- */
-asm (".text\n"
-     ".align 32\n"
-     ".global ia64_ssc\n"
-     ".proc ia64_ssc\n"
-     "ia64_ssc:\n"
-     "mov r15=3Dr36\n"
-     "break 0x80001\n"
-     "br.ret.sptk.many rp\n"
-     ".endp\n");
-
-void
-ia64_ssc_connect_irq (long intr, long irq)
-{
-	ia64_ssc(intr, irq, 0, 0, SSC_CONNECT_INTERRUPT);
-}
-
-void
-ia64_ctl_trace (long on)
-{
-	ia64_ssc(on, 0, 0, 0, SSC_CTL_TRACE);
-}
-
-void __init
-hpsim_setup (char **cmdline_p)
-{
-	ROOT_DEV =3D to_kdev_t(0x0801);		/* default to first SCSI drive */
-
-	register_console (&hpsim_cons);
-}
diff -urN linux-davidm/arch/ia64/hp/hpsim_ssc.h lia64-2.4/arch/ia64/hp/hpsi=
m_ssc.h
--- linux-davidm/arch/ia64/hp/hpsim_ssc.h	Sun Feb  6 18:42:40 2000
+++ lia64-2.4/arch/ia64/hp/hpsim_ssc.h	Wed Dec 31 16:00:00 1969
@@ -1,36 +0,0 @@
-/*
- * Platform dependent support for HP simulator.
- *
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 1999 Vijay Chander <vijay@engr.sgi.com>
- */
-#ifndef _IA64_PLATFORM_HPSIM_SSC_H
-#define _IA64_PLATFORM_HPSIM_SSC_H
-
-/* Simulator system calls: */
-
-#define SSC_CONSOLE_INIT		20
-#define SSC_GETCHAR			21
-#define SSC_PUTCHAR			31
-#define SSC_CONNECT_INTERRUPT		58
-#define SSC_GENERATE_INTERRUPT		59
-#define SSC_SET_PERIODIC_INTERRUPT	60
-#define SSC_GET_RTC			65
-#define SSC_EXIT			66
-#define SSC_LOAD_SYMBOLS		69
-#define SSC_GET_TOD			74
-#define SSC_CTL_TRACE			76
-
-#define SSC_NETDEV_PROBE		100
-#define SSC_NETDEV_SEND			101
-#define SSC_NETDEV_RECV			102
-#define SSC_NETDEV_ATTACH		103
-#define SSC_NETDEV_DETACH		104
-
-/*
- * Simulator system call.
- */
-extern long ia64_ssc (long arg0, long arg1, long arg2, long arg3, int nr);
-
-#endif /* _IA64_PLATFORM_HPSIM_SSC_H */
diff -urN linux-davidm/arch/ia64/hp/sim/Makefile lia64-2.4/arch/ia64/hp/sim=
/Makefile
--- linux-davidm/arch/ia64/hp/sim/Makefile	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/arch/ia64/hp/sim/Makefile	Fri Apr  5 16:44:44 2002
@@ -0,0 +1,13 @@
+#
+# ia64/platform/hp/sim/Makefile
+#
+# Copyright (C) 1999 Silicon Graphics, Inc.
+# Copyright (C) Srinivasa Thirumalachar (sprasad@engr.sgi.com)
+#
+
+O_TARGET :=3D sim.o
+
+obj-y :=3D hpsim_console.o hpsim_irq.o hpsim_setup.o
+obj-$(CONFIG_IA64_GENERIC) +=3D hpsim_machvec.o
+
+include $(TOPDIR)/Rules.make
diff -urN linux-davidm/arch/ia64/hp/sim/hpsim_console.c lia64-2.4/arch/ia64=
/hp/sim/hpsim_console.c
--- linux-davidm/arch/ia64/hp/sim/hpsim_console.c	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/arch/ia64/hp/sim/hpsim_console.c	Wed Nov  1 23:10:42 2000
@@ -0,0 +1,74 @@
+/*
+ * Platform dependent support for HP simulator.
+ *
+ * Copyright (C) 1998, 1999 Hewlett-Packard Co
+ * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999 Vijay Chander <vijay@engr.sgi.com>
+ */
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/param.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/kdev_t.h>
+#include <linux/console.h>
+
+#include <asm/delay.h>
+#include <asm/irq.h>
+#include <asm/pal.h>
+#include <asm/machvec.h>
+#include <asm/pgtable.h>
+#include <asm/sal.h>
+
+#include "hpsim_ssc.h"
+
+static int simcons_init (struct console *, char *);
+static void simcons_write (struct console *, const char *, unsigned);
+static int simcons_wait_key (struct console *);
+static kdev_t simcons_console_device (struct console *);
+
+struct console hpsim_cons =3D {
+	name:		"simcons",
+	write:		simcons_write,
+	device:		simcons_console_device,
+	wait_key:	simcons_wait_key,
+	setup:		simcons_init,
+	flags:		CON_PRINTBUFFER,
+	index:		-1,
+};
+
+static int
+simcons_init (struct console *cons, char *options)
+{
+	return 0;
+}
+
+static void
+simcons_write (struct console *cons, const char *buf, unsigned count)
+{
+	unsigned long ch;
+
+	while (count-- > 0) {
+		ch =3D *buf++;
+		ia64_ssc(ch, 0, 0, 0, SSC_PUTCHAR);
+		if (ch =3D '\n')
+		  ia64_ssc('\r', 0, 0, 0, SSC_PUTCHAR);
+	}
+}
+
+static int
+simcons_wait_key (struct console *cons)
+{
+	char ch;
+
+	do {
+		ch =3D ia64_ssc(0, 0, 0, 0, SSC_GETCHAR);
+	} while (ch =3D '\0');
+	return ch;
+}
+
+static kdev_t
+simcons_console_device (struct console *c)
+{
+	return MKDEV(TTY_MAJOR, 64 + c->index);
+}
diff -urN linux-davidm/arch/ia64/hp/sim/hpsim_irq.c lia64-2.4/arch/ia64/hp/=
sim/hpsim_irq.c
--- linux-davidm/arch/ia64/hp/sim/hpsim_irq.c	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/arch/ia64/hp/sim/hpsim_irq.c	Wed Feb 28 14:43:45 2001
@@ -0,0 +1,46 @@
+/*
+ * Platform dependent support for HP simulator.
+ *
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/irq.h>
+
+static unsigned int
+hpsim_irq_startup (unsigned int irq)
+{
+	return 0;
+}
+
+static void
+hpsim_irq_noop (unsigned int irq)
+{
+}
+
+static struct hw_interrupt_type irq_type_hp_sim =3D {
+	typename:	"hpsim",
+	startup:	hpsim_irq_startup,
+	shutdown:	hpsim_irq_noop,
+	enable:		hpsim_irq_noop,
+	disable:	hpsim_irq_noop,
+	ack:		hpsim_irq_noop,
+	end:		hpsim_irq_noop,
+	set_affinity:	(void (*)(unsigned int, unsigned long)) hpsim_irq_noop,
+};
+
+void __init
+hpsim_irq_init (void)
+{
+	irq_desc_t *idesc;
+	int i;
+
+	for (i =3D 0; i < NR_IRQS; ++i) {
+		idesc =3D irq_desc(i);
+		if (idesc->handler =3D &no_irq_type)
+			idesc->handler =3D &irq_type_hp_sim;
+	}
+}
diff -urN linux-davidm/arch/ia64/hp/sim/hpsim_machvec.c lia64-2.4/arch/ia64=
/hp/sim/hpsim_machvec.c
--- linux-davidm/arch/ia64/hp/sim/hpsim_machvec.c	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/arch/ia64/hp/sim/hpsim_machvec.c	Thu Aug 24 08:17:30 2000
@@ -0,0 +1,2 @@
+#define MACHVEC_PLATFORM_NAME	hpsim
+#include <asm/machvec_init.h>
diff -urN linux-davidm/arch/ia64/hp/sim/hpsim_setup.c lia64-2.4/arch/ia64/h=
p/sim/hpsim_setup.c
--- linux-davidm/arch/ia64/hp/sim/hpsim_setup.c	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/arch/ia64/hp/sim/hpsim_setup.c	Wed May 30 22:41:37 2001
@@ -0,0 +1,58 @@
+/*
+ * Platform dependent support for HP simulator.
+ *
+ * Copyright (C) 1998, 1999 Hewlett-Packard Co
+ * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999 Vijay Chander <vijay@engr.sgi.com>
+ */
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/param.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/kdev_t.h>
+#include <linux/console.h>
+
+#include <asm/delay.h>
+#include <asm/irq.h>
+#include <asm/pal.h>
+#include <asm/machvec.h>
+#include <asm/pgtable.h>
+#include <asm/sal.h>
+
+#include "hpsim_ssc.h"
+
+extern struct console hpsim_cons;
+
+/*
+ * Simulator system call.
+ */
+asm (".text\n"
+     ".align 32\n"
+     ".global ia64_ssc\n"
+     ".proc ia64_ssc\n"
+     "ia64_ssc:\n"
+     "mov r15=3Dr36\n"
+     "break 0x80001\n"
+     "br.ret.sptk.many rp\n"
+     ".endp\n");
+
+void
+ia64_ssc_connect_irq (long intr, long irq)
+{
+	ia64_ssc(intr, irq, 0, 0, SSC_CONNECT_INTERRUPT);
+}
+
+void
+ia64_ctl_trace (long on)
+{
+	ia64_ssc(on, 0, 0, 0, SSC_CTL_TRACE);
+}
+
+void __init
+hpsim_setup (char **cmdline_p)
+{
+	ROOT_DEV =3D to_kdev_t(0x0801);		/* default to first SCSI drive */
+
+	register_console (&hpsim_cons);
+}
diff -urN linux-davidm/arch/ia64/hp/sim/hpsim_ssc.h lia64-2.4/arch/ia64/hp/=
sim/hpsim_ssc.h
--- linux-davidm/arch/ia64/hp/sim/hpsim_ssc.h	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/arch/ia64/hp/sim/hpsim_ssc.h	Sun Feb  6 18:42:40 2000
@@ -0,0 +1,36 @@
+/*
+ * Platform dependent support for HP simulator.
+ *
+ * Copyright (C) 1998, 1999 Hewlett-Packard Co
+ * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999 Vijay Chander <vijay@engr.sgi.com>
+ */
+#ifndef _IA64_PLATFORM_HPSIM_SSC_H
+#define _IA64_PLATFORM_HPSIM_SSC_H
+
+/* Simulator system calls: */
+
+#define SSC_CONSOLE_INIT		20
+#define SSC_GETCHAR			21
+#define SSC_PUTCHAR			31
+#define SSC_CONNECT_INTERRUPT		58
+#define SSC_GENERATE_INTERRUPT		59
+#define SSC_SET_PERIODIC_INTERRUPT	60
+#define SSC_GET_RTC			65
+#define SSC_EXIT			66
+#define SSC_LOAD_SYMBOLS		69
+#define SSC_GET_TOD			74
+#define SSC_CTL_TRACE			76
+
+#define SSC_NETDEV_PROBE		100
+#define SSC_NETDEV_SEND			101
+#define SSC_NETDEV_RECV			102
+#define SSC_NETDEV_ATTACH		103
+#define SSC_NETDEV_DETACH		104
+
+/*
+ * Simulator system call.
+ */
+extern long ia64_ssc (long arg0, long arg1, long arg2, long arg3, int nr);
+
+#endif /* _IA64_PLATFORM_HPSIM_SSC_H */
diff -urN linux-davidm/arch/ia64/hp/zx1/Makefile lia64-2.4/arch/ia64/hp/zx1=
/Makefile
--- linux-davidm/arch/ia64/hp/zx1/Makefile	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/arch/ia64/hp/zx1/Makefile	Fri Apr  5 16:44:44 2002
@@ -0,0 +1,13 @@
+#
+# ia64/platform/hp/zx1/Makefile
+#
+# Copyright (C) 2002 Hewlett Packard
+# Copyright (C) Alex Williamson (alex_williamson@hp.com)
+#
+
+O_TARGET :=3D zx1.o
+
+obj-y :=3D hpzx1_misc.o
+obj-$(CONFIG_IA64_GENERIC) +=3D hpzx1_machvec.o
+
+include $(TOPDIR)/Rules.make
diff -urN linux-davidm/arch/ia64/hp/zx1/hpzx1_machvec.c lia64-2.4/arch/ia64=
/hp/zx1/hpzx1_machvec.c
--- linux-davidm/arch/ia64/hp/zx1/hpzx1_machvec.c	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/arch/ia64/hp/zx1/hpzx1_machvec.c	Fri Apr  5 16:44:44 2002
@@ -0,0 +1,2 @@
+#define MACHVEC_PLATFORM_NAME	hpzx1
+#include <asm/machvec_init.h>
diff -urN linux-davidm/arch/ia64/hp/zx1/hpzx1_misc.c lia64-2.4/arch/ia64/hp=
/zx1/hpzx1_misc.c
--- linux-davidm/arch/ia64/hp/zx1/hpzx1_misc.c	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/arch/ia64/hp/zx1/hpzx1_misc.c	Fri Apr  5 23:29:03 2002
@@ -0,0 +1,402 @@
+/*
+ * Misc. support for HP zx1 chipset support
+ *
+ * Copyright (C) 2002 Hewlett-Packard Co
+ * Copyright (C) 2002 Alex Williamson <alex_williamson@hp.com>
+ * Copyright (C) 2002 Bjorn Helgaas <bjorn_helgaas@hp.com>
+ */
+
+
+#include <linux/config.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/pci.h>
+#include <linux/acpi.h>
+#include <asm/iosapic.h>
+#include <asm/efi.h>
+
+#include "../drivers/acpi/include/platform/acgcc.h"
+#include "../drivers/acpi/include/actypes.h"
+#include "../drivers/acpi/include/acexcep.h"
+#include "../drivers/acpi/include/acpixf.h"
+#include "../drivers/acpi/include/actbl.h"
+#include "../drivers/acpi/include/acconfig.h"
+#include "../drivers/acpi/include/acmacros.h"
+#include "../drivers/acpi/include/aclocal.h"
+#include "../drivers/acpi/include/acobject.h"
+#include "../drivers/acpi/include/acstruct.h"
+#include "../drivers/acpi/include/acnamesp.h"
+#include "../drivers/acpi/include/acutils.h"
+
+#define PFX "hpzx1: "
+
+struct fake_pci_dev {
+	struct fake_pci_dev *next;
+	unsigned char bus;
+	unsigned int devfn;
+	int sizing;		// in middle of BAR sizing operation?
+	unsigned long csr_base;
+	unsigned int csr_size;
+	unsigned long mapped_csrs;	// ioremapped
+};
+
+static struct fake_pci_dev *fake_pci_head, **fake_pci_tail =3D &fake_pci_h=
ead;
+
+static struct pci_ops orig_pci_ops;
+
+static inline struct fake_pci_dev *
+fake_pci_find_slot(unsigned char bus, unsigned int devfn)
+{
+	struct fake_pci_dev *dev;
+
+	for (dev =3D fake_pci_head; dev; dev =3D dev->next)
+		if (dev->bus =3D bus && dev->devfn =3D devfn)
+			return dev;
+	return NULL;
+}
+
+static struct fake_pci_dev *
+alloc_fake_pci_dev(void)
+{
+        struct fake_pci_dev *dev;
+
+        dev =3D kmalloc(sizeof(*dev), GFP_KERNEL);
+	if (!dev)
+		return NULL;
+
+	memset(dev, 0, sizeof(*dev));
+
+        *fake_pci_tail =3D dev;
+        fake_pci_tail =3D &dev->next;
+
+        return dev;
+}
+
+#define HP_CFG_RD(sz, bits, name) \
+static int hp_cfg_read##sz (struct pci_dev *dev, int where, u##bits *value=
) \
+{ \
+	struct fake_pci_dev *fake_dev; \
+	if (!(fake_dev =3D fake_pci_find_slot(dev->bus->number, dev->devfn))) \
+		return orig_pci_ops.name(dev, where, value); \
+	\
+	switch (where) { \
+	case PCI_COMMAND: \
+		*value =3D read##sz(fake_dev->mapped_csrs + where); \
+		*value |=3D PCI_COMMAND_MEMORY; /* SBA omits this */ \
+		break; \
+	case PCI_BASE_ADDRESS_0: \
+		if (fake_dev->sizing) \
+			*value =3D ~(fake_dev->csr_size - 1); \
+		else \
+			*value =3D (fake_dev->csr_base & \
+				    PCI_BASE_ADDRESS_MEM_MASK) | \
+				PCI_BASE_ADDRESS_SPACE_MEMORY; \
+		fake_dev->sizing =3D 0; \
+		break; \
+	default: \
+		*value =3D read##sz(fake_dev->mapped_csrs + where); \
+		break; \
+	} \
+	return PCIBIOS_SUCCESSFUL; \
+}
+
+#define HP_CFG_WR(sz, bits, name) \
+static int hp_cfg_write##sz (struct pci_dev *dev, int where, u##bits value=
) \
+{ \
+	struct fake_pci_dev *fake_dev; \
+	if (!(fake_dev =3D fake_pci_find_slot(dev->bus->number, dev->devfn))) \
+		return orig_pci_ops.name(dev, where, value); \
+	\
+	switch (where) { \
+	case PCI_BASE_ADDRESS_0: \
+		if (value =3D ~0) \
+			fake_dev->sizing =3D 1; \
+		break; \
+	default: \
+		write##sz(value, fake_dev->mapped_csrs + where); \
+		break; \
+	} \
+	return PCIBIOS_SUCCESSFUL; \
+}
+
+HP_CFG_RD(b,  8, read_byte)
+HP_CFG_RD(w, 16, read_word)
+HP_CFG_RD(l, 32, read_dword)
+HP_CFG_WR(b,  8, write_byte)
+HP_CFG_WR(w, 16, write_word)
+HP_CFG_WR(l, 32, write_dword)
+
+static struct pci_ops hp_pci_conf =3D {
+	hp_cfg_readb,
+	hp_cfg_readw,
+	hp_cfg_readl,
+	hp_cfg_writeb,
+	hp_cfg_writew,
+	hp_cfg_writel,
+};
+
+/*
+ * Assume we'll never have a physical slot higher than 0x10, so we can
+ * use slots above that for "fake" PCI devices to represent things
+ * that only show up in the ACPI namespace.
+ */
+#define HP_MAX_SLOT	0x10
+
+static struct fake_pci_dev *
+hpzx1_fake_pci_dev(unsigned long addr, unsigned int bus, unsigned int size)
+{
+	struct fake_pci_dev *dev;
+	int slot;
+
+	// Note: lspci thinks 0x1f is invalid
+	for (slot =3D 0x1e; slot > HP_MAX_SLOT; slot--) {
+		if (!fake_pci_find_slot(bus, PCI_DEVFN(slot, 0)))
+			break;
+	}
+	if (slot =3D HP_MAX_SLOT) {
+		printk(KERN_ERR PFX
+			"no slot space for device (0x%p) on bus 0x%02x\n",
+			(void *) addr, bus);
+		return NULL;
+	}
+
+	dev =3D alloc_fake_pci_dev();
+	if (!dev) {
+		printk(KERN_ERR PFX
+			"no memory for device (0x%p) on bus 0x%02x\n",
+			(void *) addr, bus);
+		return NULL;
+	}
+
+	dev->bus =3D bus;
+	dev->devfn =3D PCI_DEVFN(slot, 0);
+	dev->csr_base =3D addr;
+	dev->csr_size =3D size;
+
+	/*
+	 * Drivers should ioremap what they need, but we have to do
+	 * it here, too, so PCI config accesses work.
+	 */
+	dev->mapped_csrs =3D (unsigned long) ioremap(dev->csr_base, dev->csr_size=
);
+
+	return dev;
+}
+
+typedef struct {
+	u8	guid_id;
+	u8	guid[16];
+	u8	csr_base[8];
+	u8	csr_length[8];
+} acpi_hp_vendor_long;
+
+#define HP_CCSR_LENGTH 0x21
+#define HP_CCSR_TYPE 0x2
+#define HP_CCSR_GUID EFI_GUID(0x69e9adf9, 0x924f, 0xab5f,			\
+			      0xf6, 0x4a, 0x24, 0xd2, 0x01, 0x37, 0x0e, 0xad)
+
+extern acpi_status acpi_get_crs(acpi_handle, acpi_buffer *);
+extern acpi_resource *acpi_get_crs_next(acpi_buffer *, int *);
+extern acpi_resource_data *acpi_get_crs_type(acpi_buffer *, int *, int);
+extern void acpi_dispose_crs(acpi_buffer *);
+extern acpi_status acpi_cf_evaluate_method(acpi_handle, UINT8 *, NATIVE_UI=
NT *);
+
+static acpi_status
+hp_csr_space(acpi_handle obj, u64 *csr_base, u64 *csr_length)
+{
+	int i, offset =3D 0;
+	acpi_status status;
+	acpi_buffer buf;
+	acpi_resource_vendor *res;
+	acpi_hp_vendor_long *hp_res;
+	efi_guid_t vendor_guid;
+
+	*csr_base =3D 0;
+	*csr_length =3D 0;
+
+	status =3D acpi_get_crs(obj, &buf);
+	if (status !=3D AE_OK) {
+		printk(KERN_ERR PFX "Unable to get _CRS data on object\n");
+		return status;
+	}
+
+	res =3D (acpi_resource_vendor *)acpi_get_crs_type(&buf, &offset, ACPI_RST=
YPE_VENDOR);
+	if (!res) {
+		printk(KERN_ERR PFX "Failed to find config space for device\n");
+		acpi_dispose_crs(&buf);
+		return AE_NOT_FOUND;
+	}
+
+	hp_res =3D (acpi_hp_vendor_long *)(res->reserved);
+
+	if (res->length !=3D HP_CCSR_LENGTH || hp_res->guid_id !=3D HP_CCSR_TYPE)=
 {
+		printk(KERN_ERR PFX "Unknown Vendor data\n");
+		acpi_dispose_crs(&buf);
+		return AE_TYPE; /* Revisit error? */
+	}
+
+	memcpy(&vendor_guid, hp_res->guid, sizeof(efi_guid_t));
+	if (efi_guidcmp(vendor_guid, HP_CCSR_GUID) !=3D 0) {
+		printk(KERN_ERR PFX "Vendor GUID does not match\n");
+		acpi_dispose_crs(&buf);
+		return AE_TYPE; /* Revisit error? */
+	}
+
+	for (i =3D 0 ; i < 8 ; i++) {
+		*csr_base |=3D ((u64)(hp_res->csr_base[i]) << (i * 8));
+		*csr_length |=3D ((u64)(hp_res->csr_length[i]) << (i * 8));
+	}
+
+	acpi_dispose_crs(&buf);
+
+	return AE_OK;
+}
+
+static acpi_status
+hpzx1_sba_probe(acpi_handle obj, u32 depth, void *context, void **ret)
+{
+	u64 csr_base =3D 0, csr_length =3D 0;
+	char *name =3D context;
+	struct fake_pci_dev *dev;
+	acpi_status status;
+
+	status =3D hp_csr_space(obj, &csr_base, &csr_length);
+
+printk("hpzx1_sba_probe: status=3D%d\n", status);
+	if (status !=3D AE_OK)
+		return status;
+
+	/*
+	 * Only SBA shows up in ACPI namespace, so its CSR space
+	 * includes both SBA and IOC.  Make SBA and IOC show up
+	 * separately in PCI space.
+	 */
+	if ((dev =3D hpzx1_fake_pci_dev(csr_base, 0, 0x1000)))
+		printk(KERN_INFO PFX "%s SBA at 0x%lx; pci dev %02x:%02x.%d\n",
+			name, csr_base, dev->bus,
+			PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
+	if ((dev =3D hpzx1_fake_pci_dev(csr_base + 0x1000, 0, 0x1000)))
+		printk(KERN_INFO PFX "%s IOC at 0x%lx; pci dev %02x:%02x.%d\n",
+			name, csr_base + 0x1000, dev->bus,
+			PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
+
+	return AE_OK;
+}
+
+static acpi_status
+hpzx1_lba_probe(acpi_handle obj, u32 depth, void *context, void **ret)
+{
+	acpi_status status;
+	u64 csr_base =3D 0, csr_length =3D 0;
+	char *name =3D context;
+	NATIVE_UINT busnum =3D 0;
+	struct fake_pci_dev *dev;
+
+	status =3D hp_csr_space(obj, &csr_base, &csr_length);
+
+	if (status !=3D AE_OK)
+		return status;
+
+	status =3D acpi_cf_evaluate_method(obj, METHOD_NAME__BBN, &busnum);
+	if (ACPI_FAILURE(status)) {
+		printk(KERN_ERR PFX "evaluate _BBN fail=3D0x%x\n", status);
+		busnum =3D 0;	// no _BBN; stick it on bus 0
+	}
+
+	if ((dev =3D hpzx1_fake_pci_dev(csr_base, busnum, csr_length)))
+		printk(KERN_INFO PFX "%s LBA at 0x%lx, _BBN 0x%02x; "
+			"pci dev %02x:%02x.%d\n",
+			name, csr_base, busnum, dev->bus,
+			PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
+
+	return AE_OK;
+}
+
+static void
+hpzx1_acpi_dev_init(void)
+{
+	extern struct pci_ops pci_conf;
+
+	/*
+	 * Make fake PCI devices for the following hardware in the
+	 * ACPI namespace.  This makes it more convenient for drivers
+	 * because they can claim these devices based on PCI
+	 * information, rather than needing to know about ACPI.  The
+	 * 64-bit "HPA" space for this hardware is available as BAR
+	 * 0/1.
+	 *
+	 * HWP0001: Single IOC SBA w/o IOC in namespace
+	 * HWP0002: LBA device
+	 * HWP0003: AGP LBA device
+	 */
+printk("hpzx1_acpi_dev_init\n");
+	acpi_get_devices("HWP0001", hpzx1_sba_probe, "HWP0001", NULL);
+#ifdef CONFIG_IA64_HP_PROTO
+	if (fake_pci_tail !=3D &fake_pci_head) {
+#endif
+	acpi_get_devices("HWP0002", hpzx1_lba_probe, "HWP0002", NULL);
+	acpi_get_devices("HWP0003", hpzx1_lba_probe, "HWP0003", NULL);
+
+#ifdef CONFIG_IA64_HP_PROTO
+	}
+
+#define ZX1_FUNC_ID_VALUE    (PCI_DEVICE_ID_HP_ZX1_SBA << 16) | PCI_VENDOR=
_ID_HP
+	/*
+	 * Early protos don't have bridges in the ACPI namespace, so
+	 * if we didn't find anything, add the things we know are
+	 * there.
+	 */
+	if (fake_pci_tail =3D &fake_pci_head) {
+		u64 hpa, csr_base;
+		struct fake_pci_dev *dev;
+
+		csr_base =3D 0xfed00000UL;
+		hpa =3D (u64) ioremap(csr_base, 0x1000);
+		if (__raw_readl(hpa) =3D ZX1_FUNC_ID_VALUE) {
+			if ((dev =3D hpzx1_fake_pci_dev(csr_base, 0, 0x1000)))
+				printk(KERN_INFO PFX "HWP0001 SBA at 0x%lx; "
+					"pci dev %02x:%02x.%d\n", csr_base,
+					dev->bus, PCI_SLOT(dev->devfn),
+					PCI_FUNC(dev->devfn));
+			if ((dev =3D hpzx1_fake_pci_dev(csr_base + 0x1000, 0,
+					0x1000)))
+				printk(KERN_INFO PFX "HWP0001 IOC at 0x%lx; "
+					"pci dev %02x:%02x.%d\n",
+					csr_base + 0x1000,
+					dev->bus, PCI_SLOT(dev->devfn),
+					PCI_FUNC(dev->devfn));
+
+			csr_base =3D 0xfed24000UL;
+			iounmap(hpa);
+			hpa =3D (u64) ioremap(csr_base, 0x1000);
+			if ((dev =3D hpzx1_fake_pci_dev(csr_base, 0x40, 0x1000)))
+				printk(KERN_INFO PFX "HWP0003 AGP LBA at "
+					"0x%lx; pci dev %02x:%02x.%d\n",
+					csr_base,
+					dev->bus, PCI_SLOT(dev->devfn),
+					PCI_FUNC(dev->devfn));
+		}
+		iounmap(hpa);
+	}
+#endif
+
+	if (fake_pci_tail =3D &fake_pci_head)
+		return;
+
+	/*
+	 * Replace PCI ops, but only if we made fake devices.
+	 */
+	orig_pci_ops =3D pci_conf;
+	pci_conf =3D hp_pci_conf;
+}
+
+extern void sba_init(void);
+
+void
+hpzx1_pci_fixup (int phase)
+{
+	if (phase =3D 0)
+		hpzx1_acpi_dev_init();
+	iosapic_pci_fixup(phase);
+        if (phase =3D 1)
+		sba_init();
+}
diff -urN linux-davidm/arch/ia64/ia32/ia32_traps.c lia64-2.4/arch/ia64/ia32=
/ia32_traps.c
--- linux-davidm/arch/ia64/ia32/ia32_traps.c	Wed Apr 10 13:24:24 2002
+++ lia64-2.4/arch/ia64/ia32/ia32_traps.c	Fri Mar 15 12:03:00 2002
@@ -20,7 +20,7 @@
 {
 	switch ((isr >> 16) & 0xff) {
 	      case 0:	/* Instruction intercept fault */
-	      case 3:	/* Locked Data reference fault */
+	      case 4:	/* Locked Data reference fault */
 	      case 1:	/* Gate intercept trap */
 		return -1;
=20
diff -urN linux-davidm/arch/ia64/kernel/Makefile lia64-2.4/arch/ia64/kernel=
/Makefile
--- linux-davidm/arch/ia64/kernel/Makefile	Wed Apr 10 13:24:24 2002
+++ lia64-2.4/arch/ia64/kernel/Makefile	Fri Apr  5 16:44:44 2002
@@ -17,6 +17,7 @@
 	 machvec.o pal.o process.o perfmon.o ptrace.o sal.o salinfo.o semaphore.o=
 setup.o	 \
 	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
 obj-$(CONFIG_IA64_GENERIC) +=3D iosapic.o
+obj-$(CONFIG_IA64_HP_ZX1) +=3D iosapic.o
 obj-$(CONFIG_IA64_DIG) +=3D iosapic.o
 obj-$(CONFIG_IA64_PALINFO) +=3D palinfo.o
 obj-$(CONFIG_EFI_VARS) +=3D efivars.o
diff -urN linux-davidm/arch/ia64/kernel/acpi.c lia64-2.4/arch/ia64/kernel/a=
cpi.c
--- linux-davidm/arch/ia64/kernel/acpi.c	Wed Apr 10 13:24:24 2002
+++ lia64-2.4/arch/ia64/kernel/acpi.c	Wed Apr 10 11:25:39 2002
@@ -1,21 +1,34 @@
 /*
- * Advanced Configuration and Power Interface
+ *  acpi.c - Architecture-Specific Low-Level ACPI Support
  *
- * Based on 'ACPI Specification 1.0b' February 2, 1999 and
- * 'IA-64 Extensions to ACPI Specification' Revision 0.6
+ *  Copyright (C) 1999 VA Linux Systems
+ *  Copyright (C) 1999,2000 Walt Drummond <drummond@valinux.com>
+ *  Copyright (C) 2000 Hewlett-Packard Co.
+ *  Copyright (C) 2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ *  Copyright (C) 2000 Intel Corp.
+ *  Copyright (C) 2000,2001 J.I. Lee <jung-ik.lee@intel.com>
+ *  Copyright (C) 2001 Paul Diefenbaugh <paul.s.diefenbaugh@intel.com>
  *
- * Copyright (C) 1999 VA Linux Systems
- * Copyright (C) 1999,2000 Walt Drummond <drummond@valinux.com>
- * Copyright (C) 2000 Hewlett-Packard Co.
- * Copyright (C) 2000 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 2000 Intel Corp.
- * Copyright (C) 2000,2001 J.I. Lee <jung-ik.lee@intel.com>
- *      ACPI based kernel configuration manager.
- *      ACPI 2.0 & IA64 ext 0.71
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=
~~~
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
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=
~~~
  */
=20
 #include <linux/config.h>
-
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
@@ -23,29 +36,16 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/irq.h>
-#ifdef CONFIG_SERIAL_ACPI
-#include <linux/acpi_serial.h>
-#endif
-
-#include <asm/acpi-ext.h>
-#include <asm/acpikcfg.h>
+#include <linux/acpi.h>
 #include <asm/efi.h>
 #include <asm/io.h>
 #include <asm/iosapic.h>
 #include <asm/machvec.h>
 #include <asm/page.h>
+#include <asm/system.h>
=20
-#undef ACPI_DEBUG		/* Guess what this does? */
-
-/* global array to record platform interrupt vectors for generic int routi=
ng */
-int platform_irq_list[ACPI_MAX_PLATFORM_IRQS];
=20
-/* These are ugly but will be reclaimed by the kernel */
-int __initdata available_cpus;
-int __initdata total_cpus;
-
-void (*pm_idle) (void);
-void (*pm_power_off) (void);
+#define PREFIX			"ACPI: "
=20
 asm (".weak iosapic_register_irq");
 asm (".weak iosapic_register_legacy_irq");
@@ -53,10 +53,16 @@
 asm (".weak iosapic_init");
 asm (".weak iosapic_version");
=20
+void (*pm_idle) (void);
+void (*pm_power_off) (void);
+
+
+/*
+ * TBD: Should go away once we have an ACPI parser.
+ */
 const char *
 acpi_get_sysname (void)
 {
-	/* the following should go away once we have an ACPI parser: */
 #ifdef CONFIG_IA64_GENERIC
 	return "hpsim";
 #else
@@ -72,16 +78,19 @@
 #	error Unknown platform.  Fix acpi.c.
 # endif
 #endif
-
 }
=20
+#define ACPI_MAX_PLATFORM_IRQS	256
+
+/* Array to record platform interrupt vectors for generic interrupt routin=
g. */
+int platform_irq_list[ACPI_MAX_PLATFORM_IRQS];
+
 /*
- * Interrupt routing API for device drivers.
- * Provides the interrupt vector for a generic platform event
- * (currently only CPEI implemented)
+ * Interrupt routing API for device drivers.  Provides interrupt vector for
+ * a generic platform event.  Currently only CPEI is implemented.
  */
 int
-acpi_request_vector(u32 int_type)
+acpi_request_vector (u32 int_type)
 {
 	int vector =3D -1;
=20
@@ -94,586 +103,492 @@
 	return vector;
 }
=20
-/*
- * Configure legacy IRQ information.
- */
-static void __init
-acpi_legacy_irq (char *p)
+
+/* -----------------------------------------------------------------------=
---
+                            Boot-time Table Parsing
+   -----------------------------------------------------------------------=
--- */
+
+static int			total_cpus __initdata;
+static int			available_cpus __initdata;
+struct acpi_table_madt *	acpi_madt __initdata;
+
+
+static int __init
+acpi_parse_lapic_addr_ovr (acpi_table_entry_header *header)
 {
-	acpi_entry_int_override_t *legacy =3D (acpi_entry_int_override_t *) p;
-	unsigned long polarity =3D 0, edge_triggered =3D 0;
+	struct acpi_table_lapic_addr_ovr *lapic =3D NULL;
=20
-	/*
-	 * If the platform we're running doesn't define
-	 * iosapic_register_legacy_irq(), we ignore this info...
-	 */
-	if (!iosapic_register_legacy_irq)
-		return;
+	lapic =3D (struct acpi_table_lapic_addr_ovr *) header;
+	if (!lapic)
+		return -EINVAL;
+
+	acpi_table_print_madt_entry(header);
=20
-	switch (legacy->flags) {
-	      case 0x5:	polarity =3D 1; edge_triggered =3D 1; break;
-	      case 0x7: polarity =3D 0; edge_triggered =3D 1; break;
-	      case 0xd: polarity =3D 1; edge_triggered =3D 0; break;
-	      case 0xf: polarity =3D 0; edge_triggered =3D 0; break;
-	      default:
-		printk("    ACPI Legacy IRQ 0x%02x: Unknown flags 0x%x\n", legacy->isa_i=
rq,
-		       legacy->flags);
-		break;
+	if (lapic->address) {
+		iounmap((void *) ipi_base_addr);
+		ipi_base_addr =3D (unsigned long) ioremap(lapic->address, 0);
 	}
-	iosapic_register_legacy_irq(legacy->isa_irq, legacy->pin, polarity, edge_=
triggered);
+
+	return 0;
 }
=20
-/*
- * ACPI 2.0 tables parsing functions
- */
=20
-static unsigned long
-readl_unaligned(void *p)
+static int __init
+acpi_parse_lsapic (acpi_table_entry_header *header)
 {
-	unsigned long ret;
-
-	memcpy(&ret, p, sizeof(long));
-	return ret;
-}
+	struct acpi_table_lsapic *lsapic =3D NULL;
=20
-/*
- * Identify usable CPU's and remember them for SMP bringup later.
- */
-static void __init
-acpi20_lsapic (char *p)
-{
-	int add =3D 1;
+	lsapic =3D (struct acpi_table_lsapic *) header;
+	if (!lsapic)
+		return -EINVAL;
=20
-	acpi20_entry_lsapic_t *lsapic =3D (acpi20_entry_lsapic_t *) p;
-	printk("      CPU %.04x:%.04x: ", lsapic->eid, lsapic->id);
+	acpi_table_print_madt_entry(header);
=20
-	if ((lsapic->flags & LSAPIC_ENABLED) =3D 0) {
-		printk("disabled.\n");
-		add =3D 0;
-	}
+	printk("CPU %d (0x%04x)", total_cpus, (lsapic->id << 8) | lsapic->eid);
=20
-#ifdef CONFIG_SMP
-	smp_boot_data.cpu_phys_id[total_cpus] =3D -1;
-#endif
-	if (add) {
+	if (lsapic->flags.enabled) {
 		available_cpus++;
-		printk("available");
+		printk(" enabled");
 #ifdef CONFIG_SMP
 		smp_boot_data.cpu_phys_id[total_cpus] =3D (lsapic->id << 8) | lsapic->ei=
d;
 		if (hard_smp_processor_id() =3D smp_boot_data.cpu_phys_id[total_cpus])
 			printk(" (BSP)");
 #endif
-		printk(".\n");
 	}
+	else {
+		printk(" disabled");
+#ifdef CONFIG_SMP
+		smp_boot_data.cpu_phys_id[total_cpus] =3D -1;
+#endif
+	}
+
+	printk("\n");
+
 	total_cpus++;
+	return 0;
 }
=20
-/*
- * Extract iosapic info from madt (again) to determine which iosapic
- * this platform interrupt resides in
- */
+
 static int __init
-acpi20_which_iosapic (int global_vector, acpi_madt_t *madt, u32 *irq_base,=
 char **iosapic_address)
+acpi_parse_lapic_nmi (acpi_table_entry_header *header)
 {
-	acpi_entry_iosapic_t *iosapic;
-	char *p, *end;
-	int ver, max_pin;
+	struct acpi_table_lapic_nmi *lacpi_nmi =3D NULL;
+
+	lacpi_nmi =3D (struct acpi_table_lapic_nmi*) header;
+	if (!lacpi_nmi)
+		return -EINVAL;
=20
-	p =3D (char *) (madt + 1);
-	end =3D p + (madt->header.length - sizeof(acpi_madt_t));
+	acpi_table_print_madt_entry(header);
+
+	/* TBD: Support lapic_nmi entries */
+
+	return 0;
+}
+
+
+static int __init
+acpi_find_iosapic (int global_vector, u32 *irq_base, char **iosapic_addres=
s)
+{
+	struct acpi_table_iosapic *iosapic =3D NULL;
+	int ver =3D 0;
+	int max_pin =3D 0;
+	char *p =3D 0;
+	char *end =3D 0;
+
+	if (!irq_base || !iosapic_address)
+		return -ENODEV;
+
+	p =3D (char *) (acpi_madt + 1);
+	end =3D p + (acpi_madt->header.length - sizeof(struct acpi_table_madt));
=20
 	while (p < end) {
-		switch (*p) {
-		      case ACPI20_ENTRY_IO_SAPIC:
-			/* collect IOSAPIC info for platform int use later */
-			iosapic =3D (acpi_entry_iosapic_t *)p;
-			*irq_base =3D iosapic->irq_base;
+		if (*p =3D ACPI_MADT_IOSAPIC) {
+			iosapic =3D (struct acpi_table_iosapic *) p;
+
+			*irq_base =3D iosapic->global_irq_base;
 			*iosapic_address =3D ioremap(iosapic->address, 0);
-			/* is this the iosapic we're looking for? */
+
 			ver =3D iosapic_version(*iosapic_address);
 			max_pin =3D (ver >> 16) & 0xff;
+
 			if ((global_vector - *irq_base) <=3D max_pin)
-				return 0;		/* found it! */
-			break;
-		      default:
-			break;
+				return 0;	/* Found it! */
 		}
 		p +=3D p[1];
 	}
-	return 1;
+	return -ENODEV;
 }
=20
-/*
- * Info on platform interrupt sources: NMI, PMI, INIT, etc.
- */
-static void __init
-acpi20_platform (char *p, acpi_madt_t *madt)
+
+static int __init
+acpi_parse_iosapic (acpi_table_entry_header *header)
 {
-	int vector;
-	u32 irq_base;
-	char *iosapic_address;
-	unsigned long polarity =3D 0, trigger =3D 0;
-	acpi20_entry_platform_src_t *plat =3D (acpi20_entry_platform_src_t *) p;
+	struct acpi_table_iosapic *iosapic;
+
+	iosapic =3D (struct acpi_table_iosapic *) header;
+	if (!iosapic)
+		return -EINVAL;
+
+	acpi_table_print_madt_entry(header);
+
+	if (iosapic_init) {
+#ifndef CONFIG_ITANIUM
+		/* PCAT_COMPAT flag indicates dual-8259 setup */
+		iosapic_init(iosapic->address, iosapic->global_irq_base,
+			     acpi_madt->flags.pcat_compat);
+#else
+		/* Firmware on old Itanium systems is broken */
+		iosapic_init(iosapic->address, iosapic->global_irq_base, 1);
+#endif
+	}
+	return 0;
+}
+
=20
-	printk("PLATFORM: IOSAPIC %x -> Vector %x on CPU %.04u:%.04u\n",
-	       plat->iosapic_vector, plat->global_vector, plat->eid, plat->id);
+static int __init
+acpi_parse_plat_int_src (acpi_table_entry_header *header)
+{
+	struct acpi_table_plat_int_src *plintsrc =3D NULL;
+	int vector =3D 0;
+	u32 irq_base =3D 0;
+	char *iosapic_address =3D NULL;
+
+	plintsrc =3D (struct acpi_table_plat_int_src *) header;
+	if (!plintsrc)
+		return -EINVAL;
=20
-	/* record platform interrupt vectors for generic int routing code */
+	acpi_table_print_madt_entry(header);
=20
 	if (!iosapic_register_platform_irq) {
-		printk("acpi20_platform(): no ACPI platform IRQ support\n");
-		return;
+		printk(KERN_WARNING PREFIX "No ACPI platform IRQ support\n");
+		return -ENODEV;
 	}
=20
-	/* extract polarity and trigger info from flags */
-	switch (plat->flags) {
-	      case 0x5: polarity =3D 1; trigger =3D 1; break;
-	      case 0x7: polarity =3D 0; trigger =3D 1; break;
-	      case 0xd: polarity =3D 1; trigger =3D 0; break;
-	      case 0xf: polarity =3D 0; trigger =3D 0; break;
-	      default:
-		printk("acpi20_platform(): unknown flags 0x%x\n", plat->flags);
-		break;
-	}
-
-	/* which iosapic does this IRQ belong to? */
-	if (acpi20_which_iosapic(plat->global_vector, madt, &irq_base, &iosapic_a=
ddress)) {
-		printk("acpi20_platform(): I/O SAPIC not found!\n");
-		return;
+	if (0 !=3D acpi_find_iosapic(plintsrc->global_irq, &irq_base, &iosapic_ad=
dress)) {
+		printk(KERN_WARNING PREFIX "IOSAPIC not found\n");
+		return -ENODEV;
 	}
=20
 	/*
-	 * get vector assignment for this IRQ, set attributes, and program the IO=
SAPIC
-	 * routing table
+	 * Get vector assignment for this IRQ, set attributes, and program the
+	 * IOSAPIC routing table.
 	 */
-	vector =3D iosapic_register_platform_irq(plat->int_type,
-					       plat->global_vector,
-					       plat->iosapic_vector,
-					       plat->eid,
-					       plat->id,
-					       polarity,
-					       trigger,
-					       irq_base,
-					       iosapic_address);
-	platform_irq_list[plat->int_type] =3D vector;
+	vector =3D iosapic_register_platform_irq (plintsrc->type,
+						plintsrc->global_irq,
+						plintsrc->iosapic_vector,
+						plintsrc->eid,
+						plintsrc->id,
+						(plintsrc->flags.polarity =3D 1) ? 1 : 0,
+						(plintsrc->flags.trigger =3D 1) ? 1 : 0,
+						irq_base,
+						iosapic_address);
+
+	platform_irq_list[plintsrc->type] =3D vector;
+	return 0;
 }
=20
-/*
- * Override the physical address of the local APIC in the MADT stable head=
er.
- */
-static void __init
-acpi20_lapic_addr_override (char *p)
+
+static int __init
+acpi_parse_int_src_ovr (acpi_table_entry_header *header)
 {
-	acpi20_entry_lapic_addr_override_t * lapic =3D (acpi20_entry_lapic_addr_o=
verride_t *) p;
+	struct acpi_table_int_src_ovr *p =3D NULL;
=20
-	if (lapic->lapic_address) {
-		iounmap((void *)ipi_base_addr);
-		ipi_base_addr =3D (unsigned long) ioremap(lapic->lapic_address, 0);
+	p =3D (struct acpi_table_int_src_ovr *) header;
+	if (!p)
+		return -EINVAL;
=20
-		printk("LOCAL ACPI override to 0x%lx(p=3D0x%lx)\n",
-		       ipi_base_addr, lapic->lapic_address);
-	}
+	acpi_table_print_madt_entry(header);
+
+	/* Ignore if the platform doesn't support overrides */
+	if (!iosapic_register_legacy_irq)
+		return 0;
+
+	iosapic_register_legacy_irq(p->bus_irq, p->global_irq,
+		(p->flags.polarity =3D 1) ? 1 : 0,
+		(p->flags.trigger =3D 1) ? 1 : 0);
+
+	return 0;
 }
=20
-/*
- * Parse the ACPI Multiple APIC Description Table
- */
-static void __init
-acpi20_parse_madt (acpi_madt_t *madt)
+
+static int __init
+acpi_parse_nmi_src (acpi_table_entry_header *header)
 {
-	acpi_entry_iosapic_t *iosapic =3D NULL;
-	acpi20_entry_lsapic_t *lsapic =3D NULL;
-	char *p, *end;
-	int i;
-
-	/* Base address of IPI Message Block */
-	if (madt->lapic_address) {
-		ipi_base_addr =3D (unsigned long) ioremap(madt->lapic_address, 0);
-		printk("Lapic address set to 0x%lx\n", ipi_base_addr);
-	} else
-		printk("Lapic address set to default 0x%lx\n", ipi_base_addr);
+	struct acpi_table_nmi_src *nmi_src =3D NULL;
=20
-	p =3D (char *) (madt + 1);
-	end =3D p + (madt->header.length - sizeof(acpi_madt_t));
+	nmi_src =3D (struct acpi_table_nmi_src*) header;
+	if (!nmi_src)
+		return -EINVAL;
=20
-	/* Initialize platform interrupt vector array */
-	for (i =3D 0; i < ACPI_MAX_PLATFORM_IRQS; i++)
-		platform_irq_list[i] =3D -1;
+	acpi_table_print_madt_entry(header);
=20
-	/*
-	 * Split-up entry parsing to ensure ordering.
-	 */
-	while (p < end) {
-		switch (*p) {
-		      case ACPI20_ENTRY_LOCAL_APIC_ADDR_OVERRIDE:
-			printk("ACPI 2.0 MADT: LOCAL APIC Override\n");
-			acpi20_lapic_addr_override(p);
-			break;
-
-		      case ACPI20_ENTRY_LOCAL_SAPIC:
-			printk("ACPI 2.0 MADT: LOCAL SAPIC\n");
-			lsapic =3D (acpi20_entry_lsapic_t *) p;
-			acpi20_lsapic(p);
-			break;
-
-		      case ACPI20_ENTRY_IO_SAPIC:
-			iosapic =3D (acpi_entry_iosapic_t *) p;
-			if (iosapic_init)
-				/*
-				 * The PCAT_COMPAT flag indicates that the system has a
-				 * dual-8259 compatible setup.
-				 */
-				iosapic_init(iosapic->address, iosapic->irq_base,
-#ifdef CONFIG_ITANIUM
-					     1 /* fw on some Itanium systems is broken... */
-#else
-					     (madt->flags & MADT_PCAT_COMPAT)
-#endif
-					);
-			break;
+	/* TBD: Support nimsrc entries */
=20
-		      case ACPI20_ENTRY_PLATFORM_INT_SOURCE:
-			printk("ACPI 2.0 MADT: PLATFORM INT SOURCE\n");
-			acpi20_platform(p, madt);
-			break;
-
-		      case ACPI20_ENTRY_LOCAL_APIC:
-			printk("ACPI 2.0 MADT: LOCAL APIC entry\n"); break;
-		      case ACPI20_ENTRY_IO_APIC:
-			printk("ACPI 2.0 MADT: IO APIC entry\n"); break;
-		      case ACPI20_ENTRY_NMI_SOURCE:
-			printk("ACPI 2.0 MADT: NMI SOURCE entry\n"); break;
-		      case ACPI20_ENTRY_LOCAL_APIC_NMI:
-			printk("ACPI 2.0 MADT: LOCAL APIC NMI entry\n"); break;
-		      case ACPI20_ENTRY_INT_SRC_OVERRIDE:
-			break;
-		      default:
-			printk("ACPI 2.0 MADT: unknown entry skip\n"); break;
-			break;
-		}
-		p +=3D p[1];
-	}
+	return 0;
+}
=20
-	p =3D (char *) (madt + 1);
-	end =3D p + (madt->header.length - sizeof(acpi_madt_t));
=20
-	while (p < end) {
-		switch (*p) {
-		      case ACPI20_ENTRY_LOCAL_APIC:
-			if (lsapic) break;
-			printk("ACPI 2.0 MADT: LOCAL APIC entry\n");
-			/* parse local apic if there's no local Sapic */
-			break;
-		      case ACPI20_ENTRY_IO_APIC:
-			if (iosapic) break;
-			printk("ACPI 2.0 MADT: IO APIC entry\n");
-			/* parse ioapic if there's no ioSapic */
-			break;
-		      default:
-			break;
-		}
-		p +=3D p[1];
-	}
+static int __init
+acpi_parse_madt (unsigned long phys_addr, unsigned long size)
+{
+	int i =3D 0;
=20
-	p =3D (char *) (madt + 1);
-	end =3D p + (madt->header.length - sizeof(acpi_madt_t));
+	if (!phys_addr || !size)
+		return -EINVAL;
=20
-	while (p < end) {
-		switch (*p) {
-		      case ACPI20_ENTRY_INT_SRC_OVERRIDE:
-			printk("ACPI 2.0 MADT: INT SOURCE Override\n");
-			acpi_legacy_irq(p);
-			break;
-		      default:
-			break;
-		}
-		p +=3D p[1];
+	acpi_madt =3D (struct acpi_table_madt *) __va(phys_addr);
+	if (!acpi_madt) {
+		printk(KERN_WARNING PREFIX "Unable to map MADT\n");
+		return -ENODEV;
 	}
=20
-	/* Make bootup pretty */
-	printk("      %d CPUs available, %d CPUs total\n",
-		available_cpus, total_cpus);
+	/* Initialize platform interrupt vector array */
+
+	for (i =3D 0; i < ACPI_MAX_PLATFORM_IRQS; i++)
+		platform_irq_list[i] =3D -1;
+
+	/* Get base address of IPI Message Block */
+
+	if (acpi_madt->lapic_address)
+		ipi_base_addr =3D (unsigned long)
+			ioremap(acpi_madt->lapic_address, 0);
+
+	printk(KERN_INFO PREFIX "Local APIC address 0x%lx\n", ipi_base_addr);
+
+	return 0;
 }
=20
+
 int __init
-acpi20_parse (acpi20_rsdp_t *rsdp20)
+acpi_find_rsdp (unsigned long *rsdp_phys)
 {
-# ifdef CONFIG_ACPI
-	acpi_xsdt_t *xsdt;
-	acpi_desc_table_hdr_t *hdrp;
-	acpi_madt_t *madt =3D NULL;
-	int tables, i;
+	if (!rsdp_phys)
+		return -EINVAL;
=20
-	if (strncmp(rsdp20->signature, ACPI_RSDP_SIG, ACPI_RSDP_SIG_LEN)) {
-		printk("ACPI 2.0 RSDP signature incorrect!\n");
+	if (efi.acpi20) {
+		(*rsdp_phys) =3D __pa(efi.acpi20);
 		return 0;
-	} else {
-		printk("ACPI 2.0 Root System Description Ptr at 0x%lx\n",
-			(unsigned long)rsdp20);
 	}
-
-	xsdt =3D __va(rsdp20->xsdt);
-	hdrp =3D &xsdt->header;
-	if (strncmp(hdrp->signature,
-		ACPI_XSDT_SIG, ACPI_XSDT_SIG_LEN)) {
-		printk("ACPI 2.0 XSDT signature incorrect. Trying RSDT\n");
-		/* RSDT parsing here */
-		return 0;
-	} else {
-		printk("ACPI 2.0 XSDT at 0x%lx (p=3D0x%lx)\n",
-		(unsigned long)xsdt, (unsigned long)rsdp20->xsdt);
+	else if (efi.acpi) {
+		printk(KERN_WARNING PREFIX "v1.0/r0.71 tables no longer supported\n");
 	}
=20
-	printk("ACPI 2.0: %.6s %.8s %d.%d\n",
-		hdrp->oem_id,
-		hdrp->oem_table_id,
-		hdrp->oem_revision >> 16,
-		hdrp->oem_revision & 0xffff);
+	return -ENODEV;
+}
+
=20
-	acpi_cf_init((void *)rsdp20);
+#ifdef CONFIG_SERIAL_ACPI
=20
-	tables =3D(hdrp->length -sizeof(acpi_desc_table_hdr_t))>>3;
+#include <linux/acpi_serial.h>
=20
-	for (i =3D 0; i < tables; i++) {
-		hdrp =3D (acpi_desc_table_hdr_t *) __va(readl_unaligned(&xsdt->entry_ptr=
s[i]));
-		printk("        :table %4.4s found\n", hdrp->signature);
+static int __init
+acpi_parse_spcr (unsigned long phys_addr, unsigned long size)
+{
+	acpi_ser_t *spcr =3D NULL;
+	unsigned long global_int =3D 0;
=20
-		/* Only interested int the MADT table for now ... */
-		if (strncmp(hdrp->signature,
-			ACPI_MADT_SIG, ACPI_MADT_SIG_LEN) !=3D 0)
-			continue;
+	if (!phys_addr || !size)
+		return -EINVAL;
=20
-		/* Save MADT pointer for later */
-		madt =3D (acpi_madt_t *) hdrp;
-		acpi20_parse_madt(madt);
-	}
+	if (!iosapic_register_irq)
+		return -ENODEV;
=20
-#ifdef CONFIG_SERIAL_ACPI
 	/*
-	 * Now we're interested in other tables.  We want the iosapics already
-	 * initialized, so we do it in a separate loop.
+	 * ACPI is able to describe serial ports that live at non-standard
+	 * memory addresses and use non-standard interrupts, either via
+	 * direct SAPIC mappings or via PCI interrupts.  We handle interrupt
+	 * routing for SAPIC-based (non-PCI) devices here.  Interrupt routing
+	 * for PCI devices will be handled when processing the PCI Interrupt
+	 * Routing Table (PRT).
 	 */
-	for (i =3D 0; i < tables; i++) {
-		hdrp =3D (acpi_desc_table_hdr_t *) __va(readl_unaligned(&xsdt->entry_ptr=
s[i]));
-		/*
-		 * search for SPCR and DBGP table entries so we can enable
-		 * non-pci interrupts to IO-SAPICs.
-		 */
-		if (!strncmp(hdrp->signature, ACPI_SPCRT_SIG, ACPI_SPCRT_SIG_LEN) ||
-		    !strncmp(hdrp->signature, ACPI_DBGPT_SIG, ACPI_DBGPT_SIG_LEN))
-		{
-			acpi_ser_t *spcr =3D (void *)hdrp;
-			unsigned long global_int;
-
-			setup_serial_acpi(hdrp);
-
-			/*
-			 * ACPI is able to describe serial ports that live at non-standard
-			 * memory space addresses and use SAPIC interrupts.  If not also
-			 * PCI devices, there would be no interrupt vector information for
-			 * them.  This checks for and fixes that situation.
-			 */
-			if (spcr->length < sizeof(acpi_ser_t))
-				/* table is not long enough for full info, thus no int */
-				break;
-
-			/*
-			 * If the device is not in PCI space, but uses a SAPIC interrupt,
-			 * we need to program the SAPIC so that serial can autoprobe for
-			 * the IA64 interrupt vector later on.  If the device is in PCI
-			 * space, it should already be setup via the PCI vectors
-			 */
-			if (spcr->base_addr.space_id !=3D ACPI_SERIAL_PCICONF_SPACE &&
-			    spcr->int_type =3D ACPI_SERIAL_INT_SAPIC)
-			{
-				u32 irq_base;
-				char *iosapic_address;
-				int vector;
-
-				/* We have a UART in memory space with a SAPIC interrupt */
-				global_int =3D (  (spcr->global_int[3] << 24)
-					      | (spcr->global_int[2] << 16)
-					      | (spcr->global_int[1] << 8)
-					      | spcr->global_int[0]);
-
-				if (!iosapic_register_irq)
-					continue;
-
-				/* which iosapic does this IRQ belong to? */
-				if (acpi20_which_iosapic(global_int, madt, &irq_base,
-							 &iosapic_address) =3D 0)
-				{
-					vector =3D iosapic_register_irq(global_int,
-					                              1, /* active high polarity */
-					                              1, /* edge triggered */
-					                              irq_base,
-					                              iosapic_address);
-				}
-			}
-		}
+
+	spcr =3D (acpi_ser_t *) __va(phys_addr);
+	if (!spcr) {
+		printk(KERN_WARNING PREFIX "Unable to map SPCR\n");
+		return -ENODEV;
 	}
-#endif
-	acpi_cf_terminate();
=20
-#  ifdef CONFIG_SMP
-	if (available_cpus =3D 0) {
-		printk("ACPI: Found 0 CPUS; assuming 1\n");
-		available_cpus =3D 1; /* We've got at least one of these, no? */
+	setup_serial_acpi(spcr);
+
+	if (spcr->length < sizeof(acpi_ser_t))
+		/* Table not long enough for full info, thus no interrupt */
+		return -ENODEV;
+
+	if ((spcr->base_addr.space_id !=3D ACPI_SERIAL_PCICONF_SPACE) &&
+	    (spcr->int_type =3D ACPI_SERIAL_INT_SAPIC))
+	{
+		u32 irq_base =3D 0;
+		char *iosapic_address =3D NULL;
+		int vector =3D 0;
+
+		/* We have a UART in memory space with an SAPIC interrupt */
+
+		global_int =3D (  (spcr->global_int[3] << 24) |
+				(spcr->global_int[2] << 16) |
+				(spcr->global_int[1] << 8)  |
+				(spcr->global_int[0])  );
+
+		/* Which iosapic does this IRQ belong to? */
+
+		if (0 =3D acpi_find_iosapic(global_int, &irq_base, &iosapic_address)) {
+			vector =3D iosapic_register_irq (global_int, 1, 1,
+						       irq_base, iosapic_address);
+		}
 	}
-	smp_boot_data.cpu_count =3D total_cpus;
-#  endif
-# endif /* CONFIG_ACPI */
-	return 1;
+	return 0;
 }
-/*
- * ACPI 1.0b with 0.71 IA64 extensions functions; should be removed once a=
ll
- * platforms start supporting ACPI 2.0
- */
=20
-/*
- * Identify usable CPU's and remember them for SMP bringup later.
- */
-static void __init
-acpi_lsapic (char *p)
+#endif /*CONFIG_SERIAL_ACPI*/
+
+
+int __init
+acpi_boot_init (char *cmdline)
 {
-	int add =3D 1;
+	int result =3D 0;
+
+	/* Initialize the ACPI boot-time table parser */
+	result =3D acpi_table_init(cmdline);
+	if (0 !=3D result)
+		return result;
=20
-	acpi_entry_lsapic_t *lsapic =3D (acpi_entry_lsapic_t *) p;
+	/*
+	 * MADT
+	 * ----
+	 * Parse the Multiple APIC Description Table (MADT), if exists.
+	 * Note that this table provides platform SMP configuration
+	 * information -- the successor to MPS tables.
+	 */
=20
-	if ((lsapic->flags & LSAPIC_PRESENT) =3D 0)
-		return;
+	result =3D acpi_table_parse(ACPI_APIC, acpi_parse_madt);
+	if (1 > result)
+		return result;
=20
-	printk("      CPU %d (%.04x:%.04x): ", total_cpus, lsapic->eid, lsapic->i=
d);
+	/* Local APIC */
=20
-	if ((lsapic->flags & LSAPIC_ENABLED) =3D 0) {
-		printk("Disabled.\n");
-		add =3D 0;
-	} else if (lsapic->flags & LSAPIC_PERFORMANCE_RESTRICTED) {
-		printk("Performance Restricted; ignoring.\n");
-		add =3D 0;
+	result =3D acpi_table_parse_madt(ACPI_MADT_LAPIC_ADDR_OVR, acpi_parse_lap=
ic_addr_ovr);
+	if (0 > result) {
+		printk(KERN_ERR PREFIX "Error parsing LAPIC address override entry\n");
+		return result;
 	}
=20
-#ifdef CONFIG_SMP
-	smp_boot_data.cpu_phys_id[total_cpus] =3D -1;
-#endif
-	if (add) {
-		printk("Available.\n");
-		available_cpus++;
-#ifdef CONFIG_SMP
-		smp_boot_data.cpu_phys_id[total_cpus] =3D (lsapic->id << 8) | lsapic->ei=
d;
-#endif /* CONFIG_SMP */
+	result =3D acpi_table_parse_madt(ACPI_MADT_LSAPIC, acpi_parse_lsapic);
+	if (1 > result) {
+		printk(KERN_ERR PREFIX "Error parsing MADT - no LAPIC entries!\n");
+		return -ENODEV;
 	}
-	total_cpus++;
-}
=20
-/*
- * Info on platform interrupt sources: NMI. PMI, INIT, etc.
- */
-static void __init
-acpi_platform (char *p)
-{
-	acpi_entry_platform_src_t *plat =3D (acpi_entry_platform_src_t *) p;
+	result =3D acpi_table_parse_madt(ACPI_MADT_LAPIC_NMI, acpi_parse_lapic_nm=
i);
+	if (0 > result) {
+		printk(KERN_ERR PREFIX "Error parsing LAPIC NMI entry\n");
+		return result;
+	}
=20
-	printk("PLATFORM: IOSAPIC %x -> Vector %x on CPU %.04u:%.04u\n",
-	       plat->iosapic_vector, plat->global_vector, plat->eid, plat->id);
-}
+	/* I/O APIC */
=20
-/*
- * Parse the ACPI Multiple SAPIC Table
- */
-static void __init
-acpi_parse_msapic (acpi_sapic_t *msapic)
-{
-	acpi_entry_iosapic_t *iosapic;
-	char *p, *end;
+	result =3D acpi_table_parse_madt(ACPI_MADT_IOSAPIC, acpi_parse_iosapic);
+	if (1 > result) {
+		printk(KERN_ERR PREFIX "Error parsing MADT - no IOAPIC entries!\n");
+		return ((result =3D 0) ? -ENODEV : result);
+	}
=20
-	/* Base address of IPI Message Block */
-	ipi_base_addr =3D (unsigned long) ioremap(msapic->interrupt_block, 0);
+	/* System-Level Interrupt Routing */
=20
-	p =3D (char *) (msapic + 1);
-	end =3D p + (msapic->header.length - sizeof(acpi_sapic_t));
+	result =3D acpi_table_parse_madt(ACPI_MADT_PLAT_INT_SRC, acpi_parse_plat_=
int_src);
+	if (0 > result) {
+		printk(KERN_ERR PREFIX "Error parsing platform interrupt source entry\n"=
);
+		return result;
+	}
=20
-	while (p < end) {
-		switch (*p) {
-		      case ACPI_ENTRY_LOCAL_SAPIC:
-			acpi_lsapic(p);
-			break;
-
-		      case ACPI_ENTRY_IO_SAPIC:
-			iosapic =3D (acpi_entry_iosapic_t *) p;
-			if (iosapic_init)
-				/*
-				 * The ACPI I/O SAPIC table doesn't have a PCAT_COMPAT
-				 * flag like the MADT table, but we can safely assume that
-				 * ACPI 1.0b systems have a dual-8259 setup.
-				 */
-				iosapic_init(iosapic->address, iosapic->irq_base, 1);
-			break;
-
-		      case ACPI_ENTRY_INT_SRC_OVERRIDE:
-			acpi_legacy_irq(p);
-			break;
-
-		      case ACPI_ENTRY_PLATFORM_INT_SOURCE:
-			acpi_platform(p);
-			break;
+	result =3D acpi_table_parse_madt(ACPI_MADT_INT_SRC_OVR, acpi_parse_int_sr=
c_ovr);
+	if (0 > result) {
+		printk(KERN_ERR PREFIX "Error parsing interrupt source overrides entry\n=
");
+		return result;
+	}
=20
-		      default:
-			break;
-		}
+	result =3D acpi_table_parse_madt(ACPI_MADT_NMI_SRC, acpi_parse_nmi_src);
+	if (0 > result) {
+		printk(KERN_ERR PREFIX "Error parsing NMI SRC entry\n");
+		return result;
+	}
=20
-		/* Move to next table entry. */
-		p +=3D p[1];
+#ifdef CONFIG_SERIAL_ACPI
+	/*
+	 * TBD: Need phased approach to table parsing (only do those absolutely
+	 *      required during boot-up).  Recommend expanding concept of fix-
+	 *      feature devices (LDM) to include table-based devices such as
+	 *      serial ports, EC, SMBus, etc.
+	 */
+	acpi_table_parse(ACPI_SPCR, acpi_parse_spcr);
+#endif /*CONFIG_SERIAL_ACPI*/
+
+#ifdef CONFIG_SMP
+	if (available_cpus =3D 0) {
+		printk("ACPI: Found 0 CPUS; assuming 1\n");
+		available_cpus =3D 1; /* We've got at least one of these, no? */
 	}
+	smp_boot_data.cpu_count =3D total_cpus;
+#endif
+	/* Make boot-up look pretty */
+	printk("%d CPUs available, %d CPUs total\n", available_cpus, total_cpus);
=20
-	/* Make bootup pretty */
-	printk("      %d CPUs available, %d CPUs total\n", available_cpus, total_=
cpus);
+	return 0;
 }
=20
+
+/* -----------------------------------------------------------------------=
---
+                             PCI Interrupt Routing
+   -----------------------------------------------------------------------=
--- */
+
 int __init
-acpi_parse (acpi_rsdp_t *rsdp)
+acpi_get_prt (struct pci_vector_struct **vectors, int *count)
 {
-# ifdef CONFIG_ACPI
-	acpi_rsdt_t *rsdt;
-	acpi_desc_table_hdr_t *hdrp;
-	long tables, i;
+	struct pci_vector_struct *vector =3D NULL;
+	struct list_head *node =3D NULL;
+	struct acpi_prt_entry *entry =3D NULL;
+	int i =3D 0;
=20
-	if (strncmp(rsdp->signature, ACPI_RSDP_SIG, ACPI_RSDP_SIG_LEN)) {
-		printk("Uh-oh, ACPI RSDP signature incorrect!\n");
-		return 0;
-	}
+	if (!vectors || !count)
+		return -EINVAL;
=20
-	rsdt =3D __va(rsdp->rsdt);
-	if (strncmp(rsdt->header.signature, ACPI_RSDT_SIG, ACPI_RSDT_SIG_LEN)) {
-		printk("Uh-oh, ACPI RDST signature incorrect!\n");
-		return 0;
+	*vectors =3D NULL;
+	*count =3D 0;
+
+	if (acpi_prts.count < 0) {
+		printk(KERN_ERR PREFIX "No PCI IRQ routing entries\n");
+		return -ENODEV;
 	}
=20
-	printk("ACPI: %.6s %.8s %d.%d\n", rsdt->header.oem_id, rsdt->header.oem_t=
able_id,
-	       rsdt->header.oem_revision >> 16, rsdt->header.oem_revision & 0xfff=
f);
+	/* Allocate vectors */
=20
-	acpi_cf_init(rsdp);
+	*vectors =3D kmalloc(sizeof(struct pci_vector_struct) * acpi_prts.count, =
GFP_KERNEL);
+	if (!(*vectors))
+		return -ENOMEM;
=20
-	tables =3D (rsdt->header.length - sizeof(acpi_desc_table_hdr_t)) / 8;
-	for (i =3D 0; i < tables; i++) {
-		hdrp =3D (acpi_desc_table_hdr_t *) __va(rsdt->entry_ptrs[i]);
+	/* Convert PRT entries to IOSAPIC PCI vectors */
=20
-		/* Only interested int the MSAPIC table for now ... */
-		if (strncmp(hdrp->signature, ACPI_SAPIC_SIG, ACPI_SAPIC_SIG_LEN) !=3D 0)
-			continue;
+	vector =3D *vectors;
=20
-		acpi_parse_msapic((acpi_sapic_t *) hdrp);
+	list_for_each(node, &acpi_prts.entries) {
+		entry =3D (struct acpi_prt_entry *)node;
+		vector[i].bus    =3D (u16) entry->id.bus;
+		vector[i].pci_id =3D (u32) entry->id.dev << 16 | 0xffff;
+		vector[i].pin    =3D (u8)  entry->id.pin;
+		vector[i].irq    =3D (u8)  entry->source.index;
+		i++;
 	}
+	*count =3D acpi_prts.count;
+	return 0;
+}
=20
-	acpi_cf_terminate();
+/* Assume IA64 always use I/O SAPIC */
=20
-#  ifdef CONFIG_SMP
-	if (available_cpus =3D 0) {
-		printk("ACPI: Found 0 CPUS; assuming 1\n");
-		available_cpus =3D 1; /* We've got at least one of these, no? */
-	}
-	smp_boot_data.cpu_count =3D total_cpus;
-#  endif
-# endif /* CONFIG_ACPI */
-	return 1;
+int __init
+acpi_get_interrupt_model (int *type)
+{
+        if (!type)
+                return -EINVAL;
+
+	*type =3D ACPI_INT_MODEL_IOSAPIC;
+
+        return 0;
 }
diff -urN linux-davidm/arch/ia64/kernel/efi.c lia64-2.4/arch/ia64/kernel/ef=
i.c
--- linux-davidm/arch/ia64/kernel/efi.c	Mon Nov 26 11:18:20 2001
+++ lia64-2.4/arch/ia64/kernel/efi.c	Wed Apr 10 11:53:19 2002
@@ -155,10 +155,10 @@
 		      case EFI_CONVENTIONAL_MEMORY:
 			if (!(md->attribute & EFI_MEMORY_WB))
 				continue;
-			if (md->phys_addr + (md->num_pages << 12) > mem_limit) {
+			if (md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) > mem_limit) {
 				if (md->phys_addr > mem_limit)
 					continue;
-				md->num_pages =3D (mem_limit - md->phys_addr) >> 12;
+				md->num_pages =3D (mem_limit - md->phys_addr) >> EFI_PAGE_SHIFT;
 			}
 			if (md->num_pages =3D 0) {
 				printk("efi_memmap_walk: ignoring empty region at 0x%lx",
@@ -167,7 +167,7 @@
 			}
=20
 			curr.start =3D PAGE_OFFSET + md->phys_addr;
-			curr.end   =3D curr.start + (md->num_pages << 12);
+			curr.end   =3D curr.start + (md->num_pages << EFI_PAGE_SHIFT);
=20
 			if (!prev_valid) {
 				prev =3D curr;
@@ -250,16 +250,17 @@
 		 * dedicated ITR for the PAL code.
 		 */
 		if ((vaddr & mask) =3D (KERNEL_START & mask)) {
-			printk(__FUNCTION__ ": no need to install ITR for PAL code\n");
+			printk("%s: no need to install ITR for PAL code\n", __FUNCTION__);
 			continue;
 		}
=20
-		if (md->num_pages << 12 > IA64_GRANULE_SIZE)
+		if (md->num_pages << EFI_PAGE_SHIFT > IA64_GRANULE_SIZE)
 			panic("Woah!  PAL code size bigger than a granule!");
=20
 		mask  =3D ~((1 << IA64_GRANULE_SHIFT) - 1);
 		printk("CPU %d: mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
-		       smp_processor_id(), md->phys_addr, md->phys_addr + (md->num_pages=
 << 12),
+		       smp_processor_id(), md->phys_addr,
+		       md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
 		       vaddr & mask, (vaddr & mask) + IA64_GRANULE_SIZE);
=20
 		/*
@@ -375,7 +376,8 @@
 			md =3D p;
 			printk("mem%02u: type=3D%u, attr=3D0x%lx, range=3D[0x%016lx-0x%016lx) (=
%luMB)\n",
 			       i, md->type, md->attribute, md->phys_addr,
-			       md->phys_addr + (md->num_pages<<12) - 1, md->num_pages >> 8);
+			       md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - 1,
+			       md->num_pages >> (20 - EFI_PAGE_SHIFT));
 		}
 	}
 #endif
@@ -482,8 +484,50 @@
 	return 0;
 }
=20
+u32
+efi_mem_type (u64 phys_addr)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size;
+
+	efi_map_start =3D __va(ia64_boot_param->efi_memmap);
+	efi_map_end   =3D efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size =3D ia64_boot_param->efi_memdesc_size;
+
+	for (p =3D efi_map_start; p < efi_map_end; p +=3D efi_desc_size) {
+		md =3D p;
+
+		if ((md->phys_addr <=3D phys_addr) && (phys_addr <+		    (md->phys_addr =
+ (md->num_pages << EFI_PAGE_SHIFT) - 1)))
+			 return md->type;
+	}
+	return 0;
+}
+
+u64
+efi_mem_attributes (u64 phys_addr)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size;
+
+	efi_map_start =3D __va(ia64_boot_param->efi_memmap);
+	efi_map_end   =3D efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size =3D ia64_boot_param->efi_memdesc_size;
+
+	for (p =3D efi_map_start; p < efi_map_end; p +=3D efi_desc_size) {
+		md =3D p;
+
+		if ((md->phys_addr <=3D phys_addr) && (phys_addr <+		    (md->phys_addr =
+ (md->num_pages << EFI_PAGE_SHIFT) - 1)))
+			return md->attribute;
+	}
+	return 0;
+}
+
 static void __exit
-efivars_exit(void)
+efivars_exit (void)
 {
 #ifdef CONFIG_PROC_FS
  	remove_proc_entry(efi_dir->name, NULL);
diff -urN linux-davidm/arch/ia64/kernel/efivars.c lia64-2.4/arch/ia64/kerne=
l/efivars.c
--- linux-davidm/arch/ia64/kernel/efivars.c	Wed Apr 10 13:24:24 2002
+++ lia64-2.4/arch/ia64/kernel/efivars.c	Thu Mar 28 16:11:08 2002
@@ -29,6 +29,9 @@
  *
  * Changelog:
  *
+ *  25 Mar 2002 - Matt Domsch <Matt_Domsch@dell.com>
+ *   move uuid_unparse() to include/asm-ia64/efi.h:efi_guid_unparse()
+ *
  *  12 Feb 2002 - Matt Domsch <Matt_Domsch@dell.com>
  *   use list_for_each_safe when deleting vars.
  *   remove ifdef CONFIG_SMP around include <linux/smp.h>
@@ -70,7 +73,7 @@
 MODULE_DESCRIPTION("/proc interface to EFI Variables");
 MODULE_LICENSE("GPL");
=20
-#define EFIVARS_VERSION "0.04 2002-Feb-12"
+#define EFIVARS_VERSION "0.05 2002-Mar-26"
=20
 static int
 efivar_read(char *page, char **start, off_t off,
@@ -141,20 +144,6 @@
 	return len;
 }
=20
-
-static void
-uuid_unparse(efi_guid_t *guid, char *out)
-{
-	sprintf(out, "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
-		guid->data1, guid->data2, guid->data3,
-		guid->data4[0], guid->data4[1], guid->data4[2], guid->data4[3],
-		guid->data4[4], guid->data4[5], guid->data4[6], guid->data4[7]);
-}
-
-
-
-
-
 /*
  * efivar_create_proc_entry()
  * Requires:
@@ -197,7 +186,7 @@
 	   private variables from another's.         */
=20
 	*(short_name + strlen(short_name)) =3D '-';
-	uuid_unparse(vendor_guid, short_name + strlen(short_name));
+	efi_guid_unparse(vendor_guid, short_name + strlen(short_name));
=20
=20
 	/* Create the entry in proc */
diff -urN linux-davidm/arch/ia64/kernel/entry.S lia64-2.4/arch/ia64/kernel/=
entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Wed Apr 10 13:24:24 2002
+++ lia64-2.4/arch/ia64/kernel/entry.S	Tue Apr  9 22:01:38 2002
@@ -3,7 +3,7 @@
  *
  * Kernel entry points.
  *
- * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2002 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
@@ -667,23 +667,38 @@
 	/*
 	 * To prevent leaking bits between the kernel and user-space,
 	 * we must clear the stacked registers in the "invalid" partition here.
-	 * Not pretty, but at least it's fast (3.34 registers/cycle).
-	 * Architecturally, this loop could go at 4.67 registers/cycle, but that =
would
-	 * oversubscribe Itanium.
+	 * Not pretty, but at least it's fast (3.34 registers/cycle on Itanium,
+	 * 5 registers/cycle on McKinley).
 	 */
 #	define pRecurse	p6
 #	define pReturn	p7
+#ifdef CONFIG_ITANIUM
 #	define Nregs	10
+#else
+#	define Nregs	14
+#endif
 	alloc loc0=3Dar.pfs,2,Nregs-2,2,0
 	shr.u loc1=3Dr18,9		// RNaTslots <=3D dirtySize / (64*8) + 1
 	sub r17=3Dr17,r18			// r17 =3D (physStackedSize + 8) - dirtySize
 	;;
+#if 1
+	.align 32		// see comment below about gas bug...
+#endif
 	mov ar.rsc=3Dr19			// load ar.rsc to be used for "loadrs"
 	shladd in0=3Dloc1,3,r17
 	mov in1=3D0
+#if 0
+	// gas-2.11.90 is unable to generate a stop bit after .align, which is ba=
d,
+	// because alloc must be at the beginning of an insn-group.
+	.align 32
+#else
+	nop 0
+	nop 0
+	nop 0
+#endif
 	;;
-//	.align 32	// gas-2.11.90 is unable to generate a stop bit after .align
 rse_clear_invalid:
+#ifdef CONFIG_ITANIUM
 	// cycle 0
  { .mii
 	alloc loc0=3Dar.pfs,2,Nregs-2,2,0
@@ -712,9 +727,31 @@
 	mov loc7=3D0
 (pReturn) br.ret.sptk.many b6
 }
+#else /* !CONFIG_ITANIUM */
+	alloc loc0=3Dar.pfs,2,Nregs-2,2,0
+	cmp.lt pRecurse,p0=3DNregs*8,in0	// if more than Nregs regs left to clear=
, (re)curse
+	add out0=3D-Nregs*8,in0
+	add out1=3D1,in1			// increment recursion count
+	mov loc1=3D0
+	mov loc2=3D0
+	;;
+	mov loc3=3D0
+	mov loc4=3D0
+	mov loc9=3D0
+	mov loc5=3D0
+	mov loc6=3D0
+(pRecurse) br.call.sptk.many b6=3Drse_clear_invalid
+	;;
+	mov loc7=3D0
+	mov loc8=3D0
+	cmp.ne pReturn,p0=3Dr0,in1	// if recursion count !=3D 0, we need to do a =
br.ret
+	mov loc10=3D0
+	mov loc11=3D0
+(pReturn) br.ret.sptk.many b6
+#endif /* !CONFIG_ITANIUM */
 #	undef pRecurse
 #	undef pReturn
-
+	;;
 	alloc r17=3Dar.pfs,0,0,0,0	// drop current register frame
 	;;
 	loadrs
diff -urN linux-davidm/arch/ia64/kernel/head.S lia64-2.4/arch/ia64/kernel/h=
ead.S
--- linux-davidm/arch/ia64/kernel/head.S	Wed Apr 10 13:24:24 2002
+++ lia64-2.4/arch/ia64/kernel/head.S	Tue Apr  9 21:50:52 2002
@@ -562,137 +562,114 @@
 END(__ia64_load_fpu)
=20
 GLOBAL_ENTRY(__ia64_init_fpu)
-	alloc r2=3Dar.pfs,0,0,0,0
-	stf.spill [sp]=F0
-	mov      f32=F0
-	;;
-	ldf.fill f33=3D[sp]
-	ldf.fill f34=3D[sp]
-	mov      f35=F0
-	;;
-	ldf.fill f36=3D[sp]
-	ldf.fill f37=3D[sp]
-	mov      f38=F0
-	;;
-	ldf.fill f39=3D[sp]
-	ldf.fill f40=3D[sp]
-	mov      f41=F0
-	;;
-	ldf.fill f42=3D[sp]
-	ldf.fill f43=3D[sp]
-	mov      f44=F0
-	;;
-	ldf.fill f45=3D[sp]
-	ldf.fill f46=3D[sp]
-	mov      f47=F0
-	;;
-	ldf.fill f48=3D[sp]
-	ldf.fill f49=3D[sp]
-	mov      f50=F0
-	;;
-	ldf.fill f51=3D[sp]
-	ldf.fill f52=3D[sp]
-	mov      f53=F0
-	;;
-	ldf.fill f54=3D[sp]
-	ldf.fill f55=3D[sp]
-	mov      f56=F0
-	;;
-	ldf.fill f57=3D[sp]
-	ldf.fill f58=3D[sp]
-	mov      f59=F0
-	;;
-	ldf.fill f60=3D[sp]
-	ldf.fill f61=3D[sp]
-	mov      f62=F0
-	;;
-	ldf.fill f63=3D[sp]
-	ldf.fill f64=3D[sp]
-	mov      f65=F0
-	;;
-	ldf.fill f66=3D[sp]
-	ldf.fill f67=3D[sp]
-	mov      f68=F0
-	;;
-	ldf.fill f69=3D[sp]
-	ldf.fill f70=3D[sp]
-	mov      f71=F0
-	;;
-	ldf.fill f72=3D[sp]
-	ldf.fill f73=3D[sp]
-	mov      f74=F0
-	;;
-	ldf.fill f75=3D[sp]
-	ldf.fill f76=3D[sp]
-	mov      f77=F0
-	;;
-	ldf.fill f78=3D[sp]
-	ldf.fill f79=3D[sp]
-	mov      f80=F0
-	;;
-	ldf.fill f81=3D[sp]
-	ldf.fill f82=3D[sp]
-	mov      f83=F0
-	;;
-	ldf.fill f84=3D[sp]
-	ldf.fill f85=3D[sp]
-	mov      f86=F0
-	;;
-	ldf.fill f87=3D[sp]
-	ldf.fill f88=3D[sp]
-	mov      f89=F0
-	;;
-	ldf.fill f90=3D[sp]
-	ldf.fill f91=3D[sp]
-	mov      f92=F0
-	;;
-	ldf.fill f93=3D[sp]
-	ldf.fill f94=3D[sp]
-	mov      f95=F0
-	;;
-	ldf.fill f96=3D[sp]
-	ldf.fill f97=3D[sp]
-	mov      f98=F0
-	;;
-	ldf.fill f99=3D[sp]
-	ldf.fill f100=3D[sp]
-	mov      f101=F0
-	;;
-	ldf.fill f102=3D[sp]
-	ldf.fill f103=3D[sp]
-	mov      f104=F0
-	;;
-	ldf.fill f105=3D[sp]
-	ldf.fill f106=3D[sp]
-	mov      f107=F0
-	;;
-	ldf.fill f108=3D[sp]
-	ldf.fill f109=3D[sp]
-	mov      f110=F0
-	;;
-	ldf.fill f111=3D[sp]
-	ldf.fill f112=3D[sp]
-	mov      f113=F0
-	;;
-	ldf.fill f114=3D[sp]
-	ldf.fill f115=3D[sp]
-	mov      f116=F0
-	;;
-	ldf.fill f117=3D[sp]
-	ldf.fill f118=3D[sp]
-	mov      f119=F0
-	;;
-	ldf.fill f120=3D[sp]
-	ldf.fill f121=3D[sp]
-	mov      f122=F0
-	;;
-	ldf.fill f123=3D[sp]
-	ldf.fill f124=3D[sp]
-	mov      f125=F0
-	;;
-	ldf.fill f126=3D[sp]
-	mov      f127=F0
-	br.ret.sptk.many rp
+	stf.spill [sp]=F0		// M3
+	mov	 f32=F0			// F
+	nop.b	 0
+
+	ldfps	 f33,f34=3D[sp]		// M0
+	ldfps	 f35,f36=3D[sp]		// M1
+	mov      f37=F0			// F
+	;;
+
+	setf.s	 f38=3Dr0			// M2
+	setf.s	 f39=3Dr0			// M3
+	mov      f40=F0			// F
+
+	ldfps	 f41,f42=3D[sp]		// M0
+	ldfps	 f43,f44=3D[sp]		// M1
+	mov      f45=F0			// F
+
+	setf.s	 f46=3Dr0			// M2
+	setf.s	 f47=3Dr0			// M3
+	mov      f48=F0			// F
+
+	ldfps	 f49,f50=3D[sp]		// M0
+	ldfps	 f51,f52=3D[sp]		// M1
+	mov      f53=F0			// F
+
+	setf.s	 f54=3Dr0			// M2
+	setf.s	 f55=3Dr0			// M3
+	mov      f56=F0			// F
+
+	ldfps	 f57,f58=3D[sp]		// M0
+	ldfps	 f59,f60=3D[sp]		// M1
+	mov      f61=F0			// F
+
+	setf.s	 f62=3Dr0			// M2
+	setf.s	 f63=3Dr0			// M3
+	mov      f64=F0			// F
+
+	ldfps	 f65,f66=3D[sp]		// M0
+	ldfps	 f67,f68=3D[sp]		// M1
+	mov      f69=F0			// F
+
+	setf.s	 f70=3Dr0			// M2
+	setf.s	 f71=3Dr0			// M3
+	mov      f72=F0			// F
+
+	ldfps	 f73,f74=3D[sp]		// M0
+	ldfps	 f75,f76=3D[sp]		// M1
+	mov      f77=F0			// F
+
+	setf.s	 f78=3Dr0			// M2
+	setf.s	 f79=3Dr0			// M3
+	mov      f80=F0			// F
+
+	ldfps	 f81,f82=3D[sp]		// M0
+	ldfps	 f83,f84=3D[sp]		// M1
+	mov      f85=F0			// F
+
+	setf.s	 f86=3Dr0			// M2
+	setf.s	 f87=3Dr0			// M3
+	mov      f88=F0			// F
+
+	/*
+	 * When the instructions are cached, it would be faster to initialize
+	 * the remaining registers with simply mov instructions (F-unit).
+	 * This gets the time down to ~29 cycles.  However, this would use up
+	 * 33 bundles, whereas continuing with the above pattern yields
+	 * 10 bundles and ~30 cycles.
+	 */
+
+	ldfps	 f89,f90=3D[sp]		// M0
+	ldfps	 f91,f92=3D[sp]		// M1
+	mov      f93=F0			// F
+
+	setf.s	 f94=3Dr0			// M2
+	setf.s	 f95=3Dr0			// M3
+	mov      f96=F0			// F
+
+	ldfps	 f97,f98=3D[sp]		// M0
+	ldfps	 f99,f100=3D[sp]		// M1
+	mov      f101=F0		// F
+
+	setf.s	 f102=3Dr0		// M2
+	setf.s	 f103=3Dr0		// M3
+	mov      f104=F0		// F
+
+	ldfps	 f105,f106=3D[sp]		// M0
+	ldfps	 f107,f108=3D[sp]		// M1
+	mov      f109=F0		// F
+
+	setf.s	 f110=3Dr0		// M2
+	setf.s	 f111=3Dr0		// M3
+	mov      f112=F0		// F
+
+	ldfps	 f113,f114=3D[sp]		// M0
+	ldfps	 f115,f116=3D[sp]		// M1
+	mov      f117=F0		// F
+
+	setf.s	 f118=3Dr0		// M2
+	setf.s	 f119=3Dr0		// M3
+	mov      f120=F0		// F
+
+	ldfps	 f121,f122=3D[sp]		// M0
+	ldfps	 f123,f124=3D[sp]		// M1
+	mov      f125=F0		// F
+
+	setf.s	 f126=3Dr0		// M2
+	setf.s	 f127=3Dr0		// M3
+	br.ret.sptk.many rp		// F
 END(__ia64_init_fpu)
=20
 /*
diff -urN linux-davidm/arch/ia64/kernel/ia64_ksyms.c lia64-2.4/arch/ia64/ke=
rnel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Wed Apr 10 13:24:24 2002
+++ lia64-2.4/arch/ia64/kernel/ia64_ksyms.c	Tue Apr  9 11:03:59 2002
@@ -6,7 +6,8 @@
 #include <linux/module.h>
=20
 #include <linux/string.h>
-EXPORT_SYMBOL_NOVERS(memset);
+EXPORT_SYMBOL_NOVERS(__memset_generic);
+EXPORT_SYMBOL_NOVERS(__bzero);
 EXPORT_SYMBOL(memchr);
 EXPORT_SYMBOL(memcmp);
 EXPORT_SYMBOL_NOVERS(memcpy);
@@ -148,3 +149,10 @@
 #include <linux/proc_fs.h>
 extern struct proc_dir_entry *efi_dir;
 EXPORT_SYMBOL(efi_dir);
+
+#include <asm/machvec.h>
+#ifdef CONFIG_IA64_GENERIC
+EXPORT_SYMBOL(ia64_mv);
+#endif
+EXPORT_SYMBOL(machvec_noop);
+
diff -urN linux-davidm/arch/ia64/kernel/iosapic.c lia64-2.4/arch/ia64/kerne=
l/iosapic.c
--- linux-davidm/arch/ia64/kernel/iosapic.c	Wed Apr 10 13:24:24 2002
+++ lia64-2.4/arch/ia64/kernel/iosapic.c	Wed Apr 10 11:03:55 2002
@@ -22,6 +22,7 @@
  * 02/01/07     E. Focht        <efocht@ess.nec.de> Redirectable interrupt=
 vectors in
  *                              iosapic_set_affinity(), initializations for
  *                              /proc/irq/#/smp_affinity
+ * 02/04/02	P. Diefenbaugh	Cleaned up ACPI PCI IRQ routing.
  */
 /*
  * Here is what the interrupt logic between a PCI device and the CPU looks=
 like:
@@ -56,9 +57,8 @@
 #include <linux/smp_lock.h>
 #include <linux/string.h>
 #include <linux/irq.h>
+#include <linux/acpi.h>
=20
-#include <asm/acpi-ext.h>
-#include <asm/acpikcfg.h>
 #include <asm/delay.h>
 #include <asm/hw_irq.h>
 #include <asm/io.h>
@@ -92,11 +92,37 @@
 	unsigned char trigger	: 1;	/* trigger mode (see iosapic.h) */
 } iosapic_irq[IA64_NUM_VECTORS];
=20
+static struct iosapic {
+	char *addr;			/* base address of IOSAPIC */
+	unsigned char	pcat_compat;	/* 8259 compatibility flag */
+	unsigned char 	base_irq;	/* first irq assigned to this IOSAPIC */
+	unsigned short 	max_pin;	/* max input pin supported in this IOSAPIC */
+} iosapic_lists[256] __initdata;
+
+static int num_iosapic =3D 0;
+
+
+/*
+ * Find an IOSAPIC associated with an IRQ
+ */
+static inline int __init
+find_iosapic (unsigned int irq)
+{
+	int i;
+
+	for (i =3D 0; i < num_iosapic; i++) {
+		if ((irq - iosapic_lists[i].base_irq) < iosapic_lists[i].max_pin)
+			return i;
+	}
+
+	return -1;
+}
+
 /*
  * Translate IOSAPIC irq number to the corresponding IA-64 interrupt vecto=
r.  If no
  * entry exists, return -1.
  */
-int
+static int
 iosapic_irq_to_vector (int irq)
 {
 	int vector;
@@ -479,7 +505,7 @@
 	int vector;
=20
 	switch (int_type) {
-	case ACPI20_ENTRY_PIS_PMI:
+	      case ACPI_INTERRUPT_PMI:
 		vector =3D iosapic_vector;
 		/*
 		 * since PMI vector is alloc'd by FW(ACPI) not by kernel,
@@ -488,15 +514,15 @@
 		iosapic_reassign_vector(vector);
 		delivery =3D IOSAPIC_PMI;
 		break;
-	case ACPI20_ENTRY_PIS_CPEI:
-		vector =3D IA64_PCE_VECTOR;
-		delivery =3D IOSAPIC_LOWEST_PRIORITY;
-		break;
-	case ACPI20_ENTRY_PIS_INIT:
+	      case ACPI_INTERRUPT_INIT:
 		vector =3D ia64_alloc_irq();
 		delivery =3D IOSAPIC_INIT;
 		break;
-	default:
+	      case ACPI_INTERRUPT_CPEI:
+		vector =3D IA64_PCE_VECTOR;
+		delivery =3D IOSAPIC_LOWEST_PRIORITY;
+		break;
+	      default:
 		printk("iosapic_register_platform_irq(): invalid int type\n");
 		return -1;
 	}
@@ -542,31 +568,41 @@
 void __init
 iosapic_init (unsigned long phys_addr, unsigned int base_irq, int pcat_com=
pat)
 {
-	int i, irq, max_pin, vector, pin;
+	int irq, max_pin, vector, pin;
 	unsigned int ver;
 	char *addr;
 	static int first_time =3D 1;
=20
 	if (first_time) {
 		first_time =3D 0;
-
 		for (vector =3D 0; vector < IA64_NUM_VECTORS; ++vector)
 			iosapic_irq[vector].pin =3D -1;	/* mark as unused */
+	}
=20
+	if (pcat_compat) {
 		/*
-		 * Fetch the PCI interrupt routing table:
+		 * Disable the compatibility mode interrupts (8259 style), needs IN/OUT =
support
+		 * enabled.
 		 */
-		acpi_cf_get_pci_vectors(&pci_irq.route, &pci_irq.num_routes);
+		printk("%s: Disabling PC-AT compatible 8259 interrupts\n", __FUNCTION__);
+		outb(0xff, 0xA1);
+		outb(0xff, 0x21);
 	}
=20
 	addr =3D ioremap(phys_addr, 0);
 	ver =3D iosapic_version(addr);
 	max_pin =3D (ver >> 16) & 0xff;
=20
+	iosapic_lists[num_iosapic].addr =3D addr;
+	iosapic_lists[num_iosapic].pcat_compat =3D pcat_compat;
+	iosapic_lists[num_iosapic].base_irq =3D base_irq;
+	iosapic_lists[num_iosapic].max_pin =3D max_pin;
+	num_iosapic++;
+
 	printk("IOSAPIC: version %x.%x, address 0x%lx, IRQs 0x%02x-0x%02x\n",
 	       (ver & 0xf0) >> 4, (ver & 0x0f), phys_addr, base_irq, base_irq + m=
ax_pin);
=20
-	if ((base_irq =3D 0) && pcat_compat)
+	if ((base_irq =3D 0) && pcat_compat) {
 		/*
 		 * Map the legacy ISA devices into the IOSAPIC data.  Some of these may
 		 * get reprogrammed later on with data from the ACPI Interrupt Source
@@ -590,11 +626,37 @@
 			/* program the IOSAPIC routing table: */
 			set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
 		}
+	}
+}
+
+void __init
+iosapic_init_pci_irq (void)
+{
+	int i, index, vector, pin;
+	int base_irq, max_pin, pcat_compat;
+	unsigned int irq;
+	char *addr;
+
+	if (0 !=3D acpi_get_prt(&pci_irq.route, &pci_irq.num_routes))
+		return;
=20
 	for (i =3D 0; i < pci_irq.num_routes; i++) {
+
 		irq =3D pci_irq.route[i].irq;
=20
-		if ((irq < (int)base_irq) || (irq > (int)(base_irq + max_pin)))
+		index =3D find_iosapic(irq);
+		if (index < 0) {
+			printk("PCI: IRQ %u has no IOSAPIC mapping\n", irq);
+			continue;
+		}
+
+		addr =3D iosapic_lists[index].addr;
+		base_irq =3D iosapic_lists[index].base_irq;
+		max_pin =3D iosapic_lists[index].max_pin;
+		pcat_compat =3D iosapic_lists[index].pcat_compat;
+		pin =3D irq - base_irq;
+
+		if ((unsigned) pin > max_pin)
 			/* the interrupt route is for another controller... */
 			continue;
=20
@@ -607,18 +669,13 @@
 				vector =3D ia64_alloc_irq();
 		}
=20
-		register_irq(irq, vector, irq - base_irq,
-			     /* IOSAPIC_POL_LOW, IOSAPIC_LEVEL */
-			     IOSAPIC_LOWEST_PRIORITY, 0, 0, base_irq, addr);
+		register_irq(irq, vector, pin, IOSAPIC_LOWEST_PRIORITY, 0, 0, base_irq, =
addr);
=20
-# ifdef DEBUG_IRQ_ROUTING
+#ifdef DEBUG_IRQ_ROUTING
 		printk("PCI: (B%d,I%d,P%d) -> IOSAPIC irq 0x%02x -> vector 0x%02x\n",
 		       pci_irq.route[i].bus, pci_irq.route[i].pci_id>>16, pci_irq.route[=
i].pin,
 		       iosapic_irq[vector].base_irq + iosapic_irq[vector].pin, vector);
-# endif
-
-			/* program the IOSAPIC routing table: */
-			set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
+#endif
 	}
 }
=20
@@ -631,6 +688,11 @@
 	struct hw_interrupt_type *irq_type;
 	irq_desc_t *idesc;
=20
+	if (phase =3D 0) {
+		iosapic_init_pci_irq();
+		return;
+	}
+
 	if (phase !=3D 1)
 		return;
=20
@@ -670,7 +732,7 @@
=20
 				irq_type =3D &irq_type_iosapic_level;
 				idesc =3D irq_desc(vector);
-				if (idesc->handler !=3D irq_type){
+				if (idesc->handler !=3D irq_type) {
 					if (idesc->handler !=3D &no_irq_type)
 						printk("iosapic_pci_fixup: changing vector 0x%02x "
 						       "from %s to %s\n", vector,
diff -urN linux-davidm/arch/ia64/kernel/irq.c lia64-2.4/arch/ia64/kernel/ir=
q.c
--- linux-davidm/arch/ia64/kernel/irq.c	Wed Apr 10 13:24:24 2002
+++ lia64-2.4/arch/ia64/kernel/irq.c	Fri Apr  5 17:05:37 2002
@@ -67,6 +67,27 @@
 irq_desc_t _irq_desc[NR_IRQS] __cacheline_aligned  	{ [0 ... NR_IRQS-1] =
=3D { IRQ_DISABLED, &no_irq_type, NULL, 0, SPIN_LOCK_UNLOCKED}};
=20
+#ifdef CONFIG_IA64_GENERIC
+struct irq_desc *
+__ia64_irq_desc (unsigned int irq)
+{
+	return _irq_desc + irq;
+}
+
+ia64_vector
+__ia64_irq_to_vector (unsigned int irq)
+{
+	return (ia64_vector) irq;
+}
+
+unsigned int
+__ia64_local_vector_to_irq (ia64_vector vec)
+{
+	return (unsigned int) vec;
+}
+
+#endif
+
 static void register_irq_proc (unsigned int irq);
=20
 /*
diff -urN linux-davidm/arch/ia64/kernel/mca.c lia64-2.4/arch/ia64/kernel/mc=
a.c
--- linux-davidm/arch/ia64/kernel/mca.c	Wed Apr 10 13:24:25 2002
+++ lia64-2.4/arch/ia64/kernel/mca.c	Wed Apr 10 10:11:02 2002
@@ -3,6 +3,9 @@
  * Purpose:	Generic MCA handling layer
  *
  * Updated for latest kernel
+ * Copyright (C) 2002 Dell Computer Corporation
+ * Copyright (C) Matt Domsch (Matt_Domsch@dell.com)
+ *
  * Copyright (C) 2002 Intel
  * Copyright (C) Jenna Hall (jenna.s.hall@intel.com)
  *
@@ -15,6 +18,8 @@
  * Copyright (C) 1999 Silicon Graphics, Inc.
  * Copyright (C) Vijay Chander(vijay@engr.sgi.com)
  *
+ * 02/03/25 M. Domsch	GUID cleanups
+ *
  * 02/01/04 J. Hall	Aligned MCA stack to 16 bytes, added platform vs. CPU
  *			error flag, set SAL default return values, changed
  *			error record structure to linked list, added init call
@@ -36,6 +41,7 @@
 #include <linux/irq.h>
 #include <linux/smp_lock.h>
 #include <linux/bootmem.h>
+#include <linux/acpi.h>
=20
 #include <asm/machvec.h>
 #include <asm/page.h>
@@ -46,7 +52,6 @@
=20
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
-#include <asm/acpi-ext.h>
=20
 #undef MCA_PRT_XTRA_DATA
=20
@@ -348,17 +353,13 @@
 verify_guid (efi_guid_t *test, efi_guid_t *target)
 {
 	int     rc;
+	char out[40];
=20
-	if ((rc =3D memcmp((void *)test, (void *)target, sizeof(efi_guid_t)))) {
-		IA64_MCA_DEBUG("ia64_mca_print: invalid guid =3D "
-			       "{ %08x, %04x, %04x, { %#02x, %#02x, %#02x, %#02x, "
-			       "%#02x, %#02x, %#02x, %#02x, } } \n ",
-			       test->data1, test->data2, test->data3, test->data4[0],
-			       test->data4[1], test->data4[2], test->data4[3],
-			       test->data4[4], test->data4[5], test->data4[6],
-			       test->data4[7]);
+	if ((rc =3D efi_guidcmp(*test, *target))) {
+		IA64_MCA_DEBUG(KERN_DEBUG
+			       "verify_guid: invalid GUID =3D %s\n",
+			       efi_guid_unparse(test, out));
 	}
-
 	return rc;
 }
=20
@@ -496,7 +497,7 @@
 	{
 		irq_desc_t *desc;
 		unsigned int irq;
-		int cpev =3D acpi_request_vector(ACPI20_ENTRY_PIS_CPEI);
+		int cpev =3D acpi_request_vector(ACPI_INTERRUPT_CPEI);
=20
 		if (cpev >=3D 0) {
 			for (irq =3D 0; irq < NR_IRQS; ++irq)
@@ -856,11 +857,8 @@
 void
 ia64_log_prt_guid (efi_guid_t *p_guid, prfunc_t prfunc)
 {
-	printk("GUID =3D { %08x, %04x, %04x, { %#02x, %#02x, %#02x, %#02x, "
-	       "%#02x, %#02x, %#02x, %#02x, } } \n ", p_guid->data1,
-	       p_guid->data2, p_guid->data3, p_guid->data4[0], p_guid->data4[1],
-	       p_guid->data4[2], p_guid->data4[3], p_guid->data4[4],
-	       p_guid->data4[5], p_guid->data4[6], p_guid->data4[7]);
+	char out[40];
+	printk(KERN_DEBUG "GUID =3D %s\n", efi_guid_unparse(p_guid, out));
 }
=20
 static void
@@ -1754,7 +1752,7 @@
 		ia64_log_prt_section_header(slsh, prfunc);
 #endif  // MCA_PRT_XTRA_DATA for test only @FVL
=20
-		if (verify_guid((void *)&slsh->guid, (void *)&(SAL_PROC_DEV_ERR_SECT_GUI=
D))) {
+		if (verify_guid(&slsh->guid, &(SAL_PROC_DEV_ERR_SECT_GUID))) {
 			IA64_MCA_DEBUG("ia64_mca_log_print: unsupported record section\n");
 			continue;
 		}
diff -urN linux-davidm/arch/ia64/kernel/minstate.h lia64-2.4/arch/ia64/kern=
el/minstate.h
--- linux-davidm/arch/ia64/kernel/minstate.h	Tue Jul 31 10:30:08 2001
+++ lia64-2.4/arch/ia64/kernel/minstate.h	Tue Apr  9 22:21:40 2002
@@ -92,7 +92,6 @@
  *
  * Assumed state upon entry:
  *	psr.ic: off
- *	psr.dt: off
  *	r31:	contains saved predicates (pr)
  *
  * Upon exit, the state is as follows:
@@ -186,7 +185,6 @@
  *
  * Assumed state upon entry:
  *	psr.ic: on
- *	psr.dt: on
  *	r2:	points to &pt_regs.r16
  *	r3:	points to &pt_regs.r17
  */
diff -urN linux-davidm/arch/ia64/kernel/pal.S lia64-2.4/arch/ia64/kernel/pa=
l.S
--- linux-davidm/arch/ia64/kernel/pal.S	Mon Nov 26 11:18:21 2001
+++ lia64-2.4/arch/ia64/kernel/pal.S	Tue Feb 26 20:41:18 2002
@@ -161,7 +161,7 @@
 	;;
 	mov loc3 =3D psr			// save psr
 	adds r8  =3D 1f-1b,r8		// calculate return address for call
-	;;=20
+	;;
 	mov loc4=3Dar.rsc			// save RSE configuration
 	dep.z loc2=3Dloc2,0,61		// convert pal entry point to physical
 	dep.z r8=3Dr8,0,61		// convert rp to physical
@@ -216,7 +216,7 @@
 	mov out3 =3D in3		// copy arg3
 	;;
 	mov loc3 =3D psr		// save psr
-	;;=20
+	;;
 	mov loc4=3Dar.rsc			// save RSE configuration
 	dep.z loc2=3Dloc2,0,61		// convert pal entry point to physical
 	;;
diff -urN linux-davidm/arch/ia64/kernel/pci.c lia64-2.4/arch/ia64/kernel/pc=
i.c
--- linux-davidm/arch/ia64/kernel/pci.c	Wed Dec 26 16:58:36 2001
+++ lia64-2.4/arch/ia64/kernel/pci.c	Wed Apr 10 10:28:58 2002
@@ -42,101 +42,183 @@
 extern void ia64_mca_check_errors( void );
 #endif
=20
+struct pci_fixup pcibios_fixups[];
+
+struct pci_ops *pci_root_ops;
+
+int (*pci_config_read)(int seg, int bus, int dev, int fn, int reg, int len=
, u32 *value);
+int (*pci_config_write)(int seg, int bus, int dev, int fn, int reg, int le=
n, u32 value);
+
+
 /*
- * This interrupt-safe spinlock protects all accesses to PCI
- * configuration space.
+ * Low-level SAL-based PCI configuration access functions. Note that SAL
+ * calls are already serialized (via sal_lock), so we don't need another
+ * synchronization mechanism here.  Not using segment number (yet).
  */
-static spinlock_t pci_lock =3D SPIN_LOCK_UNLOCKED;
=20
-struct pci_fixup pcibios_fixups[] =3D {
-	{ 0 }
-};
+#define PCI_SAL_ADDRESS(bus, dev, fn, reg) \
+	((u64)(bus << 16) | (u64)(dev << 11) | (u64)(fn << 8) | (u64)(reg))
+
+static int
+pci_sal_read (int seg, int bus, int dev, int fn, int reg, int len, u32 *va=
lue)
+{
+	int result =3D 0;
+	u64 data =3D 0;
+
+	if (!value || (bus > 255) || (dev > 31) || (fn > 7) || (reg > 255))
+		return -EINVAL;
+
+	result =3D ia64_sal_pci_config_read(PCI_SAL_ADDRESS(bus, dev, fn, reg), l=
en, &data);
+
+	*value =3D (u32) data;
=20
-/* Macro to build a PCI configuration address to be passed as a parameter =
to SAL. */
+	return result;
+}
+
+static int
+pci_sal_write (int seg, int bus, int dev, int fn, int reg, int len, u32 va=
lue)
+{
+	if ((bus > 255) || (dev > 31) || (fn > 7) || (reg > 255))
+		return -EINVAL;
+
+	return ia64_sal_pci_config_write(PCI_SAL_ADDRESS(bus, dev, fn, reg), len,=
 value);
+}
=20
-#define PCI_CONFIG_ADDRESS(dev, where) \
-	(((u64) dev->bus->number << 16) | ((u64) (dev->devfn & 0xff) << 8) | (whe=
re & 0xff))
=20
 static int
-pci_conf_read_config_byte(struct pci_dev *dev, int where, u8 *value)
+pci_sal_read_config_byte (struct pci_dev *dev, int where, u8 *value)
 {
-	s64 status;
-	u64 lval;
+	int result =3D 0;
+	u32 data =3D 0;
=20
-	status =3D ia64_sal_pci_config_read(PCI_CONFIG_ADDRESS(dev, where), 1, &l=
val);
-	*value =3D lval;
-	return status;
+	if (!value)
+		return -EINVAL;
+
+	result =3D pci_sal_read(0, dev->bus->number, PCI_SLOT(dev->devfn),
+			      PCI_FUNC(dev->devfn), where, 1, &data);
+
+	*value =3D (u8) data;
+
+	return result;
 }
=20
 static int
-pci_conf_read_config_word(struct pci_dev *dev, int where, u16 *value)
+pci_sal_read_config_word (struct pci_dev *dev, int where, u16 *value)
 {
-	s64 status;
-	u64 lval;
+	int result =3D 0;
+	u32 data =3D 0;
+
+	if (!value)
+		return -EINVAL;
+
+	result =3D pci_sal_read(0, dev->bus->number, PCI_SLOT(dev->devfn),
+			      PCI_FUNC(dev->devfn), where, 2, &data);
=20
-	status =3D ia64_sal_pci_config_read(PCI_CONFIG_ADDRESS(dev, where), 2, &l=
val);
-	*value =3D lval;
-	return status;
+	*value =3D (u16) data;
+
+	return result;
 }
=20
 static int
-pci_conf_read_config_dword(struct pci_dev *dev, int where, u32 *value)
+pci_sal_read_config_dword (struct pci_dev *dev, int where, u32 *value)
 {
-	s64 status;
-	u64 lval;
+	if (!value)
+		return -EINVAL;
=20
-	status =3D ia64_sal_pci_config_read(PCI_CONFIG_ADDRESS(dev, where), 4, &l=
val);
-	*value =3D lval;
-	return status;
+	return pci_sal_read(0, dev->bus->number, PCI_SLOT(dev->devfn),
+			    PCI_FUNC(dev->devfn), where, 4, value);
 }
=20
 static int
-pci_conf_write_config_byte (struct pci_dev *dev, int where, u8 value)
+pci_sal_write_config_byte (struct pci_dev *dev, int where, u8 value)
 {
-	return ia64_sal_pci_config_write(PCI_CONFIG_ADDRESS(dev, where), 1, value=
);
+	return pci_sal_write(0, dev->bus->number, PCI_SLOT(dev->devfn),
+			     PCI_FUNC(dev->devfn), where, 1, value);
 }
=20
 static int
-pci_conf_write_config_word (struct pci_dev *dev, int where, u16 value)
+pci_sal_write_config_word (struct pci_dev *dev, int where, u16 value)
 {
-	return ia64_sal_pci_config_write(PCI_CONFIG_ADDRESS(dev, where), 2, value=
);
+	return pci_sal_write(0, dev->bus->number, PCI_SLOT(dev->devfn),
+			     PCI_FUNC(dev->devfn), where, 2, value);
 }
=20
 static int
-pci_conf_write_config_dword (struct pci_dev *dev, int where, u32 value)
+pci_sal_write_config_dword (struct pci_dev *dev, int where, u32 value)
 {
-	return ia64_sal_pci_config_write(PCI_CONFIG_ADDRESS(dev, where), 4, value=
);
+	return pci_sal_write(0, dev->bus->number, PCI_SLOT(dev->devfn),
+			     PCI_FUNC(dev->devfn), where, 4, value);
 }
=20
-struct pci_ops pci_conf =3D {
-      pci_conf_read_config_byte,
-      pci_conf_read_config_word,
-      pci_conf_read_config_dword,
-      pci_conf_write_config_byte,
-      pci_conf_write_config_word,
-      pci_conf_write_config_dword
+struct pci_ops pci_sal_ops =3D {
+	pci_sal_read_config_byte,
+	pci_sal_read_config_word,
+	pci_sal_read_config_dword,
+	pci_sal_write_config_byte,
+	pci_sal_write_config_word,
+	pci_sal_write_config_dword
 };
=20
+
 /*
  * Initialization. Uses the SAL interface
  */
+
+struct pci_bus *
+pcibios_scan_root(int seg, int bus)
+{
+	struct list_head *list =3D NULL;
+	struct pci_bus *pci_bus =3D NULL;
+
+	list_for_each(list, &pci_root_buses) {
+		pci_bus =3D pci_bus_b(list);
+		if (pci_bus->number =3D bus) {
+			/* Already scanned */
+			printk("PCI: Bus (%02x:%02x) already probed\n", seg, bus);
+			return pci_bus;
+		}
+	}
+
+	printk("PCI: Probing PCI hardware on bus (%02x:%02x)\n", seg, bus);
+
+	return pci_scan_bus(bus, pci_root_ops, NULL);
+}
+
+void __init
+pcibios_config_init (void)
+{
+	if (pci_root_ops)
+		return;
+
+	printk("PCI: Using SAL to access configuration space\n");
+
+	pci_root_ops =3D &pci_sal_ops;
+	pci_config_read =3D pci_sal_read;
+	pci_config_write =3D pci_sal_write;
+
+	return;
+}
+
 void __init
 pcibios_init (void)
 {
 #	define PCI_BUSES_TO_SCAN 255
-	int i;
+	int i =3D 0;
=20
 #ifdef CONFIG_IA64_MCA
 	ia64_mca_check_errors();    /* For post-failure MCA error logging */
 #endif
=20
-	platform_pci_fixup(0);	/* phase 0 initialization (before PCI bus has been=
 scanned) */
+	pcibios_config_init();
+
+	platform_pci_fixup(0);	/* phase 0 fixups (before buses scanned) */
=20
 	printk("PCI: Probing PCI hardware\n");
 	for (i =3D 0; i < PCI_BUSES_TO_SCAN; i++)
-		pci_scan_bus(i, &pci_conf, NULL);
+		pci_scan_bus(i, pci_root_ops, NULL);
+
+	platform_pci_fixup(1);	/* phase 1 fixups (after buses scanned) */
=20
-	platform_pci_fixup(1);	/* phase 1 initialization (after PCI bus has been =
scanned) */
 	return;
 }
=20
@@ -186,7 +268,14 @@
 int
 pcibios_enable_device (struct pci_dev *dev)
 {
+	if (!dev)
+		return -EINVAL;
+
 	/* Not needed, since we enable all devices at startup.  */
+
+	printk(KERN_INFO "PCI: Found IRQ %d for device %s\n", dev->irq,=20
+		dev->slot_name);
+
 	return 0;
 }
=20
diff -urN linux-davidm/arch/ia64/kernel/perfmon.c lia64-2.4/arch/ia64/kerne=
l/perfmon.c
--- linux-davidm/arch/ia64/kernel/perfmon.c	Wed Apr 10 13:24:25 2002
+++ lia64-2.4/arch/ia64/kernel/perfmon.c	Tue Apr  9 13:23:36 2002
@@ -23,6 +23,7 @@
 #include <linux/vmalloc.h>
 #include <linux/wrapper.h>
 #include <linux/mm.h>
+#include <linux/sysctl.h>
=20
 #include <asm/bitops.h>
 #include <asm/errno.h>
@@ -42,7 +43,7 @@
  * you must enable the following flag to activate the support for
  * accessing the registers via the perfmonctl() interface.
  */
-#ifdef CONFIG_ITANIUM
+#if defined(CONFIG_ITANIUM) || defined(CONFIG_MCKINLEY)
 #define PFM_PMU_USES_DBR	1
 #endif
=20
@@ -68,26 +69,27 @@
 #define PMC_OVFL_NOTIFY(ctx, i)	((ctx)->ctx_soft_pmds[i].flags &  PFM_REGF=
L_OVFL_NOTIFY)
 #define PFM_FL_INHERIT_MASK	(PFM_FL_INHERIT_NONE|PFM_FL_INHERIT_ONCE|PFM_F=
L_INHERIT_ALL)
=20
+/* i assume unsigned */
 #define PMC_IS_IMPL(i)	  (i<pmu_conf.num_pmcs && pmu_conf.impl_regs[i>>6] =
& (1UL<< (i) %64))
 #define PMD_IS_IMPL(i)	  (i<pmu_conf.num_pmds &&  pmu_conf.impl_regs[4+(i>=
>6)] & (1UL<<(i) % 64))
=20
-#define PMD_IS_COUNTING(i) (i >=3D0  && i < 256 && pmu_conf.counter_pmds[i=
>>6] & (1UL <<(i) % 64))
-#define PMC_IS_COUNTING(i) PMD_IS_COUNTING(i)
+/* XXX: these three assume that register i is implemented */
+#define PMD_IS_COUNTING(i) (pmu_conf.pmd_desc[i].type =3D PFM_REG_COUNTING)
+#define PMC_IS_COUNTING(i) (pmu_conf.pmc_desc[i].type =3D PFM_REG_COUNTING)
+#define PMC_IS_MONITOR(c)  (pmu_conf.pmc_desc[i].type =3D PFM_REG_MONITOR)
=20
+/* k assume unsigned */
 #define IBR_IS_IMPL(k)	  (k<pmu_conf.num_ibrs)
 #define DBR_IS_IMPL(k)	  (k<pmu_conf.num_dbrs)
=20
-#define PMC_IS_BTB(a)	  (((pfm_monitor_t *)(a))->pmc_es =3D PMU_BTB_EVENT)
-
-#define LSHIFT(x)		(1UL<<(x))
-#define PMM(x)			LSHIFT(x)
-#define PMC_IS_MONITOR(c)	((pmu_conf.monitor_pmcs[0] & PMM((c))) !=3D 0)
-
 #define CTX_IS_ENABLED(c) 	((c)->ctx_flags.state =3D PFM_CTX_ENABLED)
 #define CTX_OVFL_NOBLOCK(c)	((c)->ctx_fl_block =3D 0)
 #define CTX_INHERIT_MODE(c)	((c)->ctx_fl_inherit)
 #define CTX_HAS_SMPL(c)		((c)->ctx_psb !=3D NULL)
-#define CTX_USED_PMD(ctx,n) 	(ctx)->ctx_used_pmds[(n)>>6] |=3D 1UL<< ((n) =
% 64)
+/* XXX: does not support more than 64 PMDs */
+#define CTX_USED_PMD(ctx, mask) (ctx)->ctx_used_pmds[0] |=3D (mask)
+#define CTX_IS_USED_PMD(ctx, c) (((ctx)->ctx_used_pmds[0] & (1UL << (c))) =
!=3D 0UL)
+
=20
 #define CTX_USED_IBR(ctx,n) 	(ctx)->ctx_used_ibrs[(n)>>6] |=3D 1UL<< ((n) =
% 64)
 #define CTX_USED_DBR(ctx,n) 	(ctx)->ctx_used_dbrs[(n)>>6] |=3D 1UL<< ((n) =
% 64)
@@ -109,12 +111,12 @@
  */
 #define DBprintk(a) \
 	do { \
-		if (pfm_debug_mode >0) { printk("%s.%d: CPU%d ", __FUNCTION__, __LINE__,=
 smp_processor_id()); printk a; } \
+		if (pfm_debug_mode >0 || pfm_sysctl.debug >0) { printk("%s.%d: CPU%d ", =
__FUNCTION__, __LINE__, smp_processor_id()); printk a; } \
 	} while (0)
=20
=20
 /*=20
- * These are some helpful architected PMC and IBR/DBR register layouts
+ * Architected PMC structure
  */
 typedef struct {
 	unsigned long pmc_plm:4;	/* privilege level mask */
@@ -158,22 +160,17 @@
 #define PFM_PSB_VMA	0x1			/* a VMA is describing the buffer */
=20
 /*
- * This structure is initialized at boot time and contains
- * a description of the PMU main characteristic as indicated
- * by PAL
+ * The possible type of a PMU register
  */
-typedef struct {
-	unsigned long pfm_is_disabled;	/* indicates if perfmon is working properl=
y */
-	unsigned long perf_ovfl_val;	/* overflow value for generic counters   */
-	unsigned long max_counters;	/* upper limit on counter pair (PMC/PMD) */
-	unsigned long num_pmcs ;	/* highest PMC implemented (may have holes) */
-	unsigned long num_pmds;		/* highest PMD implemented (may have holes) */
-	unsigned long impl_regs[16];	/* buffer used to hold implememted PMC/PMD m=
ask */
-	unsigned long num_ibrs;		/* number of instruction debug registers */
-	unsigned long num_dbrs;		/* number of data debug registers */
-	unsigned long monitor_pmcs[4];	/* which pmc are controlling monitors */
-	unsigned long counter_pmds[4];	/* which pmd are used as counters */
-} pmu_config_t;
+typedef enum {=20
+	PFM_REG_NOTIMPL, /* not implemented */
+	PFM_REG_NONE, 	 /* end marker */
+	PFM_REG_MONITOR, /* a PMC with a pmc.pm field only */
+	PFM_REG_COUNTING,/* a PMC with a pmc.pm AND pmc.oi, a PMD used as a count=
er */
+	PFM_REG_CONTROL, /* PMU control register */
+	PFM_REG_CONFIG,  /* refine configuration */
+	PFM_REG_BUFFER	 /* PMD used as buffer */
+} pfm_pmu_reg_type_t;
=20
 /*
  * 64-bit software counter structure
@@ -221,9 +218,11 @@
=20
 	struct semaphore	ctx_restart_sem;   	/* use for blocking notification mod=
e */
=20
-	unsigned long		ctx_used_pmds[4];	/* bitmask of used PMD (speedup ctxsw) */
-	unsigned long		ctx_saved_pmcs[4];	/* bitmask of PMC to save on ctxsw */
-	unsigned long		ctx_reload_pmcs[4];	/* bitmask of PMC to reload on ctxsw (=
SMP) */
+	unsigned long		ctx_used_pmds[4];	/* bitmask of PMD used                 */
+	unsigned long		ctx_reload_pmds[4];	/* bitmask of PMD to reload on ctxsw  =
 */
+
+	unsigned long		ctx_used_pmcs[4];	/* bitmask PMC used by context         */
+	unsigned long		ctx_reload_pmcs[4];	/* bitmask of PMC to reload on ctxsw  =
 */
=20
 	unsigned long		ctx_used_ibrs[4];	/* bitmask of used IBR (speedup ctxsw) */
 	unsigned long		ctx_used_dbrs[4];	/* bitmask of used DBR (speedup ctxsw) */
@@ -235,6 +234,7 @@
 	unsigned long		ctx_cpu;		/* cpu to which perfmon is applied (system wide)=
 */
=20
 	atomic_t		ctx_saving_in_progress;	/* flag indicating actual save in progr=
ess */
+	atomic_t		ctx_is_busy;		/* context accessed by overflow handler */
 	atomic_t		ctx_last_cpu;		/* CPU id of current or last CPU used */
 } pfm_context_t;
=20
@@ -250,16 +250,54 @@
  * mostly used to synchronize between system wide and per-process
  */
 typedef struct {
-	spinlock_t		pfs_lock;		/* lock the structure */
+	spinlock_t		pfs_lock;		   /* lock the structure */
=20
-	unsigned long		pfs_task_sessions;	/* number of per task sessions */
-	unsigned long		pfs_sys_sessions;	/* number of per system wide sessions */
-	unsigned long   	pfs_sys_use_dbregs;	  	/* incremented when a system wide=
 session uses debug regs */
-	unsigned long   	pfs_ptrace_use_dbregs;	  /* incremented when a process u=
ses debug regs */
-	struct task_struct	*pfs_sys_session[NR_CPUS];  /* point to task owning a =
system-wide session */
+	unsigned long		pfs_task_sessions;	   /* number of per task sessions */
+	unsigned long		pfs_sys_sessions;	   /* number of per system wide sessions=
 */
+	unsigned long   	pfs_sys_use_dbregs;	   /* incremented when a system wide=
 session uses debug regs */
+	unsigned long   	pfs_ptrace_use_dbregs;	   /* incremented when a process =
uses debug regs */
+	struct task_struct	*pfs_sys_session[NR_CPUS]; /* point to task owning a s=
ystem-wide session */
 } pfm_session_t;
=20
 /*
+ * information about a PMC or PMD.
+ * dep_pmd[]: a bitmask of dependent PMD registers=20
+ * dep_pmc[]: a bitmask of dependent PMC registers
+ */
+typedef struct {
+	pfm_pmu_reg_type_t	type;
+	int			pm_pos;
+	int			(*read_check)(struct task_struct *task, unsigned int cnum, unsigned=
 long *val);
+	int			(*write_check)(struct task_struct *task, unsigned int cnum, unsigne=
d long *val);
+	unsigned long		dep_pmd[4];
+	unsigned long		dep_pmc[4];
+} pfm_reg_desc_t;
+/* assume cnum is a valid monitor */
+#define PMC_PM(cnum, val)	(((val) >> (pmu_conf.pmc_desc[cnum].pm_pos)) & 0=
x1)
+#define PMC_WR_FUNC(cnum)	(pmu_conf.pmc_desc[cnum].write_check)
+#define PMD_WR_FUNC(cnum)	(pmu_conf.pmd_desc[cnum].write_check)
+#define PMD_RD_FUNC(cnum)	(pmu_conf.pmd_desc[cnum].read_check)
+
+/*
+ * This structure is initialized at boot time and contains
+ * a description of the PMU main characteristic as indicated
+ * by PAL along with a list of inter-registers dependencies and configurat=
ions.
+ */
+typedef struct {
+	unsigned long pfm_is_disabled;	/* indicates if perfmon is working properl=
y */
+	unsigned long perf_ovfl_val;	/* overflow value for generic counters   */
+	unsigned long max_counters;	/* upper limit on counter pair (PMC/PMD) */
+	unsigned long num_pmcs ;	/* highest PMC implemented (may have holes) */
+	unsigned long num_pmds;		/* highest PMD implemented (may have holes) */
+	unsigned long impl_regs[16];	/* buffer used to hold implememted PMC/PMD m=
ask */
+	unsigned long num_ibrs;		/* number of instruction debug registers */
+	unsigned long num_dbrs;		/* number of data debug registers */
+	pfm_reg_desc_t *pmc_desc;	/* detailed PMC register descriptions */
+	pfm_reg_desc_t *pmd_desc;	/* detailed PMD register descriptions */
+} pmu_config_t;
+
+
+/*
  * structure used to pass argument to/from remote CPU=20
  * using IPI to check and possibly save the PMU context on SMP systems.
  *
@@ -301,6 +339,19 @@
 #define PFM_CMD_NARG(cmd)	(pfm_cmd_tab[PFM_CMD_IDX(cmd)].cmd_narg)
 #define PFM_CMD_ARG_SIZE(cmd)	(pfm_cmd_tab[PFM_CMD_IDX(cmd)].cmd_argsize)
=20
+typedef struct {
+	int	debug;		/* turn on/off debugging via syslog */
+	int	fastctxsw;	/* turn on/off fast (unsecure) ctxsw */
+} pfm_sysctl_t;
+
+typedef struct {
+	unsigned long pfm_spurious_ovfl_intr_count; /* keep track of spurious ovf=
l interrupts */
+	unsigned long pfm_ovfl_intr_count; /* keep track of spurious ovfl interru=
pts */
+	unsigned long pfm_recorded_samples_count;
+	unsigned long pfm_restore_dbrs;
+	unsigned long pfm_ctxsw_reload_pmds;
+	unsigned long pfm_ctxsw_used_pmds;
+} pfm_stats_t;
=20
 /*
  * perfmon internal variables
@@ -309,14 +360,30 @@
 static int		pfm_debug_mode;	/* 0=3D nodebug, >0=3D debug output on */
 static pfm_session_t	pfm_sessions;	/* global sessions information */
 static struct proc_dir_entry *perfmon_dir; /* for debug only */
-static unsigned long pfm_spurious_ovfl_intr_count; /* keep track of spurio=
us ovfl interrupts */
-static unsigned long pfm_ovfl_intr_count; /* keep track of spurious ovfl i=
nterrupts */
-static unsigned long pfm_recorded_samples_count;
+static pfm_stats_t	pfm_stats;
=20
+/* sysctl() controls */
+static pfm_sysctl_t pfm_sysctl;
+
+static ctl_table pfm_ctl_table[]=3D{
+	{1, "debug", &pfm_sysctl.debug, sizeof(int), 0666, NULL, &proc_dointvec, =
NULL,},
+	{1, "fastctxsw", &pfm_sysctl.fastctxsw, sizeof(int), 0600, NULL, &proc_do=
intvec, NULL,},
+	{ 0, },
+};
+static ctl_table pfm_sysctl_dir[] =3D {
+	{1, "perfmon", NULL, 0, 0755, pfm_ctl_table, },
+ 	{0,},
+};
+static ctl_table pfm_sysctl_root[] =3D {
+	{1, "kernel", NULL, 0, 0755, pfm_sysctl_dir, },
+ 	{0,},
+};
+static struct ctl_table_header *pfm_sysctl_header;
=20
 static unsigned long reset_pmcs[IA64_NUM_PMC_REGS];	/* contains PAL reset =
values for PMCS */
=20
 static void pfm_vm_close(struct vm_area_struct * area);
+
 static struct vm_operations_struct pfm_vm_ops=3D{
 	close: pfm_vm_close
 };
@@ -339,6 +406,14 @@
 #endif
 static void pfm_lazy_save_regs (struct task_struct *ta);
=20
+#if   defined(CONFIG_ITANIUM)
+#include "perfmon_itanium.h"
+#elif defined(CONFIG_MCKINLEY)
+#include "perfmon_mckinley.h"
+#else
+#include "perfmon_generic.h"
+#endif
+=20
 static inline unsigned long
 pfm_read_soft_counter(pfm_context_t *ctx, int i)
 {
@@ -353,7 +428,7 @@
 	 * writing to unimplemented part is ignore, so we do not need to
 	 * mask off top part
 	 */
-	ia64_set_pmd(i, val);
+	ia64_set_pmd(i, val & pmu_conf.perf_ovfl_val);
 }
=20
 /*
@@ -424,7 +499,6 @@
 	return pa;
 }
=20
-
 static void *
 pfm_rvmalloc(unsigned long size)
 {
@@ -1010,20 +1084,12 @@
=20
 	atomic_set(&ctx->ctx_last_cpu,-1); /* SMP only, means no CPU */
=20
-	/*=20
-	 * Keep track of the pmds we want to sample
-	 * XXX: may be we don't need to save/restore the DEAR/IEAR pmds
-	 * but we do need the BTB for sure. This is because of a hardware
-	 * buffer of 1 only for non-BTB pmds.
-	 *
-	 * We ignore the unimplemented pmds specified by the user
-	 */
-	ctx->ctx_used_pmds[0]  =3D tmp.ctx_smpl_regs[0] & pmu_conf.impl_regs[4];
-	ctx->ctx_saved_pmcs[0] =3D 1; /* always save/restore PMC[0] */
+	/* may be redudant with memset() but at least it's easier to remember */
+	atomic_set(&ctx->ctx_saving_in_progress, 0);=20
+	atomic_set(&ctx->ctx_is_busy, 0);=20
=20
 	sema_init(&ctx->ctx_restart_sem, 0); /* init this semaphore to locked */
=20
-
 	if (copy_to_user(req, &tmp, sizeof(tmp))) {
 		ret =3D -EFAULT;
 		goto buffer_error;
@@ -1131,16 +1197,16 @@
 }
=20
 static int
-pfm_write_pmcs(struct task_struct *ta, pfm_context_t *ctx, void *arg, int =
count, struct pt_regs *regs)
+pfm_write_pmcs(struct task_struct *task, pfm_context_t *ctx, void *arg, in=
t count, struct pt_regs *regs)
 {
-	struct thread_struct *th =3D &ta->thread;
+	struct thread_struct *th =3D &task->thread;
 	pfarg_reg_t tmp, *req =3D (pfarg_reg_t *)arg;
 	unsigned int cnum;
 	int i;
 	int ret =3D 0, reg_retval =3D 0;
=20
 	/* we don't quite support this right now */
-	if (ta !=3D current) return -EINVAL;
+	if (task !=3D current) return -EINVAL;
=20
 	if (!CTX_IS_ENABLED(ctx)) return -EINVAL;
=20
@@ -1169,30 +1235,30 @@
 		 * 	- per-task : user monitor
 		 * any other configuration is rejected.
 		 */
-		if (PMC_IS_MONITOR(cnum)) {
-			pfm_monitor_t *p =3D (pfm_monitor_t *)&tmp.reg_value;
+		if (PMC_IS_MONITOR(cnum) || PMC_IS_COUNTING(cnum)) {
+			DBprintk(("pmc[%u].pm=3D%ld\n", cnum, PMC_PM(cnum, tmp.reg_value)));=20
=20
-			DBprintk(("pmc[%u].pm =3D %d\n", cnum, p->pmc_pm));
-
-			if (ctx->ctx_fl_system ^ p->pmc_pm) {
-			//if ((ctx->ctx_fl_system =3D 1 && p->pmc_pm =3D 0)
-			 //  ||(ctx->ctx_fl_system =3D 0 && p->pmc_pm =3D 1)) {
+			if (ctx->ctx_fl_system ^ PMC_PM(cnum, tmp.reg_value)) {
+				DBprintk(("pmc_pm=3D%ld fl_system=3D%d\n", PMC_PM(cnum, tmp.reg_value)=
, ctx->ctx_fl_system));
 				ret =3D -EINVAL;
 				goto abort_mission;
 			}
-			/*
-			 * enforce generation of overflow interrupt. Necessary on all
-			 * CPUs which do not implement 64-bit hardware counters.
-			 */
-			p->pmc_oi =3D 1;
 		}
=20
 		if (PMC_IS_COUNTING(cnum)) {
+			pfm_monitor_t *p =3D (pfm_monitor_t *)&tmp.reg_value;
+			/*
+		 	 * enforce generation of overflow interrupt. Necessary on all
+		 	 * CPUs.
+		 	 */
+			p->pmc_oi =3D 1;
+
 			if (tmp.reg_flags & PFM_REGFL_OVFL_NOTIFY) {
 				/*
 				 * must have a target for the signal
 				 */
 				if (ctx->ctx_notify_task =3D NULL) {
+					DBprintk(("no notify_task && PFM_REGFL_OVFL_NOTIFY\n"));
 					ret =3D -EINVAL;
 					goto abort_mission;
 				}
@@ -1206,14 +1272,11 @@
 			ctx->ctx_soft_pmds[cnum].reset_pmds[1] =3D tmp.reg_reset_pmds[1];
 			ctx->ctx_soft_pmds[cnum].reset_pmds[2] =3D tmp.reg_reset_pmds[2];
 			ctx->ctx_soft_pmds[cnum].reset_pmds[3] =3D tmp.reg_reset_pmds[3];
-
-			/*
-			 * needed in case the user does not initialize the equivalent
-			 * PMD. Clearing is done in reset_pmu() so there is no possible
-			 * leak here.
-			 */
-			CTX_USED_PMD(ctx, cnum);
 		}
+		/*
+		 * execute write checker, if any
+		 */
+		if (PMC_WR_FUNC(cnum)) ret =3D PMC_WR_FUNC(cnum)(task, cnum, &tmp.reg_va=
lue);
 abort_mission:
 		if (ret =3D -EINVAL) reg_retval =3D PFM_REG_RETFL_EINVAL;
=20
@@ -1233,14 +1296,21 @@
 		 */
 		if (ret !=3D 0) {
 			DBprintk(("[%d] pmc[%u]=3D0x%lx error %d\n",
-				  ta->pid, cnum, tmp.reg_value, reg_retval));
+				  task->pid, cnum, tmp.reg_value, reg_retval));
 			break;
 		}
=20
 		/*=20
 		 * We can proceed with this register!
 		 */
-	=09
+
+		/*
+		 * Needed in case the user does not initialize the equivalent
+		 * PMD. Clearing is done in reset_pmu() so there is no possible
+		 * leak here.
+		 */
+		CTX_USED_PMD(ctx, pmu_conf.pmc_desc[cnum].dep_pmd[0]);
+
 		/*=20
 		 * keep copy the pmc, used for register reload
 		 */
@@ -1248,17 +1318,17 @@
=20
 		ia64_set_pmc(cnum, tmp.reg_value);
=20
-		DBprintk(("[%d] pmc[%u]=3D0x%lx flags=3D0x%x save_pmcs=3D0%lx reload_pmc=
s=3D0x%lx\n",=20
-			  ta->pid, cnum, tmp.reg_value,=20
+		DBprintk(("[%d] pmc[%u]=3D0x%lx flags=3D0x%x used_pmds=3D0x%lx\n",=20
+			  task->pid, cnum, tmp.reg_value,=20
 			  ctx->ctx_soft_pmds[cnum].flags,=20
-			  ctx->ctx_saved_pmcs[0], ctx->ctx_reload_pmcs[0]));
+			  ctx->ctx_used_pmds[0]));
=20
 	}
 	return ret;
 }
=20
 static int
-pfm_write_pmds(struct task_struct *ta, pfm_context_t *ctx, void *arg, int =
count, struct pt_regs *regs)
+pfm_write_pmds(struct task_struct *task, pfm_context_t *ctx, void *arg, in=
t count, struct pt_regs *regs)
 {
 	pfarg_reg_t tmp, *req =3D (pfarg_reg_t *)arg;
 	unsigned int cnum;
@@ -1266,7 +1336,7 @@
 	int ret =3D 0, reg_retval =3D 0;
=20
 	/* we don't quite support this right now */
-	if (ta !=3D current) return -EINVAL;
+	if (task !=3D current) return -EINVAL;
=20
 	/*=20
 	 * Cannot do anything before PMU is enabled=20
@@ -1281,7 +1351,6 @@
 		if (copy_from_user(&tmp, req, sizeof(tmp))) return -EFAULT;
=20
 		cnum =3D tmp.reg_num;
-
 		if (!PMD_IS_IMPL(cnum)) {
 			ret =3D -EINVAL;
 			goto abort_mission;
@@ -1295,6 +1364,10 @@
 			ctx->ctx_soft_pmds[cnum].short_reset =3D tmp.reg_short_reset;
=20
 		}
+		/*
+		 * execute write checker, if any
+		 */
+		if (PMD_WR_FUNC(cnum)) ret =3D PMD_WR_FUNC(cnum)(task, cnum, &tmp.reg_va=
lue);
 abort_mission:
 		if (ret =3D -EINVAL) reg_retval =3D PFM_REG_RETFL_EINVAL;
=20
@@ -1311,21 +1384,22 @@
 		 */
 		if (ret !=3D 0) {
 			DBprintk(("[%d] pmc[%u]=3D0x%lx error %d\n",
-				  ta->pid, cnum, tmp.reg_value, reg_retval));
+				  task->pid, cnum, tmp.reg_value, reg_retval));
 			break;
 		}
=20
 		/* keep track of what we use */
-		CTX_USED_PMD(ctx, cnum);
+		CTX_USED_PMD(ctx, pmu_conf.pmd_desc[(cnum)].dep_pmd[0]);
=20
 		/* writes to unimplemented part is ignored, so this is safe */
-		ia64_set_pmd(cnum, tmp.reg_value);
+		ia64_set_pmd(cnum, tmp.reg_value & pmu_conf.perf_ovfl_val);
=20
 		/* to go away */
 		ia64_srlz_d();
+
 		DBprintk(("[%d] pmd[%u]: soft_pmd=3D0x%lx  short_reset=3D0x%lx "
 			  "long_reset=3D0x%lx hw_pmd=3D%lx notify=3D%c used_pmds=3D0x%lx reset_=
pmds=3D0x%lx\n",
-				ta->pid, cnum,
+				task->pid, cnum,
 				ctx->ctx_soft_pmds[cnum].val,
 				ctx->ctx_soft_pmds[cnum].short_reset,
 				ctx->ctx_soft_pmds[cnum].long_reset,
@@ -1338,12 +1412,13 @@
 }
=20
 static int
-pfm_read_pmds(struct task_struct *ta, pfm_context_t *ctx, void *arg, int c=
ount, struct pt_regs *regs)
+pfm_read_pmds(struct task_struct *task, pfm_context_t *ctx, void *arg, int=
 count, struct pt_regs *regs)
 {
-	struct thread_struct *th =3D &ta->thread;
+	struct thread_struct *th =3D &task->thread;
 	unsigned long val=3D0;
 	pfarg_reg_t tmp, *req =3D (pfarg_reg_t *)arg;
-	int i;
+	unsigned int cnum;
+	int i, ret =3D 0;
=20
 	if (!CTX_IS_ENABLED(ctx)) return -EINVAL;
=20
@@ -1356,14 +1431,25 @@
=20
 	/* XXX: ctx locking may be required here */
=20
-	DBprintk(("ctx_last_cpu=3D%d for [%d]\n", atomic_read(&ctx->ctx_last_cpu)=
, ta->pid));
+	DBprintk(("ctx_last_cpu=3D%d for [%d]\n", atomic_read(&ctx->ctx_last_cpu)=
, task->pid));
=20
 	for (i =3D 0; i < count; i++, req++) {
 		unsigned long reg_val =3D ~0UL, ctx_val =3D ~0UL;
=20
 		if (copy_from_user(&tmp, req, sizeof(tmp))) return -EFAULT;
=20
-		if (!PMD_IS_IMPL(tmp.reg_num)) goto abort_mission;
+		cnum =3D tmp.reg_num;
+
+		if (!PMD_IS_IMPL(cnum)) goto abort_mission;
+		/*
+		 * we can only read the register that we use. That includes
+		 * the one we explicitely initialize AND the one we want included
+		 * in the sampling buffer (smpl_regs).
+		 *
+		 * Having this restriction allows optimization in the ctxsw routine
+		 * without compromising security (leaks)
+		 */
+		if (!CTX_IS_USED_PMD(ctx, cnum)) goto abort_mission;
=20
 		/*
 		 * If the task is not the current one, then we check if the
@@ -1372,8 +1458,8 @@
 		 */
 		if (atomic_read(&ctx->ctx_last_cpu) =3D smp_processor_id()){
 			ia64_srlz_d();
-			val =3D reg_val =3D ia64_get_pmd(tmp.reg_num);
-			DBprintk(("reading pmd[%u]=3D0x%lx from hw\n", tmp.reg_num, val));
+			val =3D reg_val =3D ia64_get_pmd(cnum);
+			DBprintk(("reading pmd[%u]=3D0x%lx from hw\n", cnum, val));
 		} else {
 #ifdef CONFIG_SMP
 			int cpu;
@@ -1389,30 +1475,38 @@
 			 */
 			cpu =3D atomic_read(&ctx->ctx_last_cpu);
 			if (cpu !=3D -1) {
-				DBprintk(("must fetch on CPU%d for [%d]\n", cpu, ta->pid));
-				pfm_fetch_regs(cpu, ta, ctx);
+				DBprintk(("must fetch on CPU%d for [%d]\n", cpu, task->pid));
+				pfm_fetch_regs(cpu, task, ctx);
 			}
 #endif
 			/* context has been saved */
-			val =3D reg_val =3D th->pmd[tmp.reg_num];
+			val =3D reg_val =3D th->pmd[cnum];
 		}
-		if (PMD_IS_COUNTING(tmp.reg_num)) {
+		if (PMD_IS_COUNTING(cnum)) {
 			/*
 			 * XXX: need to check for overflow
 			 */
=20
 			val &=3D pmu_conf.perf_ovfl_val;
-			val +=3D ctx_val =3D ctx->ctx_soft_pmds[tmp.reg_num].val;
+			val +=3D ctx_val =3D ctx->ctx_soft_pmds[cnum].val;
 		} else {
-
-			val =3D reg_val =3D ia64_get_pmd(tmp.reg_num);
+			val =3D reg_val =3D ia64_get_pmd(cnum);
 		}
-		PFM_REG_RETFLAG_SET(tmp.reg_flags, 0);
+
 		tmp.reg_value =3D val;
=20
-		DBprintk(("read pmd[%u] soft_pmd=3D0x%lx reg=3D0x%lx pmc=3D0x%lx\n",=20
-					tmp.reg_num, ctx_val, reg_val,=20
-					ia64_get_pmc(tmp.reg_num)));
+		/*
+		 * execute read checker, if any
+		 */
+		if (PMD_RD_FUNC(cnum)) {
+			ret =3D PMD_RD_FUNC(cnum)(task, cnum, &tmp.reg_value);
+		}
+
+		PFM_REG_RETFLAG_SET(tmp.reg_flags, ret);
+
+		DBprintk(("read pmd[%u] ret=3D%d soft_pmd=3D0x%lx reg=3D0x%lx pmc=3D0x%l=
x\n",=20
+					cnum, ret, ctx_val, reg_val,=20
+					ia64_get_pmc(cnum)));
=20
 		if (copy_to_user(req, &tmp, sizeof(tmp))) return -EFAULT;
 	}
@@ -1534,12 +1628,6 @@
 	 */
 	if (!CTX_IS_ENABLED(ctx)) return -EINVAL;
=20
-
-	if (ctx->ctx_fl_frozen=3D0) {
-		printk("task %d without pmu_frozen set\n", task->pid);
-		return -EINVAL;
-	}
-
 	if (task =3D current) {
 		DBprintk(("restarting self %d frozen=3D%d \n", current->pid, ctx->ctx_fl=
_frozen));
=20
@@ -1882,15 +1970,17 @@
 			memset(task->thread.ibr, 0, sizeof(task->thread.ibr));
=20
 			/*
-			 * clear hardware registers to make sure we don't leak
-			 * information and pick up stale state
+			 * clear hardware registers to make sure we don't
+			 * pick up stale state
 			 */
 			for (i=3D0; i < pmu_conf.num_ibrs; i++) {
 				ia64_set_ibr(i, 0UL);
 			}
+			ia64_srlz_i();
 			for (i=3D0; i < pmu_conf.num_dbrs; i++) {
 				ia64_set_dbr(i, 0UL);
 			}
+			ia64_srlz_d();
 		}
 	}
=20
@@ -1951,6 +2041,7 @@
 			CTX_USED_IBR(ctx, rnum);
=20
 			ia64_set_ibr(rnum, dbreg.val);
+			ia64_srlz_i();
=20
 			thread->ibr[rnum] =3D dbreg.val;
=20
@@ -1959,6 +2050,7 @@
 			CTX_USED_DBR(ctx, rnum);
=20
 			ia64_set_dbr(rnum, dbreg.val);
+			ia64_srlz_d();
=20
 			thread->dbr[rnum] =3D dbreg.val;
=20
@@ -2387,7 +2479,8 @@
 	int j;
=20
=20
-pfm_recorded_samples_count++;
+	pfm_stats.pfm_recorded_samples_count++;
+
 	idx =3D ia64_fetch_and_add(1, &psb->psb_index);
 	DBprintk(("recording index=3D%ld entries=3D%ld\n", idx-1, psb->psb_entrie=
s));
=20
@@ -2467,15 +2560,13 @@
  *	new value of pmc[0]. if 0x0 then unfreeze, else keep frozen
  */
 static unsigned long
-pfm_overflow_handler(struct task_struct *task, u64 pmc0, struct pt_regs *r=
egs)
+pfm_overflow_handler(struct task_struct *task, pfm_context_t *ctx, u64 pmc=
0, struct pt_regs *regs)
 {
 	unsigned long mask;
 	struct thread_struct *t;
-	pfm_context_t *ctx;
 	unsigned long old_val;
 	unsigned long ovfl_notify =3D 0UL, ovfl_pmds =3D 0UL;
 	int i;
-	int my_cpu =3D smp_processor_id();
 	int ret =3D 1;
 	struct siginfo si;
 	/*
@@ -2491,18 +2582,7 @@
 	 * valid one, i.e. the one that caused the interrupt.
 	 */
=20
-	if (task =3D NULL) {
-		DBprintk(("owners[%d]=3DNULL\n", my_cpu));
-		return 0x1;
-	}
 	t   =3D &task->thread;
-	ctx =3D task->thread.pfm_context;
-
-	if (!ctx) {
-		printk("perfmon: Spurious overflow interrupt: process %d has no PFM cont=
ext\n",=20
-			task->pid);
-		return 0;
-	}
=20
 	/*
 	 * XXX: debug test
@@ -2525,11 +2605,11 @@
 	mask =3D pmc0 >> PMU_FIRST_COUNTER;
=20
 	DBprintk(("pmc0=3D0x%lx pid=3D%d iip=3D0x%lx, %s"
-		  " mode used_pmds=3D0x%lx save_pmcs=3D0x%lx reload_pmcs=3D0x%lx\n",=20
+		  " mode used_pmds=3D0x%lx used_pmcs=3D0x%lx reload_pmcs=3D0x%lx\n",=20
 			pmc0, task->pid, (regs ? regs->cr_iip : 0),=20
 			CTX_OVFL_NOBLOCK(ctx) ? "nonblocking" : "blocking",
 			ctx->ctx_used_pmds[0],
-			ctx->ctx_saved_pmcs[0],
+			ctx->ctx_used_pmcs[0],
 			ctx->ctx_reload_pmcs[0]));
=20
 	/*
@@ -2540,7 +2620,7 @@
 		/* skip pmd which did not overflow */
 		if ((mask & 0x1) =3D 0) continue;
=20
-		DBprintk(("PMD[%d] overflowed hw_pmd=3D0x%lx soft_pmd=3D0x%lx\n",=20
+		DBprintk(("pmd[%d] overflowed hw_pmd=3D0x%lx soft_pmd=3D0x%lx\n",=20
 			  i, ia64_get_pmd(i), ctx->ctx_soft_pmds[i].val));
=20
 		/*
@@ -2552,7 +2632,6 @@
 		old_val =3D ctx->ctx_soft_pmds[i].val;
 		ctx->ctx_soft_pmds[i].val =3D 1 + pmu_conf.perf_ovfl_val + pfm_read_soft=
_counter(ctx, i);
=20
-
 		DBprintk(("soft_pmd[%d].val=3D0x%lx old_val=3D0x%lx pmd=3D0x%lx\n",=20
 			  i, ctx->ctx_soft_pmds[i].val, old_val,=20
 			  ia64_get_pmd(i) & pmu_conf.perf_ovfl_val));
@@ -2750,7 +2829,7 @@
 	 */
 	ctx->ctx_fl_frozen =3D 1;
=20
-	DBprintk(("reload pmc0=3D0x%x must_block=3D%ld\n",
+	DBprintk(("return pmc0=3D0x%x must_block=3D%ld\n",
 				ctx->ctx_fl_frozen ? 0x1 : 0x0, t->pfm_ovfl_block_reset));
=20
 	return ctx->ctx_fl_frozen ? 0x1 : 0x0;
@@ -2761,8 +2840,9 @@
 {
 	u64 pmc0;
 	struct task_struct *task;
+	pfm_context_t *ctx;
=20
-	pfm_ovfl_intr_count++;
+	pfm_stats.pfm_ovfl_intr_count++;
=20
 	/*=20
 	 * srlz.d done before arriving here
@@ -2776,21 +2856,51 @@
 	 * assumes : if any PM[0].bit[63-1] is set, then PMC[0].fr =3D 1
 	 */
 	if ((pmc0 & ~0x1UL)!=3D0UL && (task=3DPMU_OWNER())!=3D NULL) {
-
 		/*=20
-		 * assumes, PMC[0].fr =3D 1 at this point=20
-		 *
-		 * XXX: change protype to pass &pmc0
+		 * we assume that pmc0.fr is always set here
 		 */
-		pmc0 =3D pfm_overflow_handler(task, pmc0, regs);
+		ctx =3D task->thread.pfm_context;
=20
-		/* we never explicitely freeze PMU here */
-		if (pmc0 =3D 0) {
-			ia64_set_pmc(0, 0);
-			ia64_srlz_d();
+		/* sanity check */
+		if (!ctx) {
+			printk("perfmon: Spurious overflow interrupt: process %d has no PFM con=
text\n",=20
+				task->pid);
+			return;
 		}
+#ifdef CONFIG_SMP
+		/*
+		 * Because an IPI has higher priority than the PMU overflow interrupt, i=
t is=20
+		 * possible that the handler be interrupted by a request from another CP=
U to fetch=20
+		 * the PMU state of the currently active context. The task may have just=
 been=20
+		 * migrated to another CPU which is trying to restore the context. If th=
ere was
+		 * a pending overflow interrupt when the task left this CPU, it is possi=
ble for
+		 * the handler to get interrupt by the IPI. In which case, we fetch requ=
est
+		 * MUST be postponed until the interrupt handler is done. The ctx_is_busy
+		 * flag indicates such a condition. The other CPU must busy wait until i=
t's cleared.
+		 */
+		atomic_set(&ctx->ctx_is_busy, 1);
+#endif
+
+		/*=20
+		 * assume PMC[0].fr =3D 1 at this point=20
+		 */
+		pmc0 =3D pfm_overflow_handler(task, ctx, pmc0, regs);
+
+		/*
+		 * We always clear the overflow status bits and either unfreeze
+		 * or keep the PMU frozen.
+		 */
+		ia64_set_pmc(0, pmc0);
+		ia64_srlz_d();
+
+#ifdef CONFIG_SMP
+		/*
+		 * announce that we are doing with the context
+		 */
+		atomic_set(&ctx->ctx_is_busy, 0);
+#endif
 	} else {
-		pfm_spurious_ovfl_intr_count++;
+		pfm_stats.pfm_spurious_ovfl_intr_count++;
=20
 		DBprintk(("perfmon: Spurious PMU overflow interrupt on CPU%d: pmc0=3D0x%=
lx owner=3D%p\n",=20
 			smp_processor_id(), pmc0, (void *)PMU_OWNER()));
@@ -2807,27 +2917,33 @@
 #define cpu_is_online(i)        1
 #endif
 	char *p =3D page;
-	u64 pmc0 =3D ia64_get_pmc(0);
 	int i;
=20
-	p +=3D sprintf(p, "perfmon enabled: %s\n", pmu_conf.pfm_is_disabled ? "No=
": "Yes");
-
-	p +=3D sprintf(p, "monitors_pmcs0]=3D0x%lx\n", pmu_conf.monitor_pmcs[0]);
-	p +=3D sprintf(p, "counter_pmcds[0]=3D0x%lx\n", pmu_conf.counter_pmds[0]);
-	p +=3D sprintf(p, "overflow interrupts=3D%lu\n", pfm_ovfl_intr_count);
-	p +=3D sprintf(p, "spurious overflow interrupts=3D%lu\n", pfm_spurious_ov=
fl_intr_count);
-	p +=3D sprintf(p, "recorded samples=3D%lu\n", pfm_recorded_samples_count);
-
-	p +=3D sprintf(p, "CPU%d.pmc[0]=3D%lx\nPerfmon debug: %s\n",=20
-			smp_processor_id(), pmc0, pfm_debug_mode ? "On" : "Off");
+	p +=3D sprintf(p, "enabled          : %s\n", pmu_conf.pfm_is_disabled ? "=
No": "Yes");
+	p +=3D sprintf(p, "debug            : %s\n", pfm_debug_mode > 0 || pfm_sy=
sctl.debug > 0 ? "Yes": "No");
+	p +=3D sprintf(p, "fastctxsw        : %s\n", pfm_sysctl.fastctxsw > 0 ? "=
Yes": "No");
+	p +=3D sprintf(p, "ovfl_mask        : 0x%lx\n", pmu_conf.perf_ovfl_val);
+	p +=3D sprintf(p, "overflow intrs   : %lu\n", pfm_stats.pfm_ovfl_intr_cou=
nt);
+	p +=3D sprintf(p, "spurious intrs   : %lu\n", pfm_stats.pfm_spurious_ovfl=
_intr_count);
+	p +=3D sprintf(p, "recorded samples : %lu\n", pfm_stats.pfm_recorded_samp=
les_count);
+	p +=3D sprintf(p, "restored dbrs    : %lu\n", pfm_stats.pfm_restore_dbrs);
+	p +=3D sprintf(p, "ctxsw reload pmds: %lu\n", pfm_stats.pfm_ctxsw_reload_=
pmds);
+	p +=3D sprintf(p, "ctxsw used pmds  : %lu\n", pfm_stats.pfm_ctxsw_used_pm=
ds);
=20
 #ifdef CONFIG_SMP
-	p +=3D sprintf(p, "CPU%d cpu_data.pfm_syst_wide=3D%d cpu_data.dcr_pp=3D%d=
\n",=20
-			smp_processor_id(), local_cpu_data->pfm_syst_wide, local_cpu_data->pfm_=
dcr_pp);
+	p +=3D sprintf(p, "CPU%d syst_wide    : %d\n"
+			"CPU%d dcr_pp       : %d\n",=20
+			smp_processor_id(),=20
+			local_cpu_data->pfm_syst_wide,=20
+			smp_processor_id(),=20
+			local_cpu_data->pfm_dcr_pp);
 #endif
=20
 	LOCK_PFS();
-	p +=3D sprintf(p, "proc_sessions=3D%lu\nsys_sessions=3D%lu\nsys_use_dbreg=
s=3D%lu\nptrace_use_dbregs=3D%lu\n",=20
+	p +=3D sprintf(p, "proc_sessions    : %lu\n"
+			"sys_sessions     : %lu\n"
+			"sys_use_dbregs   : %lu\n"
+			"ptrace_use_dbregs: %lu\n",=20
 			pfm_sessions.pfs_task_sessions,=20
 			pfm_sessions.pfs_sys_sessions,
 			pfm_sessions.pfs_sys_use_dbregs,
@@ -2837,12 +2953,28 @@
=20
 	for(i=3D0; i < NR_CPUS; i++) {
 		if (cpu_is_online(i)) {
-			p +=3D sprintf(p, "CPU%d.pmu_owner: %-6d\n",
+			p +=3D sprintf(p, "CPU%d owner : %-6d\n",
 					i,=20
 					pmu_owners[i].owner ? pmu_owners[i].owner->pid: -1);
 		}
 	}
=20
+	for(i=3D0; pmd_desc[i].type !=3D PFM_REG_NONE; i++) {
+		p +=3D sprintf(p, "PMD%-2d: %d 0x%lx 0x%lx\n",=20
+				i,
+				pmd_desc[i].type,=20
+				pmd_desc[i].dep_pmd[0],=20
+				pmd_desc[i].dep_pmc[0]);=20
+	}
+
+	for(i=3D0; pmc_desc[i].type !=3D PFM_REG_NONE; i++) {
+		p +=3D sprintf(p, "PMC%-2d: %d 0x%lx 0x%lx\n",=20
+				i,=20
+				pmc_desc[i].type,=20
+				pmc_desc[i].dep_pmd[0],=20
+				pmc_desc[i].dep_pmc[0]);=20
+	}
+
 	return p - page;
 }
=20
@@ -2956,13 +3088,9 @@
 	for (i=3D0; mask; i++, mask>>=3D1) {
 		if (mask & 0x1) t->pmd[i] =3Dia64_get_pmd(i);
 	}
-	/*
-	 * XXX: simplify to pmc0 only
-	 */
-	mask =3D ctx->ctx_saved_pmcs[0];
-	for (i=3D0; mask; i++, mask>>=3D1) {
-		if (mask & 0x1) t->pmc[i] =3D ia64_get_pmc(i);
-	}
+
+	/* save pmc0 */
+	t->pmc[0] =3D ia64_get_pmc(0);
=20
 	/* not owned by this CPU */
 	atomic_set(&ctx->ctx_last_cpu, -1);
@@ -3000,6 +3128,12 @@
 		  PMU_OWNER() ? PMU_OWNER()->pid: -1,
 		  atomic_read(&ctx->ctx_saving_in_progress)));
=20
+	/* must wait until not busy before retrying whole request */
+	if (atomic_read(&ctx->ctx_is_busy)) {
+		arg->retval =3D 2;
+		return;
+	}
+
 	/* must wait if saving was interrupted */
 	if (atomic_read(&ctx->ctx_saving_in_progress)) {
 		arg->retval =3D 1;
@@ -3012,9 +3146,9 @@
 		return;
 	}
=20
-	DBprintk(("saving state for [%d] save_pmcs=3D0x%lx all_pmcs=3D0x%lx used_=
pmds=3D0x%lx\n",=20
+	DBprintk(("saving state for [%d] used_pmcs=3D0x%lx reload_pmcs=3D0x%lx us=
ed_pmds=3D0x%lx\n",=20
 		arg->task->pid,
-		ctx->ctx_saved_pmcs[0],
+		ctx->ctx_used_pmcs[0],
 		ctx->ctx_reload_pmcs[0],
 		ctx->ctx_used_pmds[0]));
=20
@@ -3027,17 +3161,15 @@
=20
 	/*
 	 * XXX needs further optimization.
-	 * Also must take holes into account
 	 */
 	mask =3D ctx->ctx_used_pmds[0];
 	for (i=3D0; mask; i++, mask>>=3D1) {
-		if (mask & 0x1) t->pmd[i] =3Dia64_get_pmd(i);
-	}
-=09
-	mask =3D ctx->ctx_saved_pmcs[0];
-	for (i=3D0; mask; i++, mask>>=3D1) {
-		if (mask & 0x1) t->pmc[i] =3D ia64_get_pmc(i);
+		if (mask & 0x1) t->pmd[i] =3D ia64_get_pmd(i);
 	}
+
+	/* save pmc0 */
+	t->pmc[0] =3D ia64_get_pmc(0);
+
 	/* not owned by this CPU */
 	atomic_set(&ctx->ctx_last_cpu, -1);
=20
@@ -3066,11 +3198,17 @@
 	arg.task   =3D task;
 	arg.retval =3D -1;
=20
+	if (atomic_read(&ctx->ctx_is_busy)) {
+must_wait_busy:
+		while (atomic_read(&ctx->ctx_is_busy));
+	}
+
 	if (atomic_read(&ctx->ctx_saving_in_progress)) {
 		DBprintk(("no IPI, must wait for [%d] to be saved on [%d]\n", task->pid,=
 cpu));
-
+must_wait_saving:
 		/* busy wait */
 		while (atomic_read(&ctx->ctx_saving_in_progress));
+		DBprintk(("done saving for [%d] on [%d]\n", task->pid, cpu));
 		return;
 	}
 	DBprintk(("calling CPU %d from CPU %d\n", cpu, smp_processor_id()));
@@ -3090,11 +3228,8 @@
 	 * This is the case, where we interrupted the saving which started just a=
t the time we sent the
 	 * IPI.
 	 */
-	if (arg.retval =3D 1) {
-		DBprintk(("must wait for [%d] to be saved on [%d]\n", task->pid, cpu));
-		while (atomic_read(&ctx->ctx_saving_in_progress));
-		DBprintk(("done saving for [%d] on [%d]\n", task->pid, cpu));
-	}
+	if (arg.retval =3D 1) goto must_wait_saving;
+	if (arg.retval =3D 2) goto must_wait_busy;
 }
 #endif /* CONFIG_SMP */
=20
@@ -3148,12 +3283,23 @@
 		pfm_fetch_regs(cpu, task, ctx);
 	}
 #endif
-	t   =3D &task->thread;
+	t =3D &task->thread;
=20
 	/*
-	 * XXX: will be replaced by assembly routine
-	 * We clear all unused PMDs to avoid leaking information
+	 * To avoid leaking information to the user level when psr.sp=3D0,
+	 * we must reload ALL implemented pmds (even the ones we don't use).
+	 * In the kernel we only allow PFM_READ_PMDS on registers which
+	 * we initialized or requested (sampling) so there is no risk there.
+	 *
+	 * As an optimization, we will only reload the PMD that we use when=20
+	 * the context is in protected mode, i.e. psr.sp=3D1 because then there
+	 * is no leak possible.
 	 */
+	mask =3D pfm_sysctl.fastctxsw || ctx->ctx_fl_protected ?  ctx->ctx_used_p=
mds[0] : ctx->ctx_reload_pmds[0];
+	for (i=3D0; mask; i++, mask>>=3D1) {
+		if (mask & 0x1) ia64_set_pmd(i, t->pmd[i]);
+	}
+#if 0
 	mask =3D ctx->ctx_used_pmds[0];
 	for (i=3D0; mask; i++, mask>>=3D1) {
 		if (mask & 0x1)=20
@@ -3161,42 +3307,39 @@
 		else
 			ia64_set_pmd(i, 0UL);
 	}
-	/* XXX: will need to clear all unused pmd, for security */
+#endif
=20
 	/*=20
-	 * skip pmc[0] to avoid side-effects,=20
-	 * all PMCs are systematically reloaded, unsued get default value
-	 * to avoid picking up stale configuration
+	 * PMC0 is never set in the mask because it is always restored
+	 * separately. =20
+	 *
+	 * ALL PMCs are systematically reloaded, unused registers
+	 * get their default (PAL reset) values to avoid picking up=20
+	 * stale configuration.
 	 */=09
-	mask =3D ctx->ctx_reload_pmcs[0]>>1;
-	for (i=3D1; mask; i++, mask>>=3D1) {
+	mask =3D ctx->ctx_reload_pmcs[0];
+	for (i=3D0; mask; i++, mask>>=3D1) {
 		if (mask & 0x1) ia64_set_pmc(i, t->pmc[i]);
 	}
=20
 	/*
-	 * restore debug registers when used for range restrictions.
-	 * We must restore the unused registers to avoid picking up
-	 * stale information.
+	 * we restore ALL the debug registers to avoid picking up=20
+	 * stale state.
 	 */
-	mask =3D ctx->ctx_used_ibrs[0];
-	for (i=3D0; mask; i++, mask>>=3D1) {
-		if (mask & 0x1)=20
+	if (ctx->ctx_fl_using_dbreg) {
+		pfm_stats.pfm_restore_dbrs++;
+		for (i=3D0; i < pmu_conf.num_ibrs; i++) {
 			ia64_set_ibr(i, t->ibr[i]);
-		else
-			ia64_set_ibr(i, 0UL);
-	}
-
-	mask =3D ctx->ctx_used_dbrs[0];
-	for (i=3D0; mask; i++, mask>>=3D1) {
-		if (mask & 0x1)=20
+		}
+		ia64_srlz_i();
+		for (i=3D0; i < pmu_conf.num_dbrs; i++) {
 			ia64_set_dbr(i, t->dbr[i]);
-		else
-			ia64_set_dbr(i, 0UL);
+		}
 	}
+	ia64_srlz_d();
=20
 	if (t->pmc[0] & ~0x1) {
-		ia64_srlz_d();
-		pfm_overflow_handler(task, t->pmc[0], NULL);
+		pfm_overflow_handler(task, ctx, t->pmc[0], NULL);
 	}
=20
 	/*
@@ -3249,7 +3392,7 @@
 			 * When restoring context, we must restore ALL pmcs, even the ones=20
 			 * that the task does not use to avoid leaks and possibly corruption
 			 * of the sesion because of configuration conflicts. So here, we=20
-			 * initializaed the table used in the context switch restore routine.
+			 * initialize the entire set used in the context switch restore routine.
 	 		 */
 			t->pmc[i] =3D reset_pmcs[i];
 			DBprintk((" pmc[%d]=3D0x%lx\n", i, reset_pmcs[i]));
@@ -3258,39 +3401,61 @@
 	}
 	/*
 	 * clear reset values for PMD.=20
-	 * XX: good up to 64 PMDS. Suppose that zero is a valid value.
+	 * XXX: good up to 64 PMDS. Suppose that zero is a valid value.
 	 */
 	mask =3D pmu_conf.impl_regs[4];
 	for(i=3D0; mask; mask>>=3D1, i++) {
 		if (mask & 0x1) ia64_set_pmd(i, 0UL);
+		t->pmd[i] =3D 0UL;
 	}
=20
 	/*
-	 * On context switched restore, we must restore ALL pmc even
+	 * On context switched restore, we must restore ALL pmc and ALL pmd even
 	 * when they are not actively used by the task. In UP, the incoming proce=
ss=20
-	 * may otherwise pick up left over PMC state from the previous process.
+	 * may otherwise pick up left over PMC, PMD state from the previous proce=
ss.
 	 * As opposed to PMD, stale PMC can cause harm to the incoming
 	 * process because they may change what is being measured.=20
 	 * Therefore, we must systematically reinstall the entire
 	 * PMC state. In SMP, the same thing is possible on the=20
-	 * same CPU but also on between 2 CPUs.
+	 * same CPU but also on between 2 CPUs.=20
+	 *
+	 * The problem with PMD is information leaking especially
+	 * to user level when psr.sp=3D0
 	 *
 	 * There is unfortunately no easy way to avoid this problem
-	 * on either UP or SMP. This definitively slows down the=20
-	 * pfm_load_regs().=20
+	 * on either UP or SMP. This definitively slows down the
+	 * pfm_load_regs() function.=20
 	 */
 =09
 	 /*
 	  * We must include all the PMC in this mask to make sure we don't
-	  * see any side effect of the stale state, such as opcode matching
+	  * see any side effect of a stale state, such as opcode matching
 	  * or range restrictions, for instance.
+	  *
+	  * We never directly restore PMC0 so we do not include it in the mask.
 	  */
-	ctx->ctx_reload_pmcs[0] =3D pmu_conf.impl_regs[0];
+	ctx->ctx_reload_pmcs[0] =3D pmu_conf.impl_regs[0] & ~0x1;
+	/*
+	 * We must include all the PMD in this mask to avoid picking
+	 * up stale value and leak information, especially directly
+	 * at the user level when psr.sp=3D0
+	 */
+	ctx->ctx_reload_pmds[0] =3D pmu_conf.impl_regs[4];
+
+	/*=20
+	 * Keep track of the pmds we want to sample
+	 * XXX: may be we don't need to save/restore the DEAR/IEAR pmds
+	 * but we do need the BTB for sure. This is because of a hardware
+	 * buffer of 1 only for non-BTB pmds.
+	 *
+	 * We ignore the unimplemented pmds specified by the user
+	 */
+	ctx->ctx_used_pmds[0] =3D ctx->ctx_smpl_regs[0] & pmu_conf.impl_regs[4];
+	ctx->ctx_used_pmcs[0] =3D 1; /* always save/restore PMC[0] */
=20
 	/*
 	 * useful in case of re-enable after disable
 	 */
-	ctx->ctx_used_pmds[0] =3D 0UL;
 	ctx->ctx_used_ibrs[0] =3D 0UL;
 	ctx->ctx_used_dbrs[0] =3D 0UL;
=20
@@ -3472,8 +3637,22 @@
 	 */
 	if (CTX_INHERIT_MODE(ctx) =3D PFM_FL_INHERIT_NONE) {
 		DBprintk(("removing PFM context for [%d]\n", task->pid));
-		task->thread.pfm_context     =3D NULL;
-		task->thread.pfm_ovfl_block_reset  =3D 0;
+		task->thread.pfm_context          =3D NULL;
+		task->thread.pfm_ovfl_block_reset =3D 0;
+		atomic_set(&task->thread.pfm_notifiers_check,0);
+		atomic_set(&task->thread.pfm_owners_check, 0);
+		task->thread.pfm_smpl_buf_list    =3D NULL;
+
+		/*=20
+		 * we must clear psr.up because the new child does
+		 * not have a context and the PM_VALID flag is cleared
+		 * in copy_thread().
+		 *
+		 * we do not clear psr.pp because it is always
+		 * controlled by the system wide logic and we should
+		 * never be here when system wide is running anyway
+		 */
+	 	ia64_psr(regs)->up =3D 0;
=20
 		/* copy_thread() clears IA64_THREAD_PM_VALID */
 		return 0;
@@ -3514,22 +3693,26 @@
 	}
=20
 	/* initialize counters in new context */
-	m =3D pmu_conf.counter_pmds[0] >> PMU_FIRST_COUNTER;
+	m =3D nctx->ctx_used_pmds[0] >> PMU_FIRST_COUNTER;
 	for(i =3D PMU_FIRST_COUNTER ; m ; m>>=3D1, i++) {
-		if (m & 0x1) {
+		if ((m & 0x1) && pmu_conf.pmd_desc[i].type =3D PFM_REG_COUNTING) {
 			nctx->ctx_soft_pmds[i].val =3D nctx->ctx_soft_pmds[i].ival & ~pmu_conf.=
perf_ovfl_val;
 			th->pmd[i]	      	   =3D nctx->ctx_soft_pmds[i].ival & pmu_conf.perf_ov=
fl_val;
 		}
=20
 	}
-	/* clear BTB index register */
+	/*
+	 * clear BTB index register
+	 * XXX: CPU-model specific knowledge!
+	 */
 	th->pmd[16] =3D 0;
=20
-	/* if sampling then increment number of users of buffer */
+	/*=20
+	 * if sampling then increment number of users of buffer
+	 */
 	if (nctx->ctx_psb) {
-
 		/*
-		 * XXX: nopt very pretty!
+		 * XXX: not very pretty!
 		 */
 		LOCK_PSB(nctx->ctx_psb);
 		nctx->ctx_psb->psb_refcnt++;
@@ -3540,7 +3723,7 @@
 		nctx->ctx_smpl_vaddr =3D 0;
 	}
=20
-	nctx->ctx_fl_frozen =3D 0;
+	nctx->ctx_fl_frozen    =3D 0;
 	nctx->ctx_ovfl_regs[0] =3D 0UL;
=20
 	sema_init(&nctx->ctx_restart_sem, 0); /* reset this semaphore to locked */
@@ -3549,7 +3732,7 @@
 	th->pfm_ovfl_block_reset =3D 0;
=20
 	/* link with new task */
-	th->pfm_context    =3D nctx;
+	th->pfm_context =3D nctx;
=20
 	DBprintk(("nctx=3D%p for process [%d]\n", (void *)nctx, task->pid));
=20
@@ -3795,6 +3978,8 @@
 		}
 	}
 	read_unlock(&tasklist_lock);
+
+	atomic_set(&task->thread.pfm_owners_check, 0);
 }
=20
=20
@@ -3852,6 +4037,8 @@
 		}
 	}
 	read_unlock(&tasklist_lock);
+
+	atomic_set(&task->thread.pfm_notifiers_check, 0);
 }
=20
 static struct irqaction perfmon_irqaction =3D {
@@ -3870,6 +4057,12 @@
 		if (i >=3D pmu_conf.num_pmcs) break;
 		if (PMC_IS_IMPL(i)) reset_pmcs[i] =3D ia64_get_pmc(i);
 	}
+#ifdef CONFIG_MCKINLEY
+	/*
+	 * set the 'stupid' enable bit to power the PMU!
+	 */
+	reset_pmcs[4] |=3D 1UL << 23;
+#endif
 }
=20
 /*
@@ -3937,23 +4130,12 @@
 	 */
 	pfm_pmu_snapshot();
=20
-	/*=20
-	 * list the pmc registers used to control monitors=20
-	 * XXX: unfortunately this information is not provided by PAL
-	 *
-	 * We start with the architected minimum and then refine for each CPU mod=
el
-	 */
-	pmu_conf.monitor_pmcs[0] =3D PMM(4)|PMM(5)|PMM(6)|PMM(7);
-
 	/*
-	 * architected counters
+	 * setup the register configuration descriptions for the CPU
 	 */
-	pmu_conf.counter_pmds[0] |=3D PMM(4)|PMM(5)|PMM(6)|PMM(7);
+	pmu_conf.pmc_desc =3D pmc_desc;
+	pmu_conf.pmd_desc =3D pmd_desc;
=20
-#ifdef CONFIG_ITANIUM
-	pmu_conf.monitor_pmcs[0] |=3D PMM(10)|PMM(11)|PMM(12);
-	/* Itanium does not add more counters */
-#endif
 	/* we are all set */
 	pmu_conf.pfm_is_disabled =3D 0;
=20
@@ -3961,6 +4143,8 @@
 	 * for now here for debug purposes
 	 */
 	perfmon_dir =3D create_proc_read_entry ("perfmon", 0, 0, perfmon_read_ent=
ry, NULL);
+
+	pfm_sysctl_header =3D register_sysctl_table(pfm_sysctl_root, 0);
=20
 	spin_lock_init(&pfm_sessions.pfs_lock);
=20
diff -urN linux-davidm/arch/ia64/kernel/perfmon_generic.h lia64-2.4/arch/ia=
64/kernel/perfmon_generic.h
--- linux-davidm/arch/ia64/kernel/perfmon_generic.h	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/arch/ia64/kernel/perfmon_generic.h	Wed Apr 10 11:16:59 2002
@@ -0,0 +1,29 @@
+#define RDEP(x)	(1UL<<(x))
+
+#ifdef CONFIG_ITANIUM
+#error "This file should not be used when CONFIG_ITANIUM is defined"
+#endif
+
+static pfm_reg_desc_t pmc_desc[256]=3D{
+/* pmc0  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc1  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc2  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc3  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc4  */ { PFM_REG_COUNTING, 0, NULL, NULL, {RDEP(4),0UL, 0UL, 0UL}, {0=
UL,0UL, 0UL, 0UL}},
+/* pmc5  */ { PFM_REG_COUNTING, 0, NULL, NULL, {RDEP(5),0UL, 0UL, 0UL}, {0=
UL,0UL, 0UL, 0UL}},
+/* pmc6  */ { PFM_REG_COUNTING, 0, NULL, NULL, {RDEP(6),0UL, 0UL, 0UL}, {0=
UL,0UL, 0UL, 0UL}},
+/* pmc7  */ { PFM_REG_COUNTING, 0, NULL, NULL, {RDEP(7),0UL, 0UL, 0UL}, {0=
UL,0UL, 0UL, 0UL}},
+	    { PFM_REG_NONE, 0, NULL, NULL, {0,}, {0,}}, /* end marker */
+};
+
+static pfm_reg_desc_t pmd_desc[256]=3D{
+/* pmd0  */ { PFM_REG_NOTIMPL, 0, NULL, NULL, {0,}, {0,}},
+/* pmd1  */ { PFM_REG_NOTIMPL, 0, NULL, NULL, {0,}, {0,}},
+/* pmd2  */ { PFM_REG_NOTIMPL, 0, NULL, NULL, {0,}, {0,}},
+/* pmd3  */ { PFM_REG_NOTIMPL, 0, NULL, NULL, {0,}, {0,}},
+/* pmd4  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
4),0UL, 0UL, 0UL}},
+/* pmd5  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
5),0UL, 0UL, 0UL}},
+/* pmd6  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
6),0UL, 0UL, 0UL}},
+/* pmd7  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
7),0UL, 0UL, 0UL}},
+	    { PFM_REG_NONE, 0, NULL, NULL, {0,}, {0,}}, /* end marker */
+};
diff -urN linux-davidm/arch/ia64/kernel/perfmon_itanium.h lia64-2.4/arch/ia=
64/kernel/perfmon_itanium.h
--- linux-davidm/arch/ia64/kernel/perfmon_itanium.h	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/arch/ia64/kernel/perfmon_itanium.h	Wed Apr 10 11:16:59 2002
@@ -0,0 +1,65 @@
+#define RDEP(x)	(1UL<<(x))
+
+#ifndef CONFIG_ITANIUM
+#error "This file is only valid when CONFIG_ITANIUM is defined"
+#endif
+
+static int pfm_ita_pmc_check(struct task_struct *task, unsigned int cnum, =
unsigned long *val);
+
+static pfm_reg_desc_t pmc_desc[256]=3D{
+/* pmc0  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc1  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc2  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc3  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc4  */ { PFM_REG_COUNTING, 0, NULL, NULL, {RDEP(4),0UL, 0UL, 0UL}, {0=
UL,0UL, 0UL, 0UL}},
+/* pmc5  */ { PFM_REG_COUNTING, 0, NULL, NULL, {RDEP(5),0UL, 0UL, 0UL}, {0=
UL,0UL, 0UL, 0UL}},
+/* pmc6  */ { PFM_REG_COUNTING, 0, NULL, NULL, {RDEP(6),0UL, 0UL, 0UL}, {0=
UL,0UL, 0UL, 0UL}},
+/* pmc7  */ { PFM_REG_COUNTING, 0, NULL, NULL, {RDEP(7),0UL, 0UL, 0UL}, {0=
UL,0UL, 0UL, 0UL}},
+/* pmc8  */ { PFM_REG_CONFIG, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL=
, 0UL, 0UL}},
+/* pmc9  */ { PFM_REG_CONFIG, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL=
, 0UL, 0UL}},
+/* pmc10 */ { PFM_REG_MONITOR, 0, NULL, NULL, {RDEP(0)|RDEP(1),0UL, 0UL, 0=
UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc11 */ { PFM_REG_MONITOR, 0, NULL, pfm_ita_pmc_check, {RDEP(2)|RDEP(3=
)|RDEP(17),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc12 */ { PFM_REG_MONITOR, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RD=
EP(11)|RDEP(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {0UL,0U=
L, 0UL, 0UL}},
+/* pmc13 */ { PFM_REG_CONFIG, 0, NULL, pfm_ita_pmc_check, {0UL,0UL, 0UL, 0=
UL}, {0UL,0UL, 0UL, 0UL}},
+	    { PFM_REG_NONE, 0, NULL, NULL, {0,}, {0,}}, /* end marker */
+};
+
+static pfm_reg_desc_t pmd_desc[256]=3D{
+/* pmd0  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(1),0UL, 0UL, 0UL}, {RDE=
P(10),0UL, 0UL, 0UL}},
+/* pmd1  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(0),0UL, 0UL, 0UL}, {RDE=
P(10),0UL, 0UL, 0UL}},
+/* pmd2  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(3)|RDEP(17),0UL, 0UL, 0=
UL}, {RDEP(11),0UL, 0UL, 0UL}},
+/* pmd3  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(2)|RDEP(17),0UL, 0UL, 0=
UL}, {RDEP(11),0UL, 0UL, 0UL}},
+/* pmd4  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
4),0UL, 0UL, 0UL}},
+/* pmd5  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
5),0UL, 0UL, 0UL}},
+/* pmd6  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
6),0UL, 0UL, 0UL}},
+/* pmd7  */ { PFM_REG_COUNTING, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(=
7),0UL, 0UL, 0UL}},
+/* pmd8  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(9)|RDEP(10)|RDEP(11)|RD=
EP(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0=
UL, 0UL}},
+/* pmd9  */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(10)|RDEP(11)|RD=
EP(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0=
UL, 0UL}},
+/* pmd10 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(11)|RDE=
P(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd11 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd12 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(11)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd13 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(11)|RDEP(12)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd14 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(11)|RDEP(12)|RDEP(13)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd15 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(11)|RDEP(12)|RDEP(13)|RDEP(14)|RDEP(16),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd16 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDE=
P(11)|RDEP(12)|RDEP(13)|RDEP(14)|RDEP(15),0UL, 0UL, 0UL}, {RDEP(12),0UL, 0U=
L, 0UL}},
+/* pmd17 */ { PFM_REG_BUFFER, 0, NULL, NULL, {RDEP(2)|RDEP(3),0UL, 0UL, 0U=
L}, {RDEP(11),0UL, 0UL, 0UL}},
+	    { PFM_REG_NONE, 0, NULL, NULL, {0,}, {0,}}, /* end marker */
+};
+
+static int
+pfm_ita_pmc_check(struct task_struct *task, unsigned int cnum, unsigned lo=
ng *val)
+{
+	pfm_context_t *ctx =3D task->thread.pfm_context;
+
+	if (cnum =3D 13 && (*val & 0x1) && ctx->ctx_fl_using_dbreg =3D 0) {
+		DBprintk(("cannot configure range restriction without initializing the i=
nstruction debug registers first\n"));
+		return -EINVAL;
+	}
+
+	if (cnum =3D 11 && ((*val >> 28)& 0x1) =3D 0 && ctx->ctx_fl_using_dbreg =
=3D 0) {
+		DBprintk(("cannot configure range restriction without initializing the d=
ata debug registers first pmc11=3D0x%lx\n", *val));
+		return -EINVAL;
+	}
+	return 0;
+}
+
diff -urN linux-davidm/arch/ia64/kernel/setup.c lia64-2.4/arch/ia64/kernel/=
setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Wed Apr 10 13:24:25 2002
+++ lia64-2.4/arch/ia64/kernel/setup.c	Wed Apr 10 11:31:13 2002
@@ -28,8 +28,8 @@
 #include <linux/string.h>
 #include <linux/threads.h>
 #include <linux/console.h>
+#include <linux/acpi.h>
=20
-#include <asm/acpi-ext.h>
 #include <asm/ia32.h>
 #include <asm/page.h>
 #include <asm/machvec.h>
@@ -65,6 +65,8 @@
=20
 unsigned long ia64_iobase;	/* virtual address for I/O accesses */
=20
+unsigned char aux_device_present =3D 0xaa;        /* XXX remove this when =
legacy I/O is gone */
+
 #define COMMAND_LINE_SIZE	512
=20
 char saved_command_line[COMMAND_LINE_SIZE]; /* used in proc filesystem */
@@ -283,6 +285,7 @@
 setup_arch (char **cmdline_p)
 {
 	extern unsigned long ia64_iobase;
+	unsigned long phys_iobase;
=20
 	unw_init();
=20
@@ -315,24 +318,23 @@
 #endif
=20
 	/*
-	 *  Set `iobase' to the appropriate address in region 6
-	 *    (uncached access range)
+	 *  Set `iobase' to the appropriate address in region 6 (uncached access =
range).
 	 *
-	 *  The EFI memory map is the "prefered" location to get the I/O port
-	 *  space base, rather the relying on AR.KR0. This should become more
-	 *  clear in future SAL specs. We'll fall back to getting it out of
-	 *  AR.KR0 if no appropriate entry is found in the memory map.
+	 *  The EFI memory map is the "preferred" location to get the I/O port sp=
ace base,
+	 *  rather the relying on AR.KR0. This should become more clear in future=
 SAL
+	 *  specs. We'll fall back to getting it out of AR.KR0 if no appropriate =
entry is
+	 *  found in the memory map.
 	 */
-	ia64_iobase =3D efi_get_iobase();
-	if (ia64_iobase)
+	phys_iobase =3D efi_get_iobase();
+	if (phys_iobase)
 		/* set AR.KR0 since this is all we use it for anyway */
-		ia64_set_kr(IA64_KR_IO_BASE, ia64_iobase);
+		ia64_set_kr(IA64_KR_IO_BASE, phys_iobase);
 	else {
-		ia64_iobase =3D ia64_get_kr(IA64_KR_IO_BASE);
+		phys_iobase =3D ia64_get_kr(IA64_KR_IO_BASE);
 		printk("No I/O port range found in EFI memory map, falling back to AR.KR=
0\n");
 		printk("I/O port base =3D 0x%lx\n", ia64_iobase);
 	}
-	ia64_iobase =3D __IA64_UNCACHED_OFFSET | (ia64_iobase & ~PAGE_OFFSET);
+	ia64_iobase =3D (unsigned long) ioremap(phys_iobase, 0);
=20
 #ifdef CONFIG_SMP
 	cpu_physical_id(0) =3D hard_smp_processor_id();
@@ -340,19 +342,22 @@
=20
 	cpu_init();	/* initialize the bootstrap CPU */
=20
-	if (efi.acpi20) {
-		/* Parse the ACPI 2.0 tables */
-		acpi20_parse(efi.acpi20);
-	} else if (efi.acpi) {
-		/* Parse the ACPI tables */
-		acpi_parse(efi.acpi);
-	}
-
+#ifdef CONFIG_ACPI_BOOT
+	acpi_boot_init(*cmdline_p);
+#endif
 #ifdef CONFIG_VT
+# if defined(CONFIG_DUMMY_CONSOLE)
+ 	conswitchp =3D &dummy_con;
+# endif
 # if defined(CONFIG_VGA_CONSOLE)
-	conswitchp =3D &vga_con;
-# elif defined(CONFIG_DUMMY_CONSOLE)
-	conswitchp =3D &dummy_con;
+	/*
+	 * Non-legacy systems may route legacy VGA MMIO range to system
+	 * memory.  vga_con probes the MMIO hole, so memory looks like
+	 * a VGA device to it.  The EFI memory map can tell us if it's
+	 * memory so we can avoid this problem.
+	 */
+	if (efi_mem_type(0xA0000) !=3D EFI_CONVENTIONAL_MEMORY)
+		conswitchp =3D &vga_con;
 # endif
 #endif
=20
diff -urN linux-davidm/arch/ia64/kernel/smpboot.c lia64-2.4/arch/ia64/kerne=
l/smpboot.c
--- linux-davidm/arch/ia64/kernel/smpboot.c	Wed Apr 10 13:24:25 2002
+++ lia64-2.4/arch/ia64/kernel/smpboot.c	Mon Apr  1 16:05:53 2002
@@ -68,6 +68,7 @@
=20
 extern void __init calibrate_delay(void);
 extern void start_ap(void);
+extern unsigned long ia64_iobase;
=20
 int cpucount;
=20
@@ -343,6 +344,11 @@
 	 * Get our bogomips.
 	 */
 	ia64_init_itm();
+
+	/*
+	 * Set I/O port base per CPU
+	 */
+	ia64_set_kr(IA64_KR_IO_BASE, __pa(ia64_iobase));
=20
 #ifdef CONFIG_IA64_MCA
 	ia64_mca_cmc_vector_setup();	/* Setup vector on AP & enable */
diff -urN linux-davidm/arch/ia64/kernel/sys_ia64.c lia64-2.4/arch/ia64/kern=
el/sys_ia64.c
--- linux-davidm/arch/ia64/kernel/sys_ia64.c	Mon Nov 26 11:18:24 2001
+++ lia64-2.4/arch/ia64/kernel/sys_ia64.c	Fri Mar  1 15:18:04 2002
@@ -2,8 +2,8 @@
  * This file contains various system calls that have different calling
  * conventions on different platforms.
  *
- * Copyright (C) 1999-2000 Hewlett-Packard Co
- * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2000, 2002 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #include <linux/config.h>
 #include <linux/errno.h>
@@ -201,15 +201,13 @@
 	if (len =3D 0)
 		goto out;
=20
-	/* don't permit mappings into unmapped space or the virtual page table of=
 a region: */
+	/*
+	 * Don't permit mappings into unmapped space, the virtual page table of a=
 region,
+	 * or across a region boundary.  Note: RGN_MAP_LIMIT is equal to 2^n-PAGE=
_SIZE
+	 * (for some integer n <=3D 61) and len > 0.
+	 */
 	roff =3D rgn_offset(addr);
-	if ((len | roff | (roff + len)) >=3D RGN_MAP_LIMIT) {
-		addr =3D -EINVAL;
-		goto out;
-	}
-
-	/* don't permit mappings that would cross a region boundary: */
-	if (rgn_index(addr) !=3D rgn_index(addr + len)) {
+	if ((len > RGN_MAP_LIMIT) || (roff > (RGN_MAP_LIMIT - len))) {
 		addr =3D -EINVAL;
 		goto out;
 	}
diff -urN linux-davidm/arch/ia64/kernel/unaligned.c lia64-2.4/arch/ia64/ker=
nel/unaligned.c
--- linux-davidm/arch/ia64/kernel/unaligned.c	Wed Apr 10 13:24:25 2002
+++ lia64-2.4/arch/ia64/kernel/unaligned.c	Wed Mar 13 22:47:14 2002
@@ -1304,11 +1304,7 @@
 	 * handler into reading an arbitrary kernel addresses...
 	 */
 	if (!user_mode(regs)) {
-#ifdef GAS_HAS_LOCAL_TAGS
-		fix =3D search_exception_table(regs->cr_iip + ia64_psr(regs)->ri);
-#else
-		fix =3D search_exception_table(regs->cr_iip);
-#endif
+		fix =3D SEARCH_EXCEPTION_TABLE(regs);
 	}
 	if (user_mode(regs) || fix.cont) {
 		if ((current->thread.flags & IA64_THREAD_UAC_SIGBUS) !=3D 0)
diff -urN linux-davidm/arch/ia64/kernel/unwind_i.h lia64-2.4/arch/ia64/kern=
el/unwind_i.h
--- linux-davidm/arch/ia64/kernel/unwind_i.h	Wed Apr 10 13:24:25 2002
+++ lia64-2.4/arch/ia64/kernel/unwind_i.h	Mon Apr  1 17:34:40 2002
@@ -103,7 +103,7 @@
 	unsigned int in_body : 1;	/* are we inside a body (as opposed to a prolog=
ue)? */
 	unsigned long flags;		/* see UNW_FLAG_* in unwind.h */
=20
-	u8 *imask;			/* imask of of spill_mask record or NULL */
+	u8 *imask;			/* imask of spill_mask record or NULL */
 	unsigned long pr_val;		/* predicate values */
 	unsigned long pr_mask;		/* predicate mask */
 	long spill_offset;		/* psp-relative offset for spill base */
diff -urN linux-davidm/arch/ia64/lib/Makefile lia64-2.4/arch/ia64/lib/Makef=
ile
--- linux-davidm/arch/ia64/lib/Makefile	Tue Jul 31 10:30:08 2001
+++ lia64-2.4/arch/ia64/lib/Makefile	Thu Mar 28 21:01:41 2002
@@ -11,10 +11,13 @@
=20
 obj-y :=3D __divsi3.o __udivsi3.o __modsi3.o __umodsi3.o					\
 	__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o					\
-	checksum.o clear_page.o csum_partial_copy.o copy_page.o				\
+	checksum.o clear_page.o csum_partial_copy.o					\
 	copy_user.o clear_user.o strncpy_from_user.o strlen_user.o strnlen_user.o=
	\
 	flush.o io.o do_csum.o								\
 	memcpy.o memset.o strlen.o swiotlb.o
+
+obj-$(CONFIG_ITANIUM) +=3D copy_page.o
+obj-$(CONFIG_MCKINLEY) +=3D copy_page_mck.o
=20
 IGNORE_FLAGS_OBJS =3D	__divsi3.o __udivsi3.o __modsi3.o __umodsi3.o \
 			__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o
diff -urN linux-davidm/arch/ia64/lib/clear_page.S lia64-2.4/arch/ia64/lib/c=
lear_page.S
--- linux-davidm/arch/ia64/lib/clear_page.S	Mon Nov 26 11:18:24 2001
+++ lia64-2.4/arch/ia64/lib/clear_page.S	Mon Mar 11 18:42:21 2002
@@ -1,51 +1,77 @@
 /*
- *
- * Optimized function to clear a page of memory.
- *
- * Inputs:
- *	in0:	address of page
- *
- * Output:
- * 	none
- *
- * Copyright (C) 1999-2001 Hewlett-Packard Co
- * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
- * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2002 Hewlett-Packard Co
+ *	Stephane Eranian <eranian@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2002 Ken Chen <kenneth.w.chen@intel.com>
  *
  * 1/06/01 davidm	Tuned for Itanium.
+ * 2/12/02 kchen	Tuned for both Itanium and McKinley
+ * 3/08/02 davidm	Some more tweaking
  */
+#include <linux/config.h>
+
 #include <asm/asmmacro.h>
 #include <asm/page.h>
=20
+#ifdef CONFIG_ITANIUM
+# define L3_LINE_SIZE	64	// Itanium L3 line size
+# define PREFETCH_LINES	9	// magic number
+#else
+# define L3_LINE_SIZE	128	// McKinley L3 line size
+# define PREFETCH_LINES	12	// magic number
+#endif
+
 #define saved_lc	r2
-#define dst0		in0
+#define dst_fetch	r3
 #define dst1		r8
 #define dst2		r9
 #define dst3		r10
-#define dst_fetch	r11
+#define dst4		r11
+
+#define dst_last	r31
=20
 GLOBAL_ENTRY(clear_page)
 	.prologue
 	.regstk 1,0,0,0
-	mov r16 =3D PAGE_SIZE/64-1	// -1 =3D repeat/until
-	;;
+	mov r16 =3D PAGE_SIZE/L3_LINE_SIZE-1	// main loop count, -1=3Drepeat/until
 	.save ar.lc, saved_lc
 	mov saved_lc =3D ar.lc
+
 	.body
-	mov ar.lc =3D r16
-	adds dst1 =3D 16, dst0
-	adds dst2 =3D 32, dst0
-	adds dst3 =3D 48, dst0
-	adds dst_fetch =3D 512, dst0
+	mov ar.lc =3D (PREFETCH_LINES - 1)
+	mov dst_fetch =3D in0
+	adds dst1 =3D 16, in0
+	adds dst2 =3D 32, in0
+	;;
+.fetch:	stf.spill.nta [dst_fetch] =3D f0, L3_LINE_SIZE
+	adds dst3 =3D 48, in0		// executing this multiple times is harmless
+	br.cloop.sptk.few .fetch
+	;;
+	addl dst_last =3D (PAGE_SIZE - PREFETCH_LINES*L3_LINE_SIZE), dst_fetch
+	mov ar.lc =3D r16			// one L3 line per iteration
+	adds dst4 =3D 64, in0
+	;;
+#ifdef CONFIG_ITANIUM
+	// Optimized for Itanium
+1:	stf.spill.nta [dst1] =3D f0, 64
+	stf.spill.nta [dst2] =3D f0, 64
+	cmp.lt p8,p0=3Ddst_fetch, dst_last
+	;;
+#else
+	// Optimized for McKinley
+1:	stf.spill.nta [dst1] =3D f0, 64
+	stf.spill.nta [dst2] =3D f0, 64
+	stf.spill.nta [dst3] =3D f0, 64
+	stf.spill.nta [dst4] =3D f0, 128
+	cmp.lt p8,p0=3Ddst_fetch, dst_last
 	;;
-1:	stf.spill.nta [dst0] =3D f0, 64
 	stf.spill.nta [dst1] =3D f0, 64
 	stf.spill.nta [dst2] =3D f0, 64
+#endif
 	stf.spill.nta [dst3] =3D f0, 64
-
-	lfetch [dst_fetch], 64
-	br.cloop.dptk.few 1b
+(p8)	stf.spill.nta [dst_fetch] =3D f0, L3_LINE_SIZE
+	br.cloop.sptk.few 1b
 	;;
-	mov ar.lc =3D r2		// restore lc
+	mov ar.lc =3D saved_lc		// restore lc
 	br.ret.sptk.many rp
 END(clear_page)
diff -urN linux-davidm/arch/ia64/lib/copy_page_mck.S lia64-2.4/arch/ia64/li=
b/copy_page_mck.S
--- linux-davidm/arch/ia64/lib/copy_page_mck.S	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/arch/ia64/lib/copy_page_mck.S	Tue Apr  2 19:12:16 2002
@@ -0,0 +1,185 @@
+/*
+ * McKinley-optimized version of copy_page().
+ *
+ * Copyright (C) 2002 Hewlett-Packard Co
+ *	David Mosberger <davidm@hpl.hp.com>
+ *
+ * Inputs:
+ *	in0:	address of target page
+ *	in1:	address of source page
+ * Output:
+ *	no return value
+ *
+ * General idea:
+ *	- use regular loads and stores to prefetch data to avoid consuming M-sl=
ot just for
+ *	  lfetches =3D> good for in-cache performance
+ *	- avoid l2 bank-conflicts by not storing into the same 16-byte bank wit=
hin a single
+ *	  cycle
+ *
+ * Principle of operation:
+ *	First, note that L1 has a line-size of 64 bytes and L2 a line-size of 1=
28 bytes.
+ *	To avoid secondary misses in L2, we prefetch both source and destinatio=
n with a line-size
+ *	of 128 bytes.  When both of these lines are in the L2 and the first hal=
f of the
+ *	source line is in L1, we start copying the remaining words.  The second=
 half of the
+ *	source line is prefetched in an earlier iteration, so that by the time =
we start
+ *	accessing it, it's also present in the L1.
+ *
+ *	We use a software-pipelined loop to control the overall operation.  The=
 pipeline
+ *	has 2*PREFETCH_DIST+K stages.  The first PREFETCH_DIST stages are used =
for prefetching
+ *	source cache-lines.  The second PREFETCH_DIST stages are used for prefe=
tching destination
+ *	cache-lines, the last K stages are used to copy the cache-line words no=
t copied by
+ *	the prefetches.  The four relevant points in the pipelined are called A=
, B, C, D:
+ *	p[A] is TRUE if a source-line should be prefetched, p[B] is TRUE if a d=
estination-line
+ *	should be prefetched, p[C] is TRUE if the second half of an L2 line sho=
uld be brought
+ *	into L1D and p[D] is TRUE if a cacheline needs to be copied.
+ *
+ *	This all sounds very complicated, but thanks to the modulo-scheduled lo=
op support,
+ *	the resulting code is very regular and quite easy to follow (once you g=
et the idea).
+ *
+ *	As a secondary optimization, the first 2*PREFETCH_DIST iterations are i=
mplemented
+ *	as the separate .prefetch_loop.  Logically, this loop performs exactly =
like the
+ *	main-loop (.line_copy), but has all known-to-be-predicated-off instruct=
ions removed,
+ *	so that each loop iteration is faster (again, good for cached case).
+ *
+ *	When reading the code, it helps to keep the following picture in mind:
+ *
+ *	       word 0 word 1
+ *            +------+------+---
+ *	      |	v[x] | 	t1  | ^
+ *	      |	t2   |	t3  | |
+ *	      |	t4   |	t5  | |
+ *	      |	t6   |	t7  | | 128 bytes
+ *     	      |	n[y] | 	t9  | |	(L2 cache line)
+ *	      |	t10  | 	t11 | |
+ *	      |	t12  | 	t13 | |
+ *	      |	t14  | 	t15 | v
+ *	      +------+------+---
+ *
+ *	Here, v[x] is copied by the (memory) prefetch.  n[y] is loaded at p[C]
+ *	to fetch the second-half of the L2 cache line into L1, and the tX words=
 are copied in
+ *	an order that avoids bank conflicts.
+ */
+#include <asm/asmmacro.h>
+#include <asm/page.h>
+
+#define PREFETCH_DIST	8		// McKinley sustains 16 outstanding L2 misses (8 =
ld, 8 st)
+
+#define src0		r2
+#define src1		r3
+#define dst0		r9
+#define dst1		r10
+#define src_pre_mem	r11
+#define dst_pre_mem	r14
+#define src_pre_l2	r15
+#define dst_pre_l2	r16
+#define t1		r17
+#define t2		r18
+#define t3		r19
+#define t4		r20
+#define t5		t1	// alias!
+#define t6		t2	// alias!
+#define t7		t3	// alias!
+#define t9		t5	// alias!
+#define t10		t4	// alias!
+#define t11		t7	// alias!
+#define t12		t6	// alias!
+#define t14		t10	// alias!
+#define t13		r21
+#define t15		r22
+
+#define saved_lc	r23
+#define saved_pr	r24
+
+#define	A	0
+#define B	(PREFETCH_DIST)
+#define C	(B + PREFETCH_DIST)
+#define D	(C + 3)
+#define N	(D + 1)
+#define Nrot	((N + 7) & ~7)
+
+GLOBAL_ENTRY(copy_page)
+	.prologue
+	alloc r8 =3D ar.pfs, 2, Nrot-2, 0, Nrot
+
+	.rotr v[2*PREFETCH_DIST], n[D-C+1]
+	.rotp p[N]
+
+	.save ar.lc, saved_lc
+	mov saved_lc =3D ar.lc
+	.save pr, saved_pr
+	mov saved_pr =3D pr
+	.body
+
+	mov src_pre_mem =3D in1
+	mov pr.rot =3D 0x10000
+	mov ar.ec =3D 1				// special unrolled loop
+
+	mov dst_pre_mem =3D in0
+	mov ar.lc =3D 2*PREFETCH_DIST - 1
+
+	add src_pre_l2 =3D 8*8, in1
+	add dst_pre_l2 =3D 8*8, in0
+	add src0 =3D 8, in1			// first t1 src
+	add src1 =3D 3*8, in1			// first t3 src
+	add dst0 =3D 8, in0			// first t1 dst
+	add dst1 =3D 3*8, in0			// first t3 dst
+	nop.m 0
+	nop.m 0
+	nop.i 0
+	;;
+	// same as .line_copy loop, but with all predicated-off instructions remo=
ved:
+.prefetch_loop:
+(p[A])	ld8 v[A] =3D [src_pre_mem], 128		// M0
+(p[B])	st8 [dst_pre_mem] =3D v[B], 128		// M2
+	br.ctop.sptk .prefetch_loop
+	;;
+	cmp.eq p16, p0 =3D r0, r0			// reset p16 to 1 (br.ctop cleared it to zero)
+	mov ar.lc =3D (PAGE_SIZE/128) - (2*PREFETCH_DIST) - 1
+	mov ar.ec =3D N				// # of stages in pipeline
+	;;
+.line_copy:
+(p[D])	ld8 t2 =3D [src0], 3*8			// M0
+(p[D])	ld8 t4 =3D [src1], 3*8			// M1
+(p[B])	st8 [dst_pre_mem] =3D v[B], 128		// M2 prefetch dst from memory
+(p[D])	st8 [dst_pre_l2] =3D n[D-C], 128		// M3 prefetch dst from L2
+	;;
+(p[A])	ld8 v[A] =3D [src_pre_mem], 128		// M0 prefetch src from memory
+(p[C])	ld8 n[0] =3D [src_pre_l2], 128		// M1 prefetch src from L2
+(p[D])	st8 [dst0] =3D  t1, 8			// M2
+(p[D])	st8 [dst1] =3D  t3, 8			// M3
+	;;
+(p[D])	ld8  t5 =3D [src0], 8
+(p[D])	ld8  t7 =3D [src1], 3*8
+(p[D])	st8 [dst0] =3D  t2, 3*8
+(p[D])	st8 [dst1] =3D  t4, 3*8
+	;;
+(p[D])	ld8  t6 =3D [src0], 3*8
+(p[D])	ld8 t10 =3D [src1], 8
+(p[D])	st8 [dst0] =3D  t5, 8
+(p[D])	st8 [dst1] =3D  t7, 3*8
+	;;
+(p[D])	ld8  t9 =3D [src0], 3*8
+(p[D])	ld8 t11 =3D [src1], 3*8
+(p[D])	st8 [dst0] =3D  t6, 3*8
+(p[D])	st8 [dst1] =3D t10, 8
+	;;
+(p[D])	ld8 t12 =3D [src0], 8
+(p[D])	ld8 t14 =3D [src1], 8
+(p[D])	st8 [dst0] =3D  t9, 3*8
+(p[D])	st8 [dst1] =3D t11, 3*8
+	;;
+(p[D])	ld8 t13 =3D [src0], 4*8
+(p[D])	ld8 t15 =3D [src1], 4*8
+(p[D])	st8 [dst0] =3D t12, 8
+(p[D])	st8 [dst1] =3D t14, 8
+	;;
+(p[D-1])ld8  t1 =3D [src0], 8
+(p[D-1])ld8  t3 =3D [src1], 8
+(p[D])	st8 [dst0] =3D t13, 4*8
+(p[D])	st8 [dst1] =3D t15, 4*8
+	br.ctop.sptk .line_copy
+	;;
+	mov ar.lc =3D saved_lc
+	mov pr =3D saved_pr, -1
+	br.ret.sptk.many rp
+END(copy_page)
diff -urN linux-davidm/arch/ia64/lib/memset.S lia64-2.4/arch/ia64/lib/memse=
t.S
--- linux-davidm/arch/ia64/lib/memset.S	Mon Nov 26 11:18:24 2001
+++ lia64-2.4/arch/ia64/lib/memset.S	Tue Apr  9 12:32:52 2002
@@ -30,7 +30,19 @@
 #define saved_lc	r20
 #define tmp		r21
=20
-GLOBAL_ENTRY(memset)
+GLOBAL_ENTRY(__bzero)
+	.prologue
+	.save ar.pfs, saved_pfs
+	alloc saved_pfs=3Dar.pfs,0,0,3,0
+	mov out2=3Dout1
+	mov out1=3D0
+	/* FALL THROUGH (explicit NOPs so that next alloc is preceded by stop bit=
!) */
+	nop.m 0
+	nop.f 0
+	nop.i 0
+	;;
+END(__bzero)
+GLOBAL_ENTRY(__memset_generic)
 	.prologue
 	.save ar.pfs, saved_pfs
  	alloc saved_pfs=3Dar.pfs,3,0,0,0	// cnt is sink here
@@ -105,4 +117,7 @@
 	;;
 (p6)	st1 [buf]=3Dval		// only 1 byte left
 	br.ret.sptk.many rp
-END(memset)
+END(__memset_generic)
+
+	.global memset
+memset =3D __memset_generic		// alias needed for gcc
diff -urN linux-davidm/arch/ia64/lib/swiotlb.c lia64-2.4/arch/ia64/lib/swio=
tlb.c
--- linux-davidm/arch/ia64/lib/swiotlb.c	Wed Apr 10 13:24:25 2002
+++ lia64-2.4/arch/ia64/lib/swiotlb.c	Thu Apr  4 16:07:48 2002
@@ -277,8 +277,11 @@
 	int gfp =3D GFP_ATOMIC;
 	void *ret;
=20
-	if (!hwdev || hwdev->dma_mask <=3D 0xffffffff)
-		gfp |=3D GFP_DMA; /* XXX fix me: should change this to GFP_32BIT or ZONE=
_32BIT */
+	/*
+	 * Alloc_consistent() is defined to return memory < 4GB, no matter what t=
he DMA
+	 * mask says.
+	 */
+	gfp |=3D GFP_DMA;	/* XXX fix me: should change this to GFP_32BIT or ZONE_=
32BIT */
 	ret =3D (void *)__get_free_pages(gfp, get_order(size));
 	if (!ret)
 		return NULL;
diff -urN linux-davidm/arch/ia64/mm/fault.c lia64-2.4/arch/ia64/mm/fault.c
--- linux-davidm/arch/ia64/mm/fault.c	Wed Apr 10 13:24:25 2002
+++ lia64-2.4/arch/ia64/mm/fault.c	Wed Mar 13 22:47:14 2002
@@ -49,7 +49,6 @@
 	int signal =3D SIGSEGV, code =3D SEGV_MAPERR;
 	struct vm_area_struct *vma, *prev_vma;
 	struct mm_struct *mm =3D current->mm;
-	struct exception_fixup fix;
 	struct siginfo si;
 	unsigned long mask;
=20
@@ -167,15 +166,8 @@
 		return;
 	}
=20
-#ifdef GAS_HAS_LOCAL_TAGS
-	fix =3D search_exception_table(regs->cr_iip + ia64_psr(regs)->ri);
-#else
-	fix =3D search_exception_table(regs->cr_iip);
-#endif
-	if (fix.cont) {
-		handle_exception(regs, fix);
+	if (done_with_exception(regs))
 		return;
-	}
=20
 	/*
 	 * Oops. The kernel tried to access some bad page. We'll have to terminat=
e things
diff -urN linux-davidm/arch/ia64/mm/tlb.c lia64-2.4/arch/ia64/mm/tlb.c
--- linux-davidm/arch/ia64/mm/tlb.c	Mon Nov 26 11:18:25 2001
+++ lia64-2.4/arch/ia64/mm/tlb.c	Fri Apr  5 16:44:44 2002
@@ -79,7 +79,7 @@
 	flush_tlb_all();
 }
=20
-static inline void
+void
 ia64_global_tlb_purge (unsigned long start, unsigned long end, unsigned lo=
ng nbits)
 {
 	static spinlock_t ptcg_lock =3D SPIN_LOCK_UNLOCKED;
diff -urN linux-davidm/drivers/char/agp/agp.h lia64-2.4/drivers/char/agp/ag=
p.h
--- linux-davidm/drivers/char/agp/agp.h	Wed Apr 10 13:24:31 2002
+++ lia64-2.4/drivers/char/agp/agp.h	Mon Mar 11 18:52:15 2002
@@ -99,7 +99,6 @@
 	int needs_scratch_page;
 	int aperture_size_idx;
 	int num_aperture_sizes;
-	int num_of_masks;
 	int capndx;
 	int cant_use_aperture;
=20
diff -urN linux-davidm/drivers/char/agp/agpgart_be.c lia64-2.4/drivers/char=
/agp/agpgart_be.c
--- linux-davidm/drivers/char/agp/agpgart_be.c	Wed Apr 10 13:24:32 2002
+++ lia64-2.4/drivers/char/agp/agpgart_be.c	Mon Mar 11 18:52:16 2002
@@ -212,8 +212,6 @@
 	if(agp_bridge.cant_use_aperture =3D 0) {
 		if (curr->page_count !=3D 0) {
 			for (i =3D 0; i < curr->page_count; i++) {
-				curr->memory[i] =3D agp_bridge.unmask_memory(
-					                     curr->memory[i]);
 				agp_bridge.agp_destroy_page((unsigned long)
 						 phys_to_virt(curr->memory[i]));
 			}
@@ -302,10 +300,7 @@
 				agp_free_memory(new);
 				return NULL;
 			}
-			new->memory[i] -			    agp_bridge.mask_memory(
-					  virt_to_phys((void *) new->memory[i]),
-							  type);
+			new->memory[i] =3D virt_to_phys((void *) new->memory[i]);
 			new->page_count++;
 		}
 	} else {
@@ -338,7 +333,7 @@
 #else
 			paddr =3D pte_val(*pte) & PAGE_MASK;
 #endif
-			new->memory[i] =3D agp_bridge.mask_memory(paddr, type);
+			new->memory[i] =3D paddr;
 		}
=20
 		new->page_count =3D page_count;
@@ -384,9 +379,6 @@
=20
 void agp_copy_info(agp_kern_info * info)
 {
-	unsigned long page_mask =3D 0;
-	int i;
-
 	memset(info, 0, sizeof(agp_kern_info));
 	if (agp_bridge.type =3D NOT_SUPPORTED) {
 		info->chipset =3D agp_bridge.type;
@@ -402,11 +394,7 @@
 	info->max_memory =3D agp_bridge.max_memory_agp;
 	info->current_memory =3D atomic_read(&agp_bridge.current_memory_agp);
 	info->cant_use_aperture =3D agp_bridge.cant_use_aperture;
-
-	for(i =3D 0; i < agp_bridge.num_of_masks; i++)
-		page_mask |=3D agp_bridge.mask_memory(page_mask, i);
-
-	info->page_mask =3D ~page_mask;
+	info->page_mask =3D ~0UL;
 }
=20
 /* End - Routine to copy over information structure */
@@ -835,7 +823,8 @@
 		mem->is_flushed =3D TRUE;
 	}
 	for (i =3D 0, j =3D pg_start; i < mem->page_count; i++, j++) {
-		agp_bridge.gatt_table[j] =3D mem->memory[i];
+		agp_bridge.gatt_table[j] +			agp_bridge.mask_memory(mem->memory[i], mem-=
>type);
 	}
=20
 	agp_bridge.tlb_flush(mem);
@@ -1077,7 +1066,8 @@
    	CACHE_FLUSH();
 	for (i =3D 0, j =3D pg_start; i < mem->page_count; i++, j++) {
 		OUTREG32(intel_i810_private.registers,
-			 I810_PTE_BASE + (j * 4), mem->memory[i]);
+			 I810_PTE_BASE + (j * 4),
+			 agp_bridge.mask_memory(mem->memory[i], mem->type));
 	}
 	CACHE_FLUSH();
=20
@@ -1143,10 +1133,7 @@
 			agp_free_memory(new);
 			return NULL;
 		}
-		new->memory[0] -		    agp_bridge.mask_memory(
-				   virt_to_phys((void *) new->memory[0]),
-						  type);
+		new->memory[0] =3D virt_to_phys((void *) new->memory[0]);
 		new->page_count =3D 1;
 	   	new->num_scratch_pages =3D 1;
 	   	new->type =3D AGP_PHYS_MEMORY;
@@ -1180,7 +1167,6 @@
 	intel_i810_private.i810_dev =3D i810_dev;
=20
 	agp_bridge.masks =3D intel_i810_masks;
-	agp_bridge.num_of_masks =3D 2;
 	agp_bridge.aperture_sizes =3D (void *) intel_i810_sizes;
 	agp_bridge.size_type =3D FIXED_APER_SIZE;
 	agp_bridge.num_aperture_sizes =3D 2;
@@ -1383,7 +1369,8 @@
 	CACHE_FLUSH();
=20
 	for (i =3D 0, j =3D pg_start; i < mem->page_count; i++, j++)
-		OUTREG32(intel_i830_private.registers,I810_PTE_BASE + (j * 4),mem->memor=
y[i]);
+		OUTREG32(intel_i830_private.registers,I810_PTE_BASE + (j * 4),
+			 agp_bridge.mask_memory(mem->memory[i], mem->type));
=20
 	CACHE_FLUSH();
=20
@@ -1444,7 +1431,7 @@
 			return(NULL);
 		}
=20
-		nw->memory[0] =3D agp_bridge.mask_memory(virt_to_phys((void *) nw->memor=
y[0]),type);
+		nw->memory[0] =3D virt_to_phys((void *) nw->memory[0]);
 		nw->page_count =3D 1;
 		nw->num_scratch_pages =3D 1;
 		nw->type =3D AGP_PHYS_MEMORY;
@@ -1460,7 +1447,6 @@
 	intel_i830_private.i830_dev =3D i830_dev;
=20
 	agp_bridge.masks =3D intel_i810_masks;
-	agp_bridge.num_of_masks =3D 3;
 	agp_bridge.aperture_sizes =3D (void *) intel_i830_sizes;
 	agp_bridge.size_type =3D FIXED_APER_SIZE;
 	agp_bridge.num_aperture_sizes =3D 2;
@@ -1506,6 +1492,7 @@
=20
 /* 460 supports multiple GART page sizes, so GART pageshift is dynamic */ =

 static u8 intel_i460_pageshift =3D 12;
+static u32 intel_i460_pagesize;
=20
 /* Keep track of which is larger, chipset or kernel page size. */
 static u32 intel_i460_cpk =3D 1;
@@ -1533,6 +1520,7 @@
 	/* Determine the GART page size */
 	pci_read_config_byte(agp_bridge.dev, INTEL_I460_GXBCTL, &temp);
 	intel_i460_pageshift =3D (temp & I460_4M_PS) ? 22 : 12;
+	intel_i460_pagesize =3D 1UL << intel_i460_pageshift;
=20
 	values =3D A_SIZE_8(agp_bridge.aperture_sizes);
=20
@@ -1747,7 +1735,7 @@
 {
 	int i, j, k, num_entries;
 	void *temp;
-	unsigned int hold;
+	unsigned long paddr;
 	unsigned int read_back;
=20
 	/*=20
@@ -1779,10 +1767,11 @@
=20
 	for (i =3D 0, j =3D pg_start; i < mem->page_count; i++) {
=20
-		hold =3D (unsigned int) (mem->memory[i]);
+		paddr =3D mem->memory[i];
=20
-		for (k =3D 0; k < I460_CPAGES_PER_KPAGE; k++, j++, hold++)
-			agp_bridge.gatt_table[j] =3D hold;
+		for (k =3D 0; k < I460_CPAGES_PER_KPAGE; k++, j++, paddr +=3D intel_i460=
_pagesize)
+			agp_bridge.gatt_table[j] =3D (unsigned int)
+			    agp_bridge.mask_memory(paddr, mem->type);
 	}
=20
 	/*=20
@@ -1896,6 +1885,7 @@
 	int num_entries;=09
 	void *temp;
 	unsigned int read_back;
+	unsigned long paddr;
=20
 	temp =3D agp_bridge.current_size;
 	num_entries =3D A_SIZE_8(temp)->num_entries;
@@ -1944,18 +1934,17 @@
=20
 	for(pg =3D start_pg, i =3D 0; pg <=3D end_pg; pg++)
 	{
+		paddr =3D agp_bridge.unmask_memory(agp_bridge.gatt_table[pg]);
 		for(idx =3D ((pg =3D start_pg) ? start_offset : 0);
 		    idx < ((pg =3D end_pg) ? (end_offset + 1)
 				       : I460_KPAGES_PER_CPAGE);
 		    idx++, i++)
 		{
-			i460_pg_detail[pg][idx] =3D agp_bridge.gatt_table[pg] +=20
-						      ((idx * PAGE_SIZE) >> 12);
+			mem->memory[i] =3D paddr + (idx * PAGE_SIZE);
+			i460_pg_detail[pg][idx] +			    agp_bridge.mask_memory(mem->memory[i], =
mem->type);
+			   =20
 			i460_pg_count[pg]++;
-
-			/* Finally we fill in mem->memory... */
-			mem->memory[i] =3D ((unsigned long) (0xffffff &=20
-						i460_pg_detail[pg][idx])) << 12;
 		}
 	}
=20
@@ -1969,7 +1958,7 @@
 	int num_entries;
 	void *temp;
 	unsigned int read_back;
-	unsigned long addr;
+	unsigned long paddr;
=20
 	temp =3D agp_bridge.current_size;
 	num_entries =3D A_SIZE_8(temp)->num_entries;
@@ -1996,13 +1985,11 @@
=20
 		/* Free GART pages if they are unused */
 		if(i460_pg_count[pg] =3D 0) {
-			addr =3D (0xffffffUL & (unsigned long)=20
-					     (agp_bridge.gatt_table[pg])) << 12;
-
-			agp_bridge.gatt_table[pg] =3D 0;
+			paddr =3D agp_bridge.unmask_memory(agp_bridge.gatt_table[pg]);
+			agp_bridge.gatt_table[pg] =3D agp_bridge.scratch_page;
 			read_back =3D agp_bridge.gatt_table[pg];
=20
-			intel_i460_free_large_page(pg, addr);
+			intel_i460_free_large_page(pg, paddr);
 		}
 	}
 	=09
@@ -2091,7 +2078,6 @@
 {
=20
         agp_bridge.masks =3D intel_i460_masks;
-        agp_bridge.num_of_masks =3D 1;
         agp_bridge.aperture_sizes =3D (void *) intel_i460_sizes;
         agp_bridge.size_type =3D U8_APER_SIZE;
         agp_bridge.num_aperture_sizes =3D 3;
@@ -2513,7 +2499,6 @@
 static int __init intel_generic_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks =3D intel_generic_masks;
-	agp_bridge.num_of_masks =3D 1;
 	agp_bridge.aperture_sizes =3D (void *) intel_generic_sizes;
 	agp_bridge.size_type =3D U16_APER_SIZE;
 	agp_bridge.num_aperture_sizes =3D 7;
@@ -2545,11 +2530,9 @@
 }
=20
=20
-
 static int __init intel_820_setup (struct pci_dev *pdev)
 {
        agp_bridge.masks =3D intel_generic_masks;
-       agp_bridge.num_of_masks =3D 1;
        agp_bridge.aperture_sizes =3D (void *) intel_8xx_sizes;
        agp_bridge.size_type =3D U8_APER_SIZE;
        agp_bridge.num_aperture_sizes =3D 7;
@@ -2582,7 +2565,6 @@
 static int __init intel_830mp_setup (struct pci_dev *pdev)
 {
        agp_bridge.masks =3D intel_generic_masks;
-       agp_bridge.num_of_masks =3D 1;
        agp_bridge.aperture_sizes =3D (void *) intel_830mp_sizes;
        agp_bridge.size_type =3D U8_APER_SIZE;
        agp_bridge.num_aperture_sizes =3D 4;
@@ -2614,7 +2596,6 @@
 static int __init intel_840_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks =3D intel_generic_masks;
-	agp_bridge.num_of_masks =3D 1;
 	agp_bridge.aperture_sizes =3D (void *) intel_8xx_sizes;
 	agp_bridge.size_type =3D U8_APER_SIZE;
 	agp_bridge.num_aperture_sizes =3D 7;
@@ -2647,7 +2628,6 @@
 static int __init intel_845_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks =3D intel_generic_masks;
-	agp_bridge.num_of_masks =3D 1;
 	agp_bridge.aperture_sizes =3D (void *) intel_8xx_sizes;
 	agp_bridge.size_type =3D U8_APER_SIZE;
 	agp_bridge.num_aperture_sizes =3D 7;
@@ -2681,7 +2661,6 @@
 static int __init intel_850_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks =3D intel_generic_masks;
-	agp_bridge.num_of_masks =3D 1;
 	agp_bridge.aperture_sizes =3D (void *) intel_8xx_sizes;
 	agp_bridge.size_type =3D U8_APER_SIZE;
 	agp_bridge.num_aperture_sizes =3D 7;
@@ -2715,7 +2694,6 @@
 static int __init intel_860_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks =3D intel_generic_masks;
-	agp_bridge.num_of_masks =3D 1;
 	agp_bridge.aperture_sizes =3D (void *) intel_8xx_sizes;
 	agp_bridge.size_type =3D U8_APER_SIZE;
 	agp_bridge.num_aperture_sizes =3D 7;
@@ -2835,7 +2813,6 @@
 static int __init via_generic_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks =3D via_generic_masks;
-	agp_bridge.num_of_masks =3D 1;
 	agp_bridge.aperture_sizes =3D (void *) via_generic_sizes;
 	agp_bridge.size_type =3D U8_APER_SIZE;
 	agp_bridge.num_aperture_sizes =3D 7;
@@ -2950,7 +2927,6 @@
 static int __init sis_generic_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks =3D sis_generic_masks;
-	agp_bridge.num_of_masks =3D 1;
 	agp_bridge.aperture_sizes =3D (void *) sis_generic_sizes;
 	agp_bridge.size_type =3D U8_APER_SIZE;
 	agp_bridge.num_aperture_sizes =3D 7;
@@ -3283,7 +3259,8 @@
 	for (i =3D 0, j =3D pg_start; i < mem->page_count; i++, j++) {
 		addr =3D (j * PAGE_SIZE) + agp_bridge.gart_bus_addr;
 		cur_gatt =3D GET_GATT(addr);
-		cur_gatt[GET_GATT_OFF(addr)] =3D mem->memory[i];
+		cur_gatt[GET_GATT_OFF(addr)] +			agp_bridge.mask_memory(mem->memory[i], =
mem->type);
 	}
 	agp_bridge.tlb_flush(mem);
 	return 0;
@@ -3329,7 +3306,6 @@
 static int __init amd_irongate_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks =3D amd_irongate_masks;
-	agp_bridge.num_of_masks =3D 1;
 	agp_bridge.aperture_sizes =3D (void *) amd_irongate_sizes;
 	agp_bridge.size_type =3D LVL2_APER_SIZE;
 	agp_bridge.num_aperture_sizes =3D 7;
@@ -3578,7 +3554,6 @@
 static int __init ali_generic_setup (struct pci_dev *pdev)
 {
 	agp_bridge.masks =3D ali_generic_masks;
-	agp_bridge.num_of_masks =3D 1;
 	agp_bridge.aperture_sizes =3D (void *) ali_generic_sizes;
 	agp_bridge.size_type =3D U32_APER_SIZE;
 	agp_bridge.num_aperture_sizes =3D 7;
@@ -3987,7 +3962,8 @@
 	for (i =3D 0, j =3D pg_start; i < mem->page_count; i++, j++) {
 		addr =3D (j * PAGE_SIZE) + agp_bridge.gart_bus_addr;
 		cur_gatt =3D SVRWRKS_GET_GATT(addr);
-		cur_gatt[GET_GATT_OFF(addr)] =3D mem->memory[i];
+		cur_gatt[GET_GATT_OFF(addr)] +			agp_bridge.mask_memory(mem->memory[i], =
mem->type);
 	}
 	agp_bridge.tlb_flush(mem);
 	return 0;
@@ -4177,7 +4153,6 @@
 	serverworks_private.svrwrks_dev =3D pdev;
=20
 	agp_bridge.masks =3D serverworks_masks;
-	agp_bridge.num_of_masks =3D 1;
 	agp_bridge.aperture_sizes =3D (void *) serverworks_sizes;
 	agp_bridge.size_type =3D LVL2_APER_SIZE;
 	agp_bridge.num_aperture_sizes =3D 7;
diff -urN linux-davidm/drivers/char/drm/drm_vm.h lia64-2.4/drivers/char/drm=
/drm_vm.h
--- linux-davidm/drivers/char/drm/drm_vm.h	Wed Apr 10 13:24:32 2002
+++ lia64-2.4/drivers/char/drm/drm_vm.h	Wed Apr 10 12:48:42 2002
@@ -89,7 +89,7 @@
=20
 	if (map && map->type =3D _DRM_AGP) {
 		unsigned long offset =3D address - vma->vm_start;
-		unsigned long baddr =3D VM_OFFSET(vma) + offset, paddr;
+		unsigned long baddr =3D VM_OFFSET(vma) + offset;
 		struct drm_agp_mem *agpmem;
 		struct page *page;
=20
@@ -115,19 +115,8 @@
                  * Get the page, inc the use count, and return it
                  */
 		offset =3D (baddr - agpmem->bound) >> PAGE_SHIFT;
-
-		/*
-		 * This is bad.  What we really want to do here is unmask
-		 * the GART table entry held in the agp_memory structure.
-		 * There isn't a convenient way to call agp_bridge.unmask_
-		 * memory from here, so hard code it for now.
-		 */
-#if defined(__ia64__)
-		paddr =3D (agpmem->memory->memory[offset] & 0xffffff) << 12;
-#else
-		paddr =3D agpmem->memory->memory[offset] & dev->agp->page_mask;
-#endif
-		page =3D virt_to_page(__va(paddr));
+		agpmem->memory->memory[offset] &=3D dev->agp->page_mask;
+		page =3D virt_to_page(__va(agpmem->memory->memory[offset]));
 		get_page(page);
=20
 		DRM_DEBUG("baddr =3D 0x%lx page =3D 0x%p, offset =3D 0x%lx\n",
diff -urN linux-davidm/drivers/char/pc_keyb.c lia64-2.4/drivers/char/pc_key=
b.c
--- linux-davidm/drivers/char/pc_keyb.c	Mon Nov 26 11:18:32 2001
+++ lia64-2.4/drivers/char/pc_keyb.c	Fri Mar 29 17:16:46 2002
@@ -802,6 +802,17 @@
 {
 	int status;
=20
+#ifdef CONFIG_IA64
+	/*
+	 * This is not really IA-64 specific.  Probably ought to be done on all p=
latforms
+	 * that are (potentially) legacy-free.
+	 */
+	if (kbd_read_status() =3D 0xff && kbd_read_input() =3D 0xff) {
+		kbd_exists =3D 0;
+		return "No keyboard controller preset";
+	}
+#endif
+
 	/*
 	 * Test the keyboard interface.
 	 * This seems to be the only way to get it going.
@@ -904,6 +915,10 @@
 		char *msg =3D initialize_kbd();
 		if (msg)
 			printk(KERN_WARNING "initialize_kbd: %s\n", msg);
+#ifdef CONFIG_IA64
+		if (!kbd_exists)
+			return;
+#endif
 	}
=20
 #if defined CONFIG_PSMOUSE
diff -urN linux-davidm/drivers/pci/pci.ids lia64-2.4/drivers/pci/pci.ids
--- linux-davidm/drivers/pci/pci.ids	Tue Feb 26 11:04:31 2002
+++ lia64-2.4/drivers/pci/pci.ids	Fri Apr  5 16:44:44 2002
@@ -917,6 +917,9 @@
 	121a  NetServer SMIC Controller
 	121b  NetServer Legacy COM Port Decoder
 	121c  NetServer PCI COM Port Decoder
+	1229  zx1 System Bus Adapter
+	122a  zx1 I/O Controller
+	122e  zx1 Local Bus Adapter
 	2910  E2910A
 	2925  E2925A
 103e  Solliday Engineering
diff -urN linux-davidm/fs/devfs/base.c lia64-2.4/fs/devfs/base.c
--- linux-davidm/fs/devfs/base.c	Wed Apr 10 13:24:38 2002
+++ lia64-2.4/fs/devfs/base.c	Thu Mar 28 16:11:08 2002
@@ -2194,27 +2194,6 @@
     return master->slave;
 }   /*  End Function devfs_get_unregister_slave  */
=20
-#ifdef CONFIG_DEVFS_GUID
-/**
- *	devfs_unregister_slave - remove the slave that is unregistered when @ma=
ster is unregistered.
- *      Destroys the connection established by devfs_auto_unregister.
- *
- *	@master: The master devfs entry.
- */
-
-void devfs_unregister_slave (devfs_handle_t master)
-{
-	devfs_handle_t slave;
-
-	if (master =3D NULL) return;
-
-	slave =3D master->slave;
-	if (slave) {
-		master->slave =3D NULL;
-		unregister (slave);
-	};
-}
-#endif /* CONFIG_DEVFS_GUID */
=20
 /**
  *	devfs_get_name - Get the name for a device entry in its parent director=
y.
@@ -2396,9 +2375,6 @@
 EXPORT_SYMBOL(devfs_register_blkdev);
 EXPORT_SYMBOL(devfs_unregister_chrdev);
 EXPORT_SYMBOL(devfs_unregister_blkdev);
-#ifdef CONFIG_DEVFS_GUID
-EXPORT_SYMBOL(devfs_unregister_slave);
-#endif
=20
=20
 /**
diff -urN linux-davidm/fs/partitions/Config.in lia64-2.4/fs/partitions/Conf=
ig.in
--- linux-davidm/fs/partitions/Config.in	Wed Apr 10 13:24:38 2002
+++ lia64-2.4/fs/partitions/Config.in	Thu Mar 28 16:11:08 2002
@@ -24,8 +24,6 @@
       bool '    Minix subpartition support' CONFIG_MINIX_SUBPARTITION
       bool '    Solaris (x86) partition table support' CONFIG_SOLARIS_X86_=
PARTITION
       bool '    Unixware slices support' CONFIG_UNIXWARE_DISKLABEL
-      bool '    EFI GUID Partition support' CONFIG_EFI_PARTITION
-      dep_bool '    /dev/guid support (EXPERIMENTAL)' CONFIG_DEVFS_GUID $C=
ONFIG_DEVFS_FS $CONFIG_EFI_PARTITION
    fi
    dep_bool '  Windows Logical Disk Manager (Dynamic Disk) support' CONFIG=
_LDM_PARTITION $CONFIG_EXPERIMENTAL
    if [ "$CONFIG_LDM_PARTITION" =3D "y" ]; then
@@ -34,6 +32,7 @@
    bool '  SGI partition support' CONFIG_SGI_PARTITION
    bool '  Ultrix partition table support' CONFIG_ULTRIX_PARTITION
    bool '  Sun partition tables support' CONFIG_SUN_PARTITION
+   bool '  EFI GUID Partition support' CONFIG_EFI_PARTITION
 else
    if [ "$ARCH" =3D "alpha" ]; then
       define_bool CONFIG_OSF_PARTITION y
diff -urN linux-davidm/fs/partitions/check.c lia64-2.4/fs/partitions/check.c
--- linux-davidm/fs/partitions/check.c	Wed Apr 10 13:24:38 2002
+++ lia64-2.4/fs/partitions/check.c	Thu Mar 28 16:11:08 2002
@@ -79,20 +79,6 @@
 	NULL
 };
=20
-#ifdef CONFIG_DEVFS_GUID
-static devfs_handle_t guid_top_handle;
-
-#define GUID_UNPARSED_LEN 36
-static void
-uuid_unparse_1(efi_guid_t *guid, char *out)
-{
-	sprintf(out, "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
-		guid->data1, guid->data2, guid->data3,
- 		guid->data4[0], guid->data4[1], guid->data4[2], guid->data4[3],
-		guid->data4[4], guid->data4[5], guid->data4[6], guid->data4[7]);
-}
-#endif
-
 /*
  *	This is ucking fugly but its probably the best thing for 2.4.x
  *	Take it as a clear reminder than we should put the device name
@@ -285,103 +271,6 @@
 	devfs_register_partitions (hd, i, hd->sizes ? 0 : 1);
 }
=20
-#ifdef CONFIG_DEVFS_GUID
-/*
-  devfs_register_guid: create a /dev/guid entry for a disk or partition
-                       if it has a GUID.
-
-  The /dev/guid entry will be a symlink to the "real" devfs device.
-  It is marked as "slave" of the real device,
-  to be automatically unregistered by devfs if that device is unregistered.
-
-  If the partition already had a /dev/guid entry, delete (unregister) it.
-  (If the disk was repartitioned, it's likely the old GUID entry will be w=
rong).
-
-  dev, minor:  Device for which an entry is to be created.
-
-  Prerequisites: dev->part[minor].guid must be either NULL or point
-                 to a valid kmalloc'ed GUID.
-*/
-
-static void devfs_register_guid (struct gendisk *dev, int minor)
-{
-	efi_guid_t *guid =3D dev->part[minor].guid;
-	devfs_handle_t guid_handle, slave,
-		real_master =3D dev->part[minor].de;
-	devfs_handle_t master =3D real_master;
-	char guid_link[GUID_UNPARSED_LEN + 1];
-	char dirname[128];
-	int pos, st;
-
-	if (!guid_top_handle)
-		guid_top_handle =3D devfs_mk_dir (NULL, "guid", NULL);
-
-	if (!guid || !master) return;
-
-	do {
-		slave =3D devfs_get_unregister_slave (master);
-		if (slave) {
-			if (slave =3D master || slave =3D real_master) {
-				printk (KERN_WARNING
-					"devfs_register_guid: infinite slave loop!\n");
-				return;
-			} else if (devfs_get_parent (slave) =3D guid_top_handle) {
-				printk (KERN_INFO
-					"devfs_register_guid: unregistering %s\n",
-					devfs_get_name (slave, NULL));
-				devfs_unregister_slave (master);
-				slave =3D NULL;
-			} else
-				master =3D slave;
-		};
-	} while (slave);
-
-	uuid_unparse_1 (guid, guid_link);
-	pos =3D devfs_generate_path (real_master, dirname + 3,
-				   sizeof (dirname) - 3);
-	if (pos < 0) {
-		printk (KERN_WARNING
-			"devfs_register_guid: error generating path: %d\n",
-			pos);
-		return;
-	};
-
-	strncpy (dirname + pos, "../", 3);
-
-	st =3D devfs_mk_symlink (guid_top_handle, guid_link,
-			       DEVFS_FL_DEFAULT,
-			       dirname + pos, &guid_handle, NULL);
-
-	if (st < 0) {
-		printk ("Error %d creating symlink\n", st);
-	} else {
-		devfs_auto_unregister (master, guid_handle);
-	};
-};
-
-/*
-  free_disk_guids: kfree all guid data structures alloced for
-  the disk device specified by (dev, minor) and all its partitions.
-
-  This function does not remove symlinks in /dev/guid.
-*/
-static void free_disk_guids (struct gendisk *dev, int minor)
-{
-	int i;
-	efi_guid_t *guid;
-
-	for (i =3D 0; i < dev->max_p; i++) {
-		guid =3D dev->part[minor + i].guid;
-		if (!guid) continue;
-		kfree (guid);
-		dev->part[minor + i].guid =3D NULL;
-	};
-}
-#else
-#define devfs_register_guid(dev, minor)
-#define free_disk_guids(dev, minor)
-#endif /* CONFIG_DEVFS_GUID */
-
 #ifdef CONFIG_DEVFS_FS
 static void devfs_register_partition (struct gendisk *dev, int minor, int =
part)
 {
@@ -390,11 +279,7 @@
 	unsigned int devfs_flags =3D DEVFS_FL_DEFAULT;
 	char devname[16];
=20
-	/* Even if the devfs handle is still up-to-date,
-	   the GUID entry probably isn't */
-	if (dev->part[minor + part].de)
-		goto do_guid;
-
+	if (dev->part[minor + part].de) return;
 	dir =3D devfs_get_parent (dev->part[minor].de);
 	if (!dir) return;
 	if ( dev->flags && (dev->flags[devnum] & GENHD_FL_REMOVABLE) )
@@ -405,9 +290,6 @@
 			    dev->major, minor + part,
 			    S_IFBLK | S_IRUSR | S_IWUSR,
 			    dev->fops, NULL);
- do_guid:
-	devfs_register_guid (dev, minor + part);
-	return;
 }
=20
 static struct unique_numspace disc_numspace =3D UNIQUE_NUMBERSPACE_INITIAL=
ISER;
@@ -421,9 +303,7 @@
 	char dirname[64], symlink[16];
 	static devfs_handle_t devfs_handle;
=20
-	if (dev->part[minor].de)
-		goto do_guid;
-
+	if (dev->part[minor].de) return;
 	if ( dev->flags && (dev->flags[devnum] & GENHD_FL_REMOVABLE) )
 		devfs_flags |=3D DEVFS_FL_REMOVABLE;
 	if (dev->de_arr) {
@@ -451,10 +331,6 @@
 	devfs_auto_unregister (dev->part[minor].de, slave);
 	if (!dev->de_arr)
 		devfs_auto_unregister (slave, dir);
-
- do_guid:
-	devfs_register_guid (dev, minor);
-	return;
 }
 #endif  /*  CONFIG_DEVFS_FS  */
=20
@@ -479,7 +355,6 @@
 		dev->part[minor].de =3D NULL;
 		devfs_dealloc_unique_number (&disc_numspace,
 					     dev->part[minor].number);
-		free_disk_guids (dev, minor);
 	}
 #endif  /*  CONFIG_DEVFS_FS  */
 }
@@ -497,21 +372,8 @@
 void register_disk(struct gendisk *gdev, kdev_t dev, unsigned minors,
 	struct block_device_operations *ops, long size)
 {
-	int i;
-
 	if (!gdev)
 		return;
-
-#ifdef CONFIG_DEVFS_GUID
-	/* Initialize all guid fields to NULL (=3D^ not kmalloc'ed).
-	   It is assumed that drivers call register_disk after
-	   allocating the gen_hd structure, and call grok_partitions
-	   directly for a revalidate event, as those drives I've inspected
-	   (among which hd and sd) do. */
-	for (i =3D 0; i < gdev->max_p; i++)
-		gdev->part[MINOR(dev) + i].guid =3D NULL;
-#endif
-
 	grok_partitions(gdev, MINOR(dev)>>gdev->minor_shift, minors, size);
 }
=20
@@ -530,12 +392,6 @@
 		devfs_register_partitions (dev, first_minor, 0);
 	if (!size || minors =3D 1)
 		return;
-
-	/* In case this is a revalidation, free GUID memory.
-	   On the first call for this device,
-	   register_disk has set all entries to NULL,
-	   and nothing will happen. */
-	free_disk_guids (dev, first_minor);
=20
 	if (dev->sizes) {
 		dev->sizes[first_minor] =3D size >> (BLOCK_SIZE_BITS - 9);
diff -urN linux-davidm/fs/partitions/efi.c lia64-2.4/fs/partitions/efi.c
--- linux-davidm/fs/partitions/efi.c	Wed Apr 10 13:24:38 2002
+++ lia64-2.4/fs/partitions/efi.c	Thu Mar 28 16:11:09 2002
@@ -3,13 +3,7 @@
  * Per Intel EFI Specification v1.02
  * http://developer.intel.com/technology/efi/efi.htm
  * efi.[ch] by Matt Domsch <Matt_Domsch@dell.com>
- *   Copyright 2000,2001 Dell Computer Corporation
- *
- * Note, the EFI Specification, v1.02, has a reference to
- * Dr. Dobbs Journal, May 1994 (actually it's in May 1992)
- * but that isn't the CRC function being used by EFI.  Intel's
- * EFI Sample Implementation shows that they use the same function
- * as was COPYRIGHT (C) 1986 Gary S. Brown.
+ *   Copyright 2000,2001,2002 Dell Computer Corporation
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License as published by
@@ -29,6 +23,36 @@
  * TODO:
  *
  * Changelog:
+ * Wed  Mar 27 2002 Matt Domsch <Matt_Domsch@dell.com>
+ * - Ported to 2.5.7-pre1 and 2.4.18
+ * - Applied patch to avoid fault in alternate header handling
+ * - cleaned up find_valid_gpt
+ * - On-disk structure and copy in memory is *always* LE now -=20
+ *   swab fields as needed
+ * - remove print_gpt_header()
+ * - only use first max_p partition entries, to keep the kernel minor numb=
er
+ *   and partition numbers tied.
+ * - 2.4.18 patch needs own crc32() function - there's no official
+ *   lib/crc32.c in 2.4.x.
+ *
+ * Mon  Feb 04 2002 Matt Domsch <Matt_Domsch@dell.com>
+ * - Removed __PRIPTR_PREFIX - not being used
+ *
+ * Mon  Jan 14 2002 Matt Domsch <Matt_Domsch@dell.com>
+ * - Ported to 2.5.2-pre11 + library crc32 patch Linus applied
+ *
+ * Thu Dec 6 2001 Matt Domsch <Matt_Domsch@dell.com>
+ * - Added compare_gpts().
+ * - moved le_efi_guid_to_cpus() back into this file.  GPT is the only
+ *   thing that keeps EFI GUIDs on disk.
+ * - Changed gpt structure names and members to be simpler and more Linux-=
like.
+ *=20
+ * Wed Oct 17 2001 Matt Domsch <Matt_Domsch@dell.com>
+ * - Removed CONFIG_DEVFS_VOLUMES_UUID code entirely per Martin Wilck
+ *
+ * Wed Oct 10 2001 Matt Domsch <Matt_Domsch@dell.com>
+ * - Changed function comments to DocBook style per Andreas Dilger suggest=
ion.
+ *
  * Mon Oct 08 2001 Matt Domsch <Matt_Domsch@dell.com>
  * - Change read_lba() to use the page cache per Al Viro's work.
  * - print u64s properly on all architectures
@@ -46,8 +70,8 @@
  * - Added kernel command line option 'gpt' to override valid PMBR test.
  *
  * Wed Jun  6 2001 Martin Wilck <Martin.Wilck@Fujitsu-Siemens.com>
- * - added devfs GUID support (/dev/guid) for mounting file systems
- *   by the partition GUID.=20
+ * - added devfs volume UUID support (/dev/volumes/uuids) for
+ *   mounting file systems by the partition GUID.=20
  *
  * Tue Dec  5 2000 Matt Domsch <Matt_Domsch@dell.com>
  * - Moved crc32() to linux/lib, added efi_crc32().
@@ -74,7 +98,6 @@
 #include <linux/blkpg.h>
 #include <linux/slab.h>
 #include <linux/smp_lock.h>
-#include <linux/crc32.h>
 #include <linux/init.h>
 #include <asm/system.h>
 #include <asm/byteorder.h>
@@ -86,11 +109,13 @@
 #endif
=20
 /* Handle printing of 64-bit values */
-#if BITS_PER_LONG =3D 64
-#define PU64X "%lx"
-#else
-#define PU64X "%llx"
-#endif
+/* Borrowed from /usr/include/inttypes.h */
+# if BITS_PER_LONG =3D 64=20
+#  define __PRI64_PREFIX	"l"
+# else
+#  define __PRI64_PREFIX	"ll"
+# endif
+# define PRIx64		__PRI64_PREFIX "x"
=20
=20
 #undef EFI_DEBUG
@@ -104,92 +129,119 @@
  * the test for invalid PMBR.  Not __initdata because reloading
  * the partition tables happens after init too.
  */
-static int forcegpt;
-static int __init force_gpt(char *str)
+static int force_gpt;
+static int __init
+force_gpt_fn(char *str)
 {
-	forcegpt =3D 1;
+	force_gpt =3D 1;
 	return 1;
 }
-
-__setup("gpt", force_gpt);
-
+__setup("gpt", force_gpt_fn);
=20
=20
+/*
+ * There are multiple 16-bit CRC polynomials in common use, but this is
+ * *the* standard CRC-32 polynomial, first popularized by Ethernet.
+ * x^32+x^26+x^23+x^22+x^16+x^12+x^11+x^10+x^8+x^7+x^5+x^4+x^2+x^1+x^0
+ */
+#define CRCPOLY_LE 0xedb88320
+/* How many bits at a time to use.  Requires a table of 4<<CRC_xx_BITS byt=
es. */
+/* For less performance-sensitive, use 4 */
+#define CRC_LE_BITS 8
+static u32 *crc32table_le;
=20
-/************************************************************
- * efi_crc32()
- * Requires:
- *  - a buffer of length len
- * Modifies: nothing
- * Returns:
- *  EFI-style CRC32 value for buf
+/**
+ * crc32init_le() - allocate and initialize LE table data
  *
- * This function uses the crc32 function by Gary S. Brown,
- * but seeds the function with ~0, and xor's with ~0 at the end.
- ************************************************************/
+ * crc is the crc of the byte i; other entries are filled in based on the
+ * fact that crctable[i^j] =3D crctable[i] ^ crctable[j].
+ *
+ */
+static int __init crc32init_le(void)
+{
+	unsigned i, j;
+	u32 crc =3D 1;
+
+	crc32table_le +	    kmalloc((1 << CRC_LE_BITS) * sizeof(u32), GFP_KERNEL);
+	if (!crc32table_le)
+		return 1;
+	crc32table_le[0] =3D 0;
+
+	for (i =3D 1 << (CRC_LE_BITS - 1); i; i >>=3D 1) {
+		crc =3D (crc >> 1) ^ ((crc & 1) ? CRCPOLY_LE : 0);
+		for (j =3D 0; j < 1 << CRC_LE_BITS; j +=3D 2 * i)
+			crc32table_le[i + j] =3D crc ^ crc32table_le[j];
+	}
+	return 0;
+}
=20
-static inline u32 efi_crc32(const void *buf, unsigned long len)
+/**
+ * crc32cleanup_le(): free LE table data
+ */
+static void __exit crc32cleanup_le(void)
 {
-	return (crc32(buf, len, ~0L) ^ ~0L);
+	if (crc32table_le) kfree(crc32table_le);
+	crc32table_le =3D NULL;
 }
=20
+__initcall(crc32init_le);
+__exitcall(crc32cleanup_le);
=20
-/************************************************************
- * le_guid_to_cpus()
- * Requires: guid
- * Modifies: guid in situ
- * Returns: nothing
- *
- * This function converts a little endian efi_guid_t to the
- * native cpu representation.  The EFI Spec. declares that all=20
- * on-disk structures are stored in little endian format.
+/**
+ * crc32_le() - Calculate bitwise little-endian Ethernet AUTODIN II CRC32
+ * @crc - seed value for computation.  ~0 for Ethernet, sometimes 0 for
+ *        other uses, or the previous crc32 value if computing incremental=
ly.
+ * @p   - pointer to buffer over which CRC is run
+ * @len - length of buffer @p
  *=20
- ************************************************************/
-
-static void le_guid_to_cpus(efi_guid_t * guid)
+ */
+static u32 crc32_le(u32 crc, unsigned char const *p, size_t len)
 {
-	le32_to_cpus(guid->data1);
-	le16_to_cpus(guid->data2);
-	le16_to_cpus(guid->data3);
-	/* no need to change data4. It's already an array of chars */
-	return;
+	while (len--) {
+		crc =3D (crc >> 8) ^ crc32table_le[(crc ^ *p++) & 255];
+	}
+	return crc;
 }
=20
-/************************************************************
- * le_part_attributes_to_cpus()
- * Requires: attributes
- * Modifies: attributes in situ
- * Returns: nothing
+
+/**
+ * efi_crc32() - EFI version of crc32 function
+ * @buf: buffer to calculate crc32 of
+ * @len - length of buf
  *
- * This function converts a little endian partition attributes
- * struct to the native cpu representation.
+ * Description: Returns EFI-style CRC32 value for @buf
  *=20
- ************************************************************/
-
-static void le_part_attributes_to_cpus(GuidPartitionEntryAttributes_t * a)
+ * This function uses the little endian Ethernet polynomial
+ * but seeds the function with ~0, and xor's with ~0 at the end.
+ * Note, the EFI Specification, v1.02, has a reference to
+ * Dr. Dobbs Journal, May 1994 (actually it's in May 1992).
+ */
+static inline u32
+efi_crc32(const void *buf, unsigned long len)
 {
-	u64 *b =3D (u64 *) a;
-	*b =3D le64_to_cpu(*b);
+	return (crc32_le(~0L, buf, len) ^ ~0L);
 }
=20
-/************************************************************
- * is_pmbr_valid()
- * Requires:
- *  - mbr is a pointer to a legacy mbr structure
- * Modifies: nothing
- * Returns:
- *  1 on true
- *  0 on false
- ************************************************************/
-static int is_pmbr_valid(LegacyMBR_t * mbr)
+/**
+ * is_pmbr_valid(): test Protective MBR for validity
+ * @mbr: pointer to a legacy mbr structure
+ *
+ * Description: Returns 1 if PMBR is valid, 0 otherwise.
+ * Validity depends on two things:
+ *  1) MSDOS signature is in the last two bytes of the MBR
+ *  2) One partition of type 0xEE is found
+ */
+static int
+is_pmbr_valid(legacy_mbr *mbr)
 {
 	int i, found =3D 0, signature =3D 0;
 	if (!mbr)
 		return 0;
-	signature =3D (le16_to_cpu(mbr->Signature) =3D MSDOS_MBR_SIGNATURE);
+	signature =3D (le16_to_cpu(mbr->signature) =3D MSDOS_MBR_SIGNATURE);
 	for (i =3D 0; signature && i < 4; i++) {
-		if (mbr->PartitionRecord[i].OSType =3D
-		    EFI_PMBR_OSTYPE_EFI_GPT) {
+		if (mbr->partition_record[i].sys_ind =3D
+                    EFI_PMBR_OSTYPE_EFI_GPT) {
 			found =3D 1;
 			break;
 		}
@@ -197,43 +249,35 @@
 	return (signature && found);
 }
=20
-
-/************************************************************
- * last_lba()
- * Requires:
- *  - struct gendisk hd
- *  - struct block_device *bdev
- * Modifies: nothing
- * Returns:
- *  Last LBA value on success.  This is stored (by sd and
- *  ide-geometry) in
+/**
+ * last_lba(): return number of last logical block of device
+ * @hd: gendisk with partition list
+ * @bdev: block device
+ *=20
+ * Description: Returns last LBA value on success, 0 on error.
+ * This is stored (by sd and ide-geometry) in
  *  the part[0] entry for this disk, and is the number of
  *  physical sectors available on the disk.
- *  0 on error
- ************************************************************/
-static u64 last_lba(struct gendisk *hd, struct block_device *bdev)
+ */
+static u64
+last_lba(struct gendisk *hd, struct block_device *bdev)
 {
 	if (!hd || !hd->part || !bdev)
 		return 0;
 	return hd->part[MINOR(to_kdev_t(bdev->bd_dev))].nr_sects - 1;
 }
=20
-
-/************************************************************
- * read_lba()
- * Requires:
- *  - hd is our disk device.
- *  - bdev is our device major number
- *  - lba is the logical block address desired (disk hardsector number)
- *  - buffer is a buffer of size size into which data copied
- *  - size_t count is size of the read (in bytes)
- * Modifies:
- *  - buffer
- * Returns:
- *  - count of bytes read
- *  - 0 on error
- ************************************************************/
-
+/**
+ * read_lba(): Read bytes from disk, starting at given LBA
+ * @hd
+ * @bdev
+ * @lba
+ * @buffer
+ * @size_t
+ *
+ * Description:  Reads @count bytes from @bdev into @buffer.
+ * Returns number of bytes read on success, 0 on error.
+ */
 static size_t
 read_lba(struct gendisk *hd, struct block_device *bdev, u64 lba,
 	 u8 * buffer, size_t count)
@@ -259,8 +303,7 @@
=20
 		bytesread  		    PAGE_CACHE_SIZE - (data -
-				       (unsigned char *) page_address(sect.
-								      v));
+				       (unsigned char *) page_address(sect.v));
 		bytesread =3D min(bytesread, count);
 		memcpy(buffer, data, bytesread);
 		put_dev_sector(sect);
@@ -274,57 +317,27 @@
 }
=20
=20
-
-static void print_gpt_header(GuidPartitionTableHeader_t * gpt)
-{
-	Dprintk("GUID Partition Table Header\n");
-	if (!gpt)
-		return;
-	Dprintk("Signature      : " PU64X "\n", gpt->Signature);
-	Dprintk("Revision       : %x\n", gpt->Revision);
-	Dprintk("HeaderSize     : %x\n", gpt->HeaderSize);
-	Dprintk("HeaderCRC32    : %x\n", gpt->HeaderCRC32);
-	Dprintk("MyLBA          : " PU64X "\n", gpt->MyLBA);
-	Dprintk("AlternateLBA   : " PU64X "\n", gpt->AlternateLBA);
-	Dprintk("FirstUsableLBA : " PU64X "\n", gpt->FirstUsableLBA);
-	Dprintk("LastUsableLBA  : " PU64X "\n", gpt->LastUsableLBA);
-
-	Dprintk("PartitionEntryLBA : " PU64X "\n", gpt->PartitionEntryLBA);
-	Dprintk("NumberOfPartitionEntries : %x\n",
-		gpt->NumberOfPartitionEntries);
-	Dprintk("SizeOfPartitionEntry : %x\n", gpt->SizeOfPartitionEntry);
-	Dprintk("PartitionEntryArrayCRC32 : %x\n",
-		gpt->PartitionEntryArrayCRC32);
-
-	return;
-}
-
-
-
-/************************************************************
- * alloc_read_gpt_entries()
- * Requires:
- *  - hd, bdev, gpt
- * Modifies:
- *  - nothing
- * Returns:
- *   ptes on success
- *   NULL on error
+/**
+ * alloc_read_gpt_entries(): reads partition entries from disk
+ * @hd
+ * @bdev
+ * @gpt - GPT header
+ *=20
+ * Description: Returns ptes on success,  NULL on error.
+ * Allocates space for PTEs based on information found in @gpt.
  * Notes: remember to free pte when you're done!
- ************************************************************/
-static GuidPartitionEntry_t *
+ */
+static gpt_entry *
 alloc_read_gpt_entries(struct gendisk *hd,
-                       struct block_device *bdev,
-                       GuidPartitionTableHeader_t *gpt)
+		       struct block_device *bdev, gpt_header *gpt)
 {
-	u32 i, j;
 	size_t count;
-	GuidPartitionEntry_t *pte;
+	gpt_entry *pte;
 	if (!hd || !bdev || !gpt)
 		return NULL;
=20
-	count =3D gpt->NumberOfPartitionEntries * gpt->SizeOfPartitionEntry;
-	Dprintk("ReadGPTEs() kmallocing %x bytes\n", count);
+	count =3D le32_to_cpu(gpt->num_partition_entries) *
+                le32_to_cpu(gpt->sizeof_partition_entry);
 	if (!count)
 		return NULL;
 	pte =3D kmalloc(count, GFP_KERNEL);
@@ -332,108 +345,62 @@
 		return NULL;
 	memset(pte, 0, count);
=20
-	if (read_lba(hd, bdev, gpt->PartitionEntryLBA, (u8 *) pte,
+	if (read_lba(hd, bdev, le64_to_cpu(gpt->partition_entry_lba),
+                     (u8 *) pte,
 		     count) < count) {
 		kfree(pte);
+                pte=3DNULL;
 		return NULL;
 	}
-	/* Fixup endianness */
-	for (i =3D 0; i < gpt->NumberOfPartitionEntries; i++) {
-		le_guid_to_cpus(&pte[i].PartitionTypeGuid);
-		le_guid_to_cpus(&pte[i].UniquePartitionGuid);
-		le64_to_cpus(pte[i].StartingLBA);
-		le64_to_cpus(pte[i].EndingLBA);
-		le_part_attributes_to_cpus(&pte[i].Attributes);
-		for (j =3D 0; j < (72 / sizeof(efi_char16_t)); j++) {
-			le16_to_cpus((u16) (pte[i].PartitionName[j]));
-		}
-	}
-
 	return pte;
 }
=20
-
-
-/************************************************************
- * alloc_read_gpt_header()
- * Requires:
- *  - hd is our struct gendisk
- *  - dev is our device major number
- *  - lba is the Logical Block Address of the partition table
- *  - gpt is a buffer into which the GPT will be put
- *  - pte is a buffer into which the PTEs will be put
- * Modifies:
- *  - gpt and pte
- * Returns:
- *   1 on success
- *   0 on error
- ************************************************************/
-
-static GuidPartitionTableHeader_t *alloc_read_gpt_header(struct gendisk
-							 *hd,
-							 struct
-							 block_device
-							 *bdev, u64 lba)
+/**
+ * alloc_read_gpt_header(): Allocates GPT header, reads into it from disk
+ * @hd
+ * @bdev
+ * @lba is the Logical Block Address of the partition table
+ *=20
+ * Description: returns GPT header on success, NULL on error.   Allocates
+ * and fills a GPT header starting at @ from @bdev.
+ * Note: remember to free gpt when finished with it.
+ */
+static gpt_header *
+alloc_read_gpt_header(struct gendisk *hd, struct block_device *bdev, u64 l=
ba)
 {
-	GuidPartitionTableHeader_t *gpt;
+	gpt_header *gpt;
 	if (!hd || !bdev)
 		return NULL;
=20
-	gpt =3D kmalloc(sizeof(GuidPartitionTableHeader_t), GFP_KERNEL);
+	gpt =3D kmalloc(sizeof (gpt_header), GFP_KERNEL);
 	if (!gpt)
 		return NULL;
-	memset(gpt, 0, sizeof(GuidPartitionTableHeader_t));
+	memset(gpt, 0, sizeof (gpt_header));
=20
-	Dprintk("GPTH() calling read_lba().\n");
 	if (read_lba(hd, bdev, lba, (u8 *) gpt,
-		     sizeof(GuidPartitionTableHeader_t)) <
-	    sizeof(GuidPartitionTableHeader_t)) {
-		Dprintk("ReadGPTH(" PU64X ") read failed.\n", lba);
+		     sizeof (gpt_header)) < sizeof (gpt_header)) {
 		kfree(gpt);
+                gpt=3DNULL;
 		return NULL;
 	}
=20
-	/* Fixup endianness */
-	le64_to_cpus(gpt->Signature);
-	le32_to_cpus(gpt->Revision);
-	le32_to_cpus(gpt->HeaderSize);
-	le32_to_cpus(gpt->HeaderCRC32);
-	le32_to_cpus(gpt->Reserved1);
-	le64_to_cpus(gpt->MyLBA);
-	le64_to_cpus(gpt->AlternateLBA);
-	le64_to_cpus(gpt->FirstUsableLBA);
-	le64_to_cpus(gpt->LastUsableLBA);
-	le_guid_to_cpus(&gpt->DiskGUID);
-	le64_to_cpus(gpt->PartitionEntryLBA);
-	le32_to_cpus(gpt->NumberOfPartitionEntries);
-	le32_to_cpus(gpt->SizeOfPartitionEntry);
-	le32_to_cpus(gpt->PartitionEntryArrayCRC32);
-
-	print_gpt_header(gpt);
-
 	return gpt;
 }
=20
-
-
-/************************************************************
- * is_gpt_valid()
- * Requires:
- *  - gd points to our struct gendisk
- *  - dev is our device major number
- *  - lba is the logical block address of the GPTH to test
- *  - gpt is a GPTH if it's valid
- *  - ptes is a PTEs if it's valid
- * Modifies:
- *  - gpt and ptes
- * Returns:
- *   1 if valid
- *   0 on error
- ************************************************************/
+/**
+ * is_gpt_valid() - tests one GPT header and PTEs for validity
+ * @hd
+ * @bdev
+ * @lba is the logical block address of the GPT header to test
+ * @gpt is a GPT header ptr, filled on return.
+ * @ptes is a PTEs ptr, filled on return.
+ *
+ * Description: returns 1 if valid,  0 on error.
+ * If valid, returns pointers to newly allocated GPT header and PTEs.
+ */
 static int
 is_gpt_valid(struct gendisk *hd, struct block_device *bdev, u64 lba,
-	     GuidPartitionTableHeader_t ** gpt,
-	     GuidPartitionEntry_t ** ptes)
+	     gpt_header **gpt, gpt_entry **ptes)
 {
 	u32 crc, origcrc;
=20
@@ -442,10 +409,10 @@
 	if (!(*gpt =3D alloc_read_gpt_header(hd, bdev, lba)))
 		return 0;
=20
-	/* Check the GUID Partition Table Signature */
-	if ((*gpt)->Signature !=3D GPT_HEADER_SIGNATURE) {
-		Dprintk("GUID Partition Table Header Signature is wrong: "
-			PU64X " !=3D " PU64X "\n", (*gpt)->Signature,
+	/* Check the GUID Partition Table signature */
+	if (le64_to_cpu((*gpt)->signature) !=3D GPT_HEADER_SIGNATURE) {
+		Dprintk("GUID Partition Table Header signature is wrong: %"
+			PRIx64 " !=3D %" PRIx64 "\n", le64_to_cpu((*gpt)->signature),
 			GPT_HEADER_SIGNATURE);
 		kfree(*gpt);
 		*gpt =3D NULL;
@@ -453,34 +420,31 @@
 	}
=20
 	/* Check the GUID Partition Table CRC */
-	origcrc =3D (*gpt)->HeaderCRC32;
-	(*gpt)->HeaderCRC32 =3D 0;
-	crc -	    efi_crc32((const unsigned char *) (*gpt), (*gpt)->HeaderSize);
-
+	origcrc =3D le32_to_cpu((*gpt)->header_crc32);
+	(*gpt)->header_crc32 =3D 0;
+	crc =3D efi_crc32((const unsigned char *) (*gpt), le32_to_cpu((*gpt)->hea=
der_size));
=20
 	if (crc !=3D origcrc) {
 		Dprintk
 		    ("GUID Partition Table Header CRC is wrong: %x !=3D %x\n",
-		     (*gpt)->HeaderCRC32, origcrc);
+		     crc, origcrc);
 		kfree(*gpt);
 		*gpt =3D NULL;
 		return 0;
 	}
-	(*gpt)->HeaderCRC32 =3D origcrc;
+	(*gpt)->header_crc32 =3D cpu_to_le32(origcrc);
=20
-	/* Check that the MyLBA entry points to the LBA that contains
+	/* Check that the my_lba entry points to the LBA that contains
 	 * the GUID Partition Table */
-	if ((*gpt)->MyLBA !=3D lba) {
-		Dprintk("GPT MyLBA incorrect: " PU64X " !=3D " PU64X "\n",
-			(*gpt)->MyLBA, lba);
+	if (le64_to_cpu((*gpt)->my_lba) !=3D lba) {
+		Dprintk("GPT my_lba incorrect: %" PRIx64 " !=3D %" PRIx64 "\n",
+			le64_to_cpu((*gpt)->my_lba), lba);
 		kfree(*gpt);
 		*gpt =3D NULL;
 		return 0;
 	}
=20
 	if (!(*ptes =3D alloc_read_gpt_entries(hd, bdev, *gpt))) {
-		Dprintk("read PTEs failed.\n");
 		kfree(*gpt);
 		*gpt =3D NULL;
 		return 0;
@@ -488,12 +452,11 @@
=20
 	/* Check the GUID Partition Entry Array CRC */
 	crc =3D efi_crc32((const unsigned char *) (*ptes),
-			(*gpt)->NumberOfPartitionEntries *
-			(*gpt)->SizeOfPartitionEntry);
+			le32_to_cpu((*gpt)->num_partition_entries) *
+			le32_to_cpu((*gpt)->sizeof_partition_entry));
=20
-	if (crc !=3D (*gpt)->PartitionEntryArrayCRC32) {
-		Dprintk
-		    ("GUID Partitition Entry Array CRC check failed.\n");
+	if (crc !=3D le32_to_cpu((*gpt)->partition_entry_array_crc32)) {
+		Dprintk("GUID Partitition Entry Array CRC check failed.\n");
 		kfree(*gpt);
 		*gpt =3D NULL;
 		kfree(*ptes);
@@ -501,164 +464,231 @@
 		return 0;
 	}
=20
-
 	/* We're done, all's well */
 	return 1;
 }
=20
+/**
+ * compare_gpts() - Search disk for valid GPT headers and PTEs
+ * @pgpt is the primary GPT header
+ * @agpt is the alternate GPT header
+ * @lastlba is the last LBA number
+ * Description: Returns nothing.  Sanity checks pgpt and agpt fields
+ * and prints warnings on discrepancies.
+ *=20
+ */
+static void
+compare_gpts(gpt_header *pgpt, gpt_header *agpt, u64 lastlba)
+{
+	int error_found =3D 0;
+	if (!pgpt || !agpt)
+		return;
+	if (le64_to_cpu(pgpt->my_lba) !=3D le64_to_cpu(agpt->alternate_lba)) {
+		printk(KERN_WARNING
+		       "GPT:Primary header LBA !=3D Alt. header alternate_lba\n");
+		printk(KERN_WARNING "GPT:%" PRIx64 " !=3D %" PRIx64 "\n",
+		       le64_to_cpu(pgpt->my_lba),
+                       le64_to_cpu(agpt->alternate_lba));
+		error_found++;
+	}
+	if (le64_to_cpu(pgpt->alternate_lba) !=3D le64_to_cpu(agpt->my_lba)) {
+		printk(KERN_WARNING
+		       "GPT:Primary header alternate_lba !=3D Alt. header my_lba\n");
+		printk(KERN_WARNING "GPT:%" PRIx64 " !=3D %" PRIx64 "\n",
+		       le64_to_cpu(pgpt->alternate_lba),
+                       le64_to_cpu(agpt->my_lba));
+		error_found++;
+	}
+	if (le64_to_cpu(pgpt->first_usable_lba) !+            le64_to_cpu(agpt->f=
irst_usable_lba)) {
+		printk(KERN_WARNING "GPT:first_usable_lbas don't match.\n");
+		printk(KERN_WARNING "GPT:%" PRIx64 " !=3D %" PRIx64 "\n",
+		       le64_to_cpu(pgpt->first_usable_lba),
+                       le64_to_cpu(agpt->first_usable_lba));
+		error_found++;
+	}
+	if (le64_to_cpu(pgpt->last_usable_lba) !+            le64_to_cpu(agpt->la=
st_usable_lba)) {
+		printk(KERN_WARNING "GPT:last_usable_lbas don't match.\n");
+		printk(KERN_WARNING "GPT:%" PRIx64 " !=3D %" PRIx64 "\n",
+		       le64_to_cpu(pgpt->last_usable_lba),
+                       le64_to_cpu(agpt->last_usable_lba));
+		error_found++;
+	}
+	if (efi_guidcmp(pgpt->disk_guid, agpt->disk_guid)) {
+		printk(KERN_WARNING "GPT:disk_guids don't match.\n");
+		error_found++;
+	}
+	if (le32_to_cpu(pgpt->num_partition_entries) !+            le32_to_cpu(ag=
pt->num_partition_entries)) {
+		printk(KERN_WARNING "GPT:num_partition_entries don't match: "
+		       "0x%x !=3D 0x%x\n",
+		       le32_to_cpu(pgpt->num_partition_entries),
+		       le32_to_cpu(agpt->num_partition_entries));
+		error_found++;
+	}
+	if (le32_to_cpu(pgpt->sizeof_partition_entry) !+            le32_to_cpu(a=
gpt->sizeof_partition_entry)) {
+		printk(KERN_WARNING
+		       "GPT:sizeof_partition_entry values don't match: "
+		       "0x%x !=3D 0x%x\n",
+                       le32_to_cpu(pgpt->sizeof_partition_entry),
+		       le32_to_cpu(agpt->sizeof_partition_entry));
+		error_found++;
+	}
+	if (le32_to_cpu(pgpt->partition_entry_array_crc32) !+            le32_to_=
cpu(agpt->partition_entry_array_crc32)) {
+		printk(KERN_WARNING
+		       "GPT:partition_entry_array_crc32 values don't match: "
+		       "0x%x !=3D 0x%x\n",
+                       le32_to_cpu(pgpt->partition_entry_array_crc32),
+		       le32_to_cpu(agpt->partition_entry_array_crc32));
+		error_found++;
+	}
+	if (le64_to_cpu(pgpt->alternate_lba) !=3D lastlba) {
+		printk(KERN_WARNING
+		       "GPT:Primary header thinks Alt. header is not at the end of the d=
isk.\n");
+		printk(KERN_WARNING "GPT:%" PRIx64 " !=3D %" PRIx64 "\n",
+		       le64_to_cpu(pgpt->alternate_lba), lastlba);
+		error_found++;
+	}
=20
+	if (le64_to_cpu(agpt->my_lba) !=3D lastlba) {
+		printk(KERN_WARNING
+		       "GPT:Alternate GPT header not at the end of the disk.\n");
+		printk(KERN_WARNING "GPT:%" PRIx64 " !=3D %" PRIx64 "\n",
+		       le64_to_cpu(agpt->my_lba), lastlba);
+		error_found++;
+	}
=20
-/************************************************************
- * find_valid_gpt()
- * Requires:
- *  - gd points to our struct gendisk
- *  - dev is our device major number
- *  - gpt is a GPTH if it's valid
- *  - ptes is a PTE
- * Modifies:
- *  - gpt & ptes
- * Returns:
- *   1 if valid
- *   0 on error
- ************************************************************/
+	if (error_found)
+		printk(KERN_WARNING
+		       "GPT: Use GNU Parted to correct GPT errors.\n");
+	return;
+}
+
+/**
+ * find_valid_gpt() - Search disk for valid GPT headers and PTEs
+ * @hd
+ * @bdev
+ * @gpt is a GPT header ptr, filled on return.
+ * @ptes is a PTEs ptr, filled on return.
+ * Description: Returns 1 if valid, 0 on error.
+ * If valid, returns pointers to newly allocated GPT header and PTEs.
+ * Validity depends on finding either the Primary GPT header and PTEs vali=
d,
+ * or the Alternate GPT header and PTEs valid, and the PMBR valid.
+ */
 static int
 find_valid_gpt(struct gendisk *hd, struct block_device *bdev,
-	       GuidPartitionTableHeader_t ** gpt,
-	       GuidPartitionEntry_t ** ptes)
+	       gpt_header **gpt, gpt_entry **ptes)
 {
 	int good_pgpt =3D 0, good_agpt =3D 0, good_pmbr =3D 0;
-	GuidPartitionTableHeader_t *pgpt =3D NULL, *agpt =3D NULL;
-	GuidPartitionEntry_t *pptes =3D NULL, *aptes =3D NULL;
-	LegacyMBR_t *legacyMbr =3D NULL;
+	gpt_header *pgpt =3D NULL, *agpt =3D NULL;
+	gpt_entry *pptes =3D NULL, *aptes =3D NULL;
+	legacy_mbr *legacymbr =3D NULL;
 	u64 lastlba;
 	if (!hd || !bdev || !gpt || !ptes)
 		return 0;
=20
 	lastlba =3D last_lba(hd, bdev);
-	/* Check the Primary GPT */
 	good_pgpt =3D is_gpt_valid(hd, bdev, GPT_PRIMARY_PARTITION_TABLE_LBA,
 				 &pgpt, &pptes);
-	if (good_pgpt) {
-		/* Primary GPT is OK, check the alternate and warn if bad */
-		good_agpt =3D is_gpt_valid(hd, bdev, pgpt->AlternateLBA,
+        if (good_pgpt) {
+		good_agpt =3D is_gpt_valid(hd, bdev,
+                                         le64_to_cpu(pgpt->alternate_lba),
 					 &agpt, &aptes);
-		if (!good_agpt) {
-			printk(KERN_WARNING
-			       "Alternate GPT is invalid, using primary GPT.\n");
-		}
-
-		*gpt =3D pgpt;
-		*ptes =3D pptes;
-		if (agpt) {
-			kfree(agpt);
-			agpt =3D NULL;
-		}
-		if (aptes) {
-			kfree(aptes);
-			aptes =3D NULL;
-		}
-	} /* if primary is valid */
-	else {
-		/* Primary GPT is bad, check the Alternate GPT */
-		good_agpt =3D is_gpt_valid(hd, bdev, lastlba, &agpt, &aptes);
-		if (good_agpt) {
-			/* Primary is bad, alternate is good.
-			   Return values from the alternate and warn.
-			 */
-			printk(KERN_WARNING
-			       "Primary GPT is invalid, using alternate GPT.\n");
-			*gpt =3D agpt;
-			*ptes =3D aptes;
-		}
-	}
+                if (!good_agpt) {
+                        good_agpt =3D is_gpt_valid(hd, bdev, lastlba,
+                                                 &agpt, &aptes);
+                }
+        }
+        else {
+                good_agpt =3D is_gpt_valid(hd, bdev, lastlba,
+                                         &agpt, &aptes);
+        }
+
+        /* The obviously unsuccessful case */
+        if (!good_pgpt && !good_agpt) {
+                goto fail;
+        }
=20
-	/* Now test for valid PMBR */
 	/* This will be added to the EFI Spec. per Intel after v1.02. */
-	if (good_pgpt || good_agpt) {
-		legacyMbr =3D kmalloc(sizeof(*legacyMbr), GFP_KERNEL);
-		if (legacyMbr) {
-			memset(legacyMbr, 0, sizeof(*legacyMbr));
-			read_lba(hd, bdev, 0, (u8 *) legacyMbr,
-				 sizeof(*legacyMbr));
-			good_pmbr =3D is_pmbr_valid(legacyMbr);
-			kfree(legacyMbr);
-		}
-		if (good_pmbr)
-			return 1;
-		if (!forcegpt) {
-			printk
-			    (" Warning: Disk has a valid GPT signature but invalid PMBR.\n");
-			printk(KERN_WARNING
-			       "  Assuming this disk is *not* a GPT disk anymore.\n");
-			printk(KERN_WARNING
-			       "  Use gpt kernel option to override.  Use GNU Parted to correct=
 disk.\n");
-		} else {
-			printk(KERN_WARNING
-			       "  Warning: Disk has a valid GPT signature but invalid PMBR.\n");
-			printk(KERN_WARNING
-			       "  Use GNU Parted to correct disk.\n");
-			printk(KERN_WARNING
-			       "  gpt option taken, disk treated as GPT.\n");
-			return 1;
-		}
-	}
-
-	/* Both primary and alternate GPTs are bad, and/or PMBR is invalid.
-	 * This isn't our disk, return 0.
-	 */
-	*gpt =3D NULL;
+        legacymbr =3D kmalloc(sizeof (*legacymbr), GFP_KERNEL);
+        if (legacymbr) {
+                memset(legacymbr, 0, sizeof (*legacymbr));
+                read_lba(hd, bdev, 0, (u8 *) legacymbr,
+                         sizeof (*legacymbr));
+                good_pmbr =3D is_pmbr_valid(legacymbr);
+                kfree(legacymbr);
+                legacymbr=3DNULL;
+        }
+
+        /* Failure due to bad PMBR */
+        if ((good_pgpt || good_agpt) && !good_pmbr && !force_gpt) {
+                printk(KERN_WARNING=20
+                       "  Warning: Disk has a valid GPT signature "
+                       "but invalid PMBR.\n");
+                printk(KERN_WARNING
+                       "  Assuming this disk is *not* a GPT disk anymore.\=
n");
+                printk(KERN_WARNING
+                       "  Use gpt kernel option to override.  "
+                       "Use GNU Parted to correct disk.\n");
+                goto fail;
+        }
+
+        /* Would fail due to bad PMBR, but force GPT anyhow */
+        if ((good_pgpt || good_agpt) && !good_pmbr && force_gpt) {
+                printk(KERN_WARNING
+                       "  Warning: Disk has a valid GPT signature but "
+                       "invalid PMBR.\n");
+                printk(KERN_WARNING
+                       "  Use GNU Parted to correct disk.\n");
+                printk(KERN_WARNING
+                       "  gpt option taken, disk treated as GPT.\n");
+        }
+
+        compare_gpts(pgpt, agpt, lastlba);
+
+        /* The good cases */
+        if (good_pgpt && (good_pmbr || force_gpt)) {
+                *gpt  =3D pgpt;
+                *ptes =3D pptes;
+                if (agpt)  { kfree(agpt);   agpt =3D NULL; }
+                if (aptes) { kfree(aptes); aptes =3D NULL; }
+                if (!good_agpt) {
+                        printk(KERN_WARNING=20
+			       "Alternate GPT is invalid, "
+                               "using primary GPT.\n");
+                }
+                return 1;
+        }
+        else if (good_agpt && (good_pmbr || force_gpt)) {
+                *gpt  =3D agpt;
+                *ptes =3D aptes;
+                if (pgpt)  { kfree(pgpt);   pgpt =3D NULL; }
+                if (pptes) { kfree(pptes); pptes =3D NULL; }
+                printk(KERN_WARNING=20
+                       "Primary GPT is invalid, using alternate GPT.\n");
+                return 1;
+        }
+
+ fail:
+        if (pgpt)  { kfree(pgpt);   pgpt=3DNULL; }
+        if (agpt)  { kfree(agpt);   agpt=3DNULL; }
+        if (pptes) { kfree(pptes); pptes=3DNULL; }
+        if (aptes) { kfree(aptes); aptes=3DNULL; }
+        *gpt =3D NULL;
         *ptes =3D NULL;
-
-	if (pgpt) {
-		kfree(pgpt);
-		pgpt =3D NULL;
-	}
-	if (agpt) {
-		kfree(agpt);
-		agpt =3D NULL;
-	}
-	if (pptes) {
-		kfree(pptes);
-		pptes =3D NULL;
-	}
-	if (aptes) {
-		kfree(aptes);
-		aptes =3D NULL;
-	}
-	return 0;
+        return 0;
 }
=20
-#ifdef CONFIG_DEVFS_GUID
-/* set_partition_guid */
-/* Fill in the GUID field of the partition.
-   It is set to NULL by register_disk before. */
-static void
-set_partition_guid(struct gendisk *hd,
-		   const int minor, const efi_guid_t * guid)
-{
-	efi_guid_t *part_guid =3D hd->part[minor].guid;
-
-	if (!guid || !hd)
-		return;
-
-	part_guid =3D kmalloc(sizeof(efi_guid_t), GFP_KERNEL);
-
-	if (part_guid) {
-		memcpy(part_guid, guid, sizeof(efi_guid_t));
-	} else {
-		printk(KERN_WARNING
-		       "add_gpt_partitions: cannot allocate GUID memory!\n");
-	};
-
-	hd->part[minor].guid =3D part_guid;
-}
-#else
-#define set_partition_guid(hd, minor, guid)
-#endif				/* CONFIG_DEVFS_GUID */
-
-/*
- * Create devices for each entry in the GUID Partition Table Entries.
- * The first block of each partition is a Legacy MBR.
+/**
+ * add_gpt_partitions(struct gendisk *hd, struct block_device *bdev,
+ * @hd
+ * @bdev
+ *
+ * Description: Create devices for each entry in the GUID Partition Table
+ * Entries.
  *
  * We do not create a Linux partition for GPT, but
  * only for the actual data partitions.
@@ -668,69 +698,69 @@
  *  1 if successful
  *
  */
-
 static int
-add_gpt_partitions(struct gendisk *hd, struct block_device *bdev,
-		   int nextminor)
+add_gpt_partitions(struct gendisk *hd, struct block_device *bdev, int next=
minor)
 {
-	GuidPartitionTableHeader_t *gpt =3D NULL;
-	GuidPartitionEntry_t *ptes =3D NULL;
-	u32 i, nummade =3D 0;
-
-	efi_guid_t unusedGuid =3D UNUSED_ENTRY_GUID;
-#if CONFIG_BLK_DEV_MD
-	efi_guid_t raidGuid =3D PARTITION_LINUX_RAID_GUID;
-#endif
+	gpt_header *gpt =3D NULL;
+	gpt_entry *ptes =3D NULL;
+	u32 i;
+	int max_p;=20
=20
 	if (!hd || !bdev)
 		return -1;
=20
 	if (!find_valid_gpt(hd, bdev, &gpt, &ptes) || !gpt || !ptes) {
-		if (gpt)
+		if (gpt) {
 			kfree(gpt);
-		if (ptes)
+                        gpt =3D NULL;
+                }
+		if (ptes) {
 			kfree(ptes);
+                        ptes =3D NULL;
+                }
 		return 0;
 	}
=20
 	Dprintk("GUID Partition Table is valid!  Yea!\n");
=20
-	set_partition_guid(hd, nextminor - 1, &(gpt->DiskGUID));
-
-	for (i =3D 0; i < gpt->NumberOfPartitionEntries &&
-	     nummade < (hd->max_p - 1); i++) {
-		if (!efi_guidcmp(unusedGuid, ptes[i].PartitionTypeGuid))
+	max_p =3D (1 << hd->minor_shift) - 1;
+	for (i =3D 0; i < le32_to_cpu(gpt->num_partition_entries) && i < max_p; i=
++) {
+		if (!efi_guidcmp(ptes[i].partition_type_guid, NULL_GUID))
 			continue;
=20
-		add_gd_partition(hd, nextminor, ptes[i].StartingLBA,
-				 (ptes[i].EndingLBA - ptes[i].StartingLBA +
+		add_gd_partition(hd, nextminor+i,
+                                 le64_to_cpu(ptes[i].starting_lba),
+				 (le64_to_cpu(ptes[i].ending_lba) -
+                                  le64_to_cpu(ptes[i].starting_lba) +
 				  1));
=20
-		set_partition_guid(hd, nextminor,
-				   &(ptes[i].UniquePartitionGuid));
-
 		/* If there's this is a RAID volume, tell md */
 #if CONFIG_BLK_DEV_MD
-		if (!efi_guidcmp(raidGuid, ptes[i].PartitionTypeGuid)) {
-			md_autodetect_dev(MKDEV
-					  (MAJOR(to_kdev_t(bdev->bd_dev)),
-					   nextminor));
+		if (!efi_guidcmp(ptes[i].partition_type_guid,
+                                 PARTITION_LINUX_RAID_GUID)) {
+                        md_autodetect_dev(MKDEV
+                                          (MAJOR(to_kdev_t(bdev->bd_dev)),
+                                           nextminor));
 		}
 #endif
-		nummade++;
-		nextminor++;
-
 	}
 	kfree(ptes);
+        ptes=3DNULL;
 	kfree(gpt);
+        gpt=3DNULL;
 	printk("\n");
 	return 1;
-
 }
=20
-
-/*
- * efi_partition()
+/**
+ * efi_partition(): EFI GPT partition handling entry function
+ * @hd
+ * @bdev
+ * @first_sector: unused
+ * @first_part_minor: minor number assigned to first GPT partition found
+ *
+ * Description: called from check.c, if the disk contains GPT
+ * partitions, sets up partition entries in the kernel.
  *
  * If the first block on the disk is a legacy MBR,
  * it will get handled by msdos_partition().
@@ -745,9 +775,7 @@
  * -1 if unable to read the partition table
  *  0 if this isn't our partitoin table
  *  1 if successful
- *
  */
-
 int
 efi_partition(struct gendisk *hd, struct block_device *bdev,
 	      unsigned long first_sector, int first_part_minor)
@@ -760,7 +788,7 @@
=20
 	/* Need to change the block size that the block layer uses */
 	if (blksize_size[MAJOR(dev)]) {
-		orig_blksize_size =3D blksize_size[MAJOR(dev)][MINOR(dev)];
+                orig_blksize_size =3D blksize_size[MAJOR(dev)][MINOR(dev)];
 	}
=20
 	if (orig_blksize_size !=3D hardblocksize)
@@ -774,7 +802,6 @@
=20
 	return rc;
 }
-
=20
 /*
  * Overrides for Emacs so that we follow Linus's tabbing style.
diff -urN linux-davidm/fs/partitions/efi.h lia64-2.4/fs/partitions/efi.h
--- linux-davidm/fs/partitions/efi.h	Wed Apr 10 13:24:38 2002
+++ lia64-2.4/fs/partitions/efi.h	Wed Apr 10 11:43:40 2002
@@ -39,7 +39,6 @@
  */
 #include <asm-ia64/efi.h>
=20
-
 #define MSDOS_MBR_SIGNATURE 0xaa55
 #define EFI_PMBR_OSTYPE_EFI 0xEF
 #define EFI_PMBR_OSTYPE_EFI_GPT 0xEE
@@ -49,90 +48,73 @@
 #define GPT_HEADER_REVISION_V1 0x00010000
 #define GPT_PRIMARY_PARTITION_TABLE_LBA 1
=20
-#define UNUSED_ENTRY_GUID    \
-    ((efi_guid_t) { 0x00000000, 0x0000, 0x0000, { 0x00, 0x00, 0x00, 0x00, =
0x00, 0x00, 0x00, 0x00 }})
 #define PARTITION_SYSTEM_GUID \
-((efi_guid_t) { 0xC12A7328, 0xF81F, 0x11d2, { 0xBA, 0x4B, 0x00, 0xA0, 0xC9=
, 0x3E, 0xC9, 0x3B }})
+    EFI_GUID( 0xC12A7328, 0xF81F, 0x11d2, \
+              0xBA, 0x4B, 0x00, 0xA0, 0xC9, 0x3E, 0xC9, 0x3B)=20
 #define LEGACY_MBR_PARTITION_GUID \
-    ((efi_guid_t) { 0x024DEE41, 0x33E7, 0x11d3, { 0x9D, 0x69, 0x00, 0x08, =
0xC7, 0x81, 0xF3, 0x9F }})
+    EFI_GUID( 0x024DEE41, 0x33E7, 0x11d3, \
+              0x9D, 0x69, 0x00, 0x08, 0xC7, 0x81, 0xF3, 0x9F)
 #define PARTITION_MSFT_RESERVED_GUID \
-    ((efi_guid_t) { 0xE3C9E316, 0x0B5C, 0x4DB8, { 0x81, 0x7D, 0xF9, 0x2D, =
0xF0, 0x02, 0x15, 0xAE }})
+    EFI_GUID( 0xE3C9E316, 0x0B5C, 0x4DB8, \
+              0x81, 0x7D, 0xF9, 0x2D, 0xF0, 0x02, 0x15, 0xAE)
 #define PARTITION_BASIC_DATA_GUID \
-    ((efi_guid_t) { 0xEBD0A0A2, 0xB9E5, 0x4433, { 0x87, 0xC0, 0x68, 0xB6, =
0xB7, 0x26, 0x99, 0xC7 }})
+    EFI_GUID( 0xEBD0A0A2, 0xB9E5, 0x4433, \
+              0x87, 0xC0, 0x68, 0xB6, 0xB7, 0x26, 0x99, 0xC7)
 #define PARTITION_LINUX_RAID_GUID \
-    ((efi_guid_t) { 0xa19d880f, 0x05fc, 0x4d3b, { 0xa0, 0x06, 0x74, 0x3f, =
0x0f, 0x84, 0x91, 0x1e  }})
+    EFI_GUID( 0xa19d880f, 0x05fc, 0x4d3b, \
+              0xa0, 0x06, 0x74, 0x3f, 0x0f, 0x84, 0x91, 0x1e)
 #define PARTITION_LINUX_SWAP_GUID \
-    ((efi_guid_t) { 0x0657fd6d, 0xa4ab, 0x43c4, { 0x84, 0xe5, 0x09, 0x33, =
0xc8, 0x4b, 0x4f, 0x4f  }})
+    EFI_GUID( 0x0657fd6d, 0xa4ab, 0x43c4, \
+              0x84, 0xe5, 0x09, 0x33, 0xc8, 0x4b, 0x4f, 0x4f)
 #define PARTITION_LINUX_LVM_GUID \
-    ((efi_guid_t) { 0xe6d6d379, 0xf507, 0x44c2, { 0xa2, 0x3c, 0x23, 0x8f, =
0x2a, 0x3d, 0xf9, 0x28 }})
-
-typedef struct _GuidPartitionTableHeader_t {
-	u64 Signature;
-	u32 Revision;
-	u32 HeaderSize;
-	u32 HeaderCRC32;
-	u32 Reserved1;
-	u64 MyLBA;
-	u64 AlternateLBA;
-	u64 FirstUsableLBA;
-	u64 LastUsableLBA;
-	efi_guid_t DiskGUID;
-	u64 PartitionEntryLBA;
-	u32 NumberOfPartitionEntries;
-	u32 SizeOfPartitionEntry;
-	u32 PartitionEntryArrayCRC32;
-	u8 Reserved2[GPT_BLOCK_SIZE - 92];
-} __attribute__ ((packed)) GuidPartitionTableHeader_t;
-
-typedef struct _GuidPartitionEntryAttributes_t {
-	u64 RequiredToFunction:1;
-	u64 Reserved:63;
-} __attribute__ ((packed)) GuidPartitionEntryAttributes_t;
-
-typedef struct _GuidPartitionEntry_t {
-	efi_guid_t PartitionTypeGuid;
-	efi_guid_t UniquePartitionGuid;
-	u64 StartingLBA;
-	u64 EndingLBA;
-	GuidPartitionEntryAttributes_t Attributes;
-	efi_char16_t PartitionName[72 / sizeof(efi_char16_t)];
-} __attribute__ ((packed)) GuidPartitionEntry_t;
-
-typedef struct _PartitionRecord_t {
-	u8 BootIndicator;	/* Not used by EFI firmware. Set to 0x80 to indicate th=
at this
-				   is the bootable legacy partition. */
-	u8 StartHead;		/* Start of partition in CHS address, not used by EFI firm=
ware. */
-	u8 StartSector;		/* Start of partition in CHS address, not used by EFI fi=
rmware. */
-	u8 StartTrack;		/* Start of partition in CHS address, not used by EFI fir=
mware. */
-	u8 OSType;		/* OS type. A value of 0xEF defines an EFI system partition.
-				   Other values are reserved for legacy operating systems, and
-				   allocated independently of the EFI specification. */
-	u8 EndHead;		/* End of partition in CHS address, not used by EFI firmware=
. */
-	u8 EndSector;		/* End of partition in CHS address, not used by EFI firmwa=
re. */
-	u8 EndTrack;		/* End of partition in CHS address, not used by EFI firmwar=
e. */
-	u32 StartingLBA;	/* Starting LBA address of the partition on the disk. Us=
ed by
-				   EFI firmware to define the start of the partition. */
-	u32 SizeInLBA;		/* Size of partition in LBA. Used by EFI firmware to dete=
rmine
-				   the size of the partition. */
-} PartitionRecord_t;
-
-typedef struct _LegacyMBR_t {
-	u8 BootCode[440];
-	u32 UniqueMBRSignature;
-	u16 Unknown;
-	PartitionRecord_t PartitionRecord[4];
-	u16 Signature;
-} __attribute__ ((packed)) LegacyMBR_t;
-
+    EFI_GUID( 0xe6d6d379, 0xf507, 0x44c2, \
+              0xa2, 0x3c, 0x23, 0x8f, 0x2a, 0x3d, 0xf9, 0x28)
=20
+typedef struct _gpt_header {
+	u64 signature;
+	u32 revision;
+	u32 header_size;
+	u32 header_crc32;
+	u32 reserved1;
+	u64 my_lba;
+	u64 alternate_lba;
+	u64 first_usable_lba;
+	u64 last_usable_lba;
+	efi_guid_t disk_guid;
+	u64 partition_entry_lba;
+	u32 num_partition_entries;
+	u32 sizeof_partition_entry;
+	u32 partition_entry_array_crc32;
+	u8 reserved2[GPT_BLOCK_SIZE - 92];
+} __attribute__ ((packed)) gpt_header;
+
+typedef struct _gpt_entry_attributes {
+	u64 required_to_function:1;
+	u64 reserved:47;
+        u64 type_guid_specific:16;
+} __attribute__ ((packed)) gpt_entry_attributes;
+
+typedef struct _gpt_entry {
+	efi_guid_t partition_type_guid;
+	efi_guid_t unique_partition_guid;
+	u64 starting_lba;
+	u64 ending_lba;
+	gpt_entry_attributes attributes;
+	efi_char16_t partition_name[72 / sizeof (efi_char16_t)];
+} __attribute__ ((packed)) gpt_entry;
+
+typedef struct _legacy_mbr {
+	u8 boot_code[440];
+	u32 unique_mbr_signature;
+	u16 unknown;
+	struct partition partition_record[4];
+	u16 signature;
+} __attribute__ ((packed)) legacy_mbr;
=20
 /* Functions */
 extern int
-efi_partition(struct gendisk *hd, struct block_device *bdev,
+ efi_partition(struct gendisk *hd, struct block_device *bdev,
 	      unsigned long first_sector, int first_part_minor);
-
-
-
=20
 #endif
=20
diff -urN linux-davidm/fs/partitions/msdos.c lia64-2.4/fs/partitions/msdos.c
--- linux-davidm/fs/partitions/msdos.c	Wed Apr 10 13:24:38 2002
+++ lia64-2.4/fs/partitions/msdos.c	Thu Mar 28 16:11:09 2002
@@ -35,10 +35,7 @@
=20
 #include "check.h"
 #include "msdos.h"
-
-#ifdef CONFIG_EFI_PARTITION
 #include "efi.h"
-#endif
=20
 #if CONFIG_BLK_DEV_MD
 extern void md_autodetect_dev(kdev_t dev);
diff -urN linux-davidm/include/asm-ia64/acpi-ext.h lia64-2.4/include/asm-ia=
64/acpi-ext.h
--- linux-davidm/include/asm-ia64/acpi-ext.h	Wed Apr 10 13:24:38 2002
+++ lia64-2.4/include/asm-ia64/acpi-ext.h	Wed Apr 10 11:13:58 2002
@@ -1,323 +0,0 @@
-#ifndef _ASM_IA64_ACPI_EXT_H
-#define _ASM_IA64_ACPI_EXT_H
-
-/*
- * Advanced Configuration and Power Infterface
- * Based on 'ACPI Specification 1.0b' Febryary 2, 1999
- * and 'IA-64 Extensions to the ACPI Specification' Rev 0.6
- *
- * Copyright (C) 1999 VA Linux Systems
- * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
- * Copyright (C) 2000 Intel Corp.
- * Copyright (C) 2000,2001 J.I. Lee <jung-ik.lee@intel.com>
- *	ACPI 2.0 specification
- */
-
-#include <linux/config.h>
-#include <linux/types.h>
-#include <linux/mm.h>
-
-#pragma	pack(1)
-#define ACPI_RSDP_SIG "RSD PTR " /* Trailing space required */
-#define ACPI_RSDP_SIG_LEN 8
-typedef struct {
-	char signature[8];
-	u8 checksum;
-	char oem_id[6];
-	u8 revision;
-	u32 rsdt;
-	u32 length;
-	struct acpi_xsdt *xsdt;
-	u8 ext_checksum;
-	u8 reserved[3];
-} acpi20_rsdp_t;
-
-typedef struct {
-	char signature[4];
-	u32 length;
-	u8 revision;
-	u8 checksum;
-	char oem_id[6];
-	char oem_table_id[8];
-	u32 oem_revision;
-	u32 creator_id;
-	u32 creator_revision;
-} acpi_desc_table_hdr_t;
-
-#define ACPI_RSDT_SIG "RSDT"
-#define ACPI_RSDT_SIG_LEN 4
-typedef struct {
-	acpi_desc_table_hdr_t header;
-	u8 reserved[4];
-	u32 entry_ptrs[1];	/* Not really . . . */
-} acpi20_rsdt_t;
-
-#define ACPI_XSDT_SIG "XSDT"
-#define ACPI_XSDT_SIG_LEN 4
-typedef struct acpi_xsdt {
-	acpi_desc_table_hdr_t header;
-	unsigned long entry_ptrs[1];	/* Not really . . . */
-} acpi_xsdt_t;
-
-/* Common structures for ACPI 2.0 and 0.71 */
-
-typedef struct acpi_entry_iosapic {
-	u8 type;
-	u8 length;
-	u8 id;
-	u8 reserved;
-	u32 irq_base;	/* start of IRQ's this IOSAPIC is responsible for. */
-	unsigned long address;	/* Address of this IOSAPIC */
-} acpi_entry_iosapic_t;
-
-/* Local SAPIC flags */
-#define LSAPIC_ENABLED                (1<<0)
-#define LSAPIC_PERFORMANCE_RESTRICTED (1<<1)
-#define LSAPIC_PRESENT                (1<<2)
-
-/* Defines legacy IRQ->pin mapping */
-typedef struct {
-	u8 type;
-	u8 length;
-	u8 bus;		/* Constant 0 =3D ISA */
-	u8 isa_irq;	/* ISA IRQ # */
-	u32 pin;		/* called vector in spec; really IOSAPIC pin number */
-	u16 flags;	/* Edge/Level trigger & High/Low active */
-} acpi_entry_int_override_t;
-
-#define INT_OVERRIDE_ACTIVE_LOW    0x03
-#define INT_OVERRIDE_LEVEL_TRIGGER 0x0d
-
-/* IA64 ext 0.71 */
-
-typedef struct {
-	char signature[8];
-	u8 checksum;
-	char oem_id[6];
-	char reserved;		/* Must be 0 */
-	struct acpi_rsdt *rsdt;
-} acpi_rsdp_t;
-
-typedef struct acpi_rsdt {
-	acpi_desc_table_hdr_t header;
-	u8 reserved[4];
-	unsigned long entry_ptrs[1];	/* Not really . . . */
-} acpi_rsdt_t;
-
-#define ACPI_SAPIC_SIG "SPIC"
-#define ACPI_SAPIC_SIG_LEN 4
-typedef struct {
-	acpi_desc_table_hdr_t header;
-	u8 reserved[4];
-	unsigned long interrupt_block;
-} acpi_sapic_t;
-
-/* SAPIC structure types */
-#define ACPI_ENTRY_LOCAL_SAPIC         0
-#define ACPI_ENTRY_IO_SAPIC            1
-#define ACPI_ENTRY_INT_SRC_OVERRIDE    2
-#define ACPI_ENTRY_PLATFORM_INT_SOURCE 3	/* Unimplemented */
-
-typedef struct acpi_entry_lsapic {
-	u8 type;
-	u8 length;
-	u16 acpi_processor_id;
-	u16 flags;
-	u8 id;
-	u8 eid;
-} acpi_entry_lsapic_t;
-
-typedef struct {
-	u8 type;
-	u8 length;
-	u16 flags;
-	u8 int_type;
-	u8 id;
-	u8 eid;
-	u8 iosapic_vector;
-	u8 reserved[4];
-	u32 global_vector;
-} acpi_entry_platform_src_t;
-
-/* ACPI 2.0 with 1.3 errata specific structures */
-
-#define ACPI_MADT_SIG "APIC"
-#define ACPI_MADT_SIG_LEN 4
-typedef struct {
-	acpi_desc_table_hdr_t header;
-	u32 lapic_address;
-	u32 flags;
-} acpi_madt_t;
-
-/* acpi 2.0 MADT flags */
-#define MADT_PCAT_COMPAT	(1<<0)
-
-/* acpi 2.0 MADT structure types */
-#define ACPI20_ENTRY_LOCAL_APIC			0
-#define ACPI20_ENTRY_IO_APIC			1
-#define ACPI20_ENTRY_INT_SRC_OVERRIDE		2
-#define ACPI20_ENTRY_NMI_SOURCE			3
-#define ACPI20_ENTRY_LOCAL_APIC_NMI		4
-#define ACPI20_ENTRY_LOCAL_APIC_ADDR_OVERRIDE	5
-#define ACPI20_ENTRY_IO_SAPIC			6
-#define ACPI20_ENTRY_LOCAL_SAPIC		7
-#define ACPI20_ENTRY_PLATFORM_INT_SOURCE	8
-
-typedef struct acpi20_entry_lsapic {
-	u8 type;
-	u8 length;
-	u8 acpi_processor_id;
-	u8 id;
-	u8 eid;
-	u8 reserved[3];
-	u32 flags;
-} acpi20_entry_lsapic_t;
-
-typedef struct acpi20_entry_lapic_addr_override {
-	u8 type;
-	u8 length;
-	u8 reserved[2];
-	unsigned long lapic_address;
-} acpi20_entry_lapic_addr_override_t;
-
-typedef struct {
-	u8 type;
-	u8 length;
-	u16 flags;
-	u8 int_type;
-	u8 id;
-	u8 eid;
-	u8 iosapic_vector;
-	u32 global_vector;
-} acpi20_entry_platform_src_t;
-
-/* constants for interrupt routing API for device drivers */
-#define ACPI20_ENTRY_PIS_PMI	1
-#define ACPI20_ENTRY_PIS_INIT	2
-#define ACPI20_ENTRY_PIS_CPEI	3
-#define ACPI_MAX_PLATFORM_IRQS	4
-
-#define ACPI_SPCRT_SIG	"SPCR"
-#define ACPI_SPCRT_SIG_LEN 4
-
-#define ACPI_DBGPT_SIG	"DBGP"
-#define ACPI_DBGPT_SIG_LEN 4
-
-extern int acpi20_parse(acpi20_rsdp_t *);
-extern int acpi20_early_parse(acpi20_rsdp_t *);
-extern int acpi_parse(acpi_rsdp_t *);
-extern const char *acpi_get_sysname (void);
-extern int acpi_request_vector(u32 int_type);
-extern void (*acpi_idle) (void);	/* power-management idle function, if any=
 */
-#ifdef CONFIG_NUMA
-extern cnodeid_t paddr_to_nid(unsigned long paddr);
-#endif
-
-/*
- * ACPI 2.0 SRAT Table
- * http://www.microsoft.com/HWDEV/design/SRAT.htm
- */
-
-typedef struct acpi_srat {
-	acpi_desc_table_hdr_t header;
-	u32 table_revision;
-	u64 reserved;
-} acpi_srat_t;
-
-typedef struct srat_cpu_affinity {
-	u8 type;
-	u8 length;
-	u8 proximity_domain;
-	u8 apic_id;
-	u32 flags;
-	u8 local_sapic_eid;
-	u8 reserved[7];
-} srat_cpu_affinity_t;
-
-typedef struct srat_memory_affinity {
-	u8 type;
-	u8 length;
-	u8 proximity_domain;
-	u8 reserved[5];
-	u32 base_addr_lo;
-	u32 base_addr_hi;
-	u32 length_lo;
-	u32 length_hi;
-	u32 memory_type;
-	u32 flags;
-	u64 reserved2;
-} srat_memory_affinity_t;
-
-/* ACPI 2.0 SRAT structure */
-#define ACPI_SRAT_SIG "SRAT"
-#define ACPI_SRAT_SIG_LEN 4
-#define ACPI_SRAT_REVISION 1
-
-#define SRAT_CPU_STRUCTURE		0
-#define SRAT_MEMORY_STRUCTURE		1
-
-/* Only 1 flag for cpu affinity structure! */
-#define SRAT_CPU_FLAGS_ENABLED			0x00000001
-
-#define SRAT_MEMORY_FLAGS_ENABLED		0x00000001
-#define SRAT_MEMORY_FLAGS_HOTREMOVABLE		0x00000002
-
-/* ACPI 2.0 address range types */
-#define ACPI_ADDRESS_RANGE_MEMORY	1
-#define ACPI_ADDRESS_RANGE_RESERVED	2
-#define ACPI_ADDRESS_RANGE_ACPI		3
-#define ACPI_ADDRESS_RANGE_NVS		4
-
-#define NODE_ARRAY_INDEX(x)	((x) / 8)	/* 8 bits/char */
-#define NODE_ARRAY_OFFSET(x)	((x) % 8)	/* 8 bits/char */
-#define MAX_PXM_DOMAINS		(256)
-
-#ifdef CONFIG_DISCONTIGMEM
-/*
- * List of node memory chunks. Filled when parsing SRAT table to
- * obtain information about memory nodes.
-*/
-
-struct node_memory_chunk_s {
-	unsigned long start_paddr;
-	unsigned long size;
-	int pxm;			// proximity domain of node
-	int nid;			// which cnode contains this chunk?
-	int bank;			// which mem bank on this node
-};
-
-extern struct node_memory_chunk_s node_memory_chunk[PLAT_MAXCLUMPS];	// te=
mporary?
-
-struct node_cpuid_s {
-	u16	phys_id;		/* id << 8 | eid */
-	int	pxm;			// proximity domain of cpu
-	int	nid;
-};
-extern struct node_cpuid_s node_cpuid[NR_CPUS];
-
-extern int pxm_to_nid_map[MAX_PXM_DOMAINS]; /* _PXM to logical node ID map=
 */
-extern int nid_to_pxm_map[PLAT_MAX_COMPACT_NODES]; /* logical node ID to _=
PXM map */
-extern int numnodes;			/* total number of nodes in system */
-extern int num_memory_chunks;		/* total number of memory chunks */
-
-/*
- * ACPI 2.0 SLIT Table
- * http://devresource.hp.com/devresource/Docs/TechPapers/IA64/slit.pdf
- */
-
-typedef struct acpi_slit {
-	acpi_desc_table_hdr_t header;
-	u64 localities;
-	u8 entries[1];			/* dummy, real size =3D locality^2 */
-} acpi_slit_t;
-
-extern u8 acpi20_slit[PLAT_MAX_COMPACT_NODES * PLAT_MAX_COMPACT_NODES];
-
-#define ACPI_SLIT_SIG "SLIT"
-#define ACPI_SLIT_SIG_LEN 4
-#define ACPI_SLIT_REVISION 1
-#define ACPI_SLIT_LOCAL 10
-#endif /* CONFIG_DISCONTIGMEM */
-
-#pragma	pack()
-#endif /* _ASM_IA64_ACPI_EXT_H */
diff -urN linux-davidm/include/asm-ia64/acpi.h lia64-2.4/include/asm-ia64/a=
cpi.h
--- linux-davidm/include/asm-ia64/acpi.h	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/include/asm-ia64/acpi.h	Wed Apr 10 10:11:03 2002
@@ -0,0 +1,49 @@
+/*
+ *  asm-ia64/acpi.h
+ *
+ *  Copyright (C) 1999 VA Linux Systems
+ *  Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
+ *  Copyright (C) 2000,2001 J.I. Lee <jung-ik.lee@intel.com>
+ *  Copyright (C) 2001,2002 Paul Diefenbaugh <paul.s.diefenbaugh@intel.com>
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=
~~~
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
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=
~~~
+ */
+
+#ifndef _ASM_ACPI_H
+#define _ASM_ACPI_H
+
+#ifdef __KERNEL__
+
+#define __acpi_map_table(phys_addr, size) __va(phys_addr)
+
+int acpi_boot_init (char *cdline);
+int acpi_find_rsdp (unsigned long *phys_addr);
+int acpi_request_vector (u32 int_type);
+int acpi_get_prt (struct pci_vector_struct **vectors, int *count);
+int acpi_get_interrupt_model(int *type);
+
+#ifdef CONFIG_DISCONTIGMEM
+#define NODE_ARRAY_INDEX(x)	((x) / 8)	/* 8 bits/char */
+#define NODE_ARRAY_OFFSET(x)	((x) % 8)	/* 8 bits/char */
+#define MAX_PXM_DOMAINS		(256)
+#endif /* CONFIG_DISCONTIGMEM */
+
+#endif /*__KERNEL__*/
+
+#endif /*_ASM_ACPI_H*/
diff -urN linux-davidm/include/asm-ia64/acpikcfg.h lia64-2.4/include/asm-ia=
64/acpikcfg.h
--- linux-davidm/include/asm-ia64/acpikcfg.h	Tue Jul 31 10:30:09 2001
+++ lia64-2.4/include/asm-ia64/acpikcfg.h	Wed Apr 10 11:13:58 2002
@@ -1,30 +0,0 @@
-#ifndef _ASM_IA64_ACPIKCFG_H
-#define _ASM_IA64_ACPIKCFG_H
-
-/*
- *  acpikcfg.h - ACPI based Kernel Configuration Manager External Interfac=
es
- *
- *  Copyright (C) 2000 Intel Corp.
- *  Copyright (C) 2000 J.I. Lee  <jung-ik.lee@intel.com>
- */
-
-
-u32	__init acpi_cf_init (void * rsdp);
-u32	__init acpi_cf_terminate (void );
-
-u32	__init
-acpi_cf_get_pci_vectors (
-	struct pci_vector_struct	**vectors,
-	int				*num_pci_vectors
-	);
-
-
-#ifdef	CONFIG_ACPI_KERNEL_CONFIG_DEBUG
-void	__init
-acpi_cf_print_pci_vectors (
-	struct pci_vector_struct	*vectors,
-	int				num_pci_vectors
-	);
-#endif
-
-#endif /* _ASM_IA64_ACPIKCFG_H */
diff -urN linux-davidm/include/asm-ia64/cache.h lia64-2.4/include/asm-ia64/=
cache.h
--- linux-davidm/include/asm-ia64/cache.h	Thu Apr  5 12:51:47 2001
+++ lia64-2.4/include/asm-ia64/cache.h	Wed Apr 10 11:16:58 2002
@@ -5,7 +5,7 @@
=20
 /*
  * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 /* Bytes per L1 (data) cache line.  */
diff -urN linux-davidm/include/asm-ia64/current.h lia64-2.4/include/asm-ia6=
4/current.h
--- linux-davidm/include/asm-ia64/current.h	Fri Apr 21 15:21:24 2000
+++ lia64-2.4/include/asm-ia64/current.h	Thu Mar  7 14:24:32 2002
@@ -3,7 +3,7 @@
=20
 /*
  * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 /* In kernel mode, thread pointer (r13) is used to point to the
diff -urN linux-davidm/include/asm-ia64/efi.h lia64-2.4/include/asm-ia64/ef=
i.h
--- linux-davidm/include/asm-ia64/efi.h	Tue Jul 31 10:30:09 2001
+++ lia64-2.4/include/asm-ia64/efi.h	Wed Apr 10 11:31:50 2002
@@ -32,13 +32,18 @@
 typedef u8 efi_bool_t;
 typedef u16 efi_char16_t;		/* UNICODE character */
=20
+
 typedef struct {
-	u32 data1;
-	u16 data2;
-	u16 data3;
-	u8 data4[8];
+	u8 b[16];
 } efi_guid_t;
=20
+#define EFI_GUID(a,b,c,d0,d1,d2,d3,d4,d5,d6,d7) \
+((efi_guid_t) \
+{{ (a) & 0xff, ((a) >> 8) & 0xff, ((a) >> 16) & 0xff, ((a) >> 24) & 0xff, \
+  (b) & 0xff, ((b) >> 8) & 0xff, \
+  (c) & 0xff, ((c) >> 8) & 0xff, \
+  (d0), (d1), (d2), (d3), (d4), (d5), (d6), (d7) }})
+
 /*
  * Generic EFI table header
  */
@@ -82,6 +87,8 @@
 #define EFI_MEMORY_RUNTIME	0x8000000000000000	/* range requires runtime ma=
pping */
 #define EFI_MEMORY_DESCRIPTOR_VERSION	1
=20
+#define EFI_PAGE_SHIFT		12
+
 typedef struct {
 	u32 type;
 	u32 pad;
@@ -165,21 +172,23 @@
 /*
  *  EFI Configuration Table and GUID definitions
  */
+#define NULL_GUID \
+    EFI_GUID(  0x00000000, 0x0000, 0x0000, 0x00, 0x00, 0x00, 0x00, 0x00, 0=
x00, 0x00, 0x00 )
=20
 #define MPS_TABLE_GUID    \
-    ((efi_guid_t) { 0xeb9d2d2f, 0x2d88, 0x11d3, { 0x9a, 0x16, 0x0, 0x90, 0=
x27, 0x3f, 0xc1, 0x4d }})
+    EFI_GUID(  0xeb9d2d2f, 0x2d88, 0x11d3, 0x9a, 0x16, 0x0, 0x90, 0x27, 0x=
3f, 0xc1, 0x4d )
=20
 #define ACPI_TABLE_GUID    \
-    ((efi_guid_t) { 0xeb9d2d30, 0x2d88, 0x11d3, { 0x9a, 0x16, 0x0, 0x90, 0=
x27, 0x3f, 0xc1, 0x4d }})
+    EFI_GUID(  0xeb9d2d30, 0x2d88, 0x11d3, 0x9a, 0x16, 0x0, 0x90, 0x27, 0x=
3f, 0xc1, 0x4d )
=20
 #define ACPI_20_TABLE_GUID    \
-    ((efi_guid_t) { 0x8868e871, 0xe4f1, 0x11d3, { 0xbc, 0x22, 0x0, 0x80, 0=
xc7, 0x3c, 0x88, 0x81 }})
+    EFI_GUID(  0x8868e871, 0xe4f1, 0x11d3, 0xbc, 0x22, 0x0, 0x80, 0xc7, 0x=
3c, 0x88, 0x81 )
=20
 #define SMBIOS_TABLE_GUID    \
-    ((efi_guid_t) { 0xeb9d2d31, 0x2d88, 0x11d3, { 0x9a, 0x16, 0x0, 0x90, 0=
x27, 0x3f, 0xc1, 0x4d }})
+    EFI_GUID(  0xeb9d2d31, 0x2d88, 0x11d3, 0x9a, 0x16, 0x0, 0x90, 0x27, 0x=
3f, 0xc1, 0x4d )
=20
 #define SAL_SYSTEM_TABLE_GUID    \
-    ((efi_guid_t) { 0xeb9d2d32, 0x2d88, 0x11d3, { 0x9a, 0x16, 0x0, 0x90, 0=
x27, 0x3f, 0xc1, 0x4d }})
+    EFI_GUID(  0xeb9d2d32, 0x2d88, 0x11d3, 0x9a, 0x16, 0x0, 0x90, 0x27, 0x=
3f, 0xc1, 0x4d )
=20
 typedef struct {
 	efi_guid_t guid;
@@ -233,12 +242,24 @@
 	return memcmp(&left, &right, sizeof (efi_guid_t));
 }
=20
+static inline char *
+efi_guid_unparse(efi_guid_t *guid, char *out)
+{
+	sprintf(out, "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02=
x%02x%02x",
+		guid->b[3], guid->b[2], guid->b[1], guid->b[0],
+		guid->b[5], guid->b[4], guid->b[7], guid->b[6],
+		guid->b[8], guid->b[9], guid->b[10], guid->b[11],
+		guid->b[12], guid->b[13], guid->b[14], guid->b[15]);
+        return out;
+}
+
 extern void efi_init (void);
 extern void efi_map_pal_code (void);
 extern void efi_memmap_walk (efi_freemem_callback_t callback, void *arg);
 extern void efi_gettimeofday (struct timeval *tv);
 extern void efi_enter_virtual_mode (void);	/* switch EFI to virtual mode, =
if possible */
 extern u64  efi_get_iobase (void);
+extern u32  efi_mem_type (u64 phys_addr);
=20
 /*
  * Variable Attributes
diff -urN linux-davidm/include/asm-ia64/hw_irq.h lia64-2.4/include/asm-ia64=
/hw_irq.h
--- linux-davidm/include/asm-ia64/hw_irq.h	Tue Jul 31 10:30:09 2001
+++ lia64-2.4/include/asm-ia64/hw_irq.h	Wed Apr 10 11:16:59 2002
@@ -88,6 +88,7 @@
=20
 extern struct irq_desc _irq_desc[NR_IRQS];
=20
+#ifndef CONFIG_IA64_GENERIC
 static inline struct irq_desc *
 __ia64_irq_desc (unsigned int irq)
 {
@@ -105,6 +106,7 @@
 {
 	return (unsigned int) vec;
 }
+#endif
=20
 /*
  * Next follows the irq descriptor interface.  On IA-64, each CPU supports=
 256 interrupt
diff -urN linux-davidm/include/asm-ia64/machvec.h lia64-2.4/include/asm-ia6=
4/machvec.h
--- linux-davidm/include/asm-ia64/machvec.h	Wed Apr 10 13:24:38 2002
+++ lia64-2.4/include/asm-ia64/machvec.h	Wed Apr 10 11:16:58 2002
@@ -67,6 +67,8 @@
 #  include <asm/machvec_hpsim.h>
 # elif defined (CONFIG_IA64_DIG)
 #  include <asm/machvec_dig.h>
+# elif defined (CONFIG_IA64_HP_ZX1)
+#  include <asm/machvec_hpzx1.h>
 # elif defined (CONFIG_IA64_SGI_SN1)
 #  include <asm/machvec_sn1.h>
 # elif defined (CONFIG_IA64_SGI_SN2)
@@ -121,6 +123,7 @@
 	ia64_mv_cmci_handler_t *cmci_handler;
 	ia64_mv_log_print_t *log_print;
 	ia64_mv_send_ipi_t *send_ipi;
+	ia64_mv_global_tlb_purge_t *global_tlb_purge;
 	ia64_mv_pci_dma_init *dma_init;
 	ia64_mv_pci_alloc_consistent *alloc_consistent;
 	ia64_mv_pci_free_consistent *free_consistent;
@@ -146,6 +149,7 @@
 {						\
 	#name,					\
 	platform_setup,				\
+	platform_cpu_init,			\
 	platform_irq_init,			\
 	platform_pci_fixup,			\
 	platform_map_nr,			\
diff -urN linux-davidm/include/asm-ia64/machvec_hpzx1.h lia64-2.4/include/a=
sm-ia64/machvec_hpzx1.h
--- linux-davidm/include/asm-ia64/machvec_hpzx1.h	Wed Dec 31 16:00:00 1969
+++ lia64-2.4/include/asm-ia64/machvec_hpzx1.h	Fri Apr  5 16:44:44 2002
@@ -0,0 +1,37 @@
+#ifndef _ASM_IA64_MACHVEC_HPZX1_h
+#define _ASM_IA64_MACHVEC_HPZX1_h
+
+extern ia64_mv_setup_t dig_setup;
+extern ia64_mv_pci_fixup_t hpzx1_pci_fixup;
+extern ia64_mv_map_nr_t map_nr_dense;
+extern ia64_mv_pci_alloc_consistent sba_alloc_consistent;
+extern ia64_mv_pci_free_consistent sba_free_consistent;
+extern ia64_mv_pci_map_single sba_map_single;
+extern ia64_mv_pci_unmap_single sba_unmap_single;
+extern ia64_mv_pci_map_sg sba_map_sg;
+extern ia64_mv_pci_unmap_sg sba_unmap_sg;
+extern ia64_mv_pci_dma_address sba_dma_address;
+
+/*
+ * This stuff has dual use!
+ *
+ * For a generic kernel, the macros are used to initialize the
+ * platform's machvec structure.  When compiling a non-generic kernel,
+ * the macros are used directly.
+ */
+#define platform_name			"hpzx1"
+#define platform_setup			dig_setup
+#define platform_pci_fixup		hpzx1_pci_fixup
+#define platform_map_nr			map_nr_dense
+#define platform_pci_dma_init		((ia64_mv_pci_dma_init *) machvec_noop)
+#define platform_pci_alloc_consistent	sba_alloc_consistent
+#define platform_pci_free_consistent	sba_free_consistent
+#define platform_pci_map_single		sba_map_single
+#define platform_pci_unmap_single	sba_unmap_single
+#define platform_pci_map_sg		sba_map_sg
+#define platform_pci_unmap_sg		sba_unmap_sg
+#define platform_pci_dma_sync_single	((ia64_mv_pci_dma_sync_single *) mach=
vec_noop)
+#define platform_pci_dma_sync_sg	((ia64_mv_pci_dma_sync_sg *) machvec_noop)
+#define platform_pci_dma_address	sba_dma_address
+
+#endif /* _ASM_IA64_MACHVEC_HPZX1_h */
diff -urN linux-davidm/include/asm-ia64/machvec_init.h lia64-2.4/include/as=
m-ia64/machvec_init.h
--- linux-davidm/include/asm-ia64/machvec_init.h	Thu Jan  4 12:50:17 2001
+++ lia64-2.4/include/asm-ia64/machvec_init.h	Fri Apr  5 16:44:44 2002
@@ -5,6 +5,11 @@
 #include <asm/machvec.h>
=20
 extern ia64_mv_send_ipi_t ia64_send_ipi;
+extern ia64_mv_global_tlb_purge_t ia64_global_tlb_purge;
+extern ia64_mv_irq_desc __ia64_irq_desc;
+extern ia64_mv_irq_to_vector __ia64_irq_to_vector;
+extern ia64_mv_local_vector_to_irq __ia64_local_vector_to_irq;
+
 extern ia64_mv_inb_t __ia64_inb;
 extern ia64_mv_inw_t __ia64_inw;
 extern ia64_mv_inl_t __ia64_inl;
diff -urN linux-davidm/include/asm-ia64/module.h lia64-2.4/include/asm-ia64=
/module.h
--- linux-davidm/include/asm-ia64/module.h	Mon Nov 26 11:19:18 2001
+++ lia64-2.4/include/asm-ia64/module.h	Wed Apr 10 11:26:00 2002
@@ -51,6 +51,9 @@
 		return 0;
 	archdata =3D (struct archdata *)(mod->archdata_start);
=20
+	if (archdata->unw_start =3D 0)
+		return 0;
+
 	/*
 	 * Make sure the unwind pointers are sane.
 	 */
diff -urN linux-davidm/include/asm-ia64/pci.h lia64-2.4/include/asm-ia64/pc=
i.h
--- linux-davidm/include/asm-ia64/pci.h	Wed Apr 10 13:24:38 2002
+++ lia64-2.4/include/asm-ia64/pci.h	Wed Apr 10 11:17:20 2002
@@ -19,6 +19,11 @@
 #define PCIBIOS_MIN_IO		0x1000
 #define PCIBIOS_MIN_MEM		0x10000000
=20
+void pcibios_config_init(void);
+struct pci_bus * pcibios_scan_root(int seg, int bus);
+extern int (*pci_config_read)(int seg, int bus, int dev, int fn, int reg, =
int len, u32 *value);
+extern int (*pci_config_write)(int seg, int bus, int dev, int fn, int reg,=
 int len, u32 value);
+
 struct pci_dev;
=20
 static inline void
diff -urN linux-davidm/include/asm-ia64/pgalloc.h lia64-2.4/include/asm-ia6=
4/pgalloc.h
--- linux-davidm/include/asm-ia64/pgalloc.h	Mon Nov 26 11:19:18 2001
+++ lia64-2.4/include/asm-ia64/pgalloc.h	Wed Apr 10 11:17:12 2002
@@ -220,6 +220,7 @@
 #define flush_cache_range(mm, start, end)	do { } while (0)
 #define flush_cache_page(vma, vmaddr)		do { } while (0)
 #define flush_page_to_ram(page)			do { } while (0)
+#define flush_icache_page(vma,pg)		do { } while (0)
=20
 extern void flush_icache_range (unsigned long start, unsigned long end);
=20
diff -urN linux-davidm/include/asm-ia64/sal.h lia64-2.4/include/asm-ia64/sa=
l.h
--- linux-davidm/include/asm-ia64/sal.h	Wed Apr 10 13:24:39 2002
+++ lia64-2.4/include/asm-ia64/sal.h	Wed Apr 10 11:32:08 2002
@@ -241,32 +241,32 @@
=20
 /* SAL Error Record Section GUID Definitions */
 #define SAL_PROC_DEV_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf1, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    EFI_GUID ( 0xe429faf1, 0x3cb7, 0x11d4,  0xbc, 0xa7, 0x0, 0x80, \
+                    0xc7, 0x3c, 0x88, 0x81 )
 #define SAL_PLAT_MEM_DEV_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf2, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    EFI_GUID(  0xe429faf2, 0x3cb7, 0x11d4,  0xbc, 0xa7, 0x0, 0x80, \
+                    0xc7, 0x3c, 0x88, 0x81 )
 #define SAL_PLAT_SEL_DEV_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf3, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    EFI_GUID(  0xe429faf3, 0x3cb7, 0x11d4, 0xbc, 0xa7, 0x0, 0x80, \
+                    0xc7, 0x3c, 0x88, 0x81 )
 #define SAL_PLAT_PCI_BUS_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf4, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    EFI_GUID(  0xe429faf4, 0x3cb7, 0x11d4, 0xbc, 0xa7, 0x0, 0x80, \
+                    0xc7, 0x3c, 0x88, 0x81 )
 #define SAL_PLAT_SMBIOS_DEV_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf5, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    EFI_GUID(  0xe429faf5, 0x3cb7, 0x11d4, 0xbc, 0xa7, 0x0, 0x80, \
+                    0xc7, 0x3c, 0x88, 0x81 )
 #define SAL_PLAT_PCI_COMP_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf6, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    EFI_GUID(  0xe429faf6, 0x3cb7, 0x11d4, 0xbc, 0xa7, 0x0, 0x80, \
+                    0xc7, 0x3c, 0x88, 0x81 )
 #define SAL_PLAT_SPECIFIC_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf7, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    EFI_GUID(  0xe429faf7, 0x3cb7, 0x11d4, 0xbc, 0xa7, 0x0, 0x80, \
+                    0xc7, 0x3c, 0x88, 0x81 )
 #define SAL_PLAT_HOST_CTLR_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf8, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    EFI_GUID(  0xe429faf8, 0x3cb7, 0x11d4, 0xbc, 0xa7, 0x0, 0x80, \
+                    0xc7, 0x3c, 0x88, 0x81 )
 #define SAL_PLAT_BUS_ERR_SECT_GUID  \
-    ((efi_guid_t) { 0xe429faf9, 0x3cb7, 0x11d4, { 0xbc, 0xa7, 0x0, 0x80, \
-                    0xc7, 0x3c, 0x88, 0x81 }} )
+    EFI_GUID(  0xe429faf9, 0x3cb7, 0x11d4, 0xbc, 0xa7, 0x0, 0x80, \
+                    0xc7, 0x3c, 0x88, 0x81 )
=20
 #define MAX_CACHE_ERRORS			6
 #define MAX_TLB_ERRORS				6
diff -urN linux-davidm/include/asm-ia64/string.h lia64-2.4/include/asm-ia64=
/string.h
--- linux-davidm/include/asm-ia64/string.h	Tue Jul 31 10:30:09 2001
+++ lia64-2.4/include/asm-ia64/string.h	Tue Apr  9 10:58:51 2002
@@ -5,8 +5,8 @@
  * Here is where we want to put optimized versions of the string
  * routines.
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2000, 2002 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <linux/config.h>	/* remove this once we remove the A-step workaro=
und... */
@@ -17,7 +17,21 @@
 #define __HAVE_ARCH_BCOPY	1 /* see arch/ia64/lib/memcpy.S */
=20
 extern __kernel_size_t strlen (const char *);
-extern void *memset (void *, int, __kernel_size_t);
 extern void *memcpy (void *, const void *, __kernel_size_t);
+
+extern void *__memset_generic (void *, int, __kernel_size_t);
+extern void __bzero (void *, __kernel_size_t);
+
+#define memset(s, c, count)				\
+({							\
+	void *_s =3D (s);					\
+	int _c =3D (c);					\
+	__kernel_size_t _count =3D (count);		\
+							\
+	if (__builtin_constant_p(_c) && _c =3D 0)	\
+		__bzero(_s, _count);			\
+	else						\
+		__memset_generic(_s, _c, _count);	\
+})
=20
 #endif /* _ASM_IA64_STRING_H */
diff -urN linux-davidm/include/asm-ia64/system.h lia64-2.4/include/asm-ia64=
/system.h
--- linux-davidm/include/asm-ia64/system.h	Wed Apr 10 13:24:47 2002
+++ lia64-2.4/include/asm-ia64/system.h	Wed Apr 10 11:16:59 2002
@@ -395,13 +395,17 @@
 } while (0)
=20
 #ifdef CONFIG_SMP
-  /*
-   * In the SMP case, we save the fph state when context-switching
-   * away from a thread that modified fph.  This way, when the thread
-   * gets scheduled on another CPU, the CPU can pick up the state from
-   * task->thread.fph, avoiding the complication of having to fetch
-   * the latest fph state from another CPU.
-   */
+
+/* Return true if this CPU can call the console drivers in printk() */
+#define arch_consoles_callable() (cpu_online_map & (1UL << smp_processor_i=
d()))
+
+/*
+ * In the SMP case, we save the fph state when context-switching
+ * away from a thread that modified fph.  This way, when the thread
+ * gets scheduled on another CPU, the CPU can pick up the state from
+ * task->thread.fph, avoiding the complication of having to fetch
+ * the latest fph state from another CPU.
+ */
 # define switch_to(prev,next,last) do {						\
 	if (ia64_psr(ia64_task_regs(prev))->mfh) {				\
 		ia64_psr(ia64_task_regs(prev))->mfh =3D 0;			\
diff -urN linux-davidm/include/asm-ia64/uaccess.h lia64-2.4/include/asm-ia6=
4/uaccess.h
--- linux-davidm/include/asm-ia64/uaccess.h	Thu Apr  5 12:51:47 2001
+++ lia64-2.4/include/asm-ia64/uaccess.h	Wed Apr 10 11:17:09 2002
@@ -320,4 +320,22 @@
 extern struct exception_fixup search_exception_table (unsigned long addr);
 extern void handle_exception (struct pt_regs *regs, struct exception_fixup=
 fixup);
=20
+#ifdef GAS_HAS_LOCAL_TAGS
+#define SEARCH_EXCEPTION_TABLE(regs) search_exception_table(regs->cr_iip +=
 ia64_psr(regs)->ri);
+#else
+#define SEARCH_EXCEPTION_TABLE(regs) search_exception_table(regs->cr_iip);
+#endif
+
+static inline int
+done_with_exception (struct pt_regs *regs)
+{
+	struct exception_fixup fix;
+	fix =3D SEARCH_EXCEPTION_TABLE(regs);
+	if (fix.cont) {
+		handle_exception(regs, fix);
+		return 1;
+	}
+	return 0;
+}
+
 #endif /* _ASM_IA64_UACCESS_H */
diff -urN linux-davidm/include/linux/acpi.h lia64-2.4/include/linux/acpi.h
--- linux-davidm/include/linux/acpi.h	Mon Sep 24 15:08:31 2001
+++ lia64-2.4/include/linux/acpi.h	Wed Apr 10 11:23:48 2002
@@ -1,180 +1,394 @@
 /*
- *  acpi.h - ACPI driver interface
+ * acpi.h - ACPI Interface
  *
- *  Copyright (C) 1999 Andrew Henroid
+ * Copyright (C) 2001 Paul Diefenbaugh <paul.s.diefenbaugh@intel.com>
  *
- *  This program is free software; you can redistribute it and/or modify
- *  it under the terms of the GNU General Public License as published by
- *  the Free Software Foundation; either version 2 of the License, or
- *  (at your option) any later version.
- *
- *  This program is distributed in the hope that it will be useful,
- *  but WITHOUT ANY WARRANTY; without even the implied warranty of
- *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- *  GNU General Public License for more details.
- *
- *  You should have received a copy of the GNU General Public License
- *  along with this program; if not, write to the Free Software
- *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=
~~~
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  U=
SA
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=
~~~
  */
=20
 #ifndef _LINUX_ACPI_H
 #define _LINUX_ACPI_H
=20
-#include <linux/types.h>
-#include <linux/ioctl.h>
-#ifdef __KERNEL__
-#include <linux/sched.h>
-#include <linux/wait.h>
-#endif /* __KERNEL__ */
+#ifndef _LINUX
+#define _LINUX
+#endif
=20
 /*
- * Device states
+ * YES this is ugly.
+ * But, moving all of ACPI's private headers to include/acpi isn't the rig=
ht
+ * answer either.
+ * Please just ignore it for now.
  */
-typedef enum {
-	ACPI_D0, /* fully-on */
-	ACPI_D1, /* partial-on */
-	ACPI_D2, /* partial-on */
-	ACPI_D3, /* fully-off */
-} acpi_dstate_t;
-
-typedef enum {
-	ACPI_S0, /* working state */
-	ACPI_S1, /* power-on suspend */
-	ACPI_S2, /* suspend to ram, with devices */
-	ACPI_S3, /* suspend to ram */
-	ACPI_S4, /* suspend to disk */
-	ACPI_S5, /* soft-off */
-} acpi_sstate_t;
-
-/* RSDP location */
-#define ACPI_BIOS_ROM_BASE (0x0e0000)
-#define ACPI_BIOS_ROM_END  (0x100000)
-
-/* Table signatures */
-#define ACPI_RSDP1_SIG 0x20445352 /* 'RSD ' */
-#define ACPI_RSDP2_SIG 0x20525450 /* 'PTR ' */
-#define ACPI_RSDT_SIG  0x54445352 /* 'RSDT' */
-#define ACPI_FADT_SIG  0x50434146 /* 'FACP' */
-#define ACPI_DSDT_SIG  0x54445344 /* 'DSDT' */
-#define ACPI_FACS_SIG  0x53434146 /* 'FACS' */
-
-#define ACPI_SIG_LEN		4
-#define ACPI_FADT_SIGNATURE	"FACP"
-
-/* PM1_STS/EN flags */
-#define ACPI_TMR    0x0001
-#define ACPI_BM	    0x0010
-#define ACPI_GBL    0x0020
-#define ACPI_PWRBTN 0x0100
-#define ACPI_SLPBTN 0x0200
-#define ACPI_RTC    0x0400
-#define ACPI_WAK    0x8000
-
-/* PM1_CNT flags */
-#define ACPI_SCI_EN   0x0001
-#define ACPI_BM_RLD   0x0002
-#define ACPI_GBL_RLS  0x0004
-#define ACPI_SLP_TYP0 0x0400
-#define ACPI_SLP_TYP1 0x0800
-#define ACPI_SLP_TYP2 0x1000
-#define ACPI_SLP_EN   0x2000
-
-#define ACPI_SLP_TYP_MASK  0x1c00
-#define ACPI_SLP_TYP_SHIFT 10
-
-/* PM_TMR masks */
-#define ACPI_TMR_VAL_EXT 0x00000100
-#define ACPI_TMR_MASK	 0x00ffffff
-#define ACPI_TMR_HZ	 3579545 /* 3.58 MHz */
-#define ACPI_TMR_KHZ	 (ACPI_TMR_HZ / 1000)
-
-#define ACPI_MICROSEC_TO_TMR_TICKS(val) \
-  (((val) * (ACPI_TMR_KHZ)) / 1000)
-
-/* PM2_CNT flags */
-#define ACPI_ARB_DIS 0x01
-
-/* FADT flags */
-#define ACPI_WBINVD	  0x00000001
-#define ACPI_WBINVD_FLUSH 0x00000002
-#define ACPI_PROC_C1	  0x00000004
-#define ACPI_P_LVL2_UP	  0x00000008
-#define ACPI_PWR_BUTTON	  0x00000010
-#define ACPI_SLP_BUTTON	  0x00000020
-#define ACPI_FIX_RTC	  0x00000040
-#define ACPI_RTC_64	  0x00000080
-#define ACPI_TMR_VAL_EXT  0x00000100
-#define ACPI_DCK_CAP	  0x00000200
-
-/* FADT BOOT_ARCH flags */
-#define FADT_BOOT_ARCH_LEGACY_DEVICES	0x0001
-#define FADT_BOOT_ARCH_KBD_CONTROLLER	0x0002
-
-/* FACS flags */
-#define ACPI_S4BIOS	  0x00000001
-
-/* processor block offsets */
-#define ACPI_P_CNT	  0x00000000
-#define ACPI_P_LVL2	  0x00000004
-#define ACPI_P_LVL3	  0x00000005
-
-/* C-state latencies (microseconds) */
-#define ACPI_MAX_P_LVL2_LAT 100
-#define ACPI_MAX_P_LVL3_LAT 1000
-#define ACPI_INFINITE_LAT   (~0UL)
+#include "../../drivers/acpi/include/acpi.h"
+#include <asm/acpi.h>
+
+
+/* -----------------------------------------------------------------------=
---
+                             Boot-Time Table Parsing
+   -----------------------------------------------------------------------=
--- */
+
+#ifdef CONFIG_ACPI_BOOT
+
+/* Root System Description Pointer (RSDP) */
+
+struct acpi_table_rsdp {
+	char			signature[8];
+	u8			checksum;
+	char			oem_id[6];
+	u8			revision;
+	u32			rsdt_address;
+} __attribute__ ((packed));
+
+struct acpi20_table_rsdp {
+	char			signature[8];
+	u8			checksum;
+	char			oem_id[6];
+	u8			revision;
+	u32			rsdt_address;
+	u32			length;
+	u64			xsdt_address;
+	u8			ext_checksum;
+	u8			reserved[3];
+} __attribute__ ((packed));
+
+/* Common table header */
+
+struct acpi_table_header {
+	char			signature[4];
+	u32			length;
+	u8			revision;
+	u8			checksum;
+	char			oem_id[6];
+	char			oem_table_id[8];
+	u32			oem_revision;
+	char			asl_compiler_id[4];
+	u32			asl_compiler_revision;
+} __attribute__ ((packed));
+
+typedef struct {
+	u8			type;
+	u8			length;
+} acpi_table_entry_header __attribute__ ((packed));
+
+/* Root System Description Table (RSDT) */
+
+struct acpi_table_rsdt {
+	struct acpi_table_header header;
+	u32			entry[1];
+} __attribute__ ((packed));
+
+/* Extended System Description Table (XSDT) */
+
+struct acpi_table_xsdt {
+	struct acpi_table_header header;
+	u64			entry[1];
+} __attribute__ ((packed));
+
+/* Multiple APIC Description Table (MADT) */
+
+struct acpi_table_madt {
+	struct acpi_table_header header;
+	u32			lapic_address;
+	struct {
+		u32			pcat_compat:1;
+		u32			reserved:31;
+	}			flags;
+} __attribute__ ((packed));
+
+enum acpi_madt_entry_id {
+	ACPI_MADT_LAPIC =3D 0,
+	ACPI_MADT_IOAPIC,
+	ACPI_MADT_INT_SRC_OVR,
+	ACPI_MADT_NMI_SRC,
+	ACPI_MADT_LAPIC_NMI,
+	ACPI_MADT_LAPIC_ADDR_OVR,
+	ACPI_MADT_IOSAPIC,
+	ACPI_MADT_LSAPIC,
+	ACPI_MADT_PLAT_INT_SRC,
+	ACPI_MADT_ENTRY_COUNT
+};
+
+typedef struct {
+	u16			polarity:2;
+	u16			trigger:2;
+	u16			reserved:12;
+} acpi_interrupt_flags __attribute__ ((packed));
+
+struct acpi_table_lapic {
+	acpi_table_entry_header	header;
+	u8			acpi_id;
+	u8			id;
+	struct {
+		u32			enabled:1;
+		u32			reserved:31;
+	}			flags;
+} __attribute__ ((packed));
+
+struct acpi_table_ioapic {
+	acpi_table_entry_header	header;
+	u8			id;
+	u8			reserved;
+	u32			address;
+	u32			global_irq_base;
+} __attribute__ ((packed));
+
+struct acpi_table_int_src_ovr {
+	acpi_table_entry_header	header;
+	u8			bus;
+	u8			bus_irq;
+	u32			global_irq;
+	acpi_interrupt_flags	flags;
+} __attribute__ ((packed));
+
+struct acpi_table_nmi_src {
+	acpi_table_entry_header	header;
+	acpi_interrupt_flags	flags;
+	u32			global_irq;
+} __attribute__ ((packed));
+
+struct acpi_table_lapic_nmi {
+	acpi_table_entry_header	header;
+	u8			acpi_id;
+	acpi_interrupt_flags	flags;
+	u8			lint;
+} __attribute__ ((packed));
+
+struct acpi_table_lapic_addr_ovr {
+	acpi_table_entry_header	header;
+	u8			reserved[2];
+	u64			address;
+} __attribute__ ((packed));
+
+struct acpi_table_iosapic {
+	acpi_table_entry_header	header;
+	u8			id;
+	u8			reserved;
+	u32			global_irq_base;
+	u64			address;
+} __attribute__ ((packed));
+
+struct acpi_table_lsapic {
+	acpi_table_entry_header	header;
+	u8			acpi_id;
+	u8			id;
+	u8			eid;
+	u8			reserved[3];
+	struct {
+		u32			enabled:1;
+		u32			reserved:31;
+	}			flags;
+} __attribute__ ((packed));
+
+struct acpi_table_plat_int_src {
+	acpi_table_entry_header	header;
+	acpi_interrupt_flags	flags;
+	u8			type;	/* See acpi_interrupt_type */
+	u8			id;
+	u8			eid;
+	u8			iosapic_vector;
+	u32			global_irq;
+	u32			reserved;
+} __attribute__ ((packed));
+
+enum acpi_interrupt_id {
+	ACPI_INTERRUPT_PMI	=3D 1,
+	ACPI_INTERRUPT_INIT,
+	ACPI_INTERRUPT_CPEI,
+	ACPI_INTERRUPT_COUNT
+};
=20
 /*
- * Sysctl declarations
+ * System Resource Affinity Table (SRAT)
+ *   see http://www.microsoft.com/hwdev/design/srat.htm
  */
=20
-enum
-{
-	CTL_ACPI =3D 10
+struct acpi_table_srat {
+	struct acpi_table_header header;
+	u32			table_revision;
+	u64			reserved;
+} __attribute__ ((packed));
+
+enum acpi_srat_entry_id {
+	ACPI_SRAT_PROCESSOR_AFFINITY =3D 0,
+	ACPI_SRAT_MEMORY_AFFINITY,
+	ACPI_SRAT_ENTRY_COUNT
+};
+
+struct acpi_table_processor_affinity {
+	acpi_table_entry_header	header;
+	u8			proximity_domain;
+	u8			apic_id;
+	struct {
+		u32			enabled:1;
+		u32			reserved:31;
+	}			flags;
+	u8			lsapic_eid;
+	u8			reserved[7];
+} __attribute__ ((packed));
+
+struct acpi_table_memory_affinity {
+	acpi_table_entry_header	header;
+	u8			proximity_domain;
+	u8			reserved1[5];
+	u32			base_addr_lo;
+	u32			base_addr_hi;
+	u32			length_lo;
+	u32			length_hi;
+	u32			memory_type;	/* See acpi_address_range_id */
+	struct {
+		u32			enabled:1;
+		u32			hot_pluggable:1;
+		u32			reserved:30;
+	}			flags;
+	u64			reserved2;
+} __attribute__ ((packed));
+
+enum acpi_address_range_id {
+	ACPI_ADDRESS_RANGE_MEMORY =3D 1,
+	ACPI_ADDRESS_RANGE_RESERVED =3D 2,
+	ACPI_ADDRESS_RANGE_ACPI =3D 3,
+	ACPI_ADDRESS_RANGE_NVS	=3D 4,
+	ACPI_ADDRESS_RANGE_COUNT
 };
=20
-enum
-{
-	ACPI_FADT =3D 1,
+/*
+ * System Locality Information Table (SLIT)
+ *   see http://devresource.hp.com/devresource/docs/techpapers/ia64/slit.p=
df
+ */
+
+struct acpi_table_slit {
+	struct acpi_table_header header;
+	u64			localities;
+	u8			entry[1];	/* real size =3D localities^2 */
+} __attribute__ ((packed));
+
+/* Smart Battery Description Table (SBST) */
+
+struct acpi_table_sbst {
+	struct acpi_table_header header;
+	u32			warning;	/* Warn user */
+	u32			low;		/* Critical sleep */
+	u32			critical;	/* Critical shutdown */
+} __attribute__ ((packed));
+
+/* Embedded Controller Boot Resources Table (ECDT) */
+
+struct acpi_table_ecdt {
+	struct acpi_table_header header;
+	acpi_generic_address	ec_control;
+	acpi_generic_address	ec_data;
+	u32			uid;
+	u8			gpe_bit;
+	char			*ec_id;
+} __attribute__ ((packed));
+
+/* Table Handlers */
+
+enum acpi_table_id {
+	ACPI_TABLE_UNKNOWN =3D 0,
+	ACPI_APIC,
+	ACPI_BOOT,
+	ACPI_DBGP,
 	ACPI_DSDT,
-	ACPI_PM1_ENABLE,
-	ACPI_GPE_ENABLE,
-	ACPI_GPE_LEVEL,
-	ACPI_EVENT,
-	ACPI_P_BLK,
-	ACPI_ENTER_LVL2_LAT,
-	ACPI_ENTER_LVL3_LAT,
-	ACPI_P_LVL2_LAT,
-	ACPI_P_LVL3_LAT,
-	ACPI_C1_TIME,
-	ACPI_C2_TIME,
-	ACPI_C3_TIME,
-	ACPI_C1_COUNT,
-	ACPI_C2_COUNT,
-	ACPI_C3_COUNT,
-	ACPI_S0_SLP_TYP,
-	ACPI_S1_SLP_TYP,
-	ACPI_S5_SLP_TYP,
-	ACPI_SLEEP,
+	ACPI_ECDT,
+	ACPI_ETDT,
+	ACPI_FACP,
 	ACPI_FACS,
-	ACPI_XSDT,
-	ACPI_PMTIMER,
-	ACPI_BATT,
+	ACPI_OEMX,
+	ACPI_PSDT,
+	ACPI_SBST,
+	ACPI_SLIT,
+	ACPI_SPCR,
+	ACPI_SRAT,
+	ACPI_SSDT,
+	ACPI_SPMI,
+	ACPI_TABLE_COUNT
 };
=20
-#define ACPI_SLP_TYP_DISABLED	(~0UL)
+typedef int (*acpi_table_handler) (unsigned long phys_addr, unsigned long =
size);
=20
-#ifdef __KERNEL__
+extern acpi_table_handler acpi_table_ops[ACPI_TABLE_COUNT];
=20
-/* routines for saving/restoring kernel state */
-FASTCALL(extern unsigned long acpi_save_state_mem(unsigned long return_poi=
nt));
-FASTCALL(extern int acpi_save_state_disk(unsigned long return_point));
-extern void acpi_restore_state(void);
+typedef int (*acpi_madt_entry_handler) (acpi_table_entry_header *header);
=20
-extern unsigned long acpi_wakeup_address;
+struct acpi_boot_flags {
+	u8		madt:1;
+	u8		reserved:7;
+};
+
+int acpi_table_init (char *cmdline);
+int acpi_table_parse (enum acpi_table_id, acpi_table_handler);
+int acpi_table_parse_madt (enum acpi_table_id, acpi_madt_entry_handler);
+void acpi_table_print (struct acpi_table_header *, unsigned long);
+void acpi_table_print_madt_entry (acpi_table_entry_header *);
+
+#endif /*CONFIG_ACPI_BOOT*/
+
+
+/* -----------------------------------------------------------------------=
---
+                           PCI Interrupt Routing (PRT)
+   -----------------------------------------------------------------------=
--- */
+
+#ifdef CONFIG_ACPI_PCI
+
+#define ACPI_INT_MODEL_PIC	0
+#define ACPI_INT_MODEL_IOAPIC	1
+#define ACPI_INT_MODEL_IOSAPIC	2
+
+struct acpi_prt_entry {
+	struct list_head	node;
+	struct {
+		u8			seg;
+		u8			bus;
+		u8			dev;
+		u8			pin;
+	}			id;
+	struct {
+		acpi_handle		handle;
+		u32			index;
+	}			source;
+};
+
+struct acpi_prt_list {
+	int			count;
+	struct list_head	entries;
+};
+
+extern struct acpi_prt_list	acpi_prts;
+
+struct pci_dev;
=20
-#endif /* __KERNEL__ */
+int acpi_prt_get_irq (struct pci_dev *dev, u8 pin, int *irq);
+int acpi_prt_set_irq (struct pci_dev *dev, u8 pin, int irq);
+
+#endif /*CONFIG_ACPI_PCI*/
+
+
+/* -----------------------------------------------------------------------=
---
+                            ACPI Interpreter (Core)
+   -----------------------------------------------------------------------=
--- */
+
+#ifdef CONFIG_ACPI_INTERPRETER
=20
 int acpi_init(void);
=20
-#endif /* _LINUX_ACPI_H */
+#endif /*CONFIG_ACPI_INTERPRETER*/
+
+
+#endif /*_LINUX_ACPI_H*/
diff -urN linux-davidm/include/linux/acpi_serial.h lia64-2.4/include/linux/=
acpi_serial.h
--- linux-davidm/include/linux/acpi_serial.h	Mon Nov 26 11:19:19 2001
+++ lia64-2.4/include/linux/acpi_serial.h	Wed Apr 10 11:42:26 2002
@@ -11,6 +11,8 @@
=20
 extern void setup_serial_acpi(void *);
=20
+#define ACPI_SIG_LEN		4
+
 /* ACPI table signatures */
 #define ACPI_SPCRT_SIGNATURE	"SPCR"
 #define ACPI_DBGPT_SIGNATURE	"DBGP"
diff -urN linux-davidm/include/linux/crc32.h lia64-2.4/include/linux/crc32.h
--- linux-davidm/include/linux/crc32.h	Wed Apr 10 13:24:47 2002
+++ lia64-2.4/include/linux/crc32.h	Wed Dec 31 16:00:00 1969
@@ -1,17 +0,0 @@
-/*
- * crc32.h
- * See linux/lib/crc32.c for license and changes
- */
-#ifndef _LINUX_CRC32_H
-#define _LINUX_CRC32_H
-
-#include <linux/types.h>
-
-/*
- * This computes a 32 bit CRC of the data in the buffer, and returns the C=
RC.
- * The polynomial used is 0xedb88320.
- */
-
-extern u32 crc32 (const void *buf, unsigned long len, u32 seed);
-
-#endif /* _LINUX_CRC32_H */
diff -urN linux-davidm/include/linux/devfs_fs_kernel.h lia64-2.4/include/li=
nux/devfs_fs_kernel.h
--- linux-davidm/include/linux/devfs_fs_kernel.h	Wed Apr 10 13:24:47 2002
+++ lia64-2.4/include/linux/devfs_fs_kernel.h	Wed Apr 10 11:17:23 2002
@@ -101,9 +101,6 @@
 extern devfs_handle_t devfs_get_next_sibling (devfs_handle_t de);
 extern void devfs_auto_unregister (devfs_handle_t master,devfs_handle_t sl=
ave);
 extern devfs_handle_t devfs_get_unregister_slave (devfs_handle_t master);
-#ifdef CONFIG_DEVFS_GUID
-extern void devfs_unregister_slave (devfs_handle_t master);
-#endif
 extern const char *devfs_get_name (devfs_handle_t de, unsigned int *namele=
n);
 extern int devfs_register_chrdev (unsigned int major, const char *name,
 				  struct file_operations *fops);
diff -urN linux-davidm/include/linux/genhd.h lia64-2.4/include/linux/genhd.h
--- linux-davidm/include/linux/genhd.h	Wed Apr 10 13:24:47 2002
+++ lia64-2.4/include/linux/genhd.h	Wed Apr 10 11:17:23 2002
@@ -13,10 +13,6 @@
 #include <linux/types.h>
 #include <linux/major.h>
=20
-#ifdef CONFIG_DEVFS_GUID
-#include <asm-ia64/efi.h>
-#endif
-
 enum {
 /* These three have identical behaviour; use the second one if DOS fdisk g=
ets
    confused about extended/logical partitions starting past cylinder 1023.=
 */
@@ -67,9 +63,6 @@
 	unsigned long nr_sects;
 	devfs_handle_t de;              /* primary (master) devfs entry  */
 	int number;                     /* stupid old code wastes space  */
-#ifdef CONFIG_DEVFS_GUID
-	efi_guid_t *guid;
-#endif
 };
=20
 #define GENHD_FL_REMOVABLE  1
diff -urN linux-davidm/include/linux/pci_ids.h lia64-2.4/include/linux/pci_=
ids.h
--- linux-davidm/include/linux/pci_ids.h	Tue Feb 26 11:05:06 2002
+++ lia64-2.4/include/linux/pci_ids.h	Fri Apr  5 16:44:44 2002
@@ -505,6 +505,9 @@
 #define PCI_DEVICE_ID_HP_DIVA1		0x1049
 #define PCI_DEVICE_ID_HP_DIVA2		0x104A
 #define PCI_DEVICE_ID_HP_SP2_0		0x104B
+#define PCI_DEVICE_ID_HP_ZX1_SBA	0x1229
+#define PCI_DEVICE_ID_HP_ZX1_IOC	0x122a
+#define PCI_DEVICE_ID_HP_ZX1_LBA	0x122e
=20
 #define PCI_VENDOR_ID_PCTECH		0x1042
 #define PCI_DEVICE_ID_PCTECH_RZ1000	0x1000
diff -urN linux-davidm/init/main.c lia64-2.4/init/main.c
--- linux-davidm/init/main.c	Wed Apr 10 13:24:47 2002
+++ lia64-2.4/init/main.c	Wed Apr 10 10:11:03 2002
@@ -36,6 +36,10 @@
 #include <asm/ccwcache.h>
 #endif
=20
+#ifdef CONFIG_ACPI
+#include <linux/acpi.h>
+#endif
+
 #ifdef CONFIG_PCI
 #include <linux/pci.h>
 #endif
@@ -693,7 +697,9 @@
 #if defined(CONFIG_ARCH_S390)
 	s390_init_machine_check();
 #endif
-
+#ifdef CONFIG_ACPI
+	acpi_init();
+#endif
 #ifdef CONFIG_PCI
 	pci_init();
 #endif
diff -urN linux-davidm/lib/Makefile lia64-2.4/lib/Makefile
--- linux-davidm/lib/Makefile	Wed Apr 10 13:24:47 2002
+++ lia64-2.4/lib/Makefile	Mon Apr  8 10:35:19 2002
@@ -10,7 +10,7 @@
=20
 export-objs :=3D cmdline.o dec_and_lock.o rwsem-spinlock.o rwsem.o
=20
-obj-y :=3D errno.o ctype.o string.o vsprintf.o brlock.o cmdline.o bust_spi=
nlocks.o rbtree.o crc32.o
+obj-y :=3D errno.o ctype.o string.o vsprintf.o brlock.o cmdline.o bust_spi=
nlocks.o rbtree.o
=20
 obj-$(CONFIG_RWSEM_GENERIC_SPINLOCK) +=3D rwsem-spinlock.o
 obj-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) +=3D rwsem.o
diff -urN linux-davidm/lib/crc32.c lia64-2.4/lib/crc32.c
--- linux-davidm/lib/crc32.c	Wed Apr 10 13:24:47 2002
+++ lia64-2.4/lib/crc32.c	Wed Dec 31 16:00:00 1969
@@ -1,125 +0,0 @@
-/*=20
- * Dec 5, 2000 Matt Domsch <Matt_Domsch@dell.com>
- * - Copied crc32.c from the linux/drivers/net/cipe directory.
- * - Now pass seed as an arg
- * - changed unsigned long to u32, added #include<linux/types.h>
- * - changed len to be an unsigned long
- * - changed crc32val to be a register
- * - License remains unchanged!  It's still GPL-compatable!
- */
-
-  /* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D */
-  /*  COPYRIGHT (C) 1986 Gary S. Brown.  You may use this program, or     =
  */
-  /*  code or tables extracted from it, as desired without restriction.   =
  */
-  /*                                                                      =
  */
-  /*  First, the polynomial itself and its table of feedback terms.  The  =
  */
-  /*  polynomial is                                                       =
  */
-  /*  X^32+X^26+X^23+X^22+X^16+X^12+X^11+X^10+X^8+X^7+X^5+X^4+X^2+X^1+X^0 =
  */
-  /*                                                                      =
  */
-  /*  Note that we take it "backwards" and put the highest-order term in  =
  */
-  /*  the lowest-order bit.  The X^32 term is "implied"; the LSB is the   =
  */
-  /*  X^31 term, etc.  The X^0 term (usually shown as "+1") results in    =
  */
-  /*  the MSB being 1.                                                    =
  */
-  /*                                                                      =
  */
-  /*  Note that the usual hardware shift register implementation, which   =
  */
-  /*  is what we're using (we're merely optimizing it by doing eight-bit  =
  */
-  /*  chunks at a time) shifts bits into the lowest-order term.  In our   =
  */
-  /*  implementation, that means shifting towards the right.  Why do we   =
  */
-  /*  do it this way?  Because the calculated CRC must be transmitted in  =
  */
-  /*  order from highest-order term to lowest-order term.  UARTs transmit =
  */
-  /*  characters in order from LSB to MSB.  By storing the CRC this way,  =
  */
-  /*  we hand it to the UART in the order low-byte to high-byte; the UART =
  */
-  /*  sends each low-bit to hight-bit; and the result is transmission bit =
  */
-  /*  by bit from highest- to lowest-order term without requiring any bit =
  */
-  /*  shuffling on our part.  Reception works similarly.                  =
  */
-  /*                                                                      =
  */
-  /*  The feedback terms table consists of 256, 32-bit entries.  Notes:   =
  */
-  /*                                                                      =
  */
-  /*      The table can be generated at runtime if desired; code to do so =
  */
-  /*      is shown later.  It might not be obvious, but the feedback      =
  */
-  /*      terms simply represent the results of eight shift/xor opera-    =
  */
-  /*      tions for all combinations of data and CRC register values.     =
  */
-  /*                                                                      =
  */
-  /*      The values must be right-shifted by eight bits by the "updcrc"  =
  */
-  /*      logic; the shift must be unsigned (bring in zeroes).  On some   =
  */
-  /*      hardware you could probably optimize the shift in assembler by  =
  */
-  /*      using byte-swap instructions.                                   =
  */
-  /*      polynomial $edb88320                                            =
  */
-  /*                                                                      =
  */
-  /*  --------------------------------------------------------------------=
  */
-
-#include <linux/crc32.h>
-
-static u32 crc32_tab[] =3D {
-      0x00000000L, 0x77073096L, 0xee0e612cL, 0x990951baL, 0x076dc419L,
-      0x706af48fL, 0xe963a535L, 0x9e6495a3L, 0x0edb8832L, 0x79dcb8a4L,
-      0xe0d5e91eL, 0x97d2d988L, 0x09b64c2bL, 0x7eb17cbdL, 0xe7b82d07L,
-      0x90bf1d91L, 0x1db71064L, 0x6ab020f2L, 0xf3b97148L, 0x84be41deL,
-      0x1adad47dL, 0x6ddde4ebL, 0xf4d4b551L, 0x83d385c7L, 0x136c9856L,
-      0x646ba8c0L, 0xfd62f97aL, 0x8a65c9ecL, 0x14015c4fL, 0x63066cd9L,
-      0xfa0f3d63L, 0x8d080df5L, 0x3b6e20c8L, 0x4c69105eL, 0xd56041e4L,
-      0xa2677172L, 0x3c03e4d1L, 0x4b04d447L, 0xd20d85fdL, 0xa50ab56bL,
-      0x35b5a8faL, 0x42b2986cL, 0xdbbbc9d6L, 0xacbcf940L, 0x32d86ce3L,
-      0x45df5c75L, 0xdcd60dcfL, 0xabd13d59L, 0x26d930acL, 0x51de003aL,
-      0xc8d75180L, 0xbfd06116L, 0x21b4f4b5L, 0x56b3c423L, 0xcfba9599L,
-      0xb8bda50fL, 0x2802b89eL, 0x5f058808L, 0xc60cd9b2L, 0xb10be924L,
-      0x2f6f7c87L, 0x58684c11L, 0xc1611dabL, 0xb6662d3dL, 0x76dc4190L,
-      0x01db7106L, 0x98d220bcL, 0xefd5102aL, 0x71b18589L, 0x06b6b51fL,
-      0x9fbfe4a5L, 0xe8b8d433L, 0x7807c9a2L, 0x0f00f934L, 0x9609a88eL,
-      0xe10e9818L, 0x7f6a0dbbL, 0x086d3d2dL, 0x91646c97L, 0xe6635c01L,
-      0x6b6b51f4L, 0x1c6c6162L, 0x856530d8L, 0xf262004eL, 0x6c0695edL,
-      0x1b01a57bL, 0x8208f4c1L, 0xf50fc457L, 0x65b0d9c6L, 0x12b7e950L,
-      0x8bbeb8eaL, 0xfcb9887cL, 0x62dd1ddfL, 0x15da2d49L, 0x8cd37cf3L,
-      0xfbd44c65L, 0x4db26158L, 0x3ab551ceL, 0xa3bc0074L, 0xd4bb30e2L,
-      0x4adfa541L, 0x3dd895d7L, 0xa4d1c46dL, 0xd3d6f4fbL, 0x4369e96aL,
-      0x346ed9fcL, 0xad678846L, 0xda60b8d0L, 0x44042d73L, 0x33031de5L,
-      0xaa0a4c5fL, 0xdd0d7cc9L, 0x5005713cL, 0x270241aaL, 0xbe0b1010L,
-      0xc90c2086L, 0x5768b525L, 0x206f85b3L, 0xb966d409L, 0xce61e49fL,
-      0x5edef90eL, 0x29d9c998L, 0xb0d09822L, 0xc7d7a8b4L, 0x59b33d17L,
-      0x2eb40d81L, 0xb7bd5c3bL, 0xc0ba6cadL, 0xedb88320L, 0x9abfb3b6L,
-      0x03b6e20cL, 0x74b1d29aL, 0xead54739L, 0x9dd277afL, 0x04db2615L,
-      0x73dc1683L, 0xe3630b12L, 0x94643b84L, 0x0d6d6a3eL, 0x7a6a5aa8L,
-      0xe40ecf0bL, 0x9309ff9dL, 0x0a00ae27L, 0x7d079eb1L, 0xf00f9344L,
-      0x8708a3d2L, 0x1e01f268L, 0x6906c2feL, 0xf762575dL, 0x806567cbL,
-      0x196c3671L, 0x6e6b06e7L, 0xfed41b76L, 0x89d32be0L, 0x10da7a5aL,
-      0x67dd4accL, 0xf9b9df6fL, 0x8ebeeff9L, 0x17b7be43L, 0x60b08ed5L,
-      0xd6d6a3e8L, 0xa1d1937eL, 0x38d8c2c4L, 0x4fdff252L, 0xd1bb67f1L,
-      0xa6bc5767L, 0x3fb506ddL, 0x48b2364bL, 0xd80d2bdaL, 0xaf0a1b4cL,
-      0x36034af6L, 0x41047a60L, 0xdf60efc3L, 0xa867df55L, 0x316e8eefL,
-      0x4669be79L, 0xcb61b38cL, 0xbc66831aL, 0x256fd2a0L, 0x5268e236L,
-      0xcc0c7795L, 0xbb0b4703L, 0x220216b9L, 0x5505262fL, 0xc5ba3bbeL,
-      0xb2bd0b28L, 0x2bb45a92L, 0x5cb36a04L, 0xc2d7ffa7L, 0xb5d0cf31L,
-      0x2cd99e8bL, 0x5bdeae1dL, 0x9b64c2b0L, 0xec63f226L, 0x756aa39cL,
-      0x026d930aL, 0x9c0906a9L, 0xeb0e363fL, 0x72076785L, 0x05005713L,
-      0x95bf4a82L, 0xe2b87a14L, 0x7bb12baeL, 0x0cb61b38L, 0x92d28e9bL,
-      0xe5d5be0dL, 0x7cdcefb7L, 0x0bdbdf21L, 0x86d3d2d4L, 0xf1d4e242L,
-      0x68ddb3f8L, 0x1fda836eL, 0x81be16cdL, 0xf6b9265bL, 0x6fb077e1L,
-      0x18b74777L, 0x88085ae6L, 0xff0f6a70L, 0x66063bcaL, 0x11010b5cL,
-      0x8f659effL, 0xf862ae69L, 0x616bffd3L, 0x166ccf45L, 0xa00ae278L,
-      0xd70dd2eeL, 0x4e048354L, 0x3903b3c2L, 0xa7672661L, 0xd06016f7L,
-      0x4969474dL, 0x3e6e77dbL, 0xaed16a4aL, 0xd9d65adcL, 0x40df0b66L,
-      0x37d83bf0L, 0xa9bcae53L, 0xdebb9ec5L, 0x47b2cf7fL, 0x30b5ffe9L,
-      0xbdbdf21cL, 0xcabac28aL, 0x53b39330L, 0x24b4a3a6L, 0xbad03605L,
-      0xcdd70693L, 0x54de5729L, 0x23d967bfL, 0xb3667a2eL, 0xc4614ab8L,
-      0x5d681b02L, 0x2a6f2b94L, 0xb40bbe37L, 0xc30c8ea1L, 0x5a05df1bL,
-      0x2d02ef8dL
-   };
-
-/* Return a 32-bit CRC of the contents of the buffer. */
-
-u32
-crc32(const void *buf, unsigned long len, u32 seed)
-{
-  unsigned long i;
-  register u32 crc32val;
-  const unsigned char *s =3D buf;
-
-  crc32val =3D seed;
-  for (i =3D 0;  i < len;  i ++)
-    {
-      crc32val -	crc32_tab[(crc32val ^ s[i]) & 0xff] ^
-	  (crc32val >> 8);
-    }
-  return crc32val;
-}
diff -urN linux-davidm/mm/memory.c lia64-2.4/mm/memory.c
--- linux-davidm/mm/memory.c	Wed Apr 10 13:24:47 2002
+++ lia64-2.4/mm/memory.c	Tue Feb 26 18:48:34 2002
@@ -476,8 +476,7 @@
 			struct page *map;
 			while (!(map =3D follow_page(mm, start, write))) {
 				spin_unlock(&mm->page_table_lock);
-				switch (handle_mm_fault(mm, vma, start, write))
-				{
+				switch (handle_mm_fault(mm, vma, start, write)) {
 				case 1:
 					tsk->min_flt++;
 					break;
@@ -1168,6 +1167,7 @@
 	unlock_page(page);
=20
 	flush_page_to_ram(page);
+	flush_icache_page(vma, page);
 	set_pte(page_table, pte);
=20
 	/* No need to invalidate - it was non-present before */
@@ -1283,6 +1283,7 @@
 	if (pte_none(*page_table)) {
 		++mm->rss;
 		flush_page_to_ram(new_page);
+		flush_icache_page(vma, new_page);
 		entry =3D mk_pte(new_page, vma->vm_page_prot);
 		if (write_access)
 			entry =3D pte_mkwrite(pte_mkdirty(entry));
@@ -1323,7 +1324,7 @@
  */
 static inline int handle_pte_fault(struct mm_struct *mm,
 	struct vm_area_struct * vma, unsigned long address,
-	int write, pte_t * pte)
+	int write_access, pte_t * pte)
 {
 	pte_t entry;
=20
@@ -1335,11 +1336,11 @@
 		 * drop the lock.
 		 */
 		if (pte_none(entry))
-			return do_no_page(mm, vma, address, write, pte);
-		return do_swap_page(mm, vma, address, pte, entry, write);
+			return do_no_page(mm, vma, address, write_access, pte);
+		return do_swap_page(mm, vma, address, pte, entry, write_access);
 	}
=20
-	if (write) {
+	if (write_access) {
 		if (!pte_write(entry))
 			return do_wp_page(mm, vma, address, pte, entry);
=20
@@ -1355,7 +1356,7 @@
  * By the time we get here, we already hold the mm semaphore
  */
 int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct * vma,
-	unsigned long address, int write)
+	unsigned long address, int write_access)
 {
 	pgd_t *pgd;
 	pmd_t *pmd;
@@ -1373,7 +1374,7 @@
 	if (pmd) {
 		pte_t * pte =3D pte_alloc(mm, pmd, address);
 		if (pte)
-			return handle_pte_fault(mm, vma, address, write, pte);
+			return handle_pte_fault(mm, vma, address, write_access, pte);
 	}
 	spin_unlock(&mm->page_table_lock);
 	return -1;

