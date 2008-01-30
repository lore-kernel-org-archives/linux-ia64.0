From: travis@sgi.com
Date: Wed, 30 Jan 2008 18:09:44 +0000
Subject: [PATCH 4/6] ia64: Use generic percpu linux-2.6.git
Message-Id: <20080130180940.648082000@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080130180940.022172000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, mingo@elte.hu, Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

ia64 has a special processor specific mapping that can be used to locate the
offset for the current per cpu area.

Based on latest linux-2.6.git

Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org

Signed-off-by: Mike Travis <travis@sgi.com>
---
linux-2.6.git:
  - added back in missing pieces from x86.git merge
---
 include/asm-ia64/percpu.h |   24 +++++++-----------------
 include/linux/percpu.h    |    4 ----
 2 files changed, 7 insertions(+), 21 deletions(-)

--- a/include/asm-ia64/percpu.h
+++ b/include/asm-ia64/percpu.h
@@ -19,29 +19,14 @@
 # define PER_CPU_ATTRIBUTES	__attribute__((__model__ (__small__)))
 #endif
 
-#define DECLARE_PER_CPU(type, name)				\
-	extern PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name
-
 #ifdef CONFIG_SMP
 
-extern unsigned long __per_cpu_offset[NR_CPUS];
-#define per_cpu_offset(x) (__per_cpu_offset[x])
-
-/* Equal to __per_cpu_offset[smp_processor_id()], but faster to access: */
-DECLARE_PER_CPU(unsigned long, local_per_cpu_offset);
-
-#define per_cpu(var, cpu)  (*RELOC_HIDE(&per_cpu__##var, __per_cpu_offset[cpu]))
-#define __get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __ia64_per_cpu_var(local_per_cpu_offset)))
-#define __raw_get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __ia64_per_cpu_var(local_per_cpu_offset)))
+#define __my_cpu_offset	__ia64_per_cpu_var(local_per_cpu_offset)
 
-extern void setup_per_cpu_areas (void);
 extern void *per_cpu_init(void);
 
 #else /* ! SMP */
 
-#define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu__##var))
-#define __get_cpu_var(var)			per_cpu__##var
-#define __raw_get_cpu_var(var)			per_cpu__##var
 #define per_cpu_init()				(__phys_per_cpu_start)
 
 #endif	/* SMP */
@@ -52,7 +37,12 @@ extern void *per_cpu_init(void);
  * On the positive side, using __ia64_per_cpu_var() instead of __get_cpu_var() is slightly
  * more efficient.
  */
-#define __ia64_per_cpu_var(var)	(per_cpu__##var)
+#define __ia64_per_cpu_var(var)	per_cpu__##var
+
+#include <asm-generic/percpu.h>
+
+/* Equal to __per_cpu_offset[smp_processor_id()], but faster to access: */
+DECLARE_PER_CPU(unsigned long, local_per_cpu_offset);
 
 #endif /* !__ASSEMBLY__ */
 
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -9,10 +9,6 @@
 
 #include <asm/percpu.h>
 
-#ifndef PER_CPU_ATTRIBUTES
-#define PER_CPU_ATTRIBUTES
-#endif
-
 #ifdef CONFIG_SMP
 #define DEFINE_PER_CPU(type, name)					\
 	__attribute__((__section__(".data.percpu")))			\

-- 
