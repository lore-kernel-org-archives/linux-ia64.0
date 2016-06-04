From: Yinghai Lu <yinghai@kernel.org>
Date: Sat, 04 Jun 2016 00:06:28 +0000
Subject: [PATCH v12 01/15] PCI: Let pci_mmap_page_range() take extra resource pointer
Message-Id: <20160604000642.28162-2-yinghai@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160604000642.28162-1-yinghai@kernel.org>
In-Reply-To: <20160604000642.28162-1-yinghai@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

This one is preparing patch for next one:
  PCI: Let pci_mmap_page_range() take resource addr

We need to pass extra resource pointer to avoid searching that again
for powerpc and microblaze prot set operation.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-cris-kernel@axis.com
Cc: linux-ia64@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: linux-am33-list@redhat.com
Cc: linux-parisc@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-sh@vger.kernel.org
Cc: sparclinux@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
---
 arch/arm/include/asm/pci.h              | 2 --
 arch/arm/kernel/bios32.c                | 3 ++-
 arch/cris/arch-v32/drivers/pci/bios.c   | 3 ++-
 arch/cris/include/asm/pci.h             | 3 ---
 arch/ia64/include/asm/pci.h             | 2 --
 arch/ia64/pci/pci.c                     | 3 ++-
 arch/microblaze/include/asm/pci.h       | 3 ---
 arch/microblaze/pci/pci-common.c        | 3 ++-
 arch/mips/include/asm/pci.h             | 3 ---
 arch/mips/pci/pci.c                     | 3 ++-
 arch/mn10300/include/asm/pci.h          | 3 ---
 arch/mn10300/unit-asb2305/pci-asb2305.c | 3 ++-
 arch/parisc/include/asm/pci.h           | 3 ---
 arch/parisc/kernel/pci.c                | 3 ++-
 arch/powerpc/include/asm/pci.h          | 3 ---
 arch/powerpc/kernel/pci-common.c        | 3 ++-
 arch/sh/drivers/pci/pci.c               | 3 ++-
 arch/sh/include/asm/pci.h               | 2 --
 arch/sparc/include/asm/pci_64.h         | 4 ----
 arch/sparc/kernel/pci.c                 | 3 ++-
 arch/unicore32/include/asm/pci.h        | 2 --
 arch/unicore32/kernel/pci.c             | 3 ++-
 arch/x86/include/asm/pci.h              | 4 ----
 arch/x86/pci/i386.c                     | 3 ++-
 arch/xtensa/include/asm/pci.h           | 4 ----
 arch/xtensa/kernel/pci.c                | 3 ++-
 drivers/pci/pci-sysfs.c                 | 2 +-
 drivers/pci/pci.h                       | 2 +-
 drivers/pci/proc.c                      | 2 +-
 include/linux/pci.h                     | 6 ++++++
 30 files changed, 35 insertions(+), 54 deletions(-)

diff --git a/arch/arm/include/asm/pci.h b/arch/arm/include/asm/pci.h
index 057d381..51118a0 100644
--- a/arch/arm/include/asm/pci.h
+++ b/arch/arm/include/asm/pci.h
@@ -29,8 +29,6 @@ static inline int pci_proc_domain(struct pci_bus *bus)
 #define PCI_DMA_BUS_IS_PHYS     (1)
 
 #define HAVE_PCI_MMAP
-extern int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
-                               enum pci_mmap_state mmap_state, int write_combine);
 
 static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
 {
diff --git a/arch/arm/kernel/bios32.c b/arch/arm/kernel/bios32.c
index 05e61a2..d3245d1 100644
--- a/arch/arm/kernel/bios32.c
+++ b/arch/arm/kernel/bios32.c
@@ -602,7 +602,8 @@ int pcibios_enable_device(struct pci_dev *dev, int mask)
 	return pci_enable_resources(dev, mask);
 }
 
-int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
+int pci_mmap_page_range(struct pci_dev *dev, struct resource *res,
+			struct vm_area_struct *vma,
 			enum pci_mmap_state mmap_state, int write_combine)
 {
 	if (mmap_state = pci_mmap_io)
diff --git a/arch/cris/arch-v32/drivers/pci/bios.c b/arch/cris/arch-v32/drivers/pci/bios.c
index 64a5fb9..082efb9 100644
--- a/arch/cris/arch-v32/drivers/pci/bios.c
+++ b/arch/cris/arch-v32/drivers/pci/bios.c
@@ -14,7 +14,8 @@ void pcibios_set_master(struct pci_dev *dev)
 	pci_write_config_byte(dev, PCI_LATENCY_TIMER, lat);
 }
 
-int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
+int pci_mmap_page_range(struct pci_dev *dev, struct resource *res,
+			struct vm_area_struct *vma,
 			enum pci_mmap_state mmap_state, int write_combine)
 {
 	unsigned long prot;
diff --git a/arch/cris/include/asm/pci.h b/arch/cris/include/asm/pci.h
index b1b289d..65198cb 100644
--- a/arch/cris/include/asm/pci.h
+++ b/arch/cris/include/asm/pci.h
@@ -42,9 +42,6 @@ struct pci_dev;
 #define PCI_DMA_BUS_IS_PHYS	(1)
 
 #define HAVE_PCI_MMAP
-extern int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
-			       enum pci_mmap_state mmap_state, int write_combine);
-
 
 #endif /* __KERNEL__ */
 
diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index c0835b0..6a2f5d8 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -51,8 +51,6 @@ extern unsigned long ia64_max_iommu_merge_mask;
 #define PCI_DMA_BUS_IS_PHYS	(ia64_max_iommu_merge_mask = ~0UL)
 
 #define HAVE_PCI_MMAP
-extern int pci_mmap_page_range (struct pci_dev *dev, struct vm_area_struct *vma,
-				enum pci_mmap_state mmap_state, int write_combine);
 #define HAVE_PCI_LEGACY
 extern int pci_mmap_legacy_page_range(struct pci_bus *bus,
 				      struct vm_area_struct *vma,
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 8f6ac2f..1518d66 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -419,7 +419,8 @@ pcibios_align_resource (void *data, const struct resource *res,
 }
 
 int
-pci_mmap_page_range (struct pci_dev *dev, struct vm_area_struct *vma,
+pci_mmap_page_range(struct pci_dev *dev, struct resource *res,
+		     struct vm_area_struct *vma,
 		     enum pci_mmap_state mmap_state, int write_combine)
 {
 	unsigned long size = vma->vm_end - vma->vm_start;
diff --git a/arch/microblaze/include/asm/pci.h b/arch/microblaze/include/asm/pci.h
index fc3ecb5..1b93824 100644
--- a/arch/microblaze/include/asm/pci.h
+++ b/arch/microblaze/include/asm/pci.h
@@ -46,9 +46,6 @@ extern int pci_domain_nr(struct pci_bus *bus);
 extern int pci_proc_domain(struct pci_bus *bus);
 
 struct vm_area_struct;
-/* Map a range of PCI memory or I/O space for a device into user space */
-int pci_mmap_page_range(struct pci_dev *pdev, struct vm_area_struct *vma,
-			enum pci_mmap_state mmap_state, int write_combine);
 
 /* Tell drivers/pci/proc.c that we have pci_mmap_page_range() */
 #define HAVE_PCI_MMAP	1
diff --git a/arch/microblaze/pci/pci-common.c b/arch/microblaze/pci/pci-common.c
index 14cba60..95146b0 100644
--- a/arch/microblaze/pci/pci-common.c
+++ b/arch/microblaze/pci/pci-common.c
@@ -304,7 +304,8 @@ pgprot_t pci_phys_mem_access_prot(struct file *file,
  *
  * Returns a negative error code on failure, zero on success.
  */
-int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
+int pci_mmap_page_range(struct pci_dev *dev, struct resource *rp,
+			struct vm_area_struct *vma,
 			enum pci_mmap_state mmap_state, int write_combine)
 {
 	resource_size_t offset diff --git a/arch/mips/include/asm/pci.h b/arch/mips/include/asm/pci.h
index 86b239d..71d2c3b 100644
--- a/arch/mips/include/asm/pci.h
+++ b/arch/mips/include/asm/pci.h
@@ -75,9 +75,6 @@ extern void pcibios_set_master(struct pci_dev *dev);
 
 #define HAVE_PCI_MMAP
 
-extern int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
-	enum pci_mmap_state mmap_state, int write_combine);
-
 #define HAVE_ARCH_PCI_RESOURCE_TO_USER
 
 static inline void pci_resource_to_user(const struct pci_dev *dev, int bar,
diff --git a/arch/mips/pci/pci.c b/arch/mips/pci/pci.c
index f1b11f0..e620333 100644
--- a/arch/mips/pci/pci.c
+++ b/arch/mips/pci/pci.c
@@ -319,7 +319,8 @@ void pcibios_fixup_bus(struct pci_bus *bus)
 EXPORT_SYMBOL(PCIBIOS_MIN_IO);
 EXPORT_SYMBOL(PCIBIOS_MIN_MEM);
 
-int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
+int pci_mmap_page_range(struct pci_dev *dev, struct resource *res,
+			struct vm_area_struct *vma,
 			enum pci_mmap_state mmap_state, int write_combine)
 {
 	unsigned long prot;
diff --git a/arch/mn10300/include/asm/pci.h b/arch/mn10300/include/asm/pci.h
index 51159ff..082b6de 100644
--- a/arch/mn10300/include/asm/pci.h
+++ b/arch/mn10300/include/asm/pci.h
@@ -74,9 +74,6 @@ static inline int pci_controller_num(struct pci_dev *dev)
 }
 
 #define HAVE_PCI_MMAP
-extern int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
-			       enum pci_mmap_state mmap_state,
-			       int write_combine);
 
 #endif /* __KERNEL__ */
 
diff --git a/arch/mn10300/unit-asb2305/pci-asb2305.c b/arch/mn10300/unit-asb2305/pci-asb2305.c
index b7ab837..40efdc6 100644
--- a/arch/mn10300/unit-asb2305/pci-asb2305.c
+++ b/arch/mn10300/unit-asb2305/pci-asb2305.c
@@ -211,7 +211,8 @@ void __init pcibios_resource_survey(void)
 	pcibios_allocate_resources(1);
 }
 
-int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
+int pci_mmap_page_range(struct pci_dev *dev, struct resource *res,
+			struct vm_area_struct *vma,
 			enum pci_mmap_state mmap_state, int write_combine)
 {
 	unsigned long prot;
diff --git a/arch/parisc/include/asm/pci.h b/arch/parisc/include/asm/pci.h
index defebd9..bb9ea90 100644
--- a/arch/parisc/include/asm/pci.h
+++ b/arch/parisc/include/asm/pci.h
@@ -201,7 +201,4 @@ static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
 
 #define HAVE_PCI_MMAP
 
-extern int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
-	enum pci_mmap_state mmap_state, int write_combine);
-
 #endif /* __ASM_PARISC_PCI_H */
diff --git a/arch/parisc/kernel/pci.c b/arch/parisc/kernel/pci.c
index 0903c6a..8d5c34c 100644
--- a/arch/parisc/kernel/pci.c
+++ b/arch/parisc/kernel/pci.c
@@ -228,7 +228,8 @@ resource_size_t pcibios_align_resource(void *data, const struct resource *res,
 }
 
 
-int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
+int pci_mmap_page_range(struct pci_dev *dev, struct resource *res,
+			struct vm_area_struct *vma,
 			enum pci_mmap_state mmap_state, int write_combine)
 {
 	unsigned long prot;
diff --git a/arch/powerpc/include/asm/pci.h b/arch/powerpc/include/asm/pci.h
index a6f3ac0..662c1ef 100644
--- a/arch/powerpc/include/asm/pci.h
+++ b/arch/powerpc/include/asm/pci.h
@@ -77,9 +77,6 @@ extern int pci_domain_nr(struct pci_bus *bus);
 extern int pci_proc_domain(struct pci_bus *bus);
 
 struct vm_area_struct;
-/* Map a range of PCI memory or I/O space for a device into user space */
-int pci_mmap_page_range(struct pci_dev *pdev, struct vm_area_struct *vma,
-			enum pci_mmap_state mmap_state, int write_combine);
 
 /* Tell drivers/pci/proc.c that we have pci_mmap_page_range() */
 #define HAVE_PCI_MMAP	1
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index 0f7a60f..6720b81 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -445,7 +445,8 @@ pgprot_t pci_phys_mem_access_prot(struct file *file,
  *
  * Returns a negative error code on failure, zero on success.
  */
-int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
+int pci_mmap_page_range(struct pci_dev *dev, struct resource *rp,
+			struct vm_area_struct *vma,
 			enum pci_mmap_state mmap_state, int write_combine)
 {
 	resource_size_t offset diff --git a/arch/sh/drivers/pci/pci.c b/arch/sh/drivers/pci/pci.c
index d5462b7..a1bc7ba 100644
--- a/arch/sh/drivers/pci/pci.c
+++ b/arch/sh/drivers/pci/pci.c
@@ -269,7 +269,8 @@ void __init_refok pcibios_report_status(unsigned int status_mask, int warn)
 	}
 }
 
-int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
+int pci_mmap_page_range(struct pci_dev *dev, struct resource *res,
+			struct vm_area_struct *vma,
 			enum pci_mmap_state mmap_state, int write_combine)
 {
 	/*
diff --git a/arch/sh/include/asm/pci.h b/arch/sh/include/asm/pci.h
index 644314f..8e0fdb9 100644
--- a/arch/sh/include/asm/pci.h
+++ b/arch/sh/include/asm/pci.h
@@ -66,8 +66,6 @@ extern unsigned long PCIBIOS_MIN_IO, PCIBIOS_MIN_MEM;
 struct pci_dev;
 
 #define HAVE_PCI_MMAP
-extern int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
-	enum pci_mmap_state mmap_state, int write_combine);
 extern void pcibios_set_master(struct pci_dev *dev);
 
 /* Dynamic DMA mapping stuff.
diff --git a/arch/sparc/include/asm/pci_64.h b/arch/sparc/include/asm/pci_64.h
index 022d160..f7a93df 100644
--- a/arch/sparc/include/asm/pci_64.h
+++ b/arch/sparc/include/asm/pci_64.h
@@ -45,10 +45,6 @@ static inline int pci_proc_domain(struct pci_bus *bus)
 #define HAVE_ARCH_PCI_GET_UNMAPPED_AREA
 #define get_pci_unmapped_area get_fb_unmapped_area
 
-int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
-			enum pci_mmap_state mmap_state,
-			int write_combine);
-
 static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
 {
 	return PCI_IRQ_NONE;
diff --git a/arch/sparc/kernel/pci.c b/arch/sparc/kernel/pci.c
index c2b202d..86d7dda 100644
--- a/arch/sparc/kernel/pci.c
+++ b/arch/sparc/kernel/pci.c
@@ -862,7 +862,8 @@ static void __pci_mmap_set_pgprot(struct pci_dev *dev, struct vm_area_struct *vm
  *
  * Returns a negative error code on failure, zero on success.
  */
-int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
+int pci_mmap_page_range(struct pci_dev *dev, struct resource *res,
+			struct vm_area_struct *vma,
 			enum pci_mmap_state mmap_state,
 			int write_combine)
 {
diff --git a/arch/unicore32/include/asm/pci.h b/arch/unicore32/include/asm/pci.h
index 37e55d0..a5129086 100644
--- a/arch/unicore32/include/asm/pci.h
+++ b/arch/unicore32/include/asm/pci.h
@@ -17,8 +17,6 @@
 #include <mach/hardware.h> /* for PCIBIOS_MIN_* */
 
 #define HAVE_PCI_MMAP
-extern int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
-	enum pci_mmap_state mmap_state, int write_combine);
 
 #endif /* __KERNEL__ */
 #endif
diff --git a/arch/unicore32/kernel/pci.c b/arch/unicore32/kernel/pci.c
index d45fa5f..ff1b7ef 100644
--- a/arch/unicore32/kernel/pci.c
+++ b/arch/unicore32/kernel/pci.c
@@ -362,7 +362,8 @@ int pcibios_enable_device(struct pci_dev *dev, int mask)
 	return 0;
 }
 
-int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
+int pci_mmap_page_range(struct pci_dev *dev, struct resource *res,
+			struct vm_area_struct *vma,
 			enum pci_mmap_state mmap_state, int write_combine)
 {
 	unsigned long phys;
diff --git a/arch/x86/include/asm/pci.h b/arch/x86/include/asm/pci.h
index 9ab7507..eb87481 100644
--- a/arch/x86/include/asm/pci.h
+++ b/arch/x86/include/asm/pci.h
@@ -88,10 +88,6 @@ int pcibios_set_irq_routing(struct pci_dev *dev, int pin, int irq);
 
 
 #define HAVE_PCI_MMAP
-extern int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
-			       enum pci_mmap_state mmap_state,
-			       int write_combine);
-
 
 #ifdef CONFIG_PCI
 extern void early_quirks(void);
diff --git a/arch/x86/pci/i386.c b/arch/x86/pci/i386.c
index 0a9f2ca..36463c7 100644
--- a/arch/x86/pci/i386.c
+++ b/arch/x86/pci/i386.c
@@ -411,7 +411,8 @@ static const struct vm_operations_struct pci_mmap_ops = {
 	.access = generic_access_phys,
 };
 
-int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
+int pci_mmap_page_range(struct pci_dev *dev, struct resource *res,
+			struct vm_area_struct *vma,
 			enum pci_mmap_state mmap_state, int write_combine)
 {
 	unsigned long prot;
diff --git a/arch/xtensa/include/asm/pci.h b/arch/xtensa/include/asm/pci.h
index 5d6bd93..bb5510b 100644
--- a/arch/xtensa/include/asm/pci.h
+++ b/arch/xtensa/include/asm/pci.h
@@ -46,10 +46,6 @@ struct pci_dev;
 
 #define PCI_DMA_BUS_IS_PHYS	(1)
 
-/* Map a range of PCI memory or I/O space for a device into user space */
-int pci_mmap_page_range(struct pci_dev *pdev, struct vm_area_struct *vma,
-			enum pci_mmap_state mmap_state, int write_combine);
-
 /* Tell drivers/pci/proc.c that we have pci_mmap_page_range() */
 #define HAVE_PCI_MMAP	1
 
diff --git a/arch/xtensa/kernel/pci.c b/arch/xtensa/kernel/pci.c
index b848cc3..89c8687 100644
--- a/arch/xtensa/kernel/pci.c
+++ b/arch/xtensa/kernel/pci.c
@@ -362,7 +362,8 @@ __pci_mmap_set_pgprot(struct pci_dev *dev, struct vm_area_struct *vma,
  *
  * Returns a negative error code on failure, zero on success.
  */
-int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
+int pci_mmap_page_range(struct pci_dev *dev, struct resource *res,
+			struct vm_area_struct *vma,
 			enum pci_mmap_state mmap_state,
 			int write_combine)
 {
diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
index d319a9c..5bbe20c 100644
--- a/drivers/pci/pci-sysfs.c
+++ b/drivers/pci/pci-sysfs.c
@@ -1027,7 +1027,7 @@ static int pci_mmap_resource(struct kobject *kobj, struct bin_attribute *attr,
 	pci_resource_to_user(pdev, i, res, &start, &end);
 	vma->vm_pgoff += start >> PAGE_SHIFT;
 	mmap_type = res->flags & IORESOURCE_MEM ? pci_mmap_mem : pci_mmap_io;
-	return pci_mmap_page_range(pdev, vma, mmap_type, write_combine);
+	return pci_mmap_page_range(pdev, res, vma, mmap_type, write_combine);
 }
 
 static int pci_mmap_resource_uc(struct file *filp, struct kobject *kobj,
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index a814bbb..7d339c3 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -30,7 +30,7 @@ enum pci_mmap_api {
 	PCI_MMAP_PROCFS	/* mmap on /proc/bus/pci/<BDF> */
 };
 int pci_mmap_fits(struct pci_dev *pdev, int resno, struct vm_area_struct *vmai,
-		  enum pci_mmap_api mmap_api);
+		  enum pci_mmap_state mmap_type, enum pci_mmap_api mmap_api);
 #endif
 int pci_probe_reset_function(struct pci_dev *dev);
 
diff --git a/drivers/pci/proc.c b/drivers/pci/proc.c
index 3f155e7..f19ee2a 100644
--- a/drivers/pci/proc.c
+++ b/drivers/pci/proc.c
@@ -245,7 +245,7 @@ static int proc_bus_pci_mmap(struct file *file, struct vm_area_struct *vma)
 	if (i >= PCI_ROM_RESOURCE)
 		return -ENODEV;
 
-	ret = pci_mmap_page_range(dev, vma,
+	ret = pci_mmap_page_range(dev, &dev->resource[i], vma,
 				  fpriv->mmap_state,
 				  fpriv->write_combine);
 	if (ret < 0)
diff --git a/include/linux/pci.h b/include/linux/pci.h
index b67e4df..3c1a0f4 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -70,6 +70,12 @@ enum pci_mmap_state {
 	pci_mmap_mem
 };
 
+struct vm_area_struct;
+/* Map a range of PCI memory or I/O space for a device into user space */
+int pci_mmap_page_range(struct pci_dev *dev, struct resource *res,
+			struct vm_area_struct *vma,
+			enum pci_mmap_state mmap_state, int write_combine);
+
 /*
  *  For PCI devices, the region numbers are assigned this way:
  */
-- 
2.8.3

