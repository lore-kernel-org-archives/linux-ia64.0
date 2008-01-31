From: "Xu, Anthony" <anthony.xu@intel.com>
Date: Thu, 31 Jan 2008 09:37:29 +0000
Subject: RE: [PATCH]Add TR insert/purge interface for add-on component
Message-Id: <51CFAB8CB6883745AE7B93B3E084EBE201702606@pdsmsx412.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <51CFAB8CB6883745AE7B93B3E084EBE201670418@pdsmsx412.ccr.corp.intel.com> <1FE6DD409037234FAB833C420AA843EC5FD030@orsmsx424.amr.corp.intel.com> <51CFAB8CB6883745AE7B93B3E084EBE2016708BB@pdsmsx412.ccr.corp.intel.com> <51CFAB8CB6883745AE7B93B3E084EBE2016708D8@pdsmsx412.ccr.corp.intel.com>
In-Reply-To: <51CFAB8CB6883745AE7B93B3E084EBE2016708D8@pdsmsx412.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Xu, Anthony" <anthony.xu@intel.com>, "Luck, Tony" <tony.luck@intel.com>, Avi Kivity <avi@qumranet.com>
Cc: linux-ia64@vger.kernel.org, kvm-devel <kvm-devel@lists.sourceforge.net>

Hi tony,

This is the revised patch per comments.
We don't use index as parameter of ia64_ptr_entry,
Because it will cause the unconvenientce to user.
1. the user need to remember index.
2. the user may want to use one purge to purge two previous inserts.

We add some optimization for ia64_ptr_entry,
It only compare dynamical used TRs,
As for KVM, it only compares two TRs, So it will not impact formance.


Thanks,
Anthony



From a10d0415ce8d7836c27da4147d73616bae055dd4 Mon Sep 17 00:00:00 2001
From: Zhang Xiantao <xiantao.zhang@intel.com>
Date: Tue, 29 Jan 2008 12:33:48 +0800
Subject: [PATCH] Add API for allocating TR resouce.

Dynamic TR resouce should be managed in an uniform way.
Signed-off-by: Zhang Xiantao <xiantao.zhang@intel.com>
Signed-off-by: Anthony Xu<anthony.xu@intel.com>
---
 arch/ia64/kernel/mca.c     |   50 ++++++++++++++
 arch/ia64/kernel/mca_asm.S |    5 ++
 arch/ia64/mm/tlb.c         |  163
++++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/kregs.h   |    3 +
 include/asm-ia64/tlb.h     |   12 +++
 5 files changed, 233 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 6dbf591..4253343 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -89,6 +89,7 @@
 
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
+#include <asm/tlb.h>
 
 #include "mca_drv.h"
 #include "entry.h"
@@ -104,8 +105,10 @@ DEFINE_PER_CPU(u64, ia64_mca_data); /* =
__per_cpu_mca[smp_processor_id()] */
 DEFINE_PER_CPU(u64, ia64_mca_per_cpu_pte); /* PTE to map per-CPU area
*/
 DEFINE_PER_CPU(u64, ia64_mca_pal_pte);	    /* PTE to map PAL code */
 DEFINE_PER_CPU(u64, ia64_mca_pal_base);    /* vaddr PAL code granule */
+DEFINE_PER_CPU(u64, ia64_mca_tr_reload);   /* Flag for TR reload */
 
 unsigned long __per_cpu_mca[NR_CPUS];
+extern struct ia64_tr_entry
__per_cpu_idtrs[NR_CPUS][2][IA64_TR_ALLOC_MAX];
 
 /* In mca_asm.S */
 extern void			ia64_os_init_dispatch_monarch (void);
@@ -1177,6 +1180,49 @@ all_in:
 	return;
 }
 
+/*  mca_insert_tr
+ *
+ *  Switch rid when TR reload and needed!
+ *  iord: 1: itr, 2: itr;
+ *
+*/
+static void mca_insert_tr(u64 iord)
+{
+
+	int i;
+	u64 old_rr;
+	struct ia64_tr_entry *p;
+	unsigned long psr;
+	int cpu = smp_processor_id();
+
+	psr = ia64_clear_ic();
+	for (i = IA64_TR_ALLOC_BASE; i < IA64_TR_ALLOC_MAX; i++) {
+		p = &__per_cpu_idtrs[cpu][iord-1][i];
+		if (p->pte&0x1) {
+			old_rr = ia64_get_rr(p->ifa);
+			if (old_rr != p->rr) {
+				ia64_set_rr(p->ifa, p->rr);
+				ia64_srlz_d();
+			}
+			ia64_ptr(iord, p->ifa, p->itir >> 2);
+			ia64_srlz_i();
+			if (iord & 0x1) {
+				ia64_itr(0x1, i, p->ifa, p->pte, p->itir
>> 2);
+				ia64_srlz_i();
+			}
+			if (iord & 0x2) {
+				ia64_itr(0x2, i, p->ifa, p->pte, p->itir
>> 2);
+				ia64_srlz_i();
+			}
+			if (old_rr != p->rr) {
+				ia64_set_rr(p->ifa, old_rr);
+				ia64_srlz_d();
+			}
+		}
+	}
+	ia64_set_psr(psr);
+}
+
 /*
  * ia64_mca_handler
  *
@@ -1266,6 +1312,10 @@ ia64_mca_handler(struct pt_regs *regs, struct
switch_stack *sw,
 		monarch_cpu = -1;
 #endif
 	}
+	if (__get_cpu_var(ia64_mca_tr_reload)) {
+		mca_insert_tr(0x1); /*Reload dynamic itrs*/
+		mca_insert_tr(0x2); /*Reload dynamic itrs*/
+	}
 	if (notify_die(DIE_MCA_MONARCH_LEAVE, "MCA", regs, (long)&nd, 0,
recover)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
diff --git a/arch/ia64/kernel/mca_asm.S b/arch/ia64/kernel/mca_asm.S
index 0f5965f..dd37dd0 100644
--- a/arch/ia64/kernel/mca_asm.S
+++ b/arch/ia64/kernel/mca_asm.S
@@ -215,8 +215,13 @@ ia64_reload_tr:
 	mov r20=IA64_TR_CURRENT_STACK
 	;;
 	itr.d dtr[r20]=r16
+	GET_THIS_PADDR(r2, ia64_mca_tr_reload)
+	mov r18 = 1
 	;;
 	srlz.d
+	;;
+	st8 [r2] =r18
+	;;
 
 done_tlb_purge_and_reload:
 
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 655da24..5d7dcdb 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -26,6 +26,8 @@
 #include <asm/pal.h>
 #include <asm/tlbflush.h>
 #include <asm/dma.h>
+#include <asm/processor.h>
+#include <asm/tlb.h>
 
 static struct {
 	unsigned long mask;	/* mask of supported purge page-sizes */
@@ -39,6 +41,9 @@ struct ia64_ctx ia64_ctx = {
 };
 
 DEFINE_PER_CPU(u8, ia64_need_tlb_flush);
+DEFINE_PER_CPU(u8, ia64_tr_num);
+
+struct ia64_tr_entry __per_cpu_idtrs[NR_CPUS][2][IA64_TR_ALLOC_MAX];
 
 /*
  * Initializes the ia64_ctx.bitmap array based on max_ctx+1.
@@ -190,6 +195,9 @@ ia64_tlb_init (void)
 	ia64_ptce_info_t uninitialized_var(ptce_info); /* GCC be quiet
*/
 	unsigned long tr_pgbits;
 	long status;
+	pal_vm_info_1_u_t vm_info_1;
+	pal_vm_info_2_u_t vm_info_2;
+	int cpu = smp_processor_id();
 
 	if ((status = ia64_pal_vm_page_size(&tr_pgbits, &purge.mask)) !0) {
 		printk(KERN_ERR "PAL_VM_PAGE_SIZE failed with
status=%ld; "
@@ -206,4 +214,159 @@ ia64_tlb_init (void)
 	local_cpu_data->ptce_stride[1] = ptce_info.stride[1];
 
 	local_flush_tlb_all();	/* nuke left overs from bootstrapping...
*/
+
+	if ((status = ia64_pal_vm_summary(&vm_info_1, &vm_info_2)) != 0)
{
+		printk(KERN_ERR "ia64_pal_vm_summary=%ld\n", status);
+		per_cpu(ia64_tr_num, cpu) = 8;
+		return;
+	}
+	per_cpu(ia64_tr_num, cpu) vm_info_1.pal_vm_info_1_s.max_itr_entry+1;
+	if (per_cpu(ia64_tr_num, cpu) > 
+
(vm_info_1.pal_vm_info_1_s.max_dtr_entry+1))
+		per_cpu(ia64_tr_num, cpu) vm_info_1.pal_vm_info_1_s.max_dtr_entry+1;
+}
+
+/*
+ * is_tr_overlap
+ *
+ * Check overlap with inserted TRs.
+ */
+static int is_tr_overlap(struct ia64_tr_entry *p, u64 va, u64 log_size)
+{
+	u64 tr_log_size;
+	u64 tr_end;
+	u64 va_rr = ia64_get_rr(va);
+	u64 va_rid = RR_TO_RID(va_rr);
+	u64 va_end = va + (1<<log_size) - 1;
+
+	if (va_rid != RR_TO_RID(p->rr))
+		return 0;
+	tr_log_size = (p->itir & 0xff) >> 2;
+	tr_end = p->ifa + (1<<tr_log_size) - 1;
+
+	if (va > tr_end || p->ifa > va_end)
+		return 0;
+	return 1;
+
+}
+
+/*
+ * ia64_insert_tr in virtual mode. Allocate a TR slot
+ *
+ * target_mask : 0x1 : itr, 0x2 : dtr, 0x3 : idtr
+ *
+ * va 	: virtual address.
+ * pte 	: pte entries inserted.
+ * log_size: range to be covered.
+ *
+ * Return value:  <0 :  error No.
+ *
+ *		  >=0 : slot number allocated for TR.
+ */
+int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64 log_size)
+{
+	int i, r;
+	unsigned long psr;
+	struct ia64_tr_entry *p;
+	int cpu = smp_processor_id();
+
+	r = -EINVAL;
+	/*Check overlap with existing TR entries*/
+	if (target_mask&0x1) {
+		p = &__per_cpu_idtrs[cpu][0][0];
+		for (i = IA64_TR_ALLOC_BASE; i < per_cpu(ia64_tr_num,
cpu);
+								i++,
p++) {
+			if (p->pte&0x1)
+				if (is_tr_overlap(p, va, log_size))
+					goto out;
+		}
+	}
+	if (target_mask&0x2) {
+		p = &__per_cpu_idtrs[cpu][1][0];
+		for (i = IA64_TR_ALLOC_BASE; i < per_cpu(ia64_tr_num,
cpu);
+								i++,
p++) {
+			if (p->pte&0x1)
+				if (is_tr_overlap(p, va, log_size))
+					goto out;
+		}
+	}
+
+	for (i = IA64_TR_ALLOC_BASE; i < per_cpu(ia64_tr_num, cpu); i++)
{
+		switch (target_mask & 0x3) {
+			case 1:
+				if
(!(__per_cpu_idtrs[cpu][0][i].pte&0x1))
+					goto found;
+				continue;
+			case 2:
+				if
(!(__per_cpu_idtrs[cpu][1][i].pte&0x1))
+					goto found;
+				continue;
+			case 3:
+				if
(!(__per_cpu_idtrs[cpu][0][i].pte&0x1) &&
+
!(__per_cpu_idtrs[cpu][1][i].pte&0x1))
+					goto found;
+				continue;
+			default:
+				r = -EINVAL;
+				goto out;
+		}
+	}
+found:
+	/*Record tr info for mca hander use!*/
+	psr = ia64_clear_ic();
+	if (target_mask & 0x1) {
+		ia64_itr(0x1, i, va, pte, log_size);
+		ia64_srlz_i();
+		p = &__per_cpu_idtrs[cpu][0][i];
+		p->ifa = va;
+		p->pte = pte;
+		p->itir = log_size << 2;
+		p->rr = ia64_get_rr(va);
+	}
+	if (target_mask & 0x2) {
+		ia64_itr(0x2, i, va, pte, log_size);
+		ia64_srlz_i();
+		p = &__per_cpu_idtrs[cpu][1][i];
+		p->ifa = va;
+		p->pte = pte;
+		p->itir = log_size << 2;
+		p->rr = ia64_get_rr(va);
+	}
+	ia64_set_psr(psr);
+	r = i;
+out:
+	return r;
+}
+EXPORT_SYMBOL_GPL(ia64_itr_entry);
+
+/*
+ * ia64_purge_tr
+ *
+ * target_mask: 0x1: purge itr, 0x2 : purge dtr, 0x3 purge idtr.
+ * va: begin address to be purged
+ * log_size: size to purege.
+ *
+ */
+void ia64_ptr_entry(u64 target_mask, u64 va, u64 log_size)
+{
+	int i;
+	int cpu = smp_processor_id();
+	struct ia64_tr_entry *p;
+
+	ia64_ptr(target_mask, va, log_size);
+	ia64_srlz_i();
+
+	for (i = IA64_TR_ALLOC_BASE; i < per_cpu(ia64_tr_num, cpu); i++)
{
+		if (target_mask&0x1) {
+			p = &__per_cpu_idtrs[cpu][0][i];
+			if ((p->pte&0x1) && is_tr_overlap(p, va,
log_size))
+				p->pte = 0;
+		}
+		if (target_mask&0x2) {
+			p = &__per_cpu_idtrs[cpu][1][i];
+			if ((p->pte&0x1) && is_tr_overlap(p, va,
log_size))
+				p->pte = 0;
+		}
+	}
 }
+EXPORT_SYMBOL_GPL(ia64_ptr_entry);
diff --git a/include/asm-ia64/kregs.h b/include/asm-ia64/kregs.h
index 7e55a58..aefcdfe 100644
--- a/include/asm-ia64/kregs.h
+++ b/include/asm-ia64/kregs.h
@@ -31,6 +31,9 @@
 #define IA64_TR_PALCODE		1	/* itr1: maps PALcode as
required by EFI */
 #define IA64_TR_CURRENT_STACK	1	/* dtr1: maps kernel's memory- &
register-stacks */
 
+#define IA64_TR_ALLOC_BASE	2 	/* itr&dtr: Base of dynamic TR
resource*/
+#define IA64_TR_ALLOC_MAX	32 	/* Max number for dynamic use*/
+
 /* Processor status register bits: */
 #define IA64_PSR_BE_BIT		1
 #define IA64_PSR_UP_BIT		2
diff --git a/include/asm-ia64/tlb.h b/include/asm-ia64/tlb.h
index 26edcb7..f57a8c1 100644
--- a/include/asm-ia64/tlb.h
+++ b/include/asm-ia64/tlb.h
@@ -64,6 +64,18 @@ struct mmu_gather {
 	struct page 		*pages[FREE_PTE_NR];
 };
 
+struct ia64_tr_entry {
+	u64 ifa;
+	u64 itir;
+	u64 pte;
+	u64 rr;
+}; /*Record for tr entry!*/
+
+extern int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64
log_size);
+extern void ia64_ptr_entry(u64 target_mask, u64 va, u64 log_size);
+
+#define RR_TO_RID(rr) ((rr)<<32>>40)
+
 /* Users of the generic TLB shootdown code must declare this storage
space. */
 DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
 
-- 
1.5.1
