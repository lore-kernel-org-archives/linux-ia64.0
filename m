From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Wed, 21 Jan 2009 03:44:42 +0000
Subject: [PATCH 01/03]KVM: ia64: vTLB change for enabling windows 2008 boot.
Message-Id: <706158FABBBA044BAD4FE898A02E4BC2223BCE97@pdsmsx503.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="_002_706158FABBBA044BAD4FE898A02E4BC2223BCE97pdsmsx503ccrcor_"
List-Id: <linux-ia64.vger.kernel.org>
To: "kvm-ia64@vger.kernel.org" <kvm-ia64@vger.kernel.org>
Cc: Avi Kivity <avi@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

--_002_706158FABBBA044BAD4FE898A02E4BC2223BCE97pdsmsx503ccrcor_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 988aedcf2ad07273dd3a88b5c574ee13d845b020 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Thu, 15 Jan 2009 17:58:19 +0800
Subject: [PATCH] KVM: ia64: vTLB change for enabling windows 2008 boot.

Simply the logic of hash vTLB, and export kvm_gpa_to_mpa.

Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/vcpu.h |    4 ++--
 arch/ia64/kvm/vtlb.c |   39 +++++++++++++++++----------------------
 2 files changed, 19 insertions(+), 24 deletions(-)

diff --git a/arch/ia64/kvm/vcpu.h b/arch/ia64/kvm/vcpu.h
index b2f12a5..042af92 100644
--- a/arch/ia64/kvm/vcpu.h
+++ b/arch/ia64/kvm/vcpu.h
@@ -703,7 +703,7 @@ extern u64 guest_vhpt_lookup(u64 iha, u64 *pte);
 extern void thash_purge_entries(struct kvm_vcpu *v, u64 va, u64 ps);
 extern void thash_purge_entries_remote(struct kvm_vcpu *v, u64 va, u64 ps)=
;
 extern u64 translate_phy_pte(u64 *pte, u64 itir, u64 va);
-extern int thash_purge_and_insert(struct kvm_vcpu *v, u64 pte,
+extern void thash_purge_and_insert(struct kvm_vcpu *v, u64 pte,
 		u64 itir, u64 ifa, int type);
 extern void thash_purge_all(struct kvm_vcpu *v);
 extern struct thash_data *vtlb_lookup(struct kvm_vcpu *v,
@@ -738,7 +738,7 @@ void kvm_init_vhpt(struct kvm_vcpu *v);
 void thash_init(struct thash_cb *hcb, u64 sz);
=20
 void panic_vm(struct kvm_vcpu *v, const char *fmt, ...);
-
+u64 kvm_gpa_to_mpa(u64 gpa);
 extern u64 ia64_call_vsa(u64 proc, u64 arg1, u64 arg2, u64 arg3,
 		u64 arg4, u64 arg5, u64 arg6, u64 arg7);
=20
diff --git a/arch/ia64/kvm/vtlb.c b/arch/ia64/kvm/vtlb.c
index ac94867..38232b3 100644
--- a/arch/ia64/kvm/vtlb.c
+++ b/arch/ia64/kvm/vtlb.c
@@ -164,11 +164,11 @@ static void vhpt_insert(u64 pte, u64 itir, u64 ifa, u=
64 gpte)
 	unsigned long ps, gpaddr;
=20
 	ps =3D itir_ps(itir);
+	rr.val =3D ia64_get_rr(ifa);
=20
-	gpaddr =3D ((gpte & _PAGE_PPN_MASK) >> ps << ps) |
-		(ifa & ((1UL << ps) - 1));
+	 gpaddr =3D ((gpte & _PAGE_PPN_MASK) >> ps << ps) |
+					(ifa & ((1UL << ps) - 1));
=20
-	rr.val =3D ia64_get_rr(ifa);
 	head =3D (struct thash_data *)ia64_thash(ifa);
 	head->etag =3D INVALID_TI_TAG;
 	ia64_mf();
@@ -412,16 +412,14 @@ u64 translate_phy_pte(u64 *pte, u64 itir, u64 va)
=20
 /*
  * Purge overlap TCs and then insert the new entry to emulate itc ops.
- *    Notes: Only TC entry can purge and insert.
- *    1 indicates this is MMIO
+ * Notes: Only TC entry can purge and insert.
  */
-int thash_purge_and_insert(struct kvm_vcpu *v, u64 pte, u64 itir,
+void  thash_purge_and_insert(struct kvm_vcpu *v, u64 pte, u64 itir,
 						u64 ifa, int type)
 {
 	u64 ps;
 	u64 phy_pte, io_mask, index;
 	union ia64_rr vrr, mrr;
-	int ret =3D 0;
=20
 	ps =3D itir_ps(itir);
 	vrr.val =3D vcpu_get_rr(v, ifa);
@@ -441,25 +439,19 @@ int thash_purge_and_insert(struct kvm_vcpu *v, u64 pt=
e, u64 itir,
 		phy_pte &=3D ~_PAGE_MA_MASK;
 	}
=20
-	if (pte & VTLB_PTE_IO)
-		ret =3D 1;
-
 	vtlb_purge(v, ifa, ps);
 	vhpt_purge(v, ifa, ps);
=20
-	if (ps =3D=3D mrr.ps) {
-		if (!(pte&VTLB_PTE_IO)) {
-			vhpt_insert(phy_pte, itir, ifa, pte);
-		} else {
-			vtlb_insert(v, pte, itir, ifa);
-			vcpu_quick_region_set(VMX(v, tc_regions), ifa);
-		}
-	} else if (ps > mrr.ps) {
+	if ((ps !=3D mrr.ps) || (pte & VTLB_PTE_IO)) {
 		vtlb_insert(v, pte, itir, ifa);
 		vcpu_quick_region_set(VMX(v, tc_regions), ifa);
-		if (!(pte&VTLB_PTE_IO))
-			vhpt_insert(phy_pte, itir, ifa, pte);
-	} else {
+	}
+	if (pte & VTLB_PTE_IO)
+		return;
+
+	if (ps >=3D mrr.ps)
+		vhpt_insert(phy_pte, itir, ifa, pte);
+	else {
 		u64 psr;
 		phy_pte  &=3D ~PAGE_FLAGS_RV_MASK;
 		psr =3D ia64_clear_ic();
@@ -469,7 +461,6 @@ int thash_purge_and_insert(struct kvm_vcpu *v, u64 pte,=
 u64 itir,
 	if (!(pte&VTLB_PTE_IO))
 		mark_pages_dirty(v, pte, ps);
=20
-	return ret;
 }
=20
 /*
@@ -570,6 +561,10 @@ void thash_init(struct thash_cb *hcb, u64 sz)
 u64 kvm_get_mpt_entry(u64 gpfn)
 {
 	u64 *base =3D (u64 *) KVM_P2M_BASE;
+
+	if (gpfn >=3D (KVM_P2M_SIZE >> 3))
+		panic_vm(current_vcpu, "Invalid gpfn =3D%lx\n", gpfn);
+
 	return *(base + gpfn);
 }
=20
--=20
1.6.0

--_002_706158FABBBA044BAD4FE898A02E4BC2223BCE97pdsmsx503ccrcor_
Content-Type: application/octet-stream;
	name="0001-KVM-ia64-vTLB-change-for-enabling-windows-2008-boo.patch"
Content-Description: 0001-KVM-ia64-vTLB-change-for-enabling-windows-2008-boo.patch
Content-Disposition: attachment;
	filename="0001-KVM-ia64-vTLB-change-for-enabling-windows-2008-boo.patch";
	size=3972; creation-date="Wed, 21 Jan 2009 11:37:35 GMT";
	modification-date="Wed, 21 Jan 2009 11:37:35 GMT"
Content-Transfer-Encoding: base64

RnJvbSA5ODhhZWRjZjJhZDA3MjczZGQzYTg4YjVjNTc0ZWUxM2Q4NDViMDIwIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVGh1LCAxNSBKYW4gMjAwOSAxNzo1ODoxOSArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEtWTTogaWE2NDogdlRMQiBjaGFuZ2UgZm9yIGVuYWJsaW5nIHdpbmRvd3MgMjAwOCBib290LgoK
U2ltcGx5IHRoZSBsb2dpYyBvZiBoYXNoIHZUTEIsIGFuZCBleHBvcnQga3ZtX2dwYV90b19tcGEu
CgpTaWduZWQtb2ZmLWJ5OiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNvbT4K
LS0tCiBhcmNoL2lhNjQva3ZtL3ZjcHUuaCB8ICAgIDQgKystLQogYXJjaC9pYTY0L2t2bS92dGxi
LmMgfCAgIDM5ICsrKysrKysrKysrKysrKysrLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQogMiBmaWxl
cyBjaGFuZ2VkLCAxOSBpbnNlcnRpb25zKCspLCAyNCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQg
YS9hcmNoL2lhNjQva3ZtL3ZjcHUuaCBiL2FyY2gvaWE2NC9rdm0vdmNwdS5oCmluZGV4IGIyZjEy
YTUuLjA0MmFmOTIgMTAwNjQ0Ci0tLSBhL2FyY2gvaWE2NC9rdm0vdmNwdS5oCisrKyBiL2FyY2gv
aWE2NC9rdm0vdmNwdS5oCkBAIC03MDMsNyArNzAzLDcgQEAgZXh0ZXJuIHU2NCBndWVzdF92aHB0
X2xvb2t1cCh1NjQgaWhhLCB1NjQgKnB0ZSk7CiBleHRlcm4gdm9pZCB0aGFzaF9wdXJnZV9lbnRy
aWVzKHN0cnVjdCBrdm1fdmNwdSAqdiwgdTY0IHZhLCB1NjQgcHMpOwogZXh0ZXJuIHZvaWQgdGhh
c2hfcHVyZ2VfZW50cmllc19yZW1vdGUoc3RydWN0IGt2bV92Y3B1ICp2LCB1NjQgdmEsIHU2NCBw
cyk7CiBleHRlcm4gdTY0IHRyYW5zbGF0ZV9waHlfcHRlKHU2NCAqcHRlLCB1NjQgaXRpciwgdTY0
IHZhKTsKLWV4dGVybiBpbnQgdGhhc2hfcHVyZ2VfYW5kX2luc2VydChzdHJ1Y3Qga3ZtX3ZjcHUg
KnYsIHU2NCBwdGUsCitleHRlcm4gdm9pZCB0aGFzaF9wdXJnZV9hbmRfaW5zZXJ0KHN0cnVjdCBr
dm1fdmNwdSAqdiwgdTY0IHB0ZSwKIAkJdTY0IGl0aXIsIHU2NCBpZmEsIGludCB0eXBlKTsKIGV4
dGVybiB2b2lkIHRoYXNoX3B1cmdlX2FsbChzdHJ1Y3Qga3ZtX3ZjcHUgKnYpOwogZXh0ZXJuIHN0
cnVjdCB0aGFzaF9kYXRhICp2dGxiX2xvb2t1cChzdHJ1Y3Qga3ZtX3ZjcHUgKnYsCkBAIC03Mzgs
NyArNzM4LDcgQEAgdm9pZCBrdm1faW5pdF92aHB0KHN0cnVjdCBrdm1fdmNwdSAqdik7CiB2b2lk
IHRoYXNoX2luaXQoc3RydWN0IHRoYXNoX2NiICpoY2IsIHU2NCBzeik7CiAKIHZvaWQgcGFuaWNf
dm0oc3RydWN0IGt2bV92Y3B1ICp2LCBjb25zdCBjaGFyICpmbXQsIC4uLik7Ci0KK3U2NCBrdm1f
Z3BhX3RvX21wYSh1NjQgZ3BhKTsKIGV4dGVybiB1NjQgaWE2NF9jYWxsX3ZzYSh1NjQgcHJvYywg
dTY0IGFyZzEsIHU2NCBhcmcyLCB1NjQgYXJnMywKIAkJdTY0IGFyZzQsIHU2NCBhcmc1LCB1NjQg
YXJnNiwgdTY0IGFyZzcpOwogCmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva3ZtL3Z0bGIuYyBiL2Fy
Y2gvaWE2NC9rdm0vdnRsYi5jCmluZGV4IGFjOTQ4NjcuLjM4MjMyYjMgMTAwNjQ0Ci0tLSBhL2Fy
Y2gvaWE2NC9rdm0vdnRsYi5jCisrKyBiL2FyY2gvaWE2NC9rdm0vdnRsYi5jCkBAIC0xNjQsMTEg
KzE2NCwxMSBAQCBzdGF0aWMgdm9pZCB2aHB0X2luc2VydCh1NjQgcHRlLCB1NjQgaXRpciwgdTY0
IGlmYSwgdTY0IGdwdGUpCiAJdW5zaWduZWQgbG9uZyBwcywgZ3BhZGRyOwogCiAJcHMgPSBpdGly
X3BzKGl0aXIpOworCXJyLnZhbCA9IGlhNjRfZ2V0X3JyKGlmYSk7CiAKLQlncGFkZHIgPSAoKGdw
dGUgJiBfUEFHRV9QUE5fTUFTSykgPj4gcHMgPDwgcHMpIHwKLQkJKGlmYSAmICgoMVVMIDw8IHBz
KSAtIDEpKTsKKwkgZ3BhZGRyID0gKChncHRlICYgX1BBR0VfUFBOX01BU0spID4+IHBzIDw8IHBz
KSB8CisJCQkJCShpZmEgJiAoKDFVTCA8PCBwcykgLSAxKSk7CiAKLQlyci52YWwgPSBpYTY0X2dl
dF9ycihpZmEpOwogCWhlYWQgPSAoc3RydWN0IHRoYXNoX2RhdGEgKilpYTY0X3RoYXNoKGlmYSk7
CiAJaGVhZC0+ZXRhZyA9IElOVkFMSURfVElfVEFHOwogCWlhNjRfbWYoKTsKQEAgLTQxMiwxNiAr
NDEyLDE0IEBAIHU2NCB0cmFuc2xhdGVfcGh5X3B0ZSh1NjQgKnB0ZSwgdTY0IGl0aXIsIHU2NCB2
YSkKIAogLyoKICAqIFB1cmdlIG92ZXJsYXAgVENzIGFuZCB0aGVuIGluc2VydCB0aGUgbmV3IGVu
dHJ5IHRvIGVtdWxhdGUgaXRjIG9wcy4KLSAqICAgIE5vdGVzOiBPbmx5IFRDIGVudHJ5IGNhbiBw
dXJnZSBhbmQgaW5zZXJ0LgotICogICAgMSBpbmRpY2F0ZXMgdGhpcyBpcyBNTUlPCisgKiBOb3Rl
czogT25seSBUQyBlbnRyeSBjYW4gcHVyZ2UgYW5kIGluc2VydC4KICAqLwotaW50IHRoYXNoX3B1
cmdlX2FuZF9pbnNlcnQoc3RydWN0IGt2bV92Y3B1ICp2LCB1NjQgcHRlLCB1NjQgaXRpciwKK3Zv
aWQgIHRoYXNoX3B1cmdlX2FuZF9pbnNlcnQoc3RydWN0IGt2bV92Y3B1ICp2LCB1NjQgcHRlLCB1
NjQgaXRpciwKIAkJCQkJCXU2NCBpZmEsIGludCB0eXBlKQogewogCXU2NCBwczsKIAl1NjQgcGh5
X3B0ZSwgaW9fbWFzaywgaW5kZXg7CiAJdW5pb24gaWE2NF9yciB2cnIsIG1ycjsKLQlpbnQgcmV0
ID0gMDsKIAogCXBzID0gaXRpcl9wcyhpdGlyKTsKIAl2cnIudmFsID0gdmNwdV9nZXRfcnIodiwg
aWZhKTsKQEAgLTQ0MSwyNSArNDM5LDE5IEBAIGludCB0aGFzaF9wdXJnZV9hbmRfaW5zZXJ0KHN0
cnVjdCBrdm1fdmNwdSAqdiwgdTY0IHB0ZSwgdTY0IGl0aXIsCiAJCXBoeV9wdGUgJj0gfl9QQUdF
X01BX01BU0s7CiAJfQogCi0JaWYgKHB0ZSAmIFZUTEJfUFRFX0lPKQotCQlyZXQgPSAxOwotCiAJ
dnRsYl9wdXJnZSh2LCBpZmEsIHBzKTsKIAl2aHB0X3B1cmdlKHYsIGlmYSwgcHMpOwogCi0JaWYg
KHBzID09IG1yci5wcykgewotCQlpZiAoIShwdGUmVlRMQl9QVEVfSU8pKSB7Ci0JCQl2aHB0X2lu
c2VydChwaHlfcHRlLCBpdGlyLCBpZmEsIHB0ZSk7Ci0JCX0gZWxzZSB7Ci0JCQl2dGxiX2luc2Vy
dCh2LCBwdGUsIGl0aXIsIGlmYSk7Ci0JCQl2Y3B1X3F1aWNrX3JlZ2lvbl9zZXQoVk1YKHYsIHRj
X3JlZ2lvbnMpLCBpZmEpOwotCQl9Ci0JfSBlbHNlIGlmIChwcyA+IG1yci5wcykgeworCWlmICgo
cHMgIT0gbXJyLnBzKSB8fCAocHRlICYgVlRMQl9QVEVfSU8pKSB7CiAJCXZ0bGJfaW5zZXJ0KHYs
IHB0ZSwgaXRpciwgaWZhKTsKIAkJdmNwdV9xdWlja19yZWdpb25fc2V0KFZNWCh2LCB0Y19yZWdp
b25zKSwgaWZhKTsKLQkJaWYgKCEocHRlJlZUTEJfUFRFX0lPKSkKLQkJCXZocHRfaW5zZXJ0KHBo
eV9wdGUsIGl0aXIsIGlmYSwgcHRlKTsKLQl9IGVsc2UgeworCX0KKwlpZiAocHRlICYgVlRMQl9Q
VEVfSU8pCisJCXJldHVybjsKKworCWlmIChwcyA+PSBtcnIucHMpCisJCXZocHRfaW5zZXJ0KHBo
eV9wdGUsIGl0aXIsIGlmYSwgcHRlKTsKKwllbHNlIHsKIAkJdTY0IHBzcjsKIAkJcGh5X3B0ZSAg
Jj0gflBBR0VfRkxBR1NfUlZfTUFTSzsKIAkJcHNyID0gaWE2NF9jbGVhcl9pYygpOwpAQCAtNDY5
LDcgKzQ2MSw2IEBAIGludCB0aGFzaF9wdXJnZV9hbmRfaW5zZXJ0KHN0cnVjdCBrdm1fdmNwdSAq
diwgdTY0IHB0ZSwgdTY0IGl0aXIsCiAJaWYgKCEocHRlJlZUTEJfUFRFX0lPKSkKIAkJbWFya19w
YWdlc19kaXJ0eSh2LCBwdGUsIHBzKTsKIAotCXJldHVybiByZXQ7CiB9CiAKIC8qCkBAIC01NzAs
NiArNTYxLDEwIEBAIHZvaWQgdGhhc2hfaW5pdChzdHJ1Y3QgdGhhc2hfY2IgKmhjYiwgdTY0IHN6
KQogdTY0IGt2bV9nZXRfbXB0X2VudHJ5KHU2NCBncGZuKQogewogCXU2NCAqYmFzZSA9ICh1NjQg
KikgS1ZNX1AyTV9CQVNFOworCisJaWYgKGdwZm4gPj0gKEtWTV9QMk1fU0laRSA+PiAzKSkKKwkJ
cGFuaWNfdm0oY3VycmVudF92Y3B1LCAiSW52YWxpZCBncGZuID0lbHhcbiIsIGdwZm4pOworCiAJ
cmV0dXJuICooYmFzZSArIGdwZm4pOwogfQogCi0tIAoxLjYuMAoK

--_002_706158FABBBA044BAD4FE898A02E4BC2223BCE97pdsmsx503ccrcor_--
