From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:10:30 +0000
Subject: [PATCH 12/28] RFC: ia64/xen: xen privileged instruction intrinsics binary patching.
Message-Id: <12036570472031-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

With binary patching, make intrinsics paravirtualization hypervisor neutral.
So far xen intrinsics doesn't allow another hypervisor.
Mark privileged operations which needs paravirtualization and binary patch
if running on xen at early boot time.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/module.c          |   32 ++
 arch/ia64/kernel/paravirtentry.S   |   37 +++
 arch/ia64/xen/Makefile             |    7 +
 arch/ia64/xen/paravirt_xen.c       |  242 +++++++++++++++
 arch/ia64/xen/privops_asm.S        |  221 ++++++++++++++
 arch/ia64/xen/privops_c.c          |  279 +++++++++++++++++
 arch/ia64/xen/xensetup.S           |   10 +
 include/asm-ia64/privop.h          |    4 +
 include/asm-ia64/privop_paravirt.h |  587 ++++++++++++++++++++++++++++++++++++
 include/asm-ia64/xen/privop.h      |   24 ++
 10 files changed, 1443 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kernel/paravirtentry.S
 create mode 100644 arch/ia64/xen/Makefile
 create mode 100644 arch/ia64/xen/paravirt_xen.c
 create mode 100644 arch/ia64/xen/privops_asm.S
 create mode 100644 arch/ia64/xen/privops_c.c
 create mode 100644 include/asm-ia64/privop_paravirt.h

diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index e58f436..2806f70 100644
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
+		xen_alt_bundle_patch_module(start, end);
+	}
+	if (mod->arch.paravirt_insts) {
+		struct paravirt_alt_inst_patch *start +			(struct paravirt_alt_inst_patch *)
+			mod->arch.paravirt_insts->sh_addr;
+		struct paravirt_alt_inst_patch *end +			(struct paravirt_alt_inst_patch *)
+			(mod->arch.paravirt_insts->sh_addr +
+			 mod->arch.paravirt_insts->sh_size);
+
+		xen_alt_inst_patch_module(start, end);
+	}
+#endif
 	return 0;
 }
 
diff --git a/arch/ia64/kernel/paravirtentry.S b/arch/ia64/kernel/paravirtentry.S
new file mode 100644
index 0000000..99606d0
--- /dev/null
+++ b/arch/ia64/kernel/paravirtentry.S
@@ -0,0 +1,37 @@
+/******************************************************************************
+ * linux/arch/ia64/xen/paravirtentry.S
+ *
+ * Copyright (c) 2007 Isaku Yamahata <yamahata at valinux co jp>
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
+#include <asm/types.h>
+#include <asm/asmmacro.h>
+#include <asm/paravirt_entry.h>
+#include <asm/privop_paravirt.h>
+
+#define BRANCH(sym, type)					\
+	GLOBAL_ENTRY(paravirt_ ## sym) ;			\
+		BR_COND_SPTK_MANY(__ia64_ ## sym, type) ;	\
+	END(paravirt_ ## sym)
+
+	BRANCH(switch_to,		PARAVIRT_ENTRY_SWITCH_TO)
+	BRANCH(leave_syscall,		PARAVIRT_ENTRY_LEAVE_SYSCALL)
+	BRANCH(work_processed_syscall,	PARAVIRT_ENTRY_WORK_PROCESSED_SYSCALL)
+	BRANCH(leave_kernel,		PARAVIRT_ENTRY_LEAVE_KERNEL)
+	BRANCH(pal_call_static,		PARAVIRT_ENTRY_PAL_CALL_STATIC)
diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
new file mode 100644
index 0000000..c219358
--- /dev/null
+++ b/arch/ia64/xen/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for Xen components
+#
+
+obj-$(CONFIG_PARAVIRT_ALT) += paravirt_xen.o privops_asm.o privops_c.o
+obj-$(CONFIG_PARAVIRT_NOP_B_PATCH) += paravirt_xen.o
+obj-$(CONFIG_PARAVIRT_ENTRY) += paravirt_xen.o
diff --git a/arch/ia64/xen/paravirt_xen.c b/arch/ia64/xen/paravirt_xen.c
new file mode 100644
index 0000000..57b9dfd
--- /dev/null
+++ b/arch/ia64/xen/paravirt_xen.c
@@ -0,0 +1,242 @@
+/******************************************************************************
+ * linux/arch/ia64/xen/paravirt_xen.c
+ *
+ * Copyright (c) 2007 Isaku Yamahata <yamahata at valinux co jp>
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
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/init.h>
+#include <asm/intrinsics.h>
+#include <asm/bugs.h>
+#include <asm/kprobes.h> /* for bundle_t */
+#include <asm/paravirt_core.h>
+
+#ifdef CONFIG_PARAVIRT_ALT
+struct xen_alt_bundle_patch_elem {
+	const void	*sbundle;
+	const void	*ebundle;
+	unsigned long	type;
+};
+
+static unsigned long __init_or_module
+__xen_alt_bundle_patch(void *sbundle, void *ebundle, unsigned long type)
+{
+	extern const struct xen_alt_bundle_patch_elem xen_alt_bundle_array[];
+	extern const unsigned long xen_alt_bundle_array_size;
+
+	unsigned long used = 0;
+	unsigned long i;
+
+	BUG_ON((((unsigned long)sbundle) % sizeof(bundle_t)) != 0);
+	BUG_ON((((unsigned long)ebundle) % sizeof(bundle_t)) != 0);
+
+	for (i = 0;
+	     i < xen_alt_bundle_array_size / sizeof(xen_alt_bundle_array[0]);
+	     i++) {
+		const struct xen_alt_bundle_patch_elem *p +			&xen_alt_bundle_array[i];
+		if (p->type = type) {
+			used = p->ebundle - p->sbundle;
+			BUG_ON(used > ebundle - sbundle);
+			memcpy(sbundle, p->sbundle, used);
+			break;
+		}
+	}
+
+	return used;
+}
+
+static void __init
+xen_alt_bundle_patch(void)
+{
+	extern struct paravirt_alt_bundle_patch __start_paravirt_bundles[];
+	extern struct paravirt_alt_bundle_patch __stop_paravirt_bundles[];
+
+	paravirt_alt_bundle_patch_apply(__start_paravirt_bundles,
+					__stop_paravirt_bundles,
+					&__xen_alt_bundle_patch);
+}
+
+#ifdef CONFIG_MODULES
+void
+xen_alt_bundle_patch_module(struct paravirt_alt_bundle_patch *start,
+			    struct paravirt_alt_bundle_patch *end)
+{
+	if (is_running_on_xen())
+		paravirt_alt_bundle_patch_apply(start, end,
+						&__xen_alt_bundle_patch);
+}
+#endif /* CONFIG_MODULES */
+
+
+/*
+ * all the native instructions of hyperprivops are M-form or I-form
+ * mov ar.<imm>=r1	I26, M29
+ * mov r1=ar.<imm>	I28, M31
+ * mov r1=cr.<imm>	M32
+ * mov cr.<imm>=r1	M33
+ * mov r1=psr		M36
+ * mov indirect<r1>=r2	M42
+ * mov r1=indirect<r2>	M43
+ * ptc.ga		M45
+ * thash r1=r2		M46
+ *
+ * break.{m, i} instrucitions format are same.
+ * So we can safely replace all signle instruction which is target of
+ * hyperpviops with break.{m, i} imm21 hyperprivops.
+ */
+
+struct xen_alt_inst_patch_elem {
+	unsigned long stag;
+	unsigned long etag;
+	unsigned long type;
+};
+
+unsigned long
+__xen_alt_inst_patch(unsigned long stag, unsigned long etag,
+		     unsigned long type)
+{
+	extern const struct xen_alt_inst_patch_elem xen_alt_inst_array[];
+	extern const unsigned long xen_alt_inst_array_size;
+
+	unsigned long dest_tag = stag;
+	unsigned long i;
+
+	for (i = 0;
+	     i < xen_alt_inst_array_size / sizeof(xen_alt_inst_array[0]);
+	     i++) {
+		const struct xen_alt_inst_patch_elem *p +			&xen_alt_inst_array[i];
+		if (p->type = type) {
+			unsigned long src_tag;
+
+			for (src_tag = p->stag;
+			     src_tag < p->etag;
+			     src_tag = paravirt_get_next_tag(src_tag)) {
+				const cmp_inst_t inst +					paravirt_read_inst(src_tag);
+				paravirt_write_inst(dest_tag, inst);
+
+				BUG_ON(dest_tag >= etag);
+				dest_tag = paravirt_get_next_tag(dest_tag);
+			}
+			break;
+		}
+	}
+
+	return dest_tag;
+}
+
+void
+xen_alt_inst_patch(void)
+{
+	extern struct paravirt_alt_inst_patch __start_paravirt_insts[];
+	extern struct paravirt_alt_inst_patch __stop_paravirt_insts[];
+
+	paravirt_alt_inst_patch_apply(__start_paravirt_insts,
+				      __stop_paravirt_insts,
+				      &__xen_alt_inst_patch);
+}
+
+#ifdef CONFIG_MODULES
+void
+xen_alt_inst_patch_module(struct paravirt_alt_inst_patch *start,
+			  struct paravirt_alt_inst_patch *end)
+{
+	if (is_running_on_xen())
+		paravirt_alt_inst_patch_apply(start, end,
+					      &__xen_alt_inst_patch);
+}
+#endif
+
+#else
+#define xen_alt_bundle_patch()	do { } while (0)
+#define xen_alt_inst_patch()	do { } while (0)
+#endif /* CONFIG_PARAVIRT_ALT */
+
+
+#ifdef CONFIG_PARAVIRT_NOP_B_PATCH
+#include <asm/paravirt_nop.h>
+static void __init
+xen_nop_b_patch(void)
+{
+	extern const struct paravirt_nop_patch __start_paravirt_nop_b[];
+	extern const struct paravirt_nop_patch __stop_paravirt_nop_b[];
+
+	paravirt_nop_b_patch_apply(__start_paravirt_nop_b,
+				   __stop_paravirt_nop_b);
+}
+#else
+#define xen_nop_b_patch()	do { } while (0)
+#endif
+
+
+#ifdef CONFIG_PARAVIRT_ENTRY
+
+#include <asm/paravirt_entry.h>
+
+extern void *xen_switch_to;
+extern void *xen_leave_syscall;
+extern void *xen_leave_kernel;
+extern void *xen_pal_call_static;
+extern void *xen_work_processed_syscall;
+
+const static struct paravirt_entry xen_entries[] __initdata = {
+	{&xen_switch_to,		PARAVIRT_ENTRY_SWITCH_TO},
+	{&xen_leave_syscall,		PARAVIRT_ENTRY_LEAVE_SYSCALL},
+	{&xen_leave_kernel,		PARAVIRT_ENTRY_LEAVE_KERNEL},
+	{&xen_pal_call_static,		PARAVIRT_ENTRY_PAL_CALL_STATIC},
+	{&xen_work_processed_syscall,	PARAVIRT_ENTRY_WORK_PROCESSED_SYSCALL},
+};
+
+void __init
+xen_entry_patch(void)
+{
+	extern const struct paravirt_entry_patch __start_paravirt_entry[];
+	extern const struct paravirt_entry_patch __stop_paravirt_entry[];
+
+	paravirt_entry_patch_apply(__start_paravirt_entry,
+				   __stop_paravirt_entry,
+				   xen_entries,
+				   sizeof(xen_entries)/sizeof(xen_entries[0]));
+}
+#else
+#define xen_entry_patch()	do { } while (0)
+#endif
+
+
+void __init
+xen_paravirt_patch(void)
+{
+	xen_alt_bundle_patch();
+	xen_alt_inst_patch();
+	xen_nop_b_patch();
+	xen_entry_patch();
+}
+
+/*
+ * Local variables:
+ * mode: C
+ * c-set-style: "linux"
+ * c-basic-offset: 8
+ * tab-width: 8
+ * indent-tabs-mode: t
+ * End:
+ */
diff --git a/arch/ia64/xen/privops_asm.S b/arch/ia64/xen/privops_asm.S
new file mode 100644
index 0000000..40e400e
--- /dev/null
+++ b/arch/ia64/xen/privops_asm.S
@@ -0,0 +1,221 @@
+/******************************************************************************
+ * linux/arch/ia64/xen/privop_s.S
+ *
+ * Copyright (c) 2007 Isaku Yamahata <yamahata at valinux co jp>
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
+#include <asm/intrinsics.h>
+#include <linux/init.h>
+#include <asm/paravirt_alt.h>
+
+#ifdef CONFIG_MODULES
+#define __INIT_OR_MODULE	.text
+#define __INITDATA_OR_MODULE	.data
+#else
+#define __INIT_OR_MODULE	__INIT
+#define __INITDATA_OR_MODULE	__INITDATA
+#endif /* CONFIG_MODULES */
+
+	__INIT_OR_MODULE
+	.align 32
+	.proc nop_b_inst_bundle
+	.global nop_b_inst_bundle
+nop_b_inst_bundle:
+	{
+		nop.b 0
+		nop.b 0
+		nop.b 0
+	}
+	.endp nop_b_inst_bundle
+	__FINIT
+
+	/* NOTE: nop.[mfi] has same format */
+	__INIT_OR_MODULE
+	.align 32
+	.proc nop_mfi_inst_bundle
+	.global nop_mfi_inst_bundle
+nop_mfi_inst_bundle:
+	{
+		nop.m 0
+		nop.f 0
+		nop.i 0
+	}
+	.endp nop_mfi_inst_bundle
+	__FINIT
+
+	__INIT_OR_MODULE
+	.align 32
+	.proc nop_bundle
+	.global nop_bundle
+nop_bundle:
+nop_bundle_start:
+	{
+		nop 0
+		nop 0
+		nop 0
+	}
+nop_bundle_end:
+	.endp nop_bundle
+	__FINIT
+
+	__INITDATA_OR_MODULE
+	.align 8
+	.global nop_bundle_size
+nop_bundle_size:
+	data8	nop_bundle_end - nop_bundle_start
+
+#define DEFINE_PRIVOP(name, instr)					\
+	.align 32;							\
+	.proc  xen_ ## name ## _instr;					\
+	xen_ ## name ## _instr:;					\
+	xen_ ## name ## _instr_start:;					\
+	{;								\
+	[xen_ ## name ## _stag:]					\
+		instr;							\
+	[xen_ ## name ## _etag:]					\
+		nop 0;							\
+		nop 0;							\
+	};								\
+	xen_ ## name ## _instr_end:;					\
+	.endp  xen_ ## name ## _instr;
+
+	__INIT_OR_MODULE
+	DEFINE_PRIVOP(rfi,		XEN_HYPER_RFI)
+	DEFINE_PRIVOP(rsm_psr_dt,	XEN_HYPER_RSM_PSR_DT)
+	DEFINE_PRIVOP(ssm_psr_dt,	XEN_HYPER_SSM_PSR_DT)
+	DEFINE_PRIVOP(cover,		XEN_HYPER_COVER)
+	DEFINE_PRIVOP(itc_d,		XEN_HYPER_ITC_D)
+	DEFINE_PRIVOP(itc_i,		XEN_HYPER_ITC_I)
+	DEFINE_PRIVOP(ssm_i,		XEN_HYPER_SSM_I)
+	DEFINE_PRIVOP(get_ivr,		XEN_HYPER_GET_IVR)
+	DEFINE_PRIVOP(get_tpr,		XEN_HYPER_GET_TPR)
+	DEFINE_PRIVOP(set_tpr,		XEN_HYPER_SET_TPR)
+	DEFINE_PRIVOP(eoi,		XEN_HYPER_EOI)
+	DEFINE_PRIVOP(set_itm,		XEN_HYPER_SET_ITM)
+	DEFINE_PRIVOP(thash,		XEN_HYPER_THASH)
+	DEFINE_PRIVOP(ptc_ga,		XEN_HYPER_PTC_GA)
+	DEFINE_PRIVOP(itr_d,		XEN_HYPER_ITR_D)
+	DEFINE_PRIVOP(get_rr,		XEN_HYPER_GET_RR)
+	DEFINE_PRIVOP(set_rr,		XEN_HYPER_SET_RR)
+	DEFINE_PRIVOP(set_kr,		XEN_HYPER_SET_KR)
+	DEFINE_PRIVOP(fc,		XEN_HYPER_FC)
+	DEFINE_PRIVOP(get_cpuid,	XEN_HYPER_GET_CPUID)
+	DEFINE_PRIVOP(get_pmd,		XEN_HYPER_GET_PMD)
+	DEFINE_PRIVOP(get_eflag,	XEN_HYPER_GET_EFLAG)
+	DEFINE_PRIVOP(set_eflag,	XEN_HYPER_SET_EFLAG)
+	DEFINE_PRIVOP(get_psr,		XEN_HYPER_GET_PSR)
+	DEFINE_PRIVOP(set_rr0_to_rr4,	XEN_HYPER_SET_RR0_TO_RR4)
+	__FINIT
+
+
+#define PARAVIRT_ALT_BUNDLE_ELEM(name, type)				\
+	data8 xen_ ## name ## _instr_start;				\
+	data8 xen_ ## name ## _instr_end;				\
+	data8 type;
+
+	__INITDATA_OR_MODULE
+	.align 8
+	.global xen_alt_bundle_array
+xen_alt_bundle_array:
+xen_alt_bundle_array_start:
+	PARAVIRT_ALT_BUNDLE_ELEM(rfi,		PARAVIRT_INST_RFI)
+	PARAVIRT_ALT_BUNDLE_ELEM(rsm_psr_dt,	PARAVIRT_INST_RSM_DT)
+	PARAVIRT_ALT_BUNDLE_ELEM(ssm_psr_dt,	PARAVIRT_INST_SSM_DT)
+	PARAVIRT_ALT_BUNDLE_ELEM(cover,		PARAVIRT_INST_COVER)
+	PARAVIRT_ALT_BUNDLE_ELEM(itc_d,		PARAVIRT_INST_ITC_D)
+	PARAVIRT_ALT_BUNDLE_ELEM(itc_i,		PARAVIRT_INST_ITC_I)
+	PARAVIRT_ALT_BUNDLE_ELEM(ssm_i,		PARAVIRT_INST_SSM_I)
+	PARAVIRT_ALT_BUNDLE_ELEM(get_ivr,	PARAVIRT_INST_GET_IVR)
+	PARAVIRT_ALT_BUNDLE_ELEM(get_tpr,	PARAVIRT_INST_GET_TPR)
+	PARAVIRT_ALT_BUNDLE_ELEM(set_tpr,	PARAVIRT_INST_SET_TPR)
+	PARAVIRT_ALT_BUNDLE_ELEM(eoi,		PARAVIRT_INST_EOI)
+	PARAVIRT_ALT_BUNDLE_ELEM(set_itm,	PARAVIRT_INST_SET_ITM)
+	PARAVIRT_ALT_BUNDLE_ELEM(thash,		PARAVIRT_INST_THASH)
+	PARAVIRT_ALT_BUNDLE_ELEM(ptc_ga,	PARAVIRT_INST_PTC_GA)
+	PARAVIRT_ALT_BUNDLE_ELEM(itr_d,		PARAVIRT_INST_ITR_D)
+	PARAVIRT_ALT_BUNDLE_ELEM(get_rr,	PARAVIRT_INST_GET_RR)
+	PARAVIRT_ALT_BUNDLE_ELEM(set_rr,	PARAVIRT_INST_SET_RR)
+	PARAVIRT_ALT_BUNDLE_ELEM(set_kr,	PARAVIRT_INST_SET_KR)
+	PARAVIRT_ALT_BUNDLE_ELEM(fc,		PARAVIRT_INST_FC)
+	PARAVIRT_ALT_BUNDLE_ELEM(get_cpuid,	PARAVIRT_INST_GET_CPUID)
+	PARAVIRT_ALT_BUNDLE_ELEM(get_pmd,	PARAVIRT_INST_GET_PMD)
+	PARAVIRT_ALT_BUNDLE_ELEM(get_eflag,	PARAVIRT_INST_GET_EFLAG)
+	PARAVIRT_ALT_BUNDLE_ELEM(set_eflag,	PARAVIRT_INST_SET_EFLAG)
+	PARAVIRT_ALT_BUNDLE_ELEM(get_psr,	PARAVIRT_INST_GET_PSR)
+
+	PARAVIRT_ALT_BUNDLE_ELEM(ssm_i,		PARAVIRT_BNDL_SSM_I)
+	PARAVIRT_ALT_BUNDLE_ELEM(rsm_i,		PARAVIRT_BNDL_RSM_I)
+	PARAVIRT_ALT_BUNDLE_ELEM(get_psr_i,	PARAVIRT_BNDL_GET_PSR_I)
+	PARAVIRT_ALT_BUNDLE_ELEM(intrin_local_irq_restore,
+					PARAVIRT_BNDL_INTRIN_LOCAL_IRQ_RESTORE)
+xen_alt_bundle_array_end:
+
+	.align 8
+	.global xen_alt_bundle_array_size
+xen_alt_bundle_array_size:
+	.long xen_alt_bundle_array_end - xen_alt_bundle_array_start
+
+
+#define PARAVIRT_ALT_INST_ELEM(name, type)				\
+	data8 xen_ ## name ## _stag ;					\
+	data8 xen_ ## name ## _etag ;					\
+	data8 type
+
+	__INITDATA_OR_MODULE
+	.align 8
+	.global xen_alt_inst_array
+xen_alt_inst_array:
+xen_alt_inst_array_start:
+	PARAVIRT_ALT_INST_ELEM(rfi,		PARAVIRT_INST_RFI)
+	PARAVIRT_ALT_INST_ELEM(rsm_psr_dt,	PARAVIRT_INST_RSM_DT)
+	PARAVIRT_ALT_INST_ELEM(ssm_psr_dt,	PARAVIRT_INST_SSM_DT)
+	PARAVIRT_ALT_INST_ELEM(cover,		PARAVIRT_INST_COVER)
+	PARAVIRT_ALT_INST_ELEM(itc_d,		PARAVIRT_INST_ITC_D)
+	PARAVIRT_ALT_INST_ELEM(itc_i,		PARAVIRT_INST_ITC_I)
+	PARAVIRT_ALT_INST_ELEM(ssm_i,		PARAVIRT_INST_SSM_I)
+	PARAVIRT_ALT_INST_ELEM(get_ivr,		PARAVIRT_INST_GET_IVR)
+	PARAVIRT_ALT_INST_ELEM(get_tpr,		PARAVIRT_INST_GET_TPR)
+	PARAVIRT_ALT_INST_ELEM(set_tpr,		PARAVIRT_INST_SET_TPR)
+	PARAVIRT_ALT_INST_ELEM(eoi,		PARAVIRT_INST_EOI)
+	PARAVIRT_ALT_INST_ELEM(set_itm,		PARAVIRT_INST_SET_ITM)
+	PARAVIRT_ALT_INST_ELEM(thash,		PARAVIRT_INST_THASH)
+	PARAVIRT_ALT_INST_ELEM(ptc_ga,		PARAVIRT_INST_PTC_GA)
+	PARAVIRT_ALT_INST_ELEM(itr_d,		PARAVIRT_INST_ITR_D)
+	PARAVIRT_ALT_INST_ELEM(get_rr,		PARAVIRT_INST_GET_RR)
+	PARAVIRT_ALT_INST_ELEM(set_rr,		PARAVIRT_INST_SET_RR)
+	PARAVIRT_ALT_INST_ELEM(set_kr,		PARAVIRT_INST_SET_KR)
+	PARAVIRT_ALT_INST_ELEM(fc,		PARAVIRT_INST_FC)
+	PARAVIRT_ALT_INST_ELEM(get_cpuid,	PARAVIRT_INST_GET_CPUID)
+	PARAVIRT_ALT_INST_ELEM(get_pmd,		PARAVIRT_INST_GET_PMD)
+	PARAVIRT_ALT_INST_ELEM(get_eflag,	PARAVIRT_INST_GET_EFLAG)
+	PARAVIRT_ALT_INST_ELEM(set_eflag,	PARAVIRT_INST_SET_EFLAG)
+	PARAVIRT_ALT_INST_ELEM(get_psr,		PARAVIRT_INST_GET_PSR)
+	PARAVIRT_ALT_INST_ELEM(set_rr0_to_rr4,	PARAVIRT_INST_SET_RR0_TO_RR4)
+
+	PARAVIRT_ALT_INST_ELEM(ssm_i,		PARAVIRT_BNDL_SSM_I)
+	PARAVIRT_ALT_INST_ELEM(rsm_i,		PARAVIRT_BNDL_RSM_I)
+	PARAVIRT_ALT_INST_ELEM(get_psr_i,	PARAVIRT_BNDL_GET_PSR_I)
+	PARAVIRT_ALT_INST_ELEM(intrin_local_irq_restore,
+					PARAVIRT_BNDL_INTRIN_LOCAL_IRQ_RESTORE)
+xen_alt_inst_array_end:
+
+	.align 8
+	.global xen_alt_inst_array_size
+xen_alt_inst_array_size:
+	.long xen_alt_inst_array_end - xen_alt_inst_array_start
diff --git a/arch/ia64/xen/privops_c.c b/arch/ia64/xen/privops_c.c
new file mode 100644
index 0000000..0fa2e23
--- /dev/null
+++ b/arch/ia64/xen/privops_c.c
@@ -0,0 +1,279 @@
+/******************************************************************************
+ * arch/ia64/xen/privops_c.c
+ *
+ * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
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
+#include <linux/linkage.h>
+#include <linux/init.h>
+#include <linux/module.h>
+
+#include <xen/interface/xen.h>
+
+#include <asm/asm-offsets.h>
+#define XEN_PSR_I_ADDR_ADDR	((uint8_t **)(XSI_BASE + XSI_PSR_I_ADDR_OFS))
+
+
+void __init_or_module
+xen_privop_ssm_i(void)
+{
+	/*
+	 * int masked = !xen_get_virtual_psr_i();
+	 *	// masked = *(*XEN_MAPPEDREGS->interrupt_mask_addr)
+	 * xen_set_virtual_psr_i(1)
+	 *	// *(*XEN_MAPPEDREGS->interrupt_mask_addr) = 0
+	 * // compiler barrier
+	 * if (masked) {
+	 *	uint8_t* pend_int_addr +	 *		(uint8_t*)(*XEN_MAPPEDREGS->interrupt_mask_addr) - 1;
+	 *	uint8_t pending = *pend_int_addr;
+	 *	if (pending)
+	 *		XEN_HYPER_SSM_I
+	 * }
+	 */
+	register uint8_t *tmp asm ("r8");
+	register int masked asm ("r9");
+	register uint8_t *pending_intr_addr asm ("r10");
+
+	asm volatile(".global xen_ssm_i_instr\n\t"
+		     "xen_ssm_i_instr:\n\t"
+		     ".global xen_ssm_i_instr_start\n\t"
+		     "xen_ssm_i_instr_start:\n\t"
+		     ".global xen_ssm_i_stag\n\t"
+		     "[xen_ssm_i_stag:]\n\t"
+		     /* tmp = &XEN_MAPPEDREGS->interrupt_mask_addr */
+		     "mov %[tmp]=%[XEN_PSR_I_ADDR_ADDR_IMM]\n\t"
+		     ";;\n\t"
+		     /* tmp = *XEN_MAPPEDREGS->interrupt_mask_addr */
+		     "ld8 %[tmp]=[%[tmp]]\n\t"
+		     ";;\n\t"
+		     /* pending_intr_addr = tmp - 1 */
+		     "add %[pending_intr_addr]=-1,%[tmp]\n\t"
+		     /* masked = *tmp */
+		     "ld1 %[masked]=[%[tmp]]\n\t"
+		     ";;\n\t"
+		     /* *tmp = 0 */
+		     "st1 [%[tmp]]=r0\n\t"
+		     /* p6 = !masked */
+		     "cmp.ne.unc p6,p0=%[masked],r0\n\t"
+		     ";;\n\t"
+		     /* tmp = *pending_intr_addr */
+		     "(p6) ld1 %[tmp]=[%[pending_intr_addr]]\n\t"
+		     ";;\n\t"
+		     /* p7 = p6 && !tmp */
+		     "(p6) cmp.ne.unc p7,p0=%[tmp],r0\n\t"
+		     ";;\n\t"
+		     "(p7) break %[HYPERPRIVOP_SSM_I_IMM]\n\t"
+		     ".global xen_ssm_i_etag\n\t"
+		     "[xen_ssm_i_etag:]\n\t"
+		     ".global xen_ssm_i_instr_end\n\t"
+		     "xen_ssm_i_instr_end:\n\t"
+		     :
+		     [tmp] "=r"(tmp),
+		     [pending_intr_addr] "=r"(pending_intr_addr),
+		     [masked] "=r"(masked),
+
+		     "=m"(**((uint8_t **)XEN_PSR_I_ADDR_ADDR))
+		     :
+		     [XEN_PSR_I_ADDR_ADDR_IMM] "i"(XEN_PSR_I_ADDR_ADDR),
+		     [HYPERPRIVOP_SSM_I_IMM] "i"(HYPERPRIVOP_SSM_I),
+
+		     "m"(*((uint8_t *)XEN_PSR_I_ADDR_ADDR)),
+		     "m"(**((uint8_t **)XEN_PSR_I_ADDR_ADDR)),
+		     "m"(*(*((uint8_t **)XEN_PSR_I_ADDR_ADDR) - 1))
+		     :
+		     "memory",
+		     /*
+		      * predicate registers can't be specified as C variables
+		      * so that we use p6, p7, p8 here.
+		      */
+		     "p6", /* is_old */
+		     "p7"  /* is_pending */
+		);
+}
+
+void __init_or_module
+xen_privop_rsm_i(void)
+{
+	/*
+	 * psr_i_addr_addr = XEN_MAPPEDREGS->interrupt_mask_addr
+	 *                 = XEN_PSR_I_ADDR_ADDR;
+	 * psr_i_addr = *psr_i_addr_addr;
+	 * *psr_i_addr = 1;
+	 */
+	register unsigned long psr_i_addr asm("r8");
+	register uint8_t mask asm ("r9");
+	asm volatile (".global xen_rsm_i_instr\n\t"
+		      "xen_rsm_i_instr:\n\t"
+		      ".global xen_rsm_i_instr_start\n\t"
+		      "xen_rsm_i_instr_start:\n\t"
+		      ".global xen_rsm_i_stag\n\t"
+		      "[xen_rsm_i_stag:]\n\t"
+		      "mov %[psr_i_addr]=%[XEN_PSR_I_ADDR_ADDR_IMM]\n\t"
+		      "mov %[mask]=%[ONE_IMM]\n\t"
+		      ";;\n\t"
+		      "ld8 %[psr_i_addr]=[%[psr_i_addr]]\n\t"
+		      ";;\n\t"
+		      "st1 [%[psr_i_addr]]=%[mask]\n\t"
+		      ".global xen_rsm_i_etag\n\t"
+		      "[xen_rsm_i_etag:]\n\t"
+		      ".global xen_rsm_i_instr_end\n\t"
+		      "xen_rsm_i_instr_end:\n\t"
+		      :
+		      [psr_i_addr] "=r"(psr_i_addr),
+		      [mask] "=r"(mask),
+		      "=m"(**((uint8_t **)XEN_PSR_I_ADDR_ADDR)):
+		      [XEN_PSR_I_ADDR_ADDR_IMM] "i"(XEN_PSR_I_ADDR_ADDR),
+		      [ONE_IMM] "i"(1),
+		      "m"(*((uint8_t **)XEN_PSR_I_ADDR_ADDR)):
+		      "memory");
+}
+
+void __init_or_module
+xen_privop_ia64_intrin_local_irq_restore(unsigned long val)
+{
+	/*
+	 * psr_i_addr_addr = XEN_PSR_I_ADDR_ADDR
+	 * psr_i_addr = *psr_i_addr_addr
+	 * pending_intr_addr = psr_i_addr - 1
+	 * if (val & IA64_PSR_I) {
+	 *   masked = *psr_i_addr
+	 *   *psr_i_addr = 0
+	 *   compiler barrier
+	 *   if (masked) {
+	 *	uint8_t pending = *pending_intr_addr;
+	 *	if (pending)
+	 *		XEN_HYPER_SSM_I
+	 *   }
+	 * } else {
+	 *   *psr_i_addr = 1
+	 * }
+	 */
+
+	register unsigned long __val asm("r8") = val;
+	register uint8_t *psr_i_addr asm ("r9");
+	register uint8_t *pending_intr_addr asm ("r10");
+	register uint8_t masked asm ("r11");
+	register unsigned long one_or_pending asm ("r8");
+
+	asm volatile (
+		".global xen_intrin_local_irq_restore_instr\n\t"
+		"xen_intrin_local_irq_restore_instr:\n\t"
+		".global xen_intrin_local_irq_restore_instr_start\n\t"
+		"xen_intrin_local_irq_restore_instr_start:\n\t"
+		".global xen_intrin_local_irq_restore_stag\n\t"
+		"[xen_intrin_local_irq_restore_stag:]\n\t"
+		"tbit.nz p6,p7=%[val],%[IA64_PSR_I_BIT_IMM]\n\t"
+		"mov %[psr_i_addr]=%[XEN_PSR_I_ADDR_ADDR_IMM]\n\t"
+		";;\n\t"
+		"ld8 %[psr_i_addr]=[%[psr_i_addr]]\n\t"
+		"(p7)mov %[one_or_pending]=%[ONE_IMM]\n\t"
+		";;\n\t"
+		"add %[pending_intr_addr]=-1,%[psr_i_addr]\n\t"
+		";;\n\t"
+		"(p6) ld1 %[masked]=[%[psr_i_addr]]\n\t"
+		"(p7) st1 [%[psr_i_addr]]=%[one_or_pending]\n\t"
+		";;\n\t"
+		"(p6) st1 [%[psr_i_addr]]=r0\n\t"
+		"(p6) cmp.ne.unc p8,p0=%[masked],r0\n\t"
+		"(p6) ld1 %[one_or_pending]=[%[pending_intr_addr]]\n\t"
+		";;\n\t"
+		"(p8) cmp.eq.unc p9,p0=%[one_or_pending],r0\n\t"
+		";;\n\t"
+		"(p9) break %[HYPERPRIVOP_SSM_I_IMM]\n\t"
+		".global xen_intrin_local_irq_restore_etag\n\t"
+		"[xen_intrin_local_irq_restore_etag:]\n\t"
+		".global xen_intrin_local_irq_restore_instr_end\n\t"
+		"xen_intrin_local_irq_restore_instr_end:\n\t"
+		:
+		[psr_i_addr] "=r"(psr_i_addr),
+		[pending_intr_addr] "=r"(pending_intr_addr),
+		[masked] "=r"(masked),
+		[one_or_pending] "=r"(one_or_pending),
+
+		"=m"(**((uint8_t **)XEN_PSR_I_ADDR_ADDR))
+		:
+		[val] "r"(__val),
+		[IA64_PSR_I_BIT_IMM] "i"(IA64_PSR_I_BIT),
+		[ONE_IMM] "i"(1),
+
+		[XEN_PSR_I_ADDR_ADDR_IMM] "i"(XEN_PSR_I_ADDR_ADDR),
+		[HYPERPRIVOP_SSM_I_IMM] "i"(HYPERPRIVOP_SSM_I),
+
+		"m"(*((uint8_t *)XEN_PSR_I_ADDR_ADDR)),
+		"m"(**((uint8_t **)XEN_PSR_I_ADDR_ADDR)),
+		"m"(*(*((uint8_t **)XEN_PSR_I_ADDR_ADDR) - 1))
+		:
+		"memory",
+		"p6", /* is_psr_i_set  */
+		"p7", /* not_psr_i_set */
+		"p8", /* is_masked && is_psr_i_set */
+		"p9"  /* is_pending && is_masked && is_psr_i_set */
+		);
+}
+
+unsigned long __init_or_module
+xen_privop_get_psr_i(void)
+{
+	/*
+	 * tmp = XEN_MAPPEDREGS->interrupt_mask_addr = XEN_PSR_I_ADDR_ADDR;
+	 * tmp = *tmp
+	 * tmp = *tmp;
+	 * psr_i = tmp? 0: IA64_PSR_I;
+	 */
+	register unsigned long psr_i asm ("r8");
+	register unsigned long tmp asm ("r9");
+
+	asm volatile (".global xen_get_psr_i_instr\n\t"
+		      "xen_get_psr_i_instr:\n\t"
+		      ".global xen_get_psr_i_instr_start\n\t"
+		      "xen_get_psr_i_instr_start:\n\t"
+		      ".global xen_get_psr_i_stag\n\t"
+		      "[xen_get_psr_i_stag:]\n\t"
+		      /* tmp = XEN_PSR_I_ADDR_ADDR */
+		      "mov %[tmp]=%[XEN_PSR_I_ADDR_ADDR_IMM]\n\t"
+		      ";;\n\t"
+		      /* tmp = *tmp = *XEN_PSR_I_ADDR_ADDR */
+		      "ld8 %[tmp]=[%[tmp]]\n\t"
+		      /* psr_i = 0 */
+		      "mov %[psr_i]=0\n\t"
+		      ";;\n\t"
+		      /* tmp = *(uint8_t*)tmp */
+		      "ld1 %[tmp]=[%[tmp]]\n\t"
+		      ";;\n\t"
+		      /* if (!tmp) psr_i = IA64_PSR_I */
+		      "cmp.eq.unc p6,p0=%[tmp],r0\n\t"
+		      ";;\n\t"
+		      "(p6) mov %[psr_i]=%[IA64_PSR_I_IMM]\n\t"
+		      ".global xen_get_psr_i_etag\n\t"
+		      "[xen_get_psr_i_etag:]\n\t"
+		      ".global xen_get_psr_i_instr_end\n\t"
+		      "xen_get_psr_i_instr_end:\n\t"
+		      :
+		      [tmp] "=r"(tmp),
+		      [psr_i] "=r"(psr_i)
+		      :
+		      [XEN_PSR_I_ADDR_ADDR_IMM] "i"(XEN_PSR_I_ADDR_ADDR),
+		      [IA64_PSR_I_IMM] "i"(IA64_PSR_I),
+		      "m"(*((uint8_t **)XEN_PSR_I_ADDR_ADDR)),
+		      "m"(**((uint8_t **)XEN_PSR_I_ADDR_ADDR))
+		      :
+		      "p6");
+	return psr_i;
+}
diff --git a/arch/ia64/xen/xensetup.S b/arch/ia64/xen/xensetup.S
index 17ad297..2d3d5d4 100644
--- a/arch/ia64/xen/xensetup.S
+++ b/arch/ia64/xen/xensetup.S
@@ -35,6 +35,16 @@ GLOBAL_ENTRY(early_xen_setup)
 (isBP)	movl r28=XSI_BASE;;
 (isBP)	break 0x1000;;
 
+#ifdef CONFIG_PARAVIRT
+	/* patch privops */
+(isBP)	mov r4=rp
+	;;
+(isBP)	br.call.sptk.many rp=xen_paravirt_patch
+	;;
+(isBP)	mov rp=r4
+	;;
+#endif
+
 	br.ret.sptk.many rp
 	;;
 END(early_xen_setup)
diff --git a/include/asm-ia64/privop.h b/include/asm-ia64/privop.h
index 8261dad..fcca3f4 100644
--- a/include/asm-ia64/privop.h
+++ b/include/asm-ia64/privop.h
@@ -10,6 +10,10 @@
  *
  */
 
+#ifdef CONFIG_PARAVIRT
+#include <asm/privop_paravirt.h>
+#endif
+
 #ifdef CONFIG_XEN
 #include <asm/xen/privop.h>
 #endif
diff --git a/include/asm-ia64/privop_paravirt.h b/include/asm-ia64/privop_paravirt.h
new file mode 100644
index 0000000..00e4f03
--- /dev/null
+++ b/include/asm-ia64/privop_paravirt.h
@@ -0,0 +1,587 @@
+/******************************************************************************
+ * privops_paravirt.h
+ *
+ * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
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
+#ifndef _ASM_IA64_PRIVOP_PARAVIRT_H
+#define _ASM_IA64_PRIVOP_PARAVIRT_H
+
+#define PARAVIRT_INST_START			0x1
+#define PARAVIRT_INST_RFI			(PARAVIRT_INST_START + 0x0)
+#define PARAVIRT_INST_RSM_DT			(PARAVIRT_INST_START + 0x1)
+#define PARAVIRT_INST_SSM_DT			(PARAVIRT_INST_START + 0x2)
+#define PARAVIRT_INST_COVER			(PARAVIRT_INST_START + 0x3)
+#define PARAVIRT_INST_ITC_D			(PARAVIRT_INST_START + 0x4)
+#define PARAVIRT_INST_ITC_I			(PARAVIRT_INST_START + 0x5)
+#define PARAVIRT_INST_SSM_I			(PARAVIRT_INST_START + 0x6)
+#define PARAVIRT_INST_GET_IVR			(PARAVIRT_INST_START + 0x7)
+#define PARAVIRT_INST_GET_TPR			(PARAVIRT_INST_START + 0x8)
+#define PARAVIRT_INST_SET_TPR			(PARAVIRT_INST_START + 0x9)
+#define PARAVIRT_INST_EOI			(PARAVIRT_INST_START + 0xa)
+#define PARAVIRT_INST_SET_ITM			(PARAVIRT_INST_START + 0xb)
+#define PARAVIRT_INST_THASH			(PARAVIRT_INST_START + 0xc)
+#define PARAVIRT_INST_PTC_GA			(PARAVIRT_INST_START + 0xd)
+#define PARAVIRT_INST_ITR_D			(PARAVIRT_INST_START + 0xe)
+#define PARAVIRT_INST_GET_RR			(PARAVIRT_INST_START + 0xf)
+#define PARAVIRT_INST_SET_RR			(PARAVIRT_INST_START + 0x10)
+#define PARAVIRT_INST_SET_KR			(PARAVIRT_INST_START + 0x11)
+#define PARAVIRT_INST_FC			(PARAVIRT_INST_START + 0x12)
+#define PARAVIRT_INST_GET_CPUID			(PARAVIRT_INST_START + 0x13)
+#define PARAVIRT_INST_GET_PMD			(PARAVIRT_INST_START + 0x14)
+#define PARAVIRT_INST_GET_EFLAG			(PARAVIRT_INST_START + 0x15)
+#define PARAVIRT_INST_SET_EFLAG			(PARAVIRT_INST_START + 0x16)
+#define PARAVIRT_INST_RSM_BE			(PARAVIRT_INST_START + 0x17)
+#define PARAVIRT_INST_GET_PSR			(PARAVIRT_INST_START + 0x18)
+#define PARAVIRT_INST_SET_RR0_TO_RR4		(PARAVIRT_INST_START + 0x19)
+
+#define PARAVIRT_BNDL_START			0x10000000
+#define PARAVIRT_BNDL_SSM_I			(PARAVIRT_BNDL_START + 0x0)
+#define PARAVIRT_BNDL_RSM_I			(PARAVIRT_BNDL_START + 0x1)
+#define PARAVIRT_BNDL_GET_PSR_I			(PARAVIRT_BNDL_START + 0x2)
+#define PARAVIRT_BNDL_INTRIN_LOCAL_IRQ_RESTORE	(PARAVIRT_BNDL_START + 0x3)
+
+/*
+ * struct task_struct* (*ia64_switch_to)(void* next_task);
+ * void *ia64_leave_syscall;
+ * void *ia64_work_processed_syscall
+ * void *ia64_leave_kernel;
+ * struct ia64_pal_retval (*pal_call_static)(u64, u64, u64, u64, u64);
+ */
+
+#define PARAVIRT_ENTRY_START			0x20000000
+#define PARAVIRT_ENTRY_SWITCH_TO		(PARAVIRT_ENTRY_START + 0)
+#define PARAVIRT_ENTRY_LEAVE_SYSCALL		(PARAVIRT_ENTRY_START + 1)
+#define PARAVIRT_ENTRY_WORK_PROCESSED_SYSCALL	(PARAVIRT_ENTRY_START + 2)
+#define PARAVIRT_ENTRY_LEAVE_KERNEL		(PARAVIRT_ENTRY_START + 3)
+#define PARAVIRT_ENTRY_PAL_CALL_STATIC		(PARAVIRT_ENTRY_START + 4)
+
+
+#ifndef __ASSEMBLER__
+
+#include <linux/stringify.h>
+#include <linux/types.h>
+#include <asm/paravirt_alt.h>
+#include <asm/kregs.h> /* for IA64_PSR_I */
+#include <asm/xen/interface.h>
+
+/************************************************/
+/* Instructions paravirtualized for correctness */
+/************************************************/
+/* Note that "ttag" and "cover" are also privilege-sensitive; "ttag"
+ * is not currently used (though it may be in a long-format VHPT system!) */
+#ifdef ASM_SUPPORTED
+static inline unsigned long
+paravirt_fc(unsigned long addr)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __addr asm ("r8") = addr;
+	asm volatile (paravirt_alt_inst("fc %1", PARAVIRT_INST_THASH):
+		      "=r"(ia64_intri_res): "0"(__addr): "memory");
+	return ia64_intri_res;
+}
+#define paravirt_fc(addr)	paravirt_fc((unsigned long)addr)
+
+static inline unsigned long
+paravirt_thash(unsigned long addr)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __addr asm ("r8") = addr;
+	asm volatile (paravirt_alt_inst("thash %0=%1", PARAVIRT_INST_THASH):
+		      "=r"(ia64_intri_res): "0"(__addr));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+paravirt_get_cpuid(int index)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __index asm ("r8") = index;
+	asm volatile (paravirt_alt_inst("mov %0=cpuid[%r1]",
+				   PARAVIRT_INST_GET_CPUID):
+		      "=r"(ia64_intri_res): "0O"(__index));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+paravirt_get_pmd(int index)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __index asm ("r8") = index;
+	asm volatile (paravirt_alt_inst("mov %0=pmd[%1]",
+					PARAVIRT_INST_GET_PMD):
+		      "=r"(ia64_intri_res): "0"(__index));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+paravirt_get_eflag(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile (paravirt_alt_inst("mov %0=ar%1",
+					PARAVIRT_INST_GET_EFLAG):
+		"=r"(ia64_intri_res):
+		"i"(_IA64_REG_AR_EFLAG - _IA64_REG_AR_KR0): "memory");
+	return ia64_intri_res;
+}
+
+static inline void
+paravirt_set_eflag(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile (paravirt_alt_inst("mov ar%0=%1",
+					PARAVIRT_INST_SET_EFLAG)::
+		      "i"(_IA64_REG_AR_EFLAG - _IA64_REG_AR_KR0), "r"(__val):
+		      "memory");
+}
+
+/************************************************/
+/* Instructions paravirtualized for performance */
+/************************************************/
+
+static inline unsigned long
+paravirt_get_psr(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile (paravirt_alt_inst("mov %0=psr", PARAVIRT_INST_GET_PSR):
+		      "=r"(ia64_intri_res));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+paravirt_get_ivr(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile (paravirt_alt_inst("mov %0=cr%1", PARAVIRT_INST_GET_IVR):
+		      "=r"(ia64_intri_res):
+		      "i" (_IA64_REG_CR_IVR - _IA64_REG_CR_DCR));
+	return ia64_intri_res;
+}
+
+static inline unsigned long
+paravirt_get_tpr(void)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	asm volatile (paravirt_alt_inst("mov %0=cr%1", PARAVIRT_INST_GET_TPR):
+		      "=r"(ia64_intri_res):
+		      "i" (_IA64_REG_CR_TPR - _IA64_REG_CR_DCR));
+	return ia64_intri_res;
+}
+
+static inline void
+paravirt_set_tpr(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile (paravirt_alt_inst("mov cr%0=%1", PARAVIRT_INST_SET_TPR)::
+		      "i" (_IA64_REG_CR_TPR - _IA64_REG_CR_DCR), "r"(__val):
+		      "memory");
+}
+
+static inline void
+paravirt_eoi(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile (paravirt_alt_inst("mov cr%0=%1", PARAVIRT_INST_EOI)::
+		      "i" (_IA64_REG_CR_EOI - _IA64_REG_CR_DCR), "r"(__val):
+		      "memory");
+}
+
+static inline void
+paravirt_set_itm(unsigned long val)
+{
+	register __u64 __val asm ("r8") = val;
+	asm volatile (paravirt_alt_inst("mov cr%0=%1", PARAVIRT_INST_SET_ITM)::
+		      "i" (_IA64_REG_CR_ITM - _IA64_REG_CR_DCR), "r"(__val):
+		      "memory");
+}
+
+static inline void
+paravirt_ptcga(unsigned long addr, unsigned long size)
+{
+	register __u64 __addr asm ("r8") = addr;
+	register __u64 __size asm ("r9") = size;
+	asm volatile (paravirt_alt_inst("ptc.ga %0,%1", PARAVIRT_INST_PTC_GA)::
+		      "r"(__addr), "r"(__size): "memory");
+	ia64_dv_serialize_data();
+}
+
+static inline unsigned long
+paravirt_get_rr(unsigned long index)
+{
+	register __u64 ia64_intri_res asm ("r8");
+	register __u64 __index asm ("r8") = index;
+	asm volatile (paravirt_alt_inst("mov %0=rr[%1]", PARAVIRT_INST_GET_RR):
+		      "=r"(ia64_intri_res) : "0" (__index));
+	return ia64_intri_res;
+}
+
+static inline void
+paravirt_set_rr(unsigned long index, unsigned long val)
+{
+	register __u64 __index asm ("r8") = index;
+	register __u64 __val asm ("r9") = val;
+	asm volatile (paravirt_alt_inst("mov rr[%0]=%1", PARAVIRT_INST_SET_RR)::
+		      "r"(__index), "r"(__val): "memory");
+}
+
+static inline void
+paravirt_set_rr0_to_rr4(unsigned long val0, unsigned long val1,
+			unsigned long val2, unsigned long val3,
+			unsigned long val4)
+{
+	register __u64 __val0 asm ("r8") = val0;
+	register __u64 __val1 asm ("r9") = val1;
+	register __u64 __val2 asm ("r10") = val2;
+	register __u64 __val3 asm ("r11") = val3;
+	register __u64 __val4 asm ("r14") = val4;
+	asm volatile (paravirt_alt_inst("\t;;\n"
+					"\t{.mmi\n"
+					"\tmov rr[%0]=%1\n"
+					/*
+					 * without this stop bit
+					 * assembler complains.
+					 */
+					"\t;;\n"
+					"\tmov rr[%2]=%3\n"
+					"\tnop.i 0\n"
+					"\t}\n"
+					"\t{.mmi\n"
+					"\tmov rr[%4]=%5\n"
+					"\tmov rr[%6]=%7\n"
+					"\tnop.i 0\n"
+					"\t}\n"
+					"\tmov rr[%8]=%9;;\n",
+					PARAVIRT_INST_SET_RR0_TO_RR4)::
+		      "r"(0x0000000000000000UL), "r"(__val0),
+		      "r"(0x2000000000000000UL), "r"(__val1),
+		      "r"(0x4000000000000000UL), "r"(__val2),
+		      "r"(0x6000000000000000UL), "r"(__val3),
+		      "r"(0x8000000000000000UL), "r"(__val4) :
+		      "memory");
+}
+
+static inline void
+paravirt_set_kr(unsigned long index, unsigned long val)
+{
+	register __u64 __index asm ("r8") = index - _IA64_REG_AR_KR0;
+	register __u64 __val asm ("r9") = val;
+
+	/*
+	 * asm volatile ("break %0"::
+	 *	      "i"(PARAVIRT_INST_SET_KR), "r"(__index), "r"(__val));
+	 */
+#ifndef BUILD_BUG_ON
+#define BUILD_BUG_ON(condition) ((void)sizeof(char[1 - 2*!!(condition)]))
+#endif
+	BUILD_BUG_ON(!__builtin_constant_p(__index));
+	switch (index) {
+	case _IA64_REG_AR_KR0:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					   PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR0 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	case _IA64_REG_AR_KR1:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					   PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR1 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	case _IA64_REG_AR_KR2:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					    PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR2 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	case _IA64_REG_AR_KR3:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					   PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR3 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	case _IA64_REG_AR_KR4:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					   PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR4 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	case _IA64_REG_AR_KR5:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					   PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR5 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	case _IA64_REG_AR_KR6:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					   PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR6 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	case _IA64_REG_AR_KR7:
+		asm volatile (paravirt_alt_inst("mov ar%0=%2",
+					   PARAVIRT_INST_SET_KR)::
+			      "i" (_IA64_REG_AR_KR7 - _IA64_REG_AR_KR0),
+			      "r"(__index), "r"(__val):
+			      "memory");
+		break;
+	default: {
+		extern void compile_error_ar_kr_index_must_be_copmile_time_constant(void);
+		compile_error_ar_kr_index_must_be_copmile_time_constant();
+		break;
+	}
+	}
+}
+#endif /* ASM_SUPPORTED */
+
+static inline unsigned long
+paravirt_getreg(unsigned long regnum)
+{
+	__u64 ia64_intri_res;
+
+	switch (regnum) {
+	case _IA64_REG_PSR:
+		ia64_intri_res = paravirt_get_psr();
+		break;
+	case _IA64_REG_CR_IVR:
+		ia64_intri_res = paravirt_get_ivr();
+		break;
+	case _IA64_REG_CR_TPR:
+		ia64_intri_res = paravirt_get_tpr();
+		break;
+	case _IA64_REG_AR_EFLAG:
+		ia64_intri_res = paravirt_get_eflag();
+		break;
+	default:
+		ia64_intri_res = __ia64_getreg(regnum);
+		break;
+	}
+	return ia64_intri_res;
+ }
+
+static inline void
+paravirt_setreg(unsigned long regnum, unsigned long val)
+{
+	switch (regnum) {
+	case _IA64_REG_AR_KR0 ... _IA64_REG_AR_KR7:
+		paravirt_set_kr(regnum, val);
+		break;
+	case _IA64_REG_CR_ITM:
+		paravirt_set_itm(val);
+		break;
+	case _IA64_REG_CR_TPR:
+		paravirt_set_tpr(val);
+		break;
+	case _IA64_REG_CR_EOI:
+		paravirt_eoi(val);
+		break;
+	case _IA64_REG_AR_EFLAG:
+		paravirt_set_eflag(val);
+		break;
+	default:
+		__ia64_setreg(regnum, val);
+		break;
+	}
+}
+
+#ifdef ASM_SUPPORTED
+
+#define NOP_BUNDLE				\
+	"{\n\t"					\
+	"nop 0\n\t"				\
+	"nop 0\n\t"				\
+	"nop 0\n\t"				\
+	"}\n\t"
+
+static inline void
+paravirt_ssm_i(void)
+{
+	/* five bundles */
+	asm volatile (paravirt_alt_bundle("{\n\t"
+					  "ssm psr.i\n\t"
+					  "nop 0\n\t"
+					  "nop 0\n\t"
+					  "}\n\t"
+					  NOP_BUNDLE
+					  NOP_BUNDLE
+					  NOP_BUNDLE
+					  NOP_BUNDLE,
+					  PARAVIRT_BNDL_SSM_I):::
+		      "r8", "r9", "r10",
+		      "p6", "p7",
+		      "memory");
+}
+
+static inline void
+paravirt_rsm_i(void)
+{
+	/* two budles */
+	asm volatile (paravirt_alt_bundle("{\n\t"
+					  "rsm psr.i\n\t"
+					  "nop 0\n\t"
+					  "nop 0\n\t"
+					  "}\n\t"
+					  NOP_BUNDLE,
+					  PARAVIRT_BNDL_RSM_I):::
+		      "r8", "r9",
+		      "memory");
+}
+
+static inline unsigned long
+paravirt_get_psr_i(void)
+{
+	register unsigned long psr_i asm ("r8");
+	register unsigned long mask asm ("r9");
+
+	/* three bundles */
+	asm volatile (paravirt_alt_bundle("{\n\t"
+					  "mov %0=psr\n\t"
+					  "mov %1=%2\n\t"
+					  ";;\n\t"
+					  "and %0=%0,%1\n\t"
+					  "}\n\t"
+					  NOP_BUNDLE
+					  NOP_BUNDLE,
+					  PARAVIRT_BNDL_GET_PSR_I):
+		      "=r"(psr_i),
+		      "=r"(mask)
+		      :
+		      "i"(IA64_PSR_I)
+		      :
+		      /* "r8", "r9", */
+		      "p6");
+	return psr_i;
+}
+
+static inline void
+paravirt_intrin_local_irq_restore(unsigned long flags)
+{
+	register unsigned long __flags asm ("r8") = flags;
+
+	/* six bundles */
+	asm volatile (paravirt_alt_bundle(";;\n\t"
+					  "{\n\t"
+					  "cmp.ne p6,p7=%0,r0;;\n\t"
+					  "(p6) ssm psr.i;\n\t"
+					  "nop 0\n\t"
+					  "}\n\t"
+					  "{\n\t"
+					  "(p7) rsm psr.i;;\n\t"
+					  "(p6) srlz.d\n\t"
+					  "nop 0\n\t"
+					  "}\n\t"
+					  NOP_BUNDLE
+					  NOP_BUNDLE
+					  NOP_BUNDLE
+					  NOP_BUNDLE,
+					  PARAVIRT_BNDL_INTRIN_LOCAL_IRQ_RESTORE)::
+		      "r"(__flags) :
+		      /* "r8",*/ "r9", "r10", "r11",
+		      "p6", "p7", "p8", "p9",
+		      "memory");
+
+}
+
+#undef NOP_BUNDLE
+
+#endif /* ASM_SUPPORTED */
+
+static inline void
+paravirt_ssm(unsigned long mask)
+{
+	if (mask = IA64_PSR_I)
+		paravirt_ssm_i();
+	else
+		__ia64_ssm(mask);
+}
+
+static inline void
+paravirt_rsm(unsigned long mask)
+{
+	if (mask = IA64_PSR_I)
+		paravirt_rsm_i();
+	else
+		__ia64_rsm(mask);
+}
+
+#if defined(ASM_SUPPORTED) && defined(CONFIG_PARAVIRT_ALT)
+
+#define IA64_PARAVIRTUALIZED_PRIVOP
+
+#define ia64_fc(addr)			paravirt_fc(addr)
+#define ia64_thash(addr)		paravirt_thash(addr)
+#define ia64_get_cpuid(i)		paravirt_get_cpuid(i)
+#define ia64_get_pmd(i)			paravirt_get_pmd(i)
+#define ia64_ptcga(addr, size)		paravirt_ptcga((addr), (size))
+#define ia64_set_rr(index, val)		paravirt_set_rr((index), (val))
+#define ia64_get_rr(index)		paravirt_get_rr(index)
+#define ia64_getreg(regnum)		paravirt_getreg(regnum)
+#define ia64_setreg(regnum, val)	paravirt_setreg((regnum), (val))
+#define ia64_set_rr0_to_rr4(val0, val1, val2, val3, val4)		\
+	paravirt_set_rr0_to_rr4((val0), (val1), (val2), (val3), (val4))
+
+#define ia64_ssm(mask)			paravirt_ssm(mask)
+#define ia64_rsm(mask)			paravirt_rsm(mask)
+#define ia64_get_psr_i()		paravirt_get_psr_i()
+#define ia64_intrin_local_irq_restore(x)	\
+	paravirt_intrin_local_irq_restore(x)
+
+/* the remainder of these are not performance-sensitive so its
+ * OK to not paravirtualize and just take a privop trap and emulate */
+#define ia64_hint			__ia64_hint
+#define ia64_set_pmd			__ia64_set_pmd
+#define ia64_itci			__ia64_itci
+#define ia64_itcd			__ia64_itcd
+#define ia64_itri			__ia64_itri
+#define ia64_itrd			__ia64_itrd
+#define ia64_tpa			__ia64_tpa
+#define ia64_set_ibr			__ia64_set_ibr
+#define ia64_set_pkr			__ia64_set_pkr
+#define ia64_set_pmc			__ia64_set_pmc
+#define ia64_get_ibr			__ia64_get_ibr
+#define ia64_get_pkr			__ia64_get_pkr
+#define ia64_get_pmc			__ia64_get_pmc
+#define ia64_ptce			__ia64_ptce
+#define ia64_ptcl			__ia64_ptcl
+#define ia64_ptri			__ia64_ptri
+#define ia64_ptrd			__ia64_ptrd
+
+#endif /* ASM_SUPPORTED && CONFIG_PARAVIRT_ALT */
+
+#endif /* __ASSEMBLER__*/
+
+/* these routines utilize privilege-sensitive or performance-sensitive
+ * privileged instructions so the code must be replaced with
+ * paravirtualized versions */
+#ifdef CONFIG_PARAVIRT_ENTRY
+#define IA64_PARAVIRTUALIZED_ENTRY
+#define ia64_switch_to			paravirt_switch_to
+#define ia64_work_processed_syscall	paravirt_work_processed_syscall
+#define ia64_leave_syscall		paravirt_leave_syscall
+#define ia64_leave_kernel		paravirt_leave_kernel
+#define ia64_pal_call_static		paravirt_pal_call_static
+#endif /* CONFIG_PARAVIRT_ENTRY */
+
+#endif /* _ASM_IA64_PRIVOP_PARAVIRT_H */
diff --git a/include/asm-ia64/xen/privop.h b/include/asm-ia64/xen/privop.h
index 3caa7e9..2c70988 100644
--- a/include/asm-ia64/xen/privop.h
+++ b/include/asm-ia64/xen/privop.h
@@ -557,6 +557,18 @@ do {									\
 
 #endif /* ASM_SUPPORTED && !CONFIG_PARAVIRT_ALT */
 
+#ifdef CONFIG_PARAVIRT_ALT
+#if defined(CONFIG_MODULES) && defined(CONFIG_XEN)
+void xen_alt_bundle_patch_module(struct paravirt_alt_bundle_patch *start,
+				 struct paravirt_alt_bundle_patch *end);
+void xen_alt_inst_patch_module(struct paravirt_alt_inst_patch *start,
+			       struct paravirt_alt_inst_patch *end);
+#else
+#define xen_alt_bundle_patch_module(start, end)	do { } while (0)
+#define xen_alt_inst_patch_module(start, end)	do { } while (0)
+#endif
+#endif /* CONFIG_PARAVIRT_ALT */
+
 #endif /* !__ASSEMBLY__ */
 
 /* these routines utilize privilege-sensitive or performance-sensitive
@@ -573,12 +585,24 @@ do {									\
 
 #ifdef CONFIG_XEN
 #ifdef __ASSEMBLY__
+#ifdef CONFIG_PARAVIRT_ENTRY
+#define BR_IF_NATIVE(target, reg_unused, pred_unused)	/* nothing */
+#elif defined(CONFIG_PARAVIRT_NOP_B_PATCH)
+#define BR_IF_NATIVE(target, reg_unused, pred_unused)	\
+	.body ;						\
+	[1:] ;						\
+	br.cond.sptk.many target;; ;			\
+	.section .paravirt_nop_b, "a" ;			\
+	.previous ;					\
+	.xdata8 ".paravirt_nop_b", 1b
+#else
 #define BR_IF_NATIVE(target, reg, pred)		\
 	.body ;					\
 	movl reg=running_on_xen;; ;		\
 	ld4 reg=[reg];; ;			\
 	cmp.eq pred,p0=reg,r0 ;			\
 	(pred)	br.cond.sptk.many target;;
+#endif
 #endif /* __ASSEMBLY__ */
 #endif
 
-- 
1.5.3

