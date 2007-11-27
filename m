From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 27 Nov 2007 00:14:20 +0000
Subject: [patch 13/14] ia64: Use generic percpu
Message-Id: <20071127001432.160399113@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071127001407.859743255@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

ia64 has a special processor specific mapping that can be used to locate the
offset for the current per cpu area.

Cc: linux-ia64@vger.kernel.org
Cc: tony.luck@intel.com
Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/asm-ia64/percpu.h |   24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

Index: linux-2.6/include/asm-ia64/percpu.h
=================================--- linux-2.6.orig/include/asm-ia64/percpu.h	2007-11-24 10:27:31.088350556 -0800
+++ linux-2.6/include/asm-ia64/percpu.h	2007-11-24 10:31:54.053187674 -0800
@@ -9,10 +9,9 @@
 #define PERCPU_ENOUGH_ROOM PERCPU_PAGE_SIZE
 
 #ifdef __ASSEMBLY__
-# define THIS_CPU(var)	(per_cpu__##var)  /* use this to mark accesses to per-CPU variables... */
+# define THIS_CPU(var)	(PERCPU_ADDR + per_cpu__##var)  /* use this to mark accesses to per-CPU variables... */
 #else /* !__ASSEMBLY__ */
 
-
 #include <linux/threads.h>
 
 #define DECLARE_PER_CPU(type, name)				\
@@ -20,24 +19,12 @@
 
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
@@ -48,7 +35,12 @@ extern void *per_cpu_init(void);
  * On the positive side, using __ia64_per_cpu_var() instead of __get_cpu_var() is slightly
  * more efficient.
  */
-#define __ia64_per_cpu_var(var)	(per_cpu__##var)
+#define __ia64_per_cpu_var(var)	(*SHIFT_PTR(&per_cpu__##var, PERCPU_ADDR))
+
+#include <asm-generic/percpu.h>
+
+/* Equal to __per_cpu_offset[smp_processor_id()], but faster to access: */
+DECLARE_PER_CPU(unsigned long, local_per_cpu_offset);
 
 #endif /* !__ASSEMBLY__ */
 

-- 
