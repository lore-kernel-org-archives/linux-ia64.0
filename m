From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:28:42 +0000
Subject: [PATCH][04]Add API for allocating TR resouce.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FC7@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F4.0D629CF3"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F4.0D629CF3
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: Zhang Xiantao <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 17:10:52 +0800
Subject: [PATCH] Add API for allocating TR resouce.

Dynamic TR resouce should be managed in an uniform way.
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
Signed-off-by: Anthony Xu<anthony.xu@intel.com>
---
 arch/ia64/kernel/mca.c     |   50 +++++++++++++
 arch/ia64/kernel/mca_asm.S |    5 ++
 arch/ia64/mm/tlb.c         |  167
++++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/kregs.h   |    3 +
 include/asm-ia64/tlb.h     |   12 +++
 5 files changed, 237 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 6dbf591..4253343 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -89,6 +89,7 @@
=20
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
+#include <asm/tlb.h>
=20
 #include "mca_drv.h"
 #include "entry.h"
@@ -104,8 +105,10 @@ DEFINE_PER_CPU(u64, ia64_mca_data); /* =3D=3D
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
@@ -1177,6 +1180,49 @@ all_in:
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
@@ -1266,6 +1312,10 @@ ia64_mca_handler(struct pt_regs *regs, struct
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
 		ia64_mca_spin(__FUNCTION__);
diff --git a/arch/ia64/kernel/mca_asm.S b/arch/ia64/kernel/mca_asm.S
index 0f5965f..dd37dd0 100644
--- a/arch/ia64/kernel/mca_asm.S
+++ b/arch/ia64/kernel/mca_asm.S
@@ -215,8 +215,13 @@ ia64_reload_tr:
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
index 655da24..e27e101 100644
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
@@ -206,4 +215,162 @@ ia64_tlb_init (void)
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
+	if (per_cpu(ia64_tr_num, cpu) >=20
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
+ * va: begin address to be purged
+ * log_size: size to purege.
+ *
+ */
+void ia64_ptr_entry(u64 target_mask, u64 va, u64 log_size)
+{
+	int i;
+	int cpu =3D smp_processor_id();
+	struct ia64_tr_entry *p;
+
+	ia64_ptr(target_mask, va, log_size);
+	ia64_srlz_i();
+
+	for (i =3D IA64_TR_ALLOC_BASE; i < per_cpu(ia64_tr_used, cpu);
i++) {
+		if (target_mask&0x1) {
+			p =3D &__per_cpu_idtrs[cpu][0][i];
+			if ((p->pte&0x1) && is_tr_overlap(p, va,
log_size))
+				p->pte =3D 0;
+		}
+		if (target_mask&0x2) {
+			p =3D &__per_cpu_idtrs[cpu][1][i];
+			if ((p->pte&0x1) && is_tr_overlap(p, va,
log_size))
+				p->pte =3D 0;
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
index 26edcb7..f57a8c1 100644
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
+extern void ia64_ptr_entry(u64 target_mask, u64 va, u64 log_size);
+
+#define RR_TO_RID(rr) ((rr)<<32>>40)
+
 /* Users of the generic TLB shootdown code must declare this storage
space. */
 DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
=20
--=20
1.5.1

------_=_NextPart_001_01C863F4.0D629CF3
Content-Type: application/octet-stream;
	name="0004-Add-API-for-allocating-TR-resouce.patch"
Content-Transfer-Encoding: base64
Content-Description: 0004-Add-API-for-allocating-TR-resouce.patch
Content-Disposition: attachment;
	filename="0004-Add-API-for-allocating-TR-resouce.patch"

RnJvbSAyMzA5Y2U1MGI1ZWQ5YWRmZmUzZDY3YzE1NDA5NjkwNjIzYzVmZTM5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBaaGFuZyBYaWFudGFvIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVGh1LCAzMSBKYW4gMjAwOCAxNzoxMDo1MiArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEFkZCBBUEkgZm9yIGFsbG9jYXRpbmcgVFIgcmVzb3VjZS4KCkR5bmFtaWMgVFIgcmVzb3VjZSBz
aG91bGQgYmUgbWFuYWdlZCBpbiBhbiB1bmlmb3JtIHdheS4KU2lnbmVkLW9mZi1ieTogWGlhbnRh
byBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+ClNpZ25lZC1vZmYtYnk6IEFudGhvbnkg
WHU8YW50aG9ueS54dUBpbnRlbC5jb20+Ci0tLQogYXJjaC9pYTY0L2tlcm5lbC9tY2EuYyAgICAg
fCAgIDUwICsrKysrKysrKysrKysKIGFyY2gvaWE2NC9rZXJuZWwvbWNhX2FzbS5TIHwgICAgNSAr
KwogYXJjaC9pYTY0L21tL3RsYi5jICAgICAgICAgfCAgMTY3ICsrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrCiBpbmNsdWRlL2FzbS1pYTY0L2tyZWdzLmggICB8ICAg
IDMgKwogaW5jbHVkZS9hc20taWE2NC90bGIuaCAgICAgfCAgIDEyICsrKwogNSBmaWxlcyBjaGFu
Z2VkLCAyMzcgaW5zZXJ0aW9ucygrKSwgMCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9hcmNo
L2lhNjQva2VybmVsL21jYS5jIGIvYXJjaC9pYTY0L2tlcm5lbC9tY2EuYwppbmRleCA2ZGJmNTkx
Li40MjUzMzQzIDEwMDY0NAotLS0gYS9hcmNoL2lhNjQva2VybmVsL21jYS5jCisrKyBiL2FyY2gv
aWE2NC9rZXJuZWwvbWNhLmMKQEAgLTg5LDYgKzg5LDcgQEAKIAogI2luY2x1ZGUgPGFzbS9pcnEu
aD4KICNpbmNsdWRlIDxhc20vaHdfaXJxLmg+CisjaW5jbHVkZSA8YXNtL3RsYi5oPgogCiAjaW5j
bHVkZSAibWNhX2Rydi5oIgogI2luY2x1ZGUgImVudHJ5LmgiCkBAIC0xMDQsOCArMTA1LDEwIEBA
IERFRklORV9QRVJfQ1BVKHU2NCwgaWE2NF9tY2FfZGF0YSk7IC8qID09IF9fcGVyX2NwdV9tY2Fb
c21wX3Byb2Nlc3Nvcl9pZCgpXSAqLwogREVGSU5FX1BFUl9DUFUodTY0LCBpYTY0X21jYV9wZXJf
Y3B1X3B0ZSk7IC8qIFBURSB0byBtYXAgcGVyLUNQVSBhcmVhICovCiBERUZJTkVfUEVSX0NQVSh1
NjQsIGlhNjRfbWNhX3BhbF9wdGUpOwkgICAgLyogUFRFIHRvIG1hcCBQQUwgY29kZSAqLwogREVG
SU5FX1BFUl9DUFUodTY0LCBpYTY0X21jYV9wYWxfYmFzZSk7ICAgIC8qIHZhZGRyIFBBTCBjb2Rl
IGdyYW51bGUgKi8KK0RFRklORV9QRVJfQ1BVKHU2NCwgaWE2NF9tY2FfdHJfcmVsb2FkKTsgICAv
KiBGbGFnIGZvciBUUiByZWxvYWQgKi8KIAogdW5zaWduZWQgbG9uZyBfX3Blcl9jcHVfbWNhW05S
X0NQVVNdOworZXh0ZXJuIHN0cnVjdCBpYTY0X3RyX2VudHJ5IF9fcGVyX2NwdV9pZHRyc1tOUl9D
UFVTXVsyXVtJQTY0X1RSX0FMTE9DX01BWF07CiAKIC8qIEluIG1jYV9hc20uUyAqLwogZXh0ZXJu
IHZvaWQJCQlpYTY0X29zX2luaXRfZGlzcGF0Y2hfbW9uYXJjaCAodm9pZCk7CkBAIC0xMTc3LDYg
KzExODAsNDkgQEAgYWxsX2luOgogCXJldHVybjsKIH0KIAorLyogIG1jYV9pbnNlcnRfdHIKKyAq
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
MTI2Niw2ICsxMzEyLDEwIEBAIGlhNjRfbWNhX2hhbmRsZXIoc3RydWN0IHB0X3JlZ3MgKnJlZ3Ms
IHN0cnVjdCBzd2l0Y2hfc3RhY2sgKnN3LAogCQltb25hcmNoX2NwdSA9IC0xOwogI2VuZGlmCiAJ
fQorCWlmIChfX2dldF9jcHVfdmFyKGlhNjRfbWNhX3RyX3JlbG9hZCkpIHsKKwkJbWNhX2luc2Vy
dF90cigweDEpOyAvKlJlbG9hZCBkeW5hbWljIGl0cnMqLworCQltY2FfaW5zZXJ0X3RyKDB4Mik7
IC8qUmVsb2FkIGR5bmFtaWMgaXRycyovCisJfQogCWlmIChub3RpZnlfZGllKERJRV9NQ0FfTU9O
QVJDSF9MRUFWRSwgIk1DQSIsIHJlZ3MsIChsb25nKSZuZCwgMCwgcmVjb3ZlcikKIAkJCT09IE5P
VElGWV9TVE9QKQogCQlpYTY0X21jYV9zcGluKF9fRlVOQ1RJT05fXyk7CmRpZmYgLS1naXQgYS9h
cmNoL2lhNjQva2VybmVsL21jYV9hc20uUyBiL2FyY2gvaWE2NC9rZXJuZWwvbWNhX2FzbS5TCmlu
ZGV4IDBmNTk2NWYuLmRkMzdkZDAgMTAwNjQ0Ci0tLSBhL2FyY2gvaWE2NC9rZXJuZWwvbWNhX2Fz
bS5TCisrKyBiL2FyY2gvaWE2NC9rZXJuZWwvbWNhX2FzbS5TCkBAIC0yMTUsOCArMjE1LDEzIEBA
IGlhNjRfcmVsb2FkX3RyOgogCW1vdiByMjA9SUE2NF9UUl9DVVJSRU5UX1NUQUNLCiAJOzsKIAlp
dHIuZCBkdHJbcjIwXT1yMTYKKwlHRVRfVEhJU19QQUREUihyMiwgaWE2NF9tY2FfdHJfcmVsb2Fk
KQorCW1vdiByMTggPSAxCiAJOzsKIAlzcmx6LmQKKwk7OworCXN0OCBbcjJdID1yMTgKKwk7Owog
CiBkb25lX3RsYl9wdXJnZV9hbmRfcmVsb2FkOgogCmRpZmYgLS1naXQgYS9hcmNoL2lhNjQvbW0v
dGxiLmMgYi9hcmNoL2lhNjQvbW0vdGxiLmMKaW5kZXggNjU1ZGEyNC4uZTI3ZTEwMSAxMDA2NDQK
LS0tIGEvYXJjaC9pYTY0L21tL3RsYi5jCisrKyBiL2FyY2gvaWE2NC9tbS90bGIuYwpAQCAtMjYs
NiArMjYsOCBAQAogI2luY2x1ZGUgPGFzbS9wYWwuaD4KICNpbmNsdWRlIDxhc20vdGxiZmx1c2gu
aD4KICNpbmNsdWRlIDxhc20vZG1hLmg+CisjaW5jbHVkZSA8YXNtL3Byb2Nlc3Nvci5oPgorI2lu
Y2x1ZGUgPGFzbS90bGIuaD4KIAogc3RhdGljIHN0cnVjdCB7CiAJdW5zaWduZWQgbG9uZyBtYXNr
OwkvKiBtYXNrIG9mIHN1cHBvcnRlZCBwdXJnZSBwYWdlLXNpemVzICovCkBAIC0zOSw2ICs0MSwx
MCBAQCBzdHJ1Y3QgaWE2NF9jdHggaWE2NF9jdHggPSB7CiB9OwogCiBERUZJTkVfUEVSX0NQVSh1
OCwgaWE2NF9uZWVkX3RsYl9mbHVzaCk7CitERUZJTkVfUEVSX0NQVSh1OCwgaWE2NF90cl9udW0p
OyAgLypOdW1iZXIgb2YgVFIgc2xvdHMgaW4gY3VycmVudCBwcm9jZXNzb3IqLworREVGSU5FX1BF
Ul9DUFUodTgsIGlhNjRfdHJfdXNlZCk7IC8qTWF4IFNsb3QgbnVtYmVyIHVzZWQgYnkga2VybmVs
Ki8KKworc3RydWN0IGlhNjRfdHJfZW50cnkgX19wZXJfY3B1X2lkdHJzW05SX0NQVVNdWzJdW0lB
NjRfVFJfQUxMT0NfTUFYXTsKIAogLyoKICAqIEluaXRpYWxpemVzIHRoZSBpYTY0X2N0eC5iaXRt
YXAgYXJyYXkgYmFzZWQgb24gbWF4X2N0eCsxLgpAQCAtMTkwLDYgKzE5Niw5IEBAIGlhNjRfdGxi
X2luaXQgKHZvaWQpCiAJaWE2NF9wdGNlX2luZm9fdCB1bmluaXRpYWxpemVkX3ZhcihwdGNlX2lu
Zm8pOyAvKiBHQ0MgYmUgcXVpZXQgKi8KIAl1bnNpZ25lZCBsb25nIHRyX3BnYml0czsKIAlsb25n
IHN0YXR1czsKKwlwYWxfdm1faW5mb18xX3VfdCB2bV9pbmZvXzE7CisJcGFsX3ZtX2luZm9fMl91
X3Qgdm1faW5mb18yOworCWludCBjcHUgPSBzbXBfcHJvY2Vzc29yX2lkKCk7CiAKIAlpZiAoKHN0
YXR1cyA9IGlhNjRfcGFsX3ZtX3BhZ2Vfc2l6ZSgmdHJfcGdiaXRzLCAmcHVyZ2UubWFzaykpICE9
IDApIHsKIAkJcHJpbnRrKEtFUk5fRVJSICJQQUxfVk1fUEFHRV9TSVpFIGZhaWxlZCB3aXRoIHN0
YXR1cz0lbGQ7ICIKQEAgLTIwNiw0ICsyMTUsMTYyIEBAIGlhNjRfdGxiX2luaXQgKHZvaWQpCiAJ
bG9jYWxfY3B1X2RhdGEtPnB0Y2Vfc3RyaWRlWzFdID0gcHRjZV9pbmZvLnN0cmlkZVsxXTsKIAog
CWxvY2FsX2ZsdXNoX3RsYl9hbGwoKTsJLyogbnVrZSBsZWZ0IG92ZXJzIGZyb20gYm9vdHN0cmFw
cGluZy4uLiAqLworCisJaWYgKChzdGF0dXMgPSBpYTY0X3BhbF92bV9zdW1tYXJ5KCZ2bV9pbmZv
XzEsICZ2bV9pbmZvXzIpKSAhPSAwKSB7CisJCXByaW50ayhLRVJOX0VSUiAiaWE2NF9wYWxfdm1f
c3VtbWFyeT0lbGRcbiIsIHN0YXR1cyk7CisJCXBlcl9jcHUoaWE2NF90cl9udW0sIGNwdSkgPSA4
OworCQlyZXR1cm47CisJfQorCXBlcl9jcHUoaWE2NF90cl9udW0sIGNwdSkgPSB2bV9pbmZvXzEu
cGFsX3ZtX2luZm9fMV9zLm1heF9pdHJfZW50cnkrMTsKKwlpZiAocGVyX2NwdShpYTY0X3RyX251
bSwgY3B1KSA+IAorCQkJCSh2bV9pbmZvXzEucGFsX3ZtX2luZm9fMV9zLm1heF9kdHJfZW50cnkr
MSkpCisJCXBlcl9jcHUoaWE2NF90cl9udW0sIGNwdSkgPSB2bV9pbmZvXzEucGFsX3ZtX2luZm9f
MV9zLm1heF9kdHJfZW50cnkrMTsKK30KKworLyoKKyAqIGlzX3RyX292ZXJsYXAKKyAqCisgKiBD
aGVjayBvdmVybGFwIHdpdGggaW5zZXJ0ZWQgVFJzLgorICovCitzdGF0aWMgaW50IGlzX3RyX292
ZXJsYXAoc3RydWN0IGlhNjRfdHJfZW50cnkgKnAsIHU2NCB2YSwgdTY0IGxvZ19zaXplKQorewor
CXU2NCB0cl9sb2dfc2l6ZTsKKwl1NjQgdHJfZW5kOworCXU2NCB2YV9yciA9IGlhNjRfZ2V0X3Jy
KHZhKTsKKwl1NjQgdmFfcmlkID0gUlJfVE9fUklEKHZhX3JyKTsKKwl1NjQgdmFfZW5kID0gdmEg
KyAoMTw8bG9nX3NpemUpIC0gMTsKKworCWlmICh2YV9yaWQgIT0gUlJfVE9fUklEKHAtPnJyKSkK
KwkJcmV0dXJuIDA7CisJdHJfbG9nX3NpemUgPSAocC0+aXRpciAmIDB4ZmYpID4+IDI7CisJdHJf
ZW5kID0gcC0+aWZhICsgKDE8PHRyX2xvZ19zaXplKSAtIDE7CisKKwlpZiAodmEgPiB0cl9lbmQg
fHwgcC0+aWZhID4gdmFfZW5kKQorCQlyZXR1cm4gMDsKKwlyZXR1cm4gMTsKKworfQorCisvKgor
ICogaWE2NF9pbnNlcnRfdHIgaW4gdmlydHVhbCBtb2RlLiBBbGxvY2F0ZSBhIFRSIHNsb3QKKyAq
CisgKiB0YXJnZXRfbWFzayA6IDB4MSA6IGl0ciwgMHgyIDogZHRyLCAweDMgOiBpZHRyCisgKgor
ICogdmEgCTogdmlydHVhbCBhZGRyZXNzLgorICogcHRlIAk6IHB0ZSBlbnRyaWVzIGluc2VydGVk
LgorICogbG9nX3NpemU6IHJhbmdlIHRvIGJlIGNvdmVyZWQuCisgKgorICogUmV0dXJuIHZhbHVl
OiAgPDAgOiAgZXJyb3IgTm8uCisgKgorICoJCSAgPj0wIDogc2xvdCBudW1iZXIgYWxsb2NhdGVk
IGZvciBUUi4KKyAqLworaW50IGlhNjRfaXRyX2VudHJ5KHU2NCB0YXJnZXRfbWFzaywgdTY0IHZh
LCB1NjQgcHRlLCB1NjQgbG9nX3NpemUpCit7CisJaW50IGksIHI7CisJdW5zaWduZWQgbG9uZyBw
c3I7CisJc3RydWN0IGlhNjRfdHJfZW50cnkgKnA7CisJaW50IGNwdSA9IHNtcF9wcm9jZXNzb3Jf
aWQoKTsKKworCXIgPSAtRUlOVkFMOworCS8qQ2hlY2sgb3ZlcmxhcCB3aXRoIGV4aXN0aW5nIFRS
IGVudHJpZXMqLworCWlmICh0YXJnZXRfbWFzayYweDEpIHsKKwkJcCA9ICZfX3Blcl9jcHVfaWR0
cnNbY3B1XVswXVswXTsKKwkJZm9yIChpID0gSUE2NF9UUl9BTExPQ19CQVNFOyBpIDwgcGVyX2Nw
dShpYTY0X3RyX3VzZWQsIGNwdSk7CisJCQkJCQkJCWkrKywgcCsrKSB7CisJCQlpZiAocC0+cHRl
JjB4MSkKKwkJCQlpZiAoaXNfdHJfb3ZlcmxhcChwLCB2YSwgbG9nX3NpemUpKQorCQkJCQlnb3Rv
IG91dDsKKwkJfQorCX0KKwlpZiAodGFyZ2V0X21hc2smMHgyKSB7CisJCXAgPSAmX19wZXJfY3B1
X2lkdHJzW2NwdV1bMV1bMF07CisJCWZvciAoaSA9IElBNjRfVFJfQUxMT0NfQkFTRTsgaSA8IHBl
cl9jcHUoaWE2NF90cl91c2VkLCBjcHUpOworCQkJCQkJCQlpKyssIHArKykgeworCQkJaWYgKHAt
PnB0ZSYweDEpCisJCQkJaWYgKGlzX3RyX292ZXJsYXAocCwgdmEsIGxvZ19zaXplKSkKKwkJCQkJ
Z290byBvdXQ7CisJCX0KKwl9CisKKwlmb3IgKGkgPSBJQTY0X1RSX0FMTE9DX0JBU0U7IGkgPCBw
ZXJfY3B1KGlhNjRfdHJfbnVtLCBjcHUpOyBpKyspIHsKKwkJc3dpdGNoICh0YXJnZXRfbWFzayAm
IDB4MykgeworCQkJY2FzZSAxOgorCQkJCWlmICghKF9fcGVyX2NwdV9pZHRyc1tjcHVdWzBdW2ld
LnB0ZSYweDEpKQorCQkJCQlnb3RvIGZvdW5kOworCQkJCWNvbnRpbnVlOworCQkJY2FzZSAyOgor
CQkJCWlmICghKF9fcGVyX2NwdV9pZHRyc1tjcHVdWzFdW2ldLnB0ZSYweDEpKQorCQkJCQlnb3Rv
IGZvdW5kOworCQkJCWNvbnRpbnVlOworCQkJY2FzZSAzOgorCQkJCWlmICghKF9fcGVyX2NwdV9p
ZHRyc1tjcHVdWzBdW2ldLnB0ZSYweDEpICYmCisJCQkJCSEoX19wZXJfY3B1X2lkdHJzW2NwdV1b
MV1baV0ucHRlJjB4MSkpCisJCQkJCWdvdG8gZm91bmQ7CisJCQkJY29udGludWU7CisJCQlkZWZh
dWx0OgorCQkJCXIgPSAtRUlOVkFMOworCQkJCWdvdG8gb3V0OworCQl9CisJfQorZm91bmQ6CisJ
LypSZWNvcmQgdHIgaW5mbyBmb3IgbWNhIGhhbmRlciB1c2UhKi8KKwlpZiAoaSA+IHBlcl9jcHUo
aWE2NF90cl91c2VkLCBjcHUpKQorCQlwZXJfY3B1KGlhNjRfdHJfdXNlZCwgY3B1KSA9IGk7CisK
Kwlwc3IgPSBpYTY0X2NsZWFyX2ljKCk7CisJaWYgKHRhcmdldF9tYXNrICYgMHgxKSB7CisJCWlh
NjRfaXRyKDB4MSwgaSwgdmEsIHB0ZSwgbG9nX3NpemUpOworCQlpYTY0X3NybHpfaSgpOworCQlw
ID0gJl9fcGVyX2NwdV9pZHRyc1tjcHVdWzBdW2ldOworCQlwLT5pZmEgPSB2YTsKKwkJcC0+cHRl
ID0gcHRlOworCQlwLT5pdGlyID0gbG9nX3NpemUgPDwgMjsKKwkJcC0+cnIgPSBpYTY0X2dldF9y
cih2YSk7CisJfQorCWlmICh0YXJnZXRfbWFzayAmIDB4MikgeworCQlpYTY0X2l0cigweDIsIGks
IHZhLCBwdGUsIGxvZ19zaXplKTsKKwkJaWE2NF9zcmx6X2koKTsKKwkJcCA9ICZfX3Blcl9jcHVf
aWR0cnNbY3B1XVsxXVtpXTsKKwkJcC0+aWZhID0gdmE7CisJCXAtPnB0ZSA9IHB0ZTsKKwkJcC0+
aXRpciA9IGxvZ19zaXplIDw8IDI7CisJCXAtPnJyID0gaWE2NF9nZXRfcnIodmEpOworCX0KKwlp
YTY0X3NldF9wc3IocHNyKTsKKwlyID0gaTsKK291dDoKKwlyZXR1cm4gcjsKK30KK0VYUE9SVF9T
WU1CT0xfR1BMKGlhNjRfaXRyX2VudHJ5KTsKKworLyoKKyAqIGlhNjRfcHVyZ2VfdHIKKyAqCisg
KiB0YXJnZXRfbWFzazogMHgxOiBwdXJnZSBpdHIsIDB4MiA6IHB1cmdlIGR0ciwgMHgzIHB1cmdl
IGlkdHIuCisgKiB2YTogYmVnaW4gYWRkcmVzcyB0byBiZSBwdXJnZWQKKyAqIGxvZ19zaXplOiBz
aXplIHRvIHB1cmVnZS4KKyAqCisgKi8KK3ZvaWQgaWE2NF9wdHJfZW50cnkodTY0IHRhcmdldF9t
YXNrLCB1NjQgdmEsIHU2NCBsb2dfc2l6ZSkKK3sKKwlpbnQgaTsKKwlpbnQgY3B1ID0gc21wX3By
b2Nlc3Nvcl9pZCgpOworCXN0cnVjdCBpYTY0X3RyX2VudHJ5ICpwOworCisJaWE2NF9wdHIodGFy
Z2V0X21hc2ssIHZhLCBsb2dfc2l6ZSk7CisJaWE2NF9zcmx6X2koKTsKKworCWZvciAoaSA9IElB
NjRfVFJfQUxMT0NfQkFTRTsgaSA8IHBlcl9jcHUoaWE2NF90cl91c2VkLCBjcHUpOyBpKyspIHsK
KwkJaWYgKHRhcmdldF9tYXNrJjB4MSkgeworCQkJcCA9ICZfX3Blcl9jcHVfaWR0cnNbY3B1XVsw
XVtpXTsKKwkJCWlmICgocC0+cHRlJjB4MSkgJiYgaXNfdHJfb3ZlcmxhcChwLCB2YSwgbG9nX3Np
emUpKQorCQkJCXAtPnB0ZSA9IDA7CisJCX0KKwkJaWYgKHRhcmdldF9tYXNrJjB4MikgeworCQkJ
cCA9ICZfX3Blcl9jcHVfaWR0cnNbY3B1XVsxXVtpXTsKKwkJCWlmICgocC0+cHRlJjB4MSkgJiYg
aXNfdHJfb3ZlcmxhcChwLCB2YSwgbG9nX3NpemUpKQorCQkJCXAtPnB0ZSA9IDA7CisJCX0KKwl9
CiB9CitFWFBPUlRfU1lNQk9MX0dQTChpYTY0X3B0cl9lbnRyeSk7CmRpZmYgLS1naXQgYS9pbmNs
dWRlL2FzbS1pYTY0L2tyZWdzLmggYi9pbmNsdWRlL2FzbS1pYTY0L2tyZWdzLmgKaW5kZXggN2U1
NWE1OC4uYWVmY2RmZSAxMDA2NDQKLS0tIGEvaW5jbHVkZS9hc20taWE2NC9rcmVncy5oCisrKyBi
L2luY2x1ZGUvYXNtLWlhNjQva3JlZ3MuaApAQCAtMzEsNiArMzEsOSBAQAogI2RlZmluZSBJQTY0
X1RSX1BBTENPREUJCTEJLyogaXRyMTogbWFwcyBQQUxjb2RlIGFzIHJlcXVpcmVkIGJ5IEVGSSAq
LwogI2RlZmluZSBJQTY0X1RSX0NVUlJFTlRfU1RBQ0sJMQkvKiBkdHIxOiBtYXBzIGtlcm5lbCdz
IG1lbW9yeS0gJiByZWdpc3Rlci1zdGFja3MgKi8KIAorI2RlZmluZSBJQTY0X1RSX0FMTE9DX0JB
U0UJMiAJLyogaXRyJmR0cjogQmFzZSBvZiBkeW5hbWljIFRSIHJlc291cmNlKi8KKyNkZWZpbmUg
SUE2NF9UUl9BTExPQ19NQVgJMzIgCS8qIE1heCBudW1iZXIgZm9yIGR5bmFtaWMgdXNlKi8KKwog
LyogUHJvY2Vzc29yIHN0YXR1cyByZWdpc3RlciBiaXRzOiAqLwogI2RlZmluZSBJQTY0X1BTUl9C
RV9CSVQJCTEKICNkZWZpbmUgSUE2NF9QU1JfVVBfQklUCQkyCmRpZmYgLS1naXQgYS9pbmNsdWRl
L2FzbS1pYTY0L3RsYi5oIGIvaW5jbHVkZS9hc20taWE2NC90bGIuaAppbmRleCAyNmVkY2I3Li5m
NTdhOGMxIDEwMDY0NAotLS0gYS9pbmNsdWRlL2FzbS1pYTY0L3RsYi5oCisrKyBiL2luY2x1ZGUv
YXNtLWlhNjQvdGxiLmgKQEAgLTY0LDYgKzY0LDE4IEBAIHN0cnVjdCBtbXVfZ2F0aGVyIHsKIAlz
dHJ1Y3QgcGFnZSAJCSpwYWdlc1tGUkVFX1BURV9OUl07CiB9OwogCitzdHJ1Y3QgaWE2NF90cl9l
bnRyeSB7CisJdTY0IGlmYTsKKwl1NjQgaXRpcjsKKwl1NjQgcHRlOworCXU2NCBycjsKK307IC8q
UmVjb3JkIGZvciB0ciBlbnRyeSEqLworCitleHRlcm4gaW50IGlhNjRfaXRyX2VudHJ5KHU2NCB0
YXJnZXRfbWFzaywgdTY0IHZhLCB1NjQgcHRlLCB1NjQgbG9nX3NpemUpOworZXh0ZXJuIHZvaWQg
aWE2NF9wdHJfZW50cnkodTY0IHRhcmdldF9tYXNrLCB1NjQgdmEsIHU2NCBsb2dfc2l6ZSk7CisK
KyNkZWZpbmUgUlJfVE9fUklEKHJyKSAoKHJyKTw8MzI+PjQwKQorCiAvKiBVc2VycyBvZiB0aGUg
Z2VuZXJpYyBUTEIgc2hvb3Rkb3duIGNvZGUgbXVzdCBkZWNsYXJlIHRoaXMgc3RvcmFnZSBzcGFj
ZS4gKi8KIERFQ0xBUkVfUEVSX0NQVShzdHJ1Y3QgbW11X2dhdGhlciwgbW11X2dhdGhlcnMpOwog
Ci0tIAoxLjUuMQoK

------_=_NextPart_001_01C863F4.0D629CF3--
