From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:19:03 +0000
Subject: [PATCH 48/50] ia64/pv_ops/xen: define xen pv_init_ops.
Message-Id: <12047411463299-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/xen_pv_ops.c |  194 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 194 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index 18aa2f6..a2a7493 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -58,6 +58,199 @@ xen_info_init(void)
 }
 
 /***************************************************************************
+ * pv_init_ops
+ * initialization hooks.
+ */
+
+static void
+xen_panic_hypercall(struct unw_frame_info *info, void *arg)
+{
+	current->thread.ksp = (__u64)info->sw - 16;
+	HYPERVISOR_shutdown(SHUTDOWN_crash);
+	/* we're never actually going to get here... */
+}
+
+static int
+xen_panic_event(struct notifier_block *this, unsigned long event, void *ptr)
+{
+	unw_init_running(xen_panic_hypercall, NULL);
+	/* we're never actually going to get here... */
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block xen_panic_block = {
+	xen_panic_event, NULL, 0 /* try to go last */
+};
+
+static void xen_pm_power_off(void)
+{
+	local_irq_disable();
+	HYPERVISOR_shutdown(SHUTDOWN_poweroff);
+}
+
+static void __init
+xen_banner(void)
+{
+	printk(KERN_INFO
+	       "Running on Xen! pl = %d start_info_pfn=0x%lx nr_pages=%ld "
+	       "flags=0x%x\n",
+	       xen_info.kernel_rpl,
+	       HYPERVISOR_shared_info->arch.start_info_pfn,
+	       xen_start_info->nr_pages, xen_start_info->flags);
+}
+
+static int __init
+xen_reserve_memory(struct rsvd_region *region)
+{
+	region->start = (unsigned long)__va((HYPERVISOR_shared_info->arch.start_info_pfn << PAGE_SHIFT));
+	region->end   = region->start + PAGE_SIZE;
+	return 1;
+}
+
+static void __init
+xen_arch_setup_early(void)
+{
+	struct shared_info *s;
+	BUG_ON(!is_running_on_xen());
+
+	s = HYPERVISOR_shared_info;
+	xen_start_info = __va(s->arch.start_info_pfn << PAGE_SHIFT);
+
+	/* Must be done before any hypercall.  */
+	xencomm_initialize();
+
+	xen_setup_features();
+	/* Register a call for panic conditions. */
+	atomic_notifier_chain_register(&panic_notifier_list,
+				       &xen_panic_block);
+	pm_power_off = xen_pm_power_off;
+
+	xen_ia64_enable_opt_feature();
+}
+
+static void __init
+xen_arch_setup_console(char **cmdline_p)
+{
+	/*
+	 * If a console= is NOT specified, we assume using the
+	 * xencons console is desired.  By default, this is xvc0
+	 * for both dom0 and domU.
+	 */
+	if (!strstr(*cmdline_p, "console=")) {
+		char *p, *q, name[5] = "xvc";
+		int offset = 0;
+
+#if defined(CONFIG_VGA_CONSOLE)
+		/*
+		 * conswitchp might be set intelligently from the
+		 * PCDP code.  If set to VGA console, use it.
+		 */
+		if (is_initial_xendomain() && conswitchp = &vga_con)
+			strncpy(name, "tty", 3);
+#endif
+
+		p = strstr(*cmdline_p, "xencons=");
+
+		if (p) {
+			p += 8;
+			if (!strncmp(p, "ttyS", 4)) {
+				strncpy(name, p, 4);
+				p += 4;
+				offset = simple_strtol(p, &q, 10);
+				if (p = q)
+					offset = 0;
+			} else if (!strncmp(p, "tty", 3) ||
+				   !strncmp(p, "xvc", 3)) {
+				strncpy(name, p, 3);
+				p += 3;
+				offset = simple_strtol(p, &q, 10);
+				if (p = q)
+					offset = 0;
+			} else if (!strncmp(p, "off", 3))
+				offset = -1;
+		}
+
+		if (offset >= 0)
+			add_preferred_console(name, offset, NULL);
+	} else if (!is_initial_xendomain()) {
+		/* use hvc_xen */
+		add_preferred_console("hvc", 0, NULL);
+	}
+
+#if !defined(CONFIG_VT) || !defined(CONFIG_DUMMY_CONSOLE)
+	if (!is_initial_xendomain()) {
+		conswitchp = NULL;
+	}
+#endif
+}
+
+static int __init
+xen_arch_setup_nomca(void)
+{
+	if (!is_initial_xendomain())
+		return 1;
+	return 0;
+}
+
+static void __init
+xen_post_platform_setup(void)
+{
+#ifdef CONFIG_XEN_PRIVILEGED_GUEST
+	if (is_running_on_xen() && !ia64_platform_is("xen")) {
+		extern ia64_mv_setup_t xen_setup;
+		xen_setup(cmdline_p);
+	}
+#endif
+}
+
+static void __init
+xen_post_paging_init(void)
+{
+#ifdef notyet /* XXX: notyet dma api paravirtualization*/
+#ifdef CONFIG_XEN
+	xen_contiguous_bitmap_init(max_pfn);
+#endif
+#endif
+}
+
+static void __init
+__xen_cpu_init(void)
+{
+#ifdef CONFIG_XEN_PRIVILEGED_GUEST
+	if (is_running_on_xen() && !ia64_platform_is("xen")) {
+		extern ia64_mv_cpu_init_t xen_cpu_init;
+		xen_cpu_init();
+	}
+#endif
+}
+
+static void __init
+xen_post_smp_prepare_boot_cpu(void)
+{
+	xen_setup_vcpu_info_placement();
+}
+
+static const struct pv_init_ops xen_init_ops __initdata = {
+	.banner = xen_banner,
+
+	.reserve_memory = xen_reserve_memory,
+
+	.arch_setup_early = xen_arch_setup_early,
+	.arch_setup_console = xen_arch_setup_console,
+	.arch_setup_nomca = xen_arch_setup_nomca,
+	.post_platform_setup = xen_post_platform_setup,
+	.post_paging_init = xen_post_paging_init,
+
+	.cpu_init = __xen_cpu_init,
+
+	.post_smp_prepare_boot_cpu = xen_post_smp_prepare_boot_cpu,
+
+	.bundle_patch_module = &xen_alt_bundle_patch_module,
+	.inst_patch_module = &xen_alt_inst_patch_module,
+};
+
+
+/***************************************************************************
  * pv_ops initialization
  */
 
@@ -66,4 +259,5 @@ xen_setup_pv_ops(void)
 {
 	xen_info_init();
 	pv_info = xen_info;
+	pv_init_ops = xen_init_ops;
 }
-- 
1.5.3

