From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Wed, 21 Jan 2009 03:44:49 +0000
Subject: [PATCH 02/03] KVM: ia64: Add the support for translating PAL Call's
Message-Id: <706158FABBBA044BAD4FE898A02E4BC2223BCE98@pdsmsx503.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="_002_706158FABBBA044BAD4FE898A02E4BC2223BCE98pdsmsx503ccrcor_"
List-Id: <linux-ia64.vger.kernel.org>
To: "kvm-ia64@vger.kernel.org" <kvm-ia64@vger.kernel.org>
Cc: Avi Kivity <avi@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

--_002_706158FABBBA044BAD4FE898A02E4BC2223BCE98pdsmsx503ccrcor_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 635b75a4df55771f65ce7c40268a18d528114769 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Thu, 15 Jan 2009 18:08:36 +0800
Subject: [PATCH] KVM: ia64: Add the support for translating PAL Call's poin=
ter args.

Add the support to translate PAL Call's pointer args.

Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/process.c |   48 +++++++++++++++++++++++++++++++++++++++++++=
+--
 1 files changed, 45 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kvm/process.c b/arch/ia64/kvm/process.c
index e206244..6ed0347 100644
--- a/arch/ia64/kvm/process.c
+++ b/arch/ia64/kvm/process.c
@@ -549,18 +549,60 @@ void reflect_interruption(u64 ifa, u64 isr, u64 iim,
 	inject_guest_interruption(vcpu, vector);
 }
=20
+static unsigned long kvm_trans_pal_call_args(struct kvm_vcpu *vcpu,
+						unsigned long arg)
+{
+	struct thash_data *data;
+	unsigned long gpa, poff;
+
+	if (!is_physical_mode(vcpu)) {
+		/* Depends on caller to provide the DTR or DTC mapping.*/
+		data =3D vtlb_lookup(vcpu, arg, D_TLB);
+		if (data)
+			gpa =3D data->page_flags & _PAGE_PPN_MASK;
+		else {
+			data =3D vhpt_lookup(arg);
+			if (!data)
+				return 0;
+			gpa =3D data->gpaddr & _PAGE_PPN_MASK;
+		}
+
+		poff =3D arg & (PSIZE(data->ps) - 1);
+		arg =3D PAGEALIGN(gpa, data->ps) | poff;
+	}
+	arg =3D kvm_gpa_to_mpa(arg << 1 >> 1);
+
+	return (unsigned long)__va(arg);
+}
+
 static void set_pal_call_data(struct kvm_vcpu *vcpu)
 {
 	struct exit_ctl_data *p =3D &vcpu->arch.exit_data;
+	unsigned long gr28 =3D vcpu_get_gr(vcpu, 28);
+	unsigned long gr29 =3D vcpu_get_gr(vcpu, 29);
+	unsigned long gr30 =3D vcpu_get_gr(vcpu, 30);
=20
 	/*FIXME:For static and stacked convention, firmware
 	 * has put the parameters in gr28-gr31 before
 	 * break to vmm  !!*/
=20
-	p->u.pal_data.gr28 =3D vcpu_get_gr(vcpu, 28);
-	p->u.pal_data.gr29 =3D vcpu_get_gr(vcpu, 29);
-	p->u.pal_data.gr30 =3D vcpu_get_gr(vcpu, 30);
+	switch (gr28) {
+	case PAL_PERF_MON_INFO:
+	case PAL_HALT_INFO:
+		p->u.pal_data.gr29 =3D  kvm_trans_pal_call_args(vcpu, gr29);
+		p->u.pal_data.gr30 =3D vcpu_get_gr(vcpu, 30);
+		break;
+	case PAL_BRAND_INFO:
+		p->u.pal_data.gr29 =3D gr29;;
+		p->u.pal_data.gr30 =3D kvm_trans_pal_call_args(vcpu, gr30);
+		break;
+	default:
+		p->u.pal_data.gr29 =3D gr29;;
+		p->u.pal_data.gr30 =3D vcpu_get_gr(vcpu, 30);
+	}
+	p->u.pal_data.gr28 =3D gr28;
 	p->u.pal_data.gr31 =3D vcpu_get_gr(vcpu, 31);
+
 	p->exit_reason =3D EXIT_REASON_PAL_CALL;
 }
=20
--=20
1.6.0

--_002_706158FABBBA044BAD4FE898A02E4BC2223BCE98pdsmsx503ccrcor_
Content-Type: application/octet-stream;
	name="0002-KVM-ia64-Add-the-support-for-translating-PAL-Call.patch"
Content-Description: 0002-KVM-ia64-Add-the-support-for-translating-PAL-Call.patch
Content-Disposition: attachment;
	filename="0002-KVM-ia64-Add-the-support-for-translating-PAL-Call.patch";
	size=2443; creation-date="Wed, 21 Jan 2009 11:37:36 GMT";
	modification-date="Wed, 21 Jan 2009 11:37:36 GMT"
Content-Transfer-Encoding: base64

RnJvbSA2MzViNzVhNGRmNTU3NzFmNjVjZTdjNDAyNjhhMThkNTI4MTE0NzY5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVGh1LCAxNSBKYW4gMjAwOSAxODowODozNiArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEtWTTogaWE2NDogQWRkIHRoZSBzdXBwb3J0IGZvciB0cmFuc2xhdGluZyBQQUwgQ2FsbCdzIHBv
aW50ZXIgYXJncy4KCkFkZCB0aGUgc3VwcG9ydCB0byB0cmFuc2xhdGUgUEFMIENhbGwncyBwb2lu
dGVyIGFyZ3MuCgpTaWduZWQtb2ZmLWJ5OiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGlu
dGVsLmNvbT4KLS0tCiBhcmNoL2lhNjQva3ZtL3Byb2Nlc3MuYyB8ICAgNDggKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKystLQogMSBmaWxlcyBjaGFuZ2VkLCA0NSBp
bnNlcnRpb25zKCspLCAzIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rdm0v
cHJvY2Vzcy5jIGIvYXJjaC9pYTY0L2t2bS9wcm9jZXNzLmMKaW5kZXggZTIwNjI0NC4uNmVkMDM0
NyAxMDA2NDQKLS0tIGEvYXJjaC9pYTY0L2t2bS9wcm9jZXNzLmMKKysrIGIvYXJjaC9pYTY0L2t2
bS9wcm9jZXNzLmMKQEAgLTU0OSwxOCArNTQ5LDYwIEBAIHZvaWQgcmVmbGVjdF9pbnRlcnJ1cHRp
b24odTY0IGlmYSwgdTY0IGlzciwgdTY0IGlpbSwKIAlpbmplY3RfZ3Vlc3RfaW50ZXJydXB0aW9u
KHZjcHUsIHZlY3Rvcik7CiB9CiAKK3N0YXRpYyB1bnNpZ25lZCBsb25nIGt2bV90cmFuc19wYWxf
Y2FsbF9hcmdzKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwKKwkJCQkJCXVuc2lnbmVkIGxvbmcgYXJn
KQoreworCXN0cnVjdCB0aGFzaF9kYXRhICpkYXRhOworCXVuc2lnbmVkIGxvbmcgZ3BhLCBwb2Zm
OworCisJaWYgKCFpc19waHlzaWNhbF9tb2RlKHZjcHUpKSB7CisJCS8qIERlcGVuZHMgb24gY2Fs
bGVyIHRvIHByb3ZpZGUgdGhlIERUUiBvciBEVEMgbWFwcGluZy4qLworCQlkYXRhID0gdnRsYl9s
b29rdXAodmNwdSwgYXJnLCBEX1RMQik7CisJCWlmIChkYXRhKQorCQkJZ3BhID0gZGF0YS0+cGFn
ZV9mbGFncyAmIF9QQUdFX1BQTl9NQVNLOworCQllbHNlIHsKKwkJCWRhdGEgPSB2aHB0X2xvb2t1
cChhcmcpOworCQkJaWYgKCFkYXRhKQorCQkJCXJldHVybiAwOworCQkJZ3BhID0gZGF0YS0+Z3Bh
ZGRyICYgX1BBR0VfUFBOX01BU0s7CisJCX0KKworCQlwb2ZmID0gYXJnICYgKFBTSVpFKGRhdGEt
PnBzKSAtIDEpOworCQlhcmcgPSBQQUdFQUxJR04oZ3BhLCBkYXRhLT5wcykgfCBwb2ZmOworCX0K
KwlhcmcgPSBrdm1fZ3BhX3RvX21wYShhcmcgPDwgMSA+PiAxKTsKKworCXJldHVybiAodW5zaWdu
ZWQgbG9uZylfX3ZhKGFyZyk7Cit9CisKIHN0YXRpYyB2b2lkIHNldF9wYWxfY2FsbF9kYXRhKHN0
cnVjdCBrdm1fdmNwdSAqdmNwdSkKIHsKIAlzdHJ1Y3QgZXhpdF9jdGxfZGF0YSAqcCA9ICZ2Y3B1
LT5hcmNoLmV4aXRfZGF0YTsKKwl1bnNpZ25lZCBsb25nIGdyMjggPSB2Y3B1X2dldF9ncih2Y3B1
LCAyOCk7CisJdW5zaWduZWQgbG9uZyBncjI5ID0gdmNwdV9nZXRfZ3IodmNwdSwgMjkpOworCXVu
c2lnbmVkIGxvbmcgZ3IzMCA9IHZjcHVfZ2V0X2dyKHZjcHUsIDMwKTsKIAogCS8qRklYTUU6Rm9y
IHN0YXRpYyBhbmQgc3RhY2tlZCBjb252ZW50aW9uLCBmaXJtd2FyZQogCSAqIGhhcyBwdXQgdGhl
IHBhcmFtZXRlcnMgaW4gZ3IyOC1ncjMxIGJlZm9yZQogCSAqIGJyZWFrIHRvIHZtbSAgISEqLwog
Ci0JcC0+dS5wYWxfZGF0YS5ncjI4ID0gdmNwdV9nZXRfZ3IodmNwdSwgMjgpOwotCXAtPnUucGFs
X2RhdGEuZ3IyOSA9IHZjcHVfZ2V0X2dyKHZjcHUsIDI5KTsKLQlwLT51LnBhbF9kYXRhLmdyMzAg
PSB2Y3B1X2dldF9ncih2Y3B1LCAzMCk7CisJc3dpdGNoIChncjI4KSB7CisJY2FzZSBQQUxfUEVS
Rl9NT05fSU5GTzoKKwljYXNlIFBBTF9IQUxUX0lORk86CisJCXAtPnUucGFsX2RhdGEuZ3IyOSA9
ICBrdm1fdHJhbnNfcGFsX2NhbGxfYXJncyh2Y3B1LCBncjI5KTsKKwkJcC0+dS5wYWxfZGF0YS5n
cjMwID0gdmNwdV9nZXRfZ3IodmNwdSwgMzApOworCQlicmVhazsKKwljYXNlIFBBTF9CUkFORF9J
TkZPOgorCQlwLT51LnBhbF9kYXRhLmdyMjkgPSBncjI5OzsKKwkJcC0+dS5wYWxfZGF0YS5ncjMw
ID0ga3ZtX3RyYW5zX3BhbF9jYWxsX2FyZ3ModmNwdSwgZ3IzMCk7CisJCWJyZWFrOworCWRlZmF1
bHQ6CisJCXAtPnUucGFsX2RhdGEuZ3IyOSA9IGdyMjk7OworCQlwLT51LnBhbF9kYXRhLmdyMzAg
PSB2Y3B1X2dldF9ncih2Y3B1LCAzMCk7CisJfQorCXAtPnUucGFsX2RhdGEuZ3IyOCA9IGdyMjg7
CiAJcC0+dS5wYWxfZGF0YS5ncjMxID0gdmNwdV9nZXRfZ3IodmNwdSwgMzEpOworCiAJcC0+ZXhp
dF9yZWFzb24gPSBFWElUX1JFQVNPTl9QQUxfQ0FMTDsKIH0KIAotLSAKMS42LjAKCg==

--_002_706158FABBBA044BAD4FE898A02E4BC2223BCE98pdsmsx503ccrcor_--
