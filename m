From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 05 Oct 2004 11:10:19 +0000
Subject: sparse __iomem annotations
Message-Id: <200410051110.i95BAJOi001321@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64: sparse __iomem annotations

This patch adds __iomem annotations.  The only less-than-trivial part
of the patch is the change of ipi_base_addr from "unsigned long" to
"void __iomem *" but even that part should be safe.  The patch results
in additional warnings from certain drivers (e.g., eepro100.c) but the
warnings are harmless and just indicate that the offending drivers
need to be updated for the more strict __iomem checking.  The patch
has been boot-tested.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

 arch/ia64/hp/common/sba_iommu.c |    2 
 arch/ia64/kernel/acpi.c         |    8 +--
 arch/ia64/kernel/iosapic.c      |   18 ++++----
 arch/ia64/kernel/irq_ia64.c     |    7 +--
 arch/ia64/lib/io.c              |   22 +++++-----
 drivers/char/agp/hp-agp.c       |   10 ++--
 include/asm-ia64/hw_irq.h       |    2 
 include/asm-ia64/io.h           |   83 +++++++++++++++++++---------------------
 include/asm-ia64/iosapic.h      |    8 +--
 include/asm-ia64/smp.h          |    8 +--
 10 files changed, 82 insertions(+), 86 deletions(-)

=== arch/ia64/hp/common/sba_iommu.c 1.44 vs edited ==--- 1.44/arch/ia64/hp/common/sba_iommu.c	2004-09-09 15:18:54 -07:00
+++ edited/arch/ia64/hp/common/sba_iommu.c	2004-10-05 01:44:15 -07:00
@@ -191,7 +191,7 @@
 static unsigned long iovp_mask;
 
 struct ioc {
-	void		*ioc_hpa;	/* I/O MMU base address */
+	void __iomem	*ioc_hpa;	/* I/O MMU base address */
 	char		*res_map;	/* resource map, bit = pdir entry */
 	u64		*pdir_base;	/* physical base address */
 	unsigned long	ibase;		/* pdir IOV Space base */
=== arch/ia64/kernel/acpi.c 1.76 vs edited ==--- 1.76/arch/ia64/kernel/acpi.c	2004-09-22 16:06:35 -07:00
+++ edited/arch/ia64/kernel/acpi.c	2004-10-04 09:11:00 -07:00
@@ -178,8 +178,8 @@
 		return -EINVAL;
 
 	if (lapic->address) {
-		iounmap((void *) ipi_base_addr);
-		ipi_base_addr = (unsigned long) ioremap(lapic->address, 0);
+		iounmap(ipi_base_addr);
+		ipi_base_addr = ioremap(lapic->address, 0);
 	}
 	return 0;
 }
@@ -336,9 +336,9 @@
 	/* Get base address of IPI Message Block */
 
 	if (acpi_madt->lapic_address)
-		ipi_base_addr = (unsigned long) ioremap(acpi_madt->lapic_address, 0);
+		ipi_base_addr = ioremap(acpi_madt->lapic_address, 0);
 
-	printk(KERN_INFO PREFIX "Local APIC address 0x%lx\n", ipi_base_addr);
+	printk(KERN_INFO PREFIX "Local APIC address %p\n", ipi_base_addr);
 
 	acpi_madt_oem_check(acpi_madt->header.oem_id,
 		acpi_madt->header.oem_table_id);
=== arch/ia64/kernel/iosapic.c 1.47 vs edited ==--- 1.47/arch/ia64/kernel/iosapic.c	2004-09-09 15:25:26 -07:00
+++ edited/arch/ia64/kernel/iosapic.c	2004-10-04 09:12:41 -07:00
@@ -104,7 +104,7 @@
 /* These tables map IA-64 vectors to the IOSAPIC pin that generates this vector. */
 
 static struct iosapic_intr_info {
-	char		*addr;		/* base address of IOSAPIC */
+	char __iomem	*addr;		/* base address of IOSAPIC */
 	u32		low32;		/* current value of low word of Redirection table entry */
 	unsigned int	gsi_base;	/* first GSI assigned to this IOSAPIC */
 	char		rte_index;	/* IOSAPIC RTE index (-1 => not an IOSAPIC interrupt) */
@@ -114,7 +114,7 @@
 } iosapic_intr_info[IA64_NUM_VECTORS];
 
 static struct iosapic {
-	char		*addr;		/* base address of IOSAPIC */
+	char __iomem	*addr;		/* base address of IOSAPIC */
 	unsigned int 	gsi_base;	/* first GSI assigned to this IOSAPIC */
 	unsigned short 	num_rte;	/* number of RTE in this IOSAPIC */
 #ifdef CONFIG_NUMA
@@ -179,7 +179,7 @@
 {
 	unsigned long pol, trigger, dmode, flags;
 	u32 low32, high32;
-	char *addr;
+	char __iomem *addr;
 	int rte_index;
 	char redir;
 
@@ -237,7 +237,7 @@
 mask_irq (unsigned int irq)
 {
 	unsigned long flags;
-	char *addr;
+	char __iomem *addr;
 	u32 low32;
 	int rte_index;
 	ia64_vector vec = irq_to_vector(irq);
@@ -261,7 +261,7 @@
 unmask_irq (unsigned int irq)
 {
 	unsigned long flags;
-	char *addr;
+	char __iomem *addr;
 	u32 low32;
 	int rte_index;
 	ia64_vector vec = irq_to_vector(irq);
@@ -287,7 +287,7 @@
 	unsigned long flags;
 	u32 high32, low32;
 	int dest, rte_index;
-	char *addr;
+	char __iomem *addr;
 	int redir = (irq & IA64_IRQ_REDIRECTED) ? 1 : 0;
 	ia64_vector vec;
 
@@ -412,7 +412,7 @@
 };
 
 unsigned int
-iosapic_version (char *addr)
+iosapic_version (char __iomem *addr)
 {
 	/*
 	 * IOSAPIC Version Register return 32 bit structure like:
@@ -457,7 +457,7 @@
 	int rte_index;
 	int index;
 	unsigned long gsi_base;
-	char *iosapic_address;
+	void __iomem *iosapic_address;
 
 	index = find_iosapic(gsi);
 	if (index < 0) {
@@ -696,7 +696,7 @@
 {
 	int num_rte;
 	unsigned int isa_irq, ver;
-	char *addr;
+	char __iomem *addr;
 
 	addr = ioremap(phys_addr, 0);
 	ver = iosapic_version(addr);
=== arch/ia64/kernel/irq_ia64.c 1.20 vs edited ==--- 1.20/arch/ia64/kernel/irq_ia64.c	2004-05-14 19:00:12 -07:00
+++ edited/arch/ia64/kernel/irq_ia64.c	2004-10-04 09:14:11 -07:00
@@ -47,7 +47,8 @@
 #define IRQ_DEBUG	0
 
 /* default base addr of IPI table */
-unsigned long ipi_base_addr = (__IA64_UNCACHED_OFFSET | IA64_IPI_DEFAULT_BASE_ADDR);
+void __iomem *ipi_base_addr = ((void __iomem *)
+			       (__IA64_UNCACHED_OFFSET | IA64_IPI_DEFAULT_BASE_ADDR));
 
 /*
  * Legacy IRQ to IA-64 vector translation table.
@@ -254,7 +255,7 @@
 void
 ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect)
 {
-	unsigned long ipi_addr;
+	void __iomem *ipi_addr;
 	unsigned long ipi_data;
 	unsigned long phys_cpu_id;
 
@@ -269,7 +270,7 @@
 	 */
 
 	ipi_data = (delivery_mode << 8) | (vector & 0xff);
-	ipi_addr = ipi_base_addr | (phys_cpu_id << 4) | ((redirect & 1)  << 3);
+	ipi_addr = ipi_base_addr + ((phys_cpu_id << 4) | ((redirect & 1) << 3));
 
 	writeq(ipi_data, ipi_addr);
 }
=== arch/ia64/lib/io.c 1.8 vs edited ==--- 1.8/arch/ia64/lib/io.c	2004-02-10 18:59:28 -08:00
+++ edited/arch/ia64/lib/io.c	2004-10-05 03:46:14 -07:00
@@ -9,7 +9,7 @@
  * This needs to be optimized.
  */
 void
-__ia64_memcpy_fromio (void *to, unsigned long from, long count)
+__ia64_memcpy_fromio (void *to, volatile void __iomem *from, long count)
 {
 	char *dst = to;
 
@@ -25,7 +25,7 @@
  * This needs to be optimized.
  */
 void
-__ia64_memcpy_toio (unsigned long to, void *from, long count)
+__ia64_memcpy_toio (volatile void __iomem *to, void *from, long count)
 {
 	char *src = from;
 
@@ -41,7 +41,7 @@
  * This needs to be optimized.
  */
 void
-__ia64_memset_c_io (unsigned long dst, unsigned long c, long count)
+__ia64_memset_c_io (volatile void __iomem *dst, unsigned long c, long count)
 {
 	unsigned char ch = (char)(c & 0xff);
 
@@ -111,49 +111,49 @@
 }
 
 unsigned char
-__ia64_readb (void *addr)
+__ia64_readb (void __iomem *addr)
 {
 	return ___ia64_readb (addr);
 }
 
 unsigned short
-__ia64_readw (void *addr)
+__ia64_readw (void __iomem *addr)
 {
 	return ___ia64_readw (addr);
 }
 
 unsigned int
-__ia64_readl (void *addr)
+__ia64_readl (void __iomem *addr)
 {
 	return ___ia64_readl (addr);
 }
 
 unsigned long
-__ia64_readq (void *addr)
+__ia64_readq (void __iomem *addr)
 {
 	return ___ia64_readq (addr);
 }
 
 unsigned char
-__ia64_readb_relaxed (void *addr)
+__ia64_readb_relaxed (void __iomem *addr)
 {
 	return ___ia64_readb (addr);
 }
 
 unsigned short
-__ia64_readw_relaxed (void *addr)
+__ia64_readw_relaxed (void __iomem *addr)
 {
 	return ___ia64_readw (addr);
 }
 
 unsigned int
-__ia64_readl_relaxed (void *addr)
+__ia64_readl_relaxed (void __iomem *addr)
 {
 	return ___ia64_readl (addr);
 }
 
 unsigned long
-__ia64_readq_relaxed (void *addr)
+__ia64_readq_relaxed (void __iomem *addr)
 {
 	return ___ia64_readq (addr);
 }
=== drivers/char/agp/hp-agp.c 1.29 vs edited ==--- 1.29/drivers/char/agp/hp-agp.c	2004-07-28 21:58:54 -07:00
+++ edited/drivers/char/agp/hp-agp.c	2004-10-05 01:44:16 -07:00
@@ -59,8 +59,8 @@
 };
 
 static struct _hp_private {
-	volatile u8 *ioc_regs;
-	volatile u8 *lba_regs;
+	volatile u8 __iomem *ioc_regs;
+	volatile u8 __iomem *lba_regs;
 	int lba_cap_offset;
 	u64 *io_pdir;		// PDIR for entire IOVA
 	u64 *gatt;		// PDIR just for GART (subset of above)
@@ -183,7 +183,7 @@
 }
 
 static int
-hp_zx1_lba_find_capability (volatile u8 *hpa, int cap)
+hp_zx1_lba_find_capability (volatile u8 __iomem *hpa, int cap)
 {
 	u16 status;
 	u8 pos, id;
@@ -267,10 +267,10 @@
 	if (hp->ioc_regs) {
 		if (hp->io_pdir_owner)
 			OUTREG64(hp->ioc_regs, HP_ZX1_IBASE, 0);
-		iounmap((void *) hp->ioc_regs);
+		iounmap(hp->ioc_regs);
 	}
 	if (hp->lba_regs)
-		iounmap((void *) hp->lba_regs);
+		iounmap(hp->lba_regs);
 }
 
 static void
=== include/asm-ia64/hw_irq.h 1.11 vs edited ==--- 1.11/include/asm-ia64/hw_irq.h	2004-04-12 10:54:30 -07:00
+++ edited/include/asm-ia64/hw_irq.h	2004-10-04 09:13:27 -07:00
@@ -78,8 +78,6 @@
 extern __u8 isa_irq_to_vector_map[16];
 #define isa_irq_to_vector(x)	isa_irq_to_vector_map[(x)]
 
-extern unsigned long ipi_base_addr;
-
 extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal interrupt controller */
 
 extern int assign_irq_vector (int irq);	/* allocate a free vector */
=== include/asm-ia64/io.h 1.19 vs edited ==--- 1.19/include/asm-ia64/io.h	2004-02-03 21:31:10 -08:00
+++ edited/include/asm-ia64/io.h	2004-10-05 03:45:50 -07:00
@@ -248,7 +248,7 @@
 }
 
 static inline void
-__outsl (unsigned long port, void *src, unsigned long count)
+__outsl (unsigned long port, const void *src, unsigned long count)
 {
 	const unsigned int *sp = src;
 
@@ -290,51 +290,51 @@
  * hopefully it'll stay that way).
  */
 static inline unsigned char
-___ia64_readb (void *addr)
+___ia64_readb (const volatile void __iomem *addr)
 {
-	return *(volatile unsigned char *)addr;
+	return *(volatile unsigned char __force *)addr;
 }
 
 static inline unsigned short
-___ia64_readw (void *addr)
+___ia64_readw (const volatile void __iomem *addr)
 {
-	return *(volatile unsigned short *)addr;
+	return *(volatile unsigned short __force *)addr;
 }
 
 static inline unsigned int
-___ia64_readl (void *addr)
+___ia64_readl (const volatile void __iomem *addr)
 {
-	return *(volatile unsigned int *) addr;
+	return *(volatile unsigned int __force *) addr;
 }
 
 static inline unsigned long
-___ia64_readq (void *addr)
+___ia64_readq (const volatile void __iomem *addr)
 {
-	return *(volatile unsigned long *) addr;
+	return *(volatile unsigned long __force *) addr;
 }
 
 static inline void
-__writeb (unsigned char val, void *addr)
+__writeb (unsigned char val, volatile void __iomem *addr)
 {
-	*(volatile unsigned char *) addr = val;
+	*(volatile unsigned char __force *) addr = val;
 }
 
 static inline void
-__writew (unsigned short val, void *addr)
+__writew (unsigned short val, volatile void __iomem *addr)
 {
-	*(volatile unsigned short *) addr = val;
+	*(volatile unsigned short __force *) addr = val;
 }
 
 static inline void
-__writel (unsigned int val, void *addr)
+__writel (unsigned int val, volatile void __iomem *addr)
 {
-	*(volatile unsigned int *) addr = val;
+	*(volatile unsigned int __force *) addr = val;
 }
 
 static inline void
-__writeq (unsigned long val, void *addr)
+__writeq (unsigned long val, volatile void __iomem *addr)
 {
-	*(volatile unsigned long *) addr = val;
+	*(volatile unsigned long __force *) addr = val;
 }
 
 #define __readb		platform_readb
@@ -346,14 +346,14 @@
 #define __readl_relaxed	platform_readl_relaxed
 #define __readq_relaxed	platform_readq_relaxed
 
-#define readb(a)	__readb((void *)(a))
-#define readw(a)	__readw((void *)(a))
-#define readl(a)	__readl((void *)(a))
-#define readq(a)	__readq((void *)(a))
-#define readb_relaxed(a)	__readb_relaxed((void *)(a))
-#define readw_relaxed(a)	__readw_relaxed((void *)(a))
-#define readl_relaxed(a)	__readl_relaxed((void *)(a))
-#define readq_relaxed(a)	__readq_relaxed((void *)(a))
+#define readb(a)	__readb((a))
+#define readw(a)	__readw((a))
+#define readl(a)	__readl((a))
+#define readq(a)	__readq((a))
+#define readb_relaxed(a)	__readb_relaxed((a))
+#define readw_relaxed(a)	__readw_relaxed((a))
+#define readl_relaxed(a)	__readl_relaxed((a))
+#define readq_relaxed(a)	__readq_relaxed((a))
 #define __raw_readb	readb
 #define __raw_readw	readw
 #define __raw_readl	readl
@@ -362,10 +362,10 @@
 #define __raw_readw_relaxed	readw_relaxed
 #define __raw_readl_relaxed	readl_relaxed
 #define __raw_readq_relaxed	readq_relaxed
-#define writeb(v,a)	__writeb((v), (void *) (a))
-#define writew(v,a)	__writew((v), (void *) (a))
-#define writel(v,a)	__writel((v), (void *) (a))
-#define writeq(v,a)	__writeq((v), (void *) (a))
+#define writeb(v,a)	__writeb((v), (a))
+#define writew(v,a)	__writew((v), (a))
+#define writel(v,a)	__writel((v), (a))
+#define writeq(v,a)	__writeq((v), (a))
 #define __raw_writeb	writeb
 #define __raw_writew	writew
 #define __raw_writel	writel
@@ -397,14 +397,14 @@
  *
  * On ia-64, we access the physical I/O memory space through the uncached kernel region.
  */
-static inline void *
+static inline void __iomem *
 ioremap (unsigned long offset, unsigned long size)
 {
-	return (void *) (__IA64_UNCACHED_OFFSET | (offset));
+	return (void __iomem *) (__IA64_UNCACHED_OFFSET | (offset));
 }
 
 static inline void
-iounmap (void *addr)
+iounmap (volatile void __iomem *addr)
 {
 }
 
@@ -415,17 +415,14 @@
 /*
  * String version of IO memory access ops:
  */
-extern void __ia64_memcpy_fromio (void *, unsigned long, long);
-extern void __ia64_memcpy_toio (unsigned long, void *, long);
-extern void __ia64_memset_c_io (unsigned long, unsigned long, long);
-
-#define memcpy_fromio(to,from,len) \
-  __ia64_memcpy_fromio((to),(unsigned long)(from),(len))
-#define memcpy_toio(to,from,len) \
-  __ia64_memcpy_toio((unsigned long)(to),(from),(len))
-#define memset_io(addr,c,len) \
-  __ia64_memset_c_io((unsigned long)(addr),0x0101010101010101UL*(u8)(c),(len))
-
+extern void __ia64_memcpy_fromio (void *, volatile void __iomem *, long);
+extern void __ia64_memcpy_toio (volatile void __iomem *, void *, long);
+extern void __ia64_memset_c_io (volatile void __iomem *, unsigned long, long);
+
+#define memcpy_fromio(to,from,len)	__ia64_memcpy_fromio((to), (from),(len))
+#define memcpy_toio(to,from,len)	__ia64_memcpy_toio((to),(from),(len))
+#define memset_io(addr,c,len)		__ia64_memset_c_io((addr), 0x0101010101010101UL*(u8)(c), \
+							   (len))
 
 #define dma_cache_inv(_start,_size)             do { } while (0)
 #define dma_cache_wback(_start,_size)           do { } while (0)
=== include/asm-ia64/iosapic.h 1.16 vs edited ==--- 1.16/include/asm-ia64/iosapic.h	2004-09-09 15:25:26 -07:00
+++ edited/include/asm-ia64/iosapic.h	2004-10-04 09:08:37 -07:00
@@ -53,19 +53,19 @@
 
 #define NR_IOSAPICS			256
 
-static inline unsigned int iosapic_read(char *iosapic, unsigned int reg)
+static inline unsigned int iosapic_read(char __iomem *iosapic, unsigned int reg)
 {
 	writel(reg, iosapic + IOSAPIC_REG_SELECT);
 	return readl(iosapic + IOSAPIC_WINDOW);
 }
 
-static inline void iosapic_write(char *iosapic, unsigned int reg, u32 val)
+static inline void iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
 {
 	writel(reg, iosapic + IOSAPIC_REG_SELECT);
 	writel(val, iosapic + IOSAPIC_WINDOW);
 }
 
-static inline void iosapic_eoi(char *iosapic, u32 vector)
+static inline void iosapic_eoi(char __iomem *iosapic, u32 vector)
 {
 	writel(vector, iosapic + IOSAPIC_EOI);
 }
@@ -87,7 +87,7 @@
 					   u16 eid, u16 id,
 					   unsigned long polarity,
 					   unsigned long trigger);
-extern unsigned int iosapic_version (char *addr);
+extern unsigned int iosapic_version (char __iomem *addr);
 
 extern void iosapic_pci_fixup (int);
 #ifdef CONFIG_NUMA
=== include/asm-ia64/smp.h 1.18 vs edited ==--- 1.18/include/asm-ia64/smp.h	2004-06-21 13:44:12 -07:00
+++ edited/include/asm-ia64/smp.h	2004-10-04 09:13:06 -07:00
@@ -39,7 +39,7 @@
 extern char no_int_routing __devinitdata;
 
 extern cpumask_t cpu_online_map;
-extern unsigned long ipi_base_addr;
+extern void __iomem *ipi_base_addr;
 extern unsigned char smp_int_redirect;
 
 extern volatile int ia64_cpu_to_sapicid[];
@@ -73,21 +73,21 @@
 min_xtp (void)
 {
 	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
-		writeb(0x00, ipi_base_addr | XTP_OFFSET); /* XTP to min */
+		writeb(0x00, ipi_base_addr + XTP_OFFSET); /* XTP to min */
 }
 
 static inline void
 normal_xtp (void)
 {
 	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
-		writeb(0x08, ipi_base_addr | XTP_OFFSET); /* XTP normal */
+		writeb(0x08, ipi_base_addr + XTP_OFFSET); /* XTP normal */
 }
 
 static inline void
 max_xtp (void)
 {
 	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
-		writeb(0x0f, ipi_base_addr | XTP_OFFSET); /* Set XTP to max */
+		writeb(0x0f, ipi_base_addr + XTP_OFFSET); /* Set XTP to max */
 }
 
 static inline unsigned int
