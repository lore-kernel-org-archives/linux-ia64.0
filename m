From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 23 Dec 2004 15:57:42 +0000
Subject: [PATCH] implement HAVE_PCI_LEGACY for ia64
Message-Id: <200412230757.42313.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_2ruyB16lvrvgaZN"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_2ruyB16lvrvgaZN
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch implements the features required for the HAVE_PCI_LEGACY code in 
sysfs.  It allows userspace applications to access legacy I/O ports an memory 
space using files in sysfs on a per-bus basis.  Tested on sn2, but it 
*should* work on other ia64 platforms as well (though zx1 will probably need 
machine vectors to do routing of non-base busses).

 arch/ia64/pci/pci.c             |  114 +++++++++++++++++++++++++++++++++++++-
 arch/ia64/sn/pci/pci_dma.c      |   64 ++++++++++++++++++++++
 include/asm-ia64/machvec.h      |   24 ++++++++
 include/asm-ia64/machvec_init.h |    3 +
 include/asm-ia64/machvec_sn2.h  |    6 ++
 include/asm-ia64/pci.h          |   14 ++++
 include/asm-ia64/sn/sn_sal.h    |   46 ++++++++++++++++
 7 files changed, 270 insertions(+), 1 deletion(-)

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_2ruyB16lvrvgaZN
Content-Type: text/plain;
  charset="us-ascii";
  name="sysfs-legacy-resource-ia64-3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sysfs-legacy-resource-ia64-3.patch"

===== arch/ia64/pci/pci.c 1.59 vs edited =====
--- 1.59/arch/ia64/pci/pci.c	2004-11-05 11:55:25 -08:00
+++ edited/arch/ia64/pci/pci.c	2004-12-23 07:51:19 -08:00
@@ -6,6 +6,7 @@
  * Copyright (C) 2002 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *	Bjorn Helgaas <bjorn_helgaas@hp.com>
+ * Copyright (C) 2004 Silicon Graphics, Inc.
  *
  * Note: Above list of copyright holders is incomplete...
  */
@@ -518,7 +519,7 @@
 	 * Leave vm_pgoff as-is, the PCI space address is the physical
 	 * address on this platform.
 	 */
-	vma->vm_flags |= (VM_SHM | VM_LOCKED | VM_IO);
+	vma->vm_flags |= (VM_SHM | VM_RESERVED | VM_IO);
 
 	if (write_combine)
 		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
@@ -530,6 +531,117 @@
 		return -EAGAIN;
 
 	return 0;
+}
+
+/**
+ * pci_mmap_legacy_page_range - map legacy memory space to userland
+ * @bus: bus whose legacy space we're mapping
+ * @vma: vma passed in by mmap
+ *
+ * Map legacy memory space for this device back to userspace using a machine
+ * vector to get the base address.
+ */
+int
+pci_mmap_legacy_page_range(struct pci_bus *bus, struct vm_area_struct *vma)
+{
+	char *addr;
+
+	addr = pci_get_legacy_mem(bus);
+	if (IS_ERR(addr))
+		return PTR_ERR(addr);
+
+	vma->vm_pgoff += (unsigned long)addr >> PAGE_SHIFT;
+	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+	vma->vm_flags |= (VM_SHM | VM_RESERVED | VM_IO);
+
+	if (remap_pfn_range(vma, vma->vm_start, vma->vm_pgoff,
+			    vma->vm_end - vma->vm_start, vma->vm_page_prot))
+		return -EAGAIN;
+
+	return 0;
+}
+
+/**
+ * ia64_pci_get_legacy_mem - generic legacy mem routine
+ * @bus: bus to get legacy memory base address for
+ *
+ * Find the base of legacy memory for @bus.  This is typically the first
+ * megabyte of bus address space for @bus or is simply 0 on platforms whose
+ * chipsets support legacy I/O and memory routing.  Returns the base address
+ * or an error pointer if an error occurred.
+ *
+ * This is the ia64 generic version of this routine.  Other platforms
+ * are free to override it with a machine vector.
+ */
+char *ia64_pci_get_legacy_mem(struct pci_bus *bus)
+{
+	return (char *)__IA64_UNCACHED_OFFSET;
+}
+
+/**
+ * ia64_pci_legacy_read - read from legacy I/O space
+ * @bus: bus to read
+ * @port: legacy port value
+ * @val: caller allocated storage for returned value
+ * @size: number of bytes to read
+ *
+ * Simply reads @size bytes from @port and puts the result in @val.
+ *
+ * Again, this (and the write routine) are generic versions that can be
+ * overridden by the platform.  This is necessary on platforms that don't
+ * support legacy I/O routing or that hard fail on legacy I/O timeouts.
+ */
+int ia64_pci_legacy_read(struct pci_bus *bus, u16 port, u32 *val, u8 size)
+{
+	int ret = size;
+
+	switch (size) {
+	case 1:
+		*val = inb(port);
+		break;
+	case 2:
+		*val = inw(port);
+		break;
+	case 4:
+		*val = inl(port);
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
+/**
+ * ia64_pci_legacy_write - perform a legacy I/O write
+ * @bus: bus pointer
+ * @port: port to write
+ * @val: value to write
+ * @size: number of bytes to write from @val
+ *
+ * Simply writes @size bytes of @val to @port.
+ */
+int ia64_pci_legacy_write(struct pci_dev *bus, u16 port, u32 val, u8 size)
+{
+	int ret = 0;
+
+	switch (size) {
+	case 1:
+		outb(val, port);
+		break;
+	case 2:
+		outw(val, port);
+		break;
+	case 4:
+		outl(val, port);
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
 }
 
 /**
===== arch/ia64/sn/pci/pci_dma.c 1.2 vs edited =====
--- 1.2/arch/ia64/sn/pci/pci_dma.c	2004-10-20 12:00:10 -07:00
+++ edited/arch/ia64/sn/pci/pci_dma.c	2004-12-23 07:51:19 -08:00
@@ -475,3 +475,67 @@
 EXPORT_SYMBOL(sn_pci_free_consistent);
 EXPORT_SYMBOL(sn_pci_dma_supported);
 EXPORT_SYMBOL(sn_dma_mapping_error);
+
+char *sn_pci_get_legacy_mem(struct pci_bus *bus)
+{
+	if (!SN_PCIBUS_BUSSOFT(bus))
+		return ERR_PTR(-ENODEV);
+
+	return (char *)(SN_PCIBUS_BUSSOFT(bus)->bs_legacy_mem | __IA64_UNCACHED_OFFSET);
+}
+
+int sn_pci_legacy_read(struct pci_bus *bus, u16 port, u32 *val, u8 size)
+{
+	unsigned long addr;
+	int ret;
+
+	if (!SN_PCIBUS_BUSSOFT(bus))
+		return -ENODEV;
+
+	addr = SN_PCIBUS_BUSSOFT(bus)->bs_legacy_io | __IA64_UNCACHED_OFFSET;
+	addr += port;
+
+	ret = ia64_sn_probe_mem(addr, (long)size, (void *)val);
+
+	if (ret == 2)
+		return -EINVAL;
+
+	if (ret == 1)
+		*val = -1;
+
+	return size;
+}
+
+int sn_pci_legacy_write(struct pci_bus *bus, u16 port, u32 val, u8 size)
+{
+	int ret = size;
+	unsigned long paddr;
+	unsigned long *addr;
+
+	if (!SN_PCIBUS_BUSSOFT(bus)) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	/* Put the phys addr in uncached space */
+	paddr = SN_PCIBUS_BUSSOFT(bus)->bs_legacy_io | __IA64_UNCACHED_OFFSET;
+	paddr += port;
+	addr = (unsigned long *)paddr;
+
+	switch (size) {
+	case 1:
+		*(volatile u8 *)(addr) = (u8)(val);
+		break;
+	case 2:
+		*(volatile u16 *)(addr) = (u16)(val);
+		break;
+	case 4:
+		*(volatile u32 *)(addr) = (u32)(val);
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+ out:
+	return ret;
+}
===== include/asm-ia64/machvec.h 1.29 vs edited =====
--- 1.29/include/asm-ia64/machvec.h	2004-10-25 13:06:49 -07:00
+++ edited/include/asm-ia64/machvec.h	2004-12-23 07:51:20 -08:00
@@ -20,6 +20,7 @@
 struct irq_desc;
 struct page;
 struct mm_struct;
+struct pci_bus;
 
 typedef void ia64_mv_setup_t (char **);
 typedef void ia64_mv_cpu_init_t (void);
@@ -31,6 +32,11 @@
 typedef struct irq_desc *ia64_mv_irq_desc (unsigned int);
 typedef u8 ia64_mv_irq_to_vector (unsigned int);
 typedef unsigned int ia64_mv_local_vector_to_irq (u8);
+typedef char *ia64_mv_pci_get_legacy_mem_t (struct pci_bus *);
+typedef int ia64_mv_pci_legacy_read_t (struct pci_bus *, u16 port, u32 *val,
+				       u8 size);
+typedef int ia64_mv_pci_legacy_write_t (struct pci_bus *, u16 port, u32 val,
+					u8 size);
 
 /* DMA-mapping interface: */
 typedef void ia64_mv_dma_init (void);
@@ -125,6 +131,9 @@
 #  define platform_irq_desc		ia64_mv.irq_desc
 #  define platform_irq_to_vector	ia64_mv.irq_to_vector
 #  define platform_local_vector_to_irq	ia64_mv.local_vector_to_irq
+#  define platform_pci_get_legacy_mem	ia64_mv.pci_get_legacy_mem
+#  define platform_pci_legacy_read	ia64_mv.pci_legacy_read
+#  define platform_pci_legacy_write	ia64_mv.pci_legacy_write
 #  define platform_inb		ia64_mv.inb
 #  define platform_inw		ia64_mv.inw
 #  define platform_inl		ia64_mv.inl
@@ -172,6 +181,9 @@
 	ia64_mv_irq_desc *irq_desc;
 	ia64_mv_irq_to_vector *irq_to_vector;
 	ia64_mv_local_vector_to_irq *local_vector_to_irq;
+	ia64_mv_pci_get_legacy_mem_t *pci_get_legacy_mem;
+	ia64_mv_pci_legacy_read_t *pci_legacy_read;
+	ia64_mv_pci_legacy_write_t *pci_legacy_write;
 	ia64_mv_inb_t *inb;
 	ia64_mv_inw_t *inw;
 	ia64_mv_inl_t *inl;
@@ -215,6 +227,9 @@
 	platform_irq_desc,			\
 	platform_irq_to_vector,			\
 	platform_local_vector_to_irq,		\
+	platform_pci_get_legacy_mem,		\
+	platform_pci_legacy_read,		\
+	platform_pci_legacy_write,		\
 	platform_inb,				\
 	platform_inw,				\
 	platform_inl,				\
@@ -329,6 +344,15 @@
 #endif
 #ifndef platform_local_vector_to_irq
 # define platform_local_vector_to_irq	__ia64_local_vector_to_irq
+#endif
+#ifndef platform_pci_get_legacy_mem
+# define platform_pci_get_legacy_mem	ia64_pci_get_legacy_mem
+#endif
+#ifndef platform_pci_legacy_read
+# define platform_pci_legacy_read	ia64_pci_legacy_read
+#endif
+#ifndef platform_pci_legacy_write
+# define platform_pci_legacy_write	ia64_pci_legacy_write
 #endif
 #ifndef platform_inb
 # define platform_inb		__ia64_inb
===== include/asm-ia64/machvec_init.h 1.8 vs edited =====
--- 1.8/include/asm-ia64/machvec_init.h	2004-10-25 13:06:49 -07:00
+++ edited/include/asm-ia64/machvec_init.h	2004-12-23 07:51:20 -08:00
@@ -5,6 +5,9 @@
 extern ia64_mv_irq_desc __ia64_irq_desc;
 extern ia64_mv_irq_to_vector __ia64_irq_to_vector;
 extern ia64_mv_local_vector_to_irq __ia64_local_vector_to_irq;
+extern ia64_mv_pci_get_legacy_mem_t ia64_pci_get_legacy_mem;
+extern ia64_mv_pci_legacy_read_t ia64_pci_legacy_read;
+extern ia64_mv_pci_legacy_write_t ia64_pci_legacy_write;
 
 extern ia64_mv_inb_t __ia64_inb;
 extern ia64_mv_inw_t __ia64_inw;
===== include/asm-ia64/machvec_sn2.h 1.16 vs edited =====
--- 1.16/include/asm-ia64/machvec_sn2.h	2004-10-25 13:06:49 -07:00
+++ edited/include/asm-ia64/machvec_sn2.h	2004-12-23 07:51:20 -08:00
@@ -43,6 +43,9 @@
 extern ia64_mv_irq_desc sn_irq_desc;
 extern ia64_mv_irq_to_vector sn_irq_to_vector;
 extern ia64_mv_local_vector_to_irq sn_local_vector_to_irq;
+extern ia64_mv_pci_get_legacy_mem_t sn_pci_get_legacy_mem;
+extern ia64_mv_pci_legacy_read_t sn_pci_legacy_read;
+extern ia64_mv_pci_legacy_write_t sn_pci_legacy_write;
 extern ia64_mv_inb_t __sn_inb;
 extern ia64_mv_inw_t __sn_inw;
 extern ia64_mv_inl_t __sn_inl;
@@ -105,6 +108,9 @@
 #define platform_irq_desc		sn_irq_desc
 #define platform_irq_to_vector		sn_irq_to_vector
 #define platform_local_vector_to_irq	sn_local_vector_to_irq
+#define platform_pci_get_legacy_mem	sn_pci_get_legacy_mem
+#define platform_pci_legacy_read	sn_pci_legacy_read
+#define platform_pci_legacy_write	sn_pci_legacy_write
 #define platform_dma_init		machvec_noop
 #define platform_dma_alloc_coherent	sn_dma_alloc_coherent
 #define platform_dma_free_coherent	sn_dma_free_coherent
===== include/asm-ia64/pci.h 1.27 vs edited =====
--- 1.27/include/asm-ia64/pci.h	2004-11-03 13:36:55 -08:00
+++ edited/include/asm-ia64/pci.h	2004-12-23 07:51:21 -08:00
@@ -85,6 +85,20 @@
 #define HAVE_PCI_MMAP
 extern int pci_mmap_page_range (struct pci_dev *dev, struct vm_area_struct *vma,
 				enum pci_mmap_state mmap_state, int write_combine);
+#define HAVE_PCI_LEGACY
+extern int pci_mmap_legacy_page_range(struct pci_bus *bus,
+				      struct vm_area_struct *vma);
+extern ssize_t pci_read_legacy_io(struct kobject *kobj, char *buf, loff_t off,
+				  size_t count);
+extern ssize_t pci_write_legacy_io(struct kobject *kobj, char *buf, loff_t off,
+				   size_t count);
+extern int pci_mmap_legacy_mem(struct kobject *kobj,
+			       struct bin_attribute *attr,
+			       struct vm_area_struct *vma);
+
+#define pci_get_legacy_mem platform_pci_get_legacy_mem
+#define pci_legacy_read platform_pci_legacy_read
+#define pci_legacy_write platform_pci_legacy_write
 
 struct pci_window {
 	struct resource resource;
===== include/asm-ia64/sn/sn_sal.h 1.18 vs edited =====
--- 1.18/include/asm-ia64/sn/sn_sal.h	2004-12-10 12:10:33 -08:00
+++ edited/include/asm-ia64/sn/sn_sal.h	2004-12-23 07:51:21 -08:00
@@ -475,6 +475,52 @@
 	return isrv.v0;
 }
 
+/**
+ * ia64_sn_probe_mem - read from memory safely
+ * @addr: address to probe
+ * @size: number bytes to read (1,2,4,8)
+ * @data_ptr: address to store value read by probe (-1 returned if probe fails)
+ *
+ * Call into the SAL to do a memory read.  If the read generates a machine
+ * check, this routine will recover gracefully and return -1 to the caller.
+ * @addr is usually a kernel virtual address in uncached space (i.e. the
+ * address starts with 0xc), but if called in physical mode, @addr should
+ * be a physical address.
+ *
+ * Return values:
+ *  0 - probe successful
+ *  1 - probe failed (generated MCA)
+ *  2 - Bad arg
+ * <0 - PAL error
+ */
+static inline u64
+ia64_sn_probe_mem(long addr, long size, void *data_ptr)
+{
+	struct ia64_sal_retval isrv;
+
+	SAL_CALL(isrv, SN_SAL_PROBE, addr, size, 0, 0, 0, 0, 0);
+
+	if (data_ptr) {
+		switch (size) {
+		case 1:
+			*((u8*)data_ptr) = (u8)isrv.v0;
+			break;
+		case 2:
+			*((u16*)data_ptr) = (u16)isrv.v0;
+			break;
+		case 4:
+			*((u32*)data_ptr) = (u32)isrv.v0;
+			break;
+		case 8:
+			*((u64*)data_ptr) = (u64)isrv.v0;
+			break;
+		default:
+			isrv.status = 2;
+		}
+	}
+	return isrv.status;
+}
+
 /*
  * Retrieve the system serial number as an ASCII string.
  */

--Boundary-00=_2ruyB16lvrvgaZN--
