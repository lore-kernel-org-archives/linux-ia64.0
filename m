From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 10 Jun 2008 07:47:10 +0000
Subject: [PATCH 14/27] ia64/pv_ops/xen: define xen pv_init_ops for various xen initialization.
Message-Id: <12130840444151-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch implements xen version of pv_init_ops to do various
xen initialization.
This patch includes ia64 counter part of
9e124fe16ff24746d6de5a2ad685266d7bce0e08 and
83abc70a4c6e306f4c1672e25884322f797e4fcb for xen early printk support.

Signed-off-by: Akio Takebe <takebe_akio@jp.fujitsu.com>
Signed-off-by: Alex Williamson <alex.williamson@hp.com>
Signed-off-by: Yaozu (Eddie) Dong <eddie.dong@intel.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/Makefile            |    2 +-
 arch/ia64/xen/hypervisor.c        |   96 ++++++++++++++++++++++++++++++++
 arch/ia64/xen/xen_pv_ops.c        |  110 +++++++++++++++++++++++++++++++++++++
 include/asm-ia64/xen/hypervisor.h |   72 ++++++++++++++++++++++++
 4 files changed, 279 insertions(+), 1 deletions(-)
 create mode 100644 arch/ia64/xen/hypervisor.c
 create mode 100644 include/asm-ia64/xen/hypervisor.h

diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
index abc356f..7cb4247 100644
--- a/arch/ia64/xen/Makefile
+++ b/arch/ia64/xen/Makefile
@@ -3,4 +3,4 @@
 #
 
 obj-y := hypercall.o xensetup.o xen_pv_ops.o \
-	xencomm.o xcom_hcall.o grant-table.o
+	 hypervisor.o xencomm.o xcom_hcall.o grant-table.o
diff --git a/arch/ia64/xen/hypervisor.c b/arch/ia64/xen/hypervisor.c
new file mode 100644
index 0000000..b48595e
--- /dev/null
+++ b/arch/ia64/xen/hypervisor.c
@@ -0,0 +1,96 @@
+/******************************************************************************
+ * arch/ia64/xen/hypervisor.c
+ *
+ * Copyright (c) 2006 Isaku Yamahata <yamahata at valinux co jp>
+ *                    VA Linux Systems Japan K.K.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#include <linux/efi.h>
+#include <asm/xen/hypervisor.h>
+#include <asm/xen/privop.h>
+
+#include "irq_xen.h"
+
+struct shared_info *HYPERVISOR_shared_info __read_mostly +	(struct shared_info *)XSI_BASE;
+EXPORT_SYMBOL(HYPERVISOR_shared_info);
+
+DEFINE_PER_CPU(struct vcpu_info *, xen_vcpu);
+
+struct start_info *xen_start_info;
+EXPORT_SYMBOL(xen_start_info);
+
+EXPORT_SYMBOL(running_on_xen);
+
+EXPORT_SYMBOL(__hypercall);
+
+/* Stolen from arch/x86/xen/enlighten.c */
+/*
+ * Flag to determine whether vcpu info placement is available on all
+ * VCPUs.  We assume it is to start with, and then set it to zero on
+ * the first failure.  This is because it can succeed on some VCPUs
+ * and not others, since it can involve hypervisor memory allocation,
+ * or because the guest failed to guarantee all the appropriate
+ * constraints on all VCPUs (ie buffer can't cross a page boundary).
+ *
+ * Note that any particular CPU may be using a placed vcpu structure,
+ * but we can only optimise if the all are.
+ *
+ * 0: not available, 1: available
+ */
+
+static void __init xen_vcpu_setup(int cpu)
+{
+	/*
+	 * WARNING:
+	 * before changing MAX_VIRT_CPUS,
+	 * check that shared_info fits on a page
+	 */
+	BUILD_BUG_ON(sizeof(struct shared_info) > PAGE_SIZE);
+	per_cpu(xen_vcpu, cpu) = &HYPERVISOR_shared_info->vcpu_info[cpu];
+}
+
+void __init xen_setup_vcpu_info_placement(void)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		xen_vcpu_setup(cpu);
+}
+
+void __cpuinit
+xen_cpu_init(void)
+{
+	xen_smp_intr_init();
+}
+
+/**************************************************************************
+ * opt feature
+ */
+void
+xen_ia64_enable_opt_feature(void)
+{
+	/* Enable region 7 identity map optimizations in Xen */
+	struct xen_ia64_opt_feature optf;
+
+	optf.cmd = XEN_IA64_OPTF_IDENT_MAP_REG7;
+	optf.on = XEN_IA64_OPTF_ON;
+	optf.pgprot = pgprot_val(PAGE_KERNEL);
+	optf.key = 0;	/* No key on linux. */
+	HYPERVISOR_opt_feature(&optf);
+}
diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index 77db214..433af1a 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -54,6 +54,115 @@ xen_info_init(void)
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
+	region->start = (unsigned long)__va(
+		(HYPERVISOR_shared_info->arch.start_info_pfn << PAGE_SHIFT));
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
+	add_preferred_console("xenboot", 0, NULL);
+	add_preferred_console("tty", 0, NULL);
+	/* use hvc_xen */
+	add_preferred_console("hvc", 0, NULL);
+
+#if !defined(CONFIG_VT) || !defined(CONFIG_DUMMY_CONSOLE)
+	conswitchp = NULL;
+#endif
+}
+
+static int __init
+xen_arch_setup_nomca(void)
+{
+	return 1;
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
+
+	.post_smp_prepare_boot_cpu = xen_post_smp_prepare_boot_cpu,
+};
+
+/***************************************************************************
  * pv_ops initialization
  */
 
@@ -62,4 +171,5 @@ xen_setup_pv_ops(void)
 {
 	xen_info_init();
 	pv_info = xen_info;
+	pv_init_ops = xen_init_ops;
 }
diff --git a/include/asm-ia64/xen/hypervisor.h b/include/asm-ia64/xen/hypervisor.h
new file mode 100644
index 0000000..a7527c2
--- /dev/null
+++ b/include/asm-ia64/xen/hypervisor.h
@@ -0,0 +1,72 @@
+/******************************************************************************
+ * hypervisor.h
+ *
+ * Linux-specific hypervisor handling.
+ *
+ * Copyright (c) 2002-2004, K A Fraser
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#ifndef _ASM_IA64_XEN_HYPERVISOR_H
+#define _ASM_IA64_XEN_HYPERVISOR_H
+
+#ifdef CONFIG_XEN
+
+#include <linux/init.h>
+#include <xen/interface/xen.h>
+#include <xen/interface/version.h>	/* to compile feature.c */
+#include <xen/features.h>		/* to comiple xen-netfront.c */
+#include <asm/xen/hypercall.h>
+
+/* running_on_xen is set before executing any C code by early_xen_setup */
+extern const int running_on_xen;
+# define is_running_on_xen()			(running_on_xen)
+
+extern struct shared_info *HYPERVISOR_shared_info;
+extern struct start_info *xen_start_info;
+
+void __init xen_setup_vcpu_info_placement(void);
+void force_evtchn_callback(void);
+
+/* for drivers/xen/balloon/balloon.c */
+#ifdef CONFIG_XEN_SCRUB_PAGES
+#define scrub_pages(_p, _n) memset((void *)(_p), 0, (_n) << PAGE_SHIFT)
+#else
+#define scrub_pages(_p, _n) ((void)0)
+#endif
+
+/* For setup_arch() in arch/ia64/kernel/setup.c */
+void xen_ia64_enable_opt_feature(void);
+
+#else /* CONFIG_XEN */
+
+#define is_running_on_xen()			(0)
+
+#endif
+
+#define is_initial_xendomain()			(0)
+
+#endif /* _ASM_IA64_XEN_HYPERVISOR_H */
-- 
1.5.3

