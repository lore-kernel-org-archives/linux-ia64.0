From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:32 +0000
Subject: [PATCH 17/50] ia64/pv_ops: introduce basic facilities for binary patching.
Message-Id: <1204741146342-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/Kconfig                 |   72 +++++++++++++
 arch/ia64/kernel/Makefile         |    5 +
 arch/ia64/kernel/paravirt_alt.c   |  118 ++++++++++++++++++++++
 arch/ia64/kernel/paravirt_core.c  |  201 +++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/paravirt_entry.c |   99 ++++++++++++++++++
 arch/ia64/kernel/paravirt_nop.c   |   49 +++++++++
 arch/ia64/kernel/vmlinux.lds.S    |   35 +++++++
 include/asm-ia64/module.h         |    6 +
 include/asm-ia64/paravirt_alt.h   |   82 +++++++++++++++
 include/asm-ia64/paravirt_core.h  |   54 ++++++++++
 include/asm-ia64/paravirt_entry.h |   62 +++++++++++
 include/asm-ia64/paravirt_nop.h   |   46 +++++++++
 12 files changed, 829 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kernel/paravirt_alt.c
 create mode 100644 arch/ia64/kernel/paravirt_core.c
 create mode 100644 arch/ia64/kernel/paravirt_entry.c
 create mode 100644 arch/ia64/kernel/paravirt_nop.c
 create mode 100644 include/asm-ia64/paravirt_alt.h
 create mode 100644 include/asm-ia64/paravirt_core.h
 create mode 100644 include/asm-ia64/paravirt_entry.h
 create mode 100644 include/asm-ia64/paravirt_nop.h

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 8fa3faf..e7302ee 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -111,6 +111,78 @@ config AUDIT_ARCH
 	bool
 	default y
 
+menuconfig PARAVIRT_GUEST
+	bool "Paravirtualized guest support"
+	help
+	  Say Y here to get to see options related to running Linux under
+	  various hypervisors.  This option alone does not add any kernel code.
+
+	  If you say N, all options in this submenu will be skipped and disabled.
+
+if PARAVIRT_GUEST
+
+config PARAVIRT
+	bool
+	default y
+	help
+	  This changes the kernel so it can modify itself when it is run
+	  under a hypervisor, potentially improving performance significantly
+	  over full virtualization.  However, when run without a hypervisor
+	  the kernel is theoretically slower and slightly larger.
+
+config PARAVIRT_ALT
+	bool "paravirt_alt binary patching infrastructure"
+	depends on PARAVIRT
+	default y
+	help
+	  The binary patching infratstructure to replace some privileged
+	  instructions with hypervisor specific instrutions.
+	  There are several sensitive(i.e. non-virtualizable) instructions and
+	  performance critical privileged instructions which Xen
+	  paravirtualize as hyperprivops.
+	  For transparent paravirtualization (i.e. single binary should run
+	  on both baremetal and xen environment), xenLinux/IA64 needs
+	  something like "if (is_running_on_xen()) {} else {}" where
+	  is_running_on_xen() is determined at boot time.
+	  This configuration tries to eliminate the overheads for hyperprivops
+	  by annotating such instructions and replacing them with hyperprivops
+	  at boot time.
+
+config PARAVIRT_ENTRY
+	bool "paravirt entry"
+	depends on PARAVIRT
+	default y
+	help
+	  The entry point hooking infrastructure to change the execution path
+	  at the boot time.
+	  There are several paravirtualized paths in hand coded assembly code
+	  which isn't binary patched easily by the paravirt_alt infrastructure.
+	  E.g. ia64_switch_to, ia64_leave_syscall, ia64_leave_kernel and
+	  ia64_pal_call_static.
+	  For those hand written assembly code, change the execution path
+	  by hooking them and jumping to hand paravirtualized code.
+
+config PARAVIRT_NOP_B_PATCH
+	bool "paravirt branch if native"
+	depends on PARAVIRT
+	default y
+	help
+	  paravirt branch if native
+	  There are several paravirtualized paths in hand coded assembly code.
+	  For transparent paravirtualization, there are codes like
+	  GLOBAL_ENTRY(xen_xxx)
+	  'movl reg=running_on_xen;;'
+	  'ld4 reg=[reg];;'
+	  'cmp.e1 pred,p0=reg,r0'
+	  '(pred) br.cond.sptk.many <native_xxx>;;'
+	  To reduce overhead when running on bare metal, just
+	  "br.cond.sptk.many <native_xxx>" and replace it with 'nop.b 0'
+	  when running on xen.
+
+#source "arch/ia64/xen/Kconfig"
+
+endif
+
 choice
 	prompt "System type"
 	default IA64_GENERIC
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 9281bf6..185e0e2 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -36,6 +36,11 @@ obj-$(CONFIG_PCI_MSI)		+= msi_ia64.o
 mca_recovery-y			+= mca_drv.o mca_drv_asm.o
 obj-$(CONFIG_IA64_MC_ERR_INJECT)+= err_inject.o
 
+obj-$(CONFIG_PARAVIRT)		+= paravirt_core.o
+obj-$(CONFIG_PARAVIRT_ALT)	+= paravirt_alt.o
+obj-$(CONFIG_PARAVIRT_ENTRY)	+= paravirt_entry.o paravirtentry.o
+obj-$(CONFIG_PARAVIRT_NOP_B_PATCH) += paravirt_nop.o
+
 obj-$(CONFIG_IA64_ESI)		+= esi.o
 ifneq ($(CONFIG_IA64_ESI),)
 obj-y				+= esi_stub.o	# must be in kernel proper
diff --git a/arch/ia64/kernel/paravirt_alt.c b/arch/ia64/kernel/paravirt_alt.c
new file mode 100644
index 0000000..d0a34a7
--- /dev/null
+++ b/arch/ia64/kernel/paravirt_alt.c
@@ -0,0 +1,118 @@
+/******************************************************************************
+ * linux/arch/ia64/xen/paravirt_alt.c
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
+#include <asm/paravirt_core.h>
+
+extern const char nop_bundle[];
+extern const unsigned long nop_bundle_size;
+
+static void __init_or_module
+fill_nop(void *sbundle, void *ebundle)
+{
+	void *bundle = sbundle;
+	BUG_ON((((unsigned long)sbundle) % sizeof(bundle_t)) != 0);
+	BUG_ON((((unsigned long)ebundle) % sizeof(bundle_t)) != 0);
+
+	while (bundle < ebundle) {
+		memcpy(bundle, nop_bundle, nop_bundle_size);
+
+		bundle += nop_bundle_size;
+	}
+}
+
+void __init_or_module
+paravirt_alt_bundle_patch_apply(struct paravirt_alt_bundle_patch *start,
+				struct paravirt_alt_bundle_patch *end,
+				unsigned long(*patch)(void *sbundle,
+						      void *ebundle,
+						      unsigned long type))
+{
+	struct paravirt_alt_bundle_patch *p;
+
+	for (p = start; p < end; p++) {
+		unsigned long used;
+
+		used = (*patch)(p->sbundle, p->ebundle, p->type);
+		if (used = 0)
+			continue;
+
+		fill_nop(p->sbundle + used, p->ebundle);
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
+	extern const bundle_t nop_mfi_inst_bundle[];
+	unsigned long tag;
+	const cmp_inst_t nop_inst = paravirt_read_slot0(nop_mfi_inst_bundle);
+
+	for (tag = stag; tag < etag; tag = paravirt_get_next_tag(tag))
+		paravirt_write_inst(tag, nop_inst);
+}
+
+void __init_or_module
+paravirt_alt_inst_patch_apply(struct paravirt_alt_inst_patch *start,
+			      struct paravirt_alt_inst_patch *end,
+			      unsigned long (*patch)(unsigned long stag,
+						     unsigned long etag,
+						     unsigned long type))
+{
+	struct paravirt_alt_inst_patch *p;
+
+	for (p = start; p < end; p++) {
+		unsigned long tag;
+		bundle_t *sbundle;
+		bundle_t *ebundle;
+
+		tag = (*patch)(p->stag, p->etag, p->type);
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
diff --git a/arch/ia64/kernel/paravirt_core.c b/arch/ia64/kernel/paravirt_core.c
new file mode 100644
index 0000000..6b7c70f
--- /dev/null
+++ b/arch/ia64/kernel/paravirt_core.c
@@ -0,0 +1,201 @@
+/******************************************************************************
+ * linux/arch/ia64/xen/paravirt_core.c
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
+#include <asm/paravirt_core.h>
+
+/*
+ * flush_icache_range() can't be used here.
+ * we are here before cpu_init() which initializes
+ * ia64_i_cache_stride_shift. flush_icache_range() uses it.
+ */
+void __init_or_module
+paravirt_flush_i_cache_range(const void *instr, unsigned long size)
+{
+	unsigned long i;
+
+	for (i = 0; i < size; i += sizeof(bundle_t))
+		asm volatile ("fc.i %0":: "r"(instr + i): "memory");
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
+#if 0
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
+#endif
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
+cmp_inst_t __init_or_module
+paravirt_read_slot0(const bundle_t *bundle)
+{
+	cmp_inst_t inst;
+	inst.l = bundle->quad0.slot0;
+	return inst;
+}
+
+cmp_inst_t __init_or_module
+paravirt_read_slot1(const bundle_t *bundle)
+{
+	cmp_inst_t inst;
+	inst.l = bundle->quad0.slot1_p0 |
+		((unsigned long long)bundle->quad1.slot1_p1 << 18UL);
+	return inst;
+}
+
+cmp_inst_t __init_or_module
+paravirt_read_slot2(const bundle_t *bundle)
+{
+	cmp_inst_t inst;
+	inst.l = bundle->quad1.slot2;
+	return inst;
+}
+
+cmp_inst_t __init_or_module
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
+paravirt_write_slot0(bundle_t *bundle, cmp_inst_t inst)
+{
+	bundle->quad0.slot0 = inst.l;
+}
+
+void __init_or_module
+paravirt_write_slot1(bundle_t *bundle, cmp_inst_t inst)
+{
+	bundle->quad0.slot1_p0 = inst.l;
+	bundle->quad1.slot1_p1 = inst.l >> 18UL;
+}
+
+void __init_or_module
+paravirt_write_slot2(bundle_t *bundle, cmp_inst_t inst)
+{
+	bundle->quad1.slot2 = inst.l;
+}
+
+void __init_or_module
+paravirt_write_inst(unsigned long tag, cmp_inst_t inst)
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
+	}
+	paravirt_flush_i_cache_range(bundle, sizeof(*bundle));
+}
+
+/* for debug */
+void
+print_bundle(const bundle_t *bundle)
+{
+	const unsigned long *quad = (const unsigned long *)bundle;
+	cmp_inst_t slot0 = paravirt_read_slot0(bundle);
+	cmp_inst_t slot1 = paravirt_read_slot1(bundle);
+	cmp_inst_t slot2 = paravirt_read_slot2(bundle);
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
+/*
+ * Local variables:
+ * mode: C
+ * c-set-style: "linux"
+ * c-basic-offset: 8
+ * tab-width: 8
+ * indent-tabs-mode: t
+ * End:
+ */
diff --git a/arch/ia64/kernel/paravirt_entry.c b/arch/ia64/kernel/paravirt_entry.c
new file mode 100644
index 0000000..708287a
--- /dev/null
+++ b/arch/ia64/kernel/paravirt_entry.c
@@ -0,0 +1,99 @@
+/******************************************************************************
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
+#include <asm/paravirt_core.h>
+#include <asm/paravirt_entry.h>
+
+/* br.cond.sptk.many <target25>	B1 */
+typedef union inst_b1 {
+	cmp_inst_t inst;
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
+static void __init
+__paravirt_entry_apply(unsigned long tag, const void *target)
+{
+	bundle_t *bundle = paravirt_get_bundle(tag);
+	cmp_inst_t inst = paravirt_read_inst(tag);
+	unsigned long target25 = (unsigned long)target - (unsigned long)bundle;
+	inst_b1_t inst_b1;
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
+	paravirt_flush_i_cache_range(bundle, sizeof(*bundle));
+}
+
+static void __init
+paravirt_entry_apply(const struct paravirt_entry_patch *entry_patch,
+		     const struct paravirt_entry *entries,
+		     unsigned int nr_entries)
+{
+	unsigned int i;
+	for (i = 0; i < nr_entries; i++) {
+		if (entry_patch->type = entries[i].type) {
+			__paravirt_entry_apply(entry_patch->tag,
+					       entries[i].entry);
+			break;
+		}
+	}
+}
+
+void __init
+paravirt_entry_patch_apply(const struct paravirt_entry_patch *start,
+			   const struct paravirt_entry_patch *end,
+			   const struct paravirt_entry *entries,
+			   unsigned int nr_entries)
+{
+	const struct paravirt_entry_patch *p;
+	for (p = start; p < end; p++)
+		paravirt_entry_apply(p, entries, nr_entries);
+
+	ia64_sync_i();
+	ia64_srlz_i();
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
diff --git a/arch/ia64/kernel/paravirt_nop.c b/arch/ia64/kernel/paravirt_nop.c
new file mode 100644
index 0000000..ee5a204
--- /dev/null
+++ b/arch/ia64/kernel/paravirt_nop.c
@@ -0,0 +1,49 @@
+/******************************************************************************
+ * linux/arch/ia64/xen/paravirt_nop.c
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
+#include <asm/paravirt_core.h>
+#include <asm/paravirt_nop.h>
+
+void __init_or_module
+paravirt_nop_b_patch_apply(const struct paravirt_nop_patch *start,
+			   const struct paravirt_nop_patch *end)
+{
+	extern const bundle_t nop_b_inst_bundle;
+	const cmp_inst_t nop_b_inst = paravirt_read_slot0(&nop_b_inst_bundle);
+	const struct paravirt_nop_patch *p;
+
+	for (p = start; p < end; p++)
+		paravirt_write_inst(p->tag, nop_b_inst);
+
+	ia64_sync_i();
+	ia64_srlz_i();
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
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index 80622ac..0cbe0a1 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -163,6 +163,41 @@ SECTIONS
 	  __end___mckinley_e9_bundles = .;
 	}
 
+#if defined(CONFIG_PARAVIRT_ALT)
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
+#endif
+#if defined(CONFIG_PARAVIRT_NOP_B_PATCH)
+  . = ALIGN(16);
+  .paravirt_nop_b : AT(ADDR(.paravirt_nop_b) - LOAD_OFFSET)
+	{
+	  __start_paravirt_nop_b = .;
+	  *(.paravirt_nop_b)
+	  __stop_paravirt_nop_b = .;
+	}
+#endif
+#if defined(CONFIG_PARAVIRT_ENTRY)
+  . = ALIGN(16);
+  .paravirt_entry : AT(ADDR(.paravirt_entry) - LOAD_OFFSET)
+	{
+	  __start_paravirt_entry = .;
+	  *(.paravirt_entry)
+	  __stop_paravirt_entry = .;
+	}
+#endif
+
 #if defined(CONFIG_IA64_GENERIC)
   /* Machine Vector */
   . = ALIGN(16);
diff --git a/include/asm-ia64/module.h b/include/asm-ia64/module.h
index d2da61e..44f63ff 100644
--- a/include/asm-ia64/module.h
+++ b/include/asm-ia64/module.h
@@ -16,6 +16,12 @@ struct mod_arch_specific {
 	struct elf64_shdr *got;		/* global offset table */
 	struct elf64_shdr *opd;		/* official procedure descriptors */
 	struct elf64_shdr *unwind;	/* unwind-table section */
+#ifdef CONFIG_PARAVIRT_ALT
+	struct elf64_shdr *paravirt_bundles;
+					/* paravirt_alt_bundle_patch table */
+	struct elf64_shdr *paravirt_insts;
+					/* paravirt_alt_inst_patch table */
+#endif
 	unsigned long gp;		/* global-pointer for module */
 
 	void *core_unw_table;		/* core unwind-table cookie returned by unwinder */
diff --git a/include/asm-ia64/paravirt_alt.h b/include/asm-ia64/paravirt_alt.h
new file mode 100644
index 0000000..34c5473
--- /dev/null
+++ b/include/asm-ia64/paravirt_alt.h
@@ -0,0 +1,82 @@
+/******************************************************************************
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
+#ifndef __ASM_PARAVIRT_ALT_H
+#define __ASM_PARAVIRT_ALT_H
+
+#ifndef __ASSEMBLER__
+/* for binary patch */
+struct paravirt_alt_bundle_patch {
+	void		*sbundle;
+	void		*ebundle;
+	unsigned long	type;
+};
+
+/* label means the beginning of new bundle */
+#define paravirt_alt_bundle(instr, privop)				\
+	"\t1:\n"							\
+	"\t" instr "\n"							\
+	"\t2:\n"							\
+	"\t.section .paravirt_bundles, \"a\"\n"				\
+	"\t.previous\n"							\
+	"\t.xdata8 \".paravirt_bundles\", 1b, 2b, "			\
+	__stringify(privop) "\n"
+
+struct paravirt_alt_inst_patch {
+	unsigned long	stag;
+	unsigned long	etag;
+	unsigned long	type;
+};
+
+#define paravirt_alt_inst(instr, privop)				\
+	"\t[1:]\n"							\
+	"\t" instr "\n"							\
+	"\t[2:]\n"							\
+	"\t.section .paravirt_insts, \"a\"\n"				\
+	"\t.previous\n"							\
+	"\t.xdata8 \".paravirt_insts\", 1b, 2b, "			\
+	__stringify(privop) "\n"
+
+void
+paravirt_alt_bundle_patch_apply(struct paravirt_alt_bundle_patch *start,
+				struct paravirt_alt_bundle_patch *end,
+				unsigned long(*patch)(void *sbundle,
+						      void *ebundle,
+						      unsigned long type));
+
+void
+paravirt_alt_inst_patch_apply(struct paravirt_alt_inst_patch *start,
+			      struct paravirt_alt_inst_patch *end,
+			      unsigned long (*patch)(unsigned long stag,
+						     unsigned long etag,
+						     unsigned long type));
+#endif /* __ASSEMBLER__ */
+
+#endif /* __ASM_PARAVIRT_ALT_H */
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
diff --git a/include/asm-ia64/paravirt_core.h b/include/asm-ia64/paravirt_core.h
new file mode 100644
index 0000000..9979740
--- /dev/null
+++ b/include/asm-ia64/paravirt_core.h
@@ -0,0 +1,54 @@
+/******************************************************************************
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
+#ifndef __ASM_PARAVIRT_CORE_H
+#define __ASM_PARAVIRT_CORE_H
+
+#include <asm/kprobes.h>
+
+void paravirt_flush_i_cache_range(const void *instr, unsigned long size);
+
+bundle_t *paravirt_get_bundle(unsigned long tag);
+unsigned long paravirt_get_slot(unsigned long tag);
+unsigned long paravirt_get_next_tag(unsigned long tag);
+
+cmp_inst_t paravirt_read_slot0(const bundle_t *bundle);
+cmp_inst_t paravirt_read_slot1(const bundle_t *bundle);
+cmp_inst_t paravirt_read_slot2(const bundle_t *bundle);
+cmp_inst_t paravirt_read_inst(unsigned long tag);
+
+void paravirt_write_slot0(bundle_t *bundle, cmp_inst_t inst);
+void paravirt_write_slot1(bundle_t *bundle, cmp_inst_t inst);
+void paravirt_write_slot2(bundle_t *bundle, cmp_inst_t inst);
+void paravirt_write_inst(unsigned long tag, cmp_inst_t inst);
+
+void print_bundle(const bundle_t *bundle);
+
+#endif /* __ASM_PARAVIRT_CORE_H */
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
diff --git a/include/asm-ia64/paravirt_entry.h b/include/asm-ia64/paravirt_entry.h
new file mode 100644
index 0000000..857fd37
--- /dev/null
+++ b/include/asm-ia64/paravirt_entry.h
@@ -0,0 +1,62 @@
+/******************************************************************************
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
+#ifndef __ASM_PARAVIRT_ENTRY_H
+#define __ASM_PARAVIRT_ENTRY_H
+
+#ifdef __ASSEMBLY__
+
+#define BR_COND_SPTK_MANY(target, type)		\
+	[1:] ;					\
+	br.cond.sptk.many target;; ;		\
+	.section .paravirt_entry, "a" ;		\
+	.previous ;				\
+	.xdata8 ".paravirt_entry", 1b, type
+
+#else /* __ASSEMBLY__ */
+
+struct paravirt_entry_patch {
+	unsigned long	tag;
+	unsigned long	type;
+};
+
+struct paravirt_entry {
+	void		*entry;
+	unsigned long	type;
+};
+
+void
+paravirt_entry_patch_apply(const struct paravirt_entry_patch *start,
+			   const struct paravirt_entry_patch *end,
+			   const struct paravirt_entry *entries,
+			   unsigned int nr_entries);
+
+#endif /* __ASSEMBLY__ */
+
+#endif /* __ASM_PARAVIRT_ENTRY_H */
+/*
+ * Local variables:
+ * mode: C
+ * c-set-style: "linux"
+ * c-basic-offset: 8
+ * tab-width: 8
+ * indent-tabs-mode: t
+ * End:
+ */
diff --git a/include/asm-ia64/paravirt_nop.h b/include/asm-ia64/paravirt_nop.h
new file mode 100644
index 0000000..2b05430
--- /dev/null
+++ b/include/asm-ia64/paravirt_nop.h
@@ -0,0 +1,46 @@
+/******************************************************************************
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
+#ifndef __ASM_PARAVIRT_OPS_H
+#define __ASM_PARAVIRT_OPS_H
+
+#ifndef __ASSEMBLY__
+
+struct paravirt_nop_patch {
+	unsigned long	tag;
+};
+
+void
+paravirt_nop_b_patch_apply(const struct paravirt_nop_patch *start,
+			   const struct paravirt_nop_patch *end);
+
+#endif /* !__ASSEMBLEY__ */
+
+#endif /* __ASM_PARAVIRT_OPS_H */
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
-- 
1.5.3

