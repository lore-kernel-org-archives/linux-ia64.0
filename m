From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 08:24:24 +0000
Subject: [01/17]PATCH  Add API for allocating dynamic TR resouce. V8
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC0104823F@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C89308.A0DB709F"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EEE@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EEE@pdsmsx415.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C89308.A0DB709F
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 32013d1407ccbacf962031c308f31494b3f24aa3 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Sat, 29 Mar 2008 09:23:37 +0800
Subject: [PATCH] KVM:IA64 Add API for allocating Dynamic TR resource.

Dynamic TR resource should be managed in the uniform way.
Add two interfaces for kernel:
ia64_itr_entry: Allocate a (pair of) TR for caller.
ia64_ptr_entry: Purge a (pair of ) TR by caller.

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
index 655da24..392866a 100644
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
+		for (i =3D IA64_TR_ALLOC_BASE; i <=3D per_cpu(ia64_tr_used,
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
+		for (i =3D IA64_TR_ALLOC_BASE; i <=3D per_cpu(ia64_tr_used,
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
+	for (i =3D per_cpu(ia64_tr_used, cpu); i >=3D IA64_TR_ALLOC_BASE;
i--) {
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

------_=_NextPart_001_01C89308.A0DB709F
Content-Type: application/octet-stream;
	name="0001-KVM-IA64-Add-API-for-allocating-Dynamic-TR-resource.patch"
Content-Transfer-Encoding: base64
Content-Description: 0001-KVM-IA64-Add-API-for-allocating-Dynamic-TR-resource.patch
Content-Disposition: attachment;
	filename="0001-KVM-IA64-Add-API-for-allocating-Dynamic-TR-resource.patch"

RnJvbSAzMjAxM2QxNDA3Y2NiYWNmOTYyMDMxYzMwOGYzMTQ5NGIzZjI0YWEzIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogU2F0LCAyOSBNYXIgMjAwOCAwOToyMzozNyArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEtWTTpJQTY0IEFkZCBBUEkgZm9yIGFsbG9jYXRpbmcgRHluYW1pYyBUUiByZXNvdXJjZS4KCkR5
bmFtaWMgVFIgcmVzb3VyY2Ugc2hvdWxkIGJlIG1hbmFnZWQgaW4gdGhlIHVuaWZvcm0gd2F5LgpB
ZGQgdHdvIGludGVyZmFjZXMgZm9yIGtlcm5lbDoKaWE2NF9pdHJfZW50cnk6IEFsbG9jYXRlIGEg
KHBhaXIgb2YpIFRSIGZvciBjYWxsZXIuCmlhNjRfcHRyX2VudHJ5OiBQdXJnZSBhIChwYWlyIG9m
ICkgVFIgYnkgY2FsbGVyLgoKU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56
aGFuZ0BpbnRlbC5jb20+ClNpZ25lZC1vZmYtYnk6IEFudGhvbnkgWHU8YW50aG9ueS54dUBpbnRl
bC5jb20+Ci0tLQogYXJjaC9pYTY0L2tlcm5lbC9tY2EuYyAgICAgfCAgIDQ5ICsrKysrKysrKysr
CiBhcmNoL2lhNjQva2VybmVsL21jYV9hc20uUyB8ICAgIDUgKwogYXJjaC9pYTY0L21tL3RsYi5j
ICAgICAgICAgfCAgMTk2ICsrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrCiBpbmNsdWRlL2FzbS1pYTY0L2tyZWdzLmggICB8ICAgIDMgKwogaW5jbHVkZS9hc20taWE2
NC90bGIuaCAgICAgfCAgIDE0ICsrKwogNSBmaWxlcyBjaGFuZ2VkLCAyNjcgaW5zZXJ0aW9ucygr
KSwgMCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva2VybmVsL21jYS5jIGIv
YXJjaC9pYTY0L2tlcm5lbC9tY2EuYwppbmRleCA2YzE4MjIxLi5lZTY5MjRiIDEwMDY0NAotLS0g
YS9hcmNoL2lhNjQva2VybmVsL21jYS5jCisrKyBiL2FyY2gvaWE2NC9rZXJuZWwvbWNhLmMKQEAg
LTk3LDYgKzk3LDcgQEAKIAogI2luY2x1ZGUgPGFzbS9pcnEuaD4KICNpbmNsdWRlIDxhc20vaHdf
aXJxLmg+CisjaW5jbHVkZSA8YXNtL3RsYi5oPgogCiAjaW5jbHVkZSAibWNhX2Rydi5oIgogI2lu
Y2x1ZGUgImVudHJ5LmgiCkBAIC0xMTIsNiArMTEzLDcgQEAgREVGSU5FX1BFUl9DUFUodTY0LCBp
YTY0X21jYV9kYXRhKTsgLyogPT0gX19wZXJfY3B1X21jYVtzbXBfcHJvY2Vzc29yX2lkKCldICov
CiBERUZJTkVfUEVSX0NQVSh1NjQsIGlhNjRfbWNhX3Blcl9jcHVfcHRlKTsgLyogUFRFIHRvIG1h
cCBwZXItQ1BVIGFyZWEgKi8KIERFRklORV9QRVJfQ1BVKHU2NCwgaWE2NF9tY2FfcGFsX3B0ZSk7
CSAgICAvKiBQVEUgdG8gbWFwIFBBTCBjb2RlICovCiBERUZJTkVfUEVSX0NQVSh1NjQsIGlhNjRf
bWNhX3BhbF9iYXNlKTsgICAgLyogdmFkZHIgUEFMIGNvZGUgZ3JhbnVsZSAqLworREVGSU5FX1BF
Ul9DUFUodTY0LCBpYTY0X21jYV90cl9yZWxvYWQpOyAgIC8qIEZsYWcgZm9yIFRSIHJlbG9hZCAq
LwogCiB1bnNpZ25lZCBsb25nIF9fcGVyX2NwdV9tY2FbTlJfQ1BVU107CiAKQEAgLTExODIsNiAr
MTE4NCw0OSBAQCBhbGxfaW46CiAJcmV0dXJuOwogfQogCisvKiAgbWNhX2luc2VydF90cgorICoK
KyAqICBTd2l0Y2ggcmlkIHdoZW4gVFIgcmVsb2FkIGFuZCBuZWVkZWQhCisgKiAgaW9yZDogMTog
aXRyLCAyOiBpdHI7CisgKgorKi8KK3N0YXRpYyB2b2lkIG1jYV9pbnNlcnRfdHIodTY0IGlvcmQp
Cit7CisKKwlpbnQgaTsKKwl1NjQgb2xkX3JyOworCXN0cnVjdCBpYTY0X3RyX2VudHJ5ICpwOwor
CXVuc2lnbmVkIGxvbmcgcHNyOworCWludCBjcHUgPSBzbXBfcHJvY2Vzc29yX2lkKCk7CisKKwlw
c3IgPSBpYTY0X2NsZWFyX2ljKCk7CisJZm9yIChpID0gSUE2NF9UUl9BTExPQ19CQVNFOyBpIDwg
SUE2NF9UUl9BTExPQ19NQVg7IGkrKykgeworCQlwID0gJl9fcGVyX2NwdV9pZHRyc1tjcHVdW2lv
cmQtMV1baV07CisJCWlmIChwLT5wdGUmMHgxKSB7CisJCQlvbGRfcnIgPSBpYTY0X2dldF9ycihw
LT5pZmEpOworCQkJaWYgKG9sZF9yciAhPSBwLT5ycikgeworCQkJCWlhNjRfc2V0X3JyKHAtPmlm
YSwgcC0+cnIpOworCQkJCWlhNjRfc3Jsel9kKCk7CisJCQl9CisJCQlpYTY0X3B0cihpb3JkLCBw
LT5pZmEsIHAtPml0aXIgPj4gMik7CisJCQlpYTY0X3NybHpfaSgpOworCQkJaWYgKGlvcmQgJiAw
eDEpIHsKKwkJCQlpYTY0X2l0cigweDEsIGksIHAtPmlmYSwgcC0+cHRlLCBwLT5pdGlyID4+IDIp
OworCQkJCWlhNjRfc3Jsel9pKCk7CisJCQl9CisJCQlpZiAoaW9yZCAmIDB4MikgeworCQkJCWlh
NjRfaXRyKDB4MiwgaSwgcC0+aWZhLCBwLT5wdGUsIHAtPml0aXIgPj4gMik7CisJCQkJaWE2NF9z
cmx6X2koKTsKKwkJCX0KKwkJCWlmIChvbGRfcnIgIT0gcC0+cnIpIHsKKwkJCQlpYTY0X3NldF9y
cihwLT5pZmEsIG9sZF9ycik7CisJCQkJaWE2NF9zcmx6X2QoKTsKKwkJCX0KKwkJfQorCX0KKwlp
YTY0X3NldF9wc3IocHNyKTsKK30KKwogLyoKICAqIGlhNjRfbWNhX2hhbmRsZXIKICAqCkBAIC0x
MjcxLDYgKzEzMTYsMTAgQEAgaWE2NF9tY2FfaGFuZGxlcihzdHJ1Y3QgcHRfcmVncyAqcmVncywg
c3RydWN0IHN3aXRjaF9zdGFjayAqc3csCiAJCW1vbmFyY2hfY3B1ID0gLTE7CiAjZW5kaWYKIAl9
CisJaWYgKF9fZ2V0X2NwdV92YXIoaWE2NF9tY2FfdHJfcmVsb2FkKSkgeworCQltY2FfaW5zZXJ0
X3RyKDB4MSk7IC8qUmVsb2FkIGR5bmFtaWMgaXRycyovCisJCW1jYV9pbnNlcnRfdHIoMHgyKTsg
LypSZWxvYWQgZHluYW1pYyBpdHJzKi8KKwl9CiAJaWYgKG5vdGlmeV9kaWUoRElFX01DQV9NT05B
UkNIX0xFQVZFLCAiTUNBIiwgcmVncywgKGxvbmcpJm5kLCAwLCByZWNvdmVyKQogCQkJPT0gTk9U
SUZZX1NUT1ApCiAJCWlhNjRfbWNhX3NwaW4oX19mdW5jX18pOwpkaWZmIC0tZ2l0IGEvYXJjaC9p
YTY0L2tlcm5lbC9tY2FfYXNtLlMgYi9hcmNoL2lhNjQva2VybmVsL21jYV9hc20uUwppbmRleCA4
YmM3ZDI1Li5hMDZkNDY1IDEwMDY0NAotLS0gYS9hcmNoL2lhNjQva2VybmVsL21jYV9hc20uUwor
KysgYi9hcmNoL2lhNjQva2VybmVsL21jYV9hc20uUwpAQCAtMjE5LDggKzIxOSwxMyBAQCBpYTY0
X3JlbG9hZF90cjoKIAltb3YgcjIwPUlBNjRfVFJfQ1VSUkVOVF9TVEFDSwogCTs7CiAJaXRyLmQg
ZHRyW3IyMF09cjE2CisJR0VUX1RISVNfUEFERFIocjIsIGlhNjRfbWNhX3RyX3JlbG9hZCkKKwlt
b3YgcjE4ID0gMQogCTs7CiAJc3Jsei5kCisJOzsKKwlzdDggW3IyXSA9cjE4CisJOzsKIAogZG9u
ZV90bGJfcHVyZ2VfYW5kX3JlbG9hZDoKIApkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L21tL3RsYi5j
IGIvYXJjaC9pYTY0L21tL3RsYi5jCmluZGV4IDY1NWRhMjQuLjM5Mjg2NmEgMTAwNjQ0Ci0tLSBh
L2FyY2gvaWE2NC9tbS90bGIuYworKysgYi9hcmNoL2lhNjQvbW0vdGxiLmMKQEAgLTI2LDYgKzI2
LDggQEAKICNpbmNsdWRlIDxhc20vcGFsLmg+CiAjaW5jbHVkZSA8YXNtL3RsYmZsdXNoLmg+CiAj
aW5jbHVkZSA8YXNtL2RtYS5oPgorI2luY2x1ZGUgPGFzbS9wcm9jZXNzb3IuaD4KKyNpbmNsdWRl
IDxhc20vdGxiLmg+CiAKIHN0YXRpYyBzdHJ1Y3QgewogCXVuc2lnbmVkIGxvbmcgbWFzazsJLyog
bWFzayBvZiBzdXBwb3J0ZWQgcHVyZ2UgcGFnZS1zaXplcyAqLwpAQCAtMzksNiArNDEsMTAgQEAg
c3RydWN0IGlhNjRfY3R4IGlhNjRfY3R4ID0gewogfTsKIAogREVGSU5FX1BFUl9DUFUodTgsIGlh
NjRfbmVlZF90bGJfZmx1c2gpOworREVGSU5FX1BFUl9DUFUodTgsIGlhNjRfdHJfbnVtKTsgIC8q
TnVtYmVyIG9mIFRSIHNsb3RzIGluIGN1cnJlbnQgcHJvY2Vzc29yKi8KK0RFRklORV9QRVJfQ1BV
KHU4LCBpYTY0X3RyX3VzZWQpOyAvKk1heCBTbG90IG51bWJlciB1c2VkIGJ5IGtlcm5lbCovCisK
K3N0cnVjdCBpYTY0X3RyX2VudHJ5IF9fcGVyX2NwdV9pZHRyc1tOUl9DUFVTXVsyXVtJQTY0X1RS
X0FMTE9DX01BWF07CiAKIC8qCiAgKiBJbml0aWFsaXplcyB0aGUgaWE2NF9jdHguYml0bWFwIGFy
cmF5IGJhc2VkIG9uIG1heF9jdHgrMS4KQEAgLTE5MCw2ICsxOTYsOSBAQCBpYTY0X3RsYl9pbml0
ICh2b2lkKQogCWlhNjRfcHRjZV9pbmZvX3QgdW5pbml0aWFsaXplZF92YXIocHRjZV9pbmZvKTsg
LyogR0NDIGJlIHF1aWV0ICovCiAJdW5zaWduZWQgbG9uZyB0cl9wZ2JpdHM7CiAJbG9uZyBzdGF0
dXM7CisJcGFsX3ZtX2luZm9fMV91X3Qgdm1faW5mb18xOworCXBhbF92bV9pbmZvXzJfdV90IHZt
X2luZm9fMjsKKwlpbnQgY3B1ID0gc21wX3Byb2Nlc3Nvcl9pZCgpOwogCiAJaWYgKChzdGF0dXMg
PSBpYTY0X3BhbF92bV9wYWdlX3NpemUoJnRyX3BnYml0cywgJnB1cmdlLm1hc2spKSAhPSAwKSB7
CiAJCXByaW50ayhLRVJOX0VSUiAiUEFMX1ZNX1BBR0VfU0laRSBmYWlsZWQgd2l0aCBzdGF0dXM9
JWxkOyAiCkBAIC0yMDYsNCArMjE1LDE5MSBAQCBpYTY0X3RsYl9pbml0ICh2b2lkKQogCWxvY2Fs
X2NwdV9kYXRhLT5wdGNlX3N0cmlkZVsxXSA9IHB0Y2VfaW5mby5zdHJpZGVbMV07CiAKIAlsb2Nh
bF9mbHVzaF90bGJfYWxsKCk7CS8qIG51a2UgbGVmdCBvdmVycyBmcm9tIGJvb3RzdHJhcHBpbmcu
Li4gKi8KKwlzdGF0dXMgPSBpYTY0X3BhbF92bV9zdW1tYXJ5KCZ2bV9pbmZvXzEsICZ2bV9pbmZv
XzIpOworCisJaWYgKHN0YXR1cykgeworCQlwcmludGsoS0VSTl9FUlIgImlhNjRfcGFsX3ZtX3N1
bW1hcnk9JWxkXG4iLCBzdGF0dXMpOworCQlwZXJfY3B1KGlhNjRfdHJfbnVtLCBjcHUpID0gODsK
KwkJcmV0dXJuOworCX0KKwlwZXJfY3B1KGlhNjRfdHJfbnVtLCBjcHUpID0gdm1faW5mb18xLnBh
bF92bV9pbmZvXzFfcy5tYXhfaXRyX2VudHJ5KzE7CisJaWYgKHBlcl9jcHUoaWE2NF90cl9udW0s
IGNwdSkgPgorCQkJCSh2bV9pbmZvXzEucGFsX3ZtX2luZm9fMV9zLm1heF9kdHJfZW50cnkrMSkp
CisJCXBlcl9jcHUoaWE2NF90cl9udW0sIGNwdSkgPQorCQkJCXZtX2luZm9fMS5wYWxfdm1faW5m
b18xX3MubWF4X2R0cl9lbnRyeSsxOworCWlmIChwZXJfY3B1KGlhNjRfdHJfbnVtLCBjcHUpID4g
SUE2NF9UUl9BTExPQ19NQVgpIHsKKwkJcGVyX2NwdShpYTY0X3RyX251bSwgY3B1KSA9IElBNjRf
VFJfQUxMT0NfTUFYOworCQlwcmludGsoS0VSTl9ERUJVRyJUUiByZWdpc3RlciBudW1iZXIgZXhj
ZWVkcyBJQTY0X1RSX0FMTE9DX01BWCEiCisJCQkiSUE2NF9UUl9BTExPQ19NQVggc2hvdWxkIGJl
IGV4dGVuZGVkXG4iKTsKKwl9Cit9CisKKy8qCisgKiBpc190cl9vdmVybGFwCisgKgorICogQ2hl
Y2sgb3ZlcmxhcCB3aXRoIGluc2VydGVkIFRScy4KKyAqLworc3RhdGljIGludCBpc190cl9vdmVy
bGFwKHN0cnVjdCBpYTY0X3RyX2VudHJ5ICpwLCB1NjQgdmEsIHU2NCBsb2dfc2l6ZSkKK3sKKwl1
NjQgdHJfbG9nX3NpemU7CisJdTY0IHRyX2VuZDsKKwl1NjQgdmFfcnIgPSBpYTY0X2dldF9ycih2
YSk7CisJdTY0IHZhX3JpZCA9IFJSX1RPX1JJRCh2YV9ycik7CisJdTY0IHZhX2VuZCA9IHZhICsg
KDE8PGxvZ19zaXplKSAtIDE7CisKKwlpZiAodmFfcmlkICE9IFJSX1RPX1JJRChwLT5ycikpCisJ
CXJldHVybiAwOworCXRyX2xvZ19zaXplID0gKHAtPml0aXIgJiAweGZmKSA+PiAyOworCXRyX2Vu
ZCA9IHAtPmlmYSArICgxPDx0cl9sb2dfc2l6ZSkgLSAxOworCisJaWYgKHZhID4gdHJfZW5kIHx8
IHAtPmlmYSA+IHZhX2VuZCkKKwkJcmV0dXJuIDA7CisJcmV0dXJuIDE7CisKK30KKworLyoKKyAq
IGlhNjRfaW5zZXJ0X3RyIGluIHZpcnR1YWwgbW9kZS4gQWxsb2NhdGUgYSBUUiBzbG90CisgKgor
ICogdGFyZ2V0X21hc2sgOiAweDEgOiBpdHIsIDB4MiA6IGR0ciwgMHgzIDogaWR0cgorICoKKyAq
IHZhIAk6IHZpcnR1YWwgYWRkcmVzcy4KKyAqIHB0ZSAJOiBwdGUgZW50cmllcyBpbnNlcnRlZC4K
KyAqIGxvZ19zaXplOiByYW5nZSB0byBiZSBjb3ZlcmVkLgorICoKKyAqIFJldHVybiB2YWx1ZTog
IDwwIDogIGVycm9yIE5vLgorICoKKyAqCQkgID49MCA6IHNsb3QgbnVtYmVyIGFsbG9jYXRlZCBm
b3IgVFIuCisgKi8KK2ludCBpYTY0X2l0cl9lbnRyeSh1NjQgdGFyZ2V0X21hc2ssIHU2NCB2YSwg
dTY0IHB0ZSwgdTY0IGxvZ19zaXplKQoreworCWludCBpLCByOworCXVuc2lnbmVkIGxvbmcgcHNy
OworCXN0cnVjdCBpYTY0X3RyX2VudHJ5ICpwOworCWludCBjcHUgPSBzbXBfcHJvY2Vzc29yX2lk
KCk7CisKKwlyID0gLUVJTlZBTDsKKwkvKkNoZWNrIG92ZXJsYXAgd2l0aCBleGlzdGluZyBUUiBl
bnRyaWVzKi8KKwlpZiAodGFyZ2V0X21hc2smMHgxKSB7CisJCXAgPSAmX19wZXJfY3B1X2lkdHJz
W2NwdV1bMF1bMF07CisJCWZvciAoaSA9IElBNjRfVFJfQUxMT0NfQkFTRTsgaSA8PSBwZXJfY3B1
KGlhNjRfdHJfdXNlZCwgY3B1KTsKKwkJCQkJCQkJaSsrLCBwKyspIHsKKwkJCWlmIChwLT5wdGUm
MHgxKQorCQkJCWlmIChpc190cl9vdmVybGFwKHAsIHZhLCBsb2dfc2l6ZSkpIHsKKwkJCQkJcHJp
bnRrKEtFUk5fREVCVUciT3ZlcmxhcHBlZCBFbnRyeSIKKwkJCQkJCSJJbnNlcnRlZCBmb3IgVFIg
UmVpZ3N0ZXIhISIpOworCQkJCQlnb3RvIG91dDsKKwkJCX0KKwkJfQorCX0KKwlpZiAodGFyZ2V0
X21hc2smMHgyKSB7CisJCXAgPSAmX19wZXJfY3B1X2lkdHJzW2NwdV1bMV1bMF07CisJCWZvciAo
aSA9IElBNjRfVFJfQUxMT0NfQkFTRTsgaSA8PSBwZXJfY3B1KGlhNjRfdHJfdXNlZCwgY3B1KTsK
KwkJCQkJCQkJaSsrLCBwKyspIHsKKwkJCWlmIChwLT5wdGUmMHgxKQorCQkJCWlmIChpc190cl9v
dmVybGFwKHAsIHZhLCBsb2dfc2l6ZSkpIHsKKwkJCQkJcHJpbnRrKEtFUk5fREVCVUciT3Zlcmxh
cHBlZCBFbnRyeSIKKwkJCQkJCSJJbnNlcnRlZCBmb3IgVFIgUmVpZ3N0ZXIhISIpOworCQkJCQln
b3RvIG91dDsKKwkJCQl9CisJCX0KKwl9CisKKwlmb3IgKGkgPSBJQTY0X1RSX0FMTE9DX0JBU0U7
IGkgPCBwZXJfY3B1KGlhNjRfdHJfbnVtLCBjcHUpOyBpKyspIHsKKwkJc3dpdGNoICh0YXJnZXRf
bWFzayAmIDB4MykgeworCQljYXNlIDE6CisJCQlpZiAoIShfX3Blcl9jcHVfaWR0cnNbY3B1XVsw
XVtpXS5wdGUmMHgxKSkKKwkJCQlnb3RvIGZvdW5kOworCQkJY29udGludWU7CisJCWNhc2UgMjoK
KwkJCWlmICghKF9fcGVyX2NwdV9pZHRyc1tjcHVdWzFdW2ldLnB0ZSYweDEpKQorCQkJCWdvdG8g
Zm91bmQ7CisJCQljb250aW51ZTsKKwkJY2FzZSAzOgorCQkJaWYgKCEoX19wZXJfY3B1X2lkdHJz
W2NwdV1bMF1baV0ucHRlJjB4MSkgJiYKKwkJCQkhKF9fcGVyX2NwdV9pZHRyc1tjcHVdWzFdW2ld
LnB0ZSYweDEpKQorCQkJCWdvdG8gZm91bmQ7CisJCQljb250aW51ZTsKKwkJZGVmYXVsdDoKKwkJ
CXIgPSAtRUlOVkFMOworCQkJZ290byBvdXQ7CisJCX0KKwl9Citmb3VuZDoKKwlpZiAoaSA+PSBw
ZXJfY3B1KGlhNjRfdHJfbnVtLCBjcHUpKSB7CisJCXIgPSAtRUJVU1k7CisJCWdvdG8gb3V0Owor
CX0KKworCS8qUmVjb3JkIHRyIGluZm8gZm9yIG1jYSBoYW5kZXIgdXNlISovCisJaWYgKGkgPiBw
ZXJfY3B1KGlhNjRfdHJfdXNlZCwgY3B1KSkKKwkJcGVyX2NwdShpYTY0X3RyX3VzZWQsIGNwdSkg
PSBpOworCisJcHNyID0gaWE2NF9jbGVhcl9pYygpOworCWlmICh0YXJnZXRfbWFzayAmIDB4MSkg
eworCQlpYTY0X2l0cigweDEsIGksIHZhLCBwdGUsIGxvZ19zaXplKTsKKwkJaWE2NF9zcmx6X2ko
KTsKKwkJcCA9ICZfX3Blcl9jcHVfaWR0cnNbY3B1XVswXVtpXTsKKwkJcC0+aWZhID0gdmE7CisJ
CXAtPnB0ZSA9IHB0ZTsKKwkJcC0+aXRpciA9IGxvZ19zaXplIDw8IDI7CisJCXAtPnJyID0gaWE2
NF9nZXRfcnIodmEpOworCX0KKwlpZiAodGFyZ2V0X21hc2sgJiAweDIpIHsKKwkJaWE2NF9pdHIo
MHgyLCBpLCB2YSwgcHRlLCBsb2dfc2l6ZSk7CisJCWlhNjRfc3Jsel9pKCk7CisJCXAgPSAmX19w
ZXJfY3B1X2lkdHJzW2NwdV1bMV1baV07CisJCXAtPmlmYSA9IHZhOworCQlwLT5wdGUgPSBwdGU7
CisJCXAtPml0aXIgPSBsb2dfc2l6ZSA8PCAyOworCQlwLT5yciA9IGlhNjRfZ2V0X3JyKHZhKTsK
Kwl9CisJaWE2NF9zZXRfcHNyKHBzcik7CisJciA9IGk7CitvdXQ6CisJcmV0dXJuIHI7Cit9CitF
WFBPUlRfU1lNQk9MX0dQTChpYTY0X2l0cl9lbnRyeSk7CisKKy8qCisgKiBpYTY0X3B1cmdlX3Ry
CisgKgorICogdGFyZ2V0X21hc2s6IDB4MTogcHVyZ2UgaXRyLCAweDIgOiBwdXJnZSBkdHIsIDB4
MyBwdXJnZSBpZHRyLgorICoKKyAqIHNsb3Q6IHNsb3QgbnVtYmVyIHRvIGJlIGZyZWVkLgorICov
Cit2b2lkIGlhNjRfcHRyX2VudHJ5KHU2NCB0YXJnZXRfbWFzaywgaW50IHNsb3QpCit7CisJaW50
IGNwdSA9IHNtcF9wcm9jZXNzb3JfaWQoKTsKKwlpbnQgaTsKKwlzdHJ1Y3QgaWE2NF90cl9lbnRy
eSAqcDsKKworCWlmIChzbG90IDwgSUE2NF9UUl9BTExPQ19CQVNFIHx8IHNsb3QgPj0gcGVyX2Nw
dShpYTY0X3RyX251bSwgY3B1KSkKKwkJcmV0dXJuOworCisJaWYgKHRhcmdldF9tYXNrJjB4MSkg
eworCQlwID0gJl9fcGVyX2NwdV9pZHRyc1tjcHVdWzBdW3Nsb3RdOworCQlpZiAoKHAtPnB0ZSYw
eDEpICYmIGlzX3RyX292ZXJsYXAocCwgcC0+aWZhLCBwLT5pdGlyPj4yKSkgeworCQkJcC0+cHRl
ID0gMDsKKwkJCWlhNjRfcHRyKDB4MSwgcC0+aWZhLCBwLT5pdGlyPj4yKTsKKwkJCWlhNjRfc3Js
el9pKCk7CisJCX0KKwl9CisKKwlpZiAodGFyZ2V0X21hc2smMHgyKSB7CisJCXAgPSAmX19wZXJf
Y3B1X2lkdHJzW2NwdV1bMV1bc2xvdF07CisJCWlmICgocC0+cHRlJjB4MSkgJiYgaXNfdHJfb3Zl
cmxhcChwLCBwLT5pZmEsIHAtPml0aXI+PjIpKSB7CisJCQlwLT5wdGUgPSAwOworCQkJaWE2NF9w
dHIoMHgyLCBwLT5pZmEsIHAtPml0aXI+PjIpOworCQkJaWE2NF9zcmx6X2koKTsKKwkJfQorCX0K
KworCWZvciAoaSA9IHBlcl9jcHUoaWE2NF90cl91c2VkLCBjcHUpOyBpID49IElBNjRfVFJfQUxM
T0NfQkFTRTsgaS0tKSB7CisJCWlmICgoX19wZXJfY3B1X2lkdHJzW2NwdV1bMF1baV0ucHRlJjB4
MSkgfHwKKwkJCQkoX19wZXJfY3B1X2lkdHJzW2NwdV1bMV1baV0ucHRlJjB4MSkpCisJCQlicmVh
azsKKwl9CisJcGVyX2NwdShpYTY0X3RyX3VzZWQsIGNwdSkgPSBpOwogfQorRVhQT1JUX1NZTUJP
TF9HUEwoaWE2NF9wdHJfZW50cnkpOwpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9hc20taWE2NC9rcmVn
cy5oIGIvaW5jbHVkZS9hc20taWE2NC9rcmVncy5oCmluZGV4IDdlNTVhNTguLmFlZmNkZmUgMTAw
NjQ0Ci0tLSBhL2luY2x1ZGUvYXNtLWlhNjQva3JlZ3MuaAorKysgYi9pbmNsdWRlL2FzbS1pYTY0
L2tyZWdzLmgKQEAgLTMxLDYgKzMxLDkgQEAKICNkZWZpbmUgSUE2NF9UUl9QQUxDT0RFCQkxCS8q
IGl0cjE6IG1hcHMgUEFMY29kZSBhcyByZXF1aXJlZCBieSBFRkkgKi8KICNkZWZpbmUgSUE2NF9U
Ul9DVVJSRU5UX1NUQUNLCTEJLyogZHRyMTogbWFwcyBrZXJuZWwncyBtZW1vcnktICYgcmVnaXN0
ZXItc3RhY2tzICovCiAKKyNkZWZpbmUgSUE2NF9UUl9BTExPQ19CQVNFCTIgCS8qIGl0ciZkdHI6
IEJhc2Ugb2YgZHluYW1pYyBUUiByZXNvdXJjZSovCisjZGVmaW5lIElBNjRfVFJfQUxMT0NfTUFY
CTMyIAkvKiBNYXggbnVtYmVyIGZvciBkeW5hbWljIHVzZSovCisKIC8qIFByb2Nlc3NvciBzdGF0
dXMgcmVnaXN0ZXIgYml0czogKi8KICNkZWZpbmUgSUE2NF9QU1JfQkVfQklUCQkxCiAjZGVmaW5l
IElBNjRfUFNSX1VQX0JJVAkJMgpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9hc20taWE2NC90bGIuaCBi
L2luY2x1ZGUvYXNtLWlhNjQvdGxiLmgKaW5kZXggMjZlZGNiNy4uZGUxZjgyOSAxMDA2NDQKLS0t
IGEvaW5jbHVkZS9hc20taWE2NC90bGIuaAorKysgYi9pbmNsdWRlL2FzbS1pYTY0L3RsYi5oCkBA
IC02NCw2ICs2NCwyMCBAQCBzdHJ1Y3QgbW11X2dhdGhlciB7CiAJc3RydWN0IHBhZ2UgCQkqcGFn
ZXNbRlJFRV9QVEVfTlJdOwogfTsKIAorc3RydWN0IGlhNjRfdHJfZW50cnkgeworCXU2NCBpZmE7
CisJdTY0IGl0aXI7CisJdTY0IHB0ZTsKKwl1NjQgcnI7Cit9OyAvKlJlY29yZCBmb3IgdHIgZW50
cnkhKi8KKworZXh0ZXJuIGludCBpYTY0X2l0cl9lbnRyeSh1NjQgdGFyZ2V0X21hc2ssIHU2NCB2
YSwgdTY0IHB0ZSwgdTY0IGxvZ19zaXplKTsKK2V4dGVybiB2b2lkIGlhNjRfcHRyX2VudHJ5KHU2
NCB0YXJnZXRfbWFzaywgaW50IHNsb3QpOworCitleHRlcm4gc3RydWN0IGlhNjRfdHJfZW50cnkg
X19wZXJfY3B1X2lkdHJzW05SX0NQVVNdWzJdW0lBNjRfVFJfQUxMT0NfTUFYXTsKKworI2RlZmlu
ZSBSUl9UT19SSUQocnIpICgocnIpPDwzMj4+NDApCisKIC8qIFVzZXJzIG9mIHRoZSBnZW5lcmlj
IFRMQiBzaG9vdGRvd24gY29kZSBtdXN0IGRlY2xhcmUgdGhpcyBzdG9yYWdlIHNwYWNlLiAqLwog
REVDTEFSRV9QRVJfQ1BVKHN0cnVjdCBtbXVfZ2F0aGVyLCBtbXVfZ2F0aGVycyk7CiAKLS0gCjEu
NS4yCgo=

------_=_NextPart_001_01C89308.A0DB709F--
