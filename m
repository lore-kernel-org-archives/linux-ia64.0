From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Tue, 06 May 2014 03:29:52 +0000
Subject: [PATCH] PCI: Turn pcibios_penalize_isa_irq() into __weak function
Message-Id: <1399346992-6584-1-git-send-email-hanjun.guo@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Yijing Wang <wangyijing@huawei.com>, Thomas Gleixner <tglx@linutronix.de>, linux-pci@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linaro-acpi@lists.linaro.org, Hanjun Guo <hanjun.guo@linaro.org>

pcibios_penalize_isa_irq() is only useful for x86 now, and
legacy ISA is not used by some architectures, so make
pcibios_penalize_isa_irq() as __weak function to simplify
the code, this will prevent new platform from introducing
dummy stub function for pcibios_penalize_isa_irq() too.

Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
---
 arch/alpha/include/asm/pci.h        |    5 -----
 arch/arm/include/asm/pci.h          |    5 -----
 arch/blackfin/include/asm/pci.h     |    5 -----
 arch/cris/include/asm/pci.h         |    1 -
 arch/frv/include/asm/pci.h          |    2 --
 arch/frv/mb93090-mb00/pci-irq.c     |    4 ----
 arch/ia64/include/asm/pci.h         |    6 ------
 arch/microblaze/include/asm/pci.h   |    5 -----
 arch/mips/include/asm/pci.h         |    5 -----
 arch/mn10300/include/asm/pci.h      |    1 -
 arch/mn10300/unit-asb2305/pci-irq.c |    4 ----
 arch/parisc/include/asm/pci.h       |    5 -----
 arch/powerpc/include/asm/pci.h      |    5 -----
 arch/sh/include/asm/pci.h           |    5 -----
 arch/sparc/include/asm/pci_32.h     |    5 -----
 arch/sparc/include/asm/pci_64.h     |    5 -----
 arch/unicore32/include/asm/pci.h    |    5 -----
 arch/x86/include/asm/pci.h          |    1 -
 arch/xtensa/include/asm/pci.h       |    5 -----
 drivers/pci/pci.c                   |   11 +++++++++++
 include/linux/pci.h                 |    1 +
 21 files changed, 12 insertions(+), 79 deletions(-)

diff --git a/arch/alpha/include/asm/pci.h b/arch/alpha/include/asm/pci.h
index d01afb7..f7f680f 100644
--- a/arch/alpha/include/asm/pci.h
+++ b/arch/alpha/include/asm/pci.h
@@ -59,11 +59,6 @@ struct pci_controller {
 
 extern void pcibios_set_master(struct pci_dev *dev);
 
-extern inline void pcibios_penalize_isa_irq(int irq, int active)
-{
-	/* We don't do dynamic PCI IRQ allocation */
-}
-
 /* IOMMU controls.  */
 
 /* The PCI address space does not equal the physical memory address space.
diff --git a/arch/arm/include/asm/pci.h b/arch/arm/include/asm/pci.h
index 680a83e..7e95d85 100644
--- a/arch/arm/include/asm/pci.h
+++ b/arch/arm/include/asm/pci.h
@@ -31,11 +31,6 @@ static inline int pci_proc_domain(struct pci_bus *bus)
 }
 #endif /* CONFIG_PCI_DOMAINS */
 
-static inline void pcibios_penalize_isa_irq(int irq, int active)
-{
-	/* We don't do dynamic PCI IRQ allocation */
-}
-
 /*
  * The PCI address space does equal the physical memory address space.
  * The networking and block device layers use this boolean for bounce
diff --git a/arch/blackfin/include/asm/pci.h b/arch/blackfin/include/asm/pci.h
index 74352c4..c737909 100644
--- a/arch/blackfin/include/asm/pci.h
+++ b/arch/blackfin/include/asm/pci.h
@@ -10,9 +10,4 @@
 #define PCIBIOS_MIN_IO 0x00001000
 #define PCIBIOS_MIN_MEM 0x10000000
 
-static inline void pcibios_penalize_isa_irq(int irq)
-{
-	/* We don't do dynamic PCI IRQ allocation */
-}
-
 #endif				/* _ASM_BFIN_PCI_H */
diff --git a/arch/cris/include/asm/pci.h b/arch/cris/include/asm/pci.h
index f666734..cc2399c 100644
--- a/arch/cris/include/asm/pci.h
+++ b/arch/cris/include/asm/pci.h
@@ -20,7 +20,6 @@ void pcibios_config_init(void);
 struct pci_bus * pcibios_scan_root(int bus);
 
 void pcibios_set_master(struct pci_dev *dev);
-void pcibios_penalize_isa_irq(int irq);
 struct irq_routing_table *pcibios_get_irq_routing_table(void);
 int pcibios_set_irq_routing(struct pci_dev *dev, int pin, int irq);
 
diff --git a/arch/frv/include/asm/pci.h b/arch/frv/include/asm/pci.h
index ef03baf..2035a4d 100644
--- a/arch/frv/include/asm/pci.h
+++ b/arch/frv/include/asm/pci.h
@@ -24,8 +24,6 @@ struct pci_dev;
 
 extern void pcibios_set_master(struct pci_dev *dev);
 
-extern void pcibios_penalize_isa_irq(int irq);
-
 #ifdef CONFIG_MMU
 extern void *consistent_alloc(gfp_t gfp, size_t size, dma_addr_t *dma_handle);
 extern void consistent_free(void *vaddr);
diff --git a/arch/frv/mb93090-mb00/pci-irq.c b/arch/frv/mb93090-mb00/pci-irq.c
index c677b9d..1c35c93 100644
--- a/arch/frv/mb93090-mb00/pci-irq.c
+++ b/arch/frv/mb93090-mb00/pci-irq.c
@@ -55,10 +55,6 @@ void __init pcibios_fixup_irqs(void)
 	}
 }
 
-void __init pcibios_penalize_isa_irq(int irq)
-{
-}
-
 void pcibios_enable_irq(struct pci_dev *dev)
 {
 	pci_write_config_byte(dev, PCI_INTERRUPT_LINE, dev->irq);
diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index 7d41cc0..52af5ed 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -50,12 +50,6 @@ struct pci_dev;
 extern unsigned long ia64_max_iommu_merge_mask;
 #define PCI_DMA_BUS_IS_PHYS	(ia64_max_iommu_merge_mask = ~0UL)
 
-static inline void
-pcibios_penalize_isa_irq (int irq, int active)
-{
-	/* We don't do dynamic PCI IRQ allocation */
-}
-
 #include <asm-generic/pci-dma-compat.h>
 
 #ifdef CONFIG_PCI
diff --git a/arch/microblaze/include/asm/pci.h b/arch/microblaze/include/asm/pci.h
index 935f9be..3355240 100644
--- a/arch/microblaze/include/asm/pci.h
+++ b/arch/microblaze/include/asm/pci.h
@@ -44,11 +44,6 @@ struct pci_dev;
  */
 #define pcibios_assign_all_busses()	0
 
-static inline void pcibios_penalize_isa_irq(int irq, int active)
-{
-	/* We don't do dynamic PCI IRQ allocation */
-}
-
 #ifdef CONFIG_PCI
 extern void set_pci_dma_ops(struct dma_map_ops *dma_ops);
 extern struct dma_map_ops *get_pci_dma_ops(void);
diff --git a/arch/mips/include/asm/pci.h b/arch/mips/include/asm/pci.h
index 12d6842..974b0e3 100644
--- a/arch/mips/include/asm/pci.h
+++ b/arch/mips/include/asm/pci.h
@@ -73,11 +73,6 @@ extern unsigned long PCIBIOS_MIN_MEM;
 
 extern void pcibios_set_master(struct pci_dev *dev);
 
-static inline void pcibios_penalize_isa_irq(int irq, int active)
-{
-	/* We don't do dynamic PCI IRQ allocation */
-}
-
 #define HAVE_PCI_MMAP
 
 extern int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
diff --git a/arch/mn10300/include/asm/pci.h b/arch/mn10300/include/asm/pci.h
index 1663238..5f70af2 100644
--- a/arch/mn10300/include/asm/pci.h
+++ b/arch/mn10300/include/asm/pci.h
@@ -48,7 +48,6 @@ extern void unit_pci_init(void);
 #define PCIBIOS_MIN_MEM		0xB8000000
 
 void pcibios_set_master(struct pci_dev *dev);
-void pcibios_penalize_isa_irq(int irq);
 
 /* Dynamic DMA mapping stuff.
  * i386 has everything mapped statically.
diff --git a/arch/mn10300/unit-asb2305/pci-irq.c b/arch/mn10300/unit-asb2305/pci-irq.c
index 77439da..fcb28ce 100644
--- a/arch/mn10300/unit-asb2305/pci-irq.c
+++ b/arch/mn10300/unit-asb2305/pci-irq.c
@@ -40,10 +40,6 @@ void __init pcibios_fixup_irqs(void)
 	}
 }
 
-void __init pcibios_penalize_isa_irq(int irq)
-{
-}
-
 void pcibios_enable_irq(struct pci_dev *dev)
 {
 	pci_write_config_byte(dev, PCI_INTERRUPT_LINE, dev->irq);
diff --git a/arch/parisc/include/asm/pci.h b/arch/parisc/include/asm/pci.h
index 4651540..20df2b0 100644
--- a/arch/parisc/include/asm/pci.h
+++ b/arch/parisc/include/asm/pci.h
@@ -215,11 +215,6 @@ static inline void pci_dma_burst_advice(struct pci_dev *pdev,
 }
 #endif
 
-static inline void pcibios_penalize_isa_irq(int irq, int active)
-{
-	/* We don't need to penalize isa irq's */
-}
-
 static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
 {
 	return channel ? 15 : 14;
diff --git a/arch/powerpc/include/asm/pci.h b/arch/powerpc/include/asm/pci.h
index 95145a1..1b0739b 100644
--- a/arch/powerpc/include/asm/pci.h
+++ b/arch/powerpc/include/asm/pci.h
@@ -46,11 +46,6 @@ struct pci_dev;
 #define pcibios_assign_all_busses() \
 	(pci_has_flag(PCI_REASSIGN_ALL_BUS))
 
-static inline void pcibios_penalize_isa_irq(int irq, int active)
-{
-	/* We don't do dynamic PCI IRQ allocation */
-}
-
 #define HAVE_ARCH_PCI_GET_LEGACY_IDE_IRQ
 static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
 {
diff --git a/arch/sh/include/asm/pci.h b/arch/sh/include/asm/pci.h
index bff96c2..5b45115 100644
--- a/arch/sh/include/asm/pci.h
+++ b/arch/sh/include/asm/pci.h
@@ -70,11 +70,6 @@ extern int pci_mmap_page_range(struct pci_dev *dev, struct vm_area_struct *vma,
 	enum pci_mmap_state mmap_state, int write_combine);
 extern void pcibios_set_master(struct pci_dev *dev);
 
-static inline void pcibios_penalize_isa_irq(int irq, int active)
-{
-	/* We don't do dynamic PCI IRQ allocation */
-}
-
 /* Dynamic DMA mapping stuff.
  * SuperH has everything mapped statically like x86.
  */
diff --git a/arch/sparc/include/asm/pci_32.h b/arch/sparc/include/asm/pci_32.h
index dc50329..53e9b49 100644
--- a/arch/sparc/include/asm/pci_32.h
+++ b/arch/sparc/include/asm/pci_32.h
@@ -16,11 +16,6 @@
 
 #define PCI_IRQ_NONE		0xffffffff
 
-static inline void pcibios_penalize_isa_irq(int irq, int active)
-{
-	/* We don't do dynamic PCI IRQ allocation */
-}
-
 /* Dynamic DMA mapping stuff.
  */
 #define PCI_DMA_BUS_IS_PHYS	(0)
diff --git a/arch/sparc/include/asm/pci_64.h b/arch/sparc/include/asm/pci_64.h
index 1633b71..c6c7396 100644
--- a/arch/sparc/include/asm/pci_64.h
+++ b/arch/sparc/include/asm/pci_64.h
@@ -16,11 +16,6 @@
 
 #define PCI_IRQ_NONE		0xffffffff
 
-static inline void pcibios_penalize_isa_irq(int irq, int active)
-{
-	/* We don't do dynamic PCI IRQ allocation */
-}
-
 /* The PCI address space does not equal the physical memory
  * address space.  The networking and block device layers use
  * this boolean for bounce buffer decisions.
diff --git a/arch/unicore32/include/asm/pci.h b/arch/unicore32/include/asm/pci.h
index f5e108f..654407e 100644
--- a/arch/unicore32/include/asm/pci.h
+++ b/arch/unicore32/include/asm/pci.h
@@ -18,11 +18,6 @@
 #include <asm-generic/pci.h>
 #include <mach/hardware.h> /* for PCIBIOS_MIN_* */
 
-static inline void pcibios_penalize_isa_irq(int irq, int active)
-{
-	/* We don't do dynamic PCI IRQ allocation */
-}
-
 #ifdef CONFIG_PCI
 static inline void pci_dma_burst_advice(struct pci_dev *pdev,
 					enum pci_dma_burst_strategy *strat,
diff --git a/arch/x86/include/asm/pci.h b/arch/x86/include/asm/pci.h
index 96ae4f4..0892ea0 100644
--- a/arch/x86/include/asm/pci.h
+++ b/arch/x86/include/asm/pci.h
@@ -68,7 +68,6 @@ void pcibios_config_init(void);
 void pcibios_scan_root(int bus);
 
 void pcibios_set_master(struct pci_dev *dev);
-void pcibios_penalize_isa_irq(int irq, int active);
 struct irq_routing_table *pcibios_get_irq_routing_table(void);
 int pcibios_set_irq_routing(struct pci_dev *dev, int pin, int irq);
 
diff --git a/arch/xtensa/include/asm/pci.h b/arch/xtensa/include/asm/pci.h
index 614be03..5d52dc4 100644
--- a/arch/xtensa/include/asm/pci.h
+++ b/arch/xtensa/include/asm/pci.h
@@ -22,11 +22,6 @@
 
 extern struct pci_controller* pcibios_alloc_controller(void);
 
-static inline void pcibios_penalize_isa_irq(int irq)
-{
-	/* We don't do dynamic PCI IRQ allocation */
-}
-
 /* Assume some values. (We should revise them, if necessary) */
 
 #define PCIBIOS_MIN_IO		0x2000
diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index 7325d43..57c330f 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -1468,6 +1468,17 @@ void __weak pcibios_release_device(struct pci_dev *dev) {}
  */
 void __weak pcibios_disable_device (struct pci_dev *dev) {}
 
+/**
+ * pcibios_penalize_isa_irq - provide arch specific hooks when penalize isa irq
+ * @irq: isa irq to penalize
+ * @active: irq active or not
+ *
+ * Permits the platform to provide architecture specific functionality when
+ * penalize isa irq. This is the default implementation. Architecture
+ * implementations can override this.
+ */
+void __weak pcibios_penalize_isa_irq(int irq, int active) {}
+
 static void do_pci_disable_device(struct pci_dev *dev)
 {
 	u16 pci_command;
diff --git a/include/linux/pci.h b/include/linux/pci.h
index aab57b4..da8f7d5 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1579,6 +1579,7 @@ int pcibios_set_pcie_reset_state(struct pci_dev *dev,
 				 enum pcie_reset_state state);
 int pcibios_add_device(struct pci_dev *dev);
 void pcibios_release_device(struct pci_dev *dev);
+void pcibios_penalize_isa_irq(int irq, int active);
 
 #ifdef CONFIG_HIBERNATE_CALLBACKS
 extern struct dev_pm_ops pcibios_pm_ops;
-- 
1.7.9.5

