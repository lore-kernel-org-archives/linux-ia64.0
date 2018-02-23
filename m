From: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Date: Fri, 23 Feb 2018 16:58:49 +0000
Subject: [PATCH 3/3] ftrace: Add MODULE_PLTS support
Message-Id: <20180223165849.16388-4-alexander.sverdlin@nokia.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180223165849.16388-1-alexander.sverdlin@nokia.com>
In-Reply-To: <20180223165849.16388-1-alexander.sverdlin@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Teach ftrace_make_call() and ftrace_make_nop() about PLTs.
Teach PLT code about FTRACE and all its callbacks.
Otherwise the following might happen:

------------[ cut here ]------------
WARNING: CPU: 14 PID: 2265 at .../arch/arm/kernel/insn.c:14 __arm_gen_branch+0x83/0x8c()
...
Hardware name: LSI Axxia AXM55XX
[<c0314a49>] (unwind_backtrace) from [<c03115e9>] (show_stack+0x11/0x14)
[<c03115e9>] (show_stack) from [<c0519f51>] (dump_stack+0x81/0xa8)
[<c0519f51>] (dump_stack) from [<c032185d>] (warn_slowpath_common+0x69/0x90)
[<c032185d>] (warn_slowpath_common) from [<c03218f3>] (warn_slowpath_null+0x17/0x1c)
[<c03218f3>] (warn_slowpath_null) from [<c03143cf>] (__arm_gen_branch+0x83/0x8c)
[<c03143cf>] (__arm_gen_branch) from [<c0314337>] (ftrace_make_nop+0xf/0x24)
[<c0314337>] (ftrace_make_nop) from [<c038ebcb>] (ftrace_process_locs+0x27b/0x3e8)
[<c038ebcb>] (ftrace_process_locs) from [<c0378d79>] (load_module+0x11e9/0x1a44)
[<c0378d79>] (load_module) from [<c037974d>] (SyS_finit_module+0x59/0x84)
[<c037974d>] (SyS_finit_module) from [<c030e981>] (ret_fast_syscall+0x1/0x18)
---[ end trace e1b64ced7a89adcc ]---
------------[ cut here ]------------
WARNING: CPU: 14 PID: 2265 at .../kernel/trace/ftrace.c:1979 ftrace_bug+0x1b1/0x234()
...
Hardware name: LSI Axxia AXM55XX
[<c0314a49>] (unwind_backtrace) from [<c03115e9>] (show_stack+0x11/0x14)
[<c03115e9>] (show_stack) from [<c0519f51>] (dump_stack+0x81/0xa8)
[<c0519f51>] (dump_stack) from [<c032185d>] (warn_slowpath_common+0x69/0x90)
[<c032185d>] (warn_slowpath_common) from [<c03218f3>] (warn_slowpath_null+0x17/0x1c)
[<c03218f3>] (warn_slowpath_null) from [<c038e87d>] (ftrace_bug+0x1b1/0x234)
[<c038e87d>] (ftrace_bug) from [<c038ebd5>] (ftrace_process_locs+0x285/0x3e8)
[<c038ebd5>] (ftrace_process_locs) from [<c0378d79>] (load_module+0x11e9/0x1a44)
[<c0378d79>] (load_module) from [<c037974d>] (SyS_finit_module+0x59/0x84)
[<c037974d>] (SyS_finit_module) from [<c030e981>] (ret_fast_syscall+0x1/0x18)
---[ end trace e1b64ced7a89adcd ]---
ftrace failed to modify [<e9ef7006>] 0xe9ef7006
actual: 02:f0:3b:fa
ftrace record flags: 0
(0) expected tramp: c0314265

Signed-off-by: Alexander Sverdlin <alexander.sverdlin@nokia.com>
---
 arch/arm/include/asm/module.h |  1 +
 arch/arm/kernel/ftrace.c      | 70 ++++++++++++++++++++++++++++++++++++-------
 arch/arm/kernel/module-plts.c | 53 ++++++++++++++++++++++++--------
 3 files changed, 101 insertions(+), 23 deletions(-)

diff --git a/arch/arm/include/asm/module.h b/arch/arm/include/asm/module.h
index 6996405..e3d7a51 100644
--- a/arch/arm/include/asm/module.h
+++ b/arch/arm/include/asm/module.h
@@ -30,6 +30,7 @@ struct plt_entries {
 
 struct mod_plt_sec {
 	struct elf32_shdr	*plt;
+	struct plt_entries	*plt_ent;
 	int			plt_count;
 };
 
diff --git a/arch/arm/kernel/ftrace.c b/arch/arm/kernel/ftrace.c
index be20adc..0a0da25 100644
--- a/arch/arm/kernel/ftrace.c
+++ b/arch/arm/kernel/ftrace.c
@@ -98,6 +98,19 @@ int ftrace_arch_code_modify_post_process(void)
 
 static unsigned long ftrace_call_replace(unsigned long pc, unsigned long addr)
 {
+	s32 offset = addr - pc;
+	s32 blim = 0xfe000008;
+	s32 flim = 0x02000004;
+
+	if (IS_ENABLED(CONFIG_THUMB2_KERNEL)) {
+		blim = 0xff000004;
+		flim = 0x01000002;
+	}
+
+	if (IS_ENABLED(CONFIG_ARM_MODULE_PLTS) &&
+	    (offset < blim || offset > flim))
+		return 0;
+
 	return arm_gen_branch_link(pc, addr);
 }
 
@@ -167,10 +180,27 @@ int ftrace_make_call(struct module *mod, struct dyn_ftrace *rec,
 {
 	unsigned long new, old;
 	unsigned long ip = rec->ip;
+	unsigned long aaddr = adjust_address(rec, addr);
 
 	old = ftrace_nop_replace(rec);
 
-	new = ftrace_call_replace(ip, adjust_address(rec, addr));
+	new = ftrace_call_replace(ip, aaddr);
+
+#ifdef CONFIG_ARM_MODULE_PLTS
+	if (!new) {
+		/*
+		 * mod is only supplied during module loading, later we have to
+		 * search for it
+		 */
+		if (!mod)
+			mod = __module_address(ip);
+
+		if (mod) {
+			aaddr = get_module_plt(mod, ip, aaddr);
+			new = ftrace_call_replace(ip, aaddr);
+		}
+	}
+#endif
 
 	return ftrace_modify_code(rec->ip, old, new, true);
 }
@@ -200,20 +230,40 @@ int ftrace_make_nop(struct module *mod,
 	unsigned long new;
 	int ret;
 
-	old = ftrace_call_replace(ip, adjust_address(rec, addr));
-	new = ftrace_nop_replace(rec);
-	ret = ftrace_modify_code(ip, old, new, true);
-
-#ifdef CONFIG_OLD_MCOUNT
-	if (ret = -EINVAL && addr = MCOUNT_ADDR) {
-		rec->arch.old_mcount = true;
+	for (;;) {
+		unsigned long aaddr = adjust_address(rec, addr);
+
+		old = ftrace_call_replace(ip, aaddr);
+
+#ifdef CONFIG_ARM_MODULE_PLTS
+		if (!old) {
+			/*
+			 * mod is only supplied during module loading, later we
+			 * have to search for it
+			 */
+			if (!mod)
+				mod = __module_address(ip);
+
+			if (mod) {
+				aaddr = get_module_plt(mod, ip, aaddr);
+				old = ftrace_call_replace(ip, aaddr);
+			}
+		}
+#endif
 
-		old = ftrace_call_replace(ip, adjust_address(rec, addr));
 		new = ftrace_nop_replace(rec);
 		ret = ftrace_modify_code(ip, old, new, true);
-	}
+
+#ifdef CONFIG_OLD_MCOUNT
+		if (ret = -EINVAL && !rec->arch.old_mcount) {
+			rec->arch.old_mcount = true;
+			continue;
+		}
 #endif
 
+		break;
+	}
+
 	return ret;
 }
 
diff --git a/arch/arm/kernel/module-plts.c b/arch/arm/kernel/module-plts.c
index f272711..a216256 100644
--- a/arch/arm/kernel/module-plts.c
+++ b/arch/arm/kernel/module-plts.c
@@ -7,6 +7,7 @@
  */
 
 #include <linux/elf.h>
+#include <linux/ftrace.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/sort.h>
@@ -22,6 +23,15 @@
 						    (PLT_ENT_STRIDE - 8))
 #endif
 
+static u32 fixed_plts[] = {
+	FTRACE_ADDR,
+	MCOUNT_ADDR,
+#ifdef CONFIG_OLD_MCOUNT
+	(unsigned long)ftrace_caller_old,
+	(unsigned long)mcount,
+#endif
+};
+
 static bool in_init(const struct module *mod, unsigned long loc)
 {
 	return loc - (u32)mod->init_layout.base < mod->init_layout.size;
@@ -31,26 +41,43 @@ u32 get_module_plt(struct module *mod, unsigned long loc, Elf32_Addr val)
 {
 	struct mod_plt_sec *pltsec = !in_init(mod, loc) ? &mod->arch.core :
 							  &mod->arch.init;
+	int idx;
+	struct plt_entries *plt;
+
+	/* Pre-allocate entries in the first plt */
+	if (!pltsec->plt_count) {
+		plt = (struct plt_entries *)pltsec->plt->sh_addr;
+		for (idx = 0; idx < ARRAY_SIZE(plt->ldr); ++idx)
+			plt->ldr[idx] = PLT_ENT_LDR;
+		memcpy(plt->lit, fixed_plts, sizeof(fixed_plts));
+		pltsec->plt_count = ARRAY_SIZE(fixed_plts);
+		/*
+		 * cache the address,
+		 * ELF header is available only during module load
+		 */
+		pltsec->plt_ent = plt;
+	}
+	plt = pltsec->plt_ent;
 
-	struct plt_entries *plt = (struct plt_entries *)pltsec->plt->sh_addr;
-	int idx = 0;
+	idx = ARRAY_SIZE(fixed_plts);
+	while (idx)
+		if (plt->lit[--idx] = val)
+			return (u32)&plt->ldr[idx];
 
 	/*
 	 * Look for an existing entry pointing to 'val'. Given that the
 	 * relocations are sorted, this will be the last entry we allocated.
 	 * (if one exists).
 	 */
-	if (pltsec->plt_count > 0) {
-		plt += (pltsec->plt_count - 1) / PLT_ENT_COUNT;
-		idx = (pltsec->plt_count - 1) % PLT_ENT_COUNT;
+	plt += (pltsec->plt_count - 1) / PLT_ENT_COUNT;
+	idx = (pltsec->plt_count - 1) % PLT_ENT_COUNT;
 
-		if (plt->lit[idx] = val)
-			return (u32)&plt->ldr[idx];
+	if (plt->lit[idx] = val)
+		return (u32)&plt->ldr[idx];
 
-		idx = (idx + 1) % PLT_ENT_COUNT;
-		if (!idx)
-			plt++;
-	}
+	idx = (idx + 1) % PLT_ENT_COUNT;
+	if (!idx)
+		plt++;
 
 	pltsec->plt_count++;
 	BUG_ON(pltsec->plt_count * PLT_ENT_SIZE > pltsec->plt->sh_size);
@@ -182,8 +209,8 @@ static unsigned int count_plts(const Elf32_Sym *syms, Elf32_Addr base,
 int module_frob_arch_sections(Elf_Ehdr *ehdr, Elf_Shdr *sechdrs,
 			      char *secstrings, struct module *mod)
 {
-	unsigned long core_plts = 0;
-	unsigned long init_plts = 0;
+	unsigned long core_plts = ARRAY_SIZE(fixed_plts);
+	unsigned long init_plts = ARRAY_SIZE(fixed_plts);
 	Elf32_Shdr *s, *sechdrs_end = sechdrs + ehdr->e_shnum;
 	Elf32_Sym *syms = NULL;
 
-- 
2.4.6

