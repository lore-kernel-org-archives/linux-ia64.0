From: Russ Anderson <rja@sgi.com>
Date: Fri, 07 Jan 2005 21:12:15 +0000
Subject: [patch] correct PERCPU_MCA_SIZE and ia64_init_stack size
Message-Id: <200501072112.j07LCF3S219017@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Two changes:

  * PERCPU_MCA_SIZE was the size of the wrong structure.
  * ia64_init_stack was larger than necessary.

Signed-off-by: Russ Anderson <rja@sgi.com>

--------------------------------------------------------------
Index: 2.6.11/include/asm-ia64/mca.h
=================================--- 2.6.11.orig/include/asm-ia64/mca.h	2005-01-07 14:37:22.026643158 -0600
+++ 2.6.11/include/asm-ia64/mca.h	2005-01-07 14:40:21.986122830 -0600
@@ -61,8 +61,6 @@
 
 } ia64_mc_info_t;
 
-#define PERCPU_MCA_SIZE sizeof(struct ia64_mc_info_s)
-
 typedef struct ia64_mca_sal_to_os_state_s {
 	u64		imsto_os_gp;		/* GP of the os registered with the SAL */
 	u64		imsto_pal_proc;		/* PAL_PROC entry point - physical addr */
@@ -110,12 +108,14 @@
 
 typedef struct ia64_mca_cpu_s {
 	u64	ia64_mca_stack[IA64_MCA_STACK_SIZE] 		__attribute__((aligned(16)));
-	u64	ia64_mca_proc_state_dump[512] 			__attribute__((aligned(16)));
+	u64	ia64_mca_proc_state_dump[512]			__attribute__((aligned(16)));
 	u64	ia64_mca_stackframe[32]				__attribute__((aligned(16)));
-	u64	ia64_mca_bspstore[IA64_MCA_BSPSTORE_SIZE] 	__attribute__((aligned(16)));
-	u64	ia64_init_stack[KERNEL_STACK_SIZE] 		__attribute__((aligned(16)));
+	u64	ia64_mca_bspstore[IA64_MCA_BSPSTORE_SIZE]	__attribute__((aligned(16)));
+	u64	ia64_init_stack[KERNEL_STACK_SIZE/8] 		__attribute__((aligned(16)));
 } ia64_mca_cpu_t;
 
+#define PERCPU_MCA_SIZE sizeof(ia64_mca_cpu_t)
+
 extern void ia64_mca_init(void);
 extern void ia64_os_mca_dispatch(void);
 extern void ia64_os_mca_dispatch_end(void);

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
