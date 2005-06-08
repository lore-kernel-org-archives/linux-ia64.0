From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 08 Jun 2005 20:26:22 +0000
Subject: [PATCH 2.6.12-rc6-mm1] ia64: make pci_mmap_legacy_page_range() a machine vector
Message-Id: <200506081426.22493.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Make pci_mmap_legacy_page_range() a machine vector, so platforms
have more flexibility in accessing ISA MMIO resources.

pci_mmap_legacy_page_range() implements mmap for ISA MMIO resources
on specific PCI buses.  For example, you can mmap offset 0xA0000
of /sys/class/pci_bus/0000:00/legacy_mem to access the frame buffer
of a VGA device on bus 0000:00.

The ia64 implementation previously assumed these MMIO regions were
all simultaneously accessible, just at different host addresses, so
there was a machine vector (platform_pci_get_legacy_mem()) to return
the host address.  But for HP chipsets, the VGA MMIO resources (bus
addresses 0xA0000-0xC0000) can be accessed on only one host bridge at
a time, so we need a special pci_mmap_legacy_page_range() implementation.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

--- a/arch/ia64/pci/pci.c.orig	2005-06-08 13:19:35.000000000 -0600
+++ b/arch/ia64/pci/pci.c	2005-06-08 13:27:43.000000000 -0600
@@ -19,12 +19,9 @@
 #include <linux/init.h>
 #include <linux/ioport.h>
 #include <linux/slab.h>
-#include <linux/smp_lock.h>
-#include <linux/spinlock.h>
 
 #include <asm/machvec.h>
 #include <asm/page.h>
-#include <asm/segment.h>
 #include <asm/system.h>
 #include <asm/io.h>
 #include <asm/sal.h>
@@ -570,46 +567,30 @@
 }
 
 /**
- * ia64_pci_get_legacy_mem - generic legacy mem routine
- * @bus: bus to get legacy memory base address for
- *
- * Find the base of legacy memory for @bus.  This is typically the first
- * megabyte of bus address space for @bus or is simply 0 on platforms whose
- * chipsets support legacy I/O and memory routing.  Returns the base address
- * or an error pointer if an error occurred.
- *
- * This is the ia64 generic version of this routine.  Other platforms
- * are free to override it with a machine vector.
- */
-char *ia64_pci_get_legacy_mem(struct pci_bus *bus)
-{
-	return (char *)__IA64_UNCACHED_OFFSET;
-}
-
-/**
- * pci_mmap_legacy_page_range - map legacy memory space to userland
+ * ia64_pci_mmap_legacy_page_range - map legacy memory space to userland
  * @bus: bus whose legacy space we're mapping
  * @vma: vma passed in by mmap
  *
- * Map legacy memory space for this device back to userspace using a machine
- * vector to get the base address.
+ * Map legacy memory space for this device back to userspace.  This is a
+ * generic version that may be overridden by the platform.
  */
 int
-pci_mmap_legacy_page_range(struct pci_bus *bus, struct vm_area_struct *vma)
+ia64_pci_mmap_legacy_page_range (struct pci_bus *bus,
+				 struct vm_area_struct *vma)
 {
-	char *addr;
+	unsigned long size = vma->vm_end - vma->vm_start;
+	int err;
 
-	addr = pci_get_legacy_mem(bus);
-	if (IS_ERR(addr))
-		return PTR_ERR(addr);
+	if ((vma->vm_pgoff << PAGE_SHIFT) + size > 1024*1024)
+		return -EINVAL;
 
-	vma->vm_pgoff += (unsigned long)addr >> PAGE_SHIFT;
 	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 	vma->vm_flags |= (VM_SHM | VM_RESERVED | VM_IO);
 
-	if (remap_pfn_range(vma, vma->vm_start, vma->vm_pgoff,
-			    vma->vm_end - vma->vm_start, vma->vm_page_prot))
-		return -EAGAIN;
+	err = io_remap_pfn_range(vma, vma->vm_start, vma->vm_pgoff,
+			         size, vma->vm_page_prot);
+	if (err)
+		return err;
 
 	return 0;
 }
@@ -627,7 +608,8 @@
  * overridden by the platform.  This is necessary on platforms that don't
  * support legacy I/O routing or that hard fail on legacy I/O timeouts.
  */
-int ia64_pci_legacy_read(struct pci_bus *bus, u16 port, u32 *val, u8 size)
+int
+ia64_pci_legacy_read (struct pci_bus *bus, u16 port, u32 *val, u8 size)
 {
 	int ret = size;
 
@@ -658,7 +640,8 @@
  *
  * Simply writes @size bytes of @val to @port.
  */
-int ia64_pci_legacy_write(struct pci_dev *bus, u16 port, u32 val, u8 size)
+int
+ia64_pci_legacy_write (struct pci_dev *bus, u16 port, u32 val, u8 size)
 {
 	int ret = 0;
 
--- a/arch/ia64/sn/pci/pci_dma.c.orig	2005-06-08 13:19:20.000000000 -0600
+++ b/arch/ia64/sn/pci/pci_dma.c	2005-06-08 13:27:43.000000000 -0600
@@ -303,12 +303,28 @@
 }
 EXPORT_SYMBOL(sn_dma_mapping_error);
 
-char *sn_pci_get_legacy_mem(struct pci_bus *bus)
+int sn_pci_mmap_legacy_page_range(struct pci_bus *bus,
+				  struct vm_area_struct *vma)
 {
+	unsigned long size = vma->vm_end - vma->vm_start;
+	int err;
+
 	if (!SN_PCIBUS_BUSSOFT(bus))
-		return ERR_PTR(-ENODEV);
+		return -ENODEV;
+
+	if ((vma->vm_pgoff << PAGE_SHIFT) + size > 1024*1024)
+		return -EINVAL;
+
+	vma->vm_pgoff += SN_PCIBUS_BUSSOFT(bus)->bs_legacy_mem >> PAGE_SHIFT;
+	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+	vma->vm_flags |= (VM_SHM | VM_RESERVED | VM_IO);
+
+	err = io_remap_pfn_range(vma, vma->vm_start, vma->vm_pgoff,
+			         size, vma->vm_page_prot);
+	if (err)
+		return err;
 
-	return (char *)(SN_PCIBUS_BUSSOFT(bus)->bs_legacy_mem | __IA64_UNCACHED_OFFSET);
+	return 0;
 }
 
 int sn_pci_legacy_read(struct pci_bus *bus, u16 port, u32 *val, u8 size)
--- a/include/asm-ia64/machvec.h.orig	2005-04-07 12:57:42.000000000 -0600
+++ b/include/asm-ia64/machvec.h	2005-06-08 13:27:43.000000000 -0600
@@ -20,6 +20,7 @@
 struct page;
 struct mm_struct;
 struct pci_bus;
+struct vm_area_struct;
 
 typedef void ia64_mv_setup_t (char **);
 typedef void ia64_mv_cpu_init_t (void);
@@ -29,7 +30,8 @@
 typedef void ia64_mv_global_tlb_purge_t (unsigned long, unsigned long, unsigned long);
 typedef void ia64_mv_tlb_migrate_finish_t (struct mm_struct *);
 typedef unsigned int ia64_mv_local_vector_to_irq (u8);
-typedef char *ia64_mv_pci_get_legacy_mem_t (struct pci_bus *);
+typedef int ia64_mv_pci_mmap_legacy_page_range_t (struct pci_bus *,
+						  struct vm_area_struct *);
 typedef int ia64_mv_pci_legacy_read_t (struct pci_bus *, u16 port, u32 *val,
 				       u8 size);
 typedef int ia64_mv_pci_legacy_write_t (struct pci_bus *, u16 port, u32 val,
@@ -128,7 +130,7 @@
 #  define platform_dma_mapping_error		ia64_mv.dma_mapping_error
 #  define platform_dma_supported	ia64_mv.dma_supported
 #  define platform_local_vector_to_irq	ia64_mv.local_vector_to_irq
-#  define platform_pci_get_legacy_mem	ia64_mv.pci_get_legacy_mem
+#  define platform_pci_mmap_legacy_page_range	ia64_mv.pci_mmap_legacy_page_range
 #  define platform_pci_legacy_read	ia64_mv.pci_legacy_read
 #  define platform_pci_legacy_write	ia64_mv.pci_legacy_write
 #  define platform_inb		ia64_mv.inb
@@ -176,7 +178,7 @@
 	ia64_mv_dma_mapping_error *dma_mapping_error;
 	ia64_mv_dma_supported *dma_supported;
 	ia64_mv_local_vector_to_irq *local_vector_to_irq;
-	ia64_mv_pci_get_legacy_mem_t *pci_get_legacy_mem;
+	ia64_mv_pci_mmap_legacy_page_range_t *pci_mmap_legacy_page_range;
 	ia64_mv_pci_legacy_read_t *pci_legacy_read;
 	ia64_mv_pci_legacy_write_t *pci_legacy_write;
 	ia64_mv_inb_t *inb;
@@ -217,10 +219,10 @@
 	platform_dma_sync_sg_for_cpu,		\
 	platform_dma_sync_single_for_device,	\
 	platform_dma_sync_sg_for_device,	\
-	platform_dma_mapping_error,			\
+	platform_dma_mapping_error,		\
 	platform_dma_supported,			\
 	platform_local_vector_to_irq,		\
-	platform_pci_get_legacy_mem,		\
+	platform_pci_mmap_legacy_page_range,	\
 	platform_pci_legacy_read,		\
 	platform_pci_legacy_write,		\
 	platform_inb,				\
@@ -332,8 +334,8 @@
 #ifndef platform_local_vector_to_irq
 # define platform_local_vector_to_irq	__ia64_local_vector_to_irq
 #endif
-#ifndef platform_pci_get_legacy_mem
-# define platform_pci_get_legacy_mem	ia64_pci_get_legacy_mem
+#ifndef platform_pci_mmap_legacy_page_range
+# define platform_pci_mmap_legacy_page_range	ia64_pci_mmap_legacy_page_range
 #endif
 #ifndef platform_pci_legacy_read
 # define platform_pci_legacy_read	ia64_pci_legacy_read
--- a/include/asm-ia64/machvec_init.h.orig	2005-04-07 12:58:44.000000000 -0600
+++ b/include/asm-ia64/machvec_init.h	2005-06-08 13:27:43.000000000 -0600
@@ -3,7 +3,7 @@
 extern ia64_mv_send_ipi_t ia64_send_ipi;
 extern ia64_mv_global_tlb_purge_t ia64_global_tlb_purge;
 extern ia64_mv_local_vector_to_irq __ia64_local_vector_to_irq;
-extern ia64_mv_pci_get_legacy_mem_t ia64_pci_get_legacy_mem;
+extern ia64_mv_pci_mmap_legacy_page_range_t ia64_pci_mmap_legacy_page_range;
 extern ia64_mv_pci_legacy_read_t ia64_pci_legacy_read;
 extern ia64_mv_pci_legacy_write_t ia64_pci_legacy_write;
 
--- a/include/asm-ia64/machvec_sn2.h.orig	2005-04-07 12:57:31.000000000 -0600
+++ b/include/asm-ia64/machvec_sn2.h	2005-06-08 13:27:43.000000000 -0600
@@ -41,7 +41,7 @@
 extern ia64_mv_global_tlb_purge_t sn2_global_tlb_purge;
 extern ia64_mv_tlb_migrate_finish_t	sn_tlb_migrate_finish;
 extern ia64_mv_local_vector_to_irq sn_local_vector_to_irq;
-extern ia64_mv_pci_get_legacy_mem_t sn_pci_get_legacy_mem;
+extern ia64_mv_pci_mmap_legacy_page_range_t sn_pci_mmap_legacy_page_range;
 extern ia64_mv_pci_legacy_read_t sn_pci_legacy_read;
 extern ia64_mv_pci_legacy_write_t sn_pci_legacy_write;
 extern ia64_mv_inb_t __sn_inb;
@@ -104,7 +104,7 @@
 #define platform_readl_relaxed		__sn_readl_relaxed
 #define platform_readq_relaxed		__sn_readq_relaxed
 #define platform_local_vector_to_irq	sn_local_vector_to_irq
-#define platform_pci_get_legacy_mem	sn_pci_get_legacy_mem
+#define platform_pci_mmap_legacy_page_range	sn_pci_mmap_legacy_page_range
 #define platform_pci_legacy_read	sn_pci_legacy_read
 #define platform_pci_legacy_write	sn_pci_legacy_write
 #define platform_dma_init		machvec_noop
--- a/include/asm-ia64/pci.h.orig	2005-06-08 13:19:45.000000000 -0600
+++ b/include/asm-ia64/pci.h	2005-06-08 13:27:43.000000000 -0600
@@ -105,8 +105,6 @@
 extern int pci_mmap_page_range (struct pci_dev *dev, struct vm_area_struct *vma,
 				enum pci_mmap_state mmap_state, int write_combine);
 #define HAVE_PCI_LEGACY
-extern int pci_mmap_legacy_page_range(struct pci_bus *bus,
-				      struct vm_area_struct *vma);
 extern ssize_t pci_read_legacy_io(struct kobject *kobj, char *buf, loff_t off,
 				  size_t count);
 extern ssize_t pci_write_legacy_io(struct kobject *kobj, char *buf, loff_t off,
@@ -115,7 +113,7 @@
 			       struct bin_attribute *attr,
 			       struct vm_area_struct *vma);
 
-#define pci_get_legacy_mem platform_pci_get_legacy_mem
+#define pci_mmap_legacy_page_range platform_pci_mmap_legacy_page_range
 #define pci_legacy_read platform_pci_legacy_read
 #define pci_legacy_write platform_pci_legacy_write
 
