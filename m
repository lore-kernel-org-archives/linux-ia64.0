From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 15 Sep 2005 05:36:35 +0000
Subject: Remove warnings for gcc 4.0 IA64 compilation.
Message-Id: <17193.2147.591751.129603@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The appended patch removes some compilation warnings, mostly
trivially.

Signed-off-by; Peter Chubb <peterc@gelato.unsw.edu.au>

Index: linux-2.6-import/arch/ia64/kernel/acpi.c
=================================--- linux-2.6-import.orig/arch/ia64/kernel/acpi.c	2005-09-09 12:43:30.166366764 +1000
+++ linux-2.6-import/arch/ia64/kernel/acpi.c	2005-09-15 13:01:04.281898032 +1000
@@ -892,21 +892,21 @@ acpi_map_iosapic(acpi_handle handle, u32
 }
 #endif				/* CONFIG_NUMA */
 
 int acpi_register_ioapic(acpi_handle handle, u64 phys_addr, u32 gsi_base)
 {
 	int err;
 
 	if ((err = iosapic_init(phys_addr, gsi_base)))
 		return err;
 
-#if CONFIG_ACPI_NUMA
+#ifdef CONFIG_ACPI_NUMA
 	acpi_map_iosapic(handle, 0, NULL, NULL);
 #endif				/* CONFIG_ACPI_NUMA */
 
 	return 0;
 }
 
 EXPORT_SYMBOL(acpi_register_ioapic);
 
 int acpi_unregister_ioapic(acpi_handle handle, u32 gsi_base)
 {
Index: linux-2.6-import/arch/ia64/kernel/entry.S
=================================--- linux-2.6-import.orig/arch/ia64/kernel/entry.S	2005-09-12 10:26:38.383367114 +1000
+++ linux-2.6-import/arch/ia64/kernel/entry.S	2005-09-15 13:01:42.265576317 +1000
@@ -484,21 +484,21 @@ GLOBAL_ENTRY(prefetch_stack)
 	lfetch.fault [r16], 128
 	;;
 	lfetch.fault.excl [r14], 128
 	lfetch.fault [r16], 128
 	;;
 	lfetch.fault.excl [r14], 128
 	lfetch.fault [r16], 128
 	;;
 	lfetch.fault [r16], 128
 	br.ret.sptk.many rp
-END(prefetch_switch_stack)
+END(prefetch_stack)
 
 GLOBAL_ENTRY(execve)
 	mov r15=__NR_execve			// put syscall number in place
 	break __BREAK_SYSCALL
 	br.ret.sptk.many rp
 END(execve)
 
 GLOBAL_ENTRY(clone)
 	mov r15=__NR_clone			// put syscall number in place
 	break __BREAK_SYSCALL
Index: linux-2.6-import/arch/ia64/kernel/perfmon.c
=================================--- linux-2.6-import.orig/arch/ia64/kernel/perfmon.c	2005-09-12 10:26:38.415366925 +1000
+++ linux-2.6-import/arch/ia64/kernel/perfmon.c	2005-09-15 13:05:36.651604242 +1000
@@ -567,21 +567,21 @@ pfm_unreserve_page(unsigned long a)
 	ClearPageReserved(vmalloc_to_page((void*)a));
 }
 
 static inline unsigned long
 pfm_protect_ctx_ctxsw(pfm_context_t *x)
 {
 	spin_lock(&(x)->ctx_lock);
 	return 0UL;
 }
 
-static inline unsigned long
+static inline void
 pfm_unprotect_ctx_ctxsw(pfm_context_t *x, unsigned long f)
 {
 	spin_unlock(&(x)->ctx_lock);
 }
 
 static inline unsigned int
 pfm_do_munmap(struct mm_struct *mm, unsigned long addr, size_t len, int acct)
 {
 	return do_munmap(mm, addr, len);
 }
Index: linux-2.6-import/arch/ia64/kernel/time.c
=================================--- linux-2.6-import.orig/arch/ia64/kernel/time.c	2005-07-28 11:17:28.748959464 +1000
+++ linux-2.6-import/arch/ia64/kernel/time.c	2005-09-15 13:04:49.847996264 +1000
@@ -185,21 +185,21 @@ ia64_init_itm (void)
 		platform_base_drift = -1;
 	}
 	if (!proc_ratio.den)
 		proc_ratio.den = 1;	/* avoid division by zero */
 	if (!itc_ratio.den)
 		itc_ratio.den = 1;	/* avoid division by zero */
 
 	itc_freq = (platform_base_freq*itc_ratio.num)/itc_ratio.den;
 
 	local_cpu_data->itm_delta = (itc_freq + HZ/2) / HZ;
-	printk(KERN_DEBUG "CPU %d: base freq=%lu.%03luMHz, ITC ratio=%lu/%lu, "
+	printk(KERN_DEBUG "CPU %d: base freq=%lu.%03luMHz, ITC ratio=%u/%u, "
 	       "ITC freq=%lu.%03luMHz", smp_processor_id(),
 	       platform_base_freq / 1000000, (platform_base_freq / 1000) % 1000,
 	       itc_ratio.num, itc_ratio.den, itc_freq / 1000000, (itc_freq / 1000) % 1000);
 
 	if (platform_base_drift != -1) {
 		itc_drift = platform_base_drift*itc_ratio.num/itc_ratio.den;
 		printk("+/-%ldppm\n", itc_drift);
 	} else {
 		itc_drift = -1;
 		printk("\n");
Index: linux-2.6-import/drivers/char/agp/hp-agp.c
=================================--- linux-2.6-import.orig/drivers/char/agp/hp-agp.c	2005-07-28 11:17:46.800825682 +1000
+++ linux-2.6-import/drivers/char/agp/hp-agp.c	2005-09-15 13:15:49.802544884 +1000
@@ -245,21 +245,21 @@ hp_zx1_configure (void)
 
 	agp_bridge->gart_bus_addr = hp->gart_base;
 	agp_bridge->capndx = hp->lba_cap_offset;
 	agp_bridge->mode = readl(hp->lba_regs+hp->lba_cap_offset+PCI_AGP_STATUS);
 
 	if (hp->io_pdir_owner) {
 		writel(virt_to_gart(hp->io_pdir), hp->ioc_regs+HP_ZX1_PDIR_BASE);
 		readl(hp->ioc_regs+HP_ZX1_PDIR_BASE);
 		writel(hp->io_tlb_ps, hp->ioc_regs+HP_ZX1_TCNFG);
 		readl(hp->ioc_regs+HP_ZX1_TCNFG);
-		writel(~(HP_ZX1_IOVA_SIZE-1), hp->ioc_regs+HP_ZX1_IMASK);
+		writel((unsigned int)(~(HP_ZX1_IOVA_SIZE-1)), hp->ioc_regs+HP_ZX1_IMASK);
 		readl(hp->ioc_regs+HP_ZX1_IMASK);
 		writel(hp->iova_base|1, hp->ioc_regs+HP_ZX1_IBASE);
 		readl(hp->ioc_regs+HP_ZX1_IBASE);
 		writel(hp->iova_base|log2(HP_ZX1_IOVA_SIZE), hp->ioc_regs+HP_ZX1_PCOM);
 		readl(hp->ioc_regs+HP_ZX1_PCOM);
 	}
 
 	return 0;
 }
 

