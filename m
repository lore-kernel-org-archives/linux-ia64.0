From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 19 May 2008 13:13:41 +0000
Subject: [PATCH 14/17] ia64/pv_ops: define initialization hooks, pv_init_ops, for paravirtualized environment
Message-Id: <12112028252465-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

define pv_init_ops hooks which represents various initialization
hooks for paravirtualized environment. and add hooks.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/paravirt.c |    7 ++++
 arch/ia64/kernel/setup.c    |   10 ++++++
 arch/ia64/kernel/smpboot.c  |    2 +
 include/asm-ia64/paravirt.h |   70 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 89 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
index 7126ea8..5daf659 100644
--- a/arch/ia64/kernel/paravirt.c
+++ b/arch/ia64/kernel/paravirt.c
@@ -42,6 +42,13 @@ struct pv_info pv_info = {
 };
 
 /***************************************************************************
+ * pv_init_ops
+ * initialization hooks.
+ */
+
+struct pv_init_ops pv_init_ops;
+
+/***************************************************************************
  * pv_cpu_ops
  * intrinsics hooks.
  */
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index e9596cd..9173add 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -51,6 +51,7 @@
 #include <asm/mca.h>
 #include <asm/meminit.h>
 #include <asm/page.h>
+#include <asm/paravirt.h>
 #include <asm/patch.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
@@ -341,6 +342,8 @@ reserve_memory (void)
 	rsvd_region[n].end   = (unsigned long) ia64_imva(_end);
 	n++;
 
+	n += paravirt_reserve_memory(&rsvd_region[n]);
+
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (ia64_boot_param->initrd_start) {
 		rsvd_region[n].start = (unsigned long)__va(ia64_boot_param->initrd_start);
@@ -519,6 +522,8 @@ setup_arch (char **cmdline_p)
 {
 	unw_init();
 
+	paravirt_arch_setup_early();
+
 	ia64_patch_vtop((u64) __start___vtop_patchlist, (u64) __end___vtop_patchlist);
 
 	*cmdline_p = __va(ia64_boot_param->command_line);
@@ -573,6 +578,9 @@ setup_arch (char **cmdline_p)
 	acpi_boot_init();
 #endif
 
+	paravirt_banner();
+	paravirt_arch_setup_console(cmdline_p);
+
 #ifdef CONFIG_VT
 	if (!conswitchp) {
 # if defined(CONFIG_DUMMY_CONSOLE)
@@ -592,6 +600,8 @@ setup_arch (char **cmdline_p)
 #endif
 
 	/* enable IA-64 Machine Check Abort Handling unless disabled */
+	if (paravirt_arch_setup_nomca())
+		nomca = 1;
 	if (!nomca)
 		ia64_mca_init();
 
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index d7ad42b..933f388 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -50,6 +50,7 @@
 #include <asm/machvec.h>
 #include <asm/mca.h>
 #include <asm/page.h>
+#include <asm/paravirt.h>
 #include <asm/pgalloc.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
@@ -642,6 +643,7 @@ void __devinit smp_prepare_boot_cpu(void)
 	cpu_set(smp_processor_id(), cpu_online_map);
 	cpu_set(smp_processor_id(), cpu_callin_map);
 	per_cpu(cpu_state, smp_processor_id()) = CPU_ONLINE;
+	paravirt_post_smp_prepare_boot_cpu();
 }
 
 #ifdef CONFIG_HOTPLUG_CPU
diff --git a/include/asm-ia64/paravirt.h b/include/asm-ia64/paravirt.h
index 1032b21..84d74c3 100644
--- a/include/asm-ia64/paravirt.h
+++ b/include/asm-ia64/paravirt.h
@@ -55,11 +55,81 @@ static inline unsigned int get_kernel_rpl(void)
 	return pv_info.kernel_rpl;
 }
 
+/******************************************************************************
+ * initialization hooks.
+ */
+struct rsvd_region;
+
+struct pv_init_ops {
+	void (*banner)(void);
+
+	int (*reserve_memory)(struct rsvd_region *region);
+
+	void (*arch_setup_early)(void);
+	void (*arch_setup_console)(char **cmdline_p);
+	int (*arch_setup_nomca)(void);
+
+	void (*post_smp_prepare_boot_cpu)(void);
+};
+
+extern struct pv_init_ops pv_init_ops;
+
+static inline void paravirt_banner(void)
+{
+	if (pv_init_ops.banner)
+		pv_init_ops.banner();
+}
+
+static inline int paravirt_reserve_memory(struct rsvd_region *region)
+{
+	if (pv_init_ops.reserve_memory)
+		return pv_init_ops.reserve_memory(region);
+	return 0;
+}
+
+static inline void paravirt_arch_setup_early(void)
+{
+	if (pv_init_ops.arch_setup_early)
+		pv_init_ops.arch_setup_early();
+}
+
+static inline void paravirt_arch_setup_console(char **cmdline_p)
+{
+	if (pv_init_ops.arch_setup_console)
+		pv_init_ops.arch_setup_console(cmdline_p);
+}
+
+static inline int paravirt_arch_setup_nomca(void)
+{
+	if (pv_init_ops.arch_setup_nomca)
+		return pv_init_ops.arch_setup_nomca();
+	return 0;
+}
+
+static inline void paravirt_post_smp_prepare_boot_cpu(void)
+{
+	if (pv_init_ops.post_smp_prepare_boot_cpu)
+		pv_init_ops.post_smp_prepare_boot_cpu();
+}
+
 #endif /* !__ASSEMBLY__ */
 
 #else
 /* fallback for native case */
 
+#ifndef __ASSEMBLY__
+
+#define paravirt_banner()				do { } while (0)
+#define paravirt_reserve_memory(region)			0
+
+#define paravirt_arch_setup_early()			do { } while (0)
+#define paravirt_arch_setup_console(cmdline_p)		do { } while (0)
+#define paravirt_arch_setup_nomca()			0
+#define paravirt_post_smp_prepare_boot_cpu()		do { } while (0)
+
+#endif /* __ASSEMBLY__ */
+
+
 #endif /* CONFIG_PARAVIRT_GUEST */
 
 #endif /* __ASM_PARAVIRT_H */
-- 
1.5.3

