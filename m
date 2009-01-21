From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Wed, 21 Jan 2009 03:44:55 +0000
Subject: [PATCH 03/03] KVM: ia64: Implement some pal calls needed for
Message-Id: <706158FABBBA044BAD4FE898A02E4BC2223BCE99@pdsmsx503.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="_002_706158FABBBA044BAD4FE898A02E4BC2223BCE99pdsmsx503ccrcor_"
List-Id: <linux-ia64.vger.kernel.org>
To: "kvm-ia64@vger.kernel.org" <kvm-ia64@vger.kernel.org>
Cc: Avi Kivity <avi@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

--_002_706158FABBBA044BAD4FE898A02E4BC2223BCE99pdsmsx503ccrcor_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 4a3755fda38a944a5bce40d14b54bd9032ba92a4 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Wed, 21 Jan 2009 11:21:27 +0800
Subject: [PATCH] KVM: ia64: Implement some pal calls needed for windows 200=
8.

For windows 2008, it needs more pal calls to implement for booting.
In addition, also changes the name of set_{sal, pal}_call_result to
get_{sal, pal}_call_result for readability.

Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/kvm_fw.c  |  151 +++++++++++++++++++++++++++++++++++++++++++=
+++-
 arch/ia64/kvm/process.c |    8 +-
 2 files changed, 152 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kvm/kvm_fw.c b/arch/ia64/kvm/kvm_fw.c
index cb7600b..a8ae52e 100644
--- a/arch/ia64/kvm/kvm_fw.c
+++ b/arch/ia64/kvm/kvm_fw.c
@@ -227,6 +227,18 @@ static struct ia64_pal_retval pal_proc_get_features(st=
ruct kvm_vcpu *vcpu)
 	return result;
 }
=20
+static struct ia64_pal_retval pal_register_info(struct kvm_vcpu *vcpu)
+{
+
+	struct ia64_pal_retval result =3D {0, 0, 0, 0};
+	long in0, in1, in2, in3;
+
+	kvm_get_pal_call_data(vcpu, &in0, &in1, &in2, &in3);
+	result.status =3D ia64_pal_register_info(in1, &result.v1, &result.v2);
+
+	return result;
+}
+
 static struct ia64_pal_retval pal_cache_info(struct kvm_vcpu *vcpu)
 {
=20
@@ -268,8 +280,12 @@ static struct ia64_pal_retval pal_vm_summary(struct kv=
m_vcpu *vcpu)
 static struct ia64_pal_retval pal_vm_info(struct kvm_vcpu *vcpu)
 {
 	struct ia64_pal_retval result;
+	unsigned long in0, in1, in2, in3;
=20
-	INIT_PAL_STATUS_UNIMPLEMENTED(result);
+	kvm_get_pal_call_data(vcpu, &in0, &in1, &in2, &in3);
+
+	result.status =3D ia64_pal_vm_info(in1, in2,
+			(pal_tc_info_u_t *)&result.v1, &result.v2);
=20
 	return result;
 }
@@ -292,6 +308,108 @@ static void prepare_for_halt(struct kvm_vcpu *vcpu)
 	vcpu->arch.timer_fired =3D 0;
 }
=20
+static struct ia64_pal_retval pal_perf_mon_info(struct kvm_vcpu *vcpu)
+{
+	long status;
+	unsigned long in0, in1, in2, in3, r9;
+	unsigned long pm_buffer[16];
+
+	kvm_get_pal_call_data(vcpu, &in0, &in1, &in2, &in3);
+	status =3D ia64_pal_perf_mon_info(pm_buffer,
+				(pal_perf_mon_info_u_t *) &r9);
+	if (status !=3D 0) {
+		printk(KERN_DEBUG"PAL_PERF_MON_INFO fails ret=3D%ld\n", status);
+	} else {
+		if (in1)
+			memcpy((void *)in1, pm_buffer, sizeof(pm_buffer));
+		else {
+			status =3D PAL_STATUS_EINVAL;
+			printk(KERN_WARNING"Invalid parameters "
+						"for PAL call:0x%lx!\n", in0);
+		}
+	}
+	return (struct ia64_pal_retval){status, r9, 0, 0};
+}
+
+static struct ia64_pal_retval pal_halt_info(struct kvm_vcpu *vcpu)
+{
+	unsigned long in0, in1, in2, in3;
+	long status;
+	unsigned long res =3D 1000UL | (1000UL << 16) | (10UL << 32)
+					| (1UL << 61) | (1UL << 60);
+
+	kvm_get_pal_call_data(vcpu, &in0, &in1, &in2, &in3);
+	if (in1) {
+		memcpy((void *)in1, &res, sizeof(res));
+		status =3D 0;
+	} else{
+		status =3D PAL_STATUS_EINVAL;
+		printk(KERN_WARNING"Invalid parameters "
+					"for PAL call:0x%lx!\n", in0);
+	}
+
+	return (struct ia64_pal_retval){status, 0, 0, 0};
+}
+
+static struct ia64_pal_retval pal_mem_attrib(struct kvm_vcpu *vcpu)
+{
+	unsigned long r9;
+	long status;
+
+	status =3D ia64_pal_mem_attrib(&r9);
+
+	return (struct ia64_pal_retval){status, r9, 0, 0};
+}
+
+static void remote_pal_prefetch_visibility(void *v)
+{
+	s64 trans_type =3D (s64)v;
+	ia64_pal_prefetch_visibility(trans_type);
+}
+
+static struct ia64_pal_retval pal_prefetch_visibility(struct kvm_vcpu *vcp=
u)
+{
+	struct ia64_pal_retval result =3D {0, 0, 0, 0};
+	unsigned long in0, in1, in2, in3;
+	kvm_get_pal_call_data(vcpu, &in0, &in1, &in2, &in3);
+	result.status =3D ia64_pal_prefetch_visibility(in1);
+	if (result.status =3D=3D 0) {
+		/* Must be performed on all remote processors
+		in the coherence domain. */
+		smp_call_function(remote_pal_prefetch_visibility,
+					(void *)in1, 1);
+		/* Unnecessary on remote processor for other vcpus!*/
+		result.status =3D 1;
+	}
+	return result;
+}
+
+static void remote_pal_mc_drain(void *v)
+{
+	ia64_pal_mc_drain();
+}
+
+static struct ia64_pal_retval pal_get_brand_info(struct kvm_vcpu *vcpu)
+{
+	struct ia64_pal_retval result =3D {0, 0, 0, 0};
+	unsigned long in0, in1, in2, in3;
+
+	kvm_get_pal_call_data(vcpu, &in0, &in1, &in2, &in3);
+
+	if (in1 =3D=3D 0 && in2) {
+		char brand_info[128];
+		result.status =3D ia64_pal_get_brand_info(brand_info);
+		if (result.status =3D=3D PAL_STATUS_SUCCESS)
+			memcpy((void *)in2, brand_info, 128);
+	} else {
+		result.status =3D PAL_STATUS_REQUIRES_MEMORY;
+		printk(KERN_WARNING"Invalid parameters for "
+					"PAL call:0x%lx!\n", in0);
+	}
+
+	return result;
+}
+
 int kvm_pal_emul(struct kvm_vcpu *vcpu, struct kvm_run *run)
 {
=20
@@ -300,14 +418,22 @@ int kvm_pal_emul(struct kvm_vcpu *vcpu, struct kvm_ru=
n *run)
 	int ret =3D 1;
=20
 	gr28 =3D kvm_get_pal_call_index(vcpu);
-	/*printk("pal_call index:%lx\n",gr28);*/
 	switch (gr28) {
 	case PAL_CACHE_FLUSH:
 		result =3D pal_cache_flush(vcpu);
 		break;
+	case PAL_MEM_ATTRIB:
+		result =3D pal_mem_attrib(vcpu);
+		break;
 	case PAL_CACHE_SUMMARY:
 		result =3D pal_cache_summary(vcpu);
 		break;
+	case PAL_PERF_MON_INFO:
+		result =3D pal_perf_mon_info(vcpu);
+		break;
+	case PAL_HALT_INFO:
+		result =3D pal_halt_info(vcpu);
+		break;
 	case PAL_HALT_LIGHT:
 	{
 		INIT_PAL_STATUS_SUCCESS(result);
@@ -317,6 +443,16 @@ int kvm_pal_emul(struct kvm_vcpu *vcpu, struct kvm_run=
 *run)
 	}
 		break;
=20
+	case PAL_PREFETCH_VISIBILITY:
+		result =3D pal_prefetch_visibility(vcpu);
+		break;
+	case PAL_MC_DRAIN:
+		result.status =3D ia64_pal_mc_drain();
+		/* FIXME: All vcpus likely call PAL_MC_DRAIN.
+		   That causes the congestion. */
+		smp_call_function(remote_pal_mc_drain, NULL, 1);
+		break;
+
 	case PAL_FREQ_RATIOS:
 		result =3D pal_freq_ratios(vcpu);
 		break;
@@ -346,6 +482,9 @@ int kvm_pal_emul(struct kvm_vcpu *vcpu, struct kvm_run =
*run)
 		INIT_PAL_STATUS_SUCCESS(result);
 		result.v1 =3D (1L << 32) | 1L;
 		break;
+	case PAL_REGISTER_INFO:
+		result =3D pal_register_info(vcpu);
+		break;
 	case PAL_VM_PAGE_SIZE:
 		result.status =3D ia64_pal_vm_page_size(&result.v0,
 							&result.v1);
@@ -365,12 +504,18 @@ int kvm_pal_emul(struct kvm_vcpu *vcpu, struct kvm_ru=
n *run)
 		result.status =3D ia64_pal_version(
 				(pal_version_u_t *)&result.v0,
 				(pal_version_u_t *)&result.v1);
-
 		break;
 	case PAL_FIXED_ADDR:
 		result.status =3D PAL_STATUS_SUCCESS;
 		result.v0 =3D vcpu->vcpu_id;
 		break;
+	case PAL_BRAND_INFO:
+		result =3D pal_get_brand_info(vcpu);
+		break;
+	case PAL_GET_PSTATE:
+	case PAL_CACHE_SHARED_INFO:
+		INIT_PAL_STATUS_UNIMPLEMENTED(result);
+		break;
 	default:
 		INIT_PAL_STATUS_UNIMPLEMENTED(result);
 		printk(KERN_WARNING"kvm: Unsupported pal call,"
diff --git a/arch/ia64/kvm/process.c b/arch/ia64/kvm/process.c
index 6ed0347..7079ace 100644
--- a/arch/ia64/kvm/process.c
+++ b/arch/ia64/kvm/process.c
@@ -606,7 +606,7 @@ static void set_pal_call_data(struct kvm_vcpu *vcpu)
 	p->exit_reason =3D EXIT_REASON_PAL_CALL;
 }
=20
-static void set_pal_call_result(struct kvm_vcpu *vcpu)
+static void get_pal_call_result(struct kvm_vcpu *vcpu)
 {
 	struct exit_ctl_data *p =3D &vcpu->arch.exit_data;
=20
@@ -634,7 +634,7 @@ static void set_sal_call_data(struct kvm_vcpu *vcpu)
 	p->exit_reason =3D EXIT_REASON_SAL_CALL;
 }
=20
-static void set_sal_call_result(struct kvm_vcpu *vcpu)
+static void get_sal_call_result(struct kvm_vcpu *vcpu)
 {
 	struct exit_ctl_data *p =3D &vcpu->arch.exit_data;
=20
@@ -657,13 +657,13 @@ void  kvm_ia64_handle_break(unsigned long ifa, struct=
 kvm_pt_regs *regs,
 		if (iim =3D=3D DOMN_PAL_REQUEST) {
 			set_pal_call_data(v);
 			vmm_transition(v);
-			set_pal_call_result(v);
+			get_pal_call_result(v);
 			vcpu_increment_iip(v);
 			return;
 		} else if (iim =3D=3D DOMN_SAL_REQUEST) {
 			set_sal_call_data(v);
 			vmm_transition(v);
-			set_sal_call_result(v);
+			get_sal_call_result(v);
 			vcpu_increment_iip(v);
 			return;
 		}
--=20
1.6.0

--_002_706158FABBBA044BAD4FE898A02E4BC2223BCE99pdsmsx503ccrcor_
Content-Type: application/octet-stream;
	name="0003-KVM-ia64-Implement-some-pal-calls-needed-for-windo.patch"
Content-Description: 0003-KVM-ia64-Implement-some-pal-calls-needed-for-windo.patch
Content-Disposition: attachment;
	filename="0003-KVM-ia64-Implement-some-pal-calls-needed-for-windo.patch";
	size=7836; creation-date="Wed, 21 Jan 2009 11:37:36 GMT";
	modification-date="Wed, 21 Jan 2009 11:37:36 GMT"
Content-Transfer-Encoding: base64

RnJvbSA0YTM3NTVmZGEzOGE5NDRhNWJjZTQwZDE0YjU0YmQ5MDMyYmE5MmE0IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAyMSBKYW4gMjAwOSAxMToyMToyNyArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEtWTTogaWE2NDogSW1wbGVtZW50IHNvbWUgcGFsIGNhbGxzIG5lZWRlZCBmb3Igd2luZG93cyAy
MDA4LgoKRm9yIHdpbmRvd3MgMjAwOCwgaXQgbmVlZHMgbW9yZSBwYWwgY2FsbHMgdG8gaW1wbGVt
ZW50IGZvciBib290aW5nLgpJbiBhZGRpdGlvbiwgYWxzbyBjaGFuZ2VzIHRoZSBuYW1lIG9mIHNl
dF97c2FsLCBwYWx9X2NhbGxfcmVzdWx0IHRvCmdldF97c2FsLCBwYWx9X2NhbGxfcmVzdWx0IGZv
ciByZWFkYWJpbGl0eS4KClNpZ25lZC1vZmYtYnk6IFhpYW50YW8gWmhhbmcgPHhpYW50YW8uemhh
bmdAaW50ZWwuY29tPgotLS0KIGFyY2gvaWE2NC9rdm0va3ZtX2Z3LmMgIHwgIDE1MSArKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrLQogYXJjaC9pYTY0L2t2bS9w
cm9jZXNzLmMgfCAgICA4ICstCiAyIGZpbGVzIGNoYW5nZWQsIDE1MiBpbnNlcnRpb25zKCspLCA3
IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rdm0va3ZtX2Z3LmMgYi9hcmNo
L2lhNjQva3ZtL2t2bV9mdy5jCmluZGV4IGNiNzYwMGIuLmE4YWU1MmUgMTAwNjQ0Ci0tLSBhL2Fy
Y2gvaWE2NC9rdm0va3ZtX2Z3LmMKKysrIGIvYXJjaC9pYTY0L2t2bS9rdm1fZncuYwpAQCAtMjI3
LDYgKzIyNywxOCBAQCBzdGF0aWMgc3RydWN0IGlhNjRfcGFsX3JldHZhbCBwYWxfcHJvY19nZXRf
ZmVhdHVyZXMoc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQogCXJldHVybiByZXN1bHQ7CiB9CiAKK3N0
YXRpYyBzdHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHBhbF9yZWdpc3Rlcl9pbmZvKHN0cnVjdCBrdm1f
dmNwdSAqdmNwdSkKK3sKKworCXN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcmVzdWx0ID0gezAsIDAs
IDAsIDB9OworCWxvbmcgaW4wLCBpbjEsIGluMiwgaW4zOworCisJa3ZtX2dldF9wYWxfY2FsbF9k
YXRhKHZjcHUsICZpbjAsICZpbjEsICZpbjIsICZpbjMpOworCXJlc3VsdC5zdGF0dXMgPSBpYTY0
X3BhbF9yZWdpc3Rlcl9pbmZvKGluMSwgJnJlc3VsdC52MSwgJnJlc3VsdC52Mik7CisKKwlyZXR1
cm4gcmVzdWx0OworfQorCiBzdGF0aWMgc3RydWN0IGlhNjRfcGFsX3JldHZhbCBwYWxfY2FjaGVf
aW5mbyhzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCiB7CiAKQEAgLTI2OCw4ICsyODAsMTIgQEAgc3Rh
dGljIHN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcGFsX3ZtX3N1bW1hcnkoc3RydWN0IGt2bV92Y3B1
ICp2Y3B1KQogc3RhdGljIHN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcGFsX3ZtX2luZm8oc3RydWN0
IGt2bV92Y3B1ICp2Y3B1KQogewogCXN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcmVzdWx0OworCXVu
c2lnbmVkIGxvbmcgaW4wLCBpbjEsIGluMiwgaW4zOwogCi0JSU5JVF9QQUxfU1RBVFVTX1VOSU1Q
TEVNRU5URUQocmVzdWx0KTsKKwlrdm1fZ2V0X3BhbF9jYWxsX2RhdGEodmNwdSwgJmluMCwgJmlu
MSwgJmluMiwgJmluMyk7CisKKwlyZXN1bHQuc3RhdHVzID0gaWE2NF9wYWxfdm1faW5mbyhpbjEs
IGluMiwKKwkJCShwYWxfdGNfaW5mb191X3QgKikmcmVzdWx0LnYxLCAmcmVzdWx0LnYyKTsKIAog
CXJldHVybiByZXN1bHQ7CiB9CkBAIC0yOTIsNiArMzA4LDEwOCBAQCBzdGF0aWMgdm9pZCBwcmVw
YXJlX2Zvcl9oYWx0KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkKIAl2Y3B1LT5hcmNoLnRpbWVyX2Zp
cmVkID0gMDsKIH0KIAorc3RhdGljIHN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcGFsX3BlcmZfbW9u
X2luZm8oc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQoreworCWxvbmcgc3RhdHVzOworCXVuc2lnbmVk
IGxvbmcgaW4wLCBpbjEsIGluMiwgaW4zLCByOTsKKwl1bnNpZ25lZCBsb25nIHBtX2J1ZmZlclsx
Nl07CisKKwlrdm1fZ2V0X3BhbF9jYWxsX2RhdGEodmNwdSwgJmluMCwgJmluMSwgJmluMiwgJmlu
Myk7CisJc3RhdHVzID0gaWE2NF9wYWxfcGVyZl9tb25faW5mbyhwbV9idWZmZXIsCisJCQkJKHBh
bF9wZXJmX21vbl9pbmZvX3VfdCAqKSAmcjkpOworCWlmIChzdGF0dXMgIT0gMCkgeworCQlwcmlu
dGsoS0VSTl9ERUJVRyJQQUxfUEVSRl9NT05fSU5GTyBmYWlscyByZXQ9JWxkXG4iLCBzdGF0dXMp
OworCX0gZWxzZSB7CisJCWlmIChpbjEpCisJCQltZW1jcHkoKHZvaWQgKilpbjEsIHBtX2J1ZmZl
ciwgc2l6ZW9mKHBtX2J1ZmZlcikpOworCQllbHNlIHsKKwkJCXN0YXR1cyA9IFBBTF9TVEFUVVNf
RUlOVkFMOworCQkJcHJpbnRrKEtFUk5fV0FSTklORyJJbnZhbGlkIHBhcmFtZXRlcnMgIgorCQkJ
CQkJImZvciBQQUwgY2FsbDoweCVseCFcbiIsIGluMCk7CisJCX0KKwl9CisJcmV0dXJuIChzdHJ1
Y3QgaWE2NF9wYWxfcmV0dmFsKXtzdGF0dXMsIHI5LCAwLCAwfTsKK30KKworc3RhdGljIHN0cnVj
dCBpYTY0X3BhbF9yZXR2YWwgcGFsX2hhbHRfaW5mbyhzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7
CisJdW5zaWduZWQgbG9uZyBpbjAsIGluMSwgaW4yLCBpbjM7CisJbG9uZyBzdGF0dXM7CisJdW5z
aWduZWQgbG9uZyByZXMgPSAxMDAwVUwgfCAoMTAwMFVMIDw8IDE2KSB8ICgxMFVMIDw8IDMyKQor
CQkJCQl8ICgxVUwgPDwgNjEpIHwgKDFVTCA8PCA2MCk7CisKKwlrdm1fZ2V0X3BhbF9jYWxsX2Rh
dGEodmNwdSwgJmluMCwgJmluMSwgJmluMiwgJmluMyk7CisJaWYgKGluMSkgeworCQltZW1jcHko
KHZvaWQgKilpbjEsICZyZXMsIHNpemVvZihyZXMpKTsKKwkJc3RhdHVzID0gMDsKKwl9IGVsc2V7
CisJCXN0YXR1cyA9IFBBTF9TVEFUVVNfRUlOVkFMOworCQlwcmludGsoS0VSTl9XQVJOSU5HIklu
dmFsaWQgcGFyYW1ldGVycyAiCisJCQkJCSJmb3IgUEFMIGNhbGw6MHglbHghXG4iLCBpbjApOwor
CX0KKworCXJldHVybiAoc3RydWN0IGlhNjRfcGFsX3JldHZhbCl7c3RhdHVzLCAwLCAwLCAwfTsK
K30KKworc3RhdGljIHN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcGFsX21lbV9hdHRyaWIoc3RydWN0
IGt2bV92Y3B1ICp2Y3B1KQoreworCXVuc2lnbmVkIGxvbmcgcjk7CisJbG9uZyBzdGF0dXM7CisK
KwlzdGF0dXMgPSBpYTY0X3BhbF9tZW1fYXR0cmliKCZyOSk7CisKKwlyZXR1cm4gKHN0cnVjdCBp
YTY0X3BhbF9yZXR2YWwpe3N0YXR1cywgcjksIDAsIDB9OworfQorCitzdGF0aWMgdm9pZCByZW1v
dGVfcGFsX3ByZWZldGNoX3Zpc2liaWxpdHkodm9pZCAqdikKK3sKKwlzNjQgdHJhbnNfdHlwZSA9
IChzNjQpdjsKKwlpYTY0X3BhbF9wcmVmZXRjaF92aXNpYmlsaXR5KHRyYW5zX3R5cGUpOworfQor
CitzdGF0aWMgc3RydWN0IGlhNjRfcGFsX3JldHZhbCBwYWxfcHJlZmV0Y2hfdmlzaWJpbGl0eShz
dHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJc3RydWN0IGlhNjRfcGFsX3JldHZhbCByZXN1bHQg
PSB7MCwgMCwgMCwgMH07CisJdW5zaWduZWQgbG9uZyBpbjAsIGluMSwgaW4yLCBpbjM7CisJa3Zt
X2dldF9wYWxfY2FsbF9kYXRhKHZjcHUsICZpbjAsICZpbjEsICZpbjIsICZpbjMpOworCXJlc3Vs
dC5zdGF0dXMgPSBpYTY0X3BhbF9wcmVmZXRjaF92aXNpYmlsaXR5KGluMSk7CisJaWYgKHJlc3Vs
dC5zdGF0dXMgPT0gMCkgeworCQkvKiBNdXN0IGJlIHBlcmZvcm1lZCBvbiBhbGwgcmVtb3RlIHBy
b2Nlc3NvcnMKKwkJaW4gdGhlIGNvaGVyZW5jZSBkb21haW4uICovCisJCXNtcF9jYWxsX2Z1bmN0
aW9uKHJlbW90ZV9wYWxfcHJlZmV0Y2hfdmlzaWJpbGl0eSwKKwkJCQkJKHZvaWQgKilpbjEsIDEp
OworCQkvKiBVbm5lY2Vzc2FyeSBvbiByZW1vdGUgcHJvY2Vzc29yIGZvciBvdGhlciB2Y3B1cyEq
LworCQlyZXN1bHQuc3RhdHVzID0gMTsKKwl9CisJcmV0dXJuIHJlc3VsdDsKK30KKworc3RhdGlj
IHZvaWQgcmVtb3RlX3BhbF9tY19kcmFpbih2b2lkICp2KQoreworCWlhNjRfcGFsX21jX2RyYWlu
KCk7Cit9CisKK3N0YXRpYyBzdHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHBhbF9nZXRfYnJhbmRfaW5m
byhzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJc3RydWN0IGlhNjRfcGFsX3JldHZhbCByZXN1
bHQgPSB7MCwgMCwgMCwgMH07CisJdW5zaWduZWQgbG9uZyBpbjAsIGluMSwgaW4yLCBpbjM7CisK
Kwlrdm1fZ2V0X3BhbF9jYWxsX2RhdGEodmNwdSwgJmluMCwgJmluMSwgJmluMiwgJmluMyk7CisK
KwlpZiAoaW4xID09IDAgJiYgaW4yKSB7CisJCWNoYXIgYnJhbmRfaW5mb1sxMjhdOworCQlyZXN1
bHQuc3RhdHVzID0gaWE2NF9wYWxfZ2V0X2JyYW5kX2luZm8oYnJhbmRfaW5mbyk7CisJCWlmIChy
ZXN1bHQuc3RhdHVzID09IFBBTF9TVEFUVVNfU1VDQ0VTUykKKwkJCW1lbWNweSgodm9pZCAqKWlu
MiwgYnJhbmRfaW5mbywgMTI4KTsKKwl9IGVsc2UgeworCQlyZXN1bHQuc3RhdHVzID0gUEFMX1NU
QVRVU19SRVFVSVJFU19NRU1PUlk7CisJCXByaW50ayhLRVJOX1dBUk5JTkciSW52YWxpZCBwYXJh
bWV0ZXJzIGZvciAiCisJCQkJCSJQQUwgY2FsbDoweCVseCFcbiIsIGluMCk7CisJfQorCisJcmV0
dXJuIHJlc3VsdDsKK30KKwogaW50IGt2bV9wYWxfZW11bChzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUs
IHN0cnVjdCBrdm1fcnVuICpydW4pCiB7CiAKQEAgLTMwMCwxNCArNDE4LDIyIEBAIGludCBrdm1f
cGFsX2VtdWwoc3RydWN0IGt2bV92Y3B1ICp2Y3B1LCBzdHJ1Y3Qga3ZtX3J1biAqcnVuKQogCWlu
dCByZXQgPSAxOwogCiAJZ3IyOCA9IGt2bV9nZXRfcGFsX2NhbGxfaW5kZXgodmNwdSk7Ci0JLypw
cmludGsoInBhbF9jYWxsIGluZGV4OiVseFxuIixncjI4KTsqLwogCXN3aXRjaCAoZ3IyOCkgewog
CWNhc2UgUEFMX0NBQ0hFX0ZMVVNIOgogCQlyZXN1bHQgPSBwYWxfY2FjaGVfZmx1c2godmNwdSk7
CiAJCWJyZWFrOworCWNhc2UgUEFMX01FTV9BVFRSSUI6CisJCXJlc3VsdCA9IHBhbF9tZW1fYXR0
cmliKHZjcHUpOworCQlicmVhazsKIAljYXNlIFBBTF9DQUNIRV9TVU1NQVJZOgogCQlyZXN1bHQg
PSBwYWxfY2FjaGVfc3VtbWFyeSh2Y3B1KTsKIAkJYnJlYWs7CisJY2FzZSBQQUxfUEVSRl9NT05f
SU5GTzoKKwkJcmVzdWx0ID0gcGFsX3BlcmZfbW9uX2luZm8odmNwdSk7CisJCWJyZWFrOworCWNh
c2UgUEFMX0hBTFRfSU5GTzoKKwkJcmVzdWx0ID0gcGFsX2hhbHRfaW5mbyh2Y3B1KTsKKwkJYnJl
YWs7CiAJY2FzZSBQQUxfSEFMVF9MSUdIVDoKIAl7CiAJCUlOSVRfUEFMX1NUQVRVU19TVUNDRVNT
KHJlc3VsdCk7CkBAIC0zMTcsNiArNDQzLDE2IEBAIGludCBrdm1fcGFsX2VtdWwoc3RydWN0IGt2
bV92Y3B1ICp2Y3B1LCBzdHJ1Y3Qga3ZtX3J1biAqcnVuKQogCX0KIAkJYnJlYWs7CiAKKwljYXNl
IFBBTF9QUkVGRVRDSF9WSVNJQklMSVRZOgorCQlyZXN1bHQgPSBwYWxfcHJlZmV0Y2hfdmlzaWJp
bGl0eSh2Y3B1KTsKKwkJYnJlYWs7CisJY2FzZSBQQUxfTUNfRFJBSU46CisJCXJlc3VsdC5zdGF0
dXMgPSBpYTY0X3BhbF9tY19kcmFpbigpOworCQkvKiBGSVhNRTogQWxsIHZjcHVzIGxpa2VseSBj
YWxsIFBBTF9NQ19EUkFJTi4KKwkJICAgVGhhdCBjYXVzZXMgdGhlIGNvbmdlc3Rpb24uICovCisJ
CXNtcF9jYWxsX2Z1bmN0aW9uKHJlbW90ZV9wYWxfbWNfZHJhaW4sIE5VTEwsIDEpOworCQlicmVh
azsKKwogCWNhc2UgUEFMX0ZSRVFfUkFUSU9TOgogCQlyZXN1bHQgPSBwYWxfZnJlcV9yYXRpb3Mo
dmNwdSk7CiAJCWJyZWFrOwpAQCAtMzQ2LDYgKzQ4Miw5IEBAIGludCBrdm1fcGFsX2VtdWwoc3Ry
dWN0IGt2bV92Y3B1ICp2Y3B1LCBzdHJ1Y3Qga3ZtX3J1biAqcnVuKQogCQlJTklUX1BBTF9TVEFU
VVNfU1VDQ0VTUyhyZXN1bHQpOwogCQlyZXN1bHQudjEgPSAoMUwgPDwgMzIpIHwgMUw7CiAJCWJy
ZWFrOworCWNhc2UgUEFMX1JFR0lTVEVSX0lORk86CisJCXJlc3VsdCA9IHBhbF9yZWdpc3Rlcl9p
bmZvKHZjcHUpOworCQlicmVhazsKIAljYXNlIFBBTF9WTV9QQUdFX1NJWkU6CiAJCXJlc3VsdC5z
dGF0dXMgPSBpYTY0X3BhbF92bV9wYWdlX3NpemUoJnJlc3VsdC52MCwKIAkJCQkJCQkmcmVzdWx0
LnYxKTsKQEAgLTM2NSwxMiArNTA0LDE4IEBAIGludCBrdm1fcGFsX2VtdWwoc3RydWN0IGt2bV92
Y3B1ICp2Y3B1LCBzdHJ1Y3Qga3ZtX3J1biAqcnVuKQogCQlyZXN1bHQuc3RhdHVzID0gaWE2NF9w
YWxfdmVyc2lvbigKIAkJCQkocGFsX3ZlcnNpb25fdV90ICopJnJlc3VsdC52MCwKIAkJCQkocGFs
X3ZlcnNpb25fdV90ICopJnJlc3VsdC52MSk7Ci0KIAkJYnJlYWs7CiAJY2FzZSBQQUxfRklYRURf
QUREUjoKIAkJcmVzdWx0LnN0YXR1cyA9IFBBTF9TVEFUVVNfU1VDQ0VTUzsKIAkJcmVzdWx0LnYw
ID0gdmNwdS0+dmNwdV9pZDsKIAkJYnJlYWs7CisJY2FzZSBQQUxfQlJBTkRfSU5GTzoKKwkJcmVz
dWx0ID0gcGFsX2dldF9icmFuZF9pbmZvKHZjcHUpOworCQlicmVhazsKKwljYXNlIFBBTF9HRVRf
UFNUQVRFOgorCWNhc2UgUEFMX0NBQ0hFX1NIQVJFRF9JTkZPOgorCQlJTklUX1BBTF9TVEFUVVNf
VU5JTVBMRU1FTlRFRChyZXN1bHQpOworCQlicmVhazsKIAlkZWZhdWx0OgogCQlJTklUX1BBTF9T
VEFUVVNfVU5JTVBMRU1FTlRFRChyZXN1bHQpOwogCQlwcmludGsoS0VSTl9XQVJOSU5HImt2bTog
VW5zdXBwb3J0ZWQgcGFsIGNhbGwsIgpkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2t2bS9wcm9jZXNz
LmMgYi9hcmNoL2lhNjQva3ZtL3Byb2Nlc3MuYwppbmRleCA2ZWQwMzQ3Li43MDc5YWNlIDEwMDY0
NAotLS0gYS9hcmNoL2lhNjQva3ZtL3Byb2Nlc3MuYworKysgYi9hcmNoL2lhNjQva3ZtL3Byb2Nl
c3MuYwpAQCAtNjA2LDcgKzYwNiw3IEBAIHN0YXRpYyB2b2lkIHNldF9wYWxfY2FsbF9kYXRhKHN0
cnVjdCBrdm1fdmNwdSAqdmNwdSkKIAlwLT5leGl0X3JlYXNvbiA9IEVYSVRfUkVBU09OX1BBTF9D
QUxMOwogfQogCi1zdGF0aWMgdm9pZCBzZXRfcGFsX2NhbGxfcmVzdWx0KHN0cnVjdCBrdm1fdmNw
dSAqdmNwdSkKK3N0YXRpYyB2b2lkIGdldF9wYWxfY2FsbF9yZXN1bHQoc3RydWN0IGt2bV92Y3B1
ICp2Y3B1KQogewogCXN0cnVjdCBleGl0X2N0bF9kYXRhICpwID0gJnZjcHUtPmFyY2guZXhpdF9k
YXRhOwogCkBAIC02MzQsNyArNjM0LDcgQEAgc3RhdGljIHZvaWQgc2V0X3NhbF9jYWxsX2RhdGEo
c3RydWN0IGt2bV92Y3B1ICp2Y3B1KQogCXAtPmV4aXRfcmVhc29uID0gRVhJVF9SRUFTT05fU0FM
X0NBTEw7CiB9CiAKLXN0YXRpYyB2b2lkIHNldF9zYWxfY2FsbF9yZXN1bHQoc3RydWN0IGt2bV92
Y3B1ICp2Y3B1KQorc3RhdGljIHZvaWQgZ2V0X3NhbF9jYWxsX3Jlc3VsdChzdHJ1Y3Qga3ZtX3Zj
cHUgKnZjcHUpCiB7CiAJc3RydWN0IGV4aXRfY3RsX2RhdGEgKnAgPSAmdmNwdS0+YXJjaC5leGl0
X2RhdGE7CiAKQEAgLTY1NywxMyArNjU3LDEzIEBAIHZvaWQgIGt2bV9pYTY0X2hhbmRsZV9icmVh
ayh1bnNpZ25lZCBsb25nIGlmYSwgc3RydWN0IGt2bV9wdF9yZWdzICpyZWdzLAogCQlpZiAoaWlt
ID09IERPTU5fUEFMX1JFUVVFU1QpIHsKIAkJCXNldF9wYWxfY2FsbF9kYXRhKHYpOwogCQkJdm1t
X3RyYW5zaXRpb24odik7Ci0JCQlzZXRfcGFsX2NhbGxfcmVzdWx0KHYpOworCQkJZ2V0X3BhbF9j
YWxsX3Jlc3VsdCh2KTsKIAkJCXZjcHVfaW5jcmVtZW50X2lpcCh2KTsKIAkJCXJldHVybjsKIAkJ
fSBlbHNlIGlmIChpaW0gPT0gRE9NTl9TQUxfUkVRVUVTVCkgewogCQkJc2V0X3NhbF9jYWxsX2Rh
dGEodik7CiAJCQl2bW1fdHJhbnNpdGlvbih2KTsKLQkJCXNldF9zYWxfY2FsbF9yZXN1bHQodik7
CisJCQlnZXRfc2FsX2NhbGxfcmVzdWx0KHYpOwogCQkJdmNwdV9pbmNyZW1lbnRfaWlwKHYpOwog
CQkJcmV0dXJuOwogCQl9Ci0tIAoxLjYuMAoK

--_002_706158FABBBA044BAD4FE898A02E4BC2223BCE99pdsmsx503ccrcor_--
