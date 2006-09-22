From: Horms <horms@verge.net.au>
Date: Fri, 22 Sep 2006 04:09:02 +0000
Subject: Re: [Fastboot] [Patch] ia64 Kexec/Kdump patch for 2.6.18
Message-Id: <20060922040900.GA20863@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAC6D88895D68Findou.takao@jp.fujitsu.com>
In-Reply-To: <BAC6D88895D68Findou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64 Kexec/Kdump patch for 2.6.18

> ia64 Kexec/Kdump patch for 2.6.18
> 
> Fixes since last patch:
> 
> 1. Check val in kdump_init_notifier.
> 2. write EOI to clean in-service flag to make kdump work when crash
> happen inside irq handler.
> 3. Make CONFIG_KEXEC and CONFIG_CRASH_DUMP depends on !CONFIG_HP_SIM.
> 
> Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

Incremental version of this patch

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/Kconfig
=================================--- linux-2.6.orig/arch/ia64/Kconfig	2006-09-22 12:55:26.000000000 +0900
+++ linux-2.6/arch/ia64/Kconfig	2006-09-22 12:55:46.000000000 +0900
@@ -433,7 +433,7 @@
 
 config KEXEC
 	bool "kexec system call (EXPERIMENTAL)"
-	depends on EXPERIMENTAL
+	depends on EXPERIMENTAL && !IA64_HP_SIM
 	help
 	  kexec is a system call that implements the ability to shutdown your
 	  current kernel, and to start another kernel.  It is like a reboot
@@ -450,7 +450,7 @@
 
 config CRASH_DUMP
 	  bool "kernel crash dumps (EXPERIMENTAL)"
-	  depends on EXPERIMENTAL && IA64_MCA_RECOVERY
+	  depends on EXPERIMENTAL && IA64_MCA_RECOVERY && !IA64_HP_SIM
 	  help
 	    Generate crash dump after being started by kexec.
 
Index: linux-2.6/arch/ia64/kernel/crash.c
=================================--- linux-2.6.orig/arch/ia64/kernel/crash.c	2006-09-22 12:55:26.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/crash.c	2006-09-22 12:55:27.000000000 +0900
@@ -25,7 +25,7 @@
 atomic_t kdump_cpu_freezed;
 int kdump_on_init = 1;
 
-ssize_t 
+ssize_t
 copy_oldmem_page(unsigned long pfn, char *buf,
 		size_t csize, unsigned long offset, int userbuf)
 {
@@ -131,7 +131,7 @@
 #endif
 }
 
-static void 
+static void
 machine_kdump_on_init(void)
 {
 	local_irq_disable();
@@ -160,6 +160,10 @@
 
 	if (!kdump_on_init)
 		return NOTIFY_DONE;
+
+	if (val != DIE_INIT_MONARCH_ENTER && val != DIE_INIT_SLAVE_ENTER)
+		return NOTIFY_DONE;
+
 	nd = (struct ia64_mca_notify_die *)args->err;
 	/* Reason code 1 means machine check rendezous*/
 	if (nd->sos->rv_rc = 1)
@@ -168,7 +172,7 @@
 	switch (val) {
 		case DIE_INIT_MONARCH_ENTER:
 			machine_kdump_on_init();
-			break;	
+			break;
 		case DIE_INIT_SLAVE_ENTER:
 			unw_init_running(kdump_cpu_freeze, NULL);
 			break;
@@ -178,12 +182,12 @@
 
 #ifdef CONFIG_SYSCTL
 static ctl_table kdump_on_init_table[] = {
-	{ 
-		.ctl_name = KERN_KDUMP_ON_INIT, 
+	{
+		.ctl_name = KERN_KDUMP_ON_INIT,
 		.procname = "kdump_on_init",
-		.data = &kdump_on_init, 
+		.data = &kdump_on_init,
 		.maxlen = sizeof(int),
-		.mode = 0644, 
+		.mode = 0644,
 		.proc_handler = &proc_dointvec,
 	},
 	{ .ctl_name = 0 }
@@ -191,9 +195,9 @@
 
 static ctl_table sys_table[] = {
 	{
-	  .ctl_name = CTL_KERN, 
+	  .ctl_name = CTL_KERN,
 	  .procname = "kernel",
-	  .mode = 0555, 
+	  .mode = 0555,
 	  .child = kdump_on_init_table,
 	},
 	{ .ctl_name = 0 }
@@ -214,9 +218,8 @@
 	if((ret = register_die_notifier(&kdump_init_notifier_nb)) != 0)
 		return ret;
 #ifdef CONFIG_SYSCTL
-	if ((ret = register_sysctl_table(sys_table, 0)) != 0)
-		return ret;
-#endif		
+	register_sysctl_table(sys_table, 0);
+#endif
 	return 0;
 }
 
Index: linux-2.6/arch/ia64/kernel/efi.c
=================================--- linux-2.6.orig/arch/ia64/kernel/efi.c	2006-09-22 12:55:26.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/efi.c	2006-09-22 12:55:27.000000000 +0900
@@ -1126,7 +1126,7 @@
 #ifdef CONFIG_KEXEC
                         insert_resource(res, &efi_memmap_res);
                         insert_resource(res, &boot_param_res);
-			if (crashk_res.end > crashk_res.start) 
+			if (crashk_res.end > crashk_res.start)
 				insert_resource(res, &crashk_res);
 #endif
 		}
@@ -1137,12 +1137,12 @@
 /* find a block of memory aligned to 64M exclude reserved regions
    rsvd_regions are sorted
  */
-unsigned long 
-kdump_find_rsvd_region (unsigned long size, 
+unsigned long
+kdump_find_rsvd_region (unsigned long size,
 		struct rsvd_region *r, int n)
 {
   int i;
-  u64 start, end; 
+  u64 start, end;
   u64 alignment = 1UL << _PAGE_SIZE_64M;
   void *efi_map_start, *efi_map_end, *p;
   efi_memory_desc_t *md;
@@ -1173,8 +1173,8 @@
 		return start;
   }
 
-  printk(KERN_WARNING "Cannot reserve 0x%lx byte of memory for crashdump\n", 
+  printk(KERN_WARNING "Cannot reserve 0x%lx byte of memory for crashdump\n",
 	size);
   return ~0UL;
 }
-#endif 
+#endif
Index: linux-2.6/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.orig/arch/ia64/kernel/iosapic.c	2006-09-22 12:55:26.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/iosapic.c	2006-09-22 12:55:27.000000000 +0900
@@ -301,7 +301,7 @@
 		list_for_each_entry(rte, &info->rtes,
 				rte_list) {
 			iosapic_write(rte->addr,
-					IOSAPIC_RTE_LOW(rte->rte_index), 
+					IOSAPIC_RTE_LOW(rte->rte_index),
 					IOSAPIC_MASK);
 			iosapic_eoi(rte->addr, vec);
 		}
Index: linux-2.6/arch/ia64/kernel/machine_kexec.c
=================================--- linux-2.6.orig/arch/ia64/kernel/machine_kexec.c	2006-09-22 12:55:26.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/machine_kexec.c	2006-09-22 12:55:27.000000000 +0900
@@ -87,13 +87,14 @@
  * We are past the point of no return, committed to rebooting now.
  */
 extern void *efi_get_pal_addr(void);
-static void ia64_machine_kexec(struct unw_frame_info *info, void *arg) 
+static void ia64_machine_kexec(struct unw_frame_info *info, void *arg)
 {
 	struct kimage *image = arg;
 	relocate_new_kernel_t rnk;
 	void *pal_addr = efi_get_pal_addr();
 	unsigned long code_addr = (unsigned long)page_address(image->control_code_page);
 	unsigned long vector;
+	int ii;
 
 	if (image->type = KEXEC_TYPE_CRASH) {
 		crash_save_this_cpu();
@@ -102,7 +103,7 @@
 
 	/* Interrupts aren't acceptable while we reboot */
 	local_irq_disable();
-	
+
 	/* Mask CMC and Performance Monitor interrupts */
 	ia64_setreg(_IA64_REG_CR_PMV, 1 << 16);
 	ia64_setreg(_IA64_REG_CR_CMCV, 1 << 16);
@@ -112,6 +113,10 @@
 	ia64_set_lrr0(1 << 16);
 	ia64_set_lrr1(1 << 16);
 
+	/* terminate possible nested in-service interrupts */
+	for (ii = 0; ii < 16; ii++)
+		ia64_eoi();
+
 	/* unmask TPR and clear any pending interrupts */
 	ia64_setreg(_IA64_REG_CR_TPR, 0);
 	ia64_srlz_d();
@@ -124,7 +129,7 @@
 	(*rnk)(image->head, image->start, ia64_boot_param,
 		     GRANULEROUNDDOWN((unsigned long) pal_addr));
 	BUG();
-} 
+}
 
 void machine_kexec(struct kimage *image)
 {
Index: linux-2.6/arch/ia64/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/kernel/setup.c	2006-09-22 12:55:26.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/setup.c	2006-09-22 12:55:27.000000000 +0900
@@ -258,10 +258,9 @@
 #ifdef CONFIG_KEXEC
 	/* crashkernel=size@offset specifies the size to reserve for a crash
 	 * kernel.(offset is ingored for keep compatibility with other archs)
-	 * By reserving this memory we guarantee that linux 
-	 * never set's it up as a DMA target.
-	 * Useful for holding code to do something appropriate
-	 * after a kernel panic.
+	 * By reserving this memory we guarantee that linux never set's it
+	 * up as a DMA target.Useful for holding code to do something
+	 * appropriate after a kernel panic.
 	 */
 	{
 		char *from = strstr(saved_command_line, "crashkernel=");
@@ -270,7 +269,7 @@
 			size = memparse(from + 12, &from);
 			if (size) {
 				sort_regions(rsvd_region, n);
-				base = kdump_find_rsvd_region(size, 
+				base = kdump_find_rsvd_region(size,
 				rsvd_region, n);
 				if (base != ~0UL) {
 					rsvd_region[n].start Index: linux-2.6/include/asm-ia64/kexec.h
=================================--- linux-2.6.orig/include/asm-ia64/kexec.h	2006-09-22 12:55:26.000000000 +0900
+++ linux-2.6/include/asm-ia64/kexec.h	2006-09-22 12:55:27.000000000 +0900
@@ -44,7 +44,7 @@
 extern void kexec_disable_iosapic(void);
 extern void crash_save_this_cpu(void);
 struct rsvd_region;
-extern unsigned long kdump_find_rsvd_region(unsigned long size, 
+extern unsigned long kdump_find_rsvd_region(unsigned long size,
 		struct rsvd_region *rsvd_regions, int n);
 extern void kdump_cpu_freeze(struct unw_frame_info *info, void *arg);
 extern int kdump_status[];
