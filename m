From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:10:33 +0000
Subject: [PATCH 14/28] ia64/xen: ia64 domU part of xencomm.
Message-Id: <12036570473058-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

import ia64 specific part of xencomm which converts hypercall argument in
virtual address into pseudo physical address (guest physical address).

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/xcom_asm.S          |   27 +++
 arch/ia64/xen/xcom_hcall.c        |  458 +++++++++++++++++++++++++++++++++++++
 arch/ia64/xen/xencomm.c           |  108 +++++++++
 include/asm-ia64/xen/xcom_hcall.h |   55 +++++
 include/asm-ia64/xen/xencomm.h    |   33 +++
 5 files changed, 681 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/xen/xcom_asm.S
 create mode 100644 arch/ia64/xen/xcom_hcall.c
 create mode 100644 arch/ia64/xen/xencomm.c
 create mode 100644 include/asm-ia64/xen/xcom_hcall.h
 create mode 100644 include/asm-ia64/xen/xencomm.h

diff --git a/arch/ia64/xen/xcom_asm.S b/arch/ia64/xen/xcom_asm.S
new file mode 100644
index 0000000..8747908
--- /dev/null
+++ b/arch/ia64/xen/xcom_asm.S
@@ -0,0 +1,27 @@
+/*
+ * xencomm suspend support
+ * Support routines for Xen
+ *
+ * Copyright (C) 2005 Dan Magenheimer <dan.magenheimer@hp.com>
+ */
+#include <asm/asmmacro.h>
+#include <xen/interface/xen.h>
+
+/*
+ * Stub for suspend.
+ * Just force the stacked registers to be written in memory.
+ */
+GLOBAL_ENTRY(xencomm_arch_hypercall_suspend)
+	;;
+	alloc r20=ar.pfs,0,0,6,0
+	mov r2=__HYPERVISOR_sched_op
+	;;
+	/* We don't want to deal with RSE.  */
+	flushrs
+	mov r33=r32
+	mov r32=2 // SCHEDOP_shutdown
+	;;
+	break 0x1000
+	;;
+	br.ret.sptk.many b0
+END(xencomm_arch_hypercall_suspend)
diff --git a/arch/ia64/xen/xcom_hcall.c b/arch/ia64/xen/xcom_hcall.c
new file mode 100644
index 0000000..8cd9cdc
--- /dev/null
+++ b/arch/ia64/xen/xcom_hcall.c
@@ -0,0 +1,458 @@
+/*
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
+ * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ *
+ *          Tristan Gingold <tristan.gingold@bull.net>
+ *
+ *          Copyright (c) 2007
+ *          Isaku Yamahata <yamahata at valinux co jp>
+ *                          VA Linux Systems Japan K.K.
+ *          consolidate mini and inline version.
+ */
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/gfp.h>
+#include <linux/module.h>
+#include <xen/interface/xen.h>
+#include <xen/interface/memory.h>
+#include <xen/interface/xencomm.h>
+#include <xen/interface/version.h>
+#include <xen/interface/sched.h>
+#include <xen/interface/event_channel.h>
+#include <xen/interface/physdev.h>
+#include <xen/interface/grant_table.h>
+#include <xen/interface/callback.h>
+#include <xen/interface/vcpu.h>
+#include <asm/xen/hypervisor.h>
+#include <asm/page.h>
+#include <asm/uaccess.h>
+#include <asm/xen/xencomm.h>
+
+/* Xencomm notes:
+ * This file defines hypercalls to be used by xencomm.  The hypercalls simply
+ * create inlines or mini descriptors for pointers and then call the raw arch
+ * hypercall xencomm_arch_hypercall_XXX
+ *
+ * If the arch wants to directly use these hypercalls, simply define macros
+ * in asm/xen/hypercall.h, eg:
+ *  #define HYPERVISOR_sched_op xencomm_hypercall_sched_op
+ *
+ * The arch may also define HYPERVISOR_xxx as a function and do more operations
+ * before/after doing the hypercall.
+ *
+ * Note: because only inline or mini descriptors are created these functions
+ * must only be called with in kernel memory parameters.
+ */
+
+int
+xencomm_hypercall_console_io(int cmd, int count, char *str)
+{
+	return xencomm_arch_hypercall_console_io
+		(cmd, count, xencomm_map_no_alloc(str, count));
+}
+EXPORT_SYMBOL_GPL(xencomm_hypercall_console_io);
+
+int
+xencomm_hypercall_event_channel_op(int cmd, void *op)
+{
+	struct xencomm_handle *desc;
+	desc = xencomm_map_no_alloc(op, sizeof(struct evtchn_op));
+	if (desc = NULL)
+		return -EINVAL;
+
+	return xencomm_arch_hypercall_event_channel_op(cmd, desc);
+}
+EXPORT_SYMBOL_GPL(xencomm_hypercall_event_channel_op);
+
+int
+xencomm_hypercall_xen_version(int cmd, void *arg)
+{
+	struct xencomm_handle *desc;
+	unsigned int argsize;
+
+	switch (cmd) {
+	case XENVER_version:
+		/* do not actually pass an argument */
+		return xencomm_arch_hypercall_xen_version(cmd, 0);
+	case XENVER_extraversion:
+		argsize = sizeof(struct xen_extraversion);
+		break;
+	case XENVER_compile_info:
+		argsize = sizeof(struct xen_compile_info);
+		break;
+	case XENVER_capabilities:
+		argsize = sizeof(struct xen_capabilities_info);
+		break;
+	case XENVER_changeset:
+		argsize = sizeof(struct xen_changeset_info);
+		break;
+	case XENVER_platform_parameters:
+		argsize = sizeof(struct xen_platform_parameters);
+		break;
+	case XENVER_get_features:
+		argsize = (arg = NULL) ? 0 : sizeof(struct xen_feature_info);
+		break;
+
+	default:
+		printk(KERN_DEBUG
+		       "%s: unknown version op %d\n", __func__, cmd);
+		return -ENOSYS;
+	}
+
+	desc = xencomm_map_no_alloc(arg, argsize);
+	if (desc = NULL)
+		return -EINVAL;
+
+	return xencomm_arch_hypercall_xen_version(cmd, desc);
+}
+EXPORT_SYMBOL_GPL(xencomm_hypercall_xen_version);
+
+int
+xencomm_hypercall_physdev_op(int cmd, void *op)
+{
+	unsigned int argsize;
+
+	switch (cmd) {
+	case PHYSDEVOP_apic_read:
+	case PHYSDEVOP_apic_write:
+		argsize = sizeof(struct physdev_apic);
+		break;
+	case PHYSDEVOP_alloc_irq_vector:
+	case PHYSDEVOP_free_irq_vector:
+		argsize = sizeof(struct physdev_irq);
+		break;
+	case PHYSDEVOP_irq_status_query:
+		argsize = sizeof(struct physdev_irq_status_query);
+		break;
+
+	default:
+		printk(KERN_DEBUG
+		       "%s: unknown physdev op %d\n", __func__, cmd);
+		return -ENOSYS;
+	}
+
+	return xencomm_arch_hypercall_physdev_op
+		(cmd, xencomm_map_no_alloc(op, argsize));
+}
+
+static int
+xencommize_grant_table_op(struct xencomm_mini **xc_area,
+			  unsigned int cmd, void *op, unsigned int count,
+			  struct xencomm_handle **desc)
+{
+	struct xencomm_handle *desc1;
+	unsigned int argsize;
+
+	switch (cmd) {
+	case GNTTABOP_map_grant_ref:
+		argsize = sizeof(struct gnttab_map_grant_ref);
+		break;
+	case GNTTABOP_unmap_grant_ref:
+		argsize = sizeof(struct gnttab_unmap_grant_ref);
+		break;
+	case GNTTABOP_setup_table:
+	{
+		struct gnttab_setup_table *setup = op;
+
+		argsize = sizeof(*setup);
+
+		if (count != 1)
+			return -EINVAL;
+		desc1 = __xencomm_map_no_alloc
+			(xen_guest_handle(setup->frame_list),
+			 setup->nr_frames *
+			 sizeof(*xen_guest_handle(setup->frame_list)),
+			 *xc_area);
+		if (desc1 = NULL)
+			return -EINVAL;
+		(*xc_area)++;
+		set_xen_guest_handle(setup->frame_list, (void *)desc1);
+		break;
+	}
+	case GNTTABOP_dump_table:
+		argsize = sizeof(struct gnttab_dump_table);
+		break;
+	case GNTTABOP_transfer:
+		argsize = sizeof(struct gnttab_transfer);
+		break;
+	case GNTTABOP_copy:
+		argsize = sizeof(struct gnttab_copy);
+		break;
+	case GNTTABOP_query_size:
+		argsize = sizeof(struct gnttab_query_size);
+		break;
+	default:
+		printk(KERN_DEBUG "%s: unknown hypercall grant table op %d\n",
+		       __func__, cmd);
+		BUG();
+	}
+
+	*desc = __xencomm_map_no_alloc(op, count * argsize, *xc_area);
+	if (*desc = NULL)
+		return -EINVAL;
+	(*xc_area)++;
+
+	return 0;
+}
+
+int
+xencomm_hypercall_grant_table_op(unsigned int cmd, void *op,
+				 unsigned int count)
+{
+	int rc;
+	struct xencomm_handle *desc;
+	XENCOMM_MINI_ALIGNED(xc_area, 2);
+
+	rc = xencommize_grant_table_op(&xc_area, cmd, op, count, &desc);
+	if (rc)
+		return rc;
+
+	return xencomm_arch_hypercall_grant_table_op(cmd, desc, count);
+}
+EXPORT_SYMBOL_GPL(xencomm_hypercall_grant_table_op);
+
+int
+xencomm_hypercall_sched_op(int cmd, void *arg)
+{
+	struct xencomm_handle *desc;
+	unsigned int argsize;
+
+	switch (cmd) {
+	case SCHEDOP_yield:
+	case SCHEDOP_block:
+		argsize = 0;
+		break;
+	case SCHEDOP_shutdown:
+		argsize = sizeof(struct sched_shutdown);
+		break;
+	case SCHEDOP_poll:
+	{
+		struct sched_poll *poll = arg;
+		struct xencomm_handle *ports;
+
+		argsize = sizeof(struct sched_poll);
+		ports = xencomm_map_no_alloc(xen_guest_handle(poll->ports),
+				     sizeof(*xen_guest_handle(poll->ports)));
+
+		set_xen_guest_handle(poll->ports, (void *)ports);
+		break;
+	}
+	default:
+		printk(KERN_DEBUG "%s: unknown sched op %d\n", __func__, cmd);
+		return -ENOSYS;
+	}
+
+	desc = xencomm_map_no_alloc(arg, argsize);
+	if (desc = NULL)
+		return -EINVAL;
+
+	return xencomm_arch_hypercall_sched_op(cmd, desc);
+}
+EXPORT_SYMBOL_GPL(xencomm_hypercall_sched_op);
+
+int
+xencomm_hypercall_multicall(void *call_list, int nr_calls)
+{
+	int rc;
+	int i;
+	struct multicall_entry *mce;
+	struct xencomm_handle *desc;
+	XENCOMM_MINI_ALIGNED(xc_area, nr_calls * 2);
+
+	for (i = 0; i < nr_calls; i++) {
+		mce = (struct multicall_entry *)call_list + i;
+
+		switch (mce->op) {
+		case __HYPERVISOR_update_va_mapping:
+		case __HYPERVISOR_mmu_update:
+			/* No-op on ia64.  */
+			break;
+		case __HYPERVISOR_grant_table_op:
+			rc = xencommize_grant_table_op
+				(&xc_area,
+				 mce->args[0], (void *)mce->args[1],
+				 mce->args[2], &desc);
+			if (rc)
+				return rc;
+			mce->args[1] = (unsigned long)desc;
+			break;
+		case __HYPERVISOR_memory_op:
+		default:
+			printk(KERN_DEBUG
+			       "%s: unhandled multicall op entry op %lu\n",
+			       __func__, mce->op);
+			return -ENOSYS;
+		}
+	}
+
+	desc = xencomm_map_no_alloc(call_list,
+				    nr_calls * sizeof(struct multicall_entry));
+	if (desc = NULL)
+		return -EINVAL;
+
+	return xencomm_arch_hypercall_multicall(desc, nr_calls);
+}
+EXPORT_SYMBOL_GPL(xencomm_hypercall_multicall);
+
+int
+xencomm_hypercall_callback_op(int cmd, void *arg)
+{
+	unsigned int argsize;
+	switch (cmd) {
+	case CALLBACKOP_register:
+		argsize = sizeof(struct callback_register);
+		break;
+	case CALLBACKOP_unregister:
+		argsize = sizeof(struct callback_unregister);
+		break;
+	default:
+		printk(KERN_DEBUG
+		       "%s: unknown callback op %d\n", __func__, cmd);
+		return -ENOSYS;
+	}
+
+	return xencomm_arch_hypercall_callback_op
+		(cmd, xencomm_map_no_alloc(arg, argsize));
+}
+
+static int
+xencommize_memory_reservation(struct xencomm_mini *xc_area,
+			      struct xen_memory_reservation *mop)
+{
+	struct xencomm_handle *desc;
+
+	desc = __xencomm_map_no_alloc(xen_guest_handle(mop->extent_start),
+			mop->nr_extents *
+			sizeof(*xen_guest_handle(mop->extent_start)),
+			xc_area);
+	if (desc = NULL)
+		return -EINVAL;
+
+	set_xen_guest_handle(mop->extent_start, (void *)desc);
+	return 0;
+}
+
+int
+xencomm_hypercall_memory_op(unsigned int cmd, void *arg)
+{
+	XEN_GUEST_HANDLE(xen_pfn_t) extent_start_va[2] = {{NULL}, {NULL}};
+	struct xen_memory_reservation *xmr = NULL;
+	int rc;
+	struct xencomm_handle *desc;
+	unsigned int argsize;
+	XENCOMM_MINI_ALIGNED(xc_area, 2);
+
+	switch (cmd) {
+	case XENMEM_increase_reservation:
+	case XENMEM_decrease_reservation:
+	case XENMEM_populate_physmap:
+		xmr = (struct xen_memory_reservation *)arg;
+		set_xen_guest_handle(extent_start_va[0],
+				     xen_guest_handle(xmr->extent_start));
+
+		argsize = sizeof(*xmr);
+		rc = xencommize_memory_reservation(xc_area, xmr);
+		if (rc)
+			return rc;
+		xc_area++;
+		break;
+
+	case XENMEM_maximum_ram_page:
+		argsize = 0;
+		break;
+
+	case XENMEM_add_to_physmap:
+		argsize = sizeof(struct xen_add_to_physmap);
+		break;
+
+	default:
+		printk(KERN_DEBUG "%s: unknown memory op %d\n", __func__, cmd);
+		return -ENOSYS;
+	}
+
+	desc = xencomm_map_no_alloc(arg, argsize);
+	if (desc = NULL)
+		return -EINVAL;
+
+	rc = xencomm_arch_hypercall_memory_op(cmd, desc);
+
+	switch (cmd) {
+	case XENMEM_increase_reservation:
+	case XENMEM_decrease_reservation:
+	case XENMEM_populate_physmap:
+		set_xen_guest_handle(xmr->extent_start,
+				     xen_guest_handle(extent_start_va[0]));
+		break;
+	}
+
+	return rc;
+}
+EXPORT_SYMBOL_GPL(xencomm_hypercall_memory_op);
+
+int
+xencomm_hypercall_suspend(unsigned long srec)
+{
+	struct sched_shutdown arg;
+
+	arg.reason = SHUTDOWN_suspend;
+
+	return xencomm_arch_hypercall_suspend(
+		xencomm_map_no_alloc(&arg, sizeof(arg)));
+}
+
+long
+xencomm_hypercall_vcpu_op(int cmd, int cpu, void *arg)
+{
+	unsigned int argsize;
+	switch (cmd) {
+	case VCPUOP_register_runstate_memory_area: {
+		struct vcpu_register_runstate_memory_area *area +			(struct vcpu_register_runstate_memory_area *)arg;
+		argsize = sizeof(*arg);
+		set_xen_guest_handle(area->addr.h,
+		     (void *)xencomm_map_no_alloc(area->addr.v,
+						  sizeof(area->addr.v)));
+		break;
+	}
+
+	default:
+		printk(KERN_DEBUG "%s: unknown vcpu op %d\n", __func__, cmd);
+		return -ENOSYS;
+	}
+
+	return xencomm_arch_hypercall_vcpu_op(cmd, cpu,
+					xencomm_map_no_alloc(arg, argsize));
+}
+
+long
+xencomm_hypercall_opt_feature(void *arg)
+{
+	return xencomm_arch_hypercall_opt_feature(
+		xencomm_map_no_alloc(arg,
+				     sizeof(struct xen_ia64_opt_feature)));
+}
+
+int
+xencomm_hypercall_fpswa_revision(unsigned int *revision)
+{
+	struct xencomm_handle *desc;
+
+	desc = xencomm_map_no_alloc(revision, sizeof(*revision));
+	if (desc = NULL)
+		return -EINVAL;
+
+	return xencomm_arch_hypercall_fpswa_revision(desc);
+}
+EXPORT_SYMBOL_GPL(xencomm_hypercall_fpswa_revision);
diff --git a/arch/ia64/xen/xencomm.c b/arch/ia64/xen/xencomm.c
new file mode 100644
index 0000000..6e9da66
--- /dev/null
+++ b/arch/ia64/xen/xencomm.c
@@ -0,0 +1,108 @@
+/*
+ * Copyright (C) 2006 Hollis Blanchard <hollisb@us.ibm.com>, IBM Corporation
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+ */
+
+#include <linux/gfp.h>
+#include <linux/mm.h>
+#include <xen/interface/xen.h>
+#include <asm/page.h>
+
+#ifdef HAVE_XEN_PLATFORM_COMPAT_H
+#include <xen/platform-compat.h>
+#endif
+
+#include <asm/xen/xencomm.h>
+
+static unsigned long kernel_start_pa;
+
+void
+xencomm_initialize(void)
+{
+	kernel_start_pa = KERNEL_START - ia64_tpa(KERNEL_START);
+}
+
+/* Translate virtual address to physical address.  */
+unsigned long
+xencomm_vtop(unsigned long vaddr)
+{
+#ifndef CONFIG_VMX_GUEST
+	struct page *page;
+	struct vm_area_struct *vma;
+#endif
+
+	if (vaddr = 0)
+		return 0;
+
+#ifdef __ia64__
+	if (REGION_NUMBER(vaddr) = 5) {
+		pgd_t *pgd;
+		pud_t *pud;
+		pmd_t *pmd;
+		pte_t *ptep;
+
+		/* On ia64, TASK_SIZE refers to current.  It is not initialized
+		   during boot.
+		   Furthermore the kernel is relocatable and __pa() doesn't
+		   work on  addresses.  */
+		if (vaddr >= KERNEL_START
+		    && vaddr < (KERNEL_START + KERNEL_TR_PAGE_SIZE))
+			return vaddr - kernel_start_pa;
+
+		/* In kernel area -- virtually mapped.  */
+		pgd = pgd_offset_k(vaddr);
+		if (pgd_none(*pgd) || pgd_bad(*pgd))
+			return ~0UL;
+
+		pud = pud_offset(pgd, vaddr);
+		if (pud_none(*pud) || pud_bad(*pud))
+			return ~0UL;
+
+		pmd = pmd_offset(pud, vaddr);
+		if (pmd_none(*pmd) || pmd_bad(*pmd))
+			return ~0UL;
+
+		ptep = pte_offset_kernel(pmd, vaddr);
+		if (!ptep)
+			return ~0UL;
+
+		return (pte_val(*ptep) & _PFN_MASK) | (vaddr & ~PAGE_MASK);
+	}
+#endif
+
+	if (vaddr > TASK_SIZE) {
+		/* kernel address */
+		return __pa(vaddr);
+	}
+
+
+#ifdef CONFIG_VMX_GUEST
+	/* No privcmd within vmx guest.  */
+	return ~0UL;
+#else
+	/* XXX double-check (lack of) locking */
+	vma = find_extend_vma(current->mm, vaddr);
+	if (!vma)
+		return ~0UL;
+
+	/* We assume the page is modified.  */
+	page = follow_page(vma, vaddr, FOLL_WRITE | FOLL_TOUCH);
+	if (!page)
+		return ~0UL;
+
+	return (page_to_pfn(page) << PAGE_SHIFT) | (vaddr & ~PAGE_MASK);
+#endif
+}
diff --git a/include/asm-ia64/xen/xcom_hcall.h b/include/asm-ia64/xen/xcom_hcall.h
new file mode 100644
index 0000000..adf4ba2
--- /dev/null
+++ b/include/asm-ia64/xen/xcom_hcall.h
@@ -0,0 +1,55 @@
+/*
+ * Copyright (C) 2006 Tristan Gingold <tristan.gingold@bull.net>, Bull SAS
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+ */
+
+#ifndef _LINUX_XENCOMM_HCALL_H_
+#define _LINUX_XENCOMM_HCALL_H_
+
+/* These function creates inline or mini descriptor for the parameters and
+   calls the corresponding xencomm_arch_hypercall_X.
+   Architectures should defines HYPERVISOR_xxx as xencomm_hypercall_xxx unless
+   they want to use their own wrapper.  */
+extern int xencomm_hypercall_console_io(int cmd, int count, char *str);
+
+extern int xencomm_hypercall_event_channel_op(int cmd, void *op);
+
+extern int xencomm_hypercall_xen_version(int cmd, void *arg);
+
+extern int xencomm_hypercall_physdev_op(int cmd, void *op);
+
+extern int xencomm_hypercall_grant_table_op(unsigned int cmd, void *op,
+					    unsigned int count);
+
+extern int xencomm_hypercall_sched_op(int cmd, void *arg);
+
+extern int xencomm_hypercall_multicall(void *call_list, int nr_calls);
+
+extern int xencomm_hypercall_callback_op(int cmd, void *arg);
+
+extern int xencomm_hypercall_memory_op(unsigned int cmd, void *arg);
+
+extern unsigned long xencomm_hypercall_hvm_op(int cmd, void *arg);
+
+extern int xencomm_hypercall_suspend(unsigned long srec);
+
+extern long xencomm_hypercall_vcpu_op(int cmd, int cpu, void *arg);
+
+extern long xencomm_hypercall_opt_feature(void *arg);
+
+extern int xencomm_hypercall_kexec_op(int cmd, void *arg);
+
+#endif /* _LINUX_XENCOMM_HCALL_H_ */
diff --git a/include/asm-ia64/xen/xencomm.h b/include/asm-ia64/xen/xencomm.h
new file mode 100644
index 0000000..cc27a5f
--- /dev/null
+++ b/include/asm-ia64/xen/xencomm.h
@@ -0,0 +1,33 @@
+/*
+ * Copyright (C) 2006 Hollis Blanchard <hollisb@us.ibm.com>, IBM Corporation
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+ */
+
+#ifndef _ASM_IA64_XENCOMM_H_
+#define _ASM_IA64_XENCOMM_H_
+
+#define is_kernel_addr(x)					\
+	((PAGE_OFFSET <= (x) &&					\
+	  (x) < (PAGE_OFFSET + (1UL << IA64_MAX_PHYS_BITS))) ||	\
+	 (KERNEL_START <= (x) &&				\
+	  (x) < KERNEL_START + KERNEL_TR_PAGE_SIZE))
+
+/* Must be called before any hypercall.  */
+extern void xencomm_initialize(void);
+
+#include <xen/xencomm.h>
+
+#endif /* _ASM_IA64_XENCOMM_H_ */
-- 
1.5.3

