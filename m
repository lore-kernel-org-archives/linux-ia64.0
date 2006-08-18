From: Horms <horms@verge.net.au>
Date: Fri, 18 Aug 2006 12:10:10 +0000
Subject: Re: IA64 Kdump patch V3
Message-Id: <20060818121008.GA2084@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155889296.2585.1324.camel@linux-znh>
In-Reply-To: <1155889296.2585.1324.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is an incremental version of this patch, 
it should append as patch 6 to the 5 patch series that
I posted yeterday.

http://permalink.gmane.org/gmane.comp.boot-loaders.fastboot.general/1407

I have also made the series of patches available at 

http://www.vergenet.net/~horms/patches/ia64-kexec/kernel/

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

[IA64] Kdump patch V3

> Archived-At: http://permalink.gmane.org/gmane.linux.ports.ia64/14717
> 
> IA64 Kdump patch V3
>
> The fix and change in this patch include
> 
> 1. According to suggestion from Dave,
>    I put an extra switch stack frame on each CPU to help crash utility
>    to run bt command.
> 
> 2. Fix issue reported by Fujitsu that crash kernel can't startup
>    with CONFIG_SPARSEMEM
> 
> 3. More simplified crash path.
> 
> 
> Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

Incremental version of the above patch

Cc: Zou Nan hai <nanhai.zou@intel.com>
Signed-Off-By: Simon Horman <horms@verge.net.au>

Index: linux-2.6-ia64/arch/ia64/kernel/crash.c
=================================--- linux-2.6-ia64.orig/arch/ia64/kernel/crash.c	2006-08-18 20:52:17.000000000 +0900
+++ linux-2.6-ia64/arch/ia64/kernel/crash.c	2006-08-18 20:52:35.000000000 +0900
@@ -30,8 +30,7 @@
 
         if (!csize)
                 return 0;
-        vaddr = page_address(pfn_to_page(pfn));
-
+        vaddr = __va(pfn<<PAGE_SHIFT);
         if (userbuf) {
                 if (copy_to_user(buf, (vaddr + offset), csize)) {
                         return -EFAULT;
@@ -43,13 +42,7 @@
 
 static void device_shootdown(void)
 {
-	irq_desc_t *idesc;
-	int irq;
-	for (irq = 0; irq < NR_IRQS; irq++) {
-		idesc = irq_desc + irq;
-		if (idesc)
-			kdump_disable_irq(irq);
-	}
+	kdump_disable_iosapic();
 #ifdef CONFIG_IA64_HP_ZX1
 	ioc_iova_disable();
 #endif
@@ -122,4 +115,5 @@
 #ifdef CONFIG_SMP
 	kdump_smp_send_stop();
 #endif
+	udelay(1000000);
 }
Index: linux-2.6-ia64/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6-ia64.orig/arch/ia64/kernel/iosapic.c	2006-08-18 20:52:18.000000000 +0900
+++ linux-2.6-ia64/arch/ia64/kernel/iosapic.c	2006-08-18 20:52:35.000000000 +0900
@@ -290,18 +290,19 @@
 
 #ifdef CONFIG_CRASH_DUMP
 void
-kdump_disable_irq(unsigned int irq)
+kdump_disable_iosapic(void)
 {
 	u32 low32;
-	ia64_vector vec = irq_to_vector(irq);
+	struct iosapic_intr_info *info;
 	struct iosapic_rte_info *rte;
-
-	low32 = iosapic_intr_info[vec].low32 |= IOSAPIC_MASK;
-	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes,
-			rte_list) {
+	for (info = iosapic_intr_info; info <
+			iosapic_intr_info + IA64_NUM_VECTORS; ++info) {
+		low32 = info->low32 |= IOSAPIC_MASK;
+		list_for_each_entry(rte, &info->rtes,
+				rte_list) {
 			iosapic_write(rte->addr,
 					IOSAPIC_RTE_LOW(rte->rte_index), low32);
-			iosapic_eoi(rte->addr, vec);
+		}
 	}
 }
 #endif
Index: linux-2.6-ia64/arch/ia64/kernel/machine_kexec.c
=================================--- linux-2.6-ia64.orig/arch/ia64/kernel/machine_kexec.c	2006-08-18 20:52:18.000000000 +0900
+++ linux-2.6-ia64/arch/ia64/kernel/machine_kexec.c	2006-08-18 20:52:35.000000000 +0900
@@ -102,7 +102,6 @@
 	}
 #endif
 
-
 #ifdef CONFIG_IA64_HP_ZX1
 	ioc_iova_disable();
 #endif
@@ -113,13 +112,17 @@
  * We are past the point of no return, committed to rebooting now.
  */
 extern void *efi_get_pal_addr(void);
-void machine_kexec(struct kimage *image)
+static void ia64_machine_kexec(struct unw_frame_info *info, void *arg) 
 {
+	struct kimage *image = arg;
 	relocate_new_kernel_t rnk;
 	void *pal_addr = efi_get_pal_addr();
 	unsigned long code_addr = (unsigned long)page_address(image->control_code_page);
-	if (image->type = KEXEC_TYPE_CRASH)
+	if (image->type = KEXEC_TYPE_CRASH) {
 		crash_save_this_cpu();
+		current->thread.ksp = (__u64)info->sw - 16;
+	}
+
 	/* Interrupts aren't acceptable while we reboot */
 	ia64_set_itv(1<<16);
 	local_irq_disable();
@@ -127,5 +130,10 @@
 	(*rnk)(image->head, image->start, ia64_boot_param,
 		     GRANULEROUNDDOWN((unsigned long) pal_addr));
 	BUG();
-	for (;;);
+} 
+
+void machine_kexec(struct kimage *image)
+{
+	unw_init_running(ia64_machine_kexec, image);
+	for(;;);
 }
Index: linux-2.6-ia64/arch/ia64/kernel/setup.c
=================================--- linux-2.6-ia64.orig/arch/ia64/kernel/setup.c	2006-08-18 20:52:18.000000000 +0900
+++ linux-2.6-ia64/arch/ia64/kernel/setup.c	2006-08-18 20:52:35.000000000 +0900
@@ -278,9 +278,6 @@
 		efi_memmap_res.start = ia64_boot_param->efi_memmap;
                 efi_memmap_res.end = efi_memmap_res.start +
                         ia64_boot_param->efi_memmap_size;
-                printk("efi_memmap start %lx %lx\n",
-                        efi_memmap_res.start,
-                        efi_memmap_res.end);
                 boot_param_res.start = __pa(ia64_boot_param);
                 boot_param_res.end = boot_param_res.start +
                         sizeof(*ia64_boot_param);
Index: linux-2.6-ia64/arch/ia64/kernel/smp.c
=================================--- linux-2.6-ia64.orig/arch/ia64/kernel/smp.c	2006-08-18 20:52:18.000000000 +0900
+++ linux-2.6-ia64/arch/ia64/kernel/smp.c	2006-08-18 20:52:35.000000000 +0900
@@ -126,6 +126,18 @@
 	cpu_halt();
 }
 
+#ifdef CONFIG_CRASH_DUMP
+static void 
+kdump_cpu_freeze(struct unw_frame_info *info, void *arg)
+{
+	local_irq_disable();
+	crash_save_this_cpu();
+	current->thread.ksp = (__u64)info->sw - 16;
+	cpu_halt();
+}
+#endif
+
+
 void
 cpu_die(void)
 {
@@ -187,11 +199,7 @@
 				break;
 #ifdef CONFIG_CRASH_DUMP
 			      case IPI_KDUMP_CPU_STOP:
-				{
-					local_irq_disable();
-					crash_save_this_cpu();
-					cpu_halt();
-				}
+				unw_init_running(kdump_cpu_freeze, NULL);
 				break;
 #endif
 			      default:
@@ -251,6 +259,13 @@
 	send_IPI_single(smp_processor_id(), op);
 }
 
+#ifdef CONFIG_CRASH_DUMP
+void
+kdump_smp_send_stop()
+{
+ 	send_IPI_allbutself(IPI_KDUMP_CPU_STOP);
+}
+#endif
 /*
  * Called with preeemption disabled.
  */
@@ -409,13 +424,6 @@
 {
 	send_IPI_allbutself(IPI_CPU_STOP);
 }
-#ifdef CONFIG_CRASH_DUMP
-void
-kdump_smp_send_stop()
-{
- 	send_IPI_allbutself(IPI_KDUMP_CPU_STOP);
-}
-#endif
 
 int __init
 setup_profiling_timer (unsigned int multiplier)
Index: linux-2.6-ia64/include/asm-ia64/kexec.h
=================================--- linux-2.6-ia64.orig/include/asm-ia64/kexec.h	2006-08-18 20:52:18.000000000 +0900
+++ linux-2.6-ia64/include/asm-ia64/kexec.h	2006-08-18 20:52:35.000000000 +0900
@@ -34,7 +34,7 @@
 extern struct resource efi_memmap_res;
 extern struct resource boot_param_res;
 extern void kdump_smp_send_stop(void);
-extern void kdump_disable_irq(unsigned int irq);
+extern void kdump_disable_iosapic(void);
 extern void crash_save_this_cpu(void);
 
 #endif /* _ASM_IA64_KEXEC_H */
