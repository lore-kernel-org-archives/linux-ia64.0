From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Tue, 01 Apr 2008 10:39:42 +0000
Subject: [01/18]PATCH  Add API for allocating dynamic TR resouce. V9
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048720@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C893E4.B25A98BB"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C893E4.B25A98BB
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From b0c5c7fc45bbe0f56efba28e814ccb6bbbb7b8c8 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Tue, 1 Apr 2008 14:34:50 +0800
Subject: [PATCH] IA64: Add API for allocating Dynamic TR resource.

Dynamic TR resource should be managed in the uniform way.
Add two interfaces for kernel:
ia64_itr_entry: Allocate a (pair of) TR for caller.
ia64_ptr_entry: Purge a (pair of ) TR by caller.

Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
Signed-off-by: Anthony Xu<anthony.xu@intel.com>
---
 arch/ia64/kernel/mca.c     |   49 +++++++++++
 arch/ia64/kernel/mca_asm.S |    5 +
 arch/ia64/mm/tlb.c         |  198
++++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/kregs.h   |    3 +
 include/asm-ia64/tlb.h     |   26 ++++++
 5 files changed, 281 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 6c18221..607006a 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -97,6 +97,7 @@
=20
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
+#include <asm/tlb.h>
=20
 #include "mca_drv.h"
 #include "entry.h"
@@ -112,6 +113,7 @@ DEFINE_PER_CPU(u64, ia64_mca_data); /* =3D=3D
__per_cpu_mca[smp_processor_id()] */
 DEFINE_PER_CPU(u64, ia64_mca_per_cpu_pte); /* PTE to map per-CPU area
*/
 DEFINE_PER_CPU(u64, ia64_mca_pal_pte);	    /* PTE to map PAL code */
 DEFINE_PER_CPU(u64, ia64_mca_pal_base);    /* vaddr PAL code granule */
+DEFINE_PER_CPU(u64, ia64_mca_tr_reload);   /* Flag for TR reload */
=20
 unsigned long __per_cpu_mca[NR_CPUS];
=20
@@ -1182,6 +1184,49 @@ all_in:
 	return;
 }
=20
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
+	int cpu =3D smp_processor_id();
+
+	psr =3D ia64_clear_ic();
+	for (i =3D IA64_TR_ALLOC_BASE; i < IA64_TR_ALLOC_MAX; i++) {
+		p =3D &__per_cpu_idtrs[cpu][iord-1][i];
+		if (p->pte & 0x1) {
+			old_rr =3D ia64_get_rr(p->ifa);
+			if (old_rr !=3D p->rr) {
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
+			if (old_rr !=3D p->rr) {
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
@@ -1271,6 +1316,10 @@ ia64_mca_handler(struct pt_regs *regs, struct
switch_stack *sw,
 		monarch_cpu =3D -1;
 #endif
 	}
+	if (__get_cpu_var(ia64_mca_tr_reload)) {
+		mca_insert_tr(0x1); /*Reload dynamic itrs*/
+		mca_insert_tr(0x2); /*Reload dynamic itrs*/
+	}
 	if (notify_die(DIE_MCA_MONARCH_LEAVE, "MCA", regs, (long)&nd, 0,
recover)
 			=3D=3D NOTIFY_STOP)
 		ia64_mca_spin(__func__);
diff --git a/arch/ia64/kernel/mca_asm.S b/arch/ia64/kernel/mca_asm.S
index 8bc7d25..a06d465 100644
--- a/arch/ia64/kernel/mca_asm.S
+++ b/arch/ia64/kernel/mca_asm.S
@@ -219,8 +219,13 @@ ia64_reload_tr:
 	mov r20=3DIA64_TR_CURRENT_STACK
 	;;
 	itr.d dtr[r20]=3Dr16
+	GET_THIS_PADDR(r2, ia64_mca_tr_reload)
+	mov r18 =3D 1
 	;;
 	srlz.d
+	;;
+	st8 [r2] =3Dr18
+	;;
=20
 done_tlb_purge_and_reload:
=20
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 655da24..626100c 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -26,6 +26,8 @@
 #include <asm/pal.h>
 #include <asm/tlbflush.h>
 #include <asm/dma.h>
+#include <asm/processor.h>
+#include <asm/tlb.h>
=20
 static struct {
 	unsigned long mask;	/* mask of supported purge page-sizes */
@@ -39,6 +41,10 @@ struct ia64_ctx ia64_ctx =3D {
 };
=20
 DEFINE_PER_CPU(u8, ia64_need_tlb_flush);
+DEFINE_PER_CPU(u8, ia64_tr_num);  /*Number of TR slots in current
processor*/
+DEFINE_PER_CPU(u8, ia64_tr_used); /*Max Slot number used by kernel*/
+
+struct ia64_tr_entry __per_cpu_idtrs[NR_CPUS][2][IA64_TR_ALLOC_MAX];
=20
 /*
  * Initializes the ia64_ctx.bitmap array based on max_ctx+1.
@@ -190,6 +196,9 @@ ia64_tlb_init (void)
 	ia64_ptce_info_t uninitialized_var(ptce_info); /* GCC be quiet
*/
 	unsigned long tr_pgbits;
 	long status;
+	pal_vm_info_1_u_t vm_info_1;
+	pal_vm_info_2_u_t vm_info_2;
+	int cpu =3D smp_processor_id();
=20
 	if ((status =3D ia64_pal_vm_page_size(&tr_pgbits, &purge.mask)) !=3D
0) {
 		printk(KERN_ERR "PAL_VM_PAGE_SIZE failed with
status=3D%ld; "
@@ -206,4 +215,193 @@ ia64_tlb_init (void)
 	local_cpu_data->ptce_stride[1] =3D ptce_info.stride[1];
=20
 	local_flush_tlb_all();	/* nuke left overs from bootstrapping...
*/
+	status =3D ia64_pal_vm_summary(&vm_info_1, &vm_info_2);
+
+	if (status) {
+		printk(KERN_ERR "ia64_pal_vm_summary=3D%ld\n", status);
+		per_cpu(ia64_tr_num, cpu) =3D 8;
+		return;
+	}
+	per_cpu(ia64_tr_num, cpu) =3D
vm_info_1.pal_vm_info_1_s.max_itr_entry+1;
+	if (per_cpu(ia64_tr_num, cpu) >
+
(vm_info_1.pal_vm_info_1_s.max_dtr_entry+1))
+		per_cpu(ia64_tr_num, cpu) =3D
+
vm_info_1.pal_vm_info_1_s.max_dtr_entry+1;
+	if (per_cpu(ia64_tr_num, cpu) > IA64_TR_ALLOC_MAX) {
+		per_cpu(ia64_tr_num, cpu) =3D IA64_TR_ALLOC_MAX;
+		printk(KERN_DEBUG"TR register number exceeds
IA64_TR_ALLOC_MAX!"
+			"IA64_TR_ALLOC_MAX should be extended\n");
+	}
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
+	u64 va_rr =3D ia64_get_rr(va);
+	u64 va_rid =3D RR_TO_RID(va_rr);
+	u64 va_end =3D va + (1<<log_size) - 1;
+
+	if (va_rid !=3D RR_TO_RID(p->rr))
+		return 0;
+	tr_log_size =3D (p->itir & 0xff) >> 2;
+	tr_end =3D p->ifa + (1<<tr_log_size) - 1;
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
+ *		  >=3D0 : slot number allocated for TR.
+ * Called with preemption disabled.
+ */
+int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64 log_size)
+{
+	int i, r;
+	unsigned long psr;
+	struct ia64_tr_entry *p;
+	int cpu =3D smp_processor_id();
+
+	r =3D -EINVAL;
+	/*Check overlap with existing TR entries*/
+	if (target_mask & 0x1) {
+		p =3D &__per_cpu_idtrs[cpu][0][0];
+		for (i =3D IA64_TR_ALLOC_BASE; i <=3D per_cpu(ia64_tr_used,
cpu);
+								i++,
p++) {
+			if (p->pte & 0x1)
+				if (is_tr_overlap(p, va, log_size)) {
+					printk(KERN_DEBUG"Overlapped
Entry"
+						"Inserted for TR
Reigster!!\n");
+					goto out;
+			}
+		}
+	}
+	if (target_mask & 0x2) {
+		p =3D &__per_cpu_idtrs[cpu][1][0];
+		for (i =3D IA64_TR_ALLOC_BASE; i <=3D per_cpu(ia64_tr_used,
cpu);
+								i++,
p++) {
+			if (p->pte & 0x1)
+				if (is_tr_overlap(p, va, log_size)) {
+					printk(KERN_DEBUG"Overlapped
Entry"
+						"Inserted for TR
Reigster!!\n");
+					goto out;
+				}
+		}
+	}
+
+	for (i =3D IA64_TR_ALLOC_BASE; i < per_cpu(ia64_tr_num, cpu); i++)
{
+		switch (target_mask & 0x3) {
+		case 1:
+			if (!(__per_cpu_idtrs[cpu][0][i].pte & 0x1))
+				goto found;
+			continue;
+		case 2:
+			if (!(__per_cpu_idtrs[cpu][1][i].pte & 0x1))
+				goto found;
+			continue;
+		case 3:
+			if (!(__per_cpu_idtrs[cpu][0][i].pte & 0x1) &&
+				!(__per_cpu_idtrs[cpu][1][i].pte & 0x1))
+				goto found;
+			continue;
+		default:
+			r =3D -EINVAL;
+			goto out;
+		}
+	}
+found:
+	if (i >=3D per_cpu(ia64_tr_num, cpu)) {
+		r =3D -EBUSY;
+		goto out;
+	}
+
+	/*Record tr info for mca hander use!*/
+	if (i > per_cpu(ia64_tr_used, cpu))
+		per_cpu(ia64_tr_used, cpu) =3D i;
+
+	psr =3D ia64_clear_ic();
+	if (target_mask & 0x1) {
+		ia64_itr(0x1, i, va, pte, log_size);
+		ia64_srlz_i();
+		p =3D &__per_cpu_idtrs[cpu][0][i];
+		p->ifa =3D va;
+		p->pte =3D pte;
+		p->itir =3D log_size << 2;
+		p->rr =3D ia64_get_rr(va);
+	}
+	if (target_mask & 0x2) {
+		ia64_itr(0x2, i, va, pte, log_size);
+		ia64_srlz_i();
+		p =3D &__per_cpu_idtrs[cpu][1][i];
+		p->ifa =3D va;
+		p->pte =3D pte;
+		p->itir =3D log_size << 2;
+		p->rr =3D ia64_get_rr(va);
+	}
+	ia64_set_psr(psr);
+	r =3D i;
+out:
+	return r;
+}
+EXPORT_SYMBOL_GPL(ia64_itr_entry);
+
+/*
+ * ia64_purge_tr
+ *
+ * target_mask: 0x1: purge itr, 0x2 : purge dtr, 0x3 purge idtr.
+ * slot: slot number to be freed.
+ *
+ * Called with preemption disabled.
+ */
+void ia64_ptr_entry(u64 target_mask, int slot)
+{
+	int cpu =3D smp_processor_id();
+	int i;
+	struct ia64_tr_entry *p;
+
+	if (slot < IA64_TR_ALLOC_BASE || slot >=3D per_cpu(ia64_tr_num,
cpu))
+		return;
+
+	if (target_mask & 0x1) {
+		p =3D &__per_cpu_idtrs[cpu][0][slot];
+		if ((p->pte&0x1) && is_tr_overlap(p, p->ifa,
p->itir>>2)) {
+			p->pte =3D 0;
+			ia64_ptr(0x1, p->ifa, p->itir>>2);
+			ia64_srlz_i();
+		}
+	}
+
+	if (target_mask & 0x2) {
+		p =3D &__per_cpu_idtrs[cpu][1][slot];
+		if ((p->pte & 0x1) && is_tr_overlap(p, p->ifa,
p->itir>>2)) {
+			p->pte =3D 0;
+			ia64_ptr(0x2, p->ifa, p->itir>>2);
+			ia64_srlz_i();
+		}
+	}
+
+	for (i =3D per_cpu(ia64_tr_used, cpu); i >=3D IA64_TR_ALLOC_BASE;
i--) {
+		if ((__per_cpu_idtrs[cpu][0][i].pte & 0x1) ||
+				(__per_cpu_idtrs[cpu][1][i].pte & 0x1))
+			break;
+	}
+	per_cpu(ia64_tr_used, cpu) =3D i;
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
=20
+#define IA64_TR_ALLOC_BASE	2 	/* itr&dtr: Base of dynamic TR
resource*/
+#define IA64_TR_ALLOC_MAX	32 	/* Max number for dynamic use*/
+
 /* Processor status register bits: */
 #define IA64_PSR_BE_BIT		1
 #define IA64_PSR_UP_BIT		2
diff --git a/include/asm-ia64/tlb.h b/include/asm-ia64/tlb.h
index 26edcb7..20d8a39 100644
--- a/include/asm-ia64/tlb.h
+++ b/include/asm-ia64/tlb.h
@@ -64,6 +64,32 @@ struct mmu_gather {
 	struct page 		*pages[FREE_PTE_NR];
 };
=20
+struct ia64_tr_entry {
+	u64 ifa;
+	u64 itir;
+	u64 pte;
+	u64 rr;
+}; /*Record for tr entry!*/
+
+extern int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64
log_size);
+extern void ia64_ptr_entry(u64 target_mask, int slot);
+
+extern struct ia64_tr_entry
__per_cpu_idtrs[NR_CPUS][2][IA64_TR_ALLOC_MAX];
+
+/*
+ region register macros
+*/
+#define RR_TO_VE(val)   (((val) >> 0) & 0x0000000000000001)
+#define RR_VE(val)	(((val) & 0x0000000000000001) << 0)
+#define RR_VE_MASK	0x0000000000000001L
+#define RR_VE_SHIFT	0
+#define RR_TO_PS(val)	(((val) >> 2) & 0x000000000000003f)
+#define RR_PS(val)	(((val) & 0x000000000000003f) << 2)
+#define RR_PS_MASK	0x00000000000000fcL
+#define RR_PS_SHIFT	2
+#define RR_RID_MASK	0x00000000ffffff00L
+#define RR_TO_RID(val) 	((val >> 8) & 0xffffff)
+
 /* Users of the generic TLB shootdown code must declare this storage
space. */
 DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
=20
--=20
1.5.2

------_=_NextPart_001_01C893E4.B25A98BB
Content-Type: application/octet-stream;
	name="0001-IA64-Add-API-for-allocating-Dynamic-TR-resource.patch"
Content-Transfer-Encoding: base64
Content-Description: 0001-IA64-Add-API-for-allocating-Dynamic-TR-resource.patch
Content-Disposition: attachment;
	filename="0001-IA64-Add-API-for-allocating-Dynamic-TR-resource.patch"

RnJvbSBiMGM1YzdmYzQ1YmJlMGY1NmVmYmEyOGU4MTRjY2I2YmJiYjdiOGM4IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAxIEFwciAyMDA4IDE0OjM0OjUwICswODAwClN1YmplY3Q6IFtQQVRDSF0g
SUE2NDogQWRkIEFQSSBmb3IgYWxsb2NhdGluZyBEeW5hbWljIFRSIHJlc291cmNlLgoKRHluYW1p
YyBUUiByZXNvdXJjZSBzaG91bGQgYmUgbWFuYWdlZCBpbiB0aGUgdW5pZm9ybSB3YXkuCkFkZCB0
d28gaW50ZXJmYWNlcyBmb3Iga2VybmVsOgppYTY0X2l0cl9lbnRyeTogQWxsb2NhdGUgYSAocGFp
ciBvZikgVFIgZm9yIGNhbGxlci4KaWE2NF9wdHJfZW50cnk6IFB1cmdlIGEgKHBhaXIgb2YgKSBU
UiBieSBjYWxsZXIuCgpTaWduZWQtb2ZmLWJ5OiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5n
QGludGVsLmNvbT4KU2lnbmVkLW9mZi1ieTogQW50aG9ueSBYdTxhbnRob255Lnh1QGludGVsLmNv
bT4KLS0tCiBhcmNoL2lhNjQva2VybmVsL21jYS5jICAgICB8ICAgNDkgKysrKysrKysrKysKIGFy
Y2gvaWE2NC9rZXJuZWwvbWNhX2FzbS5TIHwgICAgNSArCiBhcmNoL2lhNjQvbW0vdGxiLmMgICAg
ICAgICB8ICAxOTggKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysK
IGluY2x1ZGUvYXNtLWlhNjQva3JlZ3MuaCAgIHwgICAgMyArCiBpbmNsdWRlL2FzbS1pYTY0L3Rs
Yi5oICAgICB8ICAgMjYgKysrKysrCiA1IGZpbGVzIGNoYW5nZWQsIDI4MSBpbnNlcnRpb25zKCsp
LCAwIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rZXJuZWwvbWNhLmMgYi9h
cmNoL2lhNjQva2VybmVsL21jYS5jCmluZGV4IDZjMTgyMjEuLjYwNzAwNmEgMTAwNjQ0Ci0tLSBh
L2FyY2gvaWE2NC9rZXJuZWwvbWNhLmMKKysrIGIvYXJjaC9pYTY0L2tlcm5lbC9tY2EuYwpAQCAt
OTcsNiArOTcsNyBAQAogCiAjaW5jbHVkZSA8YXNtL2lycS5oPgogI2luY2x1ZGUgPGFzbS9od19p
cnEuaD4KKyNpbmNsdWRlIDxhc20vdGxiLmg+CiAKICNpbmNsdWRlICJtY2FfZHJ2LmgiCiAjaW5j
bHVkZSAiZW50cnkuaCIKQEAgLTExMiw2ICsxMTMsNyBAQCBERUZJTkVfUEVSX0NQVSh1NjQsIGlh
NjRfbWNhX2RhdGEpOyAvKiA9PSBfX3Blcl9jcHVfbWNhW3NtcF9wcm9jZXNzb3JfaWQoKV0gKi8K
IERFRklORV9QRVJfQ1BVKHU2NCwgaWE2NF9tY2FfcGVyX2NwdV9wdGUpOyAvKiBQVEUgdG8gbWFw
IHBlci1DUFUgYXJlYSAqLwogREVGSU5FX1BFUl9DUFUodTY0LCBpYTY0X21jYV9wYWxfcHRlKTsJ
ICAgIC8qIFBURSB0byBtYXAgUEFMIGNvZGUgKi8KIERFRklORV9QRVJfQ1BVKHU2NCwgaWE2NF9t
Y2FfcGFsX2Jhc2UpOyAgICAvKiB2YWRkciBQQUwgY29kZSBncmFudWxlICovCitERUZJTkVfUEVS
X0NQVSh1NjQsIGlhNjRfbWNhX3RyX3JlbG9hZCk7ICAgLyogRmxhZyBmb3IgVFIgcmVsb2FkICov
CiAKIHVuc2lnbmVkIGxvbmcgX19wZXJfY3B1X21jYVtOUl9DUFVTXTsKIApAQCAtMTE4Miw2ICsx
MTg0LDQ5IEBAIGFsbF9pbjoKIAlyZXR1cm47CiB9CiAKKy8qICBtY2FfaW5zZXJ0X3RyCisgKgor
ICogIFN3aXRjaCByaWQgd2hlbiBUUiByZWxvYWQgYW5kIG5lZWRlZCEKKyAqICBpb3JkOiAxOiBp
dHIsIDI6IGl0cjsKKyAqCisqLworc3RhdGljIHZvaWQgbWNhX2luc2VydF90cih1NjQgaW9yZCkK
K3sKKworCWludCBpOworCXU2NCBvbGRfcnI7CisJc3RydWN0IGlhNjRfdHJfZW50cnkgKnA7CisJ
dW5zaWduZWQgbG9uZyBwc3I7CisJaW50IGNwdSA9IHNtcF9wcm9jZXNzb3JfaWQoKTsKKworCXBz
ciA9IGlhNjRfY2xlYXJfaWMoKTsKKwlmb3IgKGkgPSBJQTY0X1RSX0FMTE9DX0JBU0U7IGkgPCBJ
QTY0X1RSX0FMTE9DX01BWDsgaSsrKSB7CisJCXAgPSAmX19wZXJfY3B1X2lkdHJzW2NwdV1baW9y
ZC0xXVtpXTsKKwkJaWYgKHAtPnB0ZSAmIDB4MSkgeworCQkJb2xkX3JyID0gaWE2NF9nZXRfcnIo
cC0+aWZhKTsKKwkJCWlmIChvbGRfcnIgIT0gcC0+cnIpIHsKKwkJCQlpYTY0X3NldF9ycihwLT5p
ZmEsIHAtPnJyKTsKKwkJCQlpYTY0X3NybHpfZCgpOworCQkJfQorCQkJaWE2NF9wdHIoaW9yZCwg
cC0+aWZhLCBwLT5pdGlyID4+IDIpOworCQkJaWE2NF9zcmx6X2koKTsKKwkJCWlmIChpb3JkICYg
MHgxKSB7CisJCQkJaWE2NF9pdHIoMHgxLCBpLCBwLT5pZmEsIHAtPnB0ZSwgcC0+aXRpciA+PiAy
KTsKKwkJCQlpYTY0X3NybHpfaSgpOworCQkJfQorCQkJaWYgKGlvcmQgJiAweDIpIHsKKwkJCQlp
YTY0X2l0cigweDIsIGksIHAtPmlmYSwgcC0+cHRlLCBwLT5pdGlyID4+IDIpOworCQkJCWlhNjRf
c3Jsel9pKCk7CisJCQl9CisJCQlpZiAob2xkX3JyICE9IHAtPnJyKSB7CisJCQkJaWE2NF9zZXRf
cnIocC0+aWZhLCBvbGRfcnIpOworCQkJCWlhNjRfc3Jsel9kKCk7CisJCQl9CisJCX0KKwl9CisJ
aWE2NF9zZXRfcHNyKHBzcik7Cit9CisKIC8qCiAgKiBpYTY0X21jYV9oYW5kbGVyCiAgKgpAQCAt
MTI3MSw2ICsxMzE2LDEwIEBAIGlhNjRfbWNhX2hhbmRsZXIoc3RydWN0IHB0X3JlZ3MgKnJlZ3Ms
IHN0cnVjdCBzd2l0Y2hfc3RhY2sgKnN3LAogCQltb25hcmNoX2NwdSA9IC0xOwogI2VuZGlmCiAJ
fQorCWlmIChfX2dldF9jcHVfdmFyKGlhNjRfbWNhX3RyX3JlbG9hZCkpIHsKKwkJbWNhX2luc2Vy
dF90cigweDEpOyAvKlJlbG9hZCBkeW5hbWljIGl0cnMqLworCQltY2FfaW5zZXJ0X3RyKDB4Mik7
IC8qUmVsb2FkIGR5bmFtaWMgaXRycyovCisJfQogCWlmIChub3RpZnlfZGllKERJRV9NQ0FfTU9O
QVJDSF9MRUFWRSwgIk1DQSIsIHJlZ3MsIChsb25nKSZuZCwgMCwgcmVjb3ZlcikKIAkJCT09IE5P
VElGWV9TVE9QKQogCQlpYTY0X21jYV9zcGluKF9fZnVuY19fKTsKZGlmZiAtLWdpdCBhL2FyY2gv
aWE2NC9rZXJuZWwvbWNhX2FzbS5TIGIvYXJjaC9pYTY0L2tlcm5lbC9tY2FfYXNtLlMKaW5kZXgg
OGJjN2QyNS4uYTA2ZDQ2NSAxMDA2NDQKLS0tIGEvYXJjaC9pYTY0L2tlcm5lbC9tY2FfYXNtLlMK
KysrIGIvYXJjaC9pYTY0L2tlcm5lbC9tY2FfYXNtLlMKQEAgLTIxOSw4ICsyMTksMTMgQEAgaWE2
NF9yZWxvYWRfdHI6CiAJbW92IHIyMD1JQTY0X1RSX0NVUlJFTlRfU1RBQ0sKIAk7OwogCWl0ci5k
IGR0cltyMjBdPXIxNgorCUdFVF9USElTX1BBRERSKHIyLCBpYTY0X21jYV90cl9yZWxvYWQpCisJ
bW92IHIxOCA9IDEKIAk7OwogCXNybHouZAorCTs7CisJc3Q4IFtyMl0gPXIxOAorCTs7CiAKIGRv
bmVfdGxiX3B1cmdlX2FuZF9yZWxvYWQ6CiAKZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9tbS90bGIu
YyBiL2FyY2gvaWE2NC9tbS90bGIuYwppbmRleCA2NTVkYTI0Li42MjYxMDBjIDEwMDY0NAotLS0g
YS9hcmNoL2lhNjQvbW0vdGxiLmMKKysrIGIvYXJjaC9pYTY0L21tL3RsYi5jCkBAIC0yNiw2ICsy
Niw4IEBACiAjaW5jbHVkZSA8YXNtL3BhbC5oPgogI2luY2x1ZGUgPGFzbS90bGJmbHVzaC5oPgog
I2luY2x1ZGUgPGFzbS9kbWEuaD4KKyNpbmNsdWRlIDxhc20vcHJvY2Vzc29yLmg+CisjaW5jbHVk
ZSA8YXNtL3RsYi5oPgogCiBzdGF0aWMgc3RydWN0IHsKIAl1bnNpZ25lZCBsb25nIG1hc2s7CS8q
IG1hc2sgb2Ygc3VwcG9ydGVkIHB1cmdlIHBhZ2Utc2l6ZXMgKi8KQEAgLTM5LDYgKzQxLDEwIEBA
IHN0cnVjdCBpYTY0X2N0eCBpYTY0X2N0eCA9IHsKIH07CiAKIERFRklORV9QRVJfQ1BVKHU4LCBp
YTY0X25lZWRfdGxiX2ZsdXNoKTsKK0RFRklORV9QRVJfQ1BVKHU4LCBpYTY0X3RyX251bSk7ICAv
Kk51bWJlciBvZiBUUiBzbG90cyBpbiBjdXJyZW50IHByb2Nlc3NvciovCitERUZJTkVfUEVSX0NQ
VSh1OCwgaWE2NF90cl91c2VkKTsgLypNYXggU2xvdCBudW1iZXIgdXNlZCBieSBrZXJuZWwqLwor
CitzdHJ1Y3QgaWE2NF90cl9lbnRyeSBfX3Blcl9jcHVfaWR0cnNbTlJfQ1BVU11bMl1bSUE2NF9U
Ul9BTExPQ19NQVhdOwogCiAvKgogICogSW5pdGlhbGl6ZXMgdGhlIGlhNjRfY3R4LmJpdG1hcCBh
cnJheSBiYXNlZCBvbiBtYXhfY3R4KzEuCkBAIC0xOTAsNiArMTk2LDkgQEAgaWE2NF90bGJfaW5p
dCAodm9pZCkKIAlpYTY0X3B0Y2VfaW5mb190IHVuaW5pdGlhbGl6ZWRfdmFyKHB0Y2VfaW5mbyk7
IC8qIEdDQyBiZSBxdWlldCAqLwogCXVuc2lnbmVkIGxvbmcgdHJfcGdiaXRzOwogCWxvbmcgc3Rh
dHVzOworCXBhbF92bV9pbmZvXzFfdV90IHZtX2luZm9fMTsKKwlwYWxfdm1faW5mb18yX3VfdCB2
bV9pbmZvXzI7CisJaW50IGNwdSA9IHNtcF9wcm9jZXNzb3JfaWQoKTsKIAogCWlmICgoc3RhdHVz
ID0gaWE2NF9wYWxfdm1fcGFnZV9zaXplKCZ0cl9wZ2JpdHMsICZwdXJnZS5tYXNrKSkgIT0gMCkg
ewogCQlwcmludGsoS0VSTl9FUlIgIlBBTF9WTV9QQUdFX1NJWkUgZmFpbGVkIHdpdGggc3RhdHVz
PSVsZDsgIgpAQCAtMjA2LDQgKzIxNSwxOTMgQEAgaWE2NF90bGJfaW5pdCAodm9pZCkKIAlsb2Nh
bF9jcHVfZGF0YS0+cHRjZV9zdHJpZGVbMV0gPSBwdGNlX2luZm8uc3RyaWRlWzFdOwogCiAJbG9j
YWxfZmx1c2hfdGxiX2FsbCgpOwkvKiBudWtlIGxlZnQgb3ZlcnMgZnJvbSBib290c3RyYXBwaW5n
Li4uICovCisJc3RhdHVzID0gaWE2NF9wYWxfdm1fc3VtbWFyeSgmdm1faW5mb18xLCAmdm1faW5m
b18yKTsKKworCWlmIChzdGF0dXMpIHsKKwkJcHJpbnRrKEtFUk5fRVJSICJpYTY0X3BhbF92bV9z
dW1tYXJ5PSVsZFxuIiwgc3RhdHVzKTsKKwkJcGVyX2NwdShpYTY0X3RyX251bSwgY3B1KSA9IDg7
CisJCXJldHVybjsKKwl9CisJcGVyX2NwdShpYTY0X3RyX251bSwgY3B1KSA9IHZtX2luZm9fMS5w
YWxfdm1faW5mb18xX3MubWF4X2l0cl9lbnRyeSsxOworCWlmIChwZXJfY3B1KGlhNjRfdHJfbnVt
LCBjcHUpID4KKwkJCQkodm1faW5mb18xLnBhbF92bV9pbmZvXzFfcy5tYXhfZHRyX2VudHJ5KzEp
KQorCQlwZXJfY3B1KGlhNjRfdHJfbnVtLCBjcHUpID0KKwkJCQl2bV9pbmZvXzEucGFsX3ZtX2lu
Zm9fMV9zLm1heF9kdHJfZW50cnkrMTsKKwlpZiAocGVyX2NwdShpYTY0X3RyX251bSwgY3B1KSA+
IElBNjRfVFJfQUxMT0NfTUFYKSB7CisJCXBlcl9jcHUoaWE2NF90cl9udW0sIGNwdSkgPSBJQTY0
X1RSX0FMTE9DX01BWDsKKwkJcHJpbnRrKEtFUk5fREVCVUciVFIgcmVnaXN0ZXIgbnVtYmVyIGV4
Y2VlZHMgSUE2NF9UUl9BTExPQ19NQVghIgorCQkJIklBNjRfVFJfQUxMT0NfTUFYIHNob3VsZCBi
ZSBleHRlbmRlZFxuIik7CisJfQorfQorCisvKgorICogaXNfdHJfb3ZlcmxhcAorICoKKyAqIENo
ZWNrIG92ZXJsYXAgd2l0aCBpbnNlcnRlZCBUUnMuCisgKi8KK3N0YXRpYyBpbnQgaXNfdHJfb3Zl
cmxhcChzdHJ1Y3QgaWE2NF90cl9lbnRyeSAqcCwgdTY0IHZhLCB1NjQgbG9nX3NpemUpCit7CisJ
dTY0IHRyX2xvZ19zaXplOworCXU2NCB0cl9lbmQ7CisJdTY0IHZhX3JyID0gaWE2NF9nZXRfcnIo
dmEpOworCXU2NCB2YV9yaWQgPSBSUl9UT19SSUQodmFfcnIpOworCXU2NCB2YV9lbmQgPSB2YSAr
ICgxPDxsb2dfc2l6ZSkgLSAxOworCisJaWYgKHZhX3JpZCAhPSBSUl9UT19SSUQocC0+cnIpKQor
CQlyZXR1cm4gMDsKKwl0cl9sb2dfc2l6ZSA9IChwLT5pdGlyICYgMHhmZikgPj4gMjsKKwl0cl9l
bmQgPSBwLT5pZmEgKyAoMTw8dHJfbG9nX3NpemUpIC0gMTsKKworCWlmICh2YSA+IHRyX2VuZCB8
fCBwLT5pZmEgPiB2YV9lbmQpCisJCXJldHVybiAwOworCXJldHVybiAxOworCit9CisKKy8qCisg
KiBpYTY0X2luc2VydF90ciBpbiB2aXJ0dWFsIG1vZGUuIEFsbG9jYXRlIGEgVFIgc2xvdAorICoK
KyAqIHRhcmdldF9tYXNrIDogMHgxIDogaXRyLCAweDIgOiBkdHIsIDB4MyA6IGlkdHIKKyAqCisg
KiB2YSAJOiB2aXJ0dWFsIGFkZHJlc3MuCisgKiBwdGUgCTogcHRlIGVudHJpZXMgaW5zZXJ0ZWQu
CisgKiBsb2dfc2l6ZTogcmFuZ2UgdG8gYmUgY292ZXJlZC4KKyAqCisgKiBSZXR1cm4gdmFsdWU6
ICA8MCA6ICBlcnJvciBOby4KKyAqCisgKgkJICA+PTAgOiBzbG90IG51bWJlciBhbGxvY2F0ZWQg
Zm9yIFRSLgorICogQ2FsbGVkIHdpdGggcHJlZW1wdGlvbiBkaXNhYmxlZC4KKyAqLworaW50IGlh
NjRfaXRyX2VudHJ5KHU2NCB0YXJnZXRfbWFzaywgdTY0IHZhLCB1NjQgcHRlLCB1NjQgbG9nX3Np
emUpCit7CisJaW50IGksIHI7CisJdW5zaWduZWQgbG9uZyBwc3I7CisJc3RydWN0IGlhNjRfdHJf
ZW50cnkgKnA7CisJaW50IGNwdSA9IHNtcF9wcm9jZXNzb3JfaWQoKTsKKworCXIgPSAtRUlOVkFM
OworCS8qQ2hlY2sgb3ZlcmxhcCB3aXRoIGV4aXN0aW5nIFRSIGVudHJpZXMqLworCWlmICh0YXJn
ZXRfbWFzayAmIDB4MSkgeworCQlwID0gJl9fcGVyX2NwdV9pZHRyc1tjcHVdWzBdWzBdOworCQlm
b3IgKGkgPSBJQTY0X1RSX0FMTE9DX0JBU0U7IGkgPD0gcGVyX2NwdShpYTY0X3RyX3VzZWQsIGNw
dSk7CisJCQkJCQkJCWkrKywgcCsrKSB7CisJCQlpZiAocC0+cHRlICYgMHgxKQorCQkJCWlmIChp
c190cl9vdmVybGFwKHAsIHZhLCBsb2dfc2l6ZSkpIHsKKwkJCQkJcHJpbnRrKEtFUk5fREVCVUci
T3ZlcmxhcHBlZCBFbnRyeSIKKwkJCQkJCSJJbnNlcnRlZCBmb3IgVFIgUmVpZ3N0ZXIhIVxuIik7
CisJCQkJCWdvdG8gb3V0OworCQkJfQorCQl9CisJfQorCWlmICh0YXJnZXRfbWFzayAmIDB4Mikg
eworCQlwID0gJl9fcGVyX2NwdV9pZHRyc1tjcHVdWzFdWzBdOworCQlmb3IgKGkgPSBJQTY0X1RS
X0FMTE9DX0JBU0U7IGkgPD0gcGVyX2NwdShpYTY0X3RyX3VzZWQsIGNwdSk7CisJCQkJCQkJCWkr
KywgcCsrKSB7CisJCQlpZiAocC0+cHRlICYgMHgxKQorCQkJCWlmIChpc190cl9vdmVybGFwKHAs
IHZhLCBsb2dfc2l6ZSkpIHsKKwkJCQkJcHJpbnRrKEtFUk5fREVCVUciT3ZlcmxhcHBlZCBFbnRy
eSIKKwkJCQkJCSJJbnNlcnRlZCBmb3IgVFIgUmVpZ3N0ZXIhIVxuIik7CisJCQkJCWdvdG8gb3V0
OworCQkJCX0KKwkJfQorCX0KKworCWZvciAoaSA9IElBNjRfVFJfQUxMT0NfQkFTRTsgaSA8IHBl
cl9jcHUoaWE2NF90cl9udW0sIGNwdSk7IGkrKykgeworCQlzd2l0Y2ggKHRhcmdldF9tYXNrICYg
MHgzKSB7CisJCWNhc2UgMToKKwkJCWlmICghKF9fcGVyX2NwdV9pZHRyc1tjcHVdWzBdW2ldLnB0
ZSAmIDB4MSkpCisJCQkJZ290byBmb3VuZDsKKwkJCWNvbnRpbnVlOworCQljYXNlIDI6CisJCQlp
ZiAoIShfX3Blcl9jcHVfaWR0cnNbY3B1XVsxXVtpXS5wdGUgJiAweDEpKQorCQkJCWdvdG8gZm91
bmQ7CisJCQljb250aW51ZTsKKwkJY2FzZSAzOgorCQkJaWYgKCEoX19wZXJfY3B1X2lkdHJzW2Nw
dV1bMF1baV0ucHRlICYgMHgxKSAmJgorCQkJCSEoX19wZXJfY3B1X2lkdHJzW2NwdV1bMV1baV0u
cHRlICYgMHgxKSkKKwkJCQlnb3RvIGZvdW5kOworCQkJY29udGludWU7CisJCWRlZmF1bHQ6CisJ
CQlyID0gLUVJTlZBTDsKKwkJCWdvdG8gb3V0OworCQl9CisJfQorZm91bmQ6CisJaWYgKGkgPj0g
cGVyX2NwdShpYTY0X3RyX251bSwgY3B1KSkgeworCQlyID0gLUVCVVNZOworCQlnb3RvIG91dDsK
Kwl9CisKKwkvKlJlY29yZCB0ciBpbmZvIGZvciBtY2EgaGFuZGVyIHVzZSEqLworCWlmIChpID4g
cGVyX2NwdShpYTY0X3RyX3VzZWQsIGNwdSkpCisJCXBlcl9jcHUoaWE2NF90cl91c2VkLCBjcHUp
ID0gaTsKKworCXBzciA9IGlhNjRfY2xlYXJfaWMoKTsKKwlpZiAodGFyZ2V0X21hc2sgJiAweDEp
IHsKKwkJaWE2NF9pdHIoMHgxLCBpLCB2YSwgcHRlLCBsb2dfc2l6ZSk7CisJCWlhNjRfc3Jsel9p
KCk7CisJCXAgPSAmX19wZXJfY3B1X2lkdHJzW2NwdV1bMF1baV07CisJCXAtPmlmYSA9IHZhOwor
CQlwLT5wdGUgPSBwdGU7CisJCXAtPml0aXIgPSBsb2dfc2l6ZSA8PCAyOworCQlwLT5yciA9IGlh
NjRfZ2V0X3JyKHZhKTsKKwl9CisJaWYgKHRhcmdldF9tYXNrICYgMHgyKSB7CisJCWlhNjRfaXRy
KDB4MiwgaSwgdmEsIHB0ZSwgbG9nX3NpemUpOworCQlpYTY0X3NybHpfaSgpOworCQlwID0gJl9f
cGVyX2NwdV9pZHRyc1tjcHVdWzFdW2ldOworCQlwLT5pZmEgPSB2YTsKKwkJcC0+cHRlID0gcHRl
OworCQlwLT5pdGlyID0gbG9nX3NpemUgPDwgMjsKKwkJcC0+cnIgPSBpYTY0X2dldF9ycih2YSk7
CisJfQorCWlhNjRfc2V0X3Bzcihwc3IpOworCXIgPSBpOworb3V0OgorCXJldHVybiByOworfQor
RVhQT1JUX1NZTUJPTF9HUEwoaWE2NF9pdHJfZW50cnkpOworCisvKgorICogaWE2NF9wdXJnZV90
cgorICoKKyAqIHRhcmdldF9tYXNrOiAweDE6IHB1cmdlIGl0ciwgMHgyIDogcHVyZ2UgZHRyLCAw
eDMgcHVyZ2UgaWR0ci4KKyAqIHNsb3Q6IHNsb3QgbnVtYmVyIHRvIGJlIGZyZWVkLgorICoKKyAq
IENhbGxlZCB3aXRoIHByZWVtcHRpb24gZGlzYWJsZWQuCisgKi8KK3ZvaWQgaWE2NF9wdHJfZW50
cnkodTY0IHRhcmdldF9tYXNrLCBpbnQgc2xvdCkKK3sKKwlpbnQgY3B1ID0gc21wX3Byb2Nlc3Nv
cl9pZCgpOworCWludCBpOworCXN0cnVjdCBpYTY0X3RyX2VudHJ5ICpwOworCisJaWYgKHNsb3Qg
PCBJQTY0X1RSX0FMTE9DX0JBU0UgfHwgc2xvdCA+PSBwZXJfY3B1KGlhNjRfdHJfbnVtLCBjcHUp
KQorCQlyZXR1cm47CisKKwlpZiAodGFyZ2V0X21hc2sgJiAweDEpIHsKKwkJcCA9ICZfX3Blcl9j
cHVfaWR0cnNbY3B1XVswXVtzbG90XTsKKwkJaWYgKChwLT5wdGUmMHgxKSAmJiBpc190cl9vdmVy
bGFwKHAsIHAtPmlmYSwgcC0+aXRpcj4+MikpIHsKKwkJCXAtPnB0ZSA9IDA7CisJCQlpYTY0X3B0
cigweDEsIHAtPmlmYSwgcC0+aXRpcj4+Mik7CisJCQlpYTY0X3NybHpfaSgpOworCQl9CisJfQor
CisJaWYgKHRhcmdldF9tYXNrICYgMHgyKSB7CisJCXAgPSAmX19wZXJfY3B1X2lkdHJzW2NwdV1b
MV1bc2xvdF07CisJCWlmICgocC0+cHRlICYgMHgxKSAmJiBpc190cl9vdmVybGFwKHAsIHAtPmlm
YSwgcC0+aXRpcj4+MikpIHsKKwkJCXAtPnB0ZSA9IDA7CisJCQlpYTY0X3B0cigweDIsIHAtPmlm
YSwgcC0+aXRpcj4+Mik7CisJCQlpYTY0X3NybHpfaSgpOworCQl9CisJfQorCisJZm9yIChpID0g
cGVyX2NwdShpYTY0X3RyX3VzZWQsIGNwdSk7IGkgPj0gSUE2NF9UUl9BTExPQ19CQVNFOyBpLS0p
IHsKKwkJaWYgKChfX3Blcl9jcHVfaWR0cnNbY3B1XVswXVtpXS5wdGUgJiAweDEpIHx8CisJCQkJ
KF9fcGVyX2NwdV9pZHRyc1tjcHVdWzFdW2ldLnB0ZSAmIDB4MSkpCisJCQlicmVhazsKKwl9CisJ
cGVyX2NwdShpYTY0X3RyX3VzZWQsIGNwdSkgPSBpOwogfQorRVhQT1JUX1NZTUJPTF9HUEwoaWE2
NF9wdHJfZW50cnkpOwpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9hc20taWE2NC9rcmVncy5oIGIvaW5j
bHVkZS9hc20taWE2NC9rcmVncy5oCmluZGV4IDdlNTVhNTguLmFlZmNkZmUgMTAwNjQ0Ci0tLSBh
L2luY2x1ZGUvYXNtLWlhNjQva3JlZ3MuaAorKysgYi9pbmNsdWRlL2FzbS1pYTY0L2tyZWdzLmgK
QEAgLTMxLDYgKzMxLDkgQEAKICNkZWZpbmUgSUE2NF9UUl9QQUxDT0RFCQkxCS8qIGl0cjE6IG1h
cHMgUEFMY29kZSBhcyByZXF1aXJlZCBieSBFRkkgKi8KICNkZWZpbmUgSUE2NF9UUl9DVVJSRU5U
X1NUQUNLCTEJLyogZHRyMTogbWFwcyBrZXJuZWwncyBtZW1vcnktICYgcmVnaXN0ZXItc3RhY2tz
ICovCiAKKyNkZWZpbmUgSUE2NF9UUl9BTExPQ19CQVNFCTIgCS8qIGl0ciZkdHI6IEJhc2Ugb2Yg
ZHluYW1pYyBUUiByZXNvdXJjZSovCisjZGVmaW5lIElBNjRfVFJfQUxMT0NfTUFYCTMyIAkvKiBN
YXggbnVtYmVyIGZvciBkeW5hbWljIHVzZSovCisKIC8qIFByb2Nlc3NvciBzdGF0dXMgcmVnaXN0
ZXIgYml0czogKi8KICNkZWZpbmUgSUE2NF9QU1JfQkVfQklUCQkxCiAjZGVmaW5lIElBNjRfUFNS
X1VQX0JJVAkJMgpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9hc20taWE2NC90bGIuaCBiL2luY2x1ZGUv
YXNtLWlhNjQvdGxiLmgKaW5kZXggMjZlZGNiNy4uMjBkOGEzOSAxMDA2NDQKLS0tIGEvaW5jbHVk
ZS9hc20taWE2NC90bGIuaAorKysgYi9pbmNsdWRlL2FzbS1pYTY0L3RsYi5oCkBAIC02NCw2ICs2
NCwzMiBAQCBzdHJ1Y3QgbW11X2dhdGhlciB7CiAJc3RydWN0IHBhZ2UgCQkqcGFnZXNbRlJFRV9Q
VEVfTlJdOwogfTsKIAorc3RydWN0IGlhNjRfdHJfZW50cnkgeworCXU2NCBpZmE7CisJdTY0IGl0
aXI7CisJdTY0IHB0ZTsKKwl1NjQgcnI7Cit9OyAvKlJlY29yZCBmb3IgdHIgZW50cnkhKi8KKwor
ZXh0ZXJuIGludCBpYTY0X2l0cl9lbnRyeSh1NjQgdGFyZ2V0X21hc2ssIHU2NCB2YSwgdTY0IHB0
ZSwgdTY0IGxvZ19zaXplKTsKK2V4dGVybiB2b2lkIGlhNjRfcHRyX2VudHJ5KHU2NCB0YXJnZXRf
bWFzaywgaW50IHNsb3QpOworCitleHRlcm4gc3RydWN0IGlhNjRfdHJfZW50cnkgX19wZXJfY3B1
X2lkdHJzW05SX0NQVVNdWzJdW0lBNjRfVFJfQUxMT0NfTUFYXTsKKworLyoKKyByZWdpb24gcmVn
aXN0ZXIgbWFjcm9zCisqLworI2RlZmluZSBSUl9UT19WRSh2YWwpICAgKCgodmFsKSA+PiAwKSAm
IDB4MDAwMDAwMDAwMDAwMDAwMSkKKyNkZWZpbmUgUlJfVkUodmFsKQkoKCh2YWwpICYgMHgwMDAw
MDAwMDAwMDAwMDAxKSA8PCAwKQorI2RlZmluZSBSUl9WRV9NQVNLCTB4MDAwMDAwMDAwMDAwMDAw
MUwKKyNkZWZpbmUgUlJfVkVfU0hJRlQJMAorI2RlZmluZSBSUl9UT19QUyh2YWwpCSgoKHZhbCkg
Pj4gMikgJiAweDAwMDAwMDAwMDAwMDAwM2YpCisjZGVmaW5lIFJSX1BTKHZhbCkJKCgodmFsKSAm
IDB4MDAwMDAwMDAwMDAwMDAzZikgPDwgMikKKyNkZWZpbmUgUlJfUFNfTUFTSwkweDAwMDAwMDAw
MDAwMDAwZmNMCisjZGVmaW5lIFJSX1BTX1NISUZUCTIKKyNkZWZpbmUgUlJfUklEX01BU0sJMHgw
MDAwMDAwMGZmZmZmZjAwTAorI2RlZmluZSBSUl9UT19SSUQodmFsKSAJKCh2YWwgPj4gOCkgJiAw
eGZmZmZmZikKKwogLyogVXNlcnMgb2YgdGhlIGdlbmVyaWMgVExCIHNob290ZG93biBjb2RlIG11
c3QgZGVjbGFyZSB0aGlzIHN0b3JhZ2Ugc3BhY2UuICovCiBERUNMQVJFX1BFUl9DUFUoc3RydWN0
IG1tdV9nYXRoZXIsIG1tdV9nYXRoZXJzKTsKIAotLSAKMS41LjIKCg==

------_=_NextPart_001_01C893E4.B25A98BB--
