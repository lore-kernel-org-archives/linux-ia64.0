From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 21 Aug 2001 03:55:13 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.9)
Message-Id: <marc-linux-ia64-105590698805093@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest IA-64 patch is available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.9-ia64-010820.diff*.

The big news in this patch is a major cleanup of the DRM source
tree(s) by Chris Ahna.  Much of the ia64 specific code has now been
restructured so it fits much better into the existing framework.  This
should make it a lot easier in getting the changes accepted by the DRM
maintainers.  Other changes:

 o Small bug fix to the perfmon support (Stephane)
 o Various updated for 2.4.9.
 o Minor fixes to get rid of warnings (code in ACPI and the cs4281 and
   qla1280 driver are affected by this)
   
Enjoy,

	--david

diff -urN linux-davidm/Documentation/Configure.help lia64/Documentation/Configure.help
--- linux-davidm/Documentation/Configure.help	Mon Aug 20 18:58:50 2001
+++ lia64/Documentation/Configure.help	Mon Aug 20 17:31:11 2001
@@ -2537,7 +2537,7 @@
 CONFIG_AGP_I460
   This option gives you AGP support for the Intel 460GX chipset.  This
   chipset, the first to support Intel Itanium processors, is new and
-  this option is correspondingly experimental.
+  this option is correspondingly a little experimental.
 
   If you don't have a 460GX based machine (such as BigSur) with an AGP 
   slot then this option isn't going to do you much good.  If you're
diff -urN linux-davidm/Makefile lia64/Makefile
--- linux-davidm/Makefile	Mon Aug 20 18:58:50 2001
+++ lia64/Makefile	Mon Aug 20 17:31:11 2001
@@ -136,9 +136,6 @@
 	drivers/net/net.o \
 	drivers/media/media.o
 DRIVERS-$(CONFIG_AGP) += drivers/char/agp/agp.o
-ifeq ($(CONFIG_AGP)$(CONFIG_AGP_PTE_FIXUPS), my)
-DRIVERS-y += drivers/char/agp/agp.o
-endif
 DRIVERS-$(CONFIG_DRM_NEW) += drivers/char/drm/drm.o
 DRIVERS-$(CONFIG_DRM_OLD) += drivers/char/drm-4.0/drm.o
 DRIVERS-$(CONFIG_NUBUS) += drivers/nubus/nubus.a
diff -urN linux-davidm/arch/ia64/kernel/perfmon.c lia64/arch/ia64/kernel/perfmon.c
--- linux-davidm/arch/ia64/kernel/perfmon.c	Mon Aug 20 17:57:14 2001
+++ lia64/arch/ia64/kernel/perfmon.c	Mon Aug 20 13:09:57 2001
@@ -657,6 +657,16 @@
 
 			/* upper part is ignored on rval */
 			ia64_set_pmd(cnum, ctx->ctx_pmds[i].smpl_rval);
+
+			/* 
+			 * we must reset BTB index (clears pmd16.full to make
+			 * sure we do not report the same branches twice.
+			 * The non-blocking case in handled in update_counters().
+			 */
+			if (cnum = ctx->ctx_btb_counter) {
+				DBprintk(("reseting PMD16\n"));
+				ia64_set_pmd(16, 0);
+			}
 		}
 	}
 }
diff -urN linux-davidm/arch/ia64/kernel/smpboot.c lia64/arch/ia64/kernel/smpboot.c
--- linux-davidm/arch/ia64/kernel/smpboot.c	Mon Aug 20 17:57:14 2001
+++ lia64/arch/ia64/kernel/smpboot.c	Mon Aug 20 18:43:28 2001
@@ -324,8 +324,7 @@
 	phys_id = hard_smp_processor_id();
 
 	if (test_and_set_bit(cpuid, &cpu_online_map)) {
-		printk("huh, phys CPU#0x%x, CPU#0x%x already present??\n", 
-					phys_id, cpuid);
+		printk("huh, phys CPU#0x%x, CPU#0x%x already present??\n", phys_id, cpuid);
 		BUG();
 	}
 
diff -urN linux-davidm/drivers/acpi/acpiconf.c lia64/drivers/acpi/acpiconf.c
--- linux-davidm/drivers/acpi/acpiconf.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/acpi/acpiconf.c	Mon Aug 20 18:46:14 2001
@@ -243,10 +243,11 @@
 	acpi_rpb_t		rpb;
 	PCI_ROUTING_TABLE	*prt;
 
-	ACPI_BUFFER		ret_buf;
 	UINT8			path_name[PATHNAME_MAX];
 
 #ifdef	CONFIG_ACPI_KERNEL_CONFIG_DEBUG
+	ACPI_BUFFER		ret_buf;
+
 	ret_buf.length  = PATHNAME_MAX;
 	ret_buf.pointer = (void *) path_name;
 
@@ -325,10 +326,11 @@
 	NATIVE_UINT		devfn;
 	UINT8			bn;
 
-	ACPI_BUFFER		ret_buf;
 	UINT8			path_name[PATHNAME_MAX];
 
 #ifdef	CONFIG_ACPI_KERNEL_CONFIG_DEBUG
+	ACPI_BUFFER		ret_buf;
+
 	ret_buf.length  = PATHNAME_MAX;
 	ret_buf.pointer = (void *) path_name;
 
@@ -422,10 +424,11 @@
 	NATIVE_UINT		temp = 0x0F;
 	ACPI_STATUS		status;
 
-	ACPI_BUFFER		ret_buf;
 	UINT8			path_name[PATHNAME_MAX];
 
 #ifdef	CONFIG_ACPI_KERNEL_CONFIG_DEBUG
+	ACPI_BUFFER		ret_buf;
+
 	ret_buf.length  = PATHNAME_MAX;
 	ret_buf.pointer = (void *) path_name;
 
diff -urN linux-davidm/drivers/acpi/driver.c lia64/drivers/acpi/driver.c
--- linux-davidm/drivers/acpi/driver.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/acpi/driver.c	Mon Aug 20 18:46:23 2001
@@ -87,7 +87,7 @@
 		return -ENODEV;
 	}
 #else
-	rsdp_phys = efi.acpi;
+	rsdp_phys = (ACPI_PHYSICAL_ADDRESS) efi.acpi;
 #endif
 
 	/* from this point on, on error we must call acpi_terminate() */
diff -urN linux-davidm/drivers/char/Config.in lia64/drivers/char/Config.in
--- linux-davidm/drivers/char/Config.in	Mon Aug 20 18:58:53 2001
+++ lia64/drivers/char/Config.in	Mon Aug 20 17:31:11 2001
@@ -189,10 +189,7 @@
 if [ "$CONFIG_AGP" != "n" ]; then
    bool '  Intel 440LX/BX/GX and I815/I840/I850 support' CONFIG_AGP_INTEL
    if [ "$CONFIG_IA64" != "n" ]; then
-   	bool '  Intel 460GX support (EXPERIMENTAL)' CONFIG_AGP_I460
-	if [ "$CONFIG_AGP_I460" != "n" ]; then
-		define_bool CONFIG_AGP_PTE_FIXUPS y
-	fi
+   	bool '  Intel 460GX support' CONFIG_AGP_I460
    fi
    bool '  Intel I810/I815 (on-board) support' CONFIG_AGP_I810
    bool '  VIA chipset support' CONFIG_AGP_VIA
diff -urN linux-davidm/drivers/char/Makefile lia64/drivers/char/Makefile
--- linux-davidm/drivers/char/Makefile	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/Makefile	Mon Aug 20 17:31:11 2001
@@ -201,9 +201,6 @@
 subdir-$(CONFIG_DRM_OLD) += drm-4.0
 subdir-$(CONFIG_PCMCIA) += pcmcia
 subdir-$(CONFIG_AGP) += agp
-ifeq ($(CONFIG_AGP)$(CONFIG_AGP_PTE_FIXUPS), my)
-	subdir-y += agp
-endif
 
 ifeq ($(CONFIG_FTAPE),y)
 obj-y       += ftape/ftape.o
diff -urN linux-davidm/drivers/char/agp/Makefile lia64/drivers/char/agp/Makefile
--- linux-davidm/drivers/char/agp/Makefile	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/agp/Makefile	Mon Aug 20 18:09:28 2001
@@ -5,13 +5,12 @@
 
 O_TARGET	:= agp.o
 
-export-objs := agpgart_be.o vmmap.o
+export-objs := agpgart_be.o
 
 list-multi := agpgart.o
 agpgart-objs := agpgart_fe.o agpgart_be.o
 
 obj-$(CONFIG_AGP) += agpgart.o
-obj-$(CONFIG_AGP_PTE_FIXUPS) += vmmap.o
 
 include $(TOPDIR)/Rules.make
 
diff -urN linux-davidm/drivers/char/agp/vmmap.c lia64/drivers/char/agp/vmmap.c
--- linux-davidm/drivers/char/agp/vmmap.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/agp/vmmap.c	Wed Dec 31 16:00:00 1969
@@ -1,234 +0,0 @@
-/*
- * vmmap.c
- *
- * Hack to allow virtual addressing fixups in the kernel's
- * vmalloc area.  This is needed so that the page tables in the
- * kernel's vmalloc area can be used to emulate GART translation
- * This file is currently good for 460GX only.
- *
- * This file is basically a copy of mm/vmalloc.c modified to not
- * allocate and free pages.
- *
- * Chris Ahna <christopher.j.ahna@intel.com>
- */
-
-#include <linux/config.h>
-#include <linux/slab.h>
-#include <linux/vmalloc.h>
-#include <linux/spinlock.h>
-#include <linux/module.h>
-#include <linux/agp_backend.h>
-#include <linux/highmem.h>
-
-#include <asm/uaccess.h>
-#include <asm/pgalloc.h>
-
-#include "agp.h"
-
-#ifdef CONFIG_AGP_PTE_FIXUPS
-EXPORT_SYMBOL(agp_vmmap);
-EXPORT_SYMBOL(agp_vmunmap);
-EXPORT_SYMBOL(agp_flush_tlb_all);
-
-static inline void agp_free_area_pte(pmd_t * pmd, unsigned long address, unsigned long size)
-{
-	pte_t * pte;
-	unsigned long end;
-
-	if (pmd_none(*pmd))
-		return;
-	if (pmd_bad(*pmd)) {
-		pmd_ERROR(*pmd);
-		pmd_clear(pmd);
-		return;
-	}
-	pte = pte_offset(pmd, address);
-	address &= ~PMD_MASK;
-	end = address + size;
-	if (end > PMD_SIZE)
-		end = PMD_SIZE;
-	do {
-		pte_t page;
-		page = ptep_get_and_clear(pte);
-		address += PAGE_SIZE;
-		pte++;
-		if (pte_none(page) || pte_present(page)) {
-			continue;
-		}
-		printk(KERN_CRIT "Whee.. Swapped out page in kernel page table\n");
-	} while (address < end);
-}
-
-static inline void agp_free_area_pmd(pgd_t * dir, unsigned long address, unsigned long size)
-{
-	pmd_t * pmd;
-	unsigned long end;
-
-	if (pgd_none(*dir))
-		return;
-	if (pgd_bad(*dir)) {
-		pgd_ERROR(*dir);
-		pgd_clear(dir);
-		return;
-	}
-	pmd = pmd_offset(dir, address);
-	address &= ~PGDIR_MASK;
-	end = address + size;
-	if (end > PGDIR_SIZE)
-		end = PGDIR_SIZE;
-	do {
-		agp_free_area_pte(pmd, address, end - address);
-		address = (address + PMD_SIZE) & PMD_MASK;
-		pmd++;
-	} while (address < end);
-}
-
-void agp_vmfree_area_pages(unsigned long address, unsigned long size)
-{
-	pgd_t * dir;
-	unsigned long end = address + size;
-
-	dir = pgd_offset_k(address);
-	flush_cache_all();
-	do {
-		agp_free_area_pmd(dir, address, end - address);
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
-	flush_tlb_all();
-}
-
-static inline int agp_alloc_area_pte (pte_t * pte, unsigned long address,
-			unsigned long size, unsigned long target, pgprot_t prot)
-{
-	unsigned long end;
-
-	address &= ~PMD_MASK;
-	end = address + size;
-	if (end > PMD_SIZE)
-		end = PMD_SIZE;
-	target = (unsigned long) __va(target);
-	do {
-		struct page * page;
-		page = virt_to_page(target);
-		if (!pte_none(*pte))
-			printk(KERN_ERR "alloc_area_pte: page already exists\n");
-		if (!page)
-			return -ENOMEM;
-		set_pte(pte, mk_pte(page, prot));
-		address += PAGE_SIZE;
-		target += PAGE_SIZE;
-		pte++;
-	} while (address < end);
-	return 0;
-}
-
-static inline int agp_alloc_area_pmd(pmd_t * pmd, unsigned long address, unsigned long size, unsigned long target, pgprot_t prot)
-{
-	unsigned long end;
-
-	address &= ~PGDIR_MASK;
-	end = address + size;
-	if (end > PGDIR_SIZE)
-		end = PGDIR_SIZE;
-	do {
-		pte_t * pte = pte_alloc(&init_mm, pmd, address);
-		if (!pte)
-			return -ENOMEM;
-		if (agp_alloc_area_pte(pte, address, end - address, target, prot))
-			return -ENOMEM;
-		target += ((address + PMD_SIZE) & PMD_MASK) - address;
-		address = (address + PMD_SIZE) & PMD_MASK;
-		pmd++;
-	} while (address < end);
-	return 0;
-}
-
-inline int agp_vmalloc_area_pages (unsigned long address, unsigned long size,
-                               unsigned long target, pgprot_t prot)
-{
-	pgd_t * dir;
-	unsigned long end = address + size;
-	int ret;
-
-	dir = pgd_offset_k(address);
-	flush_cache_all();
-	spin_lock(&init_mm.page_table_lock);
-	do {
-		pmd_t *pmd;
-
-		pmd = pmd_alloc(&init_mm, dir, address);
-		ret = -ENOMEM;
-		if (!pmd)
-			break;
-
-		ret = -ENOMEM;
-		if (agp_alloc_area_pmd(pmd, address, end - address, target, prot))
-			break;
-
-		target += ((address + PGDIR_SIZE) & PGDIR_MASK) - address;
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-
-		ret = 0;
-	} while (address && (address < end));
-	spin_unlock(&init_mm.page_table_lock);
-	flush_tlb_all();
-	return ret;
-}
-
-void agp_vmunmap(void *addr)
-{
-	struct vm_struct **p, *tmp;
-
-	if (!addr)
-		return;
-	if ((PAGE_SIZE-1) & (unsigned long) addr) {
-		printk(KERN_ERR "Trying to vfree() bad address (%p)\n", addr);
-		return;
-	}
-	write_lock(&vmlist_lock);
-	for (p = &vmlist ; (tmp = *p) ; p = &tmp->next) {
-		if (tmp->addr = addr) {
-			*p = tmp->next;
-			agp_vmfree_area_pages(VMALLOC_VMADDR(tmp->addr), tmp->size);
-			write_unlock(&vmlist_lock);
-			kfree(tmp);
-			return;
-		}
-	}
-	write_unlock(&vmlist_lock);
-	printk(KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n", addr);
-}
-
-void *__agp_vmmap (unsigned long size, unsigned long target, pgprot_t prot)
-{
-	void * addr;
-	struct vm_struct *area;
-
-	size = PAGE_ALIGN(size);
-	if (!size) {
-		BUG();
-		return NULL;
-	}
-	area = get_vm_area(size, VM_ALLOC);
-	if (!area)
-		return NULL;
-	addr = area->addr;
-	if (agp_vmalloc_area_pages(VMALLOC_VMADDR(addr), size, target, prot)) {
-		vfree(addr);
-		return NULL;
-	}
-	return addr;
-}
-
-void *agp_vmmap(unsigned long offset, unsigned long size) {
-
-	return __agp_vmmap(size, offset, pgprot_writecombine(PAGE_KERNEL));
-}
-
-void agp_flush_tlb_all(void) {
-
-	flush_tlb_all();
-}
-#endif /* CONFIG_AGP_PTE_FIXUPS */
diff -urN linux-davidm/drivers/char/drm/drmP.h lia64/drivers/char/drm/drmP.h
--- linux-davidm/drivers/char/drm/drmP.h	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm/drmP.h	Mon Aug 20 18:09:30 2001
@@ -76,6 +76,17 @@
 #include <asm/pgalloc.h>
 #include "drm.h"
 
+/* page_to_bus for earlier kernels, not optimal in all cases */
+#ifndef page_to_bus
+#define page_to_bus(page)	((unsigned int)(virt_to_bus(page_address(page))))
+#endif
+
+/* We just use virt_to_bus for pci_map_single on older kernels */
+#if LINUX_VERSION_CODE < 0x020400
+#define pci_map_single(hwdev, ptr, size, direction)	virt_to_bus(ptr)
+#define pci_unmap_single(hwdev, dma_addr, size, direction)
+#endif
+
 /* DRM template customization defaults
  */
 #ifndef __HAVE_AGP
@@ -355,13 +366,14 @@
    if (len > DRM_PROC_LIMIT) { ret; *eof = 1; return len - offset; }
 
 				/* Mapping helper macros */
-#define DRM_IOREMAP(map)						\
-	(map)->handle = DRM(ioremap)( (map)->offset, (map)->size )
+#define DRM_IOREMAP(map, dev)						\
+	(map)->handle = DRM(ioremap)( (map)->offset, (map)->size, (dev) )
 
-#define DRM_IOREMAPFREE(map)						\
+#define DRM_IOREMAPFREE(map, dev)					\
 	do {								\
 		if ( (map)->handle && (map)->size )			\
-			DRM(ioremapfree)( (map)->handle, (map)->size );	\
+			DRM(ioremapfree)( (map)->handle,		\
+						 (map)->size, (dev) );	\
 	} while (0)
 
 #define DRM_FIND_MAP(_map, _o)						\
@@ -386,14 +398,6 @@
 #define DRM_BUFCOUNT(x) ((x)->count - DRM_LEFTCOUNT(x))
 #define DRM_WAITCOUNT(dev,idx) DRM_BUFCOUNT(&dev->queuelist[idx]->waitlist)
 
-#if __REALLY_HAVE_AGP && defined(CONFIG_AGP_PTE_FIXUPS)
-# define IOREMAP_SAFE(_x, _y) DRM(agp_ioremap)(_x, _y)
-# define IOUNMAP_SAFE(_x)     DRM(agp_iounmap)(_x)
-#else
-# define IOREMAP_SAFE(_x, _y) ioremap(_x, _y)
-# define IOUNMAP_SAFE(_x)     iounmap(_x)
-#endif
-
 #define DRM_GET_PRIV_SAREA(_dev, _ctx, _map) do {	\
 	(_map) = (_dev)->context_sareas[_ctx];		\
 } while(0)
@@ -624,6 +628,8 @@
 	int                acquired;
 	unsigned long      base;
    	int 		   agp_mtrr;
+	int		   cant_use_aperture;
+	unsigned long	   page_mask;
 } drm_agp_head_t;
 #endif
 
@@ -632,9 +638,7 @@
 	void            *virtual;
 	int             pages;
 	struct page     **pagelist;
-#if defined(__alpha__) && (LINUX_VERSION_CODE >= 0x020400)
 	dma_addr_t	*busaddr;
-#endif
 } drm_sg_mem_t;
 
 typedef struct drm_sigdata {
@@ -725,8 +729,8 @@
 #if __REALLY_HAVE_AGP
 	drm_agp_head_t    *agp;
 #endif
-#ifdef __alpha__
 	struct pci_dev *pdev;
+#ifdef __alpha__
 #if LINUX_VERSION_CODE < 0x020403
 	struct pci_controler *hose;
 #else
@@ -823,8 +827,10 @@
 extern unsigned long DRM(alloc_pages)(int order, int area);
 extern void	     DRM(free_pages)(unsigned long address, int order,
 				     int area);
-extern void	     *DRM(ioremap)(unsigned long offset, unsigned long size);
-extern void	     DRM(ioremapfree)(void *pt, unsigned long size);
+extern void	     *DRM(ioremap)(unsigned long offset,
+					unsigned long size, drm_device_t *dev);
+extern void	     DRM(ioremapfree)(void *pt,
+					unsigned long size, drm_device_t *dev);
 
 #if __REALLY_HAVE_AGP
 extern agp_memory    *DRM(alloc_agp)(int pages, u32 type);
@@ -1003,11 +1009,6 @@
 extern int            DRM(agp_free_memory)(agp_memory *handle);
 extern int            DRM(agp_bind_memory)(agp_memory *handle, off_t start);
 extern int            DRM(agp_unbind_memory)(agp_memory *handle);
-#ifdef CONFIG_AGP_PTE_FIXUPS
-extern void 	      *DRM(agp_ioremap)(unsigned long offset, 
-							unsigned long size);
-extern void 	      DRM(agp_iounmap)(void *handle);
-#endif
 #endif
 
 				/* Stub support (drm_stub.h) */
diff -urN linux-davidm/drivers/char/drm/drm_agpsupport.h lia64/drivers/char/drm/drm_agpsupport.h
--- linux-davidm/drivers/char/drm/drm_agpsupport.h	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm/drm_agpsupport.h	Mon Aug 20 18:09:30 2001
@@ -249,22 +249,6 @@
 	return 0;
 }
 
-#ifdef CONFIG_AGP_PTE_FIXUPS
-void *DRM(agp_ioremap)(unsigned long offset, unsigned long size)
-{
-	if(drm_agp->ioremap)
-		return drm_agp->ioremap(offset, size);
-
-	return NULL;
-}
-
-void DRM(agp_iounmap)(void *handle)
-{
-	if(drm_agp->iounmap)
-		drm_agp->iounmap(handle);
-}
-#endif /* CONFIG_AGP_PTE_FIXUPS */
-
 drm_agp_head_t *DRM(agp_init)(void)
 {
 	drm_agp_head_t *head         = NULL;
@@ -333,6 +317,14 @@
 
 		default:		head->chipset = "Unknown";       break;
 		}
+#if LINUX_VERSION_CODE <= 0x020408
+		head->cant_use_aperture = 0;
+		head->page_mask = ~(0xfff);
+#else
+		head->cant_use_aperture = head->agp_info.cant_use_aperture;
+		head->page_mask = head->agp_info.page_mask;
+#endif
+
 		DRM_INFO("AGP %d.%d on %s @ 0x%08lx %ZuMB\n",
 			 head->agp_info.version.major,
 			 head->agp_info.version.minor,
diff -urN linux-davidm/drivers/char/drm/drm_bufs.h lia64/drivers/char/drm/drm_bufs.h
--- linux-davidm/drivers/char/drm/drm_bufs.h	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm/drm_bufs.h	Mon Aug 20 18:09:30 2001
@@ -124,7 +124,7 @@
 					      MTRR_TYPE_WRCOMB, 1 );
 		}
 #endif
-		map->handle = DRM(ioremap)( map->offset, map->size );
+		map->handle = DRM(ioremap)( map->offset, map->size, dev );
 		break;
 
 	case _DRM_SHM:
@@ -249,7 +249,7 @@
 				DRM_DEBUG("mtrr_del = %d\n", retcode);
 			}
 #endif
-			DRM(ioremapfree)(map->handle, map->size);
+			DRM(ioremapfree)(map->handle, map->size, dev);
 			break;
 		case _DRM_SHM:
 			vfree(map->handle);
diff -urN linux-davidm/drivers/char/drm/drm_drv.h lia64/drivers/char/drm/drm_drv.h
--- linux-davidm/drivers/char/drm/drm_drv.h	Wed Aug  8 09:42:14 2001
+++ lia64/drivers/char/drm/drm_drv.h	Mon Aug 20 18:09:31 2001
@@ -438,7 +438,7 @@
 					DRM_DEBUG( "mtrr_del=%d\n", retcode );
 				}
 #endif
-				DRM(ioremapfree)( map->handle, map->size );
+				DRM(ioremapfree)( map->handle, map->size, dev );
 				break;
 			case _DRM_SHM:
 				vfree(map->handle);
diff -urN linux-davidm/drivers/char/drm/drm_ioctl.h lia64/drivers/char/drm/drm_ioctl.h
--- linux-davidm/drivers/char/drm/drm_ioctl.h	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm/drm_ioctl.h	Mon Aug 20 18:09:31 2001
@@ -98,7 +98,6 @@
 	}
 	sprintf(dev->devname, "%s@%s", dev->name, dev->unique);
 
-#ifdef __alpha__
 	do {
 		struct pci_dev *pci_dev;
                 int b, d, f;
@@ -116,10 +115,11 @@
                 pci_dev = pci_find_slot(b, PCI_DEVFN(d,f));
                 if (pci_dev) {
 			dev->pdev = pci_dev;
-                        dev->hose = pci_dev->sysdata;
+#ifdef __alpha__
+			dev->hose = pci_dev->sysdata;
+#endif
 		}
         } while(0);
-#endif
 
 	return 0;
 }
diff -urN linux-davidm/drivers/char/drm/drm_memory.h lia64/drivers/char/drm/drm_memory.h
--- linux-davidm/drivers/char/drm/drm_memory.h	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm/drm_memory.h	Mon Aug 20 18:09:31 2001
@@ -306,7 +306,7 @@
 	}
 }
 
-void *DRM(ioremap)(unsigned long offset, unsigned long size)
+void *DRM(ioremap)(unsigned long offset, unsigned long size, drm_device_t *dev)
 {
 	void *pt;
 
@@ -316,12 +316,52 @@
 		return NULL;
 	}
 
-	if (!(pt = IOREMAP_SAFE(offset, size))) {
+	if(dev->agp->cant_use_aperture = 0) {
+		goto standard_ioremap;
+	} else {
+		drm_map_t *map    = NULL;
+		drm_map_list_t  *r_list;
+		struct list_head *list, *head;
+
+		list_for_each(list, &dev->maplist->head) {
+			r_list = (drm_map_list_t *)list;
+			map = r_list->map;
+			if (!map) continue;
+			if (map->offset <= offset &&
+				(map->offset + map->size) >= (offset + size))
+				break;
+		}
+		
+		if(map && map->type = _DRM_AGP) {
+			struct drm_agp_mem *agpmem;
+
+			for(agpmem = dev->agp->memory; agpmem;
+						agpmem = agpmem->next) {
+				if(agpmem->bound <= offset &&
+				   (agpmem->bound + (agpmem->pages
+					<< PAGE_SHIFT)) >= (offset + size))
+					break;
+			}
+
+			if(agpmem = NULL)
+				goto standard_ioremap;
+
+			pt = agpmem->memory->vmptr + (offset - agpmem->bound);
+			goto ioremap_success;
+		} else {
+			goto standard_ioremap;
+		}
+	}
+
+standard_ioremap:
+	if (!(pt = ioremap(offset, size))) {
 		spin_lock(&DRM(mem_lock));
 		++DRM(mem_stats)[DRM_MEM_MAPPINGS].fail_count;
 		spin_unlock(&DRM(mem_lock));
 		return NULL;
 	}
+
+ioremap_success:
 	spin_lock(&DRM(mem_lock));
 	++DRM(mem_stats)[DRM_MEM_MAPPINGS].succeed_count;
 	DRM(mem_stats)[DRM_MEM_MAPPINGS].bytes_allocated += size;
@@ -329,7 +369,7 @@
 	return pt;
 }
 
-void DRM(ioremapfree)(void *pt, unsigned long size)
+void DRM(ioremapfree)(void *pt, unsigned long size, drm_device_t *dev)
 {
 	int alloc_count;
 	int free_count;
@@ -337,8 +377,8 @@
 	if (!pt)
 		DRM_MEM_ERROR(DRM_MEM_MAPPINGS,
 			      "Attempt to free NULL pointer\n");
-	else
-		IOUNMAP_SAFE(pt);
+	else if(dev->agp->cant_use_aperture = 0)
+		iounmap(pt);
 
 	spin_lock(&DRM(mem_lock));
 	DRM(mem_stats)[DRM_MEM_MAPPINGS].bytes_freed += size;
diff -urN linux-davidm/drivers/char/drm/drm_vm.h lia64/drivers/char/drm/drm_vm.h
--- linux-davidm/drivers/char/drm/drm_vm.h	Mon Aug 20 18:58:54 2001
+++ lia64/drivers/char/drm/drm_vm.h	Mon Aug 20 18:09:33 2001
@@ -68,55 +68,53 @@
 #endif
 {
 #if (defined(__alpha__) || defined(__ia64__)) && __REALLY_HAVE_AGP
-        drm_file_t *priv  = vma->vm_file->private_data;
-        drm_device_t *dev = priv->dev;
-        drm_map_t *map    = NULL;
-        drm_map_list_t  *r_list;
-        struct list_head *list;
+	drm_file_t *priv  = vma->vm_file->private_data;
+	drm_device_t *dev = priv->dev;
+	drm_map_t *map    = NULL;
+	drm_map_list_t  *r_list;
+	struct list_head *list;
 
-        /*
+	/*
          * Find the right map
          */
-        list_for_each(list, &dev->maplist->head) {
-                r_list = (drm_map_list_t *)list;
-                map = r_list->map;
-                if (!map) continue;
-                if (map->offset = VM_OFFSET(vma)) break;
-        }
 
-        if (map && map->type = _DRM_AGP) {
-                unsigned long offset = address - vma->vm_start;
-                unsigned long baddr = VM_OFFSET(vma) + offset, paddr;
-                struct drm_agp_mem *agpmem;
-                struct page *page;
+	if(!dev->agp->cant_use_aperture) goto vm_nopage_error;
 
-#if defined(__alpha__)
-                /*
-                 * Make it a bus-relative address
+	list_for_each(list, &dev->maplist->head) {
+		r_list = (drm_map_list_t *)list;
+		map = r_list->map;
+		if (!map) continue;
+		if (map->offset = VM_OFFSET(vma)) break;
+	}
+
+	if (map && map->type = _DRM_AGP) {
+		unsigned long offset = address - vma->vm_start;
+		unsigned long baddr = VM_OFFSET(vma) + offset, paddr;
+		struct drm_agp_mem *agpmem;
+		struct page *page;
+
+#if __alpha__
+		/*
+                 * Adjust to a bus-relative address
                  */
-                baddr -= dev->hose->mem_space->start;
+		baddr -= dev->hose->mem_space->start;
 #endif
 
-                /*
+		/*
                  * It's AGP memory - find the real physical page to map
                  */
-                for(agpmem = dev->agp->memory; agpmem; agpmem = agpmem->next) {
-                        if (agpmem->bound <= baddr &&
-                            agpmem->bound + agpmem->pages * PAGE_SIZE > baddr) 
-                                break;
-                }
-
-                if (!agpmem) {
-                        /*
-                         * Oops - no memory found
-                         */
-                        return NOPAGE_SIGBUS;   /* couldn't find it */
-                }
+		for(agpmem = dev->agp->memory; agpmem; agpmem = agpmem->next) {
+			if (agpmem->bound <= baddr &&
+			    agpmem->bound + agpmem->pages * PAGE_SIZE > baddr) 
+				break;
+		}
 
-                /*
+		if (!agpmem) goto vm_nopage_error;
+
+		/*
                  * Get the page, inc the use count, and return it
                  */
-                offset = (baddr - agpmem->bound) >> PAGE_SHIFT;
+		offset = (baddr - agpmem->bound) >> PAGE_SHIFT;
 
 		/*
 		 * This is bad.  What we really want to do here is unmask
@@ -130,12 +128,21 @@
 		paddr = (agpmem->memory->memory[offset] & 0xffffff) << 12;
 #endif
 
-                page = virt_to_page(__va(paddr));
+		page = virt_to_page(__va(paddr));
+		get_page(page);
 
-                get_page(page);
-                return page;
-        }
+		DRM_DEBUG("baddr = 0x%lx page = 0x%p, offset = 0x%lx\n",
+			  baddr, __va(agpmem->memory->memory[offset]), offset);
+
+#if LINUX_VERSION_CODE < 0x020317
+		return page_address(page);
+#else
+		return page;
 #endif
+        }
+vm_nopage_error:
+#endif /* __REALLY_HAVE_AGP */
+
 	return NOPAGE_SIGBUS;		/* Disallow mremap */
 }
 
@@ -260,7 +267,7 @@
 					DRM_DEBUG("mtrr_del = %d\n", retcode);
 				}
 #endif
-				DRM(ioremapfree)(map->handle, map->size);
+				DRM(ioremapfree)(map->handle, map->size, dev);
 				break;
 			case _DRM_SHM:
 				vfree(map->handle);
@@ -289,24 +296,27 @@
 	drm_file_t	 *priv	 = vma->vm_file->private_data;
 	drm_device_t	 *dev	 = priv->dev;
 	drm_device_dma_t *dma	 = dev->dma;
-	unsigned long	 physical;
 	unsigned long	 offset;
-	unsigned long	 page;
+	unsigned long	 page_nr;
+	struct page	 *page;
 
 	if (!dma)		   return NOPAGE_SIGBUS; /* Error */
 	if (address > vma->vm_end) return NOPAGE_SIGBUS; /* Disallow mremap */
 	if (!dma->pagelist)	   return NOPAGE_OOM ; /* Nothing allocated */
 
 	offset	 = address - vma->vm_start; /* vm_[pg]off[set] should be 0 */
-	page	 = offset >> PAGE_SHIFT;
-	physical = dma->pagelist[page] + (offset & (~PAGE_MASK));
-	atomic_inc(&virt_to_page(physical)->count); /* Dec. by kernel */
+	page_nr  = offset >> PAGE_SHIFT;
+	page = virt_to_page((dma->pagelist[page_nr] + 
+			     (offset & (~PAGE_MASK))));
+
+	get_page(page);
 
-	DRM_DEBUG("0x%08lx (page %lu) => 0x%08lx\n", address, page, physical);
+	DRM_DEBUG("0x%08lx (page %lu) => 0x%08x\n", address, page_nr, 
+		  page_to_bus(page));
 #if LINUX_VERSION_CODE < 0x020317
-	return physical;
+	return page_address(page);
 #else
-	return virt_to_page(physical);
+	return page;
 #endif
 }
 
@@ -343,10 +353,10 @@
 	map_offset = map->offset - dev->sg->handle;
 	page_offset = (offset >> PAGE_SHIFT) + (map_offset >> PAGE_SHIFT);
 	page = entry->pagelist[page_offset];
-	atomic_inc(&page->count);                       /* Dec. by kernel */
+	get_page(page);
 
 #if LINUX_VERSION_CODE < 0x020317
-	return (unsigned long)virt_to_phys(page->virtual);
+	return page_address(page);
 #else
 	return page;
 #endif
@@ -509,7 +519,7 @@
                 /*
                  * On Alpha and ia64 we can't talk to bus dma address from
                  * the CPU, so for memory of type DRM_AGP, we'll deal with
-                 * sorting out the real physical pages and mappings in
+                 * sorting out the real physical pages and mappings
                  * in nopage()
                  */
                 vma->vm_ops = &DRM(vm_ops);
@@ -520,6 +530,7 @@
 
                 break;
 #endif
+                /* fall through to _DRM_FRAME_BUFFER... */        
 	case _DRM_FRAME_BUFFER:
 	case _DRM_REGISTERS:
 		if (VM_OFFSET(vma) >= __pa(high_memory)) {
diff -urN linux-davidm/drivers/char/drm/i810_dma.c lia64/drivers/char/drm/i810_dma.c
--- linux-davidm/drivers/char/drm/i810_dma.c	Wed Aug  8 09:42:15 2001
+++ lia64/drivers/char/drm/i810_dma.c	Mon Aug 20 18:09:34 2001
@@ -315,7 +315,7 @@
 
 	   	if(dev_priv->ring.virtual_start) {
 		   	DRM(ioremapfree)((void *) dev_priv->ring.virtual_start,
-					 dev_priv->ring.Size);
+					 dev_priv->ring.Size, dev);
 		}
 	   	if(dev_priv->hw_status_page != 0UL) {
 		   	i810_free_page(dev, dev_priv->hw_status_page);
@@ -329,7 +329,8 @@
 		for (i = 0; i < dma->buf_count; i++) {
 			drm_buf_t *buf = dma->buflist[ i ];
 			drm_i810_buf_priv_t *buf_priv = buf->dev_private;
-			DRM(ioremapfree)(buf_priv->kernel_virtual, buf->total);
+			DRM(ioremapfree)(buf_priv->kernel_virtual,
+							buf->total, dev);
 		}
 	}
    	return 0;
@@ -402,7 +403,7 @@
 	   	*buf_priv->in_use = I810_BUF_FREE;
 
 		buf_priv->kernel_virtual = DRM(ioremap)(buf->bus_address,
-							buf->total);
+							buf->total, dev);
 	}
 	return 0;
 }
@@ -458,7 +459,7 @@
 
    	dev_priv->ring.virtual_start = DRM(ioremap)(dev->agp->base +
 						    init->ring_start,
-						    init->ring_size);
+						    init->ring_size, dev);
 
    	if (dev_priv->ring.virtual_start = NULL) {
 		dev->dev_private = (void *) dev_priv;
diff -urN linux-davidm/drivers/char/drm/mga_dma.c lia64/drivers/char/drm/mga_dma.c
--- linux-davidm/drivers/char/drm/mga_dma.c	Wed Aug  8 09:42:15 2001
+++ lia64/drivers/char/drm/mga_dma.c	Mon Aug 20 18:09:34 2001
@@ -557,9 +557,9 @@
 		(drm_mga_sarea_t *)((u8 *)dev_priv->sarea->handle +
 				    init->sarea_priv_offset);
 
-	DRM_IOREMAP( dev_priv->warp );
-	DRM_IOREMAP( dev_priv->primary );
-	DRM_IOREMAP( dev_priv->buffers );
+	DRM_IOREMAP( dev_priv->warp, dev );
+	DRM_IOREMAP( dev_priv->primary, dev );
+	DRM_IOREMAP( dev_priv->buffers, dev );
 
 	if(!dev_priv->warp->handle ||
 	   !dev_priv->primary->handle ||
@@ -647,9 +647,9 @@
 	if ( dev->dev_private ) {
 		drm_mga_private_t *dev_priv = dev->dev_private;
 
-		DRM_IOREMAPFREE( dev_priv->warp );
-		DRM_IOREMAPFREE( dev_priv->primary );
-		DRM_IOREMAPFREE( dev_priv->buffers );
+		DRM_IOREMAPFREE( dev_priv->warp, dev );
+		DRM_IOREMAPFREE( dev_priv->primary, dev );
+		DRM_IOREMAPFREE( dev_priv->buffers, dev );
 
 		if ( dev_priv->head != NULL ) {
 			mga_freelist_cleanup( dev );
diff -urN linux-davidm/drivers/char/drm/r128_cce.c lia64/drivers/char/drm/r128_cce.c
--- linux-davidm/drivers/char/drm/r128_cce.c	Mon Aug 20 18:58:54 2001
+++ lia64/drivers/char/drm/r128_cce.c	Mon Aug 20 18:09:34 2001
@@ -593,9 +593,9 @@
 				     init->sarea_priv_offset);
 
 	if ( !dev_priv->is_pci ) {
-		DRM_IOREMAP( dev_priv->cce_ring );
-		DRM_IOREMAP( dev_priv->ring_rptr );
-		DRM_IOREMAP( dev_priv->buffers );
+		DRM_IOREMAP( dev_priv->cce_ring, dev );
+		DRM_IOREMAP( dev_priv->ring_rptr, dev );
+		DRM_IOREMAP( dev_priv->buffers, dev );
 		if(!dev_priv->cce_ring->handle ||
 		   !dev_priv->ring_rptr->handle ||
 		   !dev_priv->buffers->handle) {
@@ -667,9 +667,9 @@
 		drm_r128_private_t *dev_priv = dev->dev_private;
 
 		if ( !dev_priv->is_pci ) {
-			DRM_IOREMAPFREE( dev_priv->cce_ring );
-			DRM_IOREMAPFREE( dev_priv->ring_rptr );
-			DRM_IOREMAPFREE( dev_priv->buffers );
+			DRM_IOREMAPFREE( dev_priv->cce_ring, dev );
+			DRM_IOREMAPFREE( dev_priv->ring_rptr, dev );
+			DRM_IOREMAPFREE( dev_priv->buffers, dev );
 		} else {
 			if (!DRM(ati_pcigart_cleanup)( dev,
 						dev_priv->phys_pci_gart,
diff -urN linux-davidm/drivers/char/drm/radeon_cp.c lia64/drivers/char/drm/radeon_cp.c
--- linux-davidm/drivers/char/drm/radeon_cp.c	Mon Aug 20 18:58:54 2001
+++ lia64/drivers/char/drm/radeon_cp.c	Mon Aug 20 18:09:34 2001
@@ -641,6 +641,7 @@
 
 		tmp_ofs = dev_priv->ring_rptr->offset - dev->sg->handle;
 		page_ofs = tmp_ofs >> PAGE_SHIFT;
+
 #if defined(__alpha__) && (LINUX_VERSION_CODE >= 0x020400)
 		RADEON_WRITE( RADEON_CP_RB_RPTR_ADDR,
 			     entry->busaddr[page_ofs]);
@@ -865,9 +866,9 @@
 				       init->sarea_priv_offset);
 
 	if ( !dev_priv->is_pci ) {
-		DRM_IOREMAP( dev_priv->cp_ring );
-		DRM_IOREMAP( dev_priv->ring_rptr );
-		DRM_IOREMAP( dev_priv->buffers );
+		DRM_IOREMAP( dev_priv->cp_ring, dev );
+		DRM_IOREMAP( dev_priv->ring_rptr, dev );
+		DRM_IOREMAP( dev_priv->buffers, dev );
 		if(!dev_priv->cp_ring->handle ||
 		   !dev_priv->ring_rptr->handle ||
 		   !dev_priv->buffers->handle) {
@@ -1012,9 +1013,9 @@
 		drm_radeon_private_t *dev_priv = dev->dev_private;
 
 		if ( !dev_priv->is_pci ) {
-			DRM_IOREMAPFREE( dev_priv->cp_ring );
-			DRM_IOREMAPFREE( dev_priv->ring_rptr );
-			DRM_IOREMAPFREE( dev_priv->buffers );
+			DRM_IOREMAPFREE( dev_priv->cp_ring, dev );
+			DRM_IOREMAPFREE( dev_priv->ring_rptr, dev );
+			DRM_IOREMAPFREE( dev_priv->buffers, dev );
 		} else {
 			if (!DRM(ati_pcigart_cleanup)( dev,
 						dev_priv->phys_pci_gart,
diff -urN linux-davidm/drivers/char/drm/tdfx_drv.c lia64/drivers/char/drm/tdfx_drv.c
--- linux-davidm/drivers/char/drm/tdfx_drv.c	Wed Aug  8 09:42:15 2001
+++ lia64/drivers/char/drm/tdfx_drv.c	Mon Aug 20 18:09:34 2001
@@ -44,13 +44,30 @@
 #define DRIVER_MINOR		0
 #define DRIVER_PATCHLEVEL	0
 
+#ifndef PCI_VENDOR_ID_3DFX
+#define PCI_VENDOR_ID_3DFX 0x121A
+#endif
 #ifndef PCI_DEVICE_ID_3DFX_VOODOO5
 #define PCI_DEVICE_ID_3DFX_VOODOO5 0x0009
 #endif
+#ifndef PCI_DEVICE_ID_3DFX_VOODOO4
+#define PCI_DEVICE_ID_3DFX_VOODOO4 0x0007
+#endif
+#ifndef PCI_DEVICE_ID_3DFX_VOODOO3_3000 /* Voodoo3 3000 */
+#define PCI_DEVICE_ID_3DFX_VOODOO3_3000 0x0005
+#endif
+#ifndef PCI_DEVICE_ID_3DFX_VOODOO3_2000 /* Voodoo3 3000 */
+#define PCI_DEVICE_ID_3DFX_VOODOO3_2000 0x0004
+#endif
+#ifndef PCI_DEVICE_ID_3DFX_BANSHEE
+#define PCI_DEVICE_ID_3DFX_BANSHEE 0x0003
+#endif
 
 static drm_pci_list_t DRM(idlist)[] = {
 	{ PCI_VENDOR_ID_3DFX, PCI_DEVICE_ID_3DFX_BANSHEE },
-	{ PCI_VENDOR_ID_3DFX, PCI_DEVICE_ID_3DFX_VOODOO3 },
+	{ PCI_VENDOR_ID_3DFX, PCI_DEVICE_ID_3DFX_VOODOO3_2000 },
+	{ PCI_VENDOR_ID_3DFX, PCI_DEVICE_ID_3DFX_VOODOO3_3000 },
+	{ PCI_VENDOR_ID_3DFX, PCI_DEVICE_ID_3DFX_VOODOO4 },
 	{ PCI_VENDOR_ID_3DFX, PCI_DEVICE_ID_3DFX_VOODOO5 },
 	{ 0, 0 }
 };
diff -urN linux-davidm/drivers/char/drm-4.0/agpsupport.c lia64/drivers/char/drm-4.0/agpsupport.c
--- linux-davidm/drivers/char/drm-4.0/agpsupport.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/agpsupport.c	Mon Aug 20 18:09:34 2001
@@ -193,22 +193,6 @@
 	return drm_unbind_agp(entry->memory);
 }
 
-#ifdef CONFIG_AGP_PTE_FIXUPS
-void *drm_agp_ioremap(unsigned long offset, unsigned long size)
-{
-	if(drm_agp->ioremap)
-		return drm_agp->ioremap(offset, size);
-
-	return NULL;
-}
-
-void drm_agp_iounmap(void *handle)
-{
-	if(drm_agp->iounmap)
-		drm_agp->iounmap(handle);
-}
-#endif /* CONFIG_AGP_PTE_FIXUPS */
-
 int drm_agp_bind(struct inode *inode, struct file *filp, unsigned int cmd,
 		 unsigned long arg)
 {
@@ -310,11 +294,19 @@
 		case ALI_M1651: 	head->chipset = "ALi M1651";	 break;
 		case SVWRKS_GENERIC:	head->chipset = "Serverworks Generic";
 			break;
-		case SVWRKS_HE: 	head->chipset = "Serverworks HE";
-		case SVWRKS_LE: 	head->chipset = "Serverworks LE";
+		case SVWRKS_HE: 	head->chipset = "Serverworks HE"; break;
+		case SVWRKS_LE: 	head->chipset = "Serverworks LE"; break;
 
 		default:		head->chipset = "Unknown";       break;
 		}
+#if LINUX_VERSION_CODE <= 0x020408
+		head->cant_use_aperture = 0;
+		head->page_mask = ~(0xfff);
+#else
+		head->cant_use_aperture = head->agp_info.cant_use_aperture;
+		head->page_mask = head->agp_info.page_mask;
+#endif
+
 		DRM_INFO("AGP %d.%d on %s @ 0x%08lx %ZuMB\n",
 			 head->agp_info.version.major,
 			 head->agp_info.version.minor,
diff -urN linux-davidm/drivers/char/drm-4.0/bufs.c lia64/drivers/char/drm-4.0/bufs.c
--- linux-davidm/drivers/char/drm-4.0/bufs.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/bufs.c	Mon Aug 20 18:09:34 2001
@@ -87,7 +87,7 @@
 					     MTRR_TYPE_WRCOMB, 1);
 		}
 #endif
-		map->handle = drm_ioremap(map->offset, map->size);
+		map->handle = drm_ioremap(map->offset, map->size, dev);
 		break;
 			
 
diff -urN linux-davidm/drivers/char/drm-4.0/drm.h lia64/drivers/char/drm-4.0/drm.h
--- linux-davidm/drivers/char/drm-4.0/drm.h	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/drm.h	Mon Aug 20 18:09:34 2001
@@ -84,7 +84,7 @@
 #include "i810_drm.h"
 #include "r128_drm.h"
 #include "radeon_drm.h"
-#ifdef CONFIG_DRM_SIS
+#ifdef CONFIG_DRM40_SIS
 #include "sis_drm.h"
 #endif
 
@@ -399,7 +399,7 @@
 #define DRM_IOCTL_RADEON_STIPPLE	DRM_IOW( 0x4c, drm_radeon_stipple_t)
 #define DRM_IOCTL_RADEON_INDIRECT	DRM_IOWR(0x4d, drm_radeon_indirect_t)
 
-#ifdef CONFIG_DRM_SIS
+#ifdef CONFIG_DRM40_SIS
 /* SiS specific ioctls */
 #define SIS_IOCTL_FB_ALLOC		DRM_IOWR(0x44, drm_sis_mem_t)
 #define SIS_IOCTL_FB_FREE		DRM_IOW( 0x45, drm_sis_mem_t)
diff -urN linux-davidm/drivers/char/drm-4.0/drmP.h lia64/drivers/char/drm-4.0/drmP.h
--- linux-davidm/drivers/char/drm-4.0/drmP.h	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/drmP.h	Mon Aug 20 18:20:22 2001
@@ -294,14 +294,6 @@
 #define DRM_BUFCOUNT(x) ((x)->count - DRM_LEFTCOUNT(x))
 #define DRM_WAITCOUNT(dev,idx) DRM_BUFCOUNT(&dev->queuelist[idx]->waitlist)
 
-#ifdef CONFIG_AGP_PTE_FIXUPS
-# define IOREMAP_SAFE(_x, _y) drm_agp_ioremap(_x, _y)
-# define IOUNMAP_SAFE(_x)     drm_agp_iounmap(_x)
-#else
-# define IOREMAP_SAFE(_x, _y) ioremap(_x, _y)
-# define IOUNMAP_SAFE(_x)     iounmap(_x)
-#endif
-
 typedef int drm_ioctl_t(struct inode *inode, struct file *filp,
 			unsigned int cmd, unsigned long arg);
 
@@ -518,6 +510,8 @@
 	int                acquired;
 	unsigned long      base;
    	int 		   agp_mtrr;
+	int		   cant_use_aperture;
+	unsigned long	   page_mask;
 } drm_agp_head_t;
 #endif
 
@@ -686,8 +680,10 @@
 extern unsigned long drm_alloc_pages(int order, int area);
 extern void	     drm_free_pages(unsigned long address, int order,
 				    int area);
-extern void	     *drm_ioremap(unsigned long offset, unsigned long size);
-extern void	     drm_ioremapfree(void *pt, unsigned long size);
+extern void	     *drm_ioremap(unsigned long offset, unsigned long size,
+							drm_device_t *dev);
+extern void	     drm_ioremapfree(void *pt, unsigned long size,
+							drm_device_t *dev);
 
 #if defined(CONFIG_AGP) || defined(CONFIG_AGP_MODULE)
 extern agp_memory    *drm_alloc_agp(int pages, u32 type);
@@ -838,11 +834,6 @@
 extern int            drm_agp_free_memory(agp_memory *handle);
 extern int            drm_agp_bind_memory(agp_memory *handle, off_t start);
 extern int            drm_agp_unbind_memory(agp_memory *handle);
-#ifdef CONFIG_AGP_PTE_FIXUPS
-extern void 	      *drm_agp_ioremap(unsigned long offset, 
-							unsigned long size);
-extern void 	      drm_agp_iounmap(void *handle);
-#endif
 #endif
 #endif
 #endif
diff -urN linux-davidm/drivers/char/drm-4.0/ffb_drv.c lia64/drivers/char/drm-4.0/ffb_drv.c
--- linux-davidm/drivers/char/drm-4.0/ffb_drv.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/ffb_drv.c	Mon Aug 20 18:09:34 2001
@@ -157,7 +157,7 @@
 			switch (map->type) {
 			case _DRM_REGISTERS:
 			case _DRM_FRAME_BUFFER:
-				drm_ioremapfree(map->handle, map->size);
+				drm_ioremapfree(map->handle, map->size, dev);
 				break;
 
 			case _DRM_SHM:
diff -urN linux-davidm/drivers/char/drm-4.0/gamma_drv.c lia64/drivers/char/drm-4.0/gamma_drv.c
--- linux-davidm/drivers/char/drm-4.0/gamma_drv.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/gamma_drv.c	Mon Aug 20 18:09:34 2001
@@ -257,7 +257,7 @@
 					DRM_DEBUG("mtrr_del = %d\n", retcode);
 				}
 #endif
-				drm_ioremapfree(map->handle, map->size);
+				drm_ioremapfree(map->handle, map->size, dev);
 				break;
 			case _DRM_SHM:
 				drm_free_pages((unsigned long)map->handle,
diff -urN linux-davidm/drivers/char/drm-4.0/i810_dma.c lia64/drivers/char/drm-4.0/i810_dma.c
--- linux-davidm/drivers/char/drm-4.0/i810_dma.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/i810_dma.c	Mon Aug 20 18:09:34 2001
@@ -309,7 +309,7 @@
 	   
 	   	if(dev_priv->ring.virtual_start) {
 		   	drm_ioremapfree((void *) dev_priv->ring.virtual_start,
-					dev_priv->ring.Size);
+					dev_priv->ring.Size, dev);
 		}
 	   	if(dev_priv->hw_status_page != 0UL) {
 		   	i810_free_page(dev, dev_priv->hw_status_page);
@@ -323,7 +323,8 @@
 		for (i = 0; i < dma->buf_count; i++) {
 			drm_buf_t *buf = dma->buflist[ i ];
 			drm_i810_buf_priv_t *buf_priv = buf->dev_private;
-			drm_ioremapfree(buf_priv->kernel_virtual, buf->total);
+			drm_ioremapfree(buf_priv->kernel_virtual,
+							buf->total, dev);
 		}
 	}
    	return 0;
@@ -397,7 +398,7 @@
 	   	*buf_priv->in_use = I810_BUF_FREE;
 
 		buf_priv->kernel_virtual = drm_ioremap(buf->bus_address, 
-						       buf->total);
+						       buf->total, dev);
 	}
 	return 0;
 }
@@ -434,7 +435,7 @@
 
    	dev_priv->ring.virtual_start = drm_ioremap(dev->agp->base + 
 						   init->ring_start, 
-						   init->ring_size);
+						   init->ring_size, dev);
 
    	dev_priv->ring.tail_mask = dev_priv->ring.Size - 1;
    
diff -urN linux-davidm/drivers/char/drm-4.0/i810_drv.c lia64/drivers/char/drm-4.0/i810_drv.c
--- linux-davidm/drivers/char/drm-4.0/i810_drv.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/i810_drv.c	Mon Aug 20 18:09:34 2001
@@ -285,7 +285,7 @@
 					DRM_DEBUG("mtrr_del = %d\n", retcode);
 				}
 #endif
-				drm_ioremapfree(map->handle, map->size);
+				drm_ioremapfree(map->handle, map->size, dev);
 				break;
 			case _DRM_SHM:
 				drm_free_pages((unsigned long)map->handle,
diff -urN linux-davidm/drivers/char/drm-4.0/memory.c lia64/drivers/char/drm-4.0/memory.c
--- linux-davidm/drivers/char/drm-4.0/memory.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/memory.c	Mon Aug 20 18:09:34 2001
@@ -296,7 +296,7 @@
 	}
 }
 
-void *drm_ioremap(unsigned long offset, unsigned long size)
+void *drm_ioremap(unsigned long offset, unsigned long size, drm_device_t *dev)
 {
 	void *pt;
 	
@@ -306,12 +306,50 @@
 		return NULL;
 	}
 	
-	if (!(pt = IOREMAP_SAFE(offset, size))) {
+	if(dev->agp->cant_use_aperture = 0) {
+		goto standard_ioremap;
+	} else {
+		drm_map_t *map    = NULL;
+		int i;
+
+		for(i = 0; i < dev->map_count; i++) {
+			map = dev->maplist[i];
+			if (!map) continue;
+			if (map->offset <= offset &&
+				(map->offset + map->size) >= (offset + size))
+				break;
+		}
+		
+		if(map && map->type = _DRM_AGP) {
+			struct drm_agp_mem *agpmem;
+
+			for(agpmem = dev->agp->memory; agpmem;
+						agpmem = agpmem->next) {
+				if(agpmem->bound <= offset &&
+				   (agpmem->bound + (agpmem->pages
+					<< PAGE_SHIFT)) >= (offset + size))
+					break;
+			}
+
+			if(agpmem = NULL)
+				goto standard_ioremap;
+
+			pt = agpmem->memory->vmptr + (offset - agpmem->bound);
+			goto ioremap_success;
+		} else {
+			goto standard_ioremap;
+		}
+	}
+
+standard_ioremap:
+	if (!(pt = ioremap(offset, size))) {
 		spin_lock(&drm_mem_lock);
 		++drm_mem_stats[DRM_MEM_MAPPINGS].fail_count;
 		spin_unlock(&drm_mem_lock);
 		return NULL;
 	}
+
+ioremap_success:
 	spin_lock(&drm_mem_lock);
 	++drm_mem_stats[DRM_MEM_MAPPINGS].succeed_count;
 	drm_mem_stats[DRM_MEM_MAPPINGS].bytes_allocated += size;
@@ -319,7 +357,7 @@
 	return pt;
 }
 
-void drm_ioremapfree(void *pt, unsigned long size)
+void drm_ioremapfree(void *pt, unsigned long size, drm_device_t *dev)
 {
 	int alloc_count;
 	int free_count;
@@ -327,8 +365,8 @@
 	if (!pt)
 		DRM_MEM_ERROR(DRM_MEM_MAPPINGS,
 			      "Attempt to free NULL pointer\n");
-	else
-		IOUNMAP_SAFE(pt);
+	else if(dev->agp->cant_use_aperture = 0)
+		iounmap(pt);
 	
 	spin_lock(&drm_mem_lock);
 	drm_mem_stats[DRM_MEM_MAPPINGS].bytes_freed += size;
diff -urN linux-davidm/drivers/char/drm-4.0/mga_dma.c lia64/drivers/char/drm-4.0/mga_dma.c
--- linux-davidm/drivers/char/drm-4.0/mga_dma.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/mga_dma.c	Mon Aug 20 18:09:34 2001
@@ -308,7 +308,7 @@
 	temp = ((temp + PAGE_SIZE - 1) / PAGE_SIZE) * PAGE_SIZE;
 
 	dev_priv->ioremap = drm_ioremap(dev->agp->base + offset,
-					temp);
+					temp, dev);
 	if(dev_priv->ioremap = NULL) {
 		DRM_ERROR("Ioremap failed\n");
 		return -ENOMEM;
@@ -635,7 +635,7 @@
 				    dev_priv->primary_size +
 				    PAGE_SIZE - 1) / PAGE_SIZE * PAGE_SIZE;
 
-			drm_ioremapfree((void *) dev_priv->ioremap, temp);
+			drm_ioremapfree((void *) dev_priv->ioremap, temp, dev);
 		}
 	   	if(dev_priv->status_page != NULL) {
 		   	iounmap(dev_priv->status_page);
@@ -741,9 +741,18 @@
 		return -ENOMEM;
 	}
 
-   	/* Write status page when secend or softrap occurs */
+   	/* Write status page when secend or softrap occurs
+	 *
+	 * Disable this on ia64 on the off chance that real status page will be
+	 * above 4GB.
+	 */
+#if defined(__ia64__)
    	MGA_WRITE(MGAREG_PRIMPTR,
-		  virt_to_bus((void *)dev_priv->real_status_page) | 0);
+		  virt_to_bus((void *)dev_priv->real_status_page));
+#else
+   	MGA_WRITE(MGAREG_PRIMPTR,
+		  virt_to_bus((void *)dev_priv->real_status_page) | 0x00000003);
+#endif
 
 	/* Private is now filled in, initialize the hardware */
 	{
diff -urN linux-davidm/drivers/char/drm-4.0/mga_drv.c lia64/drivers/char/drm-4.0/mga_drv.c
--- linux-davidm/drivers/char/drm-4.0/mga_drv.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/mga_drv.c	Mon Aug 20 18:09:34 2001
@@ -285,7 +285,7 @@
 					DRM_DEBUG("mtrr_del = %d\n", retcode);
 				}
 #endif
-				drm_ioremapfree(map->handle, map->size);
+				drm_ioremapfree(map->handle, map->size, dev);
 				break;
 			case _DRM_SHM:
 				drm_free_pages((unsigned long)map->handle,
diff -urN linux-davidm/drivers/char/drm-4.0/r128_cce.c lia64/drivers/char/drm-4.0/r128_cce.c
--- linux-davidm/drivers/char/drm-4.0/r128_cce.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/r128_cce.c	Mon Aug 20 18:09:34 2001
@@ -86,12 +86,13 @@
 };
 
 
-#define DO_REMAP(_m) (_m)->handle = drm_ioremap((_m)->offset, (_m)->size)
+#define DO_REMAP(_m, _d) (_m)->handle = drm_ioremap((_m)->offset,           \
+							 (_m)->size, (_d))
 
-#define DO_REMAPFREE(_m)                                                    \
+#define DO_REMAPFREE(_m, _d)                                                \
 	do {                                                                \
 		if ((_m)->handle && (_m)->size)                             \
-			drm_ioremapfree((_m)->handle, (_m)->size);          \
+			drm_ioremapfree((_m)->handle, (_m)->size, (_d));    \
 	} while (0)
 
 #define DO_FIND_MAP(_m, _o)                                                 \
@@ -519,12 +520,12 @@
 		(drm_r128_sarea_t *)((u8 *)dev_priv->sarea->handle +
 				     init->sarea_priv_offset);
 
-	DO_REMAP( dev_priv->cce_ring );
-	DO_REMAP( dev_priv->ring_rptr );
-	DO_REMAP( dev_priv->buffers );
+	DO_REMAP( dev_priv->cce_ring, dev );
+	DO_REMAP( dev_priv->ring_rptr, dev );
+	DO_REMAP( dev_priv->buffers, dev );
 #if 0
 	if ( !dev_priv->is_pci ) {
-		DO_REMAP( dev_priv->agp_textures );
+		DO_REMAP( dev_priv->agp_textures, dev );
 	}
 #endif
 
@@ -559,12 +560,12 @@
 	if ( dev->dev_private ) {
 		drm_r128_private_t *dev_priv = dev->dev_private;
 
-		DO_REMAPFREE( dev_priv->cce_ring );
-		DO_REMAPFREE( dev_priv->ring_rptr );
-		DO_REMAPFREE( dev_priv->buffers );
+		DO_REMAPFREE( dev_priv->cce_ring, dev );
+		DO_REMAPFREE( dev_priv->ring_rptr, dev );
+		DO_REMAPFREE( dev_priv->buffers, dev );
 #if 0
 		if ( !dev_priv->is_pci ) {
-			DO_REMAPFREE( dev_priv->agp_textures );
+			DO_REMAPFREE( dev_priv->agp_textures, dev );
 		}
 #endif
 
diff -urN linux-davidm/drivers/char/drm-4.0/r128_drv.c lia64/drivers/char/drm-4.0/r128_drv.c
--- linux-davidm/drivers/char/drm-4.0/r128_drv.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/r128_drv.c	Mon Aug 20 18:09:34 2001
@@ -295,7 +295,7 @@
 					DRM_DEBUG("mtrr_del = %d\n", retcode);
 				}
 #endif
-				drm_ioremapfree(map->handle, map->size);
+				drm_ioremapfree(map->handle, map->size, dev);
 				break;
 			case _DRM_SHM:
 				drm_free_pages((unsigned long)map->handle,
diff -urN linux-davidm/drivers/char/drm-4.0/radeon_cp.c lia64/drivers/char/drm-4.0/radeon_cp.c
--- linux-davidm/drivers/char/drm-4.0/radeon_cp.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/radeon_cp.c	Mon Aug 20 18:09:34 2001
@@ -300,12 +300,13 @@
 };
 
 
-#define DO_IOREMAP(_m) (_m)->handle = drm_ioremap((_m)->offset, (_m)->size)
+#define DO_IOREMAP(_m, _d) (_m)->handle = drm_ioremap((_m)->offset,	\
+						 	(_m)->size, (_d))
 
-#define DO_IOREMAPFREE(_m)						\
+#define DO_IOREMAPFREE(_m, _d)						\
 	do {								\
 		if ((_m)->handle && (_m)->size)				\
-			drm_ioremapfree((_m)->handle, (_m)->size);	\
+			drm_ioremapfree((_m)->handle, (_m)->size, (_d));\
 	} while (0)
 
 #define DO_FIND_MAP(_m, _o)						\
@@ -782,12 +783,12 @@
 		(drm_radeon_sarea_t *)((u8 *)dev_priv->sarea->handle +
 				       init->sarea_priv_offset);
 
-	DO_IOREMAP( dev_priv->cp_ring );
-	DO_IOREMAP( dev_priv->ring_rptr );
-	DO_IOREMAP( dev_priv->buffers );
+	DO_IOREMAP( dev_priv->cp_ring, dev );
+	DO_IOREMAP( dev_priv->ring_rptr, dev );
+	DO_IOREMAP( dev_priv->buffers, dev );
 #if 0
 	if ( !dev_priv->is_pci ) {
-		DO_IOREMAP( dev_priv->agp_textures );
+		DO_IOREMAP( dev_priv->agp_textures, dev );
 	}
 #endif
 
@@ -853,12 +854,12 @@
 	if ( dev->dev_private ) {
 		drm_radeon_private_t *dev_priv = dev->dev_private;
 
-		DO_IOREMAPFREE( dev_priv->cp_ring );
-		DO_IOREMAPFREE( dev_priv->ring_rptr );
-		DO_IOREMAPFREE( dev_priv->buffers );
+		DO_IOREMAPFREE( dev_priv->cp_ring, dev );
+		DO_IOREMAPFREE( dev_priv->ring_rptr, dev );
+		DO_IOREMAPFREE( dev_priv->buffers, dev );
 #if 0
 		if ( !dev_priv->is_pci ) {
-			DO_IOREMAPFREE( dev_priv->agp_textures );
+			DO_IOREMAPFREE( dev_priv->agp_textures, dev );
 		}
 #endif
 
diff -urN linux-davidm/drivers/char/drm-4.0/radeon_drv.c lia64/drivers/char/drm-4.0/radeon_drv.c
--- linux-davidm/drivers/char/drm-4.0/radeon_drv.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/radeon_drv.c	Mon Aug 20 18:09:34 2001
@@ -293,7 +293,7 @@
 					DRM_DEBUG("mtrr_del = %d\n", retcode);
 				}
 #endif
-				drm_ioremapfree(map->handle, map->size);
+				drm_ioremapfree(map->handle, map->size, dev);
 				break;
 			case _DRM_SHM:
 				drm_free_pages((unsigned long)map->handle,
diff -urN linux-davidm/drivers/char/drm-4.0/tdfx_drv.c lia64/drivers/char/drm-4.0/tdfx_drv.c
--- linux-davidm/drivers/char/drm-4.0/tdfx_drv.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/tdfx_drv.c	Mon Aug 20 18:09:34 2001
@@ -263,7 +263,7 @@
 					DRM_DEBUG("mtrr_del = %d\n", retcode);
 				}
 #endif
-				drm_ioremapfree(map->handle, map->size);
+				drm_ioremapfree(map->handle, map->size, dev);
 				break;
 			case _DRM_SHM:
 				drm_free_pages((unsigned long)map->handle,
diff -urN linux-davidm/drivers/char/drm-4.0/vm.c lia64/drivers/char/drm-4.0/vm.c
--- linux-davidm/drivers/char/drm-4.0/vm.c	Mon Aug 20 17:57:14 2001
+++ lia64/drivers/char/drm-4.0/vm.c	Mon Aug 20 18:09:34 2001
@@ -77,6 +77,9 @@
         /*
          * Find the right map
          */
+
+	if(!dev->agp->cant_use_aperture) goto vm_nopage_error;
+
 	for (i = 0; i < dev->map_count; i++) {
                 map = dev->maplist[i];
                 if (!map) continue;
@@ -98,12 +101,7 @@
                                 break;
                 }
 
-                if (!agpmem) {
-                        /*
-                         * Oops - no memory found
-                         */
-                        return NOPAGE_SIGBUS;   /* couldn't find it */
-                }
+                if (!agpmem) goto vm_nopage_error;
 
                 /*
                  * Get the page, inc the use count, and return it
@@ -120,8 +118,14 @@
 
                 page = virt_to_page(__va(paddr));
                 get_page(page);
-                return page;
+
+#if LINUX_VERSION_CODE < 0x020317
+		return page_address(page);
+#else
+		return page;
+#endif
         }
+vm_nopage_error:
 #endif
 	return NOPAGE_SIGBUS;		/* Disallow mremap */
 }
diff -urN linux-davidm/drivers/pci/pci.c lia64/drivers/pci/pci.c
--- linux-davidm/drivers/pci/pci.c	Mon Aug 20 18:59:04 2001
+++ lia64/drivers/pci/pci.c	Mon Aug 20 18:48:29 2001
@@ -1540,10 +1540,10 @@
 
 	switch (rqst) {
 	case PM_SAVE_STATE:
-		error = pci_pm_save_state((u32)data);
+		error = pci_pm_save_state((unsigned long)data);
 		break;
 	case PM_SUSPEND:
-		error = pci_pm_suspend((u32)data);
+		error = pci_pm_suspend((unsigned long)data);
 		break;
 	case PM_RESUME:
 		error = pci_pm_resume();
@@ -1860,9 +1860,9 @@
 	int			map, block;
 
 	if ((page = pool_find_page (pool, dma)) = 0) {
-		printk (KERN_ERR "pci_pool_free %s/%s, %p/%x (bad dma)\n",
+		printk (KERN_ERR "pci_pool_free %s/%s, %p/%lx (bad dma)\n",
 			pool->dev ? pool->dev->slot_name : NULL,
-			pool->name, vaddr, dma);
+			pool->name, vaddr, (unsigned long) dma);
 		return;
 	}
 #ifdef	CONFIG_PCIPOOL_DEBUG
diff -urN linux-davidm/drivers/scsi/qla1280.c lia64/drivers/scsi/qla1280.c
--- linux-davidm/drivers/scsi/qla1280.c	Mon Aug 20 17:57:15 2001
+++ lia64/drivers/scsi/qla1280.c	Mon Aug 20 18:49:25 2001
@@ -598,9 +598,9 @@
 
     size = sprintf(PROC_BUF, "SCSI Host Adapter Information: %s\n", bdp->bdName);
     len += size;
-    size = sprintf(PROC_BUF, "Request Queue = 0x%x, Response Queue = 0x%x\n",
-                        ha->request_dma,
-                        ha->response_dma);
+    size = sprintf(PROC_BUF, "Request Queue = 0x%lx, Response Queue = 0x%lx\n",
+                        (unsigned long) ha->request_dma,
+                        (unsigned long) ha->response_dma);
     len += size;
     size = sprintf(PROC_BUF, "Request Queue count= 0x%x, Response Queue count= 0x%x\n",
                         REQUEST_ENTRY_CNT,
diff -urN linux-davidm/drivers/sound/cs4281/cs4281pm-24.c lia64/drivers/sound/cs4281/cs4281pm-24.c
--- linux-davidm/drivers/sound/cs4281/cs4281pm-24.c	Mon Aug 20 17:57:15 2001
+++ lia64/drivers/sound/cs4281/cs4281pm-24.c	Mon Aug 20 18:49:47 2001
@@ -38,8 +38,8 @@
 #define CS4281_SUSPEND_TBL cs4281_suspend_tbl
 #define CS4281_RESUME_TBL cs4281_resume_tbl
 */
-#define CS4281_SUSPEND_TBL cs4281_null
-#define CS4281_RESUME_TBL cs4281_null
+#define CS4281_SUSPEND_TBL	(int (*) (struct pci_dev *, u32)) cs4281_null
+#define CS4281_RESUME_TBL	(int (*) (struct pci_dev *)) cs4281_null
 
 int cs4281_pm_callback(struct pm_dev *dev, pm_request_t rqst, void *data)
 {
@@ -78,7 +78,7 @@
 }
 
 #else /* CS4281_PM */
-#define CS4281_SUSPEND_TBL cs4281_null
-#define CS4281_RESUME_TBL cs4281_null
+#define CS4281_SUSPEND_TBL	(int (*) (struct pci_dev *, u32)) cs4281_null
+#define CS4281_RESUME_TBL 	(int (*) (struct pci_dev *)) cs4281_null
 #endif /* CS4281_PM */
 
diff -urN linux-davidm/drivers/usb/usb-ohci.c lia64/drivers/usb/usb-ohci.c
--- linux-davidm/drivers/usb/usb-ohci.c	Mon Aug 20 18:59:08 2001
+++ lia64/drivers/usb/usb-ohci.c	Mon Aug 20 18:50:00 2001
@@ -2326,21 +2326,22 @@
 {
 	ohci_t * ohci;
 	struct usb_bus * bus;
+	dma_addr_t bus_addr;
 
 	ohci = (ohci_t *) kmalloc (sizeof *ohci, GFP_KERNEL);
 	if (!ohci)
 		return NULL;
-		
+
 	memset (ohci, 0, sizeof (ohci_t));
 
-	ohci->hcca = pci_alloc_consistent (dev, sizeof *ohci->hcca,
-			&ohci->hcca_dma);
+	ohci->hcca = pci_alloc_consistent (dev, sizeof *ohci->hcca, &bus_addr);
         if (!ohci->hcca) {
                 kfree (ohci);
                 return NULL;
         }
         memset (ohci->hcca, 0, sizeof (struct ohci_hcca));
 
+	ohci->hcca_dma = bus_addr;
 	ohci->disabled = 1;
 	ohci->sleeping = 0;
 	ohci->irq = -1;
diff -urN linux-davidm/include/asm-ia64/io.h lia64/include/asm-ia64/io.h
--- linux-davidm/include/asm-ia64/io.h	Tue Jul 31 10:30:09 2001
+++ lia64/include/asm-ia64/io.h	Mon Aug 20 18:50:11 2001
@@ -43,7 +43,7 @@
 }
 
 static inline void*
-phys_to_virt(unsigned long address)
+phys_to_virt (unsigned long address)
 {
 	return (void *) (address + PAGE_OFFSET);
 }
@@ -54,6 +54,7 @@
  */
 #define bus_to_virt	phys_to_virt
 #define virt_to_bus	virt_to_phys
+#define page_to_bus	page_to_phys
 
 # endif /* KERNEL */
 
diff -urN linux-davidm/include/asm-ia64/page.h lia64/include/asm-ia64/page.h
--- linux-davidm/include/asm-ia64/page.h	Thu Apr  5 12:51:47 2001
+++ lia64/include/asm-ia64/page.h	Mon Aug 20 18:50:53 2001
@@ -55,12 +55,15 @@
 #ifdef CONFIG_IA64_GENERIC
 # include <asm/machvec.h>
 # define virt_to_page(kaddr)	(mem_map + platform_map_nr(kaddr))
+# define page_to_phys(page)	XXX fix me
 #elif defined (CONFIG_IA64_SGI_SN1)
 # ifndef CONFIG_DISCONTIGMEM
 #  define virt_to_page(kaddr)	(mem_map + MAP_NR_DENSE(kaddr))
+#  define page_to_phys(page)	XXX fix me
 # endif
 #else
 # define virt_to_page(kaddr)	(mem_map + MAP_NR_DENSE(kaddr))
+# define page_to_phys(page)	((page - mem_map) << PAGE_SHIFT)
 #endif
 #define VALID_PAGE(page)	((page - mem_map) < max_mapnr)
 
diff -urN linux-davidm/include/asm-ia64/sigcontext.h lia64/include/asm-ia64/sigcontext.h
--- linux-davidm/include/asm-ia64/sigcontext.h	Tue Jul 31 10:30:09 2001
+++ lia64/include/asm-ia64/sigcontext.h	Mon Aug 20 18:51:01 2001
@@ -2,13 +2,13 @@
 #define _ASM_IA64_SIGCONTEXT_H
 
 /*
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998, 1999, 2001 Hewlett-Packard Co
+ * Copyright (C) 1998, 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
 #include <asm/fpu.h>
 
-#define IA64_SC_FLAG_ONSTACK_BIT		1	/* is handler running on signal stack? */
+#define IA64_SC_FLAG_ONSTACK_BIT		0	/* is handler running on signal stack? */
 #define IA64_SC_FLAG_IN_SYSCALL_BIT		1	/* did signal interrupt a syscall? */
 #define IA64_SC_FLAG_FPH_VALID_BIT		2	/* is state in f[32]-f[127] valid? */
 
diff -urN linux-davidm/include/asm-ia64/user.h lia64/include/asm-ia64/user.h
--- linux-davidm/include/asm-ia64/user.h	Sun Feb  6 18:42:40 2000
+++ lia64/include/asm-ia64/user.h	Mon Aug 20 18:51:10 2001
@@ -24,11 +24,12 @@
  *	current->start_stack, so we round each of these in order to be able
  *	to write an integer number of pages.
  *
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998, 1999, 2001 Hewlett-Packard Co
+ * Copyright (C) 1998, 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
 #include <linux/ptrace.h>
+#include <linux/types.h>
 
 #include <asm/page.h>
 
diff -urN linux-davidm/include/linux/agp_backend.h lia64/include/linux/agp_backend.h
--- linux-davidm/include/linux/agp_backend.h	Mon Aug 20 17:57:15 2001
+++ lia64/include/linux/agp_backend.h	Mon Aug 20 17:31:11 2001
@@ -88,6 +88,8 @@
 	size_t aper_size;
 	int max_memory;		/* In pages */
 	int current_memory;
+	int cant_use_aperture;
+	unsigned long page_mask;
 } agp_kern_info;
 
 /* 
@@ -110,6 +112,7 @@
 	size_t page_count;
 	int num_scratch_pages;
 	unsigned long *memory;
+	void *vmptr;
 	off_t pg_start;
 	u32 type;
 	u32 physical;
@@ -240,33 +243,6 @@
  * 
  */
 
-#ifdef CONFIG_AGP_PTE_FIXUPS
-extern void *agp_ioremap(unsigned long offset, unsigned long size);
-
-/*
- * agp_ioremap:
- *
- * This function performs a standard ioremap unless offset is
- * in the AGP aperture.  In this case, a pointer to a portion of
- * the vmalloc area is returned.  This remapped chunk of the
- * vmalloc area is added to the fixup list and consequently kept
- * in agreement with GART state.  Make this call to ensure that
- * ioremaps in the AGP aperture function correctly on chipsets
- * needing PTE fixups.
- */
-
-extern void agp_iounmap(void *handle);
-
-/*
- * agp_iounmap:
- *
- * Perform a standard iounmap unless handle is in the vmalloc area.
- * In this case, free this portion of vmalloc and remove this map
- * from the fixup list.
- */
-
-#endif
-
 typedef struct {
 	void       (*free_memory)(agp_memory *);
 	agp_memory *(*allocate_memory)(size_t, u32);
@@ -276,10 +252,6 @@
 	int        (*acquire)(void);
 	void       (*release)(void);
 	void       (*copy_info)(agp_kern_info *);
-#ifdef CONFIG_AGP_PTE_FIXUPS
-	void 	   *(*ioremap)(unsigned long, unsigned long);
-	void 	   (*iounmap)(void *);
-#endif
 } drm_agp_t;
 
 extern const drm_agp_t *drm_agp_p;

