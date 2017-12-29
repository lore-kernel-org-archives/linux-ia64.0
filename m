From: Christoph Hellwig <hch@lst.de>
Date: Fri, 29 Dec 2017 08:18:05 +0000
Subject: [PATCH 01/67] x86: remove X86_PPRO_FENCE
Message-Id: <20171229081911.2802-2-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
In-Reply-To: <20171229081911.2802-1-hch-jcswGhMUV9g@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org

There were only a few Pentium Pro multiprocessors systems where this
errata applied. They are more than 20 years old now, and we've slowly
dropped places where put the workarounds in and discuraged anyone
from enabling the workaround.

Get rid of it for good.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/x86/Kconfig.cpu                        | 13 -------------
 arch/x86/entry/vdso/vdso32/vclock_gettime.c |  2 --
 arch/x86/include/asm/barrier.h              | 30 -----------------------------
 arch/x86/include/asm/io.h                   | 15 ---------------
 arch/x86/kernel/pci-nommu.c                 | 19 ------------------
 arch/x86/um/asm/barrier.h                   |  4 ----
 6 files changed, 83 deletions(-)

diff --git a/arch/x86/Kconfig.cpu b/arch/x86/Kconfig.cpu
index 65a9a4716e34..f0c5ef578153 100644
--- a/arch/x86/Kconfig.cpu
+++ b/arch/x86/Kconfig.cpu
@@ -315,19 +315,6 @@ config X86_L1_CACHE_SHIFT
 	default "4" if MELAN || M486 || MGEODEGX1
 	default "5" if MWINCHIP3D || MWINCHIPC6 || MCRUSOE || MEFFICEON || MCYRIXIII || MK6 || MPENTIUMIII || MPENTIUMII || M686 || M586MMX || M586TSC || M586 || MVIAC3_2 || MGEODE_LX
 
-config X86_PPRO_FENCE
-	bool "PentiumPro memory ordering errata workaround"
-	depends on M686 || M586MMX || M586TSC || M586 || M486 || MGEODEGX1
-	---help---
-	  Old PentiumPro multiprocessor systems had errata that could cause
-	  memory operations to violate the x86 ordering standard in rare cases.
-	  Enabling this option will attempt to work around some (but not all)
-	  occurrences of this problem, at the cost of much heavier spinlock and
-	  memory barrier operations.
-
-	  If unsure, say n here. Even distro kernels should think twice before
-	  enabling this: there are few systems, and an unlikely bug.
-
 config X86_F00F_BUG
 	def_bool y
 	depends on M586MMX || M586TSC || M586 || M486
diff --git a/arch/x86/entry/vdso/vdso32/vclock_gettime.c b/arch/x86/entry/vdso/vdso32/vclock_gettime.c
index 7780bbfb06ef..9242b28418d5 100644
--- a/arch/x86/entry/vdso/vdso32/vclock_gettime.c
+++ b/arch/x86/entry/vdso/vdso32/vclock_gettime.c
@@ -5,8 +5,6 @@
 #undef CONFIG_OPTIMIZE_INLINING
 #endif
 
-#undef CONFIG_X86_PPRO_FENCE
-
 #ifdef CONFIG_X86_64
 
 /*
diff --git a/arch/x86/include/asm/barrier.h b/arch/x86/include/asm/barrier.h
index 7fb336210e1b..aa0f7449d4a4 100644
--- a/arch/x86/include/asm/barrier.h
+++ b/arch/x86/include/asm/barrier.h
@@ -24,11 +24,7 @@
 #define wmb()	asm volatile("sfence" ::: "memory")
 #endif
 
-#ifdef CONFIG_X86_PPRO_FENCE
-#define dma_rmb()	rmb()
-#else
 #define dma_rmb()	barrier()
-#endif
 #define dma_wmb()	barrier()
 
 #ifdef CONFIG_X86_32
@@ -40,30 +36,6 @@
 #define __smp_wmb()	barrier()
 #define __smp_store_mb(var, value) do { (void)xchg(&var, value); } while (0)
 
-#if defined(CONFIG_X86_PPRO_FENCE)
-
-/*
- * For this option x86 doesn't have a strong TSO memory
- * model and we should fall back to full barriers.
- */
-
-#define __smp_store_release(p, v)					\
-do {									\
-	compiletime_assert_atomic_type(*p);				\
-	__smp_mb();							\
-	WRITE_ONCE(*p, v);						\
-} while (0)
-
-#define __smp_load_acquire(p)						\
-({									\
-	typeof(*p) ___p1 = READ_ONCE(*p);				\
-	compiletime_assert_atomic_type(*p);				\
-	__smp_mb();							\
-	___p1;								\
-})
-
-#else /* regular x86 TSO memory ordering */
-
 #define __smp_store_release(p, v)					\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
@@ -79,8 +51,6 @@ do {									\
 	___p1;								\
 })
 
-#endif
-
 /* Atomic operations are already serializing on x86 */
 #define __smp_mb__before_atomic()	barrier()
 #define __smp_mb__after_atomic()	barrier()
diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index 95e948627fd0..f6e5b9375d8c 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -232,21 +232,6 @@ extern void set_iounmap_nonlazy(void);
  */
 #define __ISA_IO_base ((char __iomem *)(PAGE_OFFSET))
 
-/*
- *	Cache management
- *
- *	This needed for two cases
- *	1. Out of order aware processors
- *	2. Accidentally out of order processors (PPro errata #51)
- */
-
-static inline void flush_write_buffers(void)
-{
-#if defined(CONFIG_X86_PPRO_FENCE)
-	asm volatile("lock; addl $0,0(%%esp)": : :"memory");
-#endif
-}
-
 #endif /* __KERNEL__ */
 
 extern void native_io_delay(void);
diff --git a/arch/x86/kernel/pci-nommu.c b/arch/x86/kernel/pci-nommu.c
index b0caae27e1b7..c78df78b5ccd 100644
--- a/arch/x86/kernel/pci-nommu.c
+++ b/arch/x86/kernel/pci-nommu.c
@@ -37,7 +37,6 @@ static dma_addr_t nommu_map_page(struct device *dev, struct page *page,
 	WARN_ON(size = 0);
 	if (!check_addr("map_single", dev, bus, size))
 		return NOMMU_MAPPING_ERROR;
-	flush_write_buffers();
 	return bus;
 }
 
@@ -72,25 +71,9 @@ static int nommu_map_sg(struct device *hwdev, struct scatterlist *sg,
 			return 0;
 		s->dma_length = s->length;
 	}
-	flush_write_buffers();
 	return nents;
 }
 
-static void nommu_sync_single_for_device(struct device *dev,
-			dma_addr_t addr, size_t size,
-			enum dma_data_direction dir)
-{
-	flush_write_buffers();
-}
-
-
-static void nommu_sync_sg_for_device(struct device *dev,
-			struct scatterlist *sg, int nelems,
-			enum dma_data_direction dir)
-{
-	flush_write_buffers();
-}
-
 static int nommu_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
 	return dma_addr = NOMMU_MAPPING_ERROR;
@@ -101,8 +84,6 @@ const struct dma_map_ops nommu_dma_ops = {
 	.free			= dma_generic_free_coherent,
 	.map_sg			= nommu_map_sg,
 	.map_page		= nommu_map_page,
-	.sync_single_for_device = nommu_sync_single_for_device,
-	.sync_sg_for_device	= nommu_sync_sg_for_device,
 	.is_phys		= 1,
 	.mapping_error		= nommu_mapping_error,
 	.dma_supported		= x86_dma_supported,
diff --git a/arch/x86/um/asm/barrier.h b/arch/x86/um/asm/barrier.h
index b7d73400ea29..f31e5d903161 100644
--- a/arch/x86/um/asm/barrier.h
+++ b/arch/x86/um/asm/barrier.h
@@ -30,11 +30,7 @@
 
 #endif /* CONFIG_X86_32 */
 
-#ifdef CONFIG_X86_PPRO_FENCE
-#define dma_rmb()	rmb()
-#else /* CONFIG_X86_PPRO_FENCE */
 #define dma_rmb()	barrier()
-#endif /* CONFIG_X86_PPRO_FENCE */
 #define dma_wmb()	barrier()
 
 #include <asm-generic/barrier.h>
-- 
2.14.2

