From: Horms <horms@verge.net.au>
Date: Wed, 20 Sep 2006 02:43:00 +0000
Subject: Kexec/Kdump: whitespace cleanups
Message-Id: <20060920024544.628886000@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove trailing whitespace introduced by IA64 Kexec/Kdump patch for 2.6.18-rc6
See: http://permalink.gmane.org/gmane.linux.ports.ia64/14988

Signed-Off-By: Simon Horman <horms@verge.net.au>
Index: linux-2.6/arch/ia64/kernel/crash.c
=================================--- linux-2.6.orig/arch/ia64/kernel/crash.c	2006-09-20 10:46:56.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/crash.c	2006-09-20 10:48:34.000000000 +0900
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
@@ -168,7 +168,7 @@
 	switch (val) {
 		case DIE_INIT_MONARCH_ENTER:
 			machine_kdump_on_init();
-			break;	
+			break;
 		case DIE_INIT_SLAVE_ENTER:
 			unw_init_running(kdump_cpu_freeze, NULL);
 			break;
@@ -178,12 +178,12 @@
 
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
@@ -191,9 +191,9 @@
 
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
@@ -216,7 +216,7 @@
 #ifdef CONFIG_SYSCTL
 	if ((ret = register_sysctl_table(sys_table, 0)) != 0)
 		return ret;
-#endif		
+#endif
 	return 0;
 }
 
Index: linux-2.6/arch/ia64/kernel/efi.c
=================================--- linux-2.6.orig/arch/ia64/kernel/efi.c	2006-09-20 10:46:56.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/efi.c	2006-09-20 10:49:40.000000000 +0900
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
=================================--- linux-2.6.orig/arch/ia64/kernel/iosapic.c	2006-09-20 10:46:56.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/iosapic.c	2006-09-20 10:48:46.000000000 +0900
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
=================================--- linux-2.6.orig/arch/ia64/kernel/machine_kexec.c	2006-09-20 10:46:56.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/machine_kexec.c	2006-09-20 10:47:43.000000000 +0900
@@ -102,7 +102,7 @@
 
 	/* Interrupts aren't acceptable while we reboot */
 	local_irq_disable();
-	
+
 	/* Mask CMC and Performance Monitor interrupts */
 	ia64_setreg(_IA64_REG_CR_PMV, 1 << 16);
 	ia64_setreg(_IA64_REG_CR_CMCV, 1 << 16);
Index: linux-2.6/arch/ia64/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/kernel/setup.c	2006-09-20 10:46:56.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/setup.c	2006-09-20 10:47:07.000000000 +0900
@@ -258,7 +258,7 @@
 #ifdef CONFIG_KEXEC
 	/* crashkernel=size@offset specifies the size to reserve for a crash
 	 * kernel.(offset is ingored for keep compatibility with other archs)
-	 * By reserving this memory we guarantee that linux 
+	 * By reserving this memory we guarantee that linux
 	 * never set's it up as a DMA target.
 	 * Useful for holding code to do something appropriate
 	 * after a kernel panic.
@@ -270,7 +270,7 @@
 			size = memparse(from + 12, &from);
 			if (size) {
 				sort_regions(rsvd_region, n);
-				base = kdump_find_rsvd_region(size, 
+				base = kdump_find_rsvd_region(size,
 				rsvd_region, n);
 				if (base != ~0UL) {
 					rsvd_region[n].start Index: linux-2.6/include/asm-ia64/kexec.h
=================================--- linux-2.6.orig/include/asm-ia64/kexec.h	2006-09-20 10:46:56.000000000 +0900
+++ linux-2.6/include/asm-ia64/kexec.h	2006-09-20 10:47:30.000000000 +0900
@@ -44,7 +44,7 @@
 extern void kexec_disable_iosapic(void);
 extern void crash_save_this_cpu(void);
 struct rsvd_region;
-extern unsigned long kdump_find_rsvd_region(unsigned long size, 
+extern unsigned long kdump_find_rsvd_region(unsigned long size,
 		struct rsvd_region *rsvd_regions, int n);
 extern void kdump_cpu_freeze(struct unw_frame_info *info, void *arg);
 extern int kdump_status[];

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

