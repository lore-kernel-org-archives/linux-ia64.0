From: dann frazier <dannf@dannf.org>
Date: Wed, 09 Mar 2005 05:09:58 +0000
Subject: conflicting per_cpu_init() defines on non-SMP
Message-Id: <1110344998.9344.9.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In 2.6.11 arch/ia64/mm/discontig.c defines a per_cpu_init() function;
however, non-SMP systems have a per_cpu_init macro defined in
include/asm-ia64/percpu.h.

#define per_cpu_init()                          (__phys_per_cpu_start)

Is this the right way to approach a patch to fix this?

diff -urN linux-2.6.11.orig/arch/ia64/mm/discontig.c linux-2.6.11/arch/ia64/mm/discontig.c
--- linux-2.6.11.orig/arch/ia64/mm/discontig.c	2005-03-02 00:38:25.000000000 -0700
+++ linux-2.6.11/arch/ia64/mm/discontig.c	2005-03-08 22:10:48.704466208 -0700
@@ -525,6 +524,7 @@
  * find_pernode_space() does most of this already, we just need to set
  * local_per_cpu_offset
  */
+#ifdef CONFIG_SMP
 void *per_cpu_init(void)
 {
 	int cpu;
@@ -538,6 +538,9 @@
 
 	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 }
+#else
+#define per_cpu_init()                          (__phys_per_cpu_start)
+#endif
 
 /**
  * show_mem - give short summary of memory stats
diff -urN linux-2.6.11.orig/include/asm-ia64/percpu.h linux-2.6.11/include/asm-ia64/percpu.h
--- linux-2.6.11.orig/include/asm-ia64/percpu.h	2005-03-02 00:38:17.000000000 -0700
+++ linux-2.6.11/include/asm-ia64/percpu.h	2005-03-08 22:09:23.689818812 -0700
@@ -52,7 +52,6 @@
 
 #define per_cpu(var, cpu)			(*((void)cpu, &per_cpu__##var))
 #define __get_cpu_var(var)			per_cpu__##var
-#define per_cpu_init()				(__phys_per_cpu_start)
 
 #endif	/* SMP */
 


-- 
dann frazier <dannf@dannf.org>

