From: Mike Rapoport <rppt@linux.ibm.com>
Date: Wed, 24 Apr 2019 10:35:50 +0000
Subject: [PATCH] memblock: make keeping memblock memory opt-in rather than opt-out
Message-Id: <1556102150-32517-1-git-send-email-rppt@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mips@vger.kernel.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Mike Rapoport <rppt@linux.ibm.com>, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Catalin Marinas <catalin.marinas@arm.com>, James Hogan <jhogan@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Will Deacon <will.deacon@arm.com>, linux-m68k@lists.linux-m68k.org, Borislav Petkov <bp@alien8.de>, nios2-dev@lists.rocketboards.org, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Richard Kuo <rkuo@codeaurora.org>, Paul Burton <paul.burton@mips.com>, Eric Biederman <ebiederm@xmission.com>, linux-hexagon@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Ley Foon Tan <lftan@altera.com>, linuxppc-dev@lists.ozlabs.org

Most architectures do not need the memblock memory after the page allocator
is initialized, but only few enable ARCH_DISCARD_MEMBLOCK in the
arch Kconfig.

Replacing ARCH_DISCARD_MEMBLOCK with ARCH_KEEP_MEMBLOCK and inverting the
logic makes it clear which architectures actually use memblock after system
initialization and skips the necessity to add ARCH_DISCARD_MEMBLOCK to the
architectures that are still missing that option.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/arm/Kconfig         |  2 +-
 arch/arm64/Kconfig       |  1 +
 arch/hexagon/Kconfig     |  1 -
 arch/ia64/Kconfig        |  1 -
 arch/m68k/Kconfig        |  1 -
 arch/mips/Kconfig        |  1 -
 arch/nios2/Kconfig       |  1 -
 arch/powerpc/Kconfig     |  1 +
 arch/s390/Kconfig        |  1 +
 arch/sh/Kconfig          |  1 -
 arch/x86/Kconfig         |  1 -
 include/linux/memblock.h |  3 ++-
 kernel/kexec_file.c      | 16 ++++++++--------
 mm/Kconfig               |  2 +-
 mm/memblock.c            |  6 +++---
 mm/page_alloc.c          |  3 +--
 16 files changed, 19 insertions(+), 23 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 850b480..7073436 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -4,7 +4,6 @@ config ARM
 	default y
 	select ARCH_32BIT_OFF_T
 	select ARCH_CLOCKSOURCE_DATA
-	select ARCH_DISCARD_MEMBLOCK if !HAVE_ARCH_PFN_VALID && !KEXEC
 	select ARCH_HAS_DEBUG_VIRTUAL if MMU
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
 	select ARCH_HAS_ELF_RANDOMIZE
@@ -21,6 +20,7 @@ config ARM
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_HAVE_CUSTOM_GPIO_H
 	select ARCH_HAS_GCOV_PROFILE_ALL
+	select ARCH_KEEP_MEMBLOCK if HAVE_ARCH_PFN_VALID || KEXEC
 	select ARCH_MIGHT_HAVE_PC_PARPORT
 	select ARCH_NO_SG_CHAIN if !ARM_HAS_SG_CHAIN
 	select ARCH_OPTIONAL_KERNEL_RWX if ARCH_HAS_STRICT_KERNEL_RWX
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 7e34b9e..d71f043 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -58,6 +58,7 @@ config ARM64
 	select ARCH_INLINE_SPIN_UNLOCK_BH if !PREEMPT
 	select ARCH_INLINE_SPIN_UNLOCK_IRQ if !PREEMPT
 	select ARCH_INLINE_SPIN_UNLOCK_IRQRESTORE if !PREEMPT
+	select ARCH_KEEP_MEMBLOCK
 	select ARCH_USE_CMPXCHG_LOCKREF
 	select ARCH_USE_QUEUED_RWLOCKS
 	select ARCH_USE_QUEUED_SPINLOCKS
diff --git a/arch/hexagon/Kconfig b/arch/hexagon/Kconfig
index ac44168..bbe3819 100644
--- a/arch/hexagon/Kconfig
+++ b/arch/hexagon/Kconfig
@@ -22,7 +22,6 @@ config HEXAGON
 	select GENERIC_IRQ_SHOW
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_TRACEHOOK
-	select ARCH_DISCARD_MEMBLOCK
 	select NEED_SG_DMA_LENGTH
 	select NO_IOPORT_MAP
 	select GENERIC_IOMAP
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 8d7396b..bd51d3b 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -33,7 +33,6 @@ config IA64
 	select ARCH_HAS_DMA_COHERENT_TO_PFN if SWIOTLB
 	select ARCH_HAS_SYNC_DMA_FOR_CPU if SWIOTLB
 	select VIRT_TO_BUS
-	select ARCH_DISCARD_MEMBLOCK
 	select GENERIC_IRQ_PROBE
 	select GENERIC_PENDING_IRQ if SMP
 	select GENERIC_IRQ_SHOW
diff --git a/arch/m68k/Kconfig b/arch/m68k/Kconfig
index b542064..7d1e5d9 100644
--- a/arch/m68k/Kconfig
+++ b/arch/m68k/Kconfig
@@ -27,7 +27,6 @@ config M68K
 	select MODULES_USE_ELF_RELA
 	select OLD_SIGSUSPEND3
 	select OLD_SIGACTION
-	select ARCH_DISCARD_MEMBLOCK
 
 config CPU_BIG_ENDIAN
 	def_bool y
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 4a5f5b0..8b9298b 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -5,7 +5,6 @@ config MIPS
 	select ARCH_32BIT_OFF_T if !64BIT
 	select ARCH_BINFMT_ELF_STATE if MIPS_FP_SUPPORT
 	select ARCH_CLOCKSOURCE_DATA
-	select ARCH_DISCARD_MEMBLOCK
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
diff --git a/arch/nios2/Kconfig b/arch/nios2/Kconfig
index 4ef15a6..dc4239c 100644
--- a/arch/nios2/Kconfig
+++ b/arch/nios2/Kconfig
@@ -23,7 +23,6 @@ config NIOS2
 	select SPARSE_IRQ
 	select USB_ARCH_HAS_HCD if USB_SUPPORT
 	select CPU_NO_EFFICIENT_FFS
-	select ARCH_DISCARD_MEMBLOCK
 
 config GENERIC_CSUM
 	def_bool y
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 2d0be82..39877b9 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -143,6 +143,7 @@ config PPC
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
 	select ARCH_HAS_ZONE_DEVICE		if PPC_BOOK3S_64
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
+	select ARCH_KEEP_MEMBLOCK
 	select ARCH_MIGHT_HAVE_PC_PARPORT
 	select ARCH_MIGHT_HAVE_PC_SERIO
 	select ARCH_OPTIONAL_KERNEL_RWX		if ARCH_HAS_STRICT_KERNEL_RWX
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index b6e3d06..3eaf660 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -106,6 +106,7 @@ config S390
 	select ARCH_INLINE_WRITE_UNLOCK_BH
 	select ARCH_INLINE_WRITE_UNLOCK_IRQ
 	select ARCH_INLINE_WRITE_UNLOCK_IRQRESTORE
+	select ARCH_KEEP_MEMBLOCK
 	select ARCH_SAVE_PAGE_KEYS if HIBERNATION
 	select ARCH_SUPPORTS_ATOMIC_RMW
 	select ARCH_SUPPORTS_NUMA_BALANCING
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index b1c91ea..418e928 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -10,7 +10,6 @@ config SUPERH
 	select DMA_DECLARE_COHERENT
 	select HAVE_IDE if HAS_IOPORT_MAP
 	select HAVE_MEMBLOCK_NODE_MAP
-	select ARCH_DISCARD_MEMBLOCK
 	select HAVE_OPROFILE
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_PERF_EVENTS
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 62fc3fd..80bc582 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -48,7 +48,6 @@ config X86
 	select ARCH_32BIT_OFF_T			if X86_32
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_CLOCKSOURCE_INIT
-	select ARCH_DISCARD_MEMBLOCK
 	select ARCH_HAS_ACPI_TABLE_UPGRADE	if ACPI
 	select ARCH_HAS_DEBUG_VIRTUAL
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 294d5d8..6ba69ba 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -96,13 +96,14 @@ struct memblock {
 extern struct memblock memblock;
 extern int memblock_debug;
 
-#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
+#ifndef CONFIG_ARCH_KEEP_MEMBLOCK
 #define __init_memblock __meminit
 #define __initdata_memblock __meminitdata
 void memblock_discard(void);
 #else
 #define __init_memblock
 #define __initdata_memblock
+static inline void memblock_discard(void) {}
 #endif
 
 #define memblock_dbg(fmt, ...) \
diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
index f1d0e00..623b022 100644
--- a/kernel/kexec_file.c
+++ b/kernel/kexec_file.c
@@ -500,13 +500,7 @@ static int locate_mem_hole_callback(struct resource *res, void *arg)
 	return locate_mem_hole_bottom_up(start, end, kbuf);
 }
 
-#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
-static int kexec_walk_memblock(struct kexec_buf *kbuf,
-			       int (*func)(struct resource *, void *))
-{
-	return 0;
-}
-#else
+#ifdef CONFIG_ARCH_KEEP_MEMBLOCK
 static int kexec_walk_memblock(struct kexec_buf *kbuf,
 			       int (*func)(struct resource *, void *))
 {
@@ -550,6 +544,12 @@ static int kexec_walk_memblock(struct kexec_buf *kbuf,
 
 	return ret;
 }
+#else
+static int kexec_walk_memblock(struct kexec_buf *kbuf,
+			       int (*func)(struct resource *, void *))
+{
+	return 0;
+}
 #endif
 
 /**
@@ -589,7 +589,7 @@ int kexec_locate_mem_hole(struct kexec_buf *kbuf)
 	if (kbuf->mem != KEXEC_BUF_MEM_UNKNOWN)
 		return 0;
 
-	if (IS_ENABLED(CONFIG_ARCH_DISCARD_MEMBLOCK))
+	if (!IS_ENABLED(CONFIG_ARCH_KEEP_MEMBLOCK))
 		ret = kexec_walk_resources(kbuf, locate_mem_hole_callback);
 	else
 		ret = kexec_walk_memblock(kbuf, locate_mem_hole_callback);
diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb..1e1c6ce 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -136,7 +136,7 @@ config HAVE_MEMBLOCK_PHYS_MAP
 config HAVE_GENERIC_GUP
 	bool
 
-config ARCH_DISCARD_MEMBLOCK
+config ARCH_KEEP_MEMBLOCK
 	bool
 
 config MEMORY_ISOLATION
diff --git a/mm/memblock.c b/mm/memblock.c
index e7665cf..d6b5755 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -94,7 +94,7 @@
  * :c:func:`mem_init` function frees all the memory to the buddy page
  * allocator.
  *
- * If an architecure enables %CONFIG_ARCH_DISCARD_MEMBLOCK, the
+ * Unless an architecure enables %CONFIG_ARCH_KEEP_MEMBLOCK, the
  * memblock data structures will be discarded after the system
  * initialization compltes.
  */
@@ -375,7 +375,7 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
 	}
 }
 
-#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
+#ifndef CONFIG_ARCH_KEEP_MEMBLOCK
 /**
  * memblock_discard - discard memory and reserved arrays if they were allocated
  */
@@ -1923,7 +1923,7 @@ unsigned long __init memblock_free_all(void)
 	return pages;
 }
 
-#if defined(CONFIG_DEBUG_FS) && !defined(CONFIG_ARCH_DISCARD_MEMBLOCK)
+#if defined(CONFIG_DEBUG_FS) && defined(CONFIG_ARCH_KEEP_MEMBLOCK)
 
 static int memblock_debug_show(struct seq_file *m, void *private)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c6ce20a..a1825e9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1831,10 +1831,9 @@ void __init page_alloc_init_late(void)
 	/* Reinit limits that are based on free pages after the kernel is up */
 	files_maxfiles_init();
 #endif
-#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
+
 	/* Discard memblock private memory */
 	memblock_discard();
-#endif
 
 	for_each_populated_zone(zone)
 		set_zone_contiguous(zone);
-- 
2.7.4
