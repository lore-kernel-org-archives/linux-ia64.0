From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 31 Jan 2008 09:06:42 +0000
Subject: Re: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <20080131090642.GA5688@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080130180623.GA24881@elte.hu> <1FE6DD409037234FAB833C420AA843EC757DEA@orsmsx424.amr.corp.intel.com> <47A0CD4B.5040706@sgi.com> <1FE6DD409037234FAB833C420AA843EC757F12@orsmsx424.amr.corp.intel.com> <20080130194616.GA19426@elte.hu> <1FE6DD409037234FAB833C420AA843EC757F7C@orsmsx424.amr.corp.intel.com> <20080130200221.GA28073@elte.hu> <1FE6DD409037234FAB833C420AA843EC757FC2@orsmsx424.amr.corp.intel.com> <20080130205915.GA4562@elte.hu> <1FE6DD409037234FAB833C420AA843EC78C219@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC78C219@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Mike Travis <travis@sgi.com>, Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org


* Luck, Tony <tony.luck@intel.com> wrote:

> > I'll start digging on why this doesn't boot ... but you might as well
> > send the fixes so far upstream to Linus so that the SMP fix is available
> 
> Well a pure 2.6.24 version compiled with CONFIG_SMP=n booted just 
> fine, so the breakage is recent ... and more than likely related to 
> this change.
> 
> I've only had a casual dig at the failing case ... kernel dies in 
> memset() as called from kmem_cache_alloc() with the address being 
> written as 0x4000000000117b48 (which is off in the virtual address 
> space range used by users ... not a kernel address).

hm, as far as i could check, on ia64 UP the .percpu section link 
difference was the only ia64 difference i could find out of those 
changes. Could you try to copy a 2.6.24 include/asm-generic/percpu.h, 
include/asm-ia64.h and include/linux/percpu.h into your current tree, 
and see whether that boots? If yes, then it's the percpu changes. The 
patch below does this ontop of very latest -git - and it builds fine 
with your UP config with a crosscompiler.

> I'll dig some more tomorrow.

thanks.

	Ingo

---
 include/asm-generic/percpu.h |   99 ++++++++++++++++---------------------------
 include/asm-ia64/percpu.h    |   57 +++++++++++++++++++-----
 include/linux/percpu.h       |   20 --------
 3 files changed, 82 insertions(+), 94 deletions(-)

Index: linux-x86.q/include/asm-generic/percpu.h
=================================--- linux-x86.q.orig/include/asm-generic/percpu.h
+++ linux-x86.q/include/asm-generic/percpu.h
@@ -3,79 +3,54 @@
 #include <linux/compiler.h>
 #include <linux/threads.h>
 
-/*
- * Determine the real variable name from the name visible in the
- * kernel sources.
- */
-#define per_cpu_var(var) per_cpu__##var
-
+#define __GENERIC_PER_CPU
 #ifdef CONFIG_SMP
 
-/*
- * per_cpu_offset() is the offset that has to be added to a
- * percpu variable to get to the instance for a certain processor.
- *
- * Most arches use the __per_cpu_offset array for those offsets but
- * some arches have their own ways of determining the offset (x86_64, s390).
- */
-#ifndef __per_cpu_offset
 extern unsigned long __per_cpu_offset[NR_CPUS];
 
 #define per_cpu_offset(x) (__per_cpu_offset[x])
-#endif
-
-/*
- * Determine the offset for the currently active processor.
- * An arch may define __my_cpu_offset to provide a more effective
- * means of obtaining the offset to the per cpu variables of the
- * current processor.
- */
-#ifndef __my_cpu_offset
-#define __my_cpu_offset per_cpu_offset(raw_smp_processor_id())
-#define my_cpu_offset per_cpu_offset(smp_processor_id())
-#else
-#define my_cpu_offset __my_cpu_offset
-#endif
-
-/*
- * Add a offset to a pointer but keep the pointer as is.
- *
- * Only S390 provides its own means of moving the pointer.
- */
-#ifndef SHIFT_PERCPU_PTR
-#define SHIFT_PERCPU_PTR(__p, __offset)	RELOC_HIDE((__p), (__offset))
-#endif
-
-/*
- * A percpu variable may point to a discarded regions. The following are
- * established ways to produce a usable pointer from the percpu variable
- * offset.
- */
-#define per_cpu(var, cpu) \
-	(*SHIFT_PERCPU_PTR(&per_cpu_var(var), per_cpu_offset(cpu)))
-#define __get_cpu_var(var) \
-	(*SHIFT_PERCPU_PTR(&per_cpu_var(var), my_cpu_offset))
-#define __raw_get_cpu_var(var) \
-	(*SHIFT_PERCPU_PTR(&per_cpu_var(var), __my_cpu_offset))
-
-
-#ifdef CONFIG_HAVE_SETUP_PER_CPU_AREA
-extern void setup_per_cpu_areas(void);
-#endif
 
+/* Separate out the type, so (int[3], foo) works. */
+#define DEFINE_PER_CPU(type, name) \
+    __attribute__((__section__(".data.percpu"))) __typeof__(type) per_cpu__##name
+
+#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)		\
+    __attribute__((__section__(".data.percpu.shared_aligned"))) \
+    __typeof__(type) per_cpu__##name				\
+    ____cacheline_aligned_in_smp
+
+/* var is in discarded region: offset to particular copy we want */
+#define per_cpu(var, cpu) (*({				\
+	extern int simple_identifier_##var(void);	\
+	RELOC_HIDE(&per_cpu__##var, __per_cpu_offset[cpu]); }))
+#define __get_cpu_var(var) per_cpu(var, smp_processor_id())
+#define __raw_get_cpu_var(var) per_cpu(var, raw_smp_processor_id())
+
+/* A macro to avoid #include hell... */
+#define percpu_modcopy(pcpudst, src, size)			\
+do {								\
+	unsigned int __i;					\
+	for_each_possible_cpu(__i)				\
+		memcpy((pcpudst)+__per_cpu_offset[__i],		\
+		       (src), (size));				\
+} while (0)
 #else /* ! SMP */
 
-#define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu_var(var)))
-#define __get_cpu_var(var)			per_cpu_var(var)
-#define __raw_get_cpu_var(var)			per_cpu_var(var)
+#define DEFINE_PER_CPU(type, name) \
+    __typeof__(type) per_cpu__##name
+
+#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)	\
+    DEFINE_PER_CPU(type, name)
+
+#define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu__##var))
+#define __get_cpu_var(var)			per_cpu__##var
+#define __raw_get_cpu_var(var)			per_cpu__##var
 
 #endif	/* SMP */
 
-#ifndef PER_CPU_ATTRIBUTES
-#define PER_CPU_ATTRIBUTES
-#endif
+#define DECLARE_PER_CPU(type, name) extern __typeof__(type) per_cpu__##name
 
-#define DECLARE_PER_CPU(type, name) extern PER_CPU_ATTRIBUTES \
-					__typeof__(type) per_cpu_var(name)
+#define EXPORT_PER_CPU_SYMBOL(var) EXPORT_SYMBOL(per_cpu__##var)
+#define EXPORT_PER_CPU_SYMBOL_GPL(var) EXPORT_SYMBOL_GPL(per_cpu__##var)
 
 #endif /* _ASM_GENERIC_PERCPU_H_ */
Index: linux-x86.q/include/asm-ia64/percpu.h
=================================--- linux-x86.q.orig/include/asm-ia64/percpu.h
+++ linux-x86.q/include/asm-ia64/percpu.h
@@ -15,36 +15,69 @@
 
 #include <linux/threads.h>
 
-#ifdef CONFIG_SMP
-
 #ifdef HAVE_MODEL_SMALL_ATTRIBUTE
-# define PER_CPU_ATTRIBUTES	__attribute__((__model__ (__small__)))
+# define __SMALL_ADDR_AREA	__attribute__((__model__ (__small__)))
+#else
+# define __SMALL_ADDR_AREA
 #endif
 
-#define __my_cpu_offset	__ia64_per_cpu_var(local_per_cpu_offset)
+#define DECLARE_PER_CPU(type, name)				\
+	extern __SMALL_ADDR_AREA __typeof__(type) per_cpu__##name
+
+/* Separate out the type, so (int[3], foo) works. */
+#define DEFINE_PER_CPU(type, name)				\
+	__attribute__((__section__(".data.percpu")))		\
+	__SMALL_ADDR_AREA __typeof__(type) per_cpu__##name
+
+#ifdef CONFIG_SMP
+#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)			\
+	__attribute__((__section__(".data.percpu.shared_aligned")))	\
+	__SMALL_ADDR_AREA __typeof__(type) per_cpu__##name		\
+	____cacheline_aligned_in_smp
+#else
+#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)	\
+	DEFINE_PER_CPU(type, name)
+#endif
+
+/*
+ * Pretty much a literal copy of asm-generic/percpu.h, except that percpu_modcopy() is an
+ * external routine, to avoid include-hell.
+ */
+#ifdef CONFIG_SMP
+
+extern unsigned long __per_cpu_offset[NR_CPUS];
+#define per_cpu_offset(x) (__per_cpu_offset[x])
 
+/* Equal to __per_cpu_offset[smp_processor_id()], but faster to access: */
+DECLARE_PER_CPU(unsigned long, local_per_cpu_offset);
+
+#define per_cpu(var, cpu)  (*RELOC_HIDE(&per_cpu__##var, __per_cpu_offset[cpu]))
+#define __get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __ia64_per_cpu_var(local_per_cpu_offset)))
+#define __raw_get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __ia64_per_cpu_var(local_per_cpu_offset)))
+
+extern void percpu_modcopy(void *pcpudst, const void *src, unsigned long size);
+extern void setup_per_cpu_areas (void);
 extern void *per_cpu_init(void);
 
 #else /* ! SMP */
 
-#define PER_CPU_ATTRIBUTES	__attribute__((__section__(".data.percpu")))
-
+#define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu__##var))
+#define __get_cpu_var(var)			per_cpu__##var
+#define __raw_get_cpu_var(var)			per_cpu__##var
 #define per_cpu_init()				(__phys_per_cpu_start)
 
 #endif	/* SMP */
 
+#define EXPORT_PER_CPU_SYMBOL(var)		EXPORT_SYMBOL(per_cpu__##var)
+#define EXPORT_PER_CPU_SYMBOL_GPL(var)		EXPORT_SYMBOL_GPL(per_cpu__##var)
+
 /*
  * Be extremely careful when taking the address of this variable!  Due to virtual
  * remapping, it is different from the canonical address returned by __get_cpu_var(var)!
  * On the positive side, using __ia64_per_cpu_var() instead of __get_cpu_var() is slightly
  * more efficient.
  */
-#define __ia64_per_cpu_var(var)	per_cpu__##var
-
-#include <asm-generic/percpu.h>
-
-/* Equal to __per_cpu_offset[smp_processor_id()], but faster to access: */
-DECLARE_PER_CPU(unsigned long, local_per_cpu_offset);
+#define __ia64_per_cpu_var(var)	(per_cpu__##var)
 
 #endif /* !__ASSEMBLY__ */
 
Index: linux-x86.q/include/linux/percpu.h
=================================--- linux-x86.q.orig/include/linux/percpu.h
+++ linux-x86.q/include/linux/percpu.h
@@ -9,26 +9,6 @@
 
 #include <asm/percpu.h>
 
-#ifdef CONFIG_SMP
-#define DEFINE_PER_CPU(type, name)					\
-	__attribute__((__section__(".data.percpu")))			\
-	PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name
-
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)			\
-	__attribute__((__section__(".data.percpu.shared_aligned")))	\
-	PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name		\
-	____cacheline_aligned_in_smp
-#else
-#define DEFINE_PER_CPU(type, name)					\
-	PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name
-
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)		      \
-	DEFINE_PER_CPU(type, name)
-#endif
-
-#define EXPORT_PER_CPU_SYMBOL(var) EXPORT_SYMBOL(per_cpu__##var)
-#define EXPORT_PER_CPU_SYMBOL_GPL(var) EXPORT_SYMBOL_GPL(per_cpu__##var)
-
 /* Enough to cover all DEFINE_PER_CPUs in kernel, including modules. */
 #ifndef PERCPU_ENOUGH_ROOM
 #ifdef CONFIG_MODULES
