From: Horms <horms@verge.net.au>
Date: Wed, 20 Sep 2006 02:51:43 +0000
Subject: Re: [Patch] IA64 Kexec/Kdump patch for 2.6.18-rc6
Message-Id: <20060920025143.78E043403B@koto.vergenet.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1158288948.2591.195.camel@linux-znh>
In-Reply-To: <1158288948.2591.195.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

here is an incremental version of this patch.
It is incremental against the previous version that you posted
according to my records.

The entire series, for 2.6.18-rc6 or Tony Luck's ia64 test branch
can be found at http://www.vergenet.net/~horms/patches/ia64-kexec/kernel/

Tony, Nan Hai, do you have any thoughts on merging this
series into ia64 test? Its really far to big to be managed
as a single unit. I would be much more comfortable if
we could track small incremental changes. Even the diff
between the current and previous version (as below) is quite large.

Alternatively, if an ia64 kexec tree, branched either of ia64-test,
or Linus' tree is better then I am happy to set that up.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

[IA64] Kexec/Kdump patch for 2.6.18-rc6

> From: Zou Nan hai <nanhai.zou@intel.com>
> Subject: [Patch] IA64 Kexec/Kdump patch for 2.6.18-rc6
> Archived-At: http://permalink.gmane.org/gmane.linux.ports.ia64/14988
> 
> Hi,
>    Here is a new version of IA64 Kexec/Kdump patch.
>    Update since last patch.
> 
>    1. Ignore offset in crashkernel=size@offset kernel parameter. kernel
> will find crashkernel region according to size at boot time. However
> crashkernel parameter format is not changed to keep compatibility with
> other archs
>    2. send EOI to iosapic
>    3. Patch from HP to clean interrupt at shutdown time.
>    4. Enhanced OS_INIT handle patch base on Takao Indoh\011and comments
> from Keith Owens.
> 
> signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

This is an incremental version of the above patch

Signed-Off-By: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/Kconfig
=================================--- linux-2.6.orig/arch/ia64/Kconfig	2006-09-20 10:44:38.000000000 +0900
+++ linux-2.6/arch/ia64/Kconfig	2006-09-20 10:45:16.000000000 +0900
@@ -444,7 +446,7 @@
 
 config CRASH_DUMP
 	  bool "kernel crash dumps (EXPERIMENTAL)"
-	  depends on EXPERIMENTAL
+	  depends on EXPERIMENTAL && IA64_MCA_RECOVERY
 	  help
 	    Generate crash dump after being started by kexec.
 
Index: linux-2.6/arch/ia64/kernel/crash.c
=================================--- linux-2.6.orig/arch/ia64/kernel/crash.c	2006-09-20 10:44:38.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/crash.c	2006-09-20 10:45:16.000000000 +0900
@@ -8,44 +8,39 @@
  * Copyright (C) 2005 Intel Corp	Zou Nan hai <nanhai.zou@intel.com>
  *
  */
-#include <linux/init.h>
-#include <linux/types.h>
-#include <linux/kernel.h>
 #include <linux/smp.h>
-#include <linux/irq.h>
-#include <linux/pci.h>
-#include <linux/reboot.h>
-#include <linux/kexec.h>
-#include <linux/irq.h>
 #include <linux/delay.h>
-#include <linux/elf.h>
+#include <linux/crash_dump.h>
+#include <linux/bootmem.h>
+#include <linux/kexec.h>
 #include <linux/elfcore.h>
-#include <linux/device.h>
-#include <asm/uaccess.h>
+#include <linux/sysctl.h>
+#include <linux/init.h>
 
-size_t copy_oldmem_page(unsigned long pfn, char *buf,
-                               size_t csize, unsigned long offset, int userbuf)
-{
-        void  *vaddr;
+#include <asm/kdebug.h>
+#include <asm/mca.h>
+#include <asm/uaccess.h>
 
-        if (!csize)
-                return 0;
-        vaddr = __va(pfn<<PAGE_SHIFT);
-        if (userbuf) {
-                if (copy_to_user(buf, (vaddr + offset), csize)) {
-                        return -EFAULT;
-                }
-        } else
-                memcpy(buf, (vaddr + offset), csize);
-        return csize;
-}
-
-static void device_shootdown(void)
-{
-	kdump_disable_iosapic();
-#ifdef CONFIG_IA64_HP_ZX1
-	ioc_iova_disable();
-#endif
+int kdump_status[NR_CPUS];
+atomic_t kdump_cpu_freezed;
+int kdump_on_init = 1;
+
+ssize_t 
+copy_oldmem_page(unsigned long pfn, char *buf,
+		size_t csize, unsigned long offset, int userbuf)
+{
+	void  *vaddr;
+
+	if (!csize)
+		return 0;
+	vaddr = __va(pfn<<PAGE_SHIFT);
+	if (userbuf) {
+		if (copy_to_user(buf, (vaddr + offset), csize)) {
+			return -EFAULT;
+		}
+	} else
+		memcpy(buf, (vaddr + offset), csize);
+	return csize;
 }
 
 static inline Elf64_Word
@@ -88,20 +83,33 @@
 	prstatus->pr_pid = current->pid;
 
 	ia64_dump_cpu_regs(dst);
-        cfm = dst[43];
-        sol = (cfm >> 7) & 0x7f;
-        sof = cfm & 0x7f;
-        dst[46] = (unsigned long)ia64_rse_skip_regs((unsigned long *)dst[46],
-                        sof - sol);
+	cfm = dst[43];
+	sol = (cfm >> 7) & 0x7f;
+	sof = cfm & 0x7f;
+	dst[46] = (unsigned long)ia64_rse_skip_regs((unsigned long *)dst[46],
+			sof - sol);
 
-        buf = (u64 *) per_cpu_ptr(crash_notes, cpu);
+	buf = (u64 *) per_cpu_ptr(crash_notes, cpu);
 	if (!buf)
 		return;
 	buf = append_elf_note(buf, "CORE", NT_PRSTATUS, prstatus,
-		sizeof(*prstatus));
+			sizeof(*prstatus));
 	final_note(buf);
 }
 
+static int
+kdump_wait_cpu_freeze(void)
+{
+	int cpu_num = num_online_cpus() - 1;
+	int timeout = 1000;
+	while(timeout-- > 0) {
+		if (atomic_read(&kdump_cpu_freezed) = cpu_num)
+			return 0;
+		udelay(1000);
+	}
+	return 1;
+}
+
 void
 machine_crash_shutdown(struct pt_regs *pt)
 {
@@ -113,11 +121,104 @@
 	 * In practice this means shooting down the other cpus in
 	 * an SMP system.
 	 */
-	if (in_interrupt())
-		ia64_eoi();
-	device_shootdown();
+	kexec_disable_iosapic();
 #ifdef CONFIG_SMP
 	kdump_smp_send_stop();
+	if (kdump_wait_cpu_freeze() && kdump_on_init) 	{
+		//not all cpu response to IPI, send INIT to freeze them
+		kdump_smp_send_init();
+	}
 #endif
-	udelay(1000000);
 }
+
+static void 
+machine_kdump_on_init(void)
+{
+	local_irq_disable();
+	kexec_disable_iosapic();
+	machine_kexec(ia64_kimage);
+}
+
+void
+kdump_cpu_freeze(struct unw_frame_info *info, void *arg)
+{
+	local_irq_disable();
+	crash_save_this_cpu();
+	current->thread.ksp = (__u64)info->sw - 16;
+	atomic_inc(&kdump_cpu_freezed);
+	kdump_status[smp_processor_id()] = 1;
+	mb();
+	for (;;)
+		cpu_relax();
+}
+
+static int
+kdump_init_notifier(struct notifier_block *self, unsigned long val, void *data)
+{
+	struct ia64_mca_notify_die *nd;
+	struct die_args *args = data;
+
+	if (!kdump_on_init)
+		return NOTIFY_DONE;
+	nd = (struct ia64_mca_notify_die *)args->err;
+	/* Reason code 1 means machine check rendezous*/
+	if (nd->sos->rv_rc = 1)
+		return NOTIFY_DONE;
+
+	switch (val) {
+		case DIE_INIT_MONARCH_ENTER:
+			machine_kdump_on_init();
+			break;	
+		case DIE_INIT_SLAVE_ENTER:
+			unw_init_running(kdump_cpu_freeze, NULL);
+			break;
+	}
+	return NOTIFY_DONE;
+}
+
+#ifdef CONFIG_SYSCTL
+static ctl_table kdump_on_init_table[] = {
+	{ 
+		.ctl_name = KERN_KDUMP_ON_INIT, 
+		.procname = "kdump_on_init",
+		.data = &kdump_on_init, 
+		.maxlen = sizeof(int),
+		.mode = 0644, 
+		.proc_handler = &proc_dointvec,
+	},
+	{ .ctl_name = 0 }
+};
+
+static ctl_table sys_table[] = {
+	{
+	  .ctl_name = CTL_KERN, 
+	  .procname = "kernel",
+	  .mode = 0555, 
+	  .child = kdump_on_init_table,
+	},
+	{ .ctl_name = 0 }
+};
+#endif
+
+static int
+machine_crash_setup(void)
+{
+	char *from = strstr(saved_command_line, "elfcorehdr=");
+	static struct notifier_block kdump_init_notifier_nb = {
+		.notifier_call = kdump_init_notifier,
+	};
+	int ret;
+	if (from)
+		elfcorehdr_addr = memparse(from+11, &from);
+	saved_max_pfn = (unsigned long)-1;
+	if((ret = register_die_notifier(&kdump_init_notifier_nb)) != 0)
+		return ret;
+#ifdef CONFIG_SYSCTL
+	if ((ret = register_sysctl_table(sys_table, 0)) != 0)
+		return ret;
+#endif		
+	return 0;
+}
+
+__initcall(machine_crash_setup);
+
Index: linux-2.6/arch/ia64/kernel/efi.c
=================================--- linux-2.6.orig/arch/ia64/kernel/efi.c	2006-09-20 10:44:38.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/efi.c	2006-09-20 10:45:16.000000000 +0900
@@ -1126,9 +1126,55 @@
 #ifdef CONFIG_KEXEC
                         insert_resource(res, &efi_memmap_res);
                         insert_resource(res, &boot_param_res);
-			if (crashk_res.end > crashk_res.start)
+			if (crashk_res.end > crashk_res.start) 
 				insert_resource(res, &crashk_res);
 #endif
 		}
 	}
 }
+
+#ifdef CONFIG_KEXEC
+/* find a block of memory aligned to 64M exclude reserved regions
+   rsvd_regions are sorted
+ */
+unsigned long 
+kdump_find_rsvd_region (unsigned long size, 
+		struct rsvd_region *r, int n)
+{
+  int i;
+  u64 start, end; 
+  u64 alignment = 1UL << _PAGE_SIZE_64M;
+  void *efi_map_start, *efi_map_end, *p;
+  efi_memory_desc_t *md;
+  u64 efi_desc_size;
+
+  efi_map_start = __va(ia64_boot_param->efi_memmap);
+  efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+  efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+  for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+	  md = p;
+	  if (!efi_wb(md))
+		  continue;
+	  start = ALIGN(md->phys_addr, alignment);
+	  end = efi_md_end(md);
+	  for (i = 0; i < n; i++) {
+		if (__pa(r[i].start) >= start && __pa(r[i].end) < end) {
+			if (__pa(r[i].start) > start + size)
+				return start;
+			start = ALIGN(__pa(r[i].end), alignment);
+			if (i < n-1 && __pa(r[i+1].start) < start + size)
+				continue;
+			else
+				break;
+		}
+	  }
+	  if (end > start + size)
+		return start;
+  }
+
+  printk(KERN_WARNING "Cannot reserve 0x%lx byte of memory for crashdump\n", 
+	size);
+  return ~0UL;
+}
+#endif 
Index: linux-2.6/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.orig/arch/ia64/kernel/iosapic.c	2006-09-20 10:44:38.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/iosapic.c	2006-09-20 10:45:16.000000000 +0900
@@ -288,20 +288,22 @@
 	/* do nothing... */
 }
 
-#ifdef CONFIG_CRASH_DUMP
+
+#ifdef CONFIG_KEXEC
 void
-kdump_disable_iosapic(void)
+kexec_disable_iosapic(void)
 {
-	u32 low32;
 	struct iosapic_intr_info *info;
 	struct iosapic_rte_info *rte;
+	u8 vec;
 	for (info = iosapic_intr_info; info <
 			iosapic_intr_info + IA64_NUM_VECTORS; ++info) {
-		low32 = info->low32 |= IOSAPIC_MASK;
 		list_for_each_entry(rte, &info->rtes,
 				rte_list) {
 			iosapic_write(rte->addr,
-					IOSAPIC_RTE_LOW(rte->rte_index), low32);
+					IOSAPIC_RTE_LOW(rte->rte_index), 
+					IOSAPIC_MASK);
+			iosapic_eoi(rte->addr, vec);
 		}
 	}
 }
Index: linux-2.6/arch/ia64/kernel/machine_kexec.c
=================================--- linux-2.6.orig/arch/ia64/kernel/machine_kexec.c	2006-09-20 10:44:38.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/machine_kexec.c	2006-09-20 10:45:16.000000000 +0900
@@ -10,24 +10,20 @@
  * Version 2.  See the file COPYING for more details.
  */
 
-#include <linux/kernel.h>
-#include <linux/config.h>
 #include <linux/mm.h>
 #include <linux/kexec.h>
-#include <linux/pci.h>
 #include <linux/cpu.h>
+#include <linux/irq.h>
 #include <asm/mmu_context.h>
 #include <asm/setup.h>
-#include <asm/mca.h>
-#include <asm/page.h>
-#include <asm/bitops.h>
-#include <asm/tlbflush.h>
 #include <asm/delay.h>
 #include <asm/meminit.h>
 
 typedef void (*relocate_new_kernel_t)(unsigned long, unsigned long,
 		struct ia64_boot_param *, unsigned long);
-static struct kimage *ia64_kimage;
+
+struct kimage *ia64_kimage;
+
 struct resource efi_memmap_res = {
         .name  = "EFI Memory Map",
         .start = 0,
@@ -83,28 +79,7 @@
 #elif defined(CONFIG_SMP)
 	smp_call_function(kexec_stop_this_cpu, (void *)ia64_kimage->start, 0, 0);
 #endif
-#ifdef CONFIG_PCI
-	{
-		struct pci_dev *dev = NULL;
-		irq_desc_t *idesc;
-		/* Disable all PCI devices */
-		while ((dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL) {
-			if (!(dev->is_enabled))
-				continue;
-			idesc = irq_desc + dev->irq;
-			if (!idesc||!idesc->chip)
-				continue;
-			disable_irq_nosync(dev->irq);
-			idesc->chip->end(dev->irq);
-			idesc->action = NULL;
-			pci_disable_device(dev);
-		}
-	}
-#endif
-
-#ifdef CONFIG_IA64_HP_ZX1
-	ioc_iova_disable();
-#endif
+	kexec_disable_iosapic();
 }
 
 /*
@@ -118,14 +93,33 @@
 	relocate_new_kernel_t rnk;
 	void *pal_addr = efi_get_pal_addr();
 	unsigned long code_addr = (unsigned long)page_address(image->control_code_page);
+	unsigned long vector;
+
 	if (image->type = KEXEC_TYPE_CRASH) {
 		crash_save_this_cpu();
 		current->thread.ksp = (__u64)info->sw - 16;
 	}
 
 	/* Interrupts aren't acceptable while we reboot */
-	ia64_set_itv(1<<16);
 	local_irq_disable();
+	
+	/* Mask CMC and Performance Monitor interrupts */
+	ia64_setreg(_IA64_REG_CR_PMV, 1 << 16);
+	ia64_setreg(_IA64_REG_CR_CMCV, 1 << 16);
+
+	/* Mask ITV and Local Redirect Registers */
+	ia64_set_itv(1 << 16);
+	ia64_set_lrr0(1 << 16);
+	ia64_set_lrr1(1 << 16);
+
+	/* unmask TPR and clear any pending interrupts */
+	ia64_setreg(_IA64_REG_CR_TPR, 0);
+	ia64_srlz_d();
+	vector = ia64_get_ivr();
+	while (vector != IA64_SPURIOUS_INT_VECTOR) {
+		ia64_eoi();
+		vector = ia64_get_ivr();
+	}
 	rnk = (relocate_new_kernel_t)&code_addr;
 	(*rnk)(image->head, image->start, ia64_boot_param,
 		     GRANULEROUNDDOWN((unsigned long) pal_addr));
Index: linux-2.6/arch/ia64/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/kernel/setup.c	2006-09-20 10:44:38.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/setup.c	2006-09-20 10:45:16.000000000 +0900
@@ -252,27 +252,35 @@
 	}
 #endif
 
+	efi_memmap_init(&rsvd_region[n].start, &rsvd_region[n].end);
+	n++;
+
 #ifdef CONFIG_KEXEC
-	/* crashkernel=size@addr specifies the location to reserve for
-	 * a crash kernel.  By reserving this memory we guarantee
-	 * that linux never set's it up as a DMA target.
+	/* crashkernel=size@offset specifies the size to reserve for a crash
+	 * kernel.(offset is ingored for keep compatibility with other archs)
+	 * By reserving this memory we guarantee that linux 
+	 * never set's it up as a DMA target.
 	 * Useful for holding code to do something appropriate
 	 * after a kernel panic.
 	 */
 	{
 		char *from = strstr(saved_command_line, "crashkernel=");
+		unsigned long base, size;
 		if (from) {
-			unsigned long size, base;
 			size = memparse(from + 12, &from);
-			if (*from = '@') {
-				base = memparse(from + 1, &from);
-				rsvd_region[n].start -					(unsigned long)__va(base);
-				rsvd_region[n].end -					(unsigned long)__va(base + size);
-				crashk_res.start = base;
-				crashk_res.end = base + size - 1;
-				n++;
+			if (size) {
+				sort_regions(rsvd_region, n);
+				base = kdump_find_rsvd_region(size, 
+				rsvd_region, n);
+				if (base != ~0UL) {
+					rsvd_region[n].start +						(unsigned long)__va(base);
+					rsvd_region[n].end +						(unsigned long)__va(base + size);
+					n++;
+					crashk_res.start = base;
+					crashk_res.end = base + size - 1;
+				}
 			}
 		}
 		efi_memmap_res.start = ia64_boot_param->efi_memmap;
@@ -283,10 +291,6 @@
                         sizeof(*ia64_boot_param);
 	}
 #endif
-
-	efi_memmap_init(&rsvd_region[n].start, &rsvd_region[n].end);
-	n++;
-
 	/* end of memory marker */
 	rsvd_region[n].start = ~0UL;
 	rsvd_region[n].end   = ~0UL;
@@ -298,6 +302,7 @@
 	sort_regions(rsvd_region, num_rsvd_regions);
 }
 
+
 /**
  * find_initrd - get initrd parameters from the boot parameter structure
  *
@@ -518,16 +523,6 @@
 	if (!nomca)
 		ia64_mca_init();
 
-#ifdef CONFIG_CRASH_DUMP
-	{
-		char *from = strstr(saved_command_line, "elfcorehdr=");
-
-		if (from)
-			elfcorehdr_addr = memparse(from+11, &from);
-		saved_max_pfn = (unsigned long) -1;
-	}
-#endif
-
 	platform_setup(cmdline_p);
 	paging_init();
 }
Index: linux-2.6/arch/ia64/kernel/smp.c
=================================--- linux-2.6.orig/arch/ia64/kernel/smp.c	2006-09-20 10:44:38.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/smp.c	2006-09-20 10:45:16.000000000 +0900
@@ -126,19 +126,6 @@
 	cpu_halt();
 }
 
-#ifdef CONFIG_CRASH_DUMP
-static void 
-kdump_cpu_freeze(struct unw_frame_info *info, void *arg)
-{
-	local_irq_disable();
-	crash_save_this_cpu();
-	current->thread.ksp = (__u64)info->sw - 16;
-	for (;;)
-                ia64_hint(ia64_hint_pause);
-}
-#endif
-
-
 void
 cpu_die(void)
 {
@@ -266,6 +253,19 @@
 {
  	send_IPI_allbutself(IPI_KDUMP_CPU_STOP);
 }
+
+void
+kdump_smp_send_init()
+{
+	unsigned int cpu, self_cpu;
+	self_cpu = smp_processor_id();
+	for_each_online_cpu(cpu) {
+		if (cpu != self_cpu) {
+			if(kdump_status[cpu] = 0)
+				platform_send_ipi(cpu, 0, IA64_IPI_DM_INIT, 0);
+		}
+	}
+}
 #endif
 /*
  * Called with preeemption disabled.
Index: linux-2.6/include/asm-ia64/kexec.h
=================================--- linux-2.6.orig/include/asm-ia64/kexec.h	2006-09-20 10:44:38.000000000 +0900
+++ linux-2.6/include/asm-ia64/kexec.h	2006-09-20 10:45:16.000000000 +0900
@@ -25,6 +25,7 @@
                 flush_icache_range(page_addr, page_addr + PAGE_SIZE); \
         } while(0)
 
+extern struct kimage *ia64_kimage;
 DECLARE_PER_CPU(u64, ia64_mca_pal_base);
 const extern unsigned int relocate_new_kernel_size;
 volatile extern long kexec_rendez;
@@ -39,7 +40,14 @@
 extern struct resource efi_memmap_res;
 extern struct resource boot_param_res;
 extern void kdump_smp_send_stop(void);
-extern void kdump_disable_iosapic(void);
+extern void kdump_smp_send_init(void);
+extern void kexec_disable_iosapic(void);
 extern void crash_save_this_cpu(void);
+struct rsvd_region;
+extern unsigned long kdump_find_rsvd_region(unsigned long size, 
+		struct rsvd_region *rsvd_regions, int n);
+extern void kdump_cpu_freeze(struct unw_frame_info *info, void *arg);
+extern int kdump_status[];
+extern atomic_t kdump_cpu_freezed;
 
 #endif /* _ASM_IA64_KEXEC_H */
Index: linux-2.6/include/linux/sysctl.h
=================================--- linux-2.6.orig/include/linux/sysctl.h	2006-09-20 10:44:39.000000000 +0900
+++ linux-2.6/include/linux/sysctl.h	2006-09-20 10:45:16.000000000 +0900
@@ -150,6 +150,7 @@
 	KERN_IA64_UNALIGNEDr, /* int: ia64 unaligned userland trap enable */
 	KERN_COMPAT_LOGs,	/* int: print compat layer  messages */
 	KERN_MAX_LOCK_DEPTHt,
+	KERN_KDUMP_ON_INITu,	/* int: ia64 kdump with INIT */
 };
 
 
