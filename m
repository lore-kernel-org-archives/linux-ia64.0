From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:10:35 +0000
Subject: [PATCH 16/28] ia64/xen: basic helper routines for xen/ia64.
Message-Id: <12036570471174-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/hypervisor.c        |  228 +++++++++++++++++++++++++++++++++++++
 include/asm-ia64/xen/hypervisor.h |  194 +++++++++++++++++++++++++++++++
 2 files changed, 422 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/xen/hypervisor.c

diff --git a/arch/ia64/xen/hypervisor.c b/arch/ia64/xen/hypervisor.c
new file mode 100644
index 0000000..4e5791d
--- /dev/null
+++ b/arch/ia64/xen/hypervisor.c
@@ -0,0 +1,228 @@
+/******************************************************************************
+ * include/asm-ia64/shadow.h
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
+#include <linux/spinlock.h>
+#include <linux/bootmem.h>
+#include <linux/module.h>
+#include <linux/vmalloc.h>
+#include <linux/efi.h>
+#include <asm/page.h>
+#include <asm/pgalloc.h>
+#include <asm/meminit.h>
+#include <asm/xen/hypervisor.h>
+#include <asm/xen/hypercall.h>
+#include <xen/interface/memory.h>
+
+struct shared_info *HYPERVISOR_shared_info __read_mostly +	(struct shared_info *)XSI_BASE;
+EXPORT_SYMBOL(HYPERVISOR_shared_info);
+
+DEFINE_PER_CPU(struct vcpu_info *, xen_vcpu);
+#ifdef notyet
+DEFINE_PER_CPU(struct vcpu_info, xen_vcpu_info);
+#endif
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
+#ifdef notyet
+static int have_vcpu_info_placement;
+#endif
+
+static void __init xen_vcpu_setup(int cpu)
+{
+/* on Xen/IA64 VCPUOP_register_vcpu_info isn't supported */
+#ifdef notyet
+	struct vcpu_register_vcpu_info info;
+	int err;
+	struct vcpu_info *vcpup;
+#endif
+
+	per_cpu(xen_vcpu, cpu) = &HYPERVISOR_shared_info->vcpu_info[cpu];
+
+#ifdef notyet
+	if (!have_vcpu_info_placement)
+		return;		/* already tested, not available */
+
+	vcpup = &per_cpu(xen_vcpu_info, cpu);
+
+	info.mfn = virt_to_mfn(vcpup);
+	info.offset = offset_in_page(vcpup);
+
+	printk(KERN_DEBUG
+	       "trying to map vcpu_info %d at %p, mfn %llx, offset %d\n",
+	       cpu, vcpup, info.mfn, info.offset);
+
+	/* Check to see if the hypervisor will put the vcpu_info
+	   structure where we want it, which allows direct access via
+	   a percpu-variable. */
+	err = HYPERVISOR_vcpu_op(VCPUOP_register_vcpu_info, cpu, &info);
+
+	if (err) {
+		printk(KERN_DEBUG "register_vcpu_info failed: err=%d\n", err);
+		have_vcpu_info_placement = 0;
+	} else {
+		/* This cpu is using the registered vcpu info, even if
+		   later ones fail to. */
+		per_cpu(xen_vcpu, cpu) = vcpup;
+
+		printk(KERN_DEBUG "cpu %d using vcpu_info at %p\n",
+		       cpu, vcpup);
+	}
+#endif
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
+void __init
+xen_setup(char **cmdline_p)
+{
+	extern void dig_setup(char **cmdline_p);
+
+	if (ia64_platform_is("xen"))
+		dig_setup(cmdline_p);
+}
+
+void __cpuinit
+xen_cpu_init(void)
+{
+	extern void xen_smp_intr_init(void);
+	xen_smp_intr_init();
+}
+
+/****************************************************************************
+ * grant table hack
+ * cmd: GNTTABOP_xxx
+ */
+
+#include <linux/mm.h>
+#include <xen/interface/xen.h>
+#include <xen/grant_table.h>
+
+int arch_gnttab_map_shared(unsigned long *frames, unsigned long nr_gframes,
+			   unsigned long max_nr_gframes,
+			   struct grant_entry **__shared)
+{
+	*__shared = __va(frames[0] << PAGE_SHIFT);
+	return 0;
+}
+
+void arch_gnttab_unmap_shared(struct grant_entry *shared,
+			      unsigned long nr_gframes)
+{
+	/* nothing */
+}
+
+static void
+gnttab_map_grant_ref_pre(struct gnttab_map_grant_ref *uop)
+{
+	uint32_t flags;
+
+	flags = uop->flags;
+
+	if (flags & GNTMAP_host_map) {
+		if (flags & GNTMAP_application_map) {
+			printk(KERN_DEBUG
+			       "GNTMAP_application_map is not supported yet: "
+			       "flags 0x%x\n", flags);
+			BUG();
+		}
+		if (flags & GNTMAP_contains_pte) {
+			printk(KERN_DEBUG
+			       "GNTMAP_contains_pte is not supported yet: "
+			       "flags 0x%x\n", flags);
+			BUG();
+		}
+	} else if (flags & GNTMAP_device_map) {
+		printk("GNTMAP_device_map is not supported yet 0x%x\n", flags);
+		BUG();	/* XXX not yet. actually this flag is not used. */
+	} else {
+		BUG();
+	}
+}
+
+int
+HYPERVISOR_grant_table_op(unsigned int cmd, void *uop, unsigned int count)
+{
+	if (cmd = GNTTABOP_map_grant_ref) {
+		unsigned int i;
+		for (i = 0; i < count; i++) {
+			gnttab_map_grant_ref_pre(
+				(struct gnttab_map_grant_ref *)uop + i);
+		}
+	}
+	return xencomm_hypercall_grant_table_op(cmd, uop, count);
+}
+EXPORT_SYMBOL(HYPERVISOR_grant_table_op);
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
+
+/**************************************************************************
+ * suspend/resume
+ */
+void
+xen_post_suspend(int suspend_cancelled)
+{
+	if (suspend_cancelled)
+		return;
+
+	xen_ia64_enable_opt_feature();
+	/* add more if necessary */
+}
diff --git a/include/asm-ia64/xen/hypervisor.h b/include/asm-ia64/xen/hypervisor.h
index 4ee50c9..c8ae8e8 100644
--- a/include/asm-ia64/xen/hypervisor.h
+++ b/include/asm-ia64/xen/hypervisor.h
@@ -42,9 +42,203 @@ extern const int running_on_xen;
 #  define is_running_on_xen()			(1)
 # else /* CONFIG_VMX_GUEST */
 #  define is_running_on_xen()			(0)
+#  define HYPERVISOR_ioremap(offset, size)	(offset)
 # endif /* CONFIG_VMX_GUEST */
 #endif /* CONFIG_XEN */
 
+#if defined(CONFIG_XEN) || defined(CONFIG_VMX_GUEST)
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/version.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <xen/interface/xen.h>
+#include <xen/interface/version.h>	/* to compile feature.c */
+#include <xen/interface/event_channel.h>
+#include <xen/interface/physdev.h>
+#include <xen/interface/sched.h>
+#include <asm/ptrace.h>
+#include <asm/page.h>
+#include <asm/percpu.h>
+#ifdef CONFIG_XEN
+#include <asm/xen/hypercall.h>
+#endif
+
+extern struct shared_info *HYPERVISOR_shared_info;
+extern struct start_info *xen_start_info;
+
+DECLARE_PER_CPU(struct vcpu_info *, xen_vcpu);
+void __init xen_setup_vcpu_info_placement(void);
+void force_evtchn_callback(void);
+
+struct vm_struct *xen_alloc_vm_area(unsigned long size);
+void xen_free_vm_area(struct vm_struct *area);
+
+/* Turn jiffies into Xen system time. XXX Implement me. */
+#define jiffies_to_st(j)	0
+
+static inline int
+HYPERVISOR_yield(
+	void)
+{
+	int rc = HYPERVISOR_sched_op(SCHEDOP_yield, NULL);
+
+	return rc;
+}
+
+static inline int
+HYPERVISOR_block(
+	void)
+{
+	int rc = HYPERVISOR_sched_op(SCHEDOP_block, NULL);
+
+	return rc;
+}
+
+static inline int
+HYPERVISOR_shutdown(
+	unsigned int reason)
+{
+	struct sched_shutdown sched_shutdown = {
+		.reason = reason
+	};
+
+	int rc = HYPERVISOR_sched_op(SCHEDOP_shutdown, &sched_shutdown);
+
+	return rc;
+}
+
+static inline int
+HYPERVISOR_poll(
+	evtchn_port_t *ports, unsigned int nr_ports, u64 timeout)
+{
+	struct sched_poll sched_poll = {
+		.nr_ports = nr_ports,
+		.timeout = jiffies_to_st(timeout)
+	};
+
+	int rc;
+
+	set_xen_guest_handle(sched_poll.ports, ports);
+	rc = HYPERVISOR_sched_op(SCHEDOP_poll, &sched_poll);
+
+	return rc;
+}
+
+#ifndef CONFIG_VMX_GUEST
+/* for drivers/xen/privcmd/privcmd.c */
+#define machine_to_phys_mapping 0
+struct vm_area_struct;
+int direct_remap_pfn_range(struct vm_area_struct *vma,
+			   unsigned long address,
+			   unsigned long mfn,
+			   unsigned long size,
+			   pgprot_t prot,
+			   domid_t  domid);
+struct file;
+int privcmd_enforce_singleshot_mapping(struct vm_area_struct *vma);
+int privcmd_mmap(struct file *file, struct vm_area_struct *vma);
+#define HAVE_ARCH_PRIVCMD_MMAP
+
+/* for drivers/xen/balloon/balloon.c */
+#ifdef CONFIG_XEN_SCRUB_PAGES
+#define scrub_pages(_p, _n) memset((void *)(_p), 0, (_n) << PAGE_SHIFT)
+#else
+#define scrub_pages(_p, _n) ((void)0)
+#endif
+#define	pte_mfn(_x)	pte_pfn(_x)
+#define phys_to_machine_mapping_valid(_x)	(1)
+
+void xen_contiguous_bitmap_init(unsigned long end_pfn);
+int __xen_create_contiguous_region(unsigned long vstart, unsigned int order,
+				   unsigned int address_bits);
+static inline int
+xen_create_contiguous_region(unsigned long vstart,
+			     unsigned int order, unsigned int address_bits)
+{
+	int ret = 0;
+	if (is_running_on_xen()) {
+		ret = __xen_create_contiguous_region(vstart, order,
+						     address_bits);
+	}
+	return ret;
+}
+
+void __xen_destroy_contiguous_region(unsigned long vstart, unsigned int order);
+static inline void
+xen_destroy_contiguous_region(unsigned long vstart, unsigned int order)
+{
+	if (is_running_on_xen())
+		__xen_destroy_contiguous_region(vstart, order);
+}
+
+struct page;
+
+int xen_limit_pages_to_max_mfn(struct page *pages, unsigned int order,
+			       unsigned int address_bits);
+
+/* For drivers/xen/core/machine_reboot.c */
+#define HAVE_XEN_POST_SUSPEND
+void xen_post_suspend(int suspend_cancelled);
+
+/* For setup_arch() in arch/ia64/kernel/setup.c */
+void xen_ia64_enable_opt_feature(void);
+#endif /* !CONFIG_VMX_GUEST */
+
+#define __pte_ma(_x)	((pte_t) {(_x)})        /* unmodified use */
+#define mfn_pte(_x, _y)	__pte_ma(0)		/* unmodified use */
+
+/* for netfront.c, netback.c */
+#define MULTI_UVMFLAGS_INDEX 0 /* XXX any value */
+
+static inline void
+MULTI_update_va_mapping(
+	struct multicall_entry *mcl, unsigned long va,
+	pte_t new_val, unsigned long flags)
+{
+	mcl->op = __HYPERVISOR_update_va_mapping;
+	mcl->result = 0;
+}
+
+static inline void
+MULTI_grant_table_op(struct multicall_entry *mcl, unsigned int cmd,
+	void *uop, unsigned int count)
+{
+	mcl->op = __HYPERVISOR_grant_table_op;
+	mcl->args[0] = cmd;
+	mcl->args[1] = (unsigned long)uop;
+	mcl->args[2] = count;
+}
+
+static inline void
+MULTI_mmu_update(struct multicall_entry *mcl, struct mmu_update *req,
+		 int count, int *success_count, domid_t domid)
+{
+	mcl->op = __HYPERVISOR_mmu_update;
+	mcl->args[0] = (unsigned long)req;
+	mcl->args[1] = count;
+	mcl->args[2] = (unsigned long)success_count;
+	mcl->args[3] = domid;
+}
+
+/*
+ * for blktap.c
+ * int create_lookup_pte_addr(struct mm_struct *mm,
+ *                            unsigned long address,
+ *                            uint64_t *ptep);
+ */
+#define create_lookup_pte_addr(mm, address, ptep)			\
+	({								\
+		printk(KERN_EMERG					\
+		       "%s:%d "						\
+		       "create_lookup_pte_addr() isn't supported.\n",	\
+		       __func__, __LINE__);				\
+		BUG();							\
+		(-ENOSYS);						\
+	})
+
+#endif /* CONFIG_XEN || CONFIG_VMX_GUEST */
+
 #ifdef CONFIG_XEN_PRIVILEGED_GUEST
 #define is_initial_xendomain()						\
 	(is_running_on_xen() ? xen_start_info->flags & SIF_INITDOMAIN : 0)
-- 
1.5.3

