From: Zou Nan hai <nanhai.zou@intel.com>
Date: Thu, 08 Feb 2007 03:28:44 +0000
Subject: [RFC Patch]Use ar.kr2 for smp_processor_id
Message-Id: <1170905324.3230.7.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Pin ar.kr2 of each CPU, so that smp_processor_id can use it.
This will save some memory foot-print when smp_procerror_id() 
is called.

This is also useful for implement sys_getcpu in fast path.

I have simply tested the patch by boot on a 16p system then try 
offline and online some CPUs through /sys/.
 

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>


diff -Nraup linux-2.6.20/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- linux-2.6.20/arch/ia64/kernel/setup.c	2007-02-04 13:44:54.000000000 -0500
+++ b/arch/ia64/kernel/setup.c	2007-02-07 23:30:03.000000000 -0500
@@ -458,6 +458,9 @@ early_param("elfcorehdr", parse_elfcoreh
 void __init
 setup_arch (char **cmdline_p)
 {
+	/* setup SMP processor id */
+	ia64_set_kr(IA64_KR_CPU_ID, (current_thread_info()->cpu));
+
 	unw_init();
 
 	ia64_patch_vtop((u64) __start___vtop_patchlist, (u64) __end___vtop_patchlist);
diff -Nraup linux-2.6.20/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
--- linux-2.6.20/arch/ia64/kernel/smpboot.c	2007-02-04 13:44:54.000000000 -0500
+++ b/arch/ia64/kernel/smpboot.c	2007-02-07 23:29:44.000000000 -0500
@@ -445,8 +445,12 @@ smp_callin (void)
 int __devinit
 start_secondary (void *unused)
 {
+	/* setup SMP processor id */
+	ia64_set_kr(IA64_KR_CPU_ID, (current_thread_info()->cpu));
+	
 	/* Early console may use I/O ports */
 	ia64_set_kr(IA64_KR_IO_BASE, __pa(ia64_iobase));
+
 	Dprintk("start_secondary: starting CPU 0x%x\n", hard_smp_processor_id());
 	efi_map_pal_code();
 	cpu_init();
diff -Nraup linux-2.6.20/include/asm-ia64/kregs.h b/include/asm-ia64/kregs.h
--- linux-2.6.20/include/asm-ia64/kregs.h	2007-02-04 13:44:54.000000000 -0500
+++ b/include/asm-ia64/kregs.h	2007-02-07 23:28:21.000000000 -0500
@@ -14,6 +14,7 @@
  */
 #define IA64_KR_IO_BASE		0	/* ar.k0: legacy I/O base address */
 #define IA64_KR_TSSD		1	/* ar.k1: IVE uses this as the TSSD */
+#define IA64_KR_CPU_ID		2	/* ar.k2: Processor ID */
 #define IA64_KR_PER_CPU_DATA	3	/* ar.k3: physical per-CPU base */
 #define IA64_KR_CURRENT_STACK	4	/* ar.k4: what's mapped in IA64_TR_CURRENT_STACK */
 #define IA64_KR_FPU_OWNER	5	/* ar.k5: fpu-owner (UP only, at the moment) */
diff -Nraup linux-2.6.20/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
--- linux-2.6.20/include/asm-ia64/smp.h	2007-02-04 13:44:54.000000000 -0500
+++ b/include/asm-ia64/smp.h	2007-02-08 00:53:58.000000000 -0500
@@ -45,7 +45,7 @@ ia64_get_lid (void)
 #define SMP_IRQ_REDIRECTION	(1 << 0)
 #define SMP_IPI_REDIRECTION	(1 << 1)
 
-#define raw_smp_processor_id() (current_thread_info()->cpu)
+#define raw_smp_processor_id() (ia64_get_kr(IA64_KR_CPU_ID))
 
 extern struct smp_boot_data {
 	int cpu_count;




  
