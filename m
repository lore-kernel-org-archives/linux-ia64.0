From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Fri, 28 Mar 2008 09:58:02 +0000
Subject: [01/17]PATCH  Add API for allocating dynamic TR resouce.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCFF7EEE@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C890BA.3624FB23"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Jes Sorensen <jes@sgi.com>, Akio Takebe <takebe_akio@jp.fujitsu.com>, 

This is a multi-part message in MIME format.

------_=_NextPart_001_01C890BA.3624FB23
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Refined according to Tony's comments.=20

From 837f0508a617ea0386808de9fd0f42ef4aefe5e0 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Thu, 27 Mar 2008 10:18:29 +0800
Subject: [PATCH] Add API for allocating TR resouce.

Dynamic TR resouce should be managed in an uniform way.
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
Signed-off-by: Anthony Xu<anthony.xu@intel.com>
---
 arch/ia64/kernel/mca.c     |   50 +++++++++++++
 arch/ia64/kernel/mca_asm.S |    5 ++
 arch/ia64/mm/tlb.c         |  170
++++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/kregs.h   |    3 +
 include/asm-ia64/tlb.h     |   12 +++
 5 files changed, 240 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 6c18221..51d0c26 100644
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
@@ -112,8 +113,10 @@ DEFINE_PER_CPU(u64, ia64_mca_data); /* =3D=3D
__per_cpu_mca[smp_processor_id()] */
 DEFINE_PER_CPU(u64, ia64_mca_per_cpu_pte); /* PTE to map per-CPU area
*/
 DEFINE_PER_CPU(u64, ia64_mca_pal_pte);	    /* PTE to map PAL code */
 DEFINE_PER_CPU(u64, ia64_mca_pal_base);    /* vaddr PAL code granule */
+DEFINE_PER_CPU(u64, ia64_mca_tr_reload);   /* Flag for TR reload */
=20
 unsigned long __per_cpu_mca[NR_CPUS];
+extern struct ia64_tr_entry
__per_cpu_idtrs[NR_CPUS][2][IA64_TR_ALLOC_MAX];
=20
 /* In mca_asm.S */
 extern void			ia64_os_init_dispatch_monarch (void);
@@ -1182,6 +1185,49 @@ all_in:
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
@@ -1271,6 +1317,10 @@ ia64_mca_handler(struct pt_regs *regs, struct
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
index 655da24..d7f8206 100644
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
@@ -206,4 +215,165 @@ ia64_tlb_init (void)
 	local_cpu_data->ptce_stride[1] =3D ptce_info.stride[1];
=20
 	local_flush_tlb_all();	/* nuke left overs from bootstrapping...
*/
+
+	if ((status =3D ia64_pal_vm_summary(&vm_info_1, &vm_info_2)) !=3D 0)
{
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
vm_info_1.pal_vm_info_1_s.max_dtr_entry+1;
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
+				if (is_tr_overlap(p, va, log_size))
+					goto out;
+		}
+	}
+	if (target_mask&0x2) {
+		p =3D &__per_cpu_idtrs[cpu][1][0];
+		for (i =3D IA64_TR_ALLOC_BASE; i < per_cpu(ia64_tr_used,
cpu);
+								i++,
p++) {
+			if (p->pte&0x1)
+				if (is_tr_overlap(p, va, log_size))
+					goto out;
+		}
+	}
+
+	for (i =3D IA64_TR_ALLOC_BASE; i < per_cpu(ia64_tr_num, cpu); i++)
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
+				r =3D -EINVAL;
+				goto out;
+		}
+	}
+found:
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
index 26edcb7..38c0723 100644
--- a/include/asm-ia64/tlb.h
+++ b/include/asm-ia64/tlb.h
@@ -64,6 +64,18 @@ struct mmu_gather {
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
+#define RR_TO_RID(rr) ((rr)<<32>>40)
+
 /* Users of the generic TLB shootdown code must declare this storage
space. */
 DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
=20
--=20
1.5.2

------_=_NextPart_001_01C890BA.3624FB23
Content-Type: application/octet-stream;
	name="0001-Add-API-for-allocating-TR-resouce.patch"
Content-Transfer-Encoding: base64
Content-Description: 0001-Add-API-for-allocating-TR-resouce.patch
Content-Disposition: attachment;
	filename="0001-Add-API-for-allocating-TR-resouce.patch"

RnJvbSA4MzdmMDUwOGE2MTdlYTAzODY4MDhkZTlmZDBmNDJlZjRhZWZlNWUwIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVGh1LCAyNyBNYXIgMjAwOCAxMDoxODoyOSArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEFkZCBBUEkgZm9yIGFsbG9jYXRpbmcgVFIgcmVzb3VjZS4KCkR5bmFtaWMgVFIgcmVzb3VjZSBz
aG91bGQgYmUgbWFuYWdlZCBpbiBhbiB1bmlmb3JtIHdheS4KU2lnbmVkLW9mZi1ieTogWGlhbnRh
byBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+ClNpZ25lZC1vZmYtYnk6IEFudGhvbnkg
WHU8YW50aG9ueS54dUBpbnRlbC5jb20+Ci0tLQogYXJjaC9pYTY0L2tlcm5lbC9tY2EuYyAgICAg
fCAgIDUwICsrKysrKysrKysrKysKIGFyY2gvaWE2NC9rZXJuZWwvbWNhX2FzbS5TIHwgICAgNSAr
KwogYXJjaC9pYTY0L21tL3RsYi5jICAgICAgICAgfCAgMTcwICsrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrCiBpbmNsdWRlL2FzbS1pYTY0L2tyZWdzLmggICB8ICAg
IDMgKwogaW5jbHVkZS9hc20taWE2NC90bGIuaCAgICAgfCAgIDEyICsrKwogNSBmaWxlcyBjaGFu
Z2VkLCAyNDAgaW5zZXJ0aW9ucygrKSwgMCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9hcmNo
L2lhNjQva2VybmVsL21jYS5jIGIvYXJjaC9pYTY0L2tlcm5lbC9tY2EuYwppbmRleCA2YzE4MjIx
Li41MWQwYzI2IDEwMDY0NAotLS0gYS9hcmNoL2lhNjQva2VybmVsL21jYS5jCisrKyBiL2FyY2gv
aWE2NC9rZXJuZWwvbWNhLmMKQEAgLTk3LDYgKzk3LDcgQEAKIAogI2luY2x1ZGUgPGFzbS9pcnEu
aD4KICNpbmNsdWRlIDxhc20vaHdfaXJxLmg+CisjaW5jbHVkZSA8YXNtL3RsYi5oPgogCiAjaW5j
bHVkZSAibWNhX2Rydi5oIgogI2luY2x1ZGUgImVudHJ5LmgiCkBAIC0xMTIsOCArMTEzLDEwIEBA
IERFRklORV9QRVJfQ1BVKHU2NCwgaWE2NF9tY2FfZGF0YSk7IC8qID09IF9fcGVyX2NwdV9tY2Fb
c21wX3Byb2Nlc3Nvcl9pZCgpXSAqLwogREVGSU5FX1BFUl9DUFUodTY0LCBpYTY0X21jYV9wZXJf
Y3B1X3B0ZSk7IC8qIFBURSB0byBtYXAgcGVyLUNQVSBhcmVhICovCiBERUZJTkVfUEVSX0NQVSh1
NjQsIGlhNjRfbWNhX3BhbF9wdGUpOwkgICAgLyogUFRFIHRvIG1hcCBQQUwgY29kZSAqLwogREVG
SU5FX1BFUl9DUFUodTY0LCBpYTY0X21jYV9wYWxfYmFzZSk7ICAgIC8qIHZhZGRyIFBBTCBjb2Rl
IGdyYW51bGUgKi8KK0RFRklORV9QRVJfQ1BVKHU2NCwgaWE2NF9tY2FfdHJfcmVsb2FkKTsgICAv
KiBGbGFnIGZvciBUUiByZWxvYWQgKi8KIAogdW5zaWduZWQgbG9uZyBfX3Blcl9jcHVfbWNhW05S
X0NQVVNdOworZXh0ZXJuIHN0cnVjdCBpYTY0X3RyX2VudHJ5IF9fcGVyX2NwdV9pZHRyc1tOUl9D
UFVTXVsyXVtJQTY0X1RSX0FMTE9DX01BWF07CiAKIC8qIEluIG1jYV9hc20uUyAqLwogZXh0ZXJu
IHZvaWQJCQlpYTY0X29zX2luaXRfZGlzcGF0Y2hfbW9uYXJjaCAodm9pZCk7CkBAIC0xMTgyLDYg
KzExODUsNDkgQEAgYWxsX2luOgogCXJldHVybjsKIH0KIAorLyogIG1jYV9pbnNlcnRfdHIKKyAq
CisgKiAgU3dpdGNoIHJpZCB3aGVuIFRSIHJlbG9hZCBhbmQgbmVlZGVkIQorICogIGlvcmQ6IDE6
IGl0ciwgMjogaXRyOworICoKKyovCitzdGF0aWMgdm9pZCBtY2FfaW5zZXJ0X3RyKHU2NCBpb3Jk
KQoreworCisJaW50IGk7CisJdTY0IG9sZF9ycjsKKwlzdHJ1Y3QgaWE2NF90cl9lbnRyeSAqcDsK
Kwl1bnNpZ25lZCBsb25nIHBzcjsKKwlpbnQgY3B1ID0gc21wX3Byb2Nlc3Nvcl9pZCgpOworCisJ
cHNyID0gaWE2NF9jbGVhcl9pYygpOworCWZvciAoaSA9IElBNjRfVFJfQUxMT0NfQkFTRTsgaSA8
IElBNjRfVFJfQUxMT0NfTUFYOyBpKyspIHsKKwkJcCA9ICZfX3Blcl9jcHVfaWR0cnNbY3B1XVtp
b3JkLTFdW2ldOworCQlpZiAocC0+cHRlJjB4MSkgeworCQkJb2xkX3JyID0gaWE2NF9nZXRfcnIo
cC0+aWZhKTsKKwkJCWlmIChvbGRfcnIgIT0gcC0+cnIpIHsKKwkJCQlpYTY0X3NldF9ycihwLT5p
ZmEsIHAtPnJyKTsKKwkJCQlpYTY0X3NybHpfZCgpOworCQkJfQorCQkJaWE2NF9wdHIoaW9yZCwg
cC0+aWZhLCBwLT5pdGlyID4+IDIpOworCQkJaWE2NF9zcmx6X2koKTsKKwkJCWlmIChpb3JkICYg
MHgxKSB7CisJCQkJaWE2NF9pdHIoMHgxLCBpLCBwLT5pZmEsIHAtPnB0ZSwgcC0+aXRpciA+PiAy
KTsKKwkJCQlpYTY0X3NybHpfaSgpOworCQkJfQorCQkJaWYgKGlvcmQgJiAweDIpIHsKKwkJCQlp
YTY0X2l0cigweDIsIGksIHAtPmlmYSwgcC0+cHRlLCBwLT5pdGlyID4+IDIpOworCQkJCWlhNjRf
c3Jsel9pKCk7CisJCQl9CisJCQlpZiAob2xkX3JyICE9IHAtPnJyKSB7CisJCQkJaWE2NF9zZXRf
cnIocC0+aWZhLCBvbGRfcnIpOworCQkJCWlhNjRfc3Jsel9kKCk7CisJCQl9CisJCX0KKwl9CisJ
aWE2NF9zZXRfcHNyKHBzcik7Cit9CisKIC8qCiAgKiBpYTY0X21jYV9oYW5kbGVyCiAgKgpAQCAt
MTI3MSw2ICsxMzE3LDEwIEBAIGlhNjRfbWNhX2hhbmRsZXIoc3RydWN0IHB0X3JlZ3MgKnJlZ3Ms
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
YyBiL2FyY2gvaWE2NC9tbS90bGIuYwppbmRleCA2NTVkYTI0Li5kN2Y4MjA2IDEwMDY0NAotLS0g
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
PSVsZDsgIgpAQCAtMjA2LDQgKzIxNSwxNjUgQEAgaWE2NF90bGJfaW5pdCAodm9pZCkKIAlsb2Nh
bF9jcHVfZGF0YS0+cHRjZV9zdHJpZGVbMV0gPSBwdGNlX2luZm8uc3RyaWRlWzFdOwogCiAJbG9j
YWxfZmx1c2hfdGxiX2FsbCgpOwkvKiBudWtlIGxlZnQgb3ZlcnMgZnJvbSBib290c3RyYXBwaW5n
Li4uICovCisKKwlpZiAoKHN0YXR1cyA9IGlhNjRfcGFsX3ZtX3N1bW1hcnkoJnZtX2luZm9fMSwg
JnZtX2luZm9fMikpICE9IDApIHsKKwkJcHJpbnRrKEtFUk5fRVJSICJpYTY0X3BhbF92bV9zdW1t
YXJ5PSVsZFxuIiwgc3RhdHVzKTsKKwkJcGVyX2NwdShpYTY0X3RyX251bSwgY3B1KSA9IDg7CisJ
CXJldHVybjsKKwl9CisJcGVyX2NwdShpYTY0X3RyX251bSwgY3B1KSA9IHZtX2luZm9fMS5wYWxf
dm1faW5mb18xX3MubWF4X2l0cl9lbnRyeSsxOworCWlmIChwZXJfY3B1KGlhNjRfdHJfbnVtLCBj
cHUpID4KKwkJCQkodm1faW5mb18xLnBhbF92bV9pbmZvXzFfcy5tYXhfZHRyX2VudHJ5KzEpKQor
CQlwZXJfY3B1KGlhNjRfdHJfbnVtLCBjcHUpID0gdm1faW5mb18xLnBhbF92bV9pbmZvXzFfcy5t
YXhfZHRyX2VudHJ5KzE7Cit9CisKKy8qCisgKiBpc190cl9vdmVybGFwCisgKgorICogQ2hlY2sg
b3ZlcmxhcCB3aXRoIGluc2VydGVkIFRScy4KKyAqLworc3RhdGljIGludCBpc190cl9vdmVybGFw
KHN0cnVjdCBpYTY0X3RyX2VudHJ5ICpwLCB1NjQgdmEsIHU2NCBsb2dfc2l6ZSkKK3sKKwl1NjQg
dHJfbG9nX3NpemU7CisJdTY0IHRyX2VuZDsKKwl1NjQgdmFfcnIgPSBpYTY0X2dldF9ycih2YSk7
CisJdTY0IHZhX3JpZCA9IFJSX1RPX1JJRCh2YV9ycik7CisJdTY0IHZhX2VuZCA9IHZhICsgKDE8
PGxvZ19zaXplKSAtIDE7CisKKwlpZiAodmFfcmlkICE9IFJSX1RPX1JJRChwLT5ycikpCisJCXJl
dHVybiAwOworCXRyX2xvZ19zaXplID0gKHAtPml0aXIgJiAweGZmKSA+PiAyOworCXRyX2VuZCA9
IHAtPmlmYSArICgxPDx0cl9sb2dfc2l6ZSkgLSAxOworCisJaWYgKHZhID4gdHJfZW5kIHx8IHAt
PmlmYSA+IHZhX2VuZCkKKwkJcmV0dXJuIDA7CisJcmV0dXJuIDE7CisKK30KKworLyoKKyAqIGlh
NjRfaW5zZXJ0X3RyIGluIHZpcnR1YWwgbW9kZS4gQWxsb2NhdGUgYSBUUiBzbG90CisgKgorICog
dGFyZ2V0X21hc2sgOiAweDEgOiBpdHIsIDB4MiA6IGR0ciwgMHgzIDogaWR0cgorICoKKyAqIHZh
IAk6IHZpcnR1YWwgYWRkcmVzcy4KKyAqIHB0ZSAJOiBwdGUgZW50cmllcyBpbnNlcnRlZC4KKyAq
IGxvZ19zaXplOiByYW5nZSB0byBiZSBjb3ZlcmVkLgorICoKKyAqIFJldHVybiB2YWx1ZTogIDww
IDogIGVycm9yIE5vLgorICoKKyAqCQkgID49MCA6IHNsb3QgbnVtYmVyIGFsbG9jYXRlZCBmb3Ig
VFIuCisgKi8KK2ludCBpYTY0X2l0cl9lbnRyeSh1NjQgdGFyZ2V0X21hc2ssIHU2NCB2YSwgdTY0
IHB0ZSwgdTY0IGxvZ19zaXplKQoreworCWludCBpLCByOworCXVuc2lnbmVkIGxvbmcgcHNyOwor
CXN0cnVjdCBpYTY0X3RyX2VudHJ5ICpwOworCWludCBjcHUgPSBzbXBfcHJvY2Vzc29yX2lkKCk7
CisKKwlyID0gLUVJTlZBTDsKKwkvKkNoZWNrIG92ZXJsYXAgd2l0aCBleGlzdGluZyBUUiBlbnRy
aWVzKi8KKwlpZiAodGFyZ2V0X21hc2smMHgxKSB7CisJCXAgPSAmX19wZXJfY3B1X2lkdHJzW2Nw
dV1bMF1bMF07CisJCWZvciAoaSA9IElBNjRfVFJfQUxMT0NfQkFTRTsgaSA8IHBlcl9jcHUoaWE2
NF90cl91c2VkLCBjcHUpOworCQkJCQkJCQlpKyssIHArKykgeworCQkJaWYgKHAtPnB0ZSYweDEp
CisJCQkJaWYgKGlzX3RyX292ZXJsYXAocCwgdmEsIGxvZ19zaXplKSkKKwkJCQkJZ290byBvdXQ7
CisJCX0KKwl9CisJaWYgKHRhcmdldF9tYXNrJjB4MikgeworCQlwID0gJl9fcGVyX2NwdV9pZHRy
c1tjcHVdWzFdWzBdOworCQlmb3IgKGkgPSBJQTY0X1RSX0FMTE9DX0JBU0U7IGkgPCBwZXJfY3B1
KGlhNjRfdHJfdXNlZCwgY3B1KTsKKwkJCQkJCQkJaSsrLCBwKyspIHsKKwkJCWlmIChwLT5wdGUm
MHgxKQorCQkJCWlmIChpc190cl9vdmVybGFwKHAsIHZhLCBsb2dfc2l6ZSkpCisJCQkJCWdvdG8g
b3V0OworCQl9CisJfQorCisJZm9yIChpID0gSUE2NF9UUl9BTExPQ19CQVNFOyBpIDwgcGVyX2Nw
dShpYTY0X3RyX251bSwgY3B1KTsgaSsrKSB7CisJCXN3aXRjaCAodGFyZ2V0X21hc2sgJiAweDMp
IHsKKwkJCWNhc2UgMToKKwkJCQlpZiAoIShfX3Blcl9jcHVfaWR0cnNbY3B1XVswXVtpXS5wdGUm
MHgxKSkKKwkJCQkJZ290byBmb3VuZDsKKwkJCQljb250aW51ZTsKKwkJCWNhc2UgMjoKKwkJCQlp
ZiAoIShfX3Blcl9jcHVfaWR0cnNbY3B1XVsxXVtpXS5wdGUmMHgxKSkKKwkJCQkJZ290byBmb3Vu
ZDsKKwkJCQljb250aW51ZTsKKwkJCWNhc2UgMzoKKwkJCQlpZiAoIShfX3Blcl9jcHVfaWR0cnNb
Y3B1XVswXVtpXS5wdGUmMHgxKSAmJgorCQkJCQkhKF9fcGVyX2NwdV9pZHRyc1tjcHVdWzFdW2ld
LnB0ZSYweDEpKQorCQkJCQlnb3RvIGZvdW5kOworCQkJCWNvbnRpbnVlOworCQkJZGVmYXVsdDoK
KwkJCQlyID0gLUVJTlZBTDsKKwkJCQlnb3RvIG91dDsKKwkJfQorCX0KK2ZvdW5kOgorCS8qUmVj
b3JkIHRyIGluZm8gZm9yIG1jYSBoYW5kZXIgdXNlISovCisJaWYgKGkgPiBwZXJfY3B1KGlhNjRf
dHJfdXNlZCwgY3B1KSkKKwkJcGVyX2NwdShpYTY0X3RyX3VzZWQsIGNwdSkgPSBpOworCisJcHNy
ID0gaWE2NF9jbGVhcl9pYygpOworCWlmICh0YXJnZXRfbWFzayAmIDB4MSkgeworCQlpYTY0X2l0
cigweDEsIGksIHZhLCBwdGUsIGxvZ19zaXplKTsKKwkJaWE2NF9zcmx6X2koKTsKKwkJcCA9ICZf
X3Blcl9jcHVfaWR0cnNbY3B1XVswXVtpXTsKKwkJcC0+aWZhID0gdmE7CisJCXAtPnB0ZSA9IHB0
ZTsKKwkJcC0+aXRpciA9IGxvZ19zaXplIDw8IDI7CisJCXAtPnJyID0gaWE2NF9nZXRfcnIodmEp
OworCX0KKwlpZiAodGFyZ2V0X21hc2sgJiAweDIpIHsKKwkJaWE2NF9pdHIoMHgyLCBpLCB2YSwg
cHRlLCBsb2dfc2l6ZSk7CisJCWlhNjRfc3Jsel9pKCk7CisJCXAgPSAmX19wZXJfY3B1X2lkdHJz
W2NwdV1bMV1baV07CisJCXAtPmlmYSA9IHZhOworCQlwLT5wdGUgPSBwdGU7CisJCXAtPml0aXIg
PSBsb2dfc2l6ZSA8PCAyOworCQlwLT5yciA9IGlhNjRfZ2V0X3JyKHZhKTsKKwl9CisJaWE2NF9z
ZXRfcHNyKHBzcik7CisJciA9IGk7CitvdXQ6CisJcmV0dXJuIHI7Cit9CitFWFBPUlRfU1lNQk9M
X0dQTChpYTY0X2l0cl9lbnRyeSk7CisKKy8qCisgKiBpYTY0X3B1cmdlX3RyCisgKgorICogdGFy
Z2V0X21hc2s6IDB4MTogcHVyZ2UgaXRyLCAweDIgOiBwdXJnZSBkdHIsIDB4MyBwdXJnZSBpZHRy
LgorICoKKyAqIHNsb3Q6IHNsb3QgbnVtYmVyIHRvIGJlIGZyZWVkLgorICovCit2b2lkIGlhNjRf
cHRyX2VudHJ5KHU2NCB0YXJnZXRfbWFzaywgaW50IHNsb3QpCit7CisJaW50IGNwdSA9IHNtcF9w
cm9jZXNzb3JfaWQoKTsKKwlzdHJ1Y3QgaWE2NF90cl9lbnRyeSAqcDsKKworCWlmIChzbG90IDwg
SUE2NF9UUl9BTExPQ19CQVNFIHx8IHNsb3QgPj0gcGVyX2NwdShpYTY0X3RyX251bSwgY3B1KSkK
KwkJcmV0dXJuOworCisJaWYgKHRhcmdldF9tYXNrJjB4MSkgeworCQlwID0gJl9fcGVyX2NwdV9p
ZHRyc1tjcHVdWzBdW3Nsb3RdOworCQlpZiAoKHAtPnB0ZSYweDEpICYmIGlzX3RyX292ZXJsYXAo
cCwgcC0+aWZhLCBwLT5pdGlyPj4yKSkgeworCQkJcC0+cHRlID0gMDsKKwkJCWlhNjRfcHRyKDB4
MSwgcC0+aWZhLCBwLT5pdGlyPj4yKTsKKwkJCWlhNjRfc3Jsel9pKCk7CisJCX0KKwl9CisKKwlp
ZiAodGFyZ2V0X21hc2smMHgyKSB7CisJCXAgPSAmX19wZXJfY3B1X2lkdHJzW2NwdV1bMV1bc2xv
dF07CisJCWlmICgocC0+cHRlJjB4MSkgJiYgaXNfdHJfb3ZlcmxhcChwLCBwLT5pZmEsIHAtPml0
aXI+PjIpKSB7CisJCQlwLT5wdGUgPSAwOworCQkJaWE2NF9wdHIoMHgyLCBwLT5pZmEsIHAtPml0
aXI+PjIpOworCQkJaWE2NF9zcmx6X2koKTsKKwkJfQorCX0KIH0KK0VYUE9SVF9TWU1CT0xfR1BM
KGlhNjRfcHRyX2VudHJ5KTsKZGlmZiAtLWdpdCBhL2luY2x1ZGUvYXNtLWlhNjQva3JlZ3MuaCBi
L2luY2x1ZGUvYXNtLWlhNjQva3JlZ3MuaAppbmRleCA3ZTU1YTU4Li5hZWZjZGZlIDEwMDY0NAot
LS0gYS9pbmNsdWRlL2FzbS1pYTY0L2tyZWdzLmgKKysrIGIvaW5jbHVkZS9hc20taWE2NC9rcmVn
cy5oCkBAIC0zMSw2ICszMSw5IEBACiAjZGVmaW5lIElBNjRfVFJfUEFMQ09ERQkJMQkvKiBpdHIx
OiBtYXBzIFBBTGNvZGUgYXMgcmVxdWlyZWQgYnkgRUZJICovCiAjZGVmaW5lIElBNjRfVFJfQ1VS
UkVOVF9TVEFDSwkxCS8qIGR0cjE6IG1hcHMga2VybmVsJ3MgbWVtb3J5LSAmIHJlZ2lzdGVyLXN0
YWNrcyAqLwogCisjZGVmaW5lIElBNjRfVFJfQUxMT0NfQkFTRQkyIAkvKiBpdHImZHRyOiBCYXNl
IG9mIGR5bmFtaWMgVFIgcmVzb3VyY2UqLworI2RlZmluZSBJQTY0X1RSX0FMTE9DX01BWAkzMiAJ
LyogTWF4IG51bWJlciBmb3IgZHluYW1pYyB1c2UqLworCiAvKiBQcm9jZXNzb3Igc3RhdHVzIHJl
Z2lzdGVyIGJpdHM6ICovCiAjZGVmaW5lIElBNjRfUFNSX0JFX0JJVAkJMQogI2RlZmluZSBJQTY0
X1BTUl9VUF9CSVQJCTIKZGlmZiAtLWdpdCBhL2luY2x1ZGUvYXNtLWlhNjQvdGxiLmggYi9pbmNs
dWRlL2FzbS1pYTY0L3RsYi5oCmluZGV4IDI2ZWRjYjcuLjM4YzA3MjMgMTAwNjQ0Ci0tLSBhL2lu
Y2x1ZGUvYXNtLWlhNjQvdGxiLmgKKysrIGIvaW5jbHVkZS9hc20taWE2NC90bGIuaApAQCAtNjQs
NiArNjQsMTggQEAgc3RydWN0IG1tdV9nYXRoZXIgewogCXN0cnVjdCBwYWdlIAkJKnBhZ2VzW0ZS
RUVfUFRFX05SXTsKIH07CiAKK3N0cnVjdCBpYTY0X3RyX2VudHJ5IHsKKwl1NjQgaWZhOworCXU2
NCBpdGlyOworCXU2NCBwdGU7CisJdTY0IHJyOworfTsgLypSZWNvcmQgZm9yIHRyIGVudHJ5ISov
CisKK2V4dGVybiBpbnQgaWE2NF9pdHJfZW50cnkodTY0IHRhcmdldF9tYXNrLCB1NjQgdmEsIHU2
NCBwdGUsIHU2NCBsb2dfc2l6ZSk7CitleHRlcm4gdm9pZCBpYTY0X3B0cl9lbnRyeSh1NjQgdGFy
Z2V0X21hc2ssIGludCBzbG90KTsKKworI2RlZmluZSBSUl9UT19SSUQocnIpICgocnIpPDwzMj4+
NDApCisKIC8qIFVzZXJzIG9mIHRoZSBnZW5lcmljIFRMQiBzaG9vdGRvd24gY29kZSBtdXN0IGRl
Y2xhcmUgdGhpcyBzdG9yYWdlIHNwYWNlLiAqLwogREVDTEFSRV9QRVJfQ1BVKHN0cnVjdCBtbXVf
Z2F0aGVyLCBtbXVfZ2F0aGVycyk7CiAKLS0gCjEuNS4yCgo=

------_=_NextPart_001_01C890BA.3624FB23--
