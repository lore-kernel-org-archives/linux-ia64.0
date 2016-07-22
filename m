From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Fri, 22 Jul 2016 21:24:38 +0000
Subject: [RFC v3 04/13] sections.h: guard against asm and linker script
Message-Id: <1469222687-1600-5-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel.org, tony.luck@intel.com, akpm@linux-foun

We'll later add some generic helpers for use in the linker scripts
and some generic asm code for all architectures. To do that we'll
first need to guard against linker script and asm code.

On x86 uaccess.h has a struct which is used as part of a section,
move that to sections.h as we otherwise have no need for uaccess.h
on sections.h

v3: new to this series, needed due to the collateral of the split of
    tables.h into 3 files: tables.h, ranges.h and sections.h, the
    need to guard sections.h is due to the fact that sections.h is
    already included and expanded considerably in certain architectures.

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 arch/arm/include/asm/sections.h      |  2 ++
 arch/blackfin/include/asm/sections.h |  4 ++++
 arch/ia64/include/asm/sections.h     |  7 +++++--
 arch/powerpc/include/asm/sections.h  | 11 ++++++-----
 arch/sh/include/asm/sections.h       |  2 ++
 arch/sparc/include/asm/sections.h    |  4 ++++
 arch/tile/include/asm/sections.h     |  4 ++++
 arch/x86/include/asm/sections.h      | 23 ++++++++++++++++++++++-
 arch/x86/include/asm/uaccess.h       | 18 +-----------------
 include/asm-generic/sections.h       |  4 ++++
 10 files changed, 54 insertions(+), 25 deletions(-)

diff --git a/arch/arm/include/asm/sections.h b/arch/arm/include/asm/sections.h
index 803bbf2b20b8..21830b9b3b6b 100644
--- a/arch/arm/include/asm/sections.h
+++ b/arch/arm/include/asm/sections.h
@@ -3,6 +3,8 @@
 
 #include <asm-generic/sections.h>
 
+#if defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__)
 extern char _exiprom[];
+#endif /* defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__) */
 
 #endif	/* _ASM_ARM_SECTIONS_H */
diff --git a/arch/blackfin/include/asm/sections.h b/arch/blackfin/include/asm/sections.h
index fbd408475725..d2abd7a585dd 100644
--- a/arch/blackfin/include/asm/sections.h
+++ b/arch/blackfin/include/asm/sections.h
@@ -7,6 +7,8 @@
 #ifndef _BLACKFIN_SECTIONS_H
 #define _BLACKFIN_SECTIONS_H
 
+#if defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__)
+
 /* only used when MTD_UCLINUX */
 extern unsigned long memory_mtd_start, memory_mtd_end, mtd_size;
 
@@ -62,6 +64,8 @@ static inline int arch_is_kernel_data(unsigned long addr)
 }
 #define arch_is_kernel_data(addr) arch_is_kernel_data(addr)
 
+#endif /* defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__) */
+
 #include <asm-generic/sections.h>
 
 #endif
diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
index 2ab2003698ef..3318e3916122 100644
--- a/arch/ia64/include/asm/sections.h
+++ b/arch/ia64/include/asm/sections.h
@@ -6,9 +6,12 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
+#include <asm-generic/sections.h>
+
+#if defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__)
+
 #include <linux/elf.h>
 #include <linux/uaccess.h>
-#include <asm-generic/sections.h>
 
 extern char __phys_per_cpu_start[];
 #ifdef	CONFIG_SMP
@@ -37,6 +40,6 @@ static inline void *dereference_function_descriptor(void *ptr)
 	return ptr;
 }
 
+#endif /* defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__) */
 
 #endif /* _ASM_IA64_SECTIONS_H */
-
diff --git a/arch/powerpc/include/asm/sections.h b/arch/powerpc/include/asm/sections.h
index 7dc006b58369..f226b5bcd27c 100644
--- a/arch/powerpc/include/asm/sections.h
+++ b/arch/powerpc/include/asm/sections.h
@@ -1,11 +1,12 @@
 #ifndef _ASM_POWERPC_SECTIONS_H
 #define _ASM_POWERPC_SECTIONS_H
-#ifdef __KERNEL__
 
-#include <linux/elf.h>
-#include <linux/uaccess.h>
 #include <asm-generic/sections.h>
 
+#if defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__)
+
+#include <linux/elf.h>
+#include <linux/uaccess.h>
 #ifdef __powerpc64__
 
 extern char __start_interrupts[];
@@ -75,7 +76,7 @@ static inline void *dereference_function_descriptor(void *ptr)
 }
 #endif /* PPC64_ELF_ABI_v1 */
 
-#endif
+#endif /* __powerpc64__ */
+#endif /* defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__) */
 
-#endif /* __KERNEL__ */
 #endif	/* _ASM_POWERPC_SECTIONS_H */
diff --git a/arch/sh/include/asm/sections.h b/arch/sh/include/asm/sections.h
index 7a99e6af6372..ad4f9cbd861d 100644
--- a/arch/sh/include/asm/sections.h
+++ b/arch/sh/include/asm/sections.h
@@ -3,9 +3,11 @@
 
 #include <asm-generic/sections.h>
 
+#if defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__)
 extern long __machvec_start, __machvec_end;
 extern char __uncached_start, __uncached_end;
 extern char __start_eh_frame[], __stop_eh_frame[];
+#endif /* defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__) */
 
 #endif /* __ASM_SH_SECTIONS_H */
 
diff --git a/arch/sparc/include/asm/sections.h b/arch/sparc/include/asm/sections.h
index f300d1a9b2b6..b07a2380863e 100644
--- a/arch/sparc/include/asm/sections.h
+++ b/arch/sparc/include/asm/sections.h
@@ -4,10 +4,14 @@
 /* nothing to see, move along */
 #include <asm-generic/sections.h>
 
+#if defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__)
+
 /* sparc entry point */
 extern char _start[];
 
 extern char __leon_1insn_patch[];
 extern char __leon_1insn_patch_end[];
 
+#endif /* defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__) */
+
 #endif
diff --git a/arch/tile/include/asm/sections.h b/arch/tile/include/asm/sections.h
index 86a746243dc8..f9cce7c6d8ba 100644
--- a/arch/tile/include/asm/sections.h
+++ b/arch/tile/include/asm/sections.h
@@ -19,6 +19,8 @@
 
 #include <asm-generic/sections.h>
 
+#if defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__)
+
 /* Write-once data is writable only till the end of initialization. */
 extern char __w1data_begin[], __w1data_end[];
 
@@ -44,4 +46,6 @@ static inline int arch_is_kernel_data(unsigned long addr)
 		addr < (unsigned long)_end;
 }
 
+#endif /* defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__) */
+
 #endif /* _ASM_TILE_SECTIONS_H */
diff --git a/arch/x86/include/asm/sections.h b/arch/x86/include/asm/sections.h
index 13b6cdd0af57..84c7044c82bf 100644
--- a/arch/x86/include/asm/sections.h
+++ b/arch/x86/include/asm/sections.h
@@ -2,13 +2,34 @@
 #define _ASM_X86_SECTIONS_H
 
 #include <asm-generic/sections.h>
-#include <asm/uaccess.h>
+
+#if defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__)
 
 extern char __brk_base[], __brk_limit[];
+
+/*
+ * The exception table consists of triples of addresses relative to the
+ * exception table entry itself. The first address is of an instruction
+ * that is allowed to fault, the second is the target at which the program
+ * should continue. The third is a handler function to deal with the fault
+ * caused by the instruction in the first field.
+ *
+ * All the routines below use bits of fixup code that are out of line
+ * with the main instruction path.  This means when everything is well,
+ * we don't even have to jump over them.  Further, they do not intrude
+ * on our cache or tlb entries.
+ */
+
+struct exception_table_entry {
+	int insn, fixup, handler;
+};
+
 extern struct exception_table_entry __stop___ex_table[];
 
 #if defined(CONFIG_X86_64)
 extern char __end_rodata_hpage_align[];
 #endif
 
+#endif /* defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__) */
+
 #endif	/* _ASM_X86_SECTIONS_H */
diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index a2f253c091e3..d661f28e4e00 100644
--- a/arch/x86/include/asm/uaccess.h
+++ b/arch/x86/include/asm/uaccess.h
@@ -8,6 +8,7 @@
 #include <linux/kasan-checks.h>
 #include <linux/thread_info.h>
 #include <linux/string.h>
+#include <asm/sections.h>
 #include <asm/asm.h>
 #include <asm/page.h>
 #include <asm/smap.h>
@@ -90,23 +91,6 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
 #define access_ok(type, addr, size) \
 	likely(!__range_not_ok(addr, size, user_addr_max()))
 
-/*
- * The exception table consists of triples of addresses relative to the
- * exception table entry itself. The first address is of an instruction
- * that is allowed to fault, the second is the target at which the program
- * should continue. The third is a handler function to deal with the fault
- * caused by the instruction in the first field.
- *
- * All the routines below use bits of fixup code that are out of line
- * with the main instruction path.  This means when everything is well,
- * we don't even have to jump over them.  Further, they do not intrude
- * on our cache or tlb entries.
- */
-
-struct exception_table_entry {
-	int insn, fixup, handler;
-};
-
 #define ARCH_HAS_RELATIVE_EXTABLE
 
 #define swap_ex_entry_fixup(a, b, tmp, delta)			\
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index af0254c09424..efd51e70a8db 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_GENERIC_SECTIONS_H_
 #define _ASM_GENERIC_SECTIONS_H_
 
+#if defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__)
+
 /* References to section boundaries */
 
 #include <linux/compiler.h>
@@ -128,4 +130,6 @@ static inline bool init_section_intersects(void *virt, size_t size)
 	return memory_intersects(__init_begin, __init_end, virt, size);
 }
 
+#endif /* defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__) */
+
 #endif /* _ASM_GENERIC_SECTIONS_H_ */
-- 
2.8.4

