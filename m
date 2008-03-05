From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:41 +0000
Subject: [PATCH 26/50] ia64/pv_ops: introduce pv_init_ops and its hooks.
Message-Id: <12047411464127-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/module.c   |   32 +++++++++++
 arch/ia64/kernel/paravirt.c |    8 +++
 arch/ia64/kernel/setup.c    |   14 +++++
 arch/ia64/kernel/smpboot.c  |    2 +
 include/asm-ia64/paravirt.h |  122 ++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 177 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index e58f436..edf7cca 100644
--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -454,6 +454,14 @@ module_frob_arch_sections (Elf_Ehdr *ehdr, Elf_Shdr *sechdrs, char *secstrings,
 			mod->arch.opd = s;
 		else if (strcmp(".IA_64.unwind", secstrings + s->sh_name) = 0)
 			mod->arch.unwind = s;
+#ifdef CONFIG_PARAVIRT_ALT
+		else if (strcmp(".paravirt_bundles",
+				secstrings + s->sh_name) = 0)
+			mod->arch.paravirt_bundles = s;
+		else if (strcmp(".paravirt_insts",
+				secstrings + s->sh_name) = 0)
+			mod->arch.paravirt_insts = s;
+#endif
 
 	if (!mod->arch.core_plt || !mod->arch.init_plt || !mod->arch.got || !mod->arch.opd) {
 		printk(KERN_ERR "%s: sections missing\n", mod->name);
@@ -929,6 +937,30 @@ module_finalize (const Elf_Ehdr *hdr, const Elf_Shdr *sechdrs, struct module *mo
 	DEBUGP("%s: init: entry=%p\n", __FUNCTION__, mod->init);
 	if (mod->arch.unwind)
 		register_unwind_table(mod);
+#ifdef CONFIG_PARAVIRT_ALT
+	if (mod->arch.paravirt_bundles) {
+		struct paravirt_alt_bundle_patch *start +			(struct paravirt_alt_bundle_patch *)
+			mod->arch.paravirt_bundles->sh_addr;
+		struct paravirt_alt_bundle_patch *end +			(struct paravirt_alt_bundle_patch *)
+			(mod->arch.paravirt_bundles->sh_addr +
+			 mod->arch.paravirt_bundles->sh_size);
+
+		paravirt_bundle_patch_module(start, end);
+	}
+	if (mod->arch.paravirt_insts) {
+		struct paravirt_alt_inst_patch *start +			(struct paravirt_alt_inst_patch *)
+			mod->arch.paravirt_insts->sh_addr;
+		struct paravirt_alt_inst_patch *end +			(struct paravirt_alt_inst_patch *)
+			(mod->arch.paravirt_insts->sh_addr +
+			 mod->arch.paravirt_insts->sh_size);
+
+		paravirt_inst_patch_module(start, end);
+	}
+#endif
 	return 0;
 }
 
diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
index b31fa91..4282b00 100644
--- a/arch/ia64/kernel/paravirt.c
+++ b/arch/ia64/kernel/paravirt.c
@@ -32,3 +32,11 @@ struct pv_info pv_info = {
 	.paravirt_enabled = 0,
 	.name = "bare hardware"
 };
+
+/***************************************************************************
+ * pv_init_ops
+ * initialization hooks.
+ */
+
+struct pv_init_ops pv_init_ops;
+
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index ebd1a09..bfccf54 100644
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
@@ -288,6 +289,8 @@ reserve_memory (void)
 	rsvd_region[n].end   = (unsigned long) ia64_imva(_end);
 	n++;
 
+	n += paravirt_reserve_memory(&rsvd_region[n]);
+
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (ia64_boot_param->initrd_start) {
 		rsvd_region[n].start = (unsigned long)__va(ia64_boot_param->initrd_start);
@@ -466,6 +469,8 @@ setup_arch (char **cmdline_p)
 {
 	unw_init();
 
+	paravirt_arch_setup_early();
+
 	ia64_patch_vtop((u64) __start___vtop_patchlist, (u64) __end___vtop_patchlist);
 
 	*cmdline_p = __va(ia64_boot_param->command_line);
@@ -518,6 +523,9 @@ setup_arch (char **cmdline_p)
 	acpi_boot_init();
 #endif
 
+	paravirt_banner();
+	paravirt_arch_setup_console(cmdline_p);
+
 #ifdef CONFIG_VT
 	if (!conswitchp) {
 # if defined(CONFIG_DUMMY_CONSOLE)
@@ -537,11 +545,15 @@ setup_arch (char **cmdline_p)
 #endif
 
 	/* enable IA-64 Machine Check Abort Handling unless disabled */
+	if (paravirt_arch_setup_nomca())
+		nomca = 1;
 	if (!nomca)
 		ia64_mca_init();
 
 	platform_setup(cmdline_p);
+	paravirt_post_platform_setup();
 	paging_init();
+	paravirt_post_paging_init();
 }
 
 /*
@@ -969,6 +981,8 @@ cpu_init (void)
 		max_num_phys_stacked = num_phys_stacked;
 	}
 	platform_cpu_init();
+	paravirt_cpu_init();
+
 	pm_idle = default_idle;
 }
 
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 32ee597..e7ce751 100644
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
index c2d4809..dd585fc 100644
--- a/include/asm-ia64/paravirt.h
+++ b/include/asm-ia64/paravirt.h
@@ -28,6 +28,8 @@
 
 #ifndef __ASSEMBLY__
 
+#include <asm/meminit.h>
+
 /******************************************************************************
  * general info
  */
@@ -49,12 +51,130 @@ static inline unsigned int get_kernel_rpl(void)
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
+	void (*post_platform_setup)(void);
+	void (*post_paging_init)(void);
+
+	void (*cpu_init)(void);
+
+
+	void (*post_smp_prepare_boot_cpu)(void);
+
+	void (*bundle_patch_module)(struct paravirt_alt_bundle_patch *start,
+				    struct paravirt_alt_bundle_patch *end);
+	void (*inst_patch_module)(struct paravirt_alt_inst_patch *start,
+				  struct paravirt_alt_inst_patch *end);
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
+static inline void paravirt_post_platform_setup(void)
+{
+	if (pv_init_ops.post_platform_setup)
+		pv_init_ops.post_platform_setup();
+}
+
+static inline void paravirt_post_paging_init(void)
+{
+	if (pv_init_ops.post_paging_init)
+		pv_init_ops.post_paging_init();
+}
+
+static inline void paravirt_cpu_init(void)
+{
+	if (pv_init_ops.cpu_init)
+		pv_init_ops.cpu_init();
+}
+
+static inline void paravirt_post_smp_prepare_boot_cpu(void)
+{
+	if (pv_init_ops.post_smp_prepare_boot_cpu)
+		pv_init_ops.post_smp_prepare_boot_cpu();
+}
+
+static inline void
+paravirt_bundle_patch_module(struct paravirt_alt_bundle_patch *start,
+			     struct paravirt_alt_bundle_patch *end)
+{
+	if (pv_init_ops.bundle_patch_module)
+		pv_init_ops.bundle_patch_module(start, end);
+}
+
+static inline void
+paravirt_inst_patch_module(struct paravirt_alt_inst_patch *start,
+			   struct paravirt_alt_inst_patch *end)
+{
+	if (pv_init_ops.inst_patch_module)
+		pv_init_ops.inst_patch_module(start, end);
+}
+
 #endif /* __ASSEMBLY__ */
 
 #else
 /* fallback for native case */
 
-/* XXX: TODO */
+#ifdef __ASSEMBLY__
+
+#define paravirt_banner()				do { } while (0)
+#define paravirt_reserve_memory(region)			0
+
+#define paravirt_arch_setup_early()			do { } while (0)
+#define paravirt_arch_setup_console(cmdline_p)		do { } while (0)
+#define paravirt_arch_setup_nomca()			0
+#define paravirt_post_platform_setup()			do { } while (0)
+#define paravirt_post_paging_init()			do { } while (0)
+#define paravirt_cpu_init()				do { } while (0)
+#define paravirt_post_smp_prepare_boot_cpu()		do { } while (0)
+
+#define paravirt_bundle_patch_module(start, end)	do { } while (0)
+#define paravirt_inst_patch_module(start, end)		do { } while (0)
+
+#endif /* __ASSEMBLY__ */
+
 
 #endif /* CONFIG_PARAVIRT_GUEST */
 
-- 
1.5.3

