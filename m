From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 12 Dec 2008 06:41:15 +0000
Subject: [PATCH 1/5] ia64/pv_op/binarypatch: add helper functions to support binary patching for paravirt_ops
Message-Id: <1229064079-27735-2-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1227618235-3890-2-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1227618235-3890-2-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

add helper functions to support binary patching for paravirt_ops.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/paravirt_patch.h |  143 +++++++++
 arch/ia64/kernel/paravirt_patch.c      |  514 ++++++++++++++++++++++++++++++++
 arch/ia64/kernel/paravirtentry.S       |   56 ++++
 arch/ia64/kernel/vmlinux.lds.S         |   24 ++
 4 files changed, 737 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/include/asm/paravirt_patch.h
 create mode 100644 arch/ia64/kernel/paravirt_patch.c

diff --git a/arch/ia64/include/asm/paravirt_patch.h b/arch/ia64/include/asm/paravirt_patch.h
new file mode 100644
index 0000000..23d4fbf
--- /dev/null
+++ b/arch/ia64/include/asm/paravirt_patch.h
@@ -0,0 +1,143 @@
+/******************************************************************************
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
+#ifndef __ASM_PARAVIRT_PATCH_H
+#define __ASM_PARAVIRT_PATCH_H
+
+#ifdef __ASSEMBLY__
+
+	.section .paravirt_branches, "a"
+	.previous
+#define PARAVIRT_PATCH_SITE_BR(type)		\
+	{					\
+	[1:] ;					\
+	br.cond.sptk.many 2f ;			\
+	nop.b 0 ;				\
+	nop.b 0;; ;				\
+	} ;					\
+	2:					\
+	.xdata8 ".paravirt_branches", 1b, type
+
+#else
+
+#include <linux/stringify.h>
+#include <asm/intrinsics.h>
+
+/* for binary patch */
+struct paravirt_patch_site_bundle {
+	void		*sbundle;
+	void		*ebundle;
+	unsigned long	type;
+};
+
+/* label means the beginning of new bundle */
+#define paravirt_alt_bundle(instr, privop)				\
+	"\t998:\n"							\
+	"\t" instr "\n"							\
+	"\t999:\n"							\
+	"\t.pushsection .paravirt_bundles, \"a\"\n"			\
+	"\t.popsection\n"						\
+	"\t.xdata8 \".paravirt_bundles\", 998b, 999b, "			\
+	__stringify(privop) "\n"
+
+
+struct paravirt_patch_bundle_elem {
+	const void	*sbundle;
+	const void	*ebundle;
+	unsigned long	type;
+};
+
+
+struct paravirt_patch_site_inst {
+	unsigned long	stag;
+	unsigned long	etag;
+	unsigned long	type;
+};
+
+#define paravirt_alt_inst(instr, privop)				\
+	"\t[998:]\n"							\
+	"\t" instr "\n"							\
+	"\t[999:]\n"							\
+	"\t.pushsection .paravirt_insts, \"a\"\n"			\
+	"\t.popsection\n"						\
+	"\t.xdata8 \".paravirt_insts\", 998b, 999b, "			\
+	__stringify(privop) "\n"
+
+struct paravirt_patch_site_branch {
+	unsigned long	tag;
+	unsigned long	type;
+};
+
+struct paravirt_patch_branch_target {
+	const void	*entry;
+	unsigned long	type;
+};
+
+void
+__paravirt_patch_apply_branch(
+	unsigned long tag, unsigned long type,
+	const struct paravirt_patch_branch_target *entries,
+	unsigned int nr_entries);
+
+void
+paravirt_patch_reloc_br(unsigned long tag, const void *target);
+
+void
+paravirt_patch_reloc_brl(unsigned long tag, const void *target);
+
+
+#ifdef ASM_SUPPORTED
+unsigned long
+ia64_native_patch_bundle(void *sbundle, void *ebundle, unsigned long type);
+
+unsigned long
+__paravirt_patch_apply_bundle(void *sbundle, void *ebundle, unsigned long type,
+			      const struct paravirt_patch_bundle_elem *elems,
+			      unsigned long nelems,
+			      const struct paravirt_patch_bundle_elem **found);
+
+void
+paravirt_patch_apply_bundle(const struct paravirt_patch_site_bundle *start,
+			    const struct paravirt_patch_site_bundle *end);
+
+void
+paravirt_patch_apply_inst(const struct paravirt_patch_site_inst *start,
+			  const struct paravirt_patch_site_inst *end);
+
+void paravirt_patch_apply(void);
+#else
+#define paravirt_patch_apply_bundle(start, end)	do { } while (0)
+#define paravirt_patch_apply_inst(start, end)	do { } while (0)
+#define paravirt_patch_apply()			do { } while (0)
+#endif
+
+#endif /* !__ASSEMBLEY__ */
+
+#endif /* __ASM_PARAVIRT_PATCH_H */
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
diff --git a/arch/ia64/kernel/paravirt_patch.c b/arch/ia64/kernel/paravirt_patch.c
new file mode 100644
index 0000000..356f196
--- /dev/null
+++ b/arch/ia64/kernel/paravirt_patch.c
@@ -0,0 +1,514 @@
+/******************************************************************************
+ * linux/arch/ia64/xen/paravirt_patch.c
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
+#include <linux/init.h>
+#include <asm/intrinsics.h>
+#include <asm/kprobes.h>
+#include <asm/paravirt.h>
+#include <asm/paravirt_patch.h>
+
+typedef union ia64_inst {
+        struct {
+		unsigned long long qp : 6;
+		unsigned long long : 31;
+		unsigned long long opcode : 4;
+		unsigned long long reserved : 23;
+        } generic;
+        unsigned long long l;
+} ia64_inst_t;
+
+/*
+ * flush_icache_range() can't be used here.
+ * we are here before cpu_init() which initializes
+ * ia64_i_cache_stride_shift. flush_icache_range() uses it.
+ */
+void __init_or_module
+paravirt_flush_i_cache_range(const void *instr, unsigned long size)
+{
+	extern void paravirt_fc_i(unsigned long addr);
+	unsigned long i;
+
+	for (i = 0; i < size; i += sizeof(bundle_t))
+		paravirt_fc_i(instr + i);
+}
+
+bundle_t* __init_or_module
+paravirt_get_bundle(unsigned long tag)
+{
+	return (bundle_t *)(tag & ~3UL);
+}
+
+unsigned long __init_or_module
+paravirt_get_slot(unsigned long tag)
+{
+	return tag & 3UL;
+}
+
+unsigned long __init_or_module
+paravirt_get_num_inst(unsigned long stag, unsigned long etag)
+{
+	bundle_t *sbundle = paravirt_get_bundle(stag);
+	unsigned long sslot = paravirt_get_slot(stag);
+	bundle_t *ebundle = paravirt_get_bundle(etag);
+	unsigned long eslot = paravirt_get_slot(etag);
+
+	return (ebundle - sbundle) * 3 + eslot - sslot + 1;
+}
+
+unsigned long __init_or_module
+paravirt_get_next_tag(unsigned long tag)
+{
+	unsigned long slot = paravirt_get_slot(tag);
+
+	switch (slot) {
+	case 0:
+	case 1:
+		return tag + 1;
+	case 2: {
+		bundle_t *bundle = paravirt_get_bundle(tag);
+		return (unsigned long)(bundle + 1);
+	}
+	default:
+		BUG();
+	}
+	/* NOTREACHED */
+}
+
+ia64_inst_t __init_or_module
+paravirt_read_slot0(const bundle_t *bundle)
+{
+	ia64_inst_t inst;
+	inst.l = bundle->quad0.slot0;
+	return inst;
+}
+
+ia64_inst_t __init_or_module
+paravirt_read_slot1(const bundle_t *bundle)
+{
+	ia64_inst_t inst;
+	inst.l = bundle->quad0.slot1_p0 |
+		((unsigned long long)bundle->quad1.slot1_p1 << 18UL);
+	return inst;
+}
+
+ia64_inst_t __init_or_module
+paravirt_read_slot2(const bundle_t *bundle)
+{
+	ia64_inst_t inst;
+	inst.l = bundle->quad1.slot2;
+	return inst;
+}
+
+ia64_inst_t __init_or_module
+paravirt_read_inst(unsigned long tag)
+{
+	bundle_t *bundle = paravirt_get_bundle(tag);
+	unsigned long slot = paravirt_get_slot(tag);
+
+	switch (slot) {
+	case 0:
+		return paravirt_read_slot0(bundle);
+	case 1:
+		return paravirt_read_slot1(bundle);
+	case 2:
+		return paravirt_read_slot2(bundle);
+	default:
+		BUG();
+	}
+	/* NOTREACHED */
+}
+
+void __init_or_module
+paravirt_write_slot0(bundle_t *bundle, ia64_inst_t inst)
+{
+	bundle->quad0.slot0 = inst.l;
+}
+
+void __init_or_module
+paravirt_write_slot1(bundle_t *bundle, ia64_inst_t inst)
+{
+	bundle->quad0.slot1_p0 = inst.l;
+	bundle->quad1.slot1_p1 = inst.l >> 18UL;
+}
+
+void __init_or_module
+paravirt_write_slot2(bundle_t *bundle, ia64_inst_t inst)
+{
+	bundle->quad1.slot2 = inst.l;
+}
+
+void __init_or_module
+paravirt_write_inst(unsigned long tag, ia64_inst_t inst)
+{
+	bundle_t *bundle = paravirt_get_bundle(tag);
+	unsigned long slot = paravirt_get_slot(tag);
+
+	switch (slot) {
+	case 0:
+		paravirt_write_slot0(bundle, inst);
+		break;
+	case 1:
+		paravirt_write_slot1(bundle, inst);
+		break;
+	case 2:
+		paravirt_write_slot2(bundle, inst);
+		break;
+	default:
+		BUG();
+		break;
+	}
+	paravirt_flush_i_cache_range(bundle, sizeof(*bundle));
+}
+
+/* for debug */
+void
+paravirt_print_bundle(const bundle_t *bundle)
+{
+	const unsigned long *quad = (const unsigned long *)bundle;
+	ia64_inst_t slot0 = paravirt_read_slot0(bundle);
+	ia64_inst_t slot1 = paravirt_read_slot1(bundle);
+	ia64_inst_t slot2 = paravirt_read_slot2(bundle);
+
+	printk(KERN_DEBUG
+	       "bundle 0x%p 0x%016lx 0x%016lx\n", bundle, quad[0], quad[1]);
+	printk(KERN_DEBUG
+	       "bundle template 0x%x\n",
+	       bundle->quad0.template);
+	printk(KERN_DEBUG
+	       "slot0 0x%lx slot1_p0 0x%lx slot1_p1 0x%lx slot2 0x%lx\n",
+	       (unsigned long)bundle->quad0.slot0,
+	       (unsigned long)bundle->quad0.slot1_p0,
+	       (unsigned long)bundle->quad1.slot1_p1,
+	       (unsigned long)bundle->quad1.slot2);
+	printk(KERN_DEBUG
+	       "slot0 0x%016llx slot1 0x%016llx slot2 0x%016llx\n",
+	       slot0.l, slot1.l, slot2.l);
+}
+
+static int noreplace_paravirt __init_or_module = 0;
+
+static int __init setup_noreplace_paravirt(char *str)
+{
+	noreplace_paravirt = 1;
+	return 1;
+}
+__setup("noreplace-paravirt", setup_noreplace_paravirt);
+
+#ifdef ASM_SUPPORTED
+static void __init_or_module
+fill_nop_bundle(void *sbundle, void *ebundle)
+{
+	extern const char paravirt_nop_bundle[];
+	extern const unsigned long paravirt_nop_bundle_size;
+
+	void *bundle = sbundle;
+
+	BUG_ON((((unsigned long)sbundle) % sizeof(bundle_t)) != 0);
+	BUG_ON((((unsigned long)ebundle) % sizeof(bundle_t)) != 0);
+
+	while (bundle < ebundle) {
+		memcpy(bundle, paravirt_nop_bundle, paravirt_nop_bundle_size);
+
+		bundle += paravirt_nop_bundle_size;
+	}
+}
+
+/* helper function */
+unsigned long __init_or_module
+__paravirt_patch_apply_bundle(void *sbundle, void *ebundle, unsigned long type,
+			      const struct paravirt_patch_bundle_elem *elems,
+			      unsigned long nelems,
+			      const struct paravirt_patch_bundle_elem **found)
+{
+	unsigned long used = 0;
+	unsigned long i;
+
+	BUG_ON((((unsigned long)sbundle) % sizeof(bundle_t)) != 0);
+	BUG_ON((((unsigned long)ebundle) % sizeof(bundle_t)) != 0);
+
+	found = NULL;
+	for (i = 0; i < nelems; i++) {
+		const struct paravirt_patch_bundle_elem *p = &elems[i];
+		if (p->type = type) {
+			unsigned long need = p->ebundle - p->sbundle;
+			unsigned long room = ebundle - sbundle;
+
+			if (found != NULL)
+				*found = p;
+
+			if (room < need) {
+				/* no room to replace. skip it */
+				printk(KERN_DEBUG
+				       "the space is too small to put "
+				       "bundles. type %ld need %ld room %ld\n",
+				       type, need, room);
+				break;
+			}
+
+			used = need;
+			memcpy(sbundle, p->sbundle, used);
+			break;
+		}
+	}
+
+	return used;
+}
+
+void __init_or_module
+paravirt_patch_apply_bundle(const struct paravirt_patch_site_bundle *start,
+			    const struct paravirt_patch_site_bundle *end)
+{
+	const struct paravirt_patch_site_bundle *p;
+
+	if (noreplace_paravirt)
+		return;
+	if (pv_init_ops.patch_bundle = NULL)
+		return;
+
+	for (p = start; p < end; p++) {
+		unsigned long used;
+
+		used = (*pv_init_ops.patch_bundle)(p->sbundle, p->ebundle,
+						   p->type);
+		if (used = 0)
+			continue;
+
+		fill_nop_bundle(p->sbundle + used, p->ebundle);
+		paravirt_flush_i_cache_range(p->sbundle,
+					     p->ebundle - p->sbundle);
+	}
+	ia64_sync_i();
+	ia64_srlz_i();
+}
+
+/*
+ * nop.i, nop.m, nop.f instruction are same format.
+ * but nop.b has differennt format.
+ * This doesn't support nop.b for now.
+ */
+static void __init_or_module
+fill_nop_inst(unsigned long stag, unsigned long etag)
+{
+	extern const bundle_t paravirt_nop_mfi_inst_bundle[];
+	unsigned long tag;
+	const ia64_inst_t nop_inst +		paravirt_read_slot0(paravirt_nop_mfi_inst_bundle);
+
+	for (tag = stag; tag < etag; tag = paravirt_get_next_tag(tag))
+		paravirt_write_inst(tag, nop_inst);
+}
+
+void __init_or_module
+paravirt_patch_apply_inst(const struct paravirt_patch_site_inst *start,
+			  const struct paravirt_patch_site_inst *end)
+{
+	const struct paravirt_patch_site_inst *p;
+
+	if (noreplace_paravirt)
+		return;
+	if (pv_init_ops.patch_inst = NULL)
+		return;
+
+	for (p = start; p < end; p++) {
+		unsigned long tag;
+		bundle_t *sbundle;
+		bundle_t *ebundle;
+
+		tag = (*pv_init_ops.patch_inst)(p->stag, p->etag, p->type);
+		if (tag = p->stag)
+			continue;
+
+		fill_nop_inst(tag, p->etag);
+		sbundle = paravirt_get_bundle(p->stag);
+		ebundle = paravirt_get_bundle(p->etag) + 1;
+		paravirt_flush_i_cache_range(sbundle, (ebundle - sbundle) *
+					     sizeof(bundle_t));
+	}
+	ia64_sync_i();
+	ia64_srlz_i();
+}
+#endif /* ASM_SUPPOTED */
+
+/* brl.cond.sptk.many <target64> X3 */
+typedef union inst_x3_op {
+	ia64_inst_t inst;
+	struct {
+		unsigned long qp: 6;
+		unsigned long btyp: 3;
+		unsigned long unused: 3;
+		unsigned long p: 1;
+		unsigned long imm20b: 20;
+		unsigned long wh: 2;
+		unsigned long d: 1;
+		unsigned long i: 1;
+		unsigned long opcode: 4;
+	};
+	unsigned long l;
+} inst_x3_op_t;
+
+typedef union inst_x3_imm {
+	ia64_inst_t inst;
+	struct {
+		unsigned long unused: 2;
+		unsigned long imm39: 39;
+	};
+	unsigned long l;
+} inst_x3_imm_t;
+
+void __init_or_module
+paravirt_patch_reloc_brl(unsigned long tag, const void *target)
+{
+	unsigned long tag_op = paravirt_get_next_tag(tag);
+	unsigned long tag_imm = tag;
+	bundle_t *bundle = paravirt_get_bundle(tag);
+
+	ia64_inst_t inst_op = paravirt_read_inst(tag_op);
+	ia64_inst_t inst_imm = paravirt_read_inst(tag_imm);
+
+	inst_x3_op_t inst_x3_op = { .l = inst_op.l };
+	inst_x3_imm_t inst_x3_imm = { .l = inst_imm.l };
+
+	unsigned long imm60 +		((unsigned long)target - (unsigned long)bundle) >> 4;
+
+	BUG_ON(paravirt_get_slot(tag) != 1); /* MLX */
+	BUG_ON(((unsigned long)target & (sizeof(bundle_t) - 1)) != 0);
+
+	/* imm60[59] 1bit */
+	inst_x3_op.i = (imm60 >> 59) & 1;
+	/* imm60[19:0] 20bit */
+	inst_x3_op.imm20b = imm60 & ((1UL << 20) - 1);
+	/* imm60[58:20] 39bit */
+	inst_x3_imm.imm39 = (imm60 >> 20) & ((1UL << 39) - 1);
+
+	inst_op.l = inst_x3_op.l;
+	inst_imm.l = inst_x3_imm.l;
+
+	paravirt_write_inst(tag_op, inst_op);
+	paravirt_write_inst(tag_imm, inst_imm);
+}
+
+/* br.cond.sptk.many <target25>	B1 */
+typedef union inst_b1 {
+	ia64_inst_t inst;
+	struct {
+		unsigned long qp: 6;
+		unsigned long btype: 3;
+		unsigned long unused: 3;
+		unsigned long p: 1;
+		unsigned long imm20b: 20;
+		unsigned long wh: 2;
+		unsigned long d: 1;
+		unsigned long s: 1;
+		unsigned long opcode: 4;
+	};
+	unsigned long l;
+} inst_b1_t;
+
+void __init
+paravirt_patch_reloc_br(unsigned long tag, const void *target)
+{
+	bundle_t *bundle = paravirt_get_bundle(tag);
+	ia64_inst_t inst = paravirt_read_inst(tag);
+	unsigned long target25 = (unsigned long)target - (unsigned long)bundle;
+	inst_b1_t inst_b1;
+
+	BUG_ON(((unsigned long)target & (sizeof(bundle_t) - 1)) != 0);
+
+	inst_b1.l = inst.l;
+	if (target25 & (1UL << 63))
+		inst_b1.s = 1;
+	else
+		inst_b1.s = 0;
+
+	inst_b1.imm20b = target25 >> 4;
+	inst.l = inst_b1.l;
+
+	paravirt_write_inst(tag, inst);
+}
+
+void __init
+__paravirt_patch_apply_branch(
+	unsigned long tag, unsigned long type,
+	const struct paravirt_patch_branch_target *entries,
+	unsigned int nr_entries)
+{
+	unsigned int i;
+	for (i = 0; i < nr_entries; i++) {
+		if (entries[i].type = type) {
+			paravirt_patch_reloc_br(tag, entries[i].entry);
+			break;
+		}
+	}
+}
+
+static void __init
+paravirt_patch_apply_branch(const struct paravirt_patch_site_branch *start,
+			    const struct paravirt_patch_site_branch *end)
+{
+	const struct paravirt_patch_site_branch *p;
+
+	if (noreplace_paravirt)
+		return;
+	if (pv_init_ops.patch_branch = NULL)
+		return;
+
+	for (p = start; p < end; p++)
+		(*pv_init_ops.patch_branch)(p->tag, p->type);
+
+	ia64_sync_i();
+	ia64_srlz_i();
+}
+
+void __init
+paravirt_patch_apply(void)
+{
+	extern const char __start_paravirt_bundles[];
+	extern const char __stop_paravirt_bundles[];
+	extern const char __start_paravirt_insts[];
+	extern const char __stop_paravirt_insts[];
+	extern const char __start_paravirt_branches[];
+	extern const char __stop_paravirt_branches[];
+
+	paravirt_patch_apply_bundle((const struct paravirt_patch_site_bundle *)
+				    __start_paravirt_bundles,
+				    (const struct paravirt_patch_site_bundle *)
+				    __stop_paravirt_bundles);
+	paravirt_patch_apply_inst((const struct paravirt_patch_site_inst *)
+				  __start_paravirt_insts,
+				  (const struct paravirt_patch_site_inst *)
+				  __stop_paravirt_insts);
+	paravirt_patch_apply_branch((const struct paravirt_patch_site_branch *)
+				    __start_paravirt_branches,
+				    (const struct paravirt_patch_site_branch *)
+				    __stop_paravirt_branches);
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
diff --git a/arch/ia64/kernel/paravirtentry.S b/arch/ia64/kernel/paravirtentry.S
index 2f42fcb..80c0d36 100644
--- a/arch/ia64/kernel/paravirtentry.S
+++ b/arch/ia64/kernel/paravirtentry.S
@@ -58,3 +58,59 @@ BRANCH_PROC(switch_to, r22, b7)
 BRANCH_PROC_UNWINFO(leave_syscall, r22, b7)
 BRANCH_PROC(work_processed_syscall, r2, b7)
 BRANCH_PROC_UNWINFO(leave_kernel, r22, b7)
+
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
+	GLOBAL_ENTRY(paravirt_fc_i)
+	fc.i r32
+	br.ret.sptk.many rp
+	END(paravirt_fc_i)
+	__FINIT
+
+	__INIT_OR_MODULE
+	.align 32
+	GLOBAL_ENTRY(paravirt_nop_b_inst_bundle)
+	{
+		nop.b 0
+		nop.b 0
+		nop.b 0
+	}
+	END(paravirt_nop_b_inst_bundle)
+	__FINIT
+
+	/* NOTE: nop.[mfi] has same format */
+	__INIT_OR_MODULE
+	GLOBAL_ENTRY(paravirt_nop_mfi_inst_bundle)
+	{
+		nop.m 0
+		nop.f 0
+		nop.i 0
+	}
+	END(paravirt_nop_mfi_inst_bundle)
+	__FINIT
+
+	__INIT_OR_MODULE
+	GLOBAL_ENTRY(paravirt_nop_bundle)
+paravirt_nop_bundle_start:
+	{
+		nop 0
+		nop 0
+		nop 0
+	}
+paravirt_nop_bundle_end:
+	END(paravirt_nop_bundle)
+	__FINIT
+
+	__INITDATA_OR_MODULE
+	.align 8
+	.global paravirt_nop_bundle_size
+paravirt_nop_bundle_size:
+	data8	paravirt_nop_bundle_end - paravirt_nop_bundle_start
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index 92ae7e8..794d168 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -169,6 +169,30 @@ SECTIONS
 	  __end___mckinley_e9_bundles = .;
 	}
 
+#if defined(CONFIG_PARAVIRT)
+  . = ALIGN(16);
+  .paravirt_bundles : AT(ADDR(.paravirt_bundles) - LOAD_OFFSET)
+	{
+	  __start_paravirt_bundles = .;
+          *(.paravirt_bundles)
+	  __stop_paravirt_bundles = .;
+	}
+  . = ALIGN(16);
+  .paravirt_insts : AT(ADDR(.paravirt_insts) - LOAD_OFFSET)
+	{
+	  __start_paravirt_insts = .;
+          *(.paravirt_insts)
+	  __stop_paravirt_insts = .;
+	}
+  . = ALIGN(16);
+  .paravirt_branches : AT(ADDR(.paravirt_branches) - LOAD_OFFSET)
+	{
+	  __start_paravirt_branches = .;
+	  *(.paravirt_branches)
+	  __stop_paravirt_branches = .;
+	}
+#endif
+
 #if defined(CONFIG_IA64_GENERIC)
   /* Machine Vector */
   . = ALIGN(16);
-- 
1.6.0.2

