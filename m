From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Sat, 29 Mar 2008 02:48:28 +0000
Subject: [01/17]PATCH  Add API for allocating dynamic TR resouce. V7
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCFF7F69@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C89147.5EA1508F"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EEE@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EEE@pdsmsx415.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C89147.5EA1508F
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

 From 1028321e00b0f3a60fc414484754f489a70f2400 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Sat, 29 Mar 2008 09:23:37 +0800
Subject: [PATCH] Add API for allocating Dynamic TR resouce.

Dynamic TR resouce should be managed in an uniform way.
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
Signed-off-by: Anthony Xu<anthony.xu@intel.com>
---
 arch/ia64/kernel/mca.c     |   49 +++++++++++
 arch/ia64/kernel/mca_asm.S |    5 +
 arch/ia64/mm/tlb.c         |  196
++++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/kregs.h   |    3 +
 include/asm-ia64/tlb.h     |   14 +++
 5 files changed, 267 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 6c18221..ee6924b 100644
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
+		if (p->pte&0x1) {
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
index 655da24..0b418cc 100644
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
@@ -206,4 +215,191 @@ ia64_tlb_init (void)
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
+	if (target_mask&0x1) {
+		p =3D &__per_cpu_idtrs[cpu][0][0];
+		for (i =3D IA64_TR_ALLOC_BASE; i < per_cpu(ia64_tr_used,
cpu);
+								i++,
p++) {
+			if (p->pte&0x1)
+				if (is_tr_overlap(p, va, log_size)) {
+					printk(KERN_DEBUG"Overlapped
Entry"
+						"Inserted for TR
Reigster!!");
+					goto out;
+			}
+		}
+	}
+	if (target_mask&0x2) {
+		p =3D &__per_cpu_idtrs[cpu][1][0];
+		for (i =3D IA64_TR_ALLOC_BASE; i < per_cpu(ia64_tr_used,
cpu);
+								i++,
p++) {
+			if (p->pte&0x1)
+				if (is_tr_overlap(p, va, log_size)) {
+					printk(KERN_DEBUG"Overlapped
Entry"
+						"Inserted for TR
Reigster!!");
+					goto out;
+				}
+		}
+	}
+
+	for (i =3D IA64_TR_ALLOC_BASE; i < per_cpu(ia64_tr_num, cpu); i++)
{
+		switch (target_mask & 0x3) {
+		case 1:
+			if (!(__per_cpu_idtrs[cpu][0][i].pte&0x1))
+				goto found;
+			continue;
+		case 2:
+			if (!(__per_cpu_idtrs[cpu][1][i].pte&0x1))
+				goto found;
+			continue;
+		case 3:
+			if (!(__per_cpu_idtrs[cpu][0][i].pte&0x1) &&
+				!(__per_cpu_idtrs[cpu][1][i].pte&0x1))
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
+ *
+ * slot: slot number to be freed.
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
+	if (target_mask&0x1) {
+		p =3D &__per_cpu_idtrs[cpu][0][slot];
+		if ((p->pte&0x1) && is_tr_overlap(p, p->ifa,
p->itir>>2)) {
+			p->pte =3D 0;
+			ia64_ptr(0x1, p->ifa, p->itir>>2);
+			ia64_srlz_i();
+		}
+	}
+
+	if (target_mask&0x2) {
+		p =3D &__per_cpu_idtrs[cpu][1][slot];
+		if ((p->pte&0x1) && is_tr_overlap(p, p->ifa,
p->itir>>2)) {
+			p->pte =3D 0;
+			ia64_ptr(0x2, p->ifa, p->itir>>2);
+			ia64_srlz_i();
+		}
+	}
+
+	for (i =3D per_cpu(ia64_tr_used, cpu) - 1; i >=3D
IA64_TR_ALLOC_BASE; i--) {
+		if ((__per_cpu_idtrs[cpu][0][i].pte&0x1) ||
+				(__per_cpu_idtrs[cpu][1][i].pte&0x1))
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
index 26edcb7..de1f829 100644
--- a/include/asm-ia64/tlb.h
+++ b/include/asm-ia64/tlb.h
@@ -64,6 +64,20 @@ struct mmu_gather {
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
+#define RR_TO_RID(rr) ((rr)<<32>>40)
+
 /* Users of the generic TLB shootdown code must declare this storage
space. */
 DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
=20
--=20
1.5.2

------_=_NextPart_001_01C89147.5EA1508F
Content-Type: application/octet-stream;
	name="0001-Add-API-for-allocating-Dynamic-TR-resouce.patch"
Content-Transfer-Encoding: base64
Content-Description: 0001-Add-API-for-allocating-Dynamic-TR-resouce.patch
Content-Disposition: attachment;
	filename="0001-Add-API-for-allocating-Dynamic-TR-resouce.patch"

RnJvbSAxMDI4MzIxZTAwYjBmM2E2MGZjNDE0NDg0NzU0ZjQ4OWE3MGYyNDAwIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogU2F0LCAyOSBNYXIgMjAwOCAwOToyMzozNyArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEFkZCBBUEkgZm9yIGFsbG9jYXRpbmcgRHluYW1pYyBUUiByZXNvdWNlLgoKRHluYW1pYyBUUiBy
ZXNvdWNlIHNob3VsZCBiZSBtYW5hZ2VkIGluIGFuIHVuaWZvcm0gd2F5LgpTaWduZWQtb2ZmLWJ5
OiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNvbT4KU2lnbmVkLW9mZi1ieTog
QW50aG9ueSBYdTxhbnRob255Lnh1QGludGVsLmNvbT4KLS0tCiBhcmNoL2lhNjQva2VybmVsL21j
YS5jICAgICB8ICAgNDkgKysrKysrKysrKysKIGFyY2gvaWE2NC9rZXJuZWwvbWNhX2FzbS5TIHwg
ICAgNSArCiBhcmNoL2lhNjQvbW0vdGxiLmMgICAgICAgICB8ICAxOTYgKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysKIGluY2x1ZGUvYXNtLWlhNjQva3JlZ3MuaCAg
IHwgICAgMyArCiBpbmNsdWRlL2FzbS1pYTY0L3RsYi5oICAgICB8ICAgMTQgKysrCiA1IGZpbGVz
IGNoYW5nZWQsIDI2NyBpbnNlcnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBh
L2FyY2gvaWE2NC9rZXJuZWwvbWNhLmMgYi9hcmNoL2lhNjQva2VybmVsL21jYS5jCmluZGV4IDZj
MTgyMjEuLmVlNjkyNGIgMTAwNjQ0Ci0tLSBhL2FyY2gvaWE2NC9rZXJuZWwvbWNhLmMKKysrIGIv
YXJjaC9pYTY0L2tlcm5lbC9tY2EuYwpAQCAtOTcsNiArOTcsNyBAQAogCiAjaW5jbHVkZSA8YXNt
L2lycS5oPgogI2luY2x1ZGUgPGFzbS9od19pcnEuaD4KKyNpbmNsdWRlIDxhc20vdGxiLmg+CiAK
ICNpbmNsdWRlICJtY2FfZHJ2LmgiCiAjaW5jbHVkZSAiZW50cnkuaCIKQEAgLTExMiw2ICsxMTMs
NyBAQCBERUZJTkVfUEVSX0NQVSh1NjQsIGlhNjRfbWNhX2RhdGEpOyAvKiA9PSBfX3Blcl9jcHVf
bWNhW3NtcF9wcm9jZXNzb3JfaWQoKV0gKi8KIERFRklORV9QRVJfQ1BVKHU2NCwgaWE2NF9tY2Ff
cGVyX2NwdV9wdGUpOyAvKiBQVEUgdG8gbWFwIHBlci1DUFUgYXJlYSAqLwogREVGSU5FX1BFUl9D
UFUodTY0LCBpYTY0X21jYV9wYWxfcHRlKTsJICAgIC8qIFBURSB0byBtYXAgUEFMIGNvZGUgKi8K
IERFRklORV9QRVJfQ1BVKHU2NCwgaWE2NF9tY2FfcGFsX2Jhc2UpOyAgICAvKiB2YWRkciBQQUwg
Y29kZSBncmFudWxlICovCitERUZJTkVfUEVSX0NQVSh1NjQsIGlhNjRfbWNhX3RyX3JlbG9hZCk7
ICAgLyogRmxhZyBmb3IgVFIgcmVsb2FkICovCiAKIHVuc2lnbmVkIGxvbmcgX19wZXJfY3B1X21j
YVtOUl9DUFVTXTsKIApAQCAtMTE4Miw2ICsxMTg0LDQ5IEBAIGFsbF9pbjoKIAlyZXR1cm47CiB9
CiAKKy8qICBtY2FfaW5zZXJ0X3RyCisgKgorICogIFN3aXRjaCByaWQgd2hlbiBUUiByZWxvYWQg
YW5kIG5lZWRlZCEKKyAqICBpb3JkOiAxOiBpdHIsIDI6IGl0cjsKKyAqCisqLworc3RhdGljIHZv
aWQgbWNhX2luc2VydF90cih1NjQgaW9yZCkKK3sKKworCWludCBpOworCXU2NCBvbGRfcnI7CisJ
c3RydWN0IGlhNjRfdHJfZW50cnkgKnA7CisJdW5zaWduZWQgbG9uZyBwc3I7CisJaW50IGNwdSA9
IHNtcF9wcm9jZXNzb3JfaWQoKTsKKworCXBzciA9IGlhNjRfY2xlYXJfaWMoKTsKKwlmb3IgKGkg
PSBJQTY0X1RSX0FMTE9DX0JBU0U7IGkgPCBJQTY0X1RSX0FMTE9DX01BWDsgaSsrKSB7CisJCXAg
PSAmX19wZXJfY3B1X2lkdHJzW2NwdV1baW9yZC0xXVtpXTsKKwkJaWYgKHAtPnB0ZSYweDEpIHsK
KwkJCW9sZF9yciA9IGlhNjRfZ2V0X3JyKHAtPmlmYSk7CisJCQlpZiAob2xkX3JyICE9IHAtPnJy
KSB7CisJCQkJaWE2NF9zZXRfcnIocC0+aWZhLCBwLT5ycik7CisJCQkJaWE2NF9zcmx6X2QoKTsK
KwkJCX0KKwkJCWlhNjRfcHRyKGlvcmQsIHAtPmlmYSwgcC0+aXRpciA+PiAyKTsKKwkJCWlhNjRf
c3Jsel9pKCk7CisJCQlpZiAoaW9yZCAmIDB4MSkgeworCQkJCWlhNjRfaXRyKDB4MSwgaSwgcC0+
aWZhLCBwLT5wdGUsIHAtPml0aXIgPj4gMik7CisJCQkJaWE2NF9zcmx6X2koKTsKKwkJCX0KKwkJ
CWlmIChpb3JkICYgMHgyKSB7CisJCQkJaWE2NF9pdHIoMHgyLCBpLCBwLT5pZmEsIHAtPnB0ZSwg
cC0+aXRpciA+PiAyKTsKKwkJCQlpYTY0X3NybHpfaSgpOworCQkJfQorCQkJaWYgKG9sZF9yciAh
PSBwLT5ycikgeworCQkJCWlhNjRfc2V0X3JyKHAtPmlmYSwgb2xkX3JyKTsKKwkJCQlpYTY0X3Ny
bHpfZCgpOworCQkJfQorCQl9CisJfQorCWlhNjRfc2V0X3Bzcihwc3IpOworfQorCiAvKgogICog
aWE2NF9tY2FfaGFuZGxlcgogICoKQEAgLTEyNzEsNiArMTMxNiwxMCBAQCBpYTY0X21jYV9oYW5k
bGVyKHN0cnVjdCBwdF9yZWdzICpyZWdzLCBzdHJ1Y3Qgc3dpdGNoX3N0YWNrICpzdywKIAkJbW9u
YXJjaF9jcHUgPSAtMTsKICNlbmRpZgogCX0KKwlpZiAoX19nZXRfY3B1X3ZhcihpYTY0X21jYV90
cl9yZWxvYWQpKSB7CisJCW1jYV9pbnNlcnRfdHIoMHgxKTsgLypSZWxvYWQgZHluYW1pYyBpdHJz
Ki8KKwkJbWNhX2luc2VydF90cigweDIpOyAvKlJlbG9hZCBkeW5hbWljIGl0cnMqLworCX0KIAlp
ZiAobm90aWZ5X2RpZShESUVfTUNBX01PTkFSQ0hfTEVBVkUsICJNQ0EiLCByZWdzLCAobG9uZykm
bmQsIDAsIHJlY292ZXIpCiAJCQk9PSBOT1RJRllfU1RPUCkKIAkJaWE2NF9tY2Ffc3BpbihfX2Z1
bmNfXyk7CmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva2VybmVsL21jYV9hc20uUyBiL2FyY2gvaWE2
NC9rZXJuZWwvbWNhX2FzbS5TCmluZGV4IDhiYzdkMjUuLmEwNmQ0NjUgMTAwNjQ0Ci0tLSBhL2Fy
Y2gvaWE2NC9rZXJuZWwvbWNhX2FzbS5TCisrKyBiL2FyY2gvaWE2NC9rZXJuZWwvbWNhX2FzbS5T
CkBAIC0yMTksOCArMjE5LDEzIEBAIGlhNjRfcmVsb2FkX3RyOgogCW1vdiByMjA9SUE2NF9UUl9D
VVJSRU5UX1NUQUNLCiAJOzsKIAlpdHIuZCBkdHJbcjIwXT1yMTYKKwlHRVRfVEhJU19QQUREUihy
MiwgaWE2NF9tY2FfdHJfcmVsb2FkKQorCW1vdiByMTggPSAxCiAJOzsKIAlzcmx6LmQKKwk7Owor
CXN0OCBbcjJdID1yMTgKKwk7OwogCiBkb25lX3RsYl9wdXJnZV9hbmRfcmVsb2FkOgogCmRpZmYg
LS1naXQgYS9hcmNoL2lhNjQvbW0vdGxiLmMgYi9hcmNoL2lhNjQvbW0vdGxiLmMKaW5kZXggNjU1
ZGEyNC4uMGI0MThjYyAxMDA2NDQKLS0tIGEvYXJjaC9pYTY0L21tL3RsYi5jCisrKyBiL2FyY2gv
aWE2NC9tbS90bGIuYwpAQCAtMjYsNiArMjYsOCBAQAogI2luY2x1ZGUgPGFzbS9wYWwuaD4KICNp
bmNsdWRlIDxhc20vdGxiZmx1c2guaD4KICNpbmNsdWRlIDxhc20vZG1hLmg+CisjaW5jbHVkZSA8
YXNtL3Byb2Nlc3Nvci5oPgorI2luY2x1ZGUgPGFzbS90bGIuaD4KIAogc3RhdGljIHN0cnVjdCB7
CiAJdW5zaWduZWQgbG9uZyBtYXNrOwkvKiBtYXNrIG9mIHN1cHBvcnRlZCBwdXJnZSBwYWdlLXNp
emVzICovCkBAIC0zOSw2ICs0MSwxMCBAQCBzdHJ1Y3QgaWE2NF9jdHggaWE2NF9jdHggPSB7CiB9
OwogCiBERUZJTkVfUEVSX0NQVSh1OCwgaWE2NF9uZWVkX3RsYl9mbHVzaCk7CitERUZJTkVfUEVS
X0NQVSh1OCwgaWE2NF90cl9udW0pOyAgLypOdW1iZXIgb2YgVFIgc2xvdHMgaW4gY3VycmVudCBw
cm9jZXNzb3IqLworREVGSU5FX1BFUl9DUFUodTgsIGlhNjRfdHJfdXNlZCk7IC8qTWF4IFNsb3Qg
bnVtYmVyIHVzZWQgYnkga2VybmVsKi8KKworc3RydWN0IGlhNjRfdHJfZW50cnkgX19wZXJfY3B1
X2lkdHJzW05SX0NQVVNdWzJdW0lBNjRfVFJfQUxMT0NfTUFYXTsKIAogLyoKICAqIEluaXRpYWxp
emVzIHRoZSBpYTY0X2N0eC5iaXRtYXAgYXJyYXkgYmFzZWQgb24gbWF4X2N0eCsxLgpAQCAtMTkw
LDYgKzE5Niw5IEBAIGlhNjRfdGxiX2luaXQgKHZvaWQpCiAJaWE2NF9wdGNlX2luZm9fdCB1bmlu
aXRpYWxpemVkX3ZhcihwdGNlX2luZm8pOyAvKiBHQ0MgYmUgcXVpZXQgKi8KIAl1bnNpZ25lZCBs
b25nIHRyX3BnYml0czsKIAlsb25nIHN0YXR1czsKKwlwYWxfdm1faW5mb18xX3VfdCB2bV9pbmZv
XzE7CisJcGFsX3ZtX2luZm9fMl91X3Qgdm1faW5mb18yOworCWludCBjcHUgPSBzbXBfcHJvY2Vz
c29yX2lkKCk7CiAKIAlpZiAoKHN0YXR1cyA9IGlhNjRfcGFsX3ZtX3BhZ2Vfc2l6ZSgmdHJfcGdi
aXRzLCAmcHVyZ2UubWFzaykpICE9IDApIHsKIAkJcHJpbnRrKEtFUk5fRVJSICJQQUxfVk1fUEFH
RV9TSVpFIGZhaWxlZCB3aXRoIHN0YXR1cz0lbGQ7ICIKQEAgLTIwNiw0ICsyMTUsMTkxIEBAIGlh
NjRfdGxiX2luaXQgKHZvaWQpCiAJbG9jYWxfY3B1X2RhdGEtPnB0Y2Vfc3RyaWRlWzFdID0gcHRj
ZV9pbmZvLnN0cmlkZVsxXTsKIAogCWxvY2FsX2ZsdXNoX3RsYl9hbGwoKTsJLyogbnVrZSBsZWZ0
IG92ZXJzIGZyb20gYm9vdHN0cmFwcGluZy4uLiAqLworCXN0YXR1cyA9IGlhNjRfcGFsX3ZtX3N1
bW1hcnkoJnZtX2luZm9fMSwgJnZtX2luZm9fMik7CisKKwlpZiAoc3RhdHVzKSB7CisJCXByaW50
ayhLRVJOX0VSUiAiaWE2NF9wYWxfdm1fc3VtbWFyeT0lbGRcbiIsIHN0YXR1cyk7CisJCXBlcl9j
cHUoaWE2NF90cl9udW0sIGNwdSkgPSA4OworCQlyZXR1cm47CisJfQorCXBlcl9jcHUoaWE2NF90
cl9udW0sIGNwdSkgPSB2bV9pbmZvXzEucGFsX3ZtX2luZm9fMV9zLm1heF9pdHJfZW50cnkrMTsK
KwlpZiAocGVyX2NwdShpYTY0X3RyX251bSwgY3B1KSA+CisJCQkJKHZtX2luZm9fMS5wYWxfdm1f
aW5mb18xX3MubWF4X2R0cl9lbnRyeSsxKSkKKwkJcGVyX2NwdShpYTY0X3RyX251bSwgY3B1KSA9
CisJCQkJdm1faW5mb18xLnBhbF92bV9pbmZvXzFfcy5tYXhfZHRyX2VudHJ5KzE7CisJaWYgKHBl
cl9jcHUoaWE2NF90cl9udW0sIGNwdSkgPiBJQTY0X1RSX0FMTE9DX01BWCkgeworCQlwZXJfY3B1
KGlhNjRfdHJfbnVtLCBjcHUpID0gSUE2NF9UUl9BTExPQ19NQVg7CisJCXByaW50ayhLRVJOX0RF
QlVHIlRSIHJlZ2lzdGVyIG51bWJlciBleGNlZWRzIElBNjRfVFJfQUxMT0NfTUFYISIKKwkJCSJJ
QTY0X1RSX0FMTE9DX01BWCBzaG91bGQgYmUgZXh0ZW5kZWRcbiIpOworCX0KK30KKworLyoKKyAq
IGlzX3RyX292ZXJsYXAKKyAqCisgKiBDaGVjayBvdmVybGFwIHdpdGggaW5zZXJ0ZWQgVFJzLgor
ICovCitzdGF0aWMgaW50IGlzX3RyX292ZXJsYXAoc3RydWN0IGlhNjRfdHJfZW50cnkgKnAsIHU2
NCB2YSwgdTY0IGxvZ19zaXplKQoreworCXU2NCB0cl9sb2dfc2l6ZTsKKwl1NjQgdHJfZW5kOwor
CXU2NCB2YV9yciA9IGlhNjRfZ2V0X3JyKHZhKTsKKwl1NjQgdmFfcmlkID0gUlJfVE9fUklEKHZh
X3JyKTsKKwl1NjQgdmFfZW5kID0gdmEgKyAoMTw8bG9nX3NpemUpIC0gMTsKKworCWlmICh2YV9y
aWQgIT0gUlJfVE9fUklEKHAtPnJyKSkKKwkJcmV0dXJuIDA7CisJdHJfbG9nX3NpemUgPSAocC0+
aXRpciAmIDB4ZmYpID4+IDI7CisJdHJfZW5kID0gcC0+aWZhICsgKDE8PHRyX2xvZ19zaXplKSAt
IDE7CisKKwlpZiAodmEgPiB0cl9lbmQgfHwgcC0+aWZhID4gdmFfZW5kKQorCQlyZXR1cm4gMDsK
KwlyZXR1cm4gMTsKKworfQorCisvKgorICogaWE2NF9pbnNlcnRfdHIgaW4gdmlydHVhbCBtb2Rl
LiBBbGxvY2F0ZSBhIFRSIHNsb3QKKyAqCisgKiB0YXJnZXRfbWFzayA6IDB4MSA6IGl0ciwgMHgy
IDogZHRyLCAweDMgOiBpZHRyCisgKgorICogdmEgCTogdmlydHVhbCBhZGRyZXNzLgorICogcHRl
IAk6IHB0ZSBlbnRyaWVzIGluc2VydGVkLgorICogbG9nX3NpemU6IHJhbmdlIHRvIGJlIGNvdmVy
ZWQuCisgKgorICogUmV0dXJuIHZhbHVlOiAgPDAgOiAgZXJyb3IgTm8uCisgKgorICoJCSAgPj0w
IDogc2xvdCBudW1iZXIgYWxsb2NhdGVkIGZvciBUUi4KKyAqLworaW50IGlhNjRfaXRyX2VudHJ5
KHU2NCB0YXJnZXRfbWFzaywgdTY0IHZhLCB1NjQgcHRlLCB1NjQgbG9nX3NpemUpCit7CisJaW50
IGksIHI7CisJdW5zaWduZWQgbG9uZyBwc3I7CisJc3RydWN0IGlhNjRfdHJfZW50cnkgKnA7CisJ
aW50IGNwdSA9IHNtcF9wcm9jZXNzb3JfaWQoKTsKKworCXIgPSAtRUlOVkFMOworCS8qQ2hlY2sg
b3ZlcmxhcCB3aXRoIGV4aXN0aW5nIFRSIGVudHJpZXMqLworCWlmICh0YXJnZXRfbWFzayYweDEp
IHsKKwkJcCA9ICZfX3Blcl9jcHVfaWR0cnNbY3B1XVswXVswXTsKKwkJZm9yIChpID0gSUE2NF9U
Ul9BTExPQ19CQVNFOyBpIDwgcGVyX2NwdShpYTY0X3RyX3VzZWQsIGNwdSk7CisJCQkJCQkJCWkr
KywgcCsrKSB7CisJCQlpZiAocC0+cHRlJjB4MSkKKwkJCQlpZiAoaXNfdHJfb3ZlcmxhcChwLCB2
YSwgbG9nX3NpemUpKSB7CisJCQkJCXByaW50ayhLRVJOX0RFQlVHIk92ZXJsYXBwZWQgRW50cnki
CisJCQkJCQkiSW5zZXJ0ZWQgZm9yIFRSIFJlaWdzdGVyISEiKTsKKwkJCQkJZ290byBvdXQ7CisJ
CQl9CisJCX0KKwl9CisJaWYgKHRhcmdldF9tYXNrJjB4MikgeworCQlwID0gJl9fcGVyX2NwdV9p
ZHRyc1tjcHVdWzFdWzBdOworCQlmb3IgKGkgPSBJQTY0X1RSX0FMTE9DX0JBU0U7IGkgPCBwZXJf
Y3B1KGlhNjRfdHJfdXNlZCwgY3B1KTsKKwkJCQkJCQkJaSsrLCBwKyspIHsKKwkJCWlmIChwLT5w
dGUmMHgxKQorCQkJCWlmIChpc190cl9vdmVybGFwKHAsIHZhLCBsb2dfc2l6ZSkpIHsKKwkJCQkJ
cHJpbnRrKEtFUk5fREVCVUciT3ZlcmxhcHBlZCBFbnRyeSIKKwkJCQkJCSJJbnNlcnRlZCBmb3Ig
VFIgUmVpZ3N0ZXIhISIpOworCQkJCQlnb3RvIG91dDsKKwkJCQl9CisJCX0KKwl9CisKKwlmb3Ig
KGkgPSBJQTY0X1RSX0FMTE9DX0JBU0U7IGkgPCBwZXJfY3B1KGlhNjRfdHJfbnVtLCBjcHUpOyBp
KyspIHsKKwkJc3dpdGNoICh0YXJnZXRfbWFzayAmIDB4MykgeworCQljYXNlIDE6CisJCQlpZiAo
IShfX3Blcl9jcHVfaWR0cnNbY3B1XVswXVtpXS5wdGUmMHgxKSkKKwkJCQlnb3RvIGZvdW5kOwor
CQkJY29udGludWU7CisJCWNhc2UgMjoKKwkJCWlmICghKF9fcGVyX2NwdV9pZHRyc1tjcHVdWzFd
W2ldLnB0ZSYweDEpKQorCQkJCWdvdG8gZm91bmQ7CisJCQljb250aW51ZTsKKwkJY2FzZSAzOgor
CQkJaWYgKCEoX19wZXJfY3B1X2lkdHJzW2NwdV1bMF1baV0ucHRlJjB4MSkgJiYKKwkJCQkhKF9f
cGVyX2NwdV9pZHRyc1tjcHVdWzFdW2ldLnB0ZSYweDEpKQorCQkJCWdvdG8gZm91bmQ7CisJCQlj
b250aW51ZTsKKwkJZGVmYXVsdDoKKwkJCXIgPSAtRUlOVkFMOworCQkJZ290byBvdXQ7CisJCX0K
Kwl9Citmb3VuZDoKKwlpZiAoaSA+PSBwZXJfY3B1KGlhNjRfdHJfbnVtLCBjcHUpKSB7CisJCXIg
PSAtRUJVU1k7CisJCWdvdG8gb3V0OworCX0KKworCS8qUmVjb3JkIHRyIGluZm8gZm9yIG1jYSBo
YW5kZXIgdXNlISovCisJaWYgKGkgPiBwZXJfY3B1KGlhNjRfdHJfdXNlZCwgY3B1KSkKKwkJcGVy
X2NwdShpYTY0X3RyX3VzZWQsIGNwdSkgPSBpOworCisJcHNyID0gaWE2NF9jbGVhcl9pYygpOwor
CWlmICh0YXJnZXRfbWFzayAmIDB4MSkgeworCQlpYTY0X2l0cigweDEsIGksIHZhLCBwdGUsIGxv
Z19zaXplKTsKKwkJaWE2NF9zcmx6X2koKTsKKwkJcCA9ICZfX3Blcl9jcHVfaWR0cnNbY3B1XVsw
XVtpXTsKKwkJcC0+aWZhID0gdmE7CisJCXAtPnB0ZSA9IHB0ZTsKKwkJcC0+aXRpciA9IGxvZ19z
aXplIDw8IDI7CisJCXAtPnJyID0gaWE2NF9nZXRfcnIodmEpOworCX0KKwlpZiAodGFyZ2V0X21h
c2sgJiAweDIpIHsKKwkJaWE2NF9pdHIoMHgyLCBpLCB2YSwgcHRlLCBsb2dfc2l6ZSk7CisJCWlh
NjRfc3Jsel9pKCk7CisJCXAgPSAmX19wZXJfY3B1X2lkdHJzW2NwdV1bMV1baV07CisJCXAtPmlm
YSA9IHZhOworCQlwLT5wdGUgPSBwdGU7CisJCXAtPml0aXIgPSBsb2dfc2l6ZSA8PCAyOworCQlw
LT5yciA9IGlhNjRfZ2V0X3JyKHZhKTsKKwl9CisJaWE2NF9zZXRfcHNyKHBzcik7CisJciA9IGk7
CitvdXQ6CisJcmV0dXJuIHI7Cit9CitFWFBPUlRfU1lNQk9MX0dQTChpYTY0X2l0cl9lbnRyeSk7
CisKKy8qCisgKiBpYTY0X3B1cmdlX3RyCisgKgorICogdGFyZ2V0X21hc2s6IDB4MTogcHVyZ2Ug
aXRyLCAweDIgOiBwdXJnZSBkdHIsIDB4MyBwdXJnZSBpZHRyLgorICoKKyAqIHNsb3Q6IHNsb3Qg
bnVtYmVyIHRvIGJlIGZyZWVkLgorICovCit2b2lkIGlhNjRfcHRyX2VudHJ5KHU2NCB0YXJnZXRf
bWFzaywgaW50IHNsb3QpCit7CisJaW50IGNwdSA9IHNtcF9wcm9jZXNzb3JfaWQoKTsKKwlpbnQg
aTsKKwlzdHJ1Y3QgaWE2NF90cl9lbnRyeSAqcDsKKworCWlmIChzbG90IDwgSUE2NF9UUl9BTExP
Q19CQVNFIHx8IHNsb3QgPj0gcGVyX2NwdShpYTY0X3RyX251bSwgY3B1KSkKKwkJcmV0dXJuOwor
CisJaWYgKHRhcmdldF9tYXNrJjB4MSkgeworCQlwID0gJl9fcGVyX2NwdV9pZHRyc1tjcHVdWzBd
W3Nsb3RdOworCQlpZiAoKHAtPnB0ZSYweDEpICYmIGlzX3RyX292ZXJsYXAocCwgcC0+aWZhLCBw
LT5pdGlyPj4yKSkgeworCQkJcC0+cHRlID0gMDsKKwkJCWlhNjRfcHRyKDB4MSwgcC0+aWZhLCBw
LT5pdGlyPj4yKTsKKwkJCWlhNjRfc3Jsel9pKCk7CisJCX0KKwl9CisKKwlpZiAodGFyZ2V0X21h
c2smMHgyKSB7CisJCXAgPSAmX19wZXJfY3B1X2lkdHJzW2NwdV1bMV1bc2xvdF07CisJCWlmICgo
cC0+cHRlJjB4MSkgJiYgaXNfdHJfb3ZlcmxhcChwLCBwLT5pZmEsIHAtPml0aXI+PjIpKSB7CisJ
CQlwLT5wdGUgPSAwOworCQkJaWE2NF9wdHIoMHgyLCBwLT5pZmEsIHAtPml0aXI+PjIpOworCQkJ
aWE2NF9zcmx6X2koKTsKKwkJfQorCX0KKworCWZvciAoaSA9IHBlcl9jcHUoaWE2NF90cl91c2Vk
LCBjcHUpIC0gMTsgaSA+PSBJQTY0X1RSX0FMTE9DX0JBU0U7IGktLSkgeworCQlpZiAoKF9fcGVy
X2NwdV9pZHRyc1tjcHVdWzBdW2ldLnB0ZSYweDEpIHx8CisJCQkJKF9fcGVyX2NwdV9pZHRyc1tj
cHVdWzFdW2ldLnB0ZSYweDEpKQorCQkJYnJlYWs7CisJfQorCXBlcl9jcHUoaWE2NF90cl91c2Vk
LCBjcHUpID0gaTsKIH0KK0VYUE9SVF9TWU1CT0xfR1BMKGlhNjRfcHRyX2VudHJ5KTsKZGlmZiAt
LWdpdCBhL2luY2x1ZGUvYXNtLWlhNjQva3JlZ3MuaCBiL2luY2x1ZGUvYXNtLWlhNjQva3JlZ3Mu
aAppbmRleCA3ZTU1YTU4Li5hZWZjZGZlIDEwMDY0NAotLS0gYS9pbmNsdWRlL2FzbS1pYTY0L2ty
ZWdzLmgKKysrIGIvaW5jbHVkZS9hc20taWE2NC9rcmVncy5oCkBAIC0zMSw2ICszMSw5IEBACiAj
ZGVmaW5lIElBNjRfVFJfUEFMQ09ERQkJMQkvKiBpdHIxOiBtYXBzIFBBTGNvZGUgYXMgcmVxdWly
ZWQgYnkgRUZJICovCiAjZGVmaW5lIElBNjRfVFJfQ1VSUkVOVF9TVEFDSwkxCS8qIGR0cjE6IG1h
cHMga2VybmVsJ3MgbWVtb3J5LSAmIHJlZ2lzdGVyLXN0YWNrcyAqLwogCisjZGVmaW5lIElBNjRf
VFJfQUxMT0NfQkFTRQkyIAkvKiBpdHImZHRyOiBCYXNlIG9mIGR5bmFtaWMgVFIgcmVzb3VyY2Uq
LworI2RlZmluZSBJQTY0X1RSX0FMTE9DX01BWAkzMiAJLyogTWF4IG51bWJlciBmb3IgZHluYW1p
YyB1c2UqLworCiAvKiBQcm9jZXNzb3Igc3RhdHVzIHJlZ2lzdGVyIGJpdHM6ICovCiAjZGVmaW5l
IElBNjRfUFNSX0JFX0JJVAkJMQogI2RlZmluZSBJQTY0X1BTUl9VUF9CSVQJCTIKZGlmZiAtLWdp
dCBhL2luY2x1ZGUvYXNtLWlhNjQvdGxiLmggYi9pbmNsdWRlL2FzbS1pYTY0L3RsYi5oCmluZGV4
IDI2ZWRjYjcuLmRlMWY4MjkgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvYXNtLWlhNjQvdGxiLmgKKysr
IGIvaW5jbHVkZS9hc20taWE2NC90bGIuaApAQCAtNjQsNiArNjQsMjAgQEAgc3RydWN0IG1tdV9n
YXRoZXIgewogCXN0cnVjdCBwYWdlIAkJKnBhZ2VzW0ZSRUVfUFRFX05SXTsKIH07CiAKK3N0cnVj
dCBpYTY0X3RyX2VudHJ5IHsKKwl1NjQgaWZhOworCXU2NCBpdGlyOworCXU2NCBwdGU7CisJdTY0
IHJyOworfTsgLypSZWNvcmQgZm9yIHRyIGVudHJ5ISovCisKK2V4dGVybiBpbnQgaWE2NF9pdHJf
ZW50cnkodTY0IHRhcmdldF9tYXNrLCB1NjQgdmEsIHU2NCBwdGUsIHU2NCBsb2dfc2l6ZSk7Citl
eHRlcm4gdm9pZCBpYTY0X3B0cl9lbnRyeSh1NjQgdGFyZ2V0X21hc2ssIGludCBzbG90KTsKKwor
ZXh0ZXJuIHN0cnVjdCBpYTY0X3RyX2VudHJ5IF9fcGVyX2NwdV9pZHRyc1tOUl9DUFVTXVsyXVtJ
QTY0X1RSX0FMTE9DX01BWF07CisKKyNkZWZpbmUgUlJfVE9fUklEKHJyKSAoKHJyKTw8MzI+PjQw
KQorCiAvKiBVc2VycyBvZiB0aGUgZ2VuZXJpYyBUTEIgc2hvb3Rkb3duIGNvZGUgbXVzdCBkZWNs
YXJlIHRoaXMgc3RvcmFnZSBzcGFjZS4gKi8KIERFQ0xBUkVfUEVSX0NQVShzdHJ1Y3QgbW11X2dh
dGhlciwgbW11X2dhdGhlcnMpOwogCi0tIAoxLjUuMgoK

------_=_NextPart_001_01C89147.5EA1508F--
