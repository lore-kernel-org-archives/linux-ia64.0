From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Sat, 06 Apr 2002 00:12:05 +0000
Subject: [Linux-ia64] [PATCH] generic and HP zx1 system types
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------Boundary-00=_5WD4QZJ4JOQ4NJQLX30X"
Message-Id: <marc-linux-ia64-105590701905399@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--------------Boundary-00=_5WD4QZJ4JOQ4NJQLX30X
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit

This patch against 2.4.18+ia64-020226 makes the IA64 "generic"
kernel work and adds an HP "zx1" system type.  The generic kernel
is intended to boot on any IA64 machine and selects an appropriate
machine_vector based on acpi_get_sysname().  Kernels built for
other system types select the machine_vector at compile-time.

We moved the hpsim files into a subdirectory, so to make the patch
more readable, the first bit is shell commands to do the renames.
Use something like "sh ../machvec; patch -p1 < ../machvec" to
apply it.

One bit of ugliness that we hope is only temporary is that there
is no good way to use ACPI functionality outside of drivers/acpi;
we had to add a whole list of "#include "../drivers/acpi/include/..."
in hpzx1_misc.c and kernel/acpi.c.  I've been told this is fixed
in recent ACPI patches, but haven't seen it myself.

This is mostly the work of Alex Williamson (alex_williamson@hp.com)
and Matthew Wilcox (willy@fc.hp.com); I'm just trying to shepherd
the changes upstream.

-- 
Bjorn Helgaas - bjorn_helgaas@hp.com
Linux Systems Operation R&D
Hewlett-Packard
--------------Boundary-00=_5WD4QZJ4JOQ4NJQLX30X
Content-Type: text/plain;
  charset="iso-8859-1";
  name="diffstat"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="diffstat"

 Documentation/Configure.help     |    8 
 arch/ia64/Makefile               |   20 
 arch/ia64/config.in              |    3 
 arch/ia64/dig/setup.c            |    2 
 arch/ia64/hp/Makefile            |   20 
 arch/ia64/hp/common/Makefile     |   14 
 arch/ia64/hp/common/sba_iommu.c  | 1850 +++++++++++++++++++++++++++++++++++++++
 arch/ia64/hp/sim/Makefile        |   13 
 arch/ia64/hp/zx1/Makefile        |   13 
 arch/ia64/hp/zx1/hpzx1_machvec.c |    2 
 arch/ia64/hp/zx1/hpzx1_misc.c    |  400 ++++++++
 arch/ia64/kernel/Makefile        |    1 
 arch/ia64/kernel/acpi.c          |  104 ++
 arch/ia64/kernel/ia64_ksyms.c    |    7 
 arch/ia64/kernel/irq.c           |   17 
 arch/ia64/kernel/setup.c         |    2 
 arch/ia64/mm/tlb.c               |    2 
 drivers/acpi/acpiconf.c          |    2 
 drivers/pci/pci.ids              |    3 
 include/asm-ia64/hw_irq.h        |    2 
 include/asm-ia64/machvec.h       |    4 
 include/asm-ia64/machvec_hpzx1.h |   37 
 include/asm-ia64/machvec_init.h  |    5 
 include/linux/pci_ids.h          |    3 
 24 files changed, 2506 insertions(+), 28 deletions(-)

--------------Boundary-00=_5WD4QZJ4JOQ4NJQLX30X
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="machvec"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="machvec"

set -x

mkdir arch/ia64/hp/common
mkdir arch/ia64/hp/sim
mkdir arch/ia64/hp/zx1

mv arch/ia64/hp/hpsim_console.c arch/ia64/hp/sim/
mv arch/ia64/hp/hpsim_irq.c     arch/ia64/hp/sim/
mv arch/ia64/hp/hpsim_machvec.c arch/ia64/hp/sim/
mv arch/ia64/hp/hpsim_setup.c   arch/ia64/hp/sim/
mv arch/ia64/hp/hpsim_ssc.h     arch/ia64/hp/sim/

exit


diff -urN -X exclude linux-2.4.18-ia64-020226-orig/Documentation/Configure.help linux-2.4.18-ia64-020226-mv/Documentation/Configure.help
--- linux-2.4.18-ia64-020226-orig/Documentation/Configure.help	Mon Apr  1 16:43:58 2002
+++ linux-2.4.18-ia64-020226-mv/Documentation/Configure.help	Fri Apr  5 13:47:08 2002
@@ -23805,12 +23805,18 @@
 
   HP-simulator   For the HP simulator
                  (<http://software.hp.com/ia64linux/>).
+  HP-zx1         For HP zx1 Platforms.
   SN1            For SGI SN1 Platforms.
   SN2            For SGI SN2 Platforms.
   DIG-compliant  For DIG ("Developer's Interface Guide") compliant
-                 system.
+                 systems.
 
   If you don't know what to do, choose "generic".
+
+CONFIG_IA64_HP_ZX1
+  Build a kernel that runs on HP zx1-based systems.  This adds support
+  for the zx1 IOMMU and makes root bus bridges appear in PCI config space
+  (required for zx1 agpgart support).
 
 CONFIG_IA64_SGI_SN_SIM
   Build a kernel that runs on both the SGI simulator AND on hardware.
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/Makefile linux-2.4.18-ia64-020226-mv/arch/ia64/Makefile
--- linux-2.4.18-ia64-020226-orig/arch/ia64/Makefile	Mon Apr  1 16:43:58 2002
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/Makefile	Fri Apr  5 13:47:08 2002
@@ -33,16 +33,11 @@
 endif
 
 ifdef CONFIG_IA64_GENERIC
-	CORE_FILES      :=      arch/$(ARCH)/hp/hp.a	\
-				arch/$(ARCH)/sn/sn.o	\
-				arch/$(ARCH)/dig/dig.a	\
-				arch/$(ARCH)/sn/io/sgiio.o \
+	CORE_FILES      :=      arch/$(ARCH)/hp/hp.o			\
+				arch/$(ARCH)/dig/dig.a			\
 				$(CORE_FILES)
 	SUBDIRS		:=	arch/$(ARCH)/hp		\
-				arch/$(ARCH)/sn/sn1	\
-				arch/$(ARCH)/sn		\
 				arch/$(ARCH)/dig	\
-				arch/$(ARCH)/sn/io	\
 				$(SUBDIRS)
 
 else # !GENERIC
@@ -50,7 +45,16 @@
 ifdef CONFIG_IA64_HP_SIM
         SUBDIRS         :=      arch/$(ARCH)/hp		\
                                 $(SUBDIRS)
-        CORE_FILES      :=      arch/$(ARCH)/hp/hp.a	\
+        CORE_FILES      :=      arch/$(ARCH)/hp/hp.o	\
+                                $(CORE_FILES)
+endif
+
+ifdef CONFIG_IA64_HP_ZX1
+        SUBDIRS         :=      arch/$(ARCH)/hp				\
+				arch/$(ARCH)/dig			\
+                                $(SUBDIRS)
+        CORE_FILES      :=      arch/$(ARCH)/hp/hp.o			\
+				arch/$(ARCH)/dig/dig.a			\
                                 $(CORE_FILES)
 endif
 
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/config.in linux-2.4.18-ia64-020226-mv/arch/ia64/config.in
--- linux-2.4.18-ia64-020226-orig/arch/ia64/config.in	Mon Apr  1 16:43:58 2002
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/config.in	Fri Apr  5 13:47:08 2002
@@ -41,6 +41,7 @@
 	"generic		CONFIG_IA64_GENERIC		\
 	 DIG-compliant		CONFIG_IA64_DIG			\
 	 HP-simulator		CONFIG_IA64_HP_SIM		\
+	 HP-zx1			CONFIG_IA64_HP_ZX1		\
 	 SGI-SN1		CONFIG_IA64_SGI_SN1		\
 	 SGI-SN2		CONFIG_IA64_SGI_SN2" generic
 
@@ -68,7 +69,7 @@
 	fi
 fi
 
-if [ "$CONFIG_IA64_DIG" = "y" ]; then
+if [ "$CONFIG_IA64_GENERIC" = "y" ] || [ "$CONFIG_IA64_DIG" = "y" ] || [ "$CONFIG_IA64_HP_ZX1" = "y" ]; then
 	bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
 	define_bool CONFIG_PM y
 fi
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/dig/setup.c linux-2.4.18-ia64-020226-mv/arch/ia64/dig/setup.c
--- linux-2.4.18-ia64-020226-orig/arch/ia64/dig/setup.c	Thu Apr  5 13:51:47 2001
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/dig/setup.c	Fri Apr  5 13:47:08 2002
@@ -34,8 +34,6 @@
  */
 char drive_info[4*16];
 
-unsigned char aux_device_present = 0xaa;	/* XXX remove this when legacy I/O is gone */
-
 void __init
 dig_setup (char **cmdline_p)
 {
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/hp/Makefile linux-2.4.18-ia64-020226-mv/arch/ia64/hp/Makefile
--- linux-2.4.18-ia64-020226-orig/arch/ia64/hp/Makefile	Thu Jan  4 13:50:17 2001
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/hp/Makefile	Fri Apr  5 13:47:08 2002
@@ -1,17 +1,15 @@
-#
-# ia64/platform/hp/Makefile
-#
-# Copyright (C) 1999 Silicon Graphics, Inc.
-# Copyright (C) Srinivasa Thirumalachar (sprasad@engr.sgi.com)
-#
+# arch/ia64/hp/Makefile
+# Copyright (c) 2002 Matthew Wilcox for Hewlett Packard
 
-all: hp.a
+ALL_SUB_DIRS := sim zx1 common
 
-O_TARGET := hp.a
+O_TARGET := hp.o
 
-obj-y := hpsim_console.o hpsim_irq.o hpsim_setup.o
-obj-$(CONFIG_IA64_GENERIC) += hpsim_machvec.o
+subdir-$(CONFIG_IA64_GENERIC) += $(ALL_SUB_DIRS)
+subdir-$(CONFIG_IA64_HP_SIM) += sim
+subdir-$(CONFIG_IA64_HP_ZX1) += zx1 common
 
-clean::
+SUB_DIRS := $(subdir-y)
+obj-y += $(join $(subdir-y),$(subdir-y:%=/%.o))
 
 include $(TOPDIR)/Rules.make
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/hp/common/Makefile linux-2.4.18-ia64-020226-mv/arch/ia64/hp/common/Makefile
--- linux-2.4.18-ia64-020226-orig/arch/ia64/hp/common/Makefile	Wed Dec 31 17:00:00 1969
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/hp/common/Makefile	Fri Apr  5 13:47:08 2002
@@ -0,0 +1,14 @@
+#
+# ia64/platform/hp/common/Makefile
+#
+# Copyright (C) 2002 Hewlett Packard
+# Copyright (C) Alex Williamson (alex_williamson@hp.com)
+#
+
+O_TARGET := common.o
+
+export-objs := sba_iommu.o
+
+obj-y := sba_iommu.o
+
+include $(TOPDIR)/Rules.make
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/hp/common/sba_iommu.c linux-2.4.18-ia64-020226-mv/arch/ia64/hp/common/sba_iommu.c
--- linux-2.4.18-ia64-020226-orig/arch/ia64/hp/common/sba_iommu.c	Wed Dec 31 17:00:00 1969
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/hp/common/sba_iommu.c	Fri Apr  5 13:47:08 2002
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
+                printk( "\n" __FILE__ ":%d: Assertion " #expr " failed!\n",__LINE__); \
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
+#define ZX1_FUNC_ID_VALUE    ((PCI_DEVICE_ID_HP_ZX1_SBA << 16) | PCI_VENDOR_ID_HP)
+#define ZX1_MC_ID    ((PCI_DEVICE_ID_HP_ZX1_MC << 16) | PCI_VENDOR_ID_HP)
+
+#define SBA_FUNC_ID	0x0000	/* function id */
+#define SBA_FCLASS	0x0008	/* function class, bist, header, rev... */
+
+#define SBA_FUNC_SIZE	0x10000   /* SBA configuration function reg set */
+
+unsigned int __initdata zx1_func_offsets[] = {0x1000, 0x4000, 0x8000,
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
+	char		*res_map;	/* resource map, bit == pdir entry */
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
+static int reserve_sba_gart = 1;
+
+#define sba_sg_iova(sg) (sg->address)
+#define sba_sg_len(sg) (sg->length)
+#define sba_sg_buffer(sg) (sg->orig_address)
+
+/* REVISIT - fix me for multiple SBAs/IOCs */
+#define GET_IOC(dev) (sba_list->ioc)
+#define SBA_SET_AGP(sba_dev) (sba_dev->flags |= 0x1)
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
+	u64 *ptr = &(ioc->pdir_base[pide  & ~(BITS_PER_LONG - 1)]);
+	unsigned long *rptr = (unsigned long *) &(ioc->res_map[(pide >>3) & ~(sizeof(unsigned long) - 1)]);
+	uint rcnt;
+
+	/* printk(KERN_DEBUG "SBA: %s rp %p bit %d rval 0x%lx\n", */
+	printk("SBA: %s rp %p bit %d rval 0x%lx\n",
+		 msg, rptr, pide & (BITS_PER_LONG - 1), *rptr);
+
+	rcnt = 0;
+	while (rcnt < BITS_PER_LONG) {
+		printk("%s %2d %p %016Lx\n",
+			(rcnt == (pide & (BITS_PER_LONG - 1)))
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
+	u64 *rptr_end = (u64 *) &(ioc->res_map[ioc->res_size]);
+	u64 *rptr = (u64 *) ioc->res_map;	/* resource map ptr */
+	u64 *pptr = ioc->pdir_base;	/* pdir ptr */
+	uint pide = 0;
+
+	while (rptr < rptr_end) {
+		u64 rval;
+		int rcnt; /* number of bits we might check */
+
+		rval = *rptr;
+		rcnt = 64;
+
+		while (rcnt) {
+			/* Get last byte and highest bit from that */
+			u32 pde = ((u32)((*pptr >> (63)) & 0x1));
+			if ((rval & 0x1) ^ pde)
+			{
+				/*
+				** BUMMER!  -- res_map != pdir --
+				** Dump rval and matching pdir entries
+				*/
+				sba_dump_pdir_entry(ioc, msg, pide);
+				return(1);
+			}
+			rcnt--;
+			rval >>= 1;	/* try the next bit */
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
+	struct scatterlist *the_sg = startsg;
+	int the_nents = nents;
+
+	while (the_nents-- > 0) {
+		if (sba_sg_buffer(the_sg) == 0x0UL)
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
+#define SBA_IOVA(ioc,iovp,offset,hint_reg) ((ioc->ibase) | (iovp) | (offset) | ((hint_reg)<<(ioc->hint_shift_pdir)))
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
+	unsigned long *res_ptr = ioc->res_hint;
+	unsigned long *res_end = (unsigned long *) &(ioc->res_map[ioc->res_size]);
+	unsigned long pide = ~0UL;
+
+	ASSERT(((unsigned long) ioc->res_hint & (sizeof(unsigned long) - 1UL)) == 0);
+	ASSERT(res_ptr < res_end);
+	if (bits_wanted > (BITS_PER_LONG/2)) {
+		/* Search word at a time - no mask needed */
+		for(; res_ptr < res_end; ++res_ptr) {
+			if (*res_ptr == 0) {
+				*res_ptr = RESMAP_MASK(bits_wanted);
+				pide = ((unsigned long)res_ptr - (unsigned long)ioc->res_map);
+				pide <<= 3;	/* convert to bit address */
+				break;
+			}
+		}
+		/* point to the next word on next pass */
+		res_ptr++;
+		ioc->res_bitshift = 0;
+	} else {
+		/*
+		** Search the resource bit map on well-aligned values.
+		** "o" is the alignment.
+		** We need the alignment to invalidate I/O TLB using
+		** SBA HW features in the unmap path.
+		*/
+		unsigned long o = 1 << get_order(bits_wanted << PAGE_SHIFT);
+		uint bitshiftcnt = ROUNDUP(ioc->res_bitshift, o);
+		unsigned long mask;
+
+		if (bitshiftcnt >= BITS_PER_LONG) {
+			bitshiftcnt = 0;
+			res_ptr++;
+		}
+		mask = RESMAP_MASK(bits_wanted) << bitshiftcnt;
+
+		DBG_RES("%s() o %ld %p", __FUNCTION__, o, res_ptr);
+		while(res_ptr < res_end)
+		{ 
+			DBG_RES("    %p %lx %lx\n", res_ptr, mask, *res_ptr);
+			ASSERT(0 != mask);
+			if(0 == ((*res_ptr) & mask)) {
+				*res_ptr |= mask;     /* mark resources busy! */
+				pide = ((unsigned long)res_ptr - (unsigned long)ioc->res_map);
+				pide <<= 3;	/* convert to bit address */
+				pide += bitshiftcnt;
+				break;
+			}
+			mask <<= o;
+			bitshiftcnt += o;
+			if (0 == mask) {
+				mask = RESMAP_MASK(bits_wanted);
+				bitshiftcnt=0;
+				res_ptr++;
+			}
+		}
+		/* look in the same word on the next pass */
+		ioc->res_bitshift = bitshiftcnt + bits_wanted;
+	}
+
+	/* wrapped ? */
+	if (res_end <= res_ptr) {
+		ioc->res_hint = (unsigned long *) ioc->res_map;
+		ioc->res_bitshift = 0;
+	} else {
+		ioc->res_hint = res_ptr;
+	}
+	return (pide);
+}
+
+
+/**
+ * sba_alloc_range - find free bits and mark them in IO PDIR resource bitmap
+ * @ioc: IO MMU structure which owns the pdir we are interested in.
+ * @size: number of bytes to create a mapping for
+ *
+ * Given a size, find consecutive unmarked and then mark those bits in the
+ * resource bit map.
+ */
+static int
+sba_alloc_range(struct ioc *ioc, size_t size)
+{
+	unsigned int pages_needed = size >> IOVP_SHIFT;
+#ifdef CONFIG_PROC_FS
+	unsigned long itc_start = ia64_get_itc();
+#endif
+	unsigned long pide;
+
+	ASSERT(pages_needed);
+	ASSERT((pages_needed * IOVP_SIZE) <= DMA_CHUNK_SIZE);
+	ASSERT(pages_needed <= BITS_PER_LONG);
+	ASSERT(0 == (size & ~IOVP_MASK));
+
+	/*
+	** "seek and ye shall find"...praying never hurts either...
+	*/
+
+	pide = sba_search_bitmap(ioc, pages_needed);
+	if (pide >= (ioc->res_size << 3)) {
+		pide = sba_search_bitmap(ioc, pages_needed);
+		if (pide >= (ioc->res_size << 3))
+			panic(__FILE__ ": I/O MMU @ %lx is out of mapping resources\n", ioc->ioc_hpa);
+	}
+
+#ifdef ASSERT_PDIR_SANITY
+	/* verify the first enable bit is clear */
+	if(0x00 != ((u8 *) ioc->pdir_base)[pide*sizeof(u64) + 7]) {
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
+		unsigned long itc_end = ia64_get_itc();
+		unsigned long tmp = itc_end - itc_start;
+		/* check for roll over */
+		itc_start = (itc_end < itc_start) ?  -(tmp) : (tmp);
+	}
+	ioc->avg_search[ioc->avg_idx++] = itc_start;
+	ioc->avg_idx &= SBA_SEARCH_SAMPLE - 1;
+
+	ioc->used_pages += pages_needed;
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
+	unsigned long iovp = SBA_IOVP(ioc, iova);
+	unsigned int pide = PDIR_INDEX(iovp);
+	unsigned int ridx = pide >> 3;	/* convert bit to byte address */
+	unsigned long *res_ptr = (unsigned long *) &((ioc)->res_map[ridx & ~RESMAP_IDX_MASK]);
+
+	int bits_not_wanted = size >> IOVP_SHIFT;
+
+	/* 3-bits "bit" address plus 2 (or 3) bits for "byte" == bit in word */
+	unsigned long m = RESMAP_MASK(bits_not_wanted) << (pide & (BITS_PER_LONG - 1));
+
+	DBG_RES("%s( ,%x,%x) %x/%lx %x %p %lx\n",
+		__FUNCTION__, (uint) iova, size,
+		bits_not_wanted, m, pide, res_ptr, *res_ptr);
+
+#ifdef CONFIG_PROC_FS
+	ioc->used_pages -= bits_not_wanted;
+#endif
+
+	ASSERT(m != 0);
+	ASSERT(bits_not_wanted);
+	ASSERT((bits_not_wanted * IOVP_SIZE) <= DMA_CHUNK_SIZE);
+	ASSERT(bits_not_wanted <= BITS_PER_LONG);
+	ASSERT((*res_ptr & m) == m); /* verify same bits are set */
+	*res_ptr &= ~m;
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
+ * (LSB == bit 0):
+ *
+ *  63                    40                                 11    7        0
+ * +-+---------------------+----------------------------------+----+--------+
+ * |V|        U            |            PPN[39:12]            | U  |   FF   |
+ * +-+---------------------+----------------------------------+----+--------+
+ *
+ *  V  == Valid Bit
+ *  U  == Unused
+ * PPN == Physical Page Number
+ *
+ * The physical address fields are filled with the results of virt_to_phys()
+ * on the vba.
+ */
+
+#if 1
+#define sba_io_pdir_entry(pdir_ptr, vba) *pdir_ptr = ((vba & ~0xE000000000000FFFULL) | 0x80000000000000FFULL)
+#else
+void SBA_INLINE
+sba_io_pdir_entry(u64 *pdir_ptr, unsigned long vba)
+{
+	*pdir_ptr = ((vba & ~0xE000000000000FFFULL) | 0x80000000000000FFULL);
+}
+#endif
+
+#ifdef ENABLE_MARK_CLEAN
+/**
+ * Since DMA is i-cache coherent, any (complete) pages that were written via
+ * DMA can be marked as "clean" so that update_mmu_cache() doesn't have to
+ * flush them when they get mapped into an executable vm-area.
+ */
+static void
+mark_clean (void *addr, size_t size)
+{
+	unsigned long pg_addr, end;
+
+	pg_addr = PAGE_ALIGN((unsigned long) addr);
+	end = (unsigned long) addr + size;
+	while (pg_addr + PAGE_SIZE <= end) {
+		struct page *page = virt_to_page(pg_addr);
+		set_bit(PG_arch_1, &page->flags);
+		pg_addr += PAGE_SIZE;
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
+	u32 iovp = (u32) SBA_IOVP(ioc,iova);
+
+	int off = PDIR_INDEX(iovp);
+
+	/* Must be non-zero and rounded up */
+	ASSERT(byte_cnt > 0);
+	ASSERT(0 == (byte_cnt & ~IOVP_MASK));
+
+#ifdef ASSERT_PDIR_SANITY
+	/* Assert first pdir entry is set */
+	if (!(ioc->pdir_base[off] >> 60)) {
+		sba_dump_pdir_entry(ioc,"sba_mark_invalid()", PDIR_INDEX(iovp));
+	}
+#endif
+
+	if (byte_cnt <= IOVP_SIZE)
+	{
+		ASSERT(off < ioc->pdir_size);
+
+		iovp |= IOVP_SHIFT;     /* set "size" field for PCOM */
+
+		/*
+		** clear I/O PDIR entry "valid" bit
+		** Do NOT clear the rest - save it for debugging.
+		** We should only clear bits that have previously
+		** been enabled.
+		*/
+		ioc->pdir_base[off] &= ~(0x80000000000000FFULL);
+	} else {
+		u32 t = get_order(byte_cnt) + PAGE_SHIFT;
+
+		iovp |= t;
+		ASSERT(t <= 31);   /* 2GB! Max value of "size" field */
+
+		do {
+			/* verify this pdir entry is enabled */
+			ASSERT(ioc->pdir_base[off]  >> 63);
+			/* clear I/O Pdir entry "valid" bit first */
+			ioc->pdir_base[off] &= ~(0x80000000000000FFULL);
+			off++;
+			byte_cnt -= IOVP_SIZE;
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
+	unsigned long flags; 
+	dma_addr_t iovp;
+	dma_addr_t offset;
+	u64 *pdir_start;
+	int pide;
+#ifdef ALLOW_IOV_BYPASS
+	unsigned long pci_addr = virt_to_phys(addr);
+#endif
+
+	ioc = GET_IOC(dev);
+	ASSERT(ioc);
+
+#ifdef ALLOW_IOV_BYPASS
+	/*
+ 	** Check if the PCI device can DMA to ptr... if so, just return ptr
+ 	*/
+	if ((pci_addr & ~dev->dma_mask) == 0) {
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
+	ASSERT(size <= DMA_CHUNK_SIZE);
+
+	/* save offset bits */
+	offset = ((dma_addr_t) (long) addr) & ~IOVP_MASK;
+
+	/* round up to nearest IOVP_SIZE */
+	size = (size + offset + ~IOVP_MASK) & IOVP_MASK;
+
+	spin_lock_irqsave(&ioc->res_lock, flags);
+#ifdef ASSERT_PDIR_SANITY
+	if (sba_check_pdir(ioc,"Check before sba_map_single()"))
+		panic("Sanity check failed");
+#endif
+
+#ifdef CONFIG_PROC_FS
+	ioc->msingle_calls++;
+	ioc->msingle_pages += size >> IOVP_SHIFT;
+#endif
+	pide = sba_alloc_range(ioc, size);
+	iovp = (dma_addr_t) pide << IOVP_SHIFT;
+
+	DBG_RUN("%s() 0x%p -> 0x%lx\n",
+		__FUNCTION__, addr, (long) iovp | offset);
+
+	pdir_start = &(ioc->pdir_base[pide]);
+
+	while (size > 0) {
+		ASSERT(((u8 *)pdir_start)[7] == 0); /* verify availability */
+		sba_io_pdir_entry(pdir_start, (unsigned long) addr);
+
+		DBG_RUN("     pdir 0x%p %lx\n", pdir_start, *pdir_start);
+
+		addr += IOVP_SIZE;
+		size -= IOVP_SIZE;
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
+	unsigned long flags; 
+	dma_addr_t offset;
+
+	ioc = GET_IOC(dev);
+	ASSERT(ioc);
+
+#ifdef ALLOW_IOV_BYPASS
+	if ((iova & ioc->imask) != ioc->ibase) {
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
+		if (direction == PCI_DMA_FROMDEVICE) {
+			mark_clean(phys_to_virt(iova), size);
+		}
+#endif
+		return;
+	}
+#endif
+	offset = iova & ~IOVP_MASK;
+
+	DBG_RUN("%s() iovp 0x%lx/%x\n",
+		__FUNCTION__, (long) iova, size);
+
+	iova ^= offset;        /* clear offset bits */
+	size += offset;
+	size = ROUNDUP(size, IOVP_SIZE);
+
+	spin_lock_irqsave(&ioc->res_lock, flags);
+#ifdef CONFIG_PROC_FS
+	ioc->usingle_calls++;
+	ioc->usingle_pages += size >> IOVP_SHIFT;
+#endif
+
+#if DELAYED_RESOURCE_CNT > 0
+	d = &(ioc->saved[ioc->saved_cnt]);
+	d->iova = iova;
+	d->size = size;
+	if (++(ioc->saved_cnt) >= DELAYED_RESOURCE_CNT) {
+		int cnt = ioc->saved_cnt;
+		while (cnt--) {
+			sba_mark_invalid(ioc, d->iova, d->size);
+			sba_free_range(ioc, d->iova, d->size);
+			d--;
+		}
+		ioc->saved_cnt = 0;
+		READ_REG(ioc->ioc_hpa+IOC_PCOM);	/* flush purges */
+	}
+#else /* DELAYED_RESOURCE_CNT == 0 */
+	sba_mark_invalid(ioc, iova, size);
+	sba_free_range(ioc, iova, size);
+	READ_REG(ioc->ioc_hpa+IOC_PCOM);	/* flush purges */
+#endif /* DELAYED_RESOURCE_CNT == 0 */
+#ifdef ENABLE_MARK_CLEAN
+	if (direction == PCI_DMA_FROMDEVICE) {
+		u32 iovp = (u32) SBA_IOVP(ioc,iova);
+		int off = PDIR_INDEX(iovp);
+		void *addr;
+
+		if (size <= IOVP_SIZE) {
+			addr = phys_to_virt(ioc->pdir_base[off] &
+					    ~0xE000000000000FFFULL);
+			mark_clean(addr, size);
+		} else {
+			size_t byte_cnt = size;
+
+			do {
+				addr = phys_to_virt(ioc->pdir_base[off] &
+				                    ~0xE000000000000FFFULL);
+				mark_clean(addr, min(byte_cnt, IOVP_SIZE));
+				off++;
+				byte_cnt -= IOVP_SIZE;
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
+	asm volatile("syncdma");	
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
+sba_alloc_consistent(struct pci_dev *hwdev, size_t size, dma_addr_t *dma_handle)
+{
+	void *ret;
+
+	if (!hwdev) {
+		/* only support PCI */
+		*dma_handle = 0;
+		return 0;
+	}
+
+        ret = (void *) __get_free_pages(GFP_ATOMIC, get_order(size));
+
+	if (ret) {
+		memset(ret, 0, size);
+		*dma_handle = sba_map_single(hwdev, ret, size, 0);
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
+int dump_run_sg = 0;
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
+	struct scatterlist *dma_sg = startsg;	/* pointer to current DMA */
+	int n_mappings = 0;
+	u64 *pdirp = 0;
+	unsigned long dma_offset = 0;
+
+	dma_sg--;
+	while (nents-- > 0) {
+		int     cnt = sba_sg_len(startsg);
+		sba_sg_len(startsg) = 0;
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
+			u32 pide = (u64)sba_sg_iova(startsg) & ~PIDE_FLAG;
+			dma_offset = (unsigned long) pide & ~IOVP_MASK;
+			sba_sg_iova(startsg) = 0;
+			dma_sg++;
+			sba_sg_iova(dma_sg) = (char *)(pide | ioc->ibase);
+			pdirp = &(ioc->pdir_base[pide >> IOVP_SHIFT]);
+			n_mappings++;
+		}
+
+		/*
+		** Look for a VCONTIG chunk
+		*/
+		if (cnt) {
+			unsigned long vaddr = (unsigned long) sba_sg_buffer(startsg);
+			ASSERT(pdirp);
+
+			/* Since multiple Vcontig blocks could make up
+			** one DMA stream, *add* cnt to dma_len.
+			*/
+			sba_sg_len(dma_sg) += cnt;
+			cnt += dma_offset;
+			dma_offset=0;	/* only want offset on first chunk */
+			cnt = ROUNDUP(cnt, IOVP_SIZE);
+#ifdef CONFIG_PROC_FS
+			ioc->msg_pages += cnt >> IOVP_SHIFT;
+#endif
+			do {
+				sba_io_pdir_entry(pdirp, vaddr);
+				vaddr += IOVP_SIZE;
+				cnt -= IOVP_SIZE;
+				pdirp++;
+			} while (cnt > 0);
+		}
+		startsg++;
+	}
+#ifdef DEBUG_LARGE_SG_ENTRIES
+	dump_run_sg = 0;
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
+	(((((unsigned long) __X) | ((unsigned long) __Y)) << (BITS_PER_LONG - PAGE_SHIFT)) == 0UL)
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
+	int n_mappings = 0;
+
+	while (nents > 0) {
+		unsigned long vaddr = (unsigned long) (startsg->address); 
+
+		/*
+		** Prepare for first/next DMA stream
+		*/
+		dma_sg = vcontig_sg = startsg;
+		dma_len = vcontig_len = vcontig_end = sba_sg_len(startsg);
+		vcontig_end +=  vaddr;
+		dma_offset = vaddr & ~IOVP_MASK;
+
+		/* PARANOID: clear entries */
+		sba_sg_buffer(startsg) = sba_sg_iova(startsg);
+		sba_sg_iova(startsg) = 0;
+		sba_sg_len(startsg) = 0;
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
+			ASSERT(startsg->length <= DMA_CHUNK_SIZE);
+
+			/*
+			** First make sure current dma stream won't
+			** exceed DMA_CHUNK_SIZE if we coalesce the
+			** next entry.
+			*/
+			if (((dma_len + dma_offset + startsg->length + ~IOVP_MASK) & IOVP_MASK) > DMA_CHUNK_SIZE)
+				break;
+
+			/*
+			** Then look for virtually contiguous blocks.
+			**
+			** append the next transaction?
+			*/
+			vaddr = (unsigned long) sba_sg_iova(startsg);
+			if  (vcontig_end == vaddr)
+			{
+				vcontig_len += sba_sg_len(startsg);
+				vcontig_end += sba_sg_len(startsg);
+				dma_len     += sba_sg_len(startsg);
+				sba_sg_buffer(startsg) = (char *)vaddr;
+				sba_sg_iova(startsg) = 0;
+				sba_sg_len(startsg) = 0;
+				continue;
+			}
+
+#ifdef DEBUG_LARGE_SG_ENTRIES
+			dump_run_sg = (vcontig_len > IOVP_SIZE);
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
+			sba_sg_len(vcontig_sg) = vcontig_len;
+
+			vcontig_sg = startsg;
+			vcontig_len = sba_sg_len(startsg);
+
+			/*
+			** 3) do the entries end/start on page boundaries?
+			**    Don't update vcontig_end until we've checked.
+			*/
+			if (DMA_CONTIG(vcontig_end, vaddr))
+			{
+				vcontig_end = vcontig_len + vaddr;
+				dma_len += vcontig_len;
+				sba_sg_buffer(startsg) = (char *)vaddr;
+				sba_sg_iova(startsg) = 0;
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
+		sba_sg_len(vcontig_sg) = vcontig_len;
+		dma_len = (dma_len + dma_offset + ~IOVP_MASK) & IOVP_MASK;
+		ASSERT(dma_len <= DMA_CHUNK_SIZE);
+		sba_sg_iova(dma_sg) = (char *) (PIDE_FLAG 
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
+	int coalesced, filled = 0;
+	unsigned long flags;
+#ifdef ALLOW_IOV_BYPASS
+	struct scatterlist *sg;
+#endif
+
+	DBG_RUN_SG("%s() START %d entries\n", __FUNCTION__, nents);
+	ioc = GET_IOC(dev);
+	ASSERT(ioc);
+
+#ifdef ALLOW_IOV_BYPASS
+	if (dev->dma_mask >= ioc->dma_mask) {
+		for (sg = sglist ; filled < nents ; filled++, sg++){
+			sba_sg_buffer(sg) = sba_sg_iova(sg);
+			sba_sg_iova(sg) = (char *)virt_to_phys(sba_sg_buffer(sg));
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
+	if (nents == 1) {
+		sba_sg_buffer(sglist) = sba_sg_iova(sglist);
+		sba_sg_iova(sglist) = (char *)sba_map_single(dev,
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
+	coalesced = sba_coalesce_chunks(ioc, sglist, nents);
+ 
+	/*
+	** Program the I/O Pdir
+	**
+	** map the virtual addresses to the I/O Pdir
+	** o dma_address will contain the pdir index
+	** o dma_len will contain the number of bytes to map 
+	** o address contains the virtual address.
+	*/
+	filled = sba_fill_pdir(ioc, sglist, nents);
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
+	ASSERT(coalesced == filled);
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
+void sba_unmap_sg(struct pci_dev *dev, struct scatterlist *sglist, int nents,
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
+	ioc = GET_IOC(dev);
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
+		ioc->usg_pages += (((u64)sba_sg_iova(sglist) & ~IOVP_MASK) + sba_sg_len(sglist) + IOVP_SIZE - 1) >> PAGE_SHIFT;
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
+	iova_space_size = ~(READ_REG(ioc->ioc_hpa + IOC_IMASK) & 0xFFFFFFFFUL) + 1;
+#ifdef CONFIG_IA64_HP_PROTO
+	if (!iova_space_size)
+		iova_space_size = GB(1);
+#endif
+
+	/*
+	** iov_order is always based on a 1GB IOVA space since we want to
+	** turn on the other half for AGP GART.
+	*/
+	iov_order = get_order(iova_space_size >> (IOVP_SHIFT-PAGE_SHIFT));
+	ioc->pdir_size = pdir_size = (iova_space_size/IOVP_SIZE) * sizeof(u64);
+
+	DBG_INIT("%s() hpa 0x%lx IOV %dMB (%d bits) PDIR size 0x%0x\n",
+		__FUNCTION__, ioc->ioc_hpa, iova_space_size>>20,
+		iov_order + PAGE_SHIFT, ioc->pdir_size);
+
+	/* FIXME : DMA HINTs not used */
+	ioc->hint_shift_pdir = iov_order + PAGE_SHIFT;
+	ioc->hint_mask_pdir = ~(0x3 << (iov_order + PAGE_SHIFT));
+
+	ioc->pdir_base =
+	pdir_base = (void *) __get_free_pages(GFP_KERNEL, get_order(pdir_size));
+	if (NULL == pdir_base)
+	{
+		panic(__FILE__ ":%s() could not allocate I/O Page Table\n", __FUNCTION__);
+	}
+	memset(pdir_base, 0, pdir_size);
+
+	DBG_INIT("%s() pdir %p size %x hint_shift_pdir %x hint_mask_pdir %lx\n",
+		__FUNCTION__, pdir_base, pdir_size,
+		ioc->hint_shift_pdir, ioc->hint_mask_pdir);
+
+	ASSERT((((unsigned long) pdir_base) & PAGE_MASK) == (unsigned long) pdir_base);
+	WRITE_REG(virt_to_phys(pdir_base), ioc->ioc_hpa + IOC_PDIR_BASE);
+
+	DBG_INIT(" base %p\n", pdir_base);
+
+	/* build IMASK for IOC and Elroy */
+	iova_space_mask =  0xffffffff;
+	iova_space_mask <<= (iov_order + PAGE_SHIFT);
+
+#ifdef CONFIG_IA64_HP_PROTO
+	/*
+	** REVISIT - this is a kludge, but we won't be supporting anything but
+	** zx1 2.0 or greater for real.  When fw is in shape, ibase will
+	** be preprogrammed w/ the IOVA hole base and imask will give us
+	** the size.
+	*/
+	if ((sba_dev->hw_rev & 0xFF) < 0x20) {
+		DBG_INIT("%s() Found SBA rev < 2.0, setting IOVA base to 0.  This device will not be supported in the future.\n", __FUNCTION__);
+		ioc->ibase = 0x0;
+	} else
+#endif
+	ioc->ibase = READ_REG(ioc->ioc_hpa + IOC_IBASE) & 0xFFFFFFFEUL;
+
+	ioc->imask = iova_space_mask;	/* save it */
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
+	ioc->imask |= 0xFFFFFFFF00000000UL;
+
+	/* Set I/O PDIR Page size to system page size */
+	switch (PAGE_SHIFT) {
+		case 12: /* 4K */
+			tcnfg = 0;
+			break;
+		case 13: /* 8K */
+			tcnfg = 1;
+			break;
+		case 14: /* 16K */
+			tcnfg = 2;
+			break;
+		case 16: /* 64K */
+			tcnfg = 3;
+			break;
+	}
+	WRITE_REG(tcnfg, ioc->ioc_hpa+IOC_TCNFG);
+
+	/*
+	** Program the IOC's ibase and enable IOVA translation
+	** Bit zero == enable bit.
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
+		DBG_INIT("%s() AGP Device found, reserving 512MB for GART support\n", __FUNCTION__);
+		ioc->pdir_size /= 2;
+		((u64 *)pdir_base)[PDIR_INDEX(iova_space_size/2)] = 0x0000badbadc0ffeeULL;
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
+{ 
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
+	func_id = READ_REG(sba_dev->sba_hpa + SBA_FUNC_ID);
+
+	if (func_id == ZX1_FUNC_ID_VALUE) {
+		dma_mask = 0xFFFFFFFFFFUL;
+	} else {
+		dma_mask = 0xFFFFFFFFFFFFFFFFUL;
+	}
+
+	DBG_INIT("%s(): ioc->dma_mask == 0x%lx\n", __FUNCTION__, dma_mask);
+	
+	/*
+	** Leaving in the multiple ioc code from parisc for the future,
+	** currently there are no muli-ioc mckinley sbas
+	*/
+	sba_dev->ioc[0].ioc_hpa = SBA_IOC_OFFSET;
+	num_ioc = 1;
+
+	sba_dev->num_ioc = num_ioc;
+	for (i = 0; i < num_ioc; i++) {
+		sba_dev->ioc[i].dma_mask = dma_mask;
+		sba_dev->ioc[i].ioc_hpa += sba_dev->sba_hpa;
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
+	sba_dev->next = sba_list;
+	sba_list = sba_dev;
+	sba_count++;
+
+	for(i=0; i< sba_dev->num_ioc; i++) {
+		int res_size;
+
+		/* resource map size dictated by pdir_size */
+		res_size = sba_dev->ioc[i].pdir_size/sizeof(u64); /* entries */
+		res_size >>= 3;  /* convert bit count to byte count */
+		DBG_INIT("%s() res_size 0x%x\n",
+			__FUNCTION__, res_size);
+
+		sba_dev->ioc[i].res_size = res_size;
+		sba_dev->ioc[i].res_map = (char *) __get_free_pages(GFP_KERNEL, get_order(res_size));
+
+		if (NULL == sba_dev->ioc[i].res_map)
+		{
+			panic(__FILE__ ":%s() could not allocate resource map\n", __FUNCTION__ );
+		}
+
+		memset(sba_dev->ioc[i].res_map, 0, res_size);
+		/* next available IOVP - circular search */
+		if ((sba_dev->hw_rev & 0xFF) >= 0x20) {
+			sba_dev->ioc[i].res_hint = (unsigned long *)
+			    sba_dev->ioc[i].res_map;
+		} else {
+			u64 reserved_iov;
+			
+			/* Yet another 1.x hack */
+			printk("zx1 1.x: Starting resource hint offset into IOV space to avoid initial zero value IOVA\n");
+			sba_dev->ioc[i].res_hint = (unsigned long *)
+			    &(sba_dev->ioc[i].res_map[L1_CACHE_BYTES]);
+
+			sba_dev->ioc[i].res_map[0] = 0x1;
+			sba_dev->ioc[i].pdir_base[0] = 0x8000badbadc0ffeeULL;
+
+			for (reserved_iov = 0xA0000 ; reserved_iov < 0xC0000 ; reserved_iov += IOVP_SIZE) {
+				u64 *res_ptr = sba_dev->ioc[i].res_map;
+				int index = PDIR_INDEX(reserved_iov);
+				int res_word;
+				u64 mask;
+
+				res_word = (int)(index / BITS_PER_LONG);
+				mask =  0x1UL << (index - (res_word * BITS_PER_LONG));
+				res_ptr[res_word] |= mask;
+				sba_dev->ioc[i].pdir_base[PDIR_INDEX(reserved_iov)] = (0x80000000000000FFULL | reserved_iov);
+
+			}
+		}
+
+#ifdef ASSERT_PDIR_SANITY
+		/* Mark first bit busy - ie no IOVA 0 */
+		sba_dev->ioc[i].res_map[0] = 0x1;
+		sba_dev->ioc[i].pdir_base[0] = 0x8000badbadc0ffeeULL;
+#endif
+
+		DBG_INIT("%s() %d res_map %x %p\n", __FUNCTION__,
+		         i, res_size, (void *)sba_dev->ioc[i].res_map);
+	}
+
+	sba_dev->sba_lock = SPIN_LOCK_UNLOCKED;
+}
+
+#ifdef CONFIG_PROC_FS
+static int sba_proc_info(char *buf, char **start, off_t offset, int len)
+{
+	struct sba_device *sba_dev = sba_list;
+	struct ioc *ioc = &sba_dev->ioc[0];	/* FIXME: Multi-IOC support! */
+	int total_pages = (int) (ioc->res_size << 3); /* 8 bits per byte */
+	unsigned long i = 0, avg = 0, min, max;
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
+	
+	sprintf(buf, "%sResource bitmap : %d bytes (%d pages)\n", 
+		buf, ioc->res_size, ioc->res_size << 3);   /* 8 bits per byte */
+
+	min = max = ioc->avg_search[0];
+	for (i = 0; i < SBA_SEARCH_SAMPLE; i++) {
+		avg += ioc->avg_search[i];
+		if (ioc->avg_search[i] > max) max = ioc->avg_search[i];
+		if (ioc->avg_search[i] < min) min = ioc->avg_search[i];
+	}
+	avg /= SBA_SEARCH_SAMPLE;
+	sprintf(buf, "%s  Bitmap search : %ld/%ld/%ld (min/avg/max CPU Cycles)\n",
+		buf, min, avg, max);
+
+	sprintf(buf, "%spci_map_single(): %12ld calls  %12ld pages (avg %d/1000)\n",
+		buf, ioc->msingle_calls, ioc->msingle_pages,
+		(int) ((ioc->msingle_pages * 1000)/ioc->msingle_calls));
+#ifdef ALLOW_IOV_BYPASS
+	sprintf(buf, "%spci_map_single(): %12ld bypasses\n",
+	        buf, ioc->msingle_bypass);
+#endif
+
+	sprintf(buf, "%spci_unmap_single: %12ld calls  %12ld pages (avg %d/1000)\n",
+		buf, ioc->usingle_calls, ioc->usingle_pages,
+		(int) ((ioc->usingle_pages * 1000)/ioc->usingle_calls));
+#ifdef ALLOW_IOV_BYPASS
+	sprintf(buf, "%spci_unmap_single: %12ld bypasses\n",
+	        buf, ioc->usingle_bypass);
+#endif
+
+	sprintf(buf, "%spci_map_sg()    : %12ld calls  %12ld pages (avg %d/1000)\n",
+		buf, ioc->msg_calls, ioc->msg_pages,
+		(int) ((ioc->msg_pages * 1000)/ioc->msg_calls));
+#ifdef ALLOW_IOV_BYPASS
+	sprintf(buf, "%spci_map_sg()    : %12ld bypasses\n",
+	        buf, ioc->msg_bypass);
+#endif
+
+	sprintf(buf, "%spci_unmap_sg()  : %12ld calls  %12ld pages (avg %d/1000)\n",
+		buf, ioc->usg_calls, ioc->usg_pages,
+		(int) ((ioc->usg_pages * 1000)/ioc->usg_calls));
+
+	return strlen(buf);
+}
+
+static int
+sba_resource_map(char *buf, char **start, off_t offset, int len)
+{
+	struct ioc *ioc = sba_list->ioc;	/* FIXME: Multi-IOC support! */
+	unsigned int *res_ptr = (unsigned int *)ioc->res_map;
+	int i;
+
+	buf[0] = '\0';
+	for(i = 0; i < (ioc->res_size / sizeof(unsigned int)); ++i, ++res_ptr) {
+		if ((i & 7) == 0)
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
+	u32 *func_offset = NULL;
+	int i, agp_found = 0;
+	static char sba_rev[6];
+	struct pci_dev *device = NULL;
+	u64 hpa = 0;
+
+	if (!(device = pci_find_device(PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_ZX1_SBA, NULL)))
+		return;
+
+	for (i = 0; i < PCI_NUM_RESOURCES; i++) {
+		if (pci_resource_flags(device, i) == IORESOURCE_MEM) {
+			hpa = ioremap(pci_resource_start(device, i),
+				pci_resource_len(device, i));
+			break;
+		}
+	}
+
+	func_id = READ_REG(hpa + SBA_FUNC_ID);
+
+	if (func_id == ZX1_FUNC_ID_VALUE) {
+		(void)strcpy(sba_rev, "zx1");
+		func_offset = zx1_func_offsets;
+	} else {
+		return;
+	}
+
+	/* Read HW Rev First */
+	hw_rev = READ_REG(hpa + SBA_FCLASS) & 0xFFUL;
+
+	/*
+	 * Not all revision registers of the chipset are updated on every
+	 * turn.  Must scan through all functions looking for the highest rev
+	 */
+	if (func_offset) {
+		for (i = 0 ; func_offset[i] != -1 ; i++) {
+			u32 func_rev;
+
+			func_rev = READ_REG(hpa + SBA_FCLASS + func_offset[i]) & 0xFFUL;
+			DBG_INIT("%s() func offset: 0x%x rev: 0x%x\n",
+			         __FUNCTION__, func_offset[i], func_rev);
+			if (func_rev > hw_rev)
+				hw_rev = func_rev;
+		}
+	}
+
+	printk(KERN_INFO "%s found %s %d.%d at %s, HPA 0x%lx\n", DRIVER_NAME,
+	       sba_rev, ((hw_rev >> 4) & 0xF), (hw_rev & 0xF),
+	       device->slot_name, hpa);
+
+	if ((hw_rev & 0xFF) < 0x20) {
+		printk(KERN_INFO "%s WARNING rev 2.0 or greater will be required for IO MMU support in the future\n", DRIVER_NAME);
+#ifndef CONFIG_IA64_HP_PROTO
+		panic("%s: CONFIG_IA64_HP_PROTO MUST be enabled to support SBA rev less than 2.0", DRIVER_NAME);
+#endif
+	}
+
+	sba_dev = kmalloc(sizeof(struct sba_device), GFP_KERNEL);
+	if (NULL == sba_dev) {
+		printk(KERN_ERR DRIVER_NAME " - couldn't alloc sba_device\n");
+		return;
+	}
+
+	memset(sba_dev, 0, sizeof(struct sba_device));
+
+	for(i=0; i<MAX_IOC; i++)
+		spin_lock_init(&(sba_dev->ioc[i].res_lock));
+
+	sba_dev->hw_rev = hw_rev;
+	sba_dev->sba_hpa = hpa;
+
+	/*
+	 * We need to check for an AGP device, if we find one, then only
+	 * use part of the IOVA space for PCI DMA, the rest is for GART.
+	 * REVISIT for multiple IOC.
+	 */
+	pci_for_each_dev(device)
+		agp_found |= pci_find_capability(device, PCI_CAP_ID_AGP);
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
+		proc_mckinley_root = proc_mkdir("bus/mckinley",0);
+		create_proc_info_entry(sba_rev, 0, proc_mckinley_root, sba_proc_info);
+		create_proc_info_entry("bitmap", 0, proc_mckinley_root, sba_resource_map);
+	}
+#endif
+}
+
+static int __init
+nosbagart (char *str)
+{
+	reserve_sba_gart = 0;
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
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/hp/sim/Makefile linux-2.4.18-ia64-020226-mv/arch/ia64/hp/sim/Makefile
--- linux-2.4.18-ia64-020226-orig/arch/ia64/hp/sim/Makefile	Wed Dec 31 17:00:00 1969
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/hp/sim/Makefile	Fri Apr  5 13:47:08 2002
@@ -0,0 +1,13 @@
+#
+# ia64/platform/hp/sim/Makefile
+#
+# Copyright (C) 1999 Silicon Graphics, Inc.
+# Copyright (C) Srinivasa Thirumalachar (sprasad@engr.sgi.com)
+#
+
+O_TARGET := sim.o
+
+obj-y := hpsim_console.o hpsim_irq.o hpsim_setup.o
+obj-$(CONFIG_IA64_GENERIC) += hpsim_machvec.o
+
+include $(TOPDIR)/Rules.make
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/hp/zx1/Makefile linux-2.4.18-ia64-020226-mv/arch/ia64/hp/zx1/Makefile
--- linux-2.4.18-ia64-020226-orig/arch/ia64/hp/zx1/Makefile	Wed Dec 31 17:00:00 1969
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/hp/zx1/Makefile	Fri Apr  5 13:47:08 2002
@@ -0,0 +1,13 @@
+#
+# ia64/platform/hp/zx1/Makefile
+#
+# Copyright (C) 2002 Hewlett Packard
+# Copyright (C) Alex Williamson (alex_williamson@hp.com)
+#
+
+O_TARGET := zx1.o
+
+obj-y := hpzx1_misc.o
+obj-$(CONFIG_IA64_GENERIC) += hpzx1_machvec.o
+
+include $(TOPDIR)/Rules.make
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/hp/zx1/hpzx1_machvec.c linux-2.4.18-ia64-020226-mv/arch/ia64/hp/zx1/hpzx1_machvec.c
--- linux-2.4.18-ia64-020226-orig/arch/ia64/hp/zx1/hpzx1_machvec.c	Wed Dec 31 17:00:00 1969
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/hp/zx1/hpzx1_machvec.c	Fri Apr  5 13:47:08 2002
@@ -0,0 +1,2 @@
+#define MACHVEC_PLATFORM_NAME	hpzx1
+#include <asm/machvec_init.h>
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/hp/zx1/hpzx1_misc.c linux-2.4.18-ia64-020226-mv/arch/ia64/hp/zx1/hpzx1_misc.c
--- linux-2.4.18-ia64-020226-orig/arch/ia64/hp/zx1/hpzx1_misc.c	Wed Dec 31 17:00:00 1969
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/hp/zx1/hpzx1_misc.c	Fri Apr  5 13:47:08 2002
@@ -0,0 +1,400 @@
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
+static struct fake_pci_dev *fake_pci_head, **fake_pci_tail = &fake_pci_head;
+
+static struct pci_ops orig_pci_ops;
+
+static inline struct fake_pci_dev *
+fake_pci_find_slot(unsigned char bus, unsigned int devfn)
+{
+	struct fake_pci_dev *dev;
+
+	for (dev = fake_pci_head; dev; dev = dev->next)
+		if (dev->bus == bus && dev->devfn == devfn)
+			return dev;
+	return NULL;
+}
+
+static struct fake_pci_dev *
+alloc_fake_pci_dev(void)
+{
+        struct fake_pci_dev *dev;
+
+        dev = kmalloc(sizeof(*dev), GFP_KERNEL);
+	if (!dev)
+		return NULL;
+
+	memset(dev, 0, sizeof(*dev));
+
+        *fake_pci_tail = dev;
+        fake_pci_tail = &dev->next;
+
+        return dev;
+}
+
+#define HP_CFG_RD(sz, bits, name) \
+static int hp_cfg_read##sz (struct pci_dev *dev, int where, u##bits *value) \
+{ \
+	struct fake_pci_dev *fake_dev; \
+	if (!(fake_dev = fake_pci_find_slot(dev->bus->number, dev->devfn))) \
+		return orig_pci_ops.name(dev, where, value); \
+	\
+	switch (where) { \
+	case PCI_COMMAND: \
+		*value = read##sz(fake_dev->mapped_csrs + where); \
+		*value |= PCI_COMMAND_MEMORY; /* SBA omits this */ \
+		break; \
+	case PCI_BASE_ADDRESS_0: \
+		if (fake_dev->sizing) \
+			*value = ~(fake_dev->csr_size - 1); \
+		else \
+			*value = (fake_dev->csr_base & \
+				    PCI_BASE_ADDRESS_MEM_MASK) | \
+				PCI_BASE_ADDRESS_SPACE_MEMORY; \
+		fake_dev->sizing = 0; \
+		break; \
+	default: \
+		*value = read##sz(fake_dev->mapped_csrs + where); \
+		break; \
+	} \
+	return PCIBIOS_SUCCESSFUL; \
+}
+
+#define HP_CFG_WR(sz, bits, name) \
+static int hp_cfg_write##sz (struct pci_dev *dev, int where, u##bits value) \
+{ \
+	struct fake_pci_dev *fake_dev; \
+	if (!(fake_dev = fake_pci_find_slot(dev->bus->number, dev->devfn))) \
+		return orig_pci_ops.name(dev, where, value); \
+	\
+	switch (where) { \
+	case PCI_BASE_ADDRESS_0: \
+		if (value == ~0) \
+			fake_dev->sizing = 1; \
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
+static struct pci_ops hp_pci_conf = {
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
+	for (slot = 0x1e; slot > HP_MAX_SLOT; slot--) {
+		if (!fake_pci_find_slot(bus, PCI_DEVFN(slot, 0)))
+			break;
+	}
+	if (slot == HP_MAX_SLOT) {
+		printk(KERN_ERR PFX
+			"no slot space for device (0x%p) on bus 0x%02x\n",
+			(void *) addr, bus);
+		return NULL;
+	}
+
+	dev = alloc_fake_pci_dev();
+	if (!dev) {
+		printk(KERN_ERR PFX
+			"no memory for device (0x%p) on bus 0x%02x\n",
+			(void *) addr, bus);
+		return NULL;
+	}
+
+	dev->bus = bus;
+	dev->devfn = PCI_DEVFN(slot, 0);
+	dev->csr_base = addr;
+	dev->csr_size = size;
+
+	/*
+	 * Drivers should ioremap what they need, but we have to do
+	 * it here, too, so PCI config accesses work.
+	 */
+	dev->mapped_csrs = ioremap(dev->csr_base, dev->csr_size);
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
+#define HP_CCSR_GUID \
+    ((efi_guid_t) { 0x69e9adf9, 0x924f, 0xab5f, { 0xf6, 0x4a, 0x24, 0xd2, 0x01, 0x37, 0x0e, 0xad }})
+
+extern acpi_status acpi_get_crs(acpi_handle, acpi_buffer *);
+extern acpi_resource *acpi_get_crs_next(acpi_buffer *, int *);
+extern acpi_resource_data *acpi_get_crs_type(acpi_buffer *, int *, int);
+extern void acpi_dispose_crs(acpi_buffer *);
+extern acpi_status acpi_cf_evaluate_method(acpi_handle, UINT8 *, NATIVE_UINT *);
+
+static acpi_status
+hp_csr_space(acpi_handle obj, u64 *csr_base, u64 *csr_length)
+{
+	int i, offset = 0;
+	acpi_status status;
+	acpi_buffer buf;
+	acpi_resource_vendor *res;
+	acpi_hp_vendor_long *hp_res;
+	efi_guid_t vendor_guid;
+
+	*csr_base = 0;
+	*csr_length = 0;
+
+	status = acpi_get_crs(obj, &buf);
+	if (status != AE_OK) {
+		printk(KERN_ERR PFX "Unable to get _CRS data on object\n");
+		return status;
+	}
+
+	res = (acpi_resource_vendor *)acpi_get_crs_type(&buf, &offset, ACPI_RSTYPE_VENDOR);
+	if (!res) {
+		printk(KERN_ERR PFX "Failed to find config space for device\n");
+		acpi_dispose_crs(&buf);
+		return AE_NOT_FOUND;
+	}
+
+	hp_res = (acpi_hp_vendor_long *)(res->reserved);
+
+	if (res->length != HP_CCSR_LENGTH || hp_res->guid_id != HP_CCSR_TYPE) {
+		printk(KERN_ERR PFX "Unknown Vendor data\n");
+		acpi_dispose_crs(&buf);
+		return AE_TYPE; /* Revisit error? */
+	}
+
+	memcpy(&vendor_guid, hp_res->guid, sizeof(efi_guid_t));
+	if (efi_guidcmp(vendor_guid, HP_CCSR_GUID) != 0) {
+		printk(KERN_ERR PFX "Vendor GUID does not match\n");
+		acpi_dispose_crs(&buf);
+		return AE_TYPE; /* Revisit error? */
+	}
+
+	for (i = 0 ; i < 8 ; i++) {
+		*csr_base |= ((u64)(hp_res->csr_base[i]) << (i * 8));
+		*csr_length |= ((u64)(hp_res->csr_length[i]) << (i * 8));
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
+	u64 csr_base = 0, csr_length = 0;
+	char *name = context;
+	struct fake_pci_dev *dev;
+	acpi_status status;
+
+	status = hp_csr_space(obj, &csr_base, &csr_length);
+
+	if (status != AE_OK)
+		return status;
+
+	/*
+	 * Only SBA shows up in ACPI namespace, so its CSR space
+	 * includes both SBA and IOC.  Make SBA and IOC show up
+	 * separately in PCI space.
+	 */
+	if ((dev = hpzx1_fake_pci_dev(csr_base, 0, 0x1000)))
+		printk(KERN_INFO PFX "%s SBA at 0x%lx; pci dev %02x:%02x.%d\n",
+			name, csr_base, dev->bus,
+			PCI_SLOT(dev->devfn), PCI_FUNC(dev->devfn));
+	if ((dev = hpzx1_fake_pci_dev(csr_base + 0x1000, 0, 0x1000)))
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
+	u64 csr_base = 0, csr_length = 0;
+	char *name = context;
+	NATIVE_UINT busnum = 0;
+	struct fake_pci_dev *dev;
+
+	status = hp_csr_space(obj, &csr_base, &csr_length);
+
+	if (status != AE_OK)
+		return status;
+
+	status = acpi_cf_evaluate_method(obj, METHOD_NAME__BBN, &busnum);
+	if (ACPI_FAILURE(status)) {
+		printk(KERN_ERR PFX "evaluate _BBN fail=0x%x\n", status);
+		busnum = 0;	// no _BBN; stick it on bus 0
+	}
+
+	if ((dev = hpzx1_fake_pci_dev(csr_base, busnum, csr_length)))
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
+	acpi_get_devices("HWP0001", hpzx1_sba_probe, "HWP0001", NULL);
+#ifdef CONFIG_IA64_HP_PROTO
+	if (fake_pci_tail != &fake_pci_head) {
+#endif
+	acpi_get_devices("HWP0002", hpzx1_lba_probe, "HWP0002", NULL);
+	acpi_get_devices("HWP0003", hpzx1_lba_probe, "HWP0003", NULL);
+
+#ifdef CONFIG_IA64_HP_PROTO
+	}
+
+#define ZX1_FUNC_ID_VALUE    (PCI_DEVICE_ID_HP_ZX1_SBA << 16) | PCI_VENDOR_ID_HP
+	/*
+	 * Early protos don't have bridges in the ACPI namespace, so
+	 * if we didn't find anything, add the things we know are
+	 * there.
+	 */
+	if (fake_pci_tail == &fake_pci_head) {
+		u64 hpa, csr_base;
+		struct fake_pci_dev *dev;
+
+		csr_base = 0xfed00000UL;
+		hpa = (u64) ioremap(csr_base, 0x1000);
+		if (__raw_readl(hpa) == ZX1_FUNC_ID_VALUE) {
+			if ((dev = hpzx1_fake_pci_dev(csr_base, 0, 0x1000)))
+				printk(KERN_INFO PFX "HWP0001 SBA at 0x%lx; "
+					"pci dev %02x:%02x.%d\n", csr_base,
+					dev->bus, PCI_SLOT(dev->devfn),
+					PCI_FUNC(dev->devfn));
+			if ((dev = hpzx1_fake_pci_dev(csr_base + 0x1000, 0,
+					0x1000)))
+				printk(KERN_INFO PFX "HWP0001 IOC at 0x%lx; "
+					"pci dev %02x:%02x.%d\n",
+					csr_base + 0x1000,
+					dev->bus, PCI_SLOT(dev->devfn),
+					PCI_FUNC(dev->devfn));
+
+			csr_base = 0xfed24000UL;
+			iounmap(hpa);
+			hpa = (u64) ioremap(csr_base, 0x1000);
+			if ((dev = hpzx1_fake_pci_dev(csr_base, 0x40, 0x1000)))
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
+	if (fake_pci_tail == &fake_pci_head)
+		return;
+
+	/*
+	 * Replace PCI ops, but only if we made fake devices.
+	 */
+	orig_pci_ops = pci_conf;
+	pci_conf = hp_pci_conf;
+}
+
+extern void sba_init(void);
+	
+void
+hpzx1_pci_fixup (int phase)
+{
+	if (phase == 0)
+		hpzx1_acpi_dev_init();
+	iosapic_pci_fixup(phase);
+        if (phase == 1)
+		sba_init();
+}
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/Makefile linux-2.4.18-ia64-020226-mv/arch/ia64/kernel/Makefile
--- linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/Makefile	Mon Apr  1 16:43:58 2002
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/kernel/Makefile	Fri Apr  5 13:47:08 2002
@@ -17,6 +17,7 @@
 	 machvec.o pal.o process.o perfmon.o ptrace.o sal.o salinfo.o semaphore.o setup.o	 \
 	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
 obj-$(CONFIG_IA64_GENERIC) += iosapic.o
+obj-$(CONFIG_IA64_HP_ZX1) += iosapic.o
 obj-$(CONFIG_IA64_DIG) += iosapic.o
 obj-$(CONFIG_IA64_PALINFO) += palinfo.o
 obj-$(CONFIG_EFI_VARS) += efivars.o
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/acpi.c linux-2.4.18-ia64-020226-mv/arch/ia64/kernel/acpi.c
--- linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/acpi.c	Mon Apr  1 16:43:58 2002
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/kernel/acpi.c	Fri Apr  5 16:26:49 2002
@@ -23,6 +23,7 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/irq.h>
+#include <linux/acpi.h>
 #ifdef CONFIG_SERIAL_ACPI
 #include <linux/acpi_serial.h>
 #endif
@@ -56,9 +57,34 @@
 const char *
 acpi_get_sysname (void)
 {
-	/* the following should go away once we have an ACPI parser: */
 #ifdef CONFIG_IA64_GENERIC
-	return "hpsim";
+	if (efi.acpi20) {
+		acpi20_rsdp_t *rsdp20;
+		acpi_xsdt_t *xsdt;
+		acpi_desc_table_hdr_t *hdrp;
+
+		rsdp20 = efi.acpi20;
+		if (strncmp(rsdp20->signature,
+		            ACPI_RSDP_SIG, ACPI_RSDP_SIG_LEN)) {
+			printk("ACPI 2.0 RSDP signature incorrect, default to DIG compatible\n");
+			return "dig";
+		}
+
+		xsdt = __va(rsdp20->xsdt);
+		hdrp = &xsdt->header;
+		if (strncmp(hdrp->signature,
+		            ACPI_XSDT_SIG, ACPI_XSDT_SIG_LEN)) {
+			printk("ACPI 2.0 XSDT signature incorrect, default to DIG compatible\n");
+			return "dig";
+		}
+
+		if (!strcmp(hdrp->oem_id, "HP")) {
+			printk("Enabling Hewlett Packard zx1 chipset support\n");
+			return "hpzx1";
+		}
+	}
+
+	return "dig";
 #else
 # if defined (CONFIG_IA64_HP_SIM)
 	return "hpsim";
@@ -66,13 +92,14 @@
 	return "sn1";
 # elif defined (CONFIG_IA64_SGI_SN2)
 	return "sn2";
+# elif defined (CONFIG_IA64_HP_ZX1)
+	return "hpzx1";
 # elif defined (CONFIG_IA64_DIG)
 	return "dig";
 # else
 #	error Unknown platform.  Fix acpi.c.
 # endif
 #endif
-
 }
 
 /*
@@ -677,3 +704,74 @@
 # endif /* CONFIG_ACPI */
 	return 1;
 }
+
+#ifdef CONFIG_ACPI
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
+/**
+ * acpi_get_crs - Return the current resource settings for a device
+ * obj: A handle for this device
+ * buf: A buffer to be populated by this call.
+ *
+ * Pass a valid handle, typically obtained by walking the namespace and a
+ * pointer to an allocated buffer, and this function will fill in the buffer
+ * with a list of acpi_resource structures.
+ */
+acpi_status acpi_get_crs(acpi_handle obj, acpi_buffer *buf)
+{
+	acpi_status result;
+	buf->length = 0;
+	buf->pointer = NULL;
+
+	result = acpi_get_current_resources(obj, buf);
+	if (result != AE_BUFFER_OVERFLOW)
+		return result;
+	buf->pointer = kmalloc(buf->length, GFP_KERNEL);
+	if (!buf->pointer)
+		return -ENOMEM;
+
+	result = acpi_get_current_resources(obj, buf);
+
+	return result;
+}
+
+acpi_resource *acpi_get_crs_next(acpi_buffer *buf, int *offset)
+{
+	acpi_resource *res;
+
+	if (*offset >= buf->length)
+		return NULL;
+
+	res = buf->pointer + *offset;
+	*offset += res->length;
+	return res;
+}
+
+acpi_resource_data *acpi_get_crs_type(acpi_buffer *buf, int *offset, int type)
+{
+	for (;;) {
+		acpi_resource *res = acpi_get_crs_next(buf, offset);
+		if (!res)
+			return NULL;
+		if (res->id == type)
+			return &res->data;
+	}
+}
+
+void acpi_dispose_crs(acpi_buffer *buf)
+{
+	kfree(buf->pointer);
+}
+#endif /* CONFIG_ACPI */
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/ia64_ksyms.c linux-2.4.18-ia64-020226-mv/arch/ia64/kernel/ia64_ksyms.c
--- linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/ia64_ksyms.c	Mon Apr  1 16:43:58 2002
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/kernel/ia64_ksyms.c	Fri Apr  5 13:47:08 2002
@@ -148,3 +148,10 @@
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
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/irq.c linux-2.4.18-ia64-020226-mv/arch/ia64/kernel/irq.c
--- linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/irq.c	Mon Apr  1 16:43:58 2002
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/kernel/irq.c	Fri Apr  5 13:47:08 2002
@@ -67,6 +67,23 @@
 irq_desc_t _irq_desc[NR_IRQS] __cacheline_aligned =
 	{ [0 ... NR_IRQS-1] = { IRQ_DISABLED, &no_irq_type, NULL, 0, SPIN_LOCK_UNLOCKED}};
 
+#ifdef CONFIG_IA64_GENERIC
+struct irq_desc * __ia64_irq_desc (unsigned int irq)
+{
+	return _irq_desc + irq;
+}
+
+ia64_vector __ia64_irq_to_vector (unsigned int irq)
+{
+	return (ia64_vector) irq;
+}
+
+unsigned int __ia64_local_vector_to_irq (ia64_vector vec)
+{
+	return (unsigned int) vec;
+}
+#endif
+
 static void register_irq_proc (unsigned int irq);
 
 /*
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/setup.c linux-2.4.18-ia64-020226-mv/arch/ia64/kernel/setup.c
--- linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/setup.c	Mon Apr  1 16:43:58 2002
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/kernel/setup.c	Fri Apr  5 13:47:08 2002
@@ -65,6 +65,8 @@
 
 unsigned long ia64_iobase;	/* virtual address for I/O accesses */
 
+unsigned char aux_device_present = 0xaa;        /* XXX remove this when legacy I/O is gone */
+
 #define COMMAND_LINE_SIZE	512
 
 char saved_command_line[COMMAND_LINE_SIZE]; /* used in proc filesystem */
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/arch/ia64/mm/tlb.c linux-2.4.18-ia64-020226-mv/arch/ia64/mm/tlb.c
--- linux-2.4.18-ia64-020226-orig/arch/ia64/mm/tlb.c	Fri Nov  9 15:26:17 2001
+++ linux-2.4.18-ia64-020226-mv/arch/ia64/mm/tlb.c	Fri Apr  5 13:47:08 2002
@@ -79,7 +79,7 @@
 	flush_tlb_all();
 }
 
-static inline void
+void
 ia64_global_tlb_purge (unsigned long start, unsigned long end, unsigned long nbits)
 {
 	static spinlock_t ptcg_lock = SPIN_LOCK_UNLOCKED;
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/drivers/acpi/acpiconf.c linux-2.4.18-ia64-020226-mv/drivers/acpi/acpiconf.c
--- linux-2.4.18-ia64-020226-orig/drivers/acpi/acpiconf.c	Mon Apr  1 16:43:59 2002
+++ linux-2.4.18-ia64-020226-mv/drivers/acpi/acpiconf.c	Fri Apr  5 13:47:08 2002
@@ -146,7 +146,7 @@
 } acpi_rpb_t;
 
 
-static acpi_status	__init
+acpi_status	__init
 acpi_cf_evaluate_method (
 	acpi_handle	handle,
 	UINT8		*method_name,
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/drivers/pci/pci.ids linux-2.4.18-ia64-020226-mv/drivers/pci/pci.ids
--- linux-2.4.18-ia64-020226-orig/drivers/pci/pci.ids	Mon Feb 25 12:38:03 2002
+++ linux-2.4.18-ia64-020226-mv/drivers/pci/pci.ids	Fri Apr  5 13:47:08 2002
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
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/include/asm-ia64/hw_irq.h linux-2.4.18-ia64-020226-mv/include/asm-ia64/hw_irq.h
--- linux-2.4.18-ia64-020226-orig/include/asm-ia64/hw_irq.h	Mon Apr  1 15:14:20 2002
+++ linux-2.4.18-ia64-020226-mv/include/asm-ia64/hw_irq.h	Fri Apr  5 15:52:44 2002
@@ -88,6 +88,7 @@
 
 extern struct irq_desc _irq_desc[NR_IRQS];
 
+#ifndef CONFIG_IA64_GENERIC
 static inline struct irq_desc *
 __ia64_irq_desc (unsigned int irq)
 {
@@ -105,6 +106,7 @@
 {
 	return (unsigned int) vec;
 }
+#endif
 
 /*
  * Next follows the irq descriptor interface.  On IA-64, each CPU supports 256 interrupt
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/include/asm-ia64/machvec.h linux-2.4.18-ia64-020226-mv/include/asm-ia64/machvec.h
--- linux-2.4.18-ia64-020226-orig/include/asm-ia64/machvec.h	Mon Apr  1 16:44:00 2002
+++ linux-2.4.18-ia64-020226-mv/include/asm-ia64/machvec.h	Fri Apr  5 15:52:44 2002
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
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/include/asm-ia64/machvec_hpzx1.h linux-2.4.18-ia64-020226-mv/include/asm-ia64/machvec_hpzx1.h
--- linux-2.4.18-ia64-020226-orig/include/asm-ia64/machvec_hpzx1.h	Wed Dec 31 17:00:00 1969
+++ linux-2.4.18-ia64-020226-mv/include/asm-ia64/machvec_hpzx1.h	Fri Apr  5 13:47:08 2002
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
+#define platform_pci_dma_sync_single	((ia64_mv_pci_dma_sync_single *) machvec_noop)
+#define platform_pci_dma_sync_sg	((ia64_mv_pci_dma_sync_sg *) machvec_noop)
+#define platform_pci_dma_address	sba_dma_address
+
+#endif /* _ASM_IA64_MACHVEC_HPZX1_h */
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/include/asm-ia64/machvec_init.h linux-2.4.18-ia64-020226-mv/include/asm-ia64/machvec_init.h
--- linux-2.4.18-ia64-020226-orig/include/asm-ia64/machvec_init.h	Thu Jan  4 13:50:17 2001
+++ linux-2.4.18-ia64-020226-mv/include/asm-ia64/machvec_init.h	Fri Apr  5 14:04:35 2002
@@ -5,6 +5,11 @@
 #include <asm/machvec.h>
 
 extern ia64_mv_send_ipi_t ia64_send_ipi;
+extern ia64_mv_global_tlb_purge_t ia64_global_tlb_purge;
+extern ia64_mv_irq_desc __ia64_irq_desc;
+extern ia64_mv_irq_to_vector __ia64_irq_to_vector;
+extern ia64_mv_local_vector_to_irq __ia64_local_vector_to_irq;
+
 extern ia64_mv_inb_t __ia64_inb;
 extern ia64_mv_inw_t __ia64_inw;
 extern ia64_mv_inl_t __ia64_inl;
diff -urN -X exclude linux-2.4.18-ia64-020226-orig/include/linux/pci_ids.h linux-2.4.18-ia64-020226-mv/include/linux/pci_ids.h
--- linux-2.4.18-ia64-020226-orig/include/linux/pci_ids.h	Mon Feb 25 12:38:13 2002
+++ linux-2.4.18-ia64-020226-mv/include/linux/pci_ids.h	Fri Apr  5 13:47:08 2002
@@ -505,6 +505,9 @@
 #define PCI_DEVICE_ID_HP_DIVA1		0x1049
 #define PCI_DEVICE_ID_HP_DIVA2		0x104A
 #define PCI_DEVICE_ID_HP_SP2_0		0x104B
+#define PCI_DEVICE_ID_HP_ZX1_SBA	0x1229
+#define PCI_DEVICE_ID_HP_ZX1_IOC	0x122a
+#define PCI_DEVICE_ID_HP_ZX1_LBA	0x122e
 
 #define PCI_VENDOR_ID_PCTECH		0x1042
 #define PCI_DEVICE_ID_PCTECH_RZ1000	0x1000

--------------Boundary-00=_5WD4QZJ4JOQ4NJQLX30X--

