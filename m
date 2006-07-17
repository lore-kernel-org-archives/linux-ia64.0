From: Keith Owens <kaos@sgi.com>
Date: Mon, 17 Jul 2006 05:41:59 +0000
Subject: [patch 2.6.18-rc1] sparse cleanups
Message-Id: <14835.1153114919@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix some sparse warnings on ia64.  Large constants that should be long
instead of int.  Use NULL instead of 0.  Add some missing __iomem
casts.  Replace a non-C99 structure assignment.

Signed-off-by: Keith Owens <kaos@sgi.com>

---
 arch/ia64/kernel/efi.c            |    6 +++---
 arch/ia64/mm/ioremap.c            |    6 +++---
 arch/ia64/sn/kernel/xpc_main.c    |    2 +-
 arch/ia64/sn/pci/tioce_provider.c |    6 +++---
 include/asm-ia64/sn/xpc.h         |    4 ++--
 include/asm-ia64/system.h         |    2 +-
 6 files changed, 13 insertions(+), 13 deletions(-)

Index: linux/arch/ia64/kernel/efi.c
=================================--- linux.orig/arch/ia64/kernel/efi.c
+++ linux/arch/ia64/kernel/efi.c
@@ -632,7 +632,7 @@ kern_memory_descriptor (unsigned long ph
 		if (phys_addr - md->start < (md->num_pages << EFI_PAGE_SHIFT))
 			 return md;
 	}
-	return 0;
+	return NULL;
 }
 
 static efi_memory_desc_t *
@@ -652,7 +652,7 @@ efi_memory_descriptor (unsigned long phy
 		if (phys_addr - md->phys_addr < (md->num_pages << EFI_PAGE_SHIFT))
 			 return md;
 	}
-	return 0;
+	return NULL;
 }
 
 u32
@@ -923,7 +923,7 @@ find_memmap_space (void)
 void
 efi_memmap_init(unsigned long *s, unsigned long *e)
 {
-	struct kern_memdesc *k, *prev = 0;
+	struct kern_memdesc *k, *prev = NULL;
 	u64	contig_low=0, contig_high=0;
 	u64	as, ae, lim;
 	void *efi_map_start, *efi_map_end, *p, *q;
Index: linux/arch/ia64/mm/ioremap.c
=================================--- linux.orig/arch/ia64/mm/ioremap.c
+++ linux/arch/ia64/mm/ioremap.c
@@ -32,7 +32,7 @@ ioremap (unsigned long offset, unsigned 
 	 */
 	attr = kern_mem_attribute(offset, size);
 	if (attr & EFI_MEMORY_WB)
-		return phys_to_virt(offset);
+		return (void __iomem *) phys_to_virt(offset);
 	else if (attr & EFI_MEMORY_UC)
 		return __ioremap(offset, size);
 
@@ -43,7 +43,7 @@ ioremap (unsigned long offset, unsigned 
 	gran_base = GRANULEROUNDDOWN(offset);
 	gran_size = GRANULEROUNDUP(offset + size) - gran_base;
 	if (efi_mem_attribute(gran_base, gran_size) & EFI_MEMORY_WB)
-		return phys_to_virt(offset);
+		return (void __iomem *) phys_to_virt(offset);
 
 	return __ioremap(offset, size);
 }
@@ -53,7 +53,7 @@ void __iomem *
 ioremap_nocache (unsigned long offset, unsigned long size)
 {
 	if (kern_mem_attribute(offset, size) & EFI_MEMORY_WB)
-		return 0;
+		return NULL;
 
 	return __ioremap(offset, size);
 }
Index: linux/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux.orig/arch/ia64/sn/kernel/xpc_main.c
+++ linux/arch/ia64/sn/kernel/xpc_main.c
@@ -480,7 +480,7 @@ xpc_activating(void *__partid)
 	partid_t partid = (u64) __partid;
 	struct xpc_partition *part = &xpc_partitions[partid];
 	unsigned long irq_flags;
-	struct sched_param param = { sched_priority: MAX_RT_PRIO - 1 };
+	struct sched_param param = { .sched_priority = MAX_RT_PRIO - 1 };
 	int ret;
 
 
Index: linux/arch/ia64/sn/pci/tioce_provider.c
=================================--- linux.orig/arch/ia64/sn/pci/tioce_provider.c
+++ linux/arch/ia64/sn/pci/tioce_provider.c
@@ -74,7 +74,7 @@ tioce_mmr_war_pre(struct tioce_kernel *k
 		else
 			mmr_war_offset = 0x158;
 
-		readq_relaxed((void *)(mmr_base + mmr_war_offset));
+		readq_relaxed((void __iomem *)(mmr_base + mmr_war_offset));
 	}
 }
 
@@ -92,8 +92,8 @@ tioce_mmr_war_post(struct tioce_kernel *
 
 	if (mmr_offset < 0x45000) {
 		if (mmr_offset = 0x100)
-			readq_relaxed((void *)(mmr_base + 0x38));
-		readq_relaxed((void *)(mmr_base + 0xb050));
+			readq_relaxed((void __iomem *)(mmr_base + 0x38));
+		readq_relaxed((void __iomem *)(mmr_base + 0xb050));
 	}
 }
 
Index: linux/include/asm-ia64/sn/xpc.h
=================================--- linux.orig/include/asm-ia64/sn/xpc.h
+++ linux/include/asm-ia64/sn/xpc.h
@@ -1124,8 +1124,8 @@ xpc_notify_IRQ_send_local(struct xpc_cha
 #define XPC_GET_IPI_FLAGS(_amo, _c)	((u8) (((_amo) >> ((_c) * 8)) & 0xff))
 #define XPC_SET_IPI_FLAGS(_amo, _c, _f)	(_amo) |= ((u64) (_f) << ((_c) * 8))
 
-#define	XPC_ANY_OPENCLOSE_IPI_FLAGS_SET(_amo) ((_amo) & 0x0f0f0f0f0f0f0f0f)
-#define XPC_ANY_MSG_IPI_FLAGS_SET(_amo)       ((_amo) & 0x1010101010101010)
+#define	XPC_ANY_OPENCLOSE_IPI_FLAGS_SET(_amo) ((_amo) & __IA64_UL_CONST(0x0f0f0f0f0f0f0f0f))
+#define XPC_ANY_MSG_IPI_FLAGS_SET(_amo)       ((_amo) & __IA64_UL_CONST(0x1010101010101010))
 
 
 static inline void
Index: linux/include/asm-ia64/system.h
=================================--- linux.orig/include/asm-ia64/system.h
+++ linux/include/asm-ia64/system.h
@@ -24,7 +24,7 @@
  * 0xa000000000000000+2*PERCPU_PAGE_SIZE
  * - 0xa000000000000000+3*PERCPU_PAGE_SIZE remain unmapped (guard page)
  */
-#define KERNEL_START		 (GATE_ADDR+0x100000000)
+#define KERNEL_START		 (GATE_ADDR+__IA64_UL_CONST(0x100000000))
 #define PERCPU_ADDR		(-PERCPU_PAGE_SIZE)
 
 #ifndef __ASSEMBLY__


