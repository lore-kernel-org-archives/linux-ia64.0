From: Alex Williamson <alex_williamson@hp.com>
Date: Thu, 03 Apr 2003 17:49:05 +0000
Subject: [Linux-ia64] [PATCH] 1/4 zx1 updates
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------5BFD0B47F37B821588978C38"
Message-Id: <marc-linux-ia64-105590723705393@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------5BFD0B47F37B821588978C38
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


 Here's a series of patches that should make 2.5 more stable on
zx1 boxes.  This first patch includes a forward port of the
2.4 sba_iommu, removes the fake PCI components and reorganizes
some of the support routines.  Patch is against 2.5.64 + 030307.
Thanks,

	Alex

--
Alex Williamson                             HP Linux & Open Source Lab
--------------5BFD0B47F37B821588978C38
Content-Type: text/plain; charset=us-ascii;
 name="patch-01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-01.diff"

diff -urN linux-2.5.64/arch/ia64/hp/common/Makefile linux-work/arch/ia64/hp/common/Makefile
--- linux-2.5.64/arch/ia64/hp/common/Makefile	Tue Mar  4 20:29:34 2003
+++ linux-work/arch/ia64/hp/common/Makefile	Thu Apr  3 09:14:59 2003
@@ -5,4 +5,6 @@
 # Copyright (C) Alex Williamson (alex_williamson@hp.com)
 #
 
+# export-objs := sba_iommu.o
+
 obj-y := sba_iommu.o
diff -urN linux-2.5.64/arch/ia64/hp/common/sba_iommu.c linux-work/arch/ia64/hp/common/sba_iommu.c
--- linux-2.5.64/arch/ia64/hp/common/sba_iommu.c	Tue Mar  4 20:29:00 2003
+++ linux-work/arch/ia64/hp/common/sba_iommu.c	Thu Apr  3 08:42:11 2003
@@ -1,9 +1,9 @@
 /*
 **  IA64 System Bus Adapter (SBA) I/O MMU manager
 **
-**	(c) Copyright 2002 Alex Williamson
-**	(c) Copyright 2002 Grant Grundler
-**	(c) Copyright 2002 Hewlett-Packard Company
+**	(c) Copyright 2002-2003 Alex Williamson
+**	(c) Copyright 2002-2003 Grant Grundler
+**	(c) Copyright 2002-2003 Hewlett-Packard Company
 **
 **	Portions (c) 2000 Grant Grundler (from parisc I/O MMU code)
 **	Portions (c) 1999 Dave S. Miller (from sparc64 I/O MMU code)
@@ -30,17 +30,38 @@
 #include <linux/string.h>
 #include <linux/pci.h>
 #include <linux/proc_fs.h>
+#include <linux/acpi.h>
 #include <linux/efi.h>
 
 #include <asm/delay.h>		/* ia64_get_itc() */
 #include <asm/io.h>
 #include <asm/page.h>		/* PAGE_OFFSET */
+#include <asm/dma.h>
+#include <asm/system.h>		/* wmb() */
 
+#include <asm/acpi-ext.h>
 
-#define DRIVER_NAME "SBA"
+#define PFX "IOC: "
 
+/*
+** This option allows cards capable of 64bit DMA to bypass the IOMMU.  If
+** not defined, all DMA will be 32bit and go through the TLB.
+*/
 #define ALLOW_IOV_BYPASS
+
+/*
+** If a device prefetches beyond the end of a valid pdir entry, it will cause
+** a hard failure, ie. MCA.  Version 3.0 and later of the zx1 LBA should
+** disconnect on 4k boundaries and prevent such issues.  If the device is
+** particularly agressive, this option will keep the entire pdir valid such
+** that prefetching will hit a valid address.  This could severely impact
+** error containment, and is therefore off by default.  The page that is
+** used for spill-over is poisoned, so that should help debugging somewhat.
+*/
+#undef FULL_VALID_PDIR
+
 #define ENABLE_MARK_CLEAN
+
 /*
 ** The number of debug flags is a clue - this code is fragile.
 */
@@ -52,6 +73,10 @@
 #undef DEBUG_LARGE_SG_ENTRIES
 #undef DEBUG_BYPASS
 
+#if defined(FULL_VALID_PDIR) && defined(ASSERT_PDIR_SANITY)
+#error FULL_VALID_PDIR and ASSERT_PDIR_SANITY are mutually exclusive
+#endif
+
 #define SBA_INLINE	__inline__
 /* #define SBA_INLINE */
 
@@ -96,10 +121,6 @@
 #define ASSERT(expr)
 #endif
 
-#define KB(x) ((x) * 1024)
-#define MB(x) (KB (KB (x)))
-#define GB(x) (MB (KB (x)))
-
 /*
 ** The number of pdir entries to "free" before issueing
 ** a read to PCOM register to flush out PCOM writes.
@@ -109,30 +130,23 @@
 */
 #define DELAYED_RESOURCE_CNT	16
 
-#define DEFAULT_DMA_HINT_REG(d)	0
-
-#define ZX1_FUNC_ID_VALUE    ((PCI_DEVICE_ID_HP_ZX1_SBA << 16) | PCI_VENDOR_ID_HP)
-#define ZX1_MC_ID    ((PCI_DEVICE_ID_HP_ZX1_MC << 16) | PCI_VENDOR_ID_HP)
+#define DEFAULT_DMA_HINT_REG	0
 
-#define SBA_FUNC_ID	0x0000	/* function id */
-#define SBA_FCLASS	0x0008	/* function class, bist, header, rev... */
+#define ZX1_IOC_ID	((PCI_DEVICE_ID_HP_ZX1_IOC << 16) | PCI_VENDOR_ID_HP)
+#define REO_IOC_ID	((PCI_DEVICE_ID_HP_REO_IOC << 16) | PCI_VENDOR_ID_HP)
 
-#define SBA_FUNC_SIZE	0x10000   /* SBA configuration function reg set */
-
-unsigned int __initdata zx1_func_offsets[] = {0x1000, 0x4000, 0x8000,
-                                              0x9000, 0xa000, -1};
-
-#define SBA_IOC_OFFSET	0x1000
-
-#define MAX_IOC		1	/* we only have 1 for now*/
+#define ZX1_IOC_OFFSET	0x1000	/* ACPI reports SBA, we want IOC */
 
+#define IOC_FUNC_ID	0x000
+#define IOC_FCLASS	0x008	/* function class, bist, header, rev... */
 #define IOC_IBASE	0x300	/* IO TLB */
 #define IOC_IMASK	0x308
 #define IOC_PCOM	0x310
 #define IOC_TCNFG	0x318
 #define IOC_PDIR_BASE	0x320
 
-#define IOC_IOVA_SPACE_BASE	0x40000000 /* IOVA ranges start at 1GB */
+/* AGP GART driver looks for this */
+#define ZX1_SBA_IOMMU_COOKIE	0x0000badbadc0ffeeUL
 
 /*
 ** IOC supports 4/8/16/64KB page sizes (see TCNFG register)
@@ -152,7 +166,7 @@
 #define IOVP_MASK	PAGE_MASK
 
 struct ioc {
-	unsigned long	ioc_hpa;	/* I/O MMU base address */
+	void		*ioc_hpa;	/* I/O MMU base address */
 	char		*res_map;	/* resource map, bit == pdir entry */
 	u64		*pdir_base;	/* physical base address */
 	unsigned long	ibase;		/* pdir IOV Space base */
@@ -193,37 +207,32 @@
 #endif
 #endif
 
-	/* STUFF We don't need in performance path */
+	/* Stuff we don't need in performance path */
+	struct ioc	*next;		/* list of IOC's in system */
+	acpi_handle	handle;		/* for multiple IOC's */
+	const char 	*name;
+	unsigned int	func_id;
+	unsigned int	rev;		/* HW revision of chip */
+	u32		iov_size;
 	unsigned int	pdir_size;	/* in bytes, determined by IOV Space size */
+	struct pci_dev	*sac_only_dev;
 };
 
-struct sba_device {
-	struct sba_device	*next;	/* list of SBA's in system */
-	const char 		*name;
-	unsigned long		sba_hpa; /* base address */
-	spinlock_t		sba_lock;
-	unsigned int		flags;  /* state/functionality enabled */
-	unsigned int		hw_rev;  /* HW revision of chip */
-
-	unsigned int		num_ioc;  /* number of on-board IOC's */
-	struct ioc		ioc[MAX_IOC];
-};
+static struct ioc *ioc_list;
+static int reserve_sba_gart = 1;
 
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,5,0)
+#define sba_sg_address(sg)	(page_address((sg)->page) + (sg)->offset)
+#else
+#define sba_sg_address(sg)	((sg)->address ? (sg)->address : \
+                                  page_address((sg)->page) + (sg)->offset)
+#endif
 
-static struct sba_device *sba_list;
-static int sba_count;
-static int reserve_sba_gart = 1;
-static struct pci_dev sac_only_dev;
+#ifdef FULL_VALID_PDIR
+static void* prefetch_spill_page;
+#endif
 
-#define sba_sg_address(sg) (page_address((sg)->page) + (sg)->offset)
-#define sba_sg_len(sg) (sg->length)
-#define sba_sg_iova(sg) (sg->dma_address)
-#define sba_sg_iova_len(sg) (sg->dma_length)
-
-/* REVISIT - fix me for multiple SBAs/IOCs */
-#define GET_IOC(dev) (sba_list->ioc)
-#define SBA_SET_AGP(sba_dev) (sba_dev->flags |= 0x1)
-#define SBA_GET_AGP(sba_dev) (sba_dev->flags & 0x1)
+#define GET_IOC(dev)	((struct ioc *) PCI_CONTROLLER(dev)->iommu)
 
 /*
 ** DMA_CHUNK_SIZE is used by the SCSI mid-layer to break up
@@ -232,10 +241,7 @@
 ** rather than the HW. I/O MMU allocation alogorithms can be
 ** faster with smaller size is (to some degree).
 */
-#define DMA_CHUNK_SIZE  (BITS_PER_LONG*IOVP_SIZE)
-
-/* Looks nice and keeps the compiler happy */
-#define SBA_DEV(d) ((struct sba_device *) (d))
+#define DMA_CHUNK_SIZE  (BITS_PER_LONG*PAGE_SIZE)
 
 #define ROUNDUP(x,y) ((x + ((y)-1)) & ~((y)-1))
 
@@ -255,7 +261,7 @@
  * sba_dump_tlb - debugging only - print IOMMU operating parameters
  * @hpa: base address of the IOMMU
  *
- * Print the size/location of the IO MMU Pdir.
+ * Print the size/location of the IO MMU PDIR.
  */
 static void
 sba_dump_tlb(char *hpa)
@@ -273,12 +279,12 @@
 #ifdef ASSERT_PDIR_SANITY
 
 /**
- * sba_dump_pdir_entry - debugging only - print one IOMMU Pdir entry
+ * sba_dump_pdir_entry - debugging only - print one IOMMU PDIR entry
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @msg: text to print ont the output line.
  * @pide: pdir index.
  *
- * Print one entry of the IO MMU Pdir in human readable form.
+ * Print one entry of the IO MMU PDIR in human readable form.
  */
 static void
 sba_dump_pdir_entry(struct ioc *ioc, char *msg, uint pide)
@@ -359,17 +365,17 @@
  * print the SG list so we can verify it's correct by hand.
  */
 static void
-sba_dump_sg(struct ioc *ioc, struct scatterlist *startsg, int nents)
+sba_dump_sg( struct ioc *ioc, struct scatterlist *startsg, int nents)
 {
 	while (nents-- > 0) {
 		printk(KERN_DEBUG " %d : DMA %08lx/%05x CPU %p\n", nents,
-		       (unsigned long) sba_sg_iova(startsg), sba_sg_iova_len(startsg),
+		       startsg->dma_address, startsg->dma_length,
 		       sba_sg_address(startsg));
 		startsg++;
 	}
 }
 static void
-sba_check_sg(struct ioc *ioc, struct scatterlist *startsg, int nents)
+sba_check_sg( struct ioc *ioc, struct scatterlist *startsg, int nents)
 {
 	struct scatterlist *the_sg = startsg;
 	int the_nents = nents;
@@ -401,6 +407,7 @@
 #define SBA_IOVA(ioc,iovp,offset,hint_reg) ((ioc->ibase) | (iovp) | (offset) | ((hint_reg)<<(ioc->hint_shift_pdir)))
 #define SBA_IOVP(ioc,iova) (((iova) & ioc->hint_mask_pdir) & ~(ioc->ibase))
 
+/* FIXME : review these macros to verify correctness and usage */
 #define PDIR_INDEX(iovp)   ((iovp)>>IOVP_SHIFT)
 
 #define RESMAP_MASK(n)    ~(~0UL << (n))
@@ -408,7 +415,7 @@
 
 
 /**
- * sba_search_bitmap - find free space in IO Pdir resource bitmap
+ * sba_search_bitmap - find free space in IO PDIR resource bitmap
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @bits_wanted: number of entries we need.
  *
@@ -445,7 +452,7 @@
 		** We need the alignment to invalidate I/O TLB using
 		** SBA HW features in the unmap path.
 		*/
-		unsigned long o = 1UL << get_order(bits_wanted << IOVP_SHIFT);
+		unsigned long o = 1 << get_order(bits_wanted << PAGE_SHIFT);
 		uint bitshiftcnt = ROUNDUP(ioc->res_bitshift, o);
 		unsigned long mask;
 
@@ -491,7 +498,7 @@
 
 
 /**
- * sba_alloc_range - find free bits and mark them in IO Pdir resource bitmap
+ * sba_alloc_range - find free bits and mark them in IO PDIR resource bitmap
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @size: number of bytes to create a mapping for
  *
@@ -520,7 +527,7 @@
 	if (pide >= (ioc->res_size << 3)) {
 		pide = sba_search_bitmap(ioc, pages_needed);
 		if (pide >= (ioc->res_size << 3))
-			panic(__FILE__ ": I/O MMU @ %lx is out of mapping resources\n", ioc->ioc_hpa);
+			panic(__FILE__ ": I/O MMU @ %p is out of mapping resources\n", ioc->ioc_hpa);
 	}
 
 #ifdef ASSERT_PDIR_SANITY
@@ -553,7 +560,7 @@
 
 
 /**
- * sba_free_range - unmark bits in IO Pdir resource bitmap
+ * sba_free_range - unmark bits in IO PDIR resource bitmap
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @iova: IO virtual address which was previously allocated.
  * @size: number of bytes to create a mapping for
@@ -600,14 +607,14 @@
 
 
 /**
- * sba_io_pdir_entry - fill in one IO Pdir entry
- * @pdir_ptr:  pointer to IO Pdir entry
- * @phys_page: phys CPU address of page to map
+ * sba_io_pdir_entry - fill in one IO PDIR entry
+ * @pdir_ptr:  pointer to IO PDIR entry
+ * @vba: Virtual CPU address of buffer to map
  *
  * SBA Mapping Routine
  *
- * Given a physical address (phys_page, arg1) sba_io_pdir_entry()
- * loads the I/O Pdir entry pointed to by pdir_ptr (arg0).
+ * Given a virtual address (vba, arg1) sba_io_pdir_entry()
+ * loads the I/O PDIR entry pointed to by pdir_ptr (arg0).
  * Each IO Pdir entry consists of 8 bytes as shown below
  * (LSB == bit 0):
  *
@@ -619,12 +626,20 @@
  *  V  == Valid Bit
  *  U  == Unused
  * PPN == Physical Page Number
+ *
+ * The physical address fields are filled with the results of virt_to_phys()
+ * on the vba.
  */
 
-#define SBA_VALID_MASK	0x80000000000000FFULL
-#define sba_io_pdir_entry(pdir_ptr, phys_page) *pdir_ptr = (phys_page | SBA_VALID_MASK)
-#define sba_io_page(pdir_ptr) (*pdir_ptr & ~SBA_VALID_MASK)
-
+#if 1
+#define sba_io_pdir_entry(pdir_ptr, vba) *pdir_ptr = ((vba & ~0xE000000000000FFFULL) | 0x8000000000000000ULL)
+#else
+void SBA_INLINE
+sba_io_pdir_entry(u64 *pdir_ptr, unsigned long vba)
+{
+	*pdir_ptr = ((vba & ~0xE000000000000FFFULL) | 0x80000000000000FFULL);
+}
+#endif
 
 #ifdef ENABLE_MARK_CLEAN
 /**
@@ -640,7 +655,7 @@
 	pg_addr = PAGE_ALIGN((unsigned long) addr);
 	end = (unsigned long) addr + size;
 	while (pg_addr + PAGE_SIZE <= end) {
-		struct page *page = virt_to_page(pg_addr);
+		struct page *page = virt_to_page((void *)pg_addr);
 		set_bit(PG_arch_1, &page->flags);
 		pg_addr += PAGE_SIZE;
 	}
@@ -648,12 +663,12 @@
 #endif
 
 /**
- * sba_mark_invalid - invalidate one or more IO Pdir entries
+ * sba_mark_invalid - invalidate one or more IO PDIR entries
  * @ioc: IO MMU structure which owns the pdir we are interested in.
  * @iova:  IO Virtual Address mapped earlier
  * @byte_cnt:  number of bytes this mapping covers.
  *
- * Marking the IO Pdir entry(ies) as Invalid and invalidate
+ * Marking the IO PDIR entry(ies) as Invalid and invalidate
  * corresponding IO TLB entry. The PCOM (Purge Command Register)
  * is to purge stale entries in the IO TLB when unmapping entries.
  *
@@ -687,15 +702,24 @@
 
 		iovp |= IOVP_SHIFT;     /* set "size" field for PCOM */
 
+#ifndef FULL_VALID_PDIR
 		/*
-		** clear I/O Pdir entry "valid" bit
+		** clear I/O PDIR entry "valid" bit
 		** Do NOT clear the rest - save it for debugging.
 		** We should only clear bits that have previously
 		** been enabled.
 		*/
-		ioc->pdir_base[off] &= ~SBA_VALID_MASK;
+		ioc->pdir_base[off] &= ~(0x80000000000000FFULL);
+#else
+		/*
+  		** If we want to maintain the PDIR as valid, put in
+		** the spill page so devices prefetching won't
+		** cause a hard fail.
+		*/
+		ioc->pdir_base[off] = (0x80000000000000FFULL | (u64)prefetch_spill_page);
+#endif
 	} else {
-		u32 t = get_order(byte_cnt) + IOVP_SHIFT;
+		u32 t = get_order(byte_cnt) + PAGE_SHIFT;
 
 		iovp |= t;
 		ASSERT(t <= 31);   /* 2GB! Max value of "size" field */
@@ -703,14 +727,18 @@
 		do {
 			/* verify this pdir entry is enabled */
 			ASSERT(ioc->pdir_base[off]  >> 63);
+#ifndef FULL_VALID_PDIR
 			/* clear I/O Pdir entry "valid" bit first */
-			ioc->pdir_base[off] &= ~SBA_VALID_MASK;
+			ioc->pdir_base[off] &= ~(0x80000000000000FFULL);
+#else
+			ioc->pdir_base[off] = (0x80000000000000FFULL | (u64)prefetch_spill_page);
+#endif
 			off++;
 			byte_cnt -= IOVP_SIZE;
 		} while (byte_cnt > 0);
 	}
 
-	WRITE_REG(iovp, ioc->ioc_hpa+IOC_PCOM);
+	WRITE_REG(iovp | ioc->ibase, ioc->ioc_hpa+IOC_PCOM);
 }
 
 /**
@@ -732,12 +760,9 @@
 	u64 *pdir_start;
 	int pide;
 #ifdef ALLOW_IOV_BYPASS
-	unsigned long phys_addr = virt_to_phys(addr);
+	unsigned long pci_addr = virt_to_phys(addr);
 #endif
 
-	if (!sba_list)
-		panic("sba_map_single: no SBA found!\n");
-
 	ioc = GET_IOC(dev);
 	ASSERT(ioc);
 
@@ -745,7 +770,7 @@
 	/*
  	** Check if the PCI device can DMA to ptr... if so, just return ptr
  	*/
-	if ((phys_addr & ~dev->dma_mask) == 0) {
+	if ((pci_addr & ~dev->dma_mask) == 0) {
 		/*
  		** Device is bit capable of DMA'ing to the buffer...
 		** just return the PCI address of ptr
@@ -756,8 +781,8 @@
 		spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif
 		DBG_BYPASS("sba_map_single() bypass mask/addr: 0x%lx/0x%lx\n",
-		           dev->dma_mask, phys_addr);
-		return phys_addr;
+		           dev->dma_mask, pci_addr);
+		return pci_addr;
 	}
 #endif
 
@@ -790,8 +815,7 @@
 
 	while (size > 0) {
 		ASSERT(((u8 *)pdir_start)[7] == 0); /* verify availability */
-
-		sba_io_pdir_entry(pdir_start, virt_to_phys(addr));
+		sba_io_pdir_entry(pdir_start, (unsigned long) addr);
 
 		DBG_RUN("     pdir 0x%p %lx\n", pdir_start, *pdir_start);
 
@@ -799,12 +823,15 @@
 		size -= IOVP_SIZE;
 		pdir_start++;
 	}
+	/* force pdir update */
+	wmb();
+
 	/* form complete address */
 #ifdef ASSERT_PDIR_SANITY
 	sba_check_pdir(ioc,"Check after sba_map_single()");
 #endif
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
-	return SBA_IOVA(ioc, iovp, offset, DEFAULT_DMA_HINT_REG(direction));
+	return SBA_IOVA(ioc, iovp, offset, DEFAULT_DMA_HINT_REG);
 }
 
 /**
@@ -826,9 +853,6 @@
 	unsigned long flags; 
 	dma_addr_t offset;
 
-	if (!sba_list)
-		panic("sba_map_single: no SBA found!\n");
-
 	ioc = GET_IOC(dev);
 	ASSERT(ioc);
 
@@ -861,29 +885,6 @@
 	size += offset;
 	size = ROUNDUP(size, IOVP_SIZE);
 
-#ifdef ENABLE_MARK_CLEAN
-	/*
-	** Don't need to hold the spinlock while telling VM pages are "clean".
-	** The pages are "busy" in the resource map until we mark them free.
-	** But tell VM pages are clean *before* releasing the resource
-	** in order to avoid race conditions.
-	*/
-	if (direction == PCI_DMA_FROMDEVICE) {
-		u32 iovp = (u32) SBA_IOVP(ioc,iova);
-		unsigned int pide = PDIR_INDEX(iovp);
-		u64 *pdirp = &(ioc->pdir_base[pide]);
-		size_t byte_cnt = size;
-		void *addr;
-
-		do {
-			addr = phys_to_virt(sba_io_page(pdirp));
-			mark_clean(addr, min(byte_cnt, IOVP_SIZE));
-			pdirp++;
-			byte_cnt -= IOVP_SIZE;
-		} while (byte_cnt > 0);
-	}
-#endif
-
 	spin_lock_irqsave(&ioc->res_lock, flags);
 #ifdef CONFIG_PROC_FS
 	ioc->usingle_calls++;
@@ -909,7 +910,40 @@
 	sba_free_range(ioc, iova, size);
 	READ_REG(ioc->ioc_hpa+IOC_PCOM);	/* flush purges */
 #endif /* DELAYED_RESOURCE_CNT == 0 */
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
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
+
+	/* XXX REVISIT for 2.5 Linux - need syncdma for zero-copy support.
+	** For Astro based systems this isn't a big deal WRT performance.
+	** As long as 2.4 kernels copyin/copyout data from/to userspace,
+	** we don't need the syncdma. The issue here is I/O MMU cachelines
+	** are *not* coherent in all cases.  May be hwrev dependent.
+	** Need to investigate more.
+	asm volatile("syncdma");	
+	*/
 }
 
 
@@ -924,6 +958,7 @@
 void *
 sba_alloc_consistent(struct pci_dev *hwdev, size_t size, dma_addr_t *dma_handle)
 {
+	struct ioc *ioc;
 	void *ret;
 
 	if (!hwdev) {
@@ -941,7 +976,8 @@
 		 * than dma_mask from the device, this needs to be
 		 * updated.
 		 */
-		*dma_handle = sba_map_single(&sac_only_dev, ret, size, 0);
+		ioc = GET_IOC(hwdev);
+		*dma_handle = sba_map_single(ioc->sac_only_dev, ret, size, 0);
 	}
 
 	return ret;
@@ -965,109 +1001,237 @@
 }
 
 
+/*
+** Since 0 is a valid pdir_base index value, can't use that
+** to determine if a value is valid or not. Use a flag to indicate
+** the SG list entry contains a valid pdir index.
+*/
+#define PIDE_FLAG 0x1UL
+
 #ifdef DEBUG_LARGE_SG_ENTRIES
 int dump_run_sg = 0;
 #endif
 
-#define SG_ENT_VIRT_PAGE(sg) page_address((sg)->page)
-#define SG_ENT_PHYS_PAGE(SG) virt_to_phys(SG_ENT_VIRT_PAGE(SG))
-
 
 /**
- * sba_coalesce_chunks - preprocess the SG list
+ * sba_fill_pdir - write allocated SG entries into IO PDIR
  * @ioc: IO MMU structure which owns the pdir we are interested in.
- * @startsg:  input=SG list	output=DMA addr/len pairs filled in
+ * @startsg:  list of IOVA/size pairs
  * @nents: number of entries in startsg list
- * @direction: R/W or both.
- *
- * Walk the SG list and determine where the breaks are in the DMA stream.
- * Allocate IO Pdir resources and fill them in separate loop.
- * Returns the number of DMA streams used for output IOVA list.
- * Note each DMA stream can consume multiple IO Pdir entries.
  *
- * Code is written assuming some coalescing is possible.
+ * Take preprocessed SG list and write corresponding entries
+ * in the IO PDIR.
  */
+
 static SBA_INLINE int
-sba_coalesce_chunks(struct ioc *ioc, struct scatterlist *startsg,
-	int nents, int direction)
+sba_fill_pdir(
+	struct ioc *ioc,
+	struct scatterlist *startsg,
+	int nents)
 {
-	struct scatterlist *dma_sg = startsg;	/* return array */
+	struct scatterlist *dma_sg = startsg;	/* pointer to current DMA */
 	int n_mappings = 0;
+	u64 *pdirp = 0;
+	unsigned long dma_offset = 0;
 
-	ASSERT(nents > 1);
+	dma_sg--;
+	while (nents-- > 0) {
+		int     cnt = startsg->dma_length;
+		startsg->dma_length = 0;
 
-	do {
-		unsigned int dma_cnt = 1; /* number of pages in DMA stream */
-		unsigned int pide;	/* index into IO Pdir array */
-		u64 *pdirp;		/* pointer into IO Pdir array */
-		unsigned long dma_offset, dma_len; /* cumulative DMA stream */
+#ifdef DEBUG_LARGE_SG_ENTRIES
+		if (dump_run_sg)
+			printk(" %2d : %08lx/%05x %p\n",
+				nents, startsg->dma_address, cnt,
+				sba_sg_address(startsg));
+#else
+		DBG_RUN_SG(" %d : %08lx/%05x %p\n",
+				nents, startsg->dma_address, cnt,
+				sba_sg_address(startsg));
+#endif
+		/*
+		** Look for the start of a new DMA stream
+		*/
+		if (startsg->dma_address & PIDE_FLAG) {
+			u32 pide = startsg->dma_address & ~PIDE_FLAG;
+			dma_offset = (unsigned long) pide & ~IOVP_MASK;
+			startsg->dma_address = 0;
+			dma_sg++;
+			dma_sg->dma_address = pide | ioc->ibase;
+			pdirp = &(ioc->pdir_base[pide >> IOVP_SHIFT]);
+			n_mappings++;
+		}
 
 		/*
-		** Prepare for first/next DMA stream
+		** Look for a VCONTIG chunk
 		*/
-		dma_len = sba_sg_len(startsg);
-		dma_offset = (unsigned long) sba_sg_address(startsg);
+		if (cnt) {
+			unsigned long vaddr = (unsigned long) sba_sg_address(startsg);
+			ASSERT(pdirp);
+
+			/* Since multiple Vcontig blocks could make up
+			** one DMA stream, *add* cnt to dma_len.
+			*/
+			dma_sg->dma_length += cnt;
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
 		startsg++;
-		nents--;
+	}
+	/* force pdir update */
+	wmb();
+
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
+		unsigned long vaddr = (unsigned long) sba_sg_address(startsg); 
 
 		/*
-		** We want to know how many entries can be coalesced
-		** before trying to allocate IO Pdir space.
-		** IOVAs can then be allocated "naturally" aligned
-		** to take advantage of the block IO TLB flush.
+		** Prepare for first/next DMA stream
 		*/
-		while (nents) {
-			unsigned long end_offset = dma_offset + dma_len;
+		dma_sg = vcontig_sg = startsg;
+		dma_len = vcontig_len = vcontig_end = startsg->length;
+		vcontig_end +=  vaddr;
+		dma_offset = vaddr & ~IOVP_MASK;
 
-			/* prev entry must end on a page boundary */
-			if (end_offset & IOVP_MASK)
-				break;
+		/* PARANOID: clear entries */
+		startsg->dma_address = startsg->dma_length = 0;
 
-			/* next entry start on a page boundary? */
-			if (startsg->offset)
-				break;
+		/*
+		** This loop terminates one iteration "early" since
+		** it's always looking one "ahead".
+		*/
+		while (--nents > 0) {
+			unsigned long vaddr;	/* tmp */
+
+			startsg++;
+
+			/* PARANOID */
+			startsg->dma_address = startsg->dma_length = 0;
+
+			/* catch brokenness in SCSI layer */
+			ASSERT(startsg->length <= DMA_CHUNK_SIZE);
 
 			/*
-			** make sure current dma stream won't exceed
-			** DMA_CHUNK_SIZE if coalescing entries.
+			** First make sure current dma stream won't
+			** exceed DMA_CHUNK_SIZE if we coalesce the
+			** next entry.
 			*/
-			if (((end_offset + startsg->length + ~IOVP_MASK)
-								& IOVP_MASK)
-					> DMA_CHUNK_SIZE)
+			if (((dma_len + dma_offset + startsg->length + ~IOVP_MASK) & IOVP_MASK) > DMA_CHUNK_SIZE)
 				break;
 
-			dma_len += sba_sg_len(startsg);
-			startsg++;
-			nents--;
-			dma_cnt++;
-		}
+			/*
+			** Then look for virtually contiguous blocks.
+			**
+			** append the next transaction?
+			*/
+			vaddr = (unsigned long) sba_sg_address(startsg);
+			if  (vcontig_end == vaddr)
+			{
+				vcontig_len += startsg->length;
+				vcontig_end += startsg->length;
+				dma_len     += startsg->length;
+				continue;
+			}
 
-		ASSERT(dma_len <= DMA_CHUNK_SIZE);
+#ifdef DEBUG_LARGE_SG_ENTRIES
+			dump_run_sg = (vcontig_len > IOVP_SIZE);
+#endif
 
-		/* allocate IO Pdir resource.
-		** returns index into (u64) IO Pdir array.
-		** IOVA is formed from this.
-		*/
-		pide = sba_alloc_range(ioc, dma_cnt << IOVP_SHIFT);
-		pdirp = &(ioc->pdir_base[pide]);
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
+			vcontig_sg->dma_length = vcontig_len;
 
-		/* fill_pdir: write stream into IO Pdir */
-		while (dma_cnt--) {
-			sba_io_pdir_entry(pdirp, SG_ENT_PHYS_PAGE(startsg));
-			startsg++;
-			pdirp++;
-		}
+			vcontig_sg = startsg;
+			vcontig_len = startsg->length;
 
-		/* "output" IOVA */
-		sba_sg_iova(dma_sg) = SBA_IOVA(ioc,
-					((dma_addr_t) pide << IOVP_SHIFT),
-					dma_offset,
-					DEFAULT_DMA_HINT_REG(direction));
-		sba_sg_iova_len(dma_sg) = dma_len;
+			/*
+			** 3) do the entries end/start on page boundaries?
+			**    Don't update vcontig_end until we've checked.
+			*/
+			if (DMA_CONTIG(vcontig_end, vaddr))
+			{
+				vcontig_end = vcontig_len + vaddr;
+				dma_len += vcontig_len;
+				continue;
+			} else {
+				break;
+			}
+		}
 
-		dma_sg++;
+		/*
+		** End of DMA Stream
+		** Terminate last VCONTIG block.
+		** Allocate space for DMA stream.
+		*/
+		vcontig_sg->dma_length = vcontig_len;
+		dma_len = (dma_len + dma_offset + ~IOVP_MASK) & IOVP_MASK;
+		ASSERT(dma_len <= DMA_CHUNK_SIZE);
+		dma_sg->dma_address = (dma_addr_t) (PIDE_FLAG 
+			| (sba_alloc_range(ioc, dma_len) << IOVP_SHIFT)
+			| dma_offset);
 		n_mappings++;
-	} while (nents);
+	}
 
 	return n_mappings;
 }
@@ -1075,7 +1239,7 @@
 
 /**
  * sba_map_sg - map Scatter/Gather list
- * @dev: instance of PCI device owned by the driver that's asking.
+ * @dev: instance of PCI owned by the driver that's asking.
  * @sglist:  array of buffer/length pairs
  * @nents:  number of entries in list
  * @direction:  R/W or both.
@@ -1086,49 +1250,42 @@
 		int direction)
 {
 	struct ioc *ioc;
-	int filled = 0;
+	int coalesced, filled = 0;
 	unsigned long flags;
 #ifdef ALLOW_IOV_BYPASS
 	struct scatterlist *sg;
 #endif
 
-	DBG_RUN_SG("%s() START %d entries, 0x%p,0x%x\n", __FUNCTION__, nents,
-		sba_sg_address(sglist), sba_sg_len(sglist));
-
-	if (!sba_list)
-		panic("sba_map_single: no SBA found!\n");
-
+	DBG_RUN_SG("%s() START %d entries\n", __FUNCTION__, nents);
 	ioc = GET_IOC(dev);
 	ASSERT(ioc);
 
 #ifdef ALLOW_IOV_BYPASS
 	if (dev->dma_mask >= ioc->dma_mask) {
-		for (sg = sglist ; filled < nents ; filled++, sg++) {
-			sba_sg_iova(sg) = virt_to_phys(sba_sg_address(sg));
-			sba_sg_iova_len(sg) = sba_sg_len(sg);
+		for (sg = sglist ; filled < nents ; filled++, sg++){
+			sg->dma_length = sg->length;
+			sg->dma_address = virt_to_phys(sba_sg_address(sg));
 		}
 #ifdef CONFIG_PROC_FS
 		spin_lock_irqsave(&ioc->res_lock, flags);
 		ioc->msg_bypass++;
 		spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif
-		DBG_RUN_SG("%s() DONE %d mappings bypassed\n", __FUNCTION__, filled);
 		return filled;
 	}
 #endif
 	/* Fast path single entry scatterlists. */
 	if (nents == 1) {
-		sba_sg_iova(sglist) = sba_map_single(dev,
-						     (void *) sba_sg_iova(sglist),
-						     sba_sg_len(sglist), direction);
-		sba_sg_iova_len(sglist) = sba_sg_len(sglist);
+		sglist->dma_length = sglist->length;
+		sglist->dma_address = sba_map_single(dev,
+		                                     sba_sg_address(sglist),
+		                                     sglist->length, direction);
 #ifdef CONFIG_PROC_FS
 		/*
 		** Should probably do some stats counting, but trying to
 		** be precise quickly starts wasting CPU time.
 		*/
 #endif
-		DBG_RUN_SG("%s() DONE 1 mapping\n", __FUNCTION__);
 		return 1;
 	}
 
@@ -1145,11 +1302,26 @@
 #ifdef CONFIG_PROC_FS
 	ioc->msg_calls++;
 #endif
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
  
 	/*
-	** coalesce and program the I/O Pdir
+	** Program the I/O Pdir
+	**
+	** map the virtual addresses to the I/O Pdir
+	** o dma_address will contain the pdir index
+	** o dma_len will contain the number of bytes to map 
+	** o address contains the virtual address.
 	*/
-	filled = sba_coalesce_chunks(ioc, sglist, nents, direction);
+	filled = sba_fill_pdir(ioc, sglist, nents);
 
 #ifdef ASSERT_PDIR_SANITY
 	if (sba_check_pdir(ioc,"Check after sba_map_sg()"))
@@ -1161,6 +1333,7 @@
 
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
 
+	ASSERT(coalesced == filled);
 	DBG_RUN_SG("%s() DONE %d mappings\n", __FUNCTION__, filled);
 
 	return filled;
@@ -1184,11 +1357,8 @@
 	unsigned long flags;
 #endif
 
-	DBG_RUN_SG("%s() START %d entries, 0x%p,0x%x\n",
-		__FUNCTION__, nents, sba_sg_address(sglist), sba_sg_len(sglist));
-
-	if (!sba_list)
-		panic("sba_map_single: no SBA found!\n");
+	DBG_RUN_SG("%s() START %d entries,  %p,%x\n",
+		__FUNCTION__, nents, sba_sg_address(sglist), sglist->length);
 
 	ioc = GET_IOC(dev);
 	ASSERT(ioc);
@@ -1203,10 +1373,10 @@
 	spin_unlock_irqrestore(&ioc->res_lock, flags);
 #endif
 
-	while (sba_sg_len(sglist) && nents--) {
+	while (nents && sglist->dma_length) {
 
-		sba_unmap_single(dev, (dma_addr_t)sba_sg_iova(sglist),
-		                 sba_sg_iova_len(sglist), direction);
+		sba_unmap_single(dev, sglist->dma_address,
+		                 sglist->dma_length, direction);
 #ifdef CONFIG_PROC_FS
 		/*
 		** This leaves inconsistent data in the stats, but we can't
@@ -1214,9 +1384,10 @@
 		** were coalesced to a single entry.  The stats are fun,
 		** but speed is more important.
 		*/
-		ioc->usg_pages += (((u64)sba_sg_iova(sglist) & ~IOVP_MASK) + sba_sg_len(sglist) + IOVP_SIZE - 1) >> IOVP_SHIFT;
+		ioc->usg_pages += ((sglist->dma_address & ~IOVP_MASK) + sglist->dma_length + IOVP_SIZE - 1) >> PAGE_SHIFT;
 #endif
-		++sglist;
+		sglist++;
+		nents--;
 	}
 
 	DBG_RUN_SG("%s() DONE (nents %d)\n", __FUNCTION__,  nents);
@@ -1229,87 +1400,89 @@
 
 }
 
-unsigned long
-sba_dma_address (struct scatterlist *sg)
-{
-	return ((unsigned long)sba_sg_iova(sg));
-}
-
-int
-sba_dma_supported (struct pci_dev *dev, u64 mask)
-{
-	return 1;
-}
-
 /**************************************************************
 *
 *   Initialization and claim
 *
 ***************************************************************/
 
-
-static void
-sba_ioc_init(struct sba_device *sba_dev, struct ioc *ioc, int ioc_num)
+static void __init
+ioc_iova_init(struct ioc *ioc)
 {
-	u32 iova_space_size, iova_space_mask;
-	void * pdir_base;
-	int pdir_size, iov_order, tcnfg;
+	u32 iova_space_mask;
+	int iov_order, tcnfg;
+	int agp_found = 0;
+	struct pci_dev *device;
+#ifdef FULL_VALID_PDIR
+	unsigned long index;
+#endif
 
 	/*
-	** Firmware programs the maximum IOV space size into the imask reg
+	** Firmware programs the base and size of a "safe IOVA space"
+	** (one that doesn't overlap memory or LMMIO space) in the
+	** IBASE and IMASK registers.
 	*/
-	iova_space_size = ~(READ_REG(ioc->ioc_hpa + IOC_IMASK) & 0xFFFFFFFFUL) + 1;
+	ioc->ibase = READ_REG(ioc->ioc_hpa + IOC_IBASE) & ~0x1UL;
+	ioc->iov_size = ~(READ_REG(ioc->ioc_hpa + IOC_IMASK) & 0xFFFFFFFFUL) + 1;
+
+	if (ioc->ibase == 0) {
+		if (((unsigned long) ioc->ioc_hpa & 0x3000UL) == 0x2000)
+			ioc->ibase = 0xc0000000;
+		else
+			ioc->ibase = 0x80000000;
+		printk("WARNING: IBASE is zero; setting to 0x%lx\n", ioc->ibase);
+	}
+
+	if (ioc->ibase < 0xfed00000UL && ioc->ibase + ioc->iov_size >= 0xfee00000UL) {
+		printk("WARNING: IOV space overlaps local config and interrupt message, truncating\n");
+		ioc->iov_size /= 2;
+	}
 
 	/*
 	** iov_order is always based on a 1GB IOVA space since we want to
 	** turn on the other half for AGP GART.
 	*/
-	iov_order = get_order(iova_space_size >> (IOVP_SHIFT-PAGE_SHIFT));
-	ioc->pdir_size = pdir_size = (iova_space_size/IOVP_SIZE) * sizeof(u64);
+	iov_order = get_order(ioc->iov_size >> (IOVP_SHIFT - PAGE_SHIFT));
+	ioc->pdir_size = (ioc->iov_size / IOVP_SIZE) * sizeof(u64);
 
 	DBG_INIT("%s() hpa 0x%lx IOV %dMB (%d bits) PDIR size 0x%0x\n",
-		__FUNCTION__, ioc->ioc_hpa, iova_space_size>>20,
+		__FUNCTION__, ioc->ioc_hpa, ioc->iov_size >> 20,
 		iov_order + PAGE_SHIFT, ioc->pdir_size);
 
-	/* XXX DMA HINTs not used */
+	/* FIXME : DMA HINTs not used */
 	ioc->hint_shift_pdir = iov_order + PAGE_SHIFT;
 	ioc->hint_mask_pdir = ~(0x3 << (iov_order + PAGE_SHIFT));
 
-	ioc->pdir_base = pdir_base =
-		(void *) __get_free_pages(GFP_KERNEL, get_order(pdir_size));
-	if (NULL == pdir_base)
-	{
-		panic(__FILE__ ":%s() could not allocate I/O Page Table\n", __FUNCTION__);
-	}
-	memset(pdir_base, 0, pdir_size);
+	ioc->pdir_base = (void *) __get_free_pages(GFP_KERNEL,
+						   get_order(ioc->pdir_size));
+	if (!ioc->pdir_base)
+		panic(PFX "Couldn't allocate I/O Page Table\n");
+
+	memset(ioc->pdir_base, 0, ioc->pdir_size);
 
 	DBG_INIT("%s() pdir %p size %x hint_shift_pdir %x hint_mask_pdir %lx\n",
-		__FUNCTION__, pdir_base, pdir_size,
+		__FUNCTION__, ioc->pdir_base, ioc->pdir_size,
 		ioc->hint_shift_pdir, ioc->hint_mask_pdir);
 
-	ASSERT((((unsigned long) pdir_base) & PAGE_MASK) == (unsigned long) pdir_base);
-	WRITE_REG(virt_to_phys(pdir_base), ioc->ioc_hpa + IOC_PDIR_BASE);
+	ASSERT((((unsigned long) ioc->pdir_base) & PAGE_MASK) == (unsigned long) ioc->pdir_base);
+	WRITE_REG(virt_to_phys(ioc->pdir_base), ioc->ioc_hpa + IOC_PDIR_BASE);
 
-	DBG_INIT(" base %p\n", pdir_base);
+	DBG_INIT(" base %p\n", ioc->pdir_base);
 
 	/* build IMASK for IOC and Elroy */
 	iova_space_mask =  0xffffffff;
-	iova_space_mask <<= (iov_order + IOVP_SHIFT);
-
-	ioc->ibase = READ_REG(ioc->ioc_hpa + IOC_IBASE) & 0xFFFFFFFEUL;
-
-	ioc->imask = iova_space_mask;	/* save it */
+	iova_space_mask <<= (iov_order + PAGE_SHIFT);
+	ioc->imask = iova_space_mask;
 
 	DBG_INIT("%s() IOV base 0x%lx mask 0x%0lx\n",
 		__FUNCTION__, ioc->ibase, ioc->imask);
 
 	/*
-	** XXX DMA HINT registers are programmed with default hint
+	** FIXME: Hint registers are programmed with default hint
 	** values during boot, so hints should be sane even if we
 	** can't reprogram them the way drivers want.
 	*/
-
-	WRITE_REG(ioc->imask, ioc->ioc_hpa+IOC_IMASK);
+	WRITE_REG(ioc->imask, ioc->ioc_hpa + IOC_IMASK);
 
 	/*
 	** Setting the upper bits makes checking for bypass addresses
@@ -1317,34 +1490,30 @@
 	*/
 	ioc->imask |= 0xFFFFFFFF00000000UL;
 
-	/* Set I/O Pdir page size to system page size */
-	switch (IOVP_SHIFT) {
-		case 12: /* 4K */
-			tcnfg = 0;
-			break;
-		case 13: /* 8K */
-			tcnfg = 1;
-			break;
-		case 14: /* 16K */
-			tcnfg = 2;
-			break;
-		case 16: /* 64K */
-			tcnfg = 3;
+	/* Set I/O PDIR Page size to system page size */
+	switch (PAGE_SHIFT) {
+		case 12: tcnfg = 0; break;	/*  4K */
+		case 13: tcnfg = 1; break;	/*  8K */
+		case 14: tcnfg = 2; break;	/* 16K */
+		case 16: tcnfg = 3; break;	/* 64K */
+		default:
+			panic(PFX "Unsupported system page size %d",
+				1 << PAGE_SHIFT);
 			break;
 	}
-	WRITE_REG(tcnfg, ioc->ioc_hpa+IOC_TCNFG);
+	WRITE_REG(tcnfg, ioc->ioc_hpa + IOC_TCNFG);
 
 	/*
 	** Program the IOC's ibase and enable IOVA translation
 	** Bit zero == enable bit.
 	*/
-	WRITE_REG(ioc->ibase | 1, ioc->ioc_hpa+IOC_IBASE);
+	WRITE_REG(ioc->ibase | 1, ioc->ioc_hpa + IOC_IBASE);
 
 	/*
 	** Clear I/O TLB of any possible entries.
 	** (Yes. This is a bit paranoid...but so what)
 	*/
-	WRITE_REG(0 | 31, ioc->ioc_hpa+IOC_PCOM);
+	WRITE_REG(ioc->ibase | (iov_order+PAGE_SHIFT), ioc->ioc_hpa + IOC_PCOM);
 
 	/*
 	** If an AGP device is present, only use half of the IOV space
@@ -1354,213 +1523,264 @@
 	** We program the next pdir index after we stop w/ a key for
 	** the GART code to handshake on.
 	*/
-	if (SBA_GET_AGP(sba_dev)) {
-		DBG_INIT("%s() AGP Device found, reserving 512MB for GART support\n", __FUNCTION__);
+	pci_for_each_dev(device)
+		agp_found |= pci_find_capability(device, PCI_CAP_ID_AGP);
+
+	if (agp_found && reserve_sba_gart) {
+		DBG_INIT("%s: AGP device found, reserving half of IOVA for GART support\n", __FUNCTION__);
 		ioc->pdir_size /= 2;
-		((u64 *)pdir_base)[PDIR_INDEX(iova_space_size/2)] = 0x0000badbadc0ffeeULL;
+		((u64 *)ioc->pdir_base)[PDIR_INDEX(ioc->iov_size/2)] = ZX1_SBA_IOMMU_COOKIE;
 	}
+#ifdef FULL_VALID_PDIR
+	/*
+  	** Check to see if the spill page has been allocated, we don't need more than
+	** one across multiple SBAs.
+	*/
+	if (!prefetch_spill_page) {
+		char *spill_poison = "SBAIOMMU POISON";
+		int poison_size = 16;
+		void *poison_addr;
+									
+		prefetch_spill_page = (void *)__get_free_pages(GFP_KERNEL, get_order(IOVP_SIZE));
+		if (!prefetch_spill_page)
+			panic(PFX "Couldn't allocate PDIR spill page\n");
+
+		poison_addr = prefetch_spill_page;
+		for (; (u64)poison_addr < (u64)prefetch_spill_page + IOVP_SIZE ; poison_addr += poison_size)
+			(void)memcpy(poison_addr,spill_poison,poison_size);
+
+		prefetch_spill_page = (void *)virt_to_phys(prefetch_spill_page);
 
-	DBG_INIT("%s() DONE\n", __FUNCTION__);
+		DBG_INIT("%s() prefetch spill addr: %p\n", __FUNCTION__, prefetch_spill_page);
+	}
+	/*
+  	** Set all the PDIR entries valid w/ the spill page as the target
+	*/
+	for (index = 0 ; index < (ioc->pdir_size / sizeof(u64)) ; index++)
+		((u64 *)ioc->pdir_base)[index] = (0x80000000000000FFULL | (u64)prefetch_spill_page);
+#endif
 }
 
+static void __init
+ioc_resource_init(struct ioc *ioc)
+{
+	spin_lock_init(&ioc->res_lock);
 
+	/* resource map size dictated by pdir_size */
+	ioc->res_size = ioc->pdir_size / sizeof(u64); /* entries */
+	ioc->res_size >>= 3;  /* convert bit count to byte count */
+	DBG_INIT("%s() res_size 0x%x\n", __FUNCTION__, ioc->res_size);
 
-/**************************************************************************
-**
-**   SBA initialization code (HW and SW)
-**
-**   o identify SBA chip itself
-**   o FIXME: initialize DMA hints for reasonable defaults
-**
-**************************************************************************/
+	ioc->res_map = (char *) __get_free_pages(GFP_KERNEL,
+						 get_order(ioc->res_size));
+	if (!ioc->res_map)
+		panic(PFX "Couldn't allocate resource map\n");
 
-static void
-sba_hw_init(struct sba_device *sba_dev)
-{ 
-	int i;
-	int num_ioc;
-	u64 dma_mask;
-	u32 func_id;
+	memset(ioc->res_map, 0, ioc->res_size);
+	/* next available IOVP - circular search */
+	ioc->res_hint = (unsigned long *) ioc->res_map;
 
-	/*
-	** Identify the SBA so we can set the dma_mask.  We can make a virtual
-	** dma_mask of the memory subsystem such that devices not implmenting
-	** a full 64bit mask might still be able to bypass efficiently.
-	*/
-	func_id = READ_REG(sba_dev->sba_hpa + SBA_FUNC_ID);
+#ifdef ASSERT_PDIR_SANITY
+	/* Mark first bit busy - ie no IOVA 0 */
+	ioc->res_map[0] = 0x1;
+	ioc->pdir_base[0] = 0x8000000000000000ULL | ZX1_SBA_IOMMU_COOKIE;
+#endif
+#ifdef FULL_VALID_PDIR
+	/* Mark the last resource used so we don't prefetch beyond IOVA space */
+	ioc->res_map[ioc->res_size - 1] |= 0x80UL; /* res_map is chars */
+	ioc->pdir_base[(ioc->pdir_size / sizeof(u64)) - 1] = (0x80000000000000FFULL | (u64)prefetch_spill_page);
+#endif
 
-	if (func_id == ZX1_FUNC_ID_VALUE) {
-		dma_mask = 0xFFFFFFFFFFUL;
-	} else {
-		dma_mask = 0xFFFFFFFFFFFFFFFFUL;
-	}
+	DBG_INIT("%s() res_map %x %p\n", __FUNCTION__,
+		 ioc->res_size, (void *) ioc->res_map);
+}
+
+static void __init
+ioc_sac_init(struct ioc *ioc)
+{
+	struct pci_dev *sac = NULL;
+	struct pci_controller *controller = NULL;
 
-	DBG_INIT("%s(): ioc->dma_mask == 0x%lx\n", __FUNCTION__, dma_mask);
-	
 	/*
-	** Leaving in the multiple ioc code from parisc for the future,
-	** currently there are no muli-ioc mckinley sbas
-	*/
-	sba_dev->ioc[0].ioc_hpa = SBA_IOC_OFFSET;
-	num_ioc = 1;
+	 * pci_alloc_consistent() must return a DMA address which is
+	 * SAC (single address cycle) addressable, so allocate a
+	 * pseudo-device to enforce that.
+	 */
+	sac = kmalloc(sizeof(*sac), GFP_KERNEL);
+	if (!sac)
+		panic(PFX "Couldn't allocate struct pci_dev");
+	memset(sac, 0, sizeof(*sac));
 
-	sba_dev->num_ioc = num_ioc;
-	for (i = 0; i < num_ioc; i++) {
-		sba_dev->ioc[i].dma_mask = dma_mask;
-		sba_dev->ioc[i].ioc_hpa += sba_dev->sba_hpa;
-		sba_ioc_init(sba_dev, &(sba_dev->ioc[i]), i);
-	}
+	controller = kmalloc(sizeof(*controller), GFP_KERNEL);
+	if (!controller)
+		panic(PFX "Couldn't allocate struct pci_controller");
+	memset(controller, 0, sizeof(*controller));
+
+	controller->iommu = ioc;
+	sac->sysdata = controller;
+	sac->dma_mask = 0xFFFFFFFFUL;
+	ioc->sac_only_dev = sac;
 }
 
-static void
-sba_common_init(struct sba_device *sba_dev)
+static void __init
+ioc_zx1_init(struct ioc *ioc)
 {
-	int i;
+	if (ioc->rev < 0x20)
+		panic(PFX "IOC 2.0 or later required for IOMMU support\n");
 
-	/* add this one to the head of the list (order doesn't matter)
-	** This will be useful for debugging - especially if we get coredumps
-	*/
-	sba_dev->next = sba_list;
-	sba_list = sba_dev;
-	sba_count++;
-
-	for(i=0; i< sba_dev->num_ioc; i++) {
-		int res_size;
-
-		/* resource map size dictated by pdir_size */
-		res_size = sba_dev->ioc[i].pdir_size/sizeof(u64); /* entries */
-		res_size >>= 3;  /* convert bit count to byte count */
-		DBG_INIT("%s() res_size 0x%x\n",
-			__FUNCTION__, res_size);
-
-		sba_dev->ioc[i].res_size = res_size;
-		sba_dev->ioc[i].res_map = (char *) __get_free_pages(GFP_KERNEL, get_order(res_size));
-
-		if (NULL == sba_dev->ioc[i].res_map)
-		{
-			panic(__FILE__ ":%s() could not allocate resource map\n", __FUNCTION__ );
-		}
+	ioc->dma_mask = 0xFFFFFFFFFFUL;
+}
 
-		memset(sba_dev->ioc[i].res_map, 0, res_size);
-		/* next available IOVP - circular search */
-		if ((sba_dev->hw_rev & 0xFF) >= 0x20) {
-			sba_dev->ioc[i].res_hint = (unsigned long *)
-			    sba_dev->ioc[i].res_map;
-		} else {
-			u64 reserved_iov;
+typedef void (initfunc)(struct ioc *);
 
-			/* Yet another 1.x hack */
-			printk(KERN_DEBUG "zx1 1.x: Starting resource hint offset into "
-			       "IOV space to avoid initial zero value IOVA\n");
-			sba_dev->ioc[i].res_hint = (unsigned long *)
-			    &(sba_dev->ioc[i].res_map[L1_CACHE_BYTES]);
-
-			sba_dev->ioc[i].res_map[0] = 0x1;
-			sba_dev->ioc[i].pdir_base[0] = 0x8000badbadc0ffeeULL;
-
-			for (reserved_iov = 0xA0000 ; reserved_iov < 0xC0000 ; reserved_iov += IOVP_SIZE) {
-				u64 *res_ptr = (u64 *) sba_dev->ioc[i].res_map;
-				int index = PDIR_INDEX(reserved_iov);
-				int res_word;
-				u64 mask;
-
-				res_word = (int)(index / BITS_PER_LONG);
-				mask =  0x1UL << (index - (res_word * BITS_PER_LONG));
-				res_ptr[res_word] |= mask;
-				sba_dev->ioc[i].pdir_base[PDIR_INDEX(reserved_iov)] = (SBA_VALID_MASK | reserved_iov);
+struct ioc_iommu {
+	u32 func_id;
+	char *name;
+	initfunc *init;
+};
 
-			}
-		}
+static struct ioc_iommu ioc_iommu_info[] __initdata = {
+	{ ZX1_IOC_ID, "zx1", ioc_zx1_init },
+	{ REO_IOC_ID, "REO" },
+};
 
-#ifdef ASSERT_PDIR_SANITY
-		/* Mark first bit busy - ie no IOVA 0 */
-		sba_dev->ioc[i].res_map[0] = 0x1;
-		sba_dev->ioc[i].pdir_base[0] = 0x8000badbadc0ffeeULL;
-#endif
+static struct ioc * __init
+ioc_init(u64 hpa, void *handle)
+{
+	struct ioc *ioc;
+	struct ioc_iommu *info;
+
+	ioc = kmalloc(sizeof(*ioc), GFP_KERNEL);
+	if (!ioc)
+		return NULL;
+
+	memset(ioc, 0, sizeof(*ioc));
+
+	ioc->next = ioc_list;
+	ioc_list = ioc;
 
-		DBG_INIT("%s() %d res_map %x %p\n", __FUNCTION__,
-		         i, res_size, (void *)sba_dev->ioc[i].res_map);
+	ioc->handle = handle;
+	ioc->ioc_hpa = ioremap(hpa, 0x1000);
+
+	ioc->func_id = READ_REG(ioc->ioc_hpa + IOC_FUNC_ID);
+	ioc->rev = READ_REG(ioc->ioc_hpa + IOC_FCLASS) & 0xFFUL;
+	ioc->dma_mask = 0xFFFFFFFFFFFFFFFFUL;	/* conservative */
+
+	for (info = ioc_iommu_info; info < ioc_iommu_info + ARRAY_SIZE(ioc_iommu_info); info++) {
+		if (ioc->func_id == info->func_id) {
+			ioc->name = info->name;
+			if (info->init)
+				(info->init)(ioc);
+		}
 	}
 
-	sba_dev->sba_lock = SPIN_LOCK_UNLOCKED;
+	if (!ioc->name)
+		ioc->name = "Unknown";
+
+	ioc_iova_init(ioc);
+	ioc_resource_init(ioc);
+	ioc_sac_init(ioc);
+
+	printk(KERN_INFO PFX
+		"Found %s IOC %d.%d HPA 0x%lx IOVA space %dMb at 0x%lx\n",
+		ioc->name, (ioc->rev >> 4) & 0xF, ioc->rev & 0xF,
+		hpa, ioc->iov_size >> 20, ioc->ibase);
+
+	return ioc;
 }
 
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
 #ifdef CONFIG_PROC_FS
-static int sba_proc_info(char *buf, char **start, off_t offset, int len)
+static int
+sba_proc_info_one(char *buf, struct ioc *ioc)
 {
-	struct sba_device *sba_dev;
-	struct ioc *ioc;
-	int total_pages;
+	int total_pages = (int) (ioc->res_size << 3); /* 8 bits per byte */
 	unsigned long i = 0, avg = 0, min, max;
 
-	for (sba_dev = sba_list; sba_dev; sba_dev = sba_dev->next) {
-		ioc = &sba_dev->ioc[0];	/* FIXME: Multi-IOC support! */
-		total_pages = (int) (ioc->res_size << 3); /* 8 bits per byte */
-
-		sprintf(buf, "%s rev %d.%d\n", "Hewlett Packard zx1 SBA",
-			((sba_dev->hw_rev >> 4) & 0xF), (sba_dev->hw_rev & 0xF));
-		sprintf(buf, "%sIO PDIR size    : %d bytes (%d entries)\n", buf,
-			(int) ((ioc->res_size << 3) * sizeof(u64)), /* 8 bits/byte */ total_pages);
-
-		sprintf(buf, "%sIO PDIR entries : %ld free  %ld used (%d%%)\n", buf,
-			total_pages - ioc->used_pages, ioc->used_pages,
-			(int) (ioc->used_pages * 100 / total_pages));
-
-		sprintf(buf, "%sResource bitmap : %d bytes (%d pages)\n", 
-			buf, ioc->res_size, ioc->res_size << 3);   /* 8 bits per byte */
-
-		min = max = ioc->avg_search[0];
-		for (i = 0; i < SBA_SEARCH_SAMPLE; i++) {
-			avg += ioc->avg_search[i];
-			if (ioc->avg_search[i] > max) max = ioc->avg_search[i];
-			if (ioc->avg_search[i] < min) min = ioc->avg_search[i];
-		}
-		avg /= SBA_SEARCH_SAMPLE;
-		sprintf(buf, "%s  Bitmap search : %ld/%ld/%ld (min/avg/max CPU Cycles)\n",
-			buf, min, avg, max);
-
-		sprintf(buf, "%spci_map_single(): %12ld calls  %12ld pages (avg %d/1000)\n",
-			buf, ioc->msingle_calls, ioc->msingle_pages,
-			(int) ((ioc->msingle_pages * 1000)/ioc->msingle_calls));
+	sprintf(buf, "Hewlett Packard %s IOC rev %d.%d\n",
+		ioc->name, ((ioc->rev >> 4) & 0xF), (ioc->rev & 0xF));
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
 #ifdef ALLOW_IOV_BYPASS
-		sprintf(buf, "%spci_map_single(): %12ld bypasses\n",
-			buf, ioc->msingle_bypass);
+	sprintf(buf, "%spci_map_single(): %12ld bypasses\n",
+	        buf, ioc->msingle_bypass);
 #endif
 
-		sprintf(buf, "%spci_unmap_single: %12ld calls  %12ld pages (avg %d/1000)\n",
-			buf, ioc->usingle_calls, ioc->usingle_pages,
-			(int) ((ioc->usingle_pages * 1000)/ioc->usingle_calls));
+	sprintf(buf, "%spci_unmap_single: %12ld calls  %12ld pages (avg %d/1000)\n",
+		buf, ioc->usingle_calls, ioc->usingle_pages,
+		(int) ((ioc->usingle_pages * 1000)/ioc->usingle_calls));
 #ifdef ALLOW_IOV_BYPASS
-		sprintf(buf, "%spci_unmap_single: %12ld bypasses\n",
-			buf, ioc->usingle_bypass);
+	sprintf(buf, "%spci_unmap_single: %12ld bypasses\n",
+	        buf, ioc->usingle_bypass);
 #endif
 
-		sprintf(buf, "%spci_map_sg()    : %12ld calls  %12ld pages (avg %d/1000)\n",
-			buf, ioc->msg_calls, ioc->msg_pages,
-			(int) ((ioc->msg_pages * 1000)/ioc->msg_calls));
+	sprintf(buf, "%spci_map_sg()    : %12ld calls  %12ld pages (avg %d/1000)\n",
+		buf, ioc->msg_calls, ioc->msg_pages,
+		(int) ((ioc->msg_pages * 1000)/ioc->msg_calls));
 #ifdef ALLOW_IOV_BYPASS
-		sprintf(buf, "%spci_map_sg()    : %12ld bypasses\n",
-			buf, ioc->msg_bypass);
+	sprintf(buf, "%spci_map_sg()    : %12ld bypasses\n",
+	        buf, ioc->msg_bypass);
 #endif
 
-		sprintf(buf, "%spci_unmap_sg()  : %12ld calls  %12ld pages (avg %d/1000)\n",
-			buf, ioc->usg_calls, ioc->usg_pages,
-			(int) ((ioc->usg_pages * 1000)/ioc->usg_calls));
-	}
+	sprintf(buf, "%spci_unmap_sg()  : %12ld calls  %12ld pages (avg %d/1000)\n",
+		buf, ioc->usg_calls, ioc->usg_pages,
+		(int) ((ioc->usg_pages * 1000)/ioc->usg_calls));
+
 	return strlen(buf);
 }
 
 static int
-sba_resource_map(char *buf, char **start, off_t offset, int len)
+sba_proc_info(char *buf, char **start, off_t offset, int len)
 {
-	struct ioc *ioc = sba_list->ioc;	/* FIXME: Multi-IOC support! */
-	unsigned int *res_ptr;
-	int i;
+	struct ioc *ioc;
+	char *base = buf;
 
-	if (!ioc)
-		return 0;
+	for (ioc = ioc_list; ioc; ioc = ioc->next) {
+		buf += sba_proc_info_one(buf, ioc);
+	}
+
+	return strlen(base);
+}
+
+static int
+sba_resource_map_one(char *buf, struct ioc *ioc)
+{
+	unsigned int *res_ptr = (unsigned int *)ioc->res_map;
+	int i;
 
-	res_ptr = (unsigned int *)ioc->res_map;
 	buf[0] = '\0';
 	for(i = 0; i < (ioc->res_size / sizeof(unsigned int)); ++i, ++res_ptr) {
 		if ((i & 7) == 0)
@@ -1571,129 +1791,147 @@
 
 	return strlen(buf);
 }
-#endif
 
-/*
-** Determine if sba should claim this chip (return 0) or not (return 1).
-** If so, initialize the chip and tell other partners in crime they
-** have work to do.
-*/
-void __init sba_init(void)
+static int
+sba_resource_map(char *buf, char **start, off_t offset, int len)
 {
-	struct sba_device *sba_dev;
-	u32 func_id, hw_rev;
-	u32 *func_offset = NULL;
-	int i, agp_found = 0;
-	static char sba_rev[6];
-	struct pci_dev *device = NULL;
-	u64 hpa = 0;
-
-	if (!(device = pci_find_device(PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_ZX1_SBA, NULL)))
-		return;
+	struct ioc *ioc;
+	char *base = buf;
 
-	for (i = 0; i < PCI_NUM_RESOURCES; i++) {
-		if (pci_resource_flags(device, i) == IORESOURCE_MEM) {
-			hpa = (u64) ioremap(pci_resource_start(device, i),
-					    pci_resource_len(device, i));
-			break;
-		}
+	for (ioc = ioc_list; ioc; ioc = ioc->next) {
+		buf += sba_resource_map_one(buf, ioc);
 	}
 
-	func_id = READ_REG(hpa + SBA_FUNC_ID);
-	if (func_id != ZX1_FUNC_ID_VALUE)
-		return;
-
-	strcpy(sba_rev, "zx1");
-	func_offset = zx1_func_offsets;
+	return strlen(base);
+}
 
-	/* Read HW Rev First */
-	hw_rev = READ_REG(hpa + SBA_FCLASS) & 0xFFUL;
+static void __init
+sba_proc_init(void)
+{
+	if (ioc_list) {
+		struct proc_dir_entry * proc_mckinley_root;
 
-	/*
-	 * Not all revision registers of the chipset are updated on every
-	 * turn.  Must scan through all functions looking for the highest rev
-	 */
-	if (func_offset) {
-		for (i = 0 ; func_offset[i] != -1 ; i++) {
-			u32 func_rev;
-
-			func_rev = READ_REG(hpa + SBA_FCLASS + func_offset[i]) & 0xFFUL;
-			DBG_INIT("%s() func offset: 0x%x rev: 0x%x\n",
-			         __FUNCTION__, func_offset[i], func_rev);
-			if (func_rev > hw_rev)
-				hw_rev = func_rev;
-		}
+		proc_mckinley_root = proc_mkdir("bus/mckinley",0);
+		create_proc_info_entry(ioc_list->name, 0, proc_mckinley_root, sba_proc_info);
+		create_proc_info_entry("bitmap", 0, proc_mckinley_root, sba_resource_map);
 	}
+	return 0;
+}
+#endif
 
-	printk(KERN_INFO "%s found %s %d.%d at %s, HPA 0x%lx\n", DRIVER_NAME,
-	       sba_rev, ((hw_rev >> 4) & 0xF), (hw_rev & 0xF),
-	       device->slot_name, hpa);
+void
+sba_connect_bus(struct pci_bus *bus)
+{
+	acpi_handle handle, parent;
+	acpi_status status;
+	struct ioc *ioc;
 
-	if ((hw_rev & 0xFF) < 0x20) {
-		printk(KERN_INFO "%s: SBA rev less than 2.0 not supported", DRIVER_NAME);
+	if (!PCI_CONTROLLER(bus))
+		panic(PFX "no sysdata on bus %d!\n",bus->number);
+
+	if (PCI_CONTROLLER(bus)->iommu)
 		return;
-	}
 
-	sba_dev = kmalloc(sizeof(struct sba_device), GFP_KERNEL);
-	if (NULL == sba_dev) {
-		printk(KERN_ERR DRIVER_NAME " - couldn't alloc sba_device\n");
+	handle = PCI_CONTROLLER(bus)->acpi_handle;
+	if (!handle)
 		return;
-	}
 
-	memset(sba_dev, 0, sizeof(struct sba_device));
+	/*
+	 * The IOC scope encloses PCI root bridges in the ACPI
+	 * namespace, so work our way out until we find an IOC we
+	 * claimed previously.
+	 */
+	do {
+		for (ioc = ioc_list; ioc; ioc = ioc->next)
+			if (ioc->handle == handle) {
+				PCI_CONTROLLER(bus)->iommu = ioc;
+				return;
+			}
 
-	for(i=0; i<MAX_IOC; i++)
-		spin_lock_init(&(sba_dev->ioc[i].res_lock));
+		status = acpi_get_parent(handle, &parent);
+		handle = parent;
+	} while (ACPI_SUCCESS(status));
 
-	sba_dev->hw_rev = hw_rev;
-	sba_dev->sba_hpa = hpa;
+	printk("No IOC for PCI Bus %d in ACPI\n", bus->number);
+}
 
-	/*
-	 * We pass this fake device from alloc_consistent to ensure
-	 * we only use SAC for alloc_consistent mappings.
-	 */
-	sac_only_dev.dma_mask = 0xFFFFFFFFUL;
+static int __init
+acpi_sba_ioc_add(struct acpi_device *device)
+{
+	struct ioc *ioc;
+	acpi_status status;
+	u64 hpa, length;
+	struct acpi_device_info dev_info;
 
 	/*
-	 * We need to check for an AGP device, if we find one, then only
-	 * use part of the IOVA space for PCI DMA, the rest is for GART.
-	 * REVISIT for multiple IOC.
+	 * Only SBA appears in ACPI namespace.  It encloses the PCI
+	 * root bridges, and its CSR space includes the IOC function.
 	 */
-	pci_for_each_dev(device)
-		agp_found |= pci_find_capability(device, PCI_CAP_ID_AGP);
+	status = hp_acpi_csr_space(device->handle, &hpa, &length);
+	if (ACPI_FAILURE(status))
+		return 1;
 
-	if (agp_found && reserve_sba_gart)
-		SBA_SET_AGP(sba_dev);
+	status = acpi_get_object_info(device->handle, &dev_info);
+	if (ACPI_FAILURE(status))
+		return 1;
 
-	sba_hw_init(sba_dev);
-	sba_common_init(sba_dev);
+	if (strncmp("HWP0001", dev_info.hardware_id, 7) == 0)
+		hpa += ZX1_IOC_OFFSET;
 
-#ifdef CONFIG_PROC_FS
-	{
-		struct proc_dir_entry * proc_mckinley_root;
+	ioc = ioc_init(hpa, device->handle);
+	if (!ioc)
+		return 1;
 
-		proc_mckinley_root = proc_mkdir("bus/mckinley",0);
-		create_proc_info_entry(sba_rev, 0, proc_mckinley_root, sba_proc_info);
-		create_proc_info_entry("bitmap", 0, proc_mckinley_root, sba_resource_map);
-	}
+	return 0;
+}
+
+static struct acpi_driver acpi_sba_ioc_driver = {
+	name:		"IOC IOMMU Driver",
+	ids:		"HWP0001,HWP0004",
+	ops: {
+		add:	acpi_sba_ioc_add,
+     },
+};
+
+static int __init
+sba_init(void)
+{
+	struct pci_bus *b;
+	MAX_DMA_ADDRESS = ~0UL;
+
+	acpi_bus_register_driver(&acpi_sba_ioc_driver);
+
+	pci_for_each_bus(b)
+		sba_connect_bus(b);
+	
+#ifdef CONFIG_PROC_FS
+	sba_proc_init();
 #endif
+	return 0;
 }
 
+device_initcall(sba_init);
+
 static int __init
-nosbagart (char *str)
+nosbagart(char *str)
 {
 	reserve_sba_gart = 0;
 	return 1;
 }
 
-__setup("nosbagart",nosbagart);
+int
+sba_dma_supported (struct pci_dev *dev, u64 mask)
+{
+	/* make sure it's at least 32bit capable */
+	return ((mask & 0xFFFFFFFFUL) == 0xFFFFFFFFUL);
+}
+
+__setup("nosbagart", nosbagart);
 
-EXPORT_SYMBOL(sba_init);
 EXPORT_SYMBOL(sba_map_single);
 EXPORT_SYMBOL(sba_unmap_single);
 EXPORT_SYMBOL(sba_map_sg);
 EXPORT_SYMBOL(sba_unmap_sg);
-EXPORT_SYMBOL(sba_dma_address);
 EXPORT_SYMBOL(sba_dma_supported);
 EXPORT_SYMBOL(sba_alloc_consistent);
 EXPORT_SYMBOL(sba_free_consistent);
diff -urN linux-2.5.64/arch/ia64/hp/zx1/Makefile linux-work/arch/ia64/hp/zx1/Makefile
--- linux-2.5.64/arch/ia64/hp/zx1/Makefile	Tue Mar  4 20:29:53 2003
+++ linux-work/arch/ia64/hp/zx1/Makefile	Wed Apr  2 12:53:19 2003
@@ -5,5 +5,4 @@
 # Copyright (C) Alex Williamson (alex_williamson@hp.com)
 #
 
-obj-y := hpzx1_misc.o
 obj-$(CONFIG_IA64_GENERIC) += hpzx1_machvec.o
diff -urN linux-2.5.64/arch/ia64/hp/zx1/hpzx1_misc.c linux-work/arch/ia64/hp/zx1/hpzx1_misc.c
--- linux-2.5.64/arch/ia64/hp/zx1/hpzx1_misc.c	Tue Mar  4 20:29:17 2003
+++ linux-work/arch/ia64/hp/zx1/hpzx1_misc.c	Wed Dec 31 17:00:00 1969
@@ -1,348 +0,0 @@
-/*
- * Misc. support for HP zx1 chipset support
- *
- * Copyright (C) 2002-2003 Hewlett-Packard Co
- *	Alex Williamson <alex_williamson@hp.com>
- *	Bjorn Helgaas <bjorn_helgaas@hp.com>
- */
-
-
-#include <linux/config.h>
-#include <linux/init.h>
-#include <linux/kernel.h>
-#include <linux/pci.h>
-#include <linux/acpi.h>
-#include <linux/efi.h>
-
-#include <asm/dma.h>
-#include <asm/iosapic.h>
-
-extern acpi_status acpi_evaluate_integer (acpi_handle, acpi_string, struct acpi_object_list *,
-					  unsigned long *);
-
-#define PFX "hpzx1: "
-
-static int hpzx1_devices;
-
-struct fake_pci_dev {
-	struct fake_pci_dev *next;
-	struct pci_dev *pci_dev;
-	unsigned long csr_base;
-	unsigned long csr_size;
-	unsigned long mapped_csrs;	// ioremapped
-	int sizing;			// in middle of BAR sizing operation?
-} *fake_pci_dev_list;
-
-static struct pci_ops *orig_pci_ops;
-
-struct fake_pci_dev *
-lookup_fake_dev (struct pci_bus *bus, unsigned int devfn)
-{
-	struct fake_pci_dev *fake_dev;
-
-	for (fake_dev = fake_pci_dev_list; fake_dev; fake_dev = fake_dev->next)
-		if (fake_dev->pci_dev->bus == bus && fake_dev->pci_dev->devfn == devfn)
-			return fake_dev;
-	return NULL;
-}
-
-static int
-hp_cfg_read (struct pci_bus *bus, unsigned int devfn, int where, int size, u32 *value)
-{
-	struct fake_pci_dev *fake_dev = lookup_fake_dev(bus, devfn);
-
-	if (!fake_dev)
-		return (*orig_pci_ops->read)(bus, devfn, where, size, value);
-
-	if (where == PCI_BASE_ADDRESS_0) {
-		if (fake_dev->sizing)
-			*value = ~(fake_dev->csr_size - 1);
-		else
-			*value = ((fake_dev->csr_base & PCI_BASE_ADDRESS_MEM_MASK)
-				  | PCI_BASE_ADDRESS_SPACE_MEMORY);
-		fake_dev->sizing = 0;
-		return PCIBIOS_SUCCESSFUL;
-	}
-	switch (size) {
-	      case 1: *value = readb(fake_dev->mapped_csrs + where); break;
-	      case 2: *value = readw(fake_dev->mapped_csrs + where); break;
-	      case 4: *value = readl(fake_dev->mapped_csrs + where); break;
-	      default:
-		printk(KERN_WARNING"hp_cfg_read: bad size = %d bytes", size);
-		break;
-	}
-	if (where == PCI_COMMAND)
-		*value |= PCI_COMMAND_MEMORY; /* SBA omits this */
-	return PCIBIOS_SUCCESSFUL;
-}
-
-static int
-hp_cfg_write (struct pci_bus *bus, unsigned int devfn, int where, int size, u32 value)
-{
-	struct fake_pci_dev *fake_dev = lookup_fake_dev(bus, devfn);
-
-	if (!fake_dev)
-		return (*orig_pci_ops->write)(bus, devfn, where, size, value);
-
-	if (where == PCI_BASE_ADDRESS_0) {
-		if (value == ((1UL << 8*size) - 1))
-			fake_dev->sizing = 1;
-		return PCIBIOS_SUCCESSFUL;
-	}
-	switch (size) {
-	      case 1: writeb(value, fake_dev->mapped_csrs + where); break;
-	      case 2: writew(value, fake_dev->mapped_csrs + where); break;
-	      case 4: writel(value, fake_dev->mapped_csrs + where); break;
-	      default:
-		printk(KERN_WARNING"hp_cfg_write: bad size = %d bytes", size);
-		break;
-	}
-	return PCIBIOS_SUCCESSFUL;
-}
-
-static struct pci_ops hp_pci_conf = {
-	.read =		hp_cfg_read,
-	.write =	hp_cfg_write
-};
-
-static void
-hpzx1_fake_pci_dev(char *name, unsigned int busnum, unsigned long addr, unsigned int size)
-{
-	struct fake_pci_dev *fake;
-	int slot, ret;
-	struct pci_dev *dev;
-	struct pci_bus *b, *bus = NULL;
-	u8 hdr;
-
-        fake = kmalloc(sizeof(*fake), GFP_KERNEL);
-	if (!fake) {
-		printk(KERN_ERR PFX "No memory for %s (0x%p) sysdata\n", name, (void *) addr);
-		return;
-	}
-
-	memset(fake, 0, sizeof(*fake));
-	fake->csr_base = addr;
-	fake->csr_size = size;
-	fake->mapped_csrs = (unsigned long) ioremap(addr, size);
-	fake->sizing = 0;
-
-	pci_for_each_bus(b)
-		if (busnum == b->number) {
-			bus = b;
-			break;
-		}
-
-	if (!bus) {
-		printk(KERN_ERR PFX "No host bus 0x%02x for %s (0x%p)\n",
-		       busnum, name, (void *) addr);
-		kfree(fake);
-		return;
-	}
-
-	for (slot = 0x1e; slot; slot--)
-		if (!pci_find_slot(busnum, PCI_DEVFN(slot, 0)))
-			break;
-
-	if (slot < 0) {
-		printk(KERN_ERR PFX "No space for %s (0x%p) on bus 0x%02x\n",
-		       name, (void *) addr, busnum);
-		kfree(fake);
-		return;
-	}
-
-        dev = kmalloc(sizeof(*dev), GFP_KERNEL);
-	if (!dev) {
-		printk(KERN_ERR PFX "No memory for %s (0x%p)\n", name, (void *) addr);
-		kfree(fake);
-		return;
-	}
-
-	bus->ops = &hp_pci_conf;	// replace pci ops for this bus
-
-	fake->pci_dev = dev;
-	fake->next = fake_pci_dev_list;
-	fake_pci_dev_list = fake;
-
-	memset(dev, 0, sizeof(*dev));
-	dev->bus = bus;
-	dev->sysdata = fake;
-	dev->dev.parent = bus->dev;
-	dev->dev.bus = &pci_bus_type;
-	dev->devfn = PCI_DEVFN(slot, 0);
-	pci_read_config_word(dev, PCI_VENDOR_ID, &dev->vendor);
-	pci_read_config_word(dev, PCI_DEVICE_ID, &dev->device);
-	pci_read_config_byte(dev, PCI_HEADER_TYPE, &hdr);
-	dev->hdr_type = hdr & 0x7f;
-
-	pci_setup_device(dev);
-
-	// pci_insert_device() without running /sbin/hotplug
-	list_add_tail(&dev->bus_list, &bus->devices);
-	list_add_tail(&dev->global_list, &pci_devices);
-
-	strcpy(dev->dev.bus_id, dev->slot_name);
-	ret = device_register(&dev->dev);
-	if (ret < 0)
-		printk(KERN_INFO PFX "fake device registration failed (%d)\n", ret);
-
-	printk(KERN_INFO PFX "%s at 0x%lx; pci dev %s\n", name, addr, dev->slot_name);
-
-	hpzx1_devices++;
-}
-
-struct acpi_hp_vendor_long {
-	u8	guid_id;
-	u8	guid[16];
-	u8	csr_base[8];
-	u8	csr_length[8];
-};
-
-#define HP_CCSR_LENGTH	0x21
-#define HP_CCSR_TYPE	0x2
-#define HP_CCSR_GUID	EFI_GUID(0x69e9adf9, 0x924f, 0xab5f,				\
-				 0xf6, 0x4a, 0x24, 0xd2, 0x01, 0x37, 0x0e, 0xad)
-
-extern acpi_status acpi_get_crs(acpi_handle, struct acpi_buffer *);
-extern struct acpi_resource *acpi_get_crs_next(struct acpi_buffer *, int *);
-extern union acpi_resource_data *acpi_get_crs_type(struct acpi_buffer *, int *, int);
-extern void acpi_dispose_crs(struct acpi_buffer *);
-
-static acpi_status
-hp_csr_space(acpi_handle obj, u64 *csr_base, u64 *csr_length)
-{
-	int i, offset = 0;
-	acpi_status status;
-	struct acpi_buffer buf;
-	struct acpi_resource_vendor *res;
-	struct acpi_hp_vendor_long *hp_res;
-	efi_guid_t vendor_guid;
-
-	*csr_base = 0;
-	*csr_length = 0;
-
-	status = acpi_get_crs(obj, &buf);
-	if (ACPI_FAILURE(status)) {
-		printk(KERN_ERR PFX "Unable to get _CRS data on object\n");
-		return status;
-	}
-
-	res = (struct acpi_resource_vendor *)acpi_get_crs_type(&buf, &offset, ACPI_RSTYPE_VENDOR);
-	if (!res) {
-		printk(KERN_ERR PFX "Failed to find config space for device\n");
-		acpi_dispose_crs(&buf);
-		return AE_NOT_FOUND;
-	}
-
-	hp_res = (struct acpi_hp_vendor_long *)(res->reserved);
-
-	if (res->length != HP_CCSR_LENGTH || hp_res->guid_id != HP_CCSR_TYPE) {
-		printk(KERN_ERR PFX "Unknown Vendor data\n");
-		acpi_dispose_crs(&buf);
-		return AE_TYPE; /* Revisit error? */
-	}
-
-	memcpy(&vendor_guid, hp_res->guid, sizeof(efi_guid_t));
-	if (efi_guidcmp(vendor_guid, HP_CCSR_GUID) != 0) {
-		printk(KERN_ERR PFX "Vendor GUID does not match\n");
-		acpi_dispose_crs(&buf);
-		return AE_TYPE; /* Revisit error? */
-	}
-
-	for (i = 0 ; i < 8 ; i++) {
-		*csr_base |= ((u64)(hp_res->csr_base[i]) << (i * 8));
-		*csr_length |= ((u64)(hp_res->csr_length[i]) << (i * 8));
-	}
-
-	acpi_dispose_crs(&buf);
-
-	return AE_OK;
-}
-
-static acpi_status
-hpzx1_sba_probe(acpi_handle obj, u32 depth, void *context, void **ret)
-{
-	u64 csr_base = 0, csr_length = 0;
-	acpi_status status;
-	char *name = context;
-	char fullname[16];
-
-	status = hp_csr_space(obj, &csr_base, &csr_length);
-	if (ACPI_FAILURE(status))
-		return status;
-
-	/*
-	 * Only SBA shows up in ACPI namespace, so its CSR space
-	 * includes both SBA and IOC.  Make SBA and IOC show up
-	 * separately in PCI space.
-	 */
-	sprintf(fullname, "%s SBA", name);
-	hpzx1_fake_pci_dev(fullname, 0, csr_base, 0x1000);
-	sprintf(fullname, "%s IOC", name);
-	hpzx1_fake_pci_dev(fullname, 0, csr_base + 0x1000, 0x1000);
-
-	return AE_OK;
-}
-
-static acpi_status
-hpzx1_lba_probe(acpi_handle obj, u32 depth, void *context, void **ret)
-{
-	u64 csr_base = 0, csr_length = 0;
-	acpi_status status;
-	acpi_native_uint busnum;
-	char *name = context;
-	char fullname[32];
-
-	status = hp_csr_space(obj, &csr_base, &csr_length);
-	if (ACPI_FAILURE(status))
-		return status;
-
-	status = acpi_evaluate_integer(obj, METHOD_NAME__BBN, NULL, &busnum);
-	if (ACPI_FAILURE(status)) {
-		printk(KERN_WARNING PFX "evaluate _BBN fail=0x%x\n", status);
-		busnum = 0;	// no _BBN; stick it on bus 0
-	}
-
-	sprintf(fullname, "%s _BBN 0x%02x", name, (unsigned int) busnum);
-	hpzx1_fake_pci_dev(fullname, busnum, csr_base, csr_length);
-
-	return AE_OK;
-}
-
-static void
-hpzx1_acpi_dev_init(void)
-{
-	extern struct pci_ops *pci_root_ops;
-
-	orig_pci_ops = pci_root_ops;
-
-	/*
-	 * Make fake PCI devices for the following hardware in the
-	 * ACPI namespace.  This makes it more convenient for drivers
-	 * because they can claim these devices based on PCI
-	 * information, rather than needing to know about ACPI.  The
-	 * 64-bit "HPA" space for this hardware is available as BAR
-	 * 0/1.
-	 *
-	 * HWP0001: Single IOC SBA w/o IOC in namespace
-	 * HWP0002: LBA device
-	 * HWP0003: AGP LBA device
-	 */
-	acpi_get_devices("HWP0001", hpzx1_sba_probe, "HWP0001", NULL);
-	acpi_get_devices("HWP0002", hpzx1_lba_probe, "HWP0002 PCI LBA", NULL);
-	acpi_get_devices("HWP0003", hpzx1_lba_probe, "HWP0003 AGP LBA", NULL);
-}
-
-extern void sba_init(void);
-
-static int
-hpzx1_init (void)
-{
-	/* zx1 has a hardware I/O TLB which lets us DMA from any device to any address */
-	MAX_DMA_ADDRESS = ~0UL;
-
-	hpzx1_acpi_dev_init();
-	sba_init();
-	return 0;
-}
-
-subsys_initcall(hpzx1_init);
diff -urN linux-2.5.64/arch/ia64/kernel/Makefile linux-work/arch/ia64/kernel/Makefile
--- linux-2.5.64/arch/ia64/kernel/Makefile	Tue Mar  4 20:29:54 2003
+++ linux-work/arch/ia64/kernel/Makefile	Thu Apr  3 08:41:46 2003
@@ -17,3 +17,5 @@
 obj-$(CONFIG_SMP) += smp.o smpboot.o
 obj-$(CONFIG_IA64_MCA) += mca.o mca_asm.o
 obj-$(CONFIG_IA64_BRL_EMU) += brl_emu.o
+obj-$(CONFIG_IA64_HP_ZX1) += acpi-ext.o
+obj-$(CONFIG_IA64_GENERIC) += acpi-ext.o
diff -urN linux-2.5.64/arch/ia64/kernel/acpi-ext.c linux-work/arch/ia64/kernel/acpi-ext.c
--- linux-2.5.64/arch/ia64/kernel/acpi-ext.c	Wed Dec 31 17:00:00 1969
+++ linux-work/arch/ia64/kernel/acpi-ext.c	Thu Apr  3 08:39:07 2003
@@ -0,0 +1,67 @@
+/*
+ * ia64/platform/hp/common/hp_acpi.c
+ *
+ * Copyright (C) 2003 Hewlett Packard
+ * Copyright (C) Alex Williamson
+ *
+ * Vendor specific extensions to ACPI.  These are used by both
+ * HP and NEC.
+ */
+
+#include <linux/types.h>
+#include <linux/acpi.h>
+#include <linux/efi.h>
+
+#include <asm/acpi-ext.h>
+	
+acpi_status
+hp_acpi_csr_space(acpi_handle obj, u64 *csr_base, u64 *csr_length)
+{
+	int i, offset = 0;
+	acpi_status status;
+	struct acpi_buffer buf;
+	struct acpi_resource_vendor *res;
+	struct acpi_hp_vendor_long *hp_res;
+	efi_guid_t vendor_guid;
+
+	*csr_base = 0;
+	*csr_length = 0;
+
+	status = acpi_get_crs(obj, &buf);
+	if (ACPI_FAILURE(status)) {
+		printk(KERN_ERR PREFIX "Unable to get _CRS data on object\n");
+		return status;
+	}
+
+	res = (struct acpi_resource_vendor *)acpi_get_crs_type(&buf, &offset, ACPI_RSTYPE_VENDOR);
+	if (!res) {
+		printk(KERN_ERR PREFIX "Failed to find config space for device\n");
+		acpi_dispose_crs(&buf);
+		return AE_NOT_FOUND;
+	}
+
+	hp_res = (struct acpi_hp_vendor_long *)(res->reserved);
+
+	if (res->length != HP_CCSR_LENGTH || hp_res->guid_id != HP_CCSR_TYPE) {
+		printk(KERN_ERR PREFIX "Unknown Vendor data\n");
+		acpi_dispose_crs(&buf);
+		return AE_TYPE; /* Revisit error? */
+	}
+
+	memcpy(&vendor_guid, hp_res->guid, sizeof(efi_guid_t));
+	if (efi_guidcmp(vendor_guid, HP_CCSR_GUID) != 0) {
+		printk(KERN_ERR PREFIX "Vendor GUID does not match\n");
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
diff -urN linux-2.5.64/include/asm-ia64/acpi-ext.h linux-work/include/asm-ia64/acpi-ext.h
--- linux-2.5.64/include/asm-ia64/acpi-ext.h	Wed Dec 31 17:00:00 1969
+++ linux-work/include/asm-ia64/acpi-ext.h	Thu Apr  3 08:37:50 2003
@@ -0,0 +1,29 @@
+/*
+ * ia64/platform/hp/common/hp_acpi.h
+ *
+ * Copyright (C) 2003 Hewlett Packard
+ * Copyright (C) Alex Williamson
+ *
+ * Vendor specific extensions to ACPI.  These are used by both
+ * HP and NEC.
+ */
+
+#define HP_CCSR_LENGTH 0x21
+#define HP_CCSR_TYPE 0x2
+#define HP_CCSR_GUID EFI_GUID(0x69e9adf9, 0x924f, 0xab5f, \
+                              0xf6, 0x4a, 0x24, 0xd2, 0x01, 0x37, 0x0e, 0xad)
+
+struct acpi_hp_vendor_long {
+	u8      guid_id;
+	u8      guid[16];
+	u8      csr_base[8];
+	u8      csr_length[8];
+};
+
+acpi_status hp_acpi_csr_space(acpi_handle, u64 *base, u64 *length);
+
+extern acpi_status acpi_get_crs(acpi_handle, struct acpi_buffer *);
+extern struct acpi_resource *acpi_get_crs_next(struct acpi_buffer *, int *);
+extern union acpi_resource_data *acpi_get_crs_type(struct acpi_buffer *, int *, int);
+extern void acpi_dispose_crs(struct acpi_buffer *);
+
diff -urN linux-2.5.64/include/linux/pci_ids.h linux-work/include/linux/pci_ids.h
--- linux-2.5.64/include/linux/pci_ids.h	Tue Mar  4 20:29:17 2003
+++ linux-work/include/linux/pci_ids.h	Tue Apr  1 09:19:53 2003
@@ -594,6 +594,8 @@
 #define PCI_DEVICE_ID_HP_DIVA_TOSCA1	0x1049
 #define PCI_DEVICE_ID_HP_DIVA_TOSCA2	0x104A
 #define PCI_DEVICE_ID_HP_DIVA_MAESTRO	0x104B
+#define PCI_DEVICE_ID_HP_REO_SBA	0x10f0
+#define PCI_DEVICE_ID_HP_REO_IOC	0x10f1
 #define PCI_DEVICE_ID_HP_VISUALIZE_FXE	0x108b
 #define PCI_DEVICE_ID_HP_DIVA_HALFDOME	0x1223
 #define PCI_DEVICE_ID_HP_DIVA_KEYSTONE	0x1226

--------------5BFD0B47F37B821588978C38--


