From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Tue, 01 Apr 2008 10:42:59 +0000
Subject: [Patch][03/18] Prepare some structure definition and routines for kvm use.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048722@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C893E5.27C20703"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C893E5.27C20703
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 7f1714377e6d5812b4557bb3ccd8268b57865952 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Tue, 1 Apr 2008 14:42:00 +0800
Subject: [PATCH] KVM: IA64 : Prepare some structure definitions and
routines for kvm use.

Register structures are defined per SDM.
Add three small routines for kernel:
ia64_ttag, ia64_loadrs, ia64_flushrs
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 include/asm-ia64/gcc_intrin.h |   12 ++++++++
 include/asm-ia64/processor.h  |   63
+++++++++++++++++++++++++++++++++++++++++
 2 files changed, 75 insertions(+), 0 deletions(-)

diff --git a/include/asm-ia64/gcc_intrin.h
b/include/asm-ia64/gcc_intrin.h
index de2ed2c..2fe292c 100644
--- a/include/asm-ia64/gcc_intrin.h
+++ b/include/asm-ia64/gcc_intrin.h
@@ -21,6 +21,10 @@
=20
 #define ia64_invala_fr(regnum)	asm volatile ("invala.e f%0" ::
"i"(regnum))
=20
+#define ia64_flushrs() asm volatile ("flushrs;;":::"memory")
+
+#define ia64_loadrs() asm volatile ("loadrs;;":::"memory")
+
 extern void ia64_bad_param_for_setreg (void);
 extern void ia64_bad_param_for_getreg (void);
=20
@@ -517,6 +521,14 @@ do {
\
 #define ia64_ptrd(addr, size)
\
 	asm volatile ("ptr.d %0,%1" :: "r"(addr), "r"(size) : "memory")
=20
+#define ia64_ttag(addr)
\
+({
\
+	__u64 ia64_intri_res;
\
+	asm volatile ("ttag %0=3D%1" : "=3Dr"(ia64_intri_res) : "r" (addr));
\
+	ia64_intri_res;
\
+})
+
+
 /* Values for lfhint in ia64_lfetch and ia64_lfetch_fault */
=20
 #define ia64_lfhint_none   0
diff --git a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
index 741f7ec..6aff126 100644
--- a/include/asm-ia64/processor.h
+++ b/include/asm-ia64/processor.h
@@ -119,6 +119,69 @@ struct ia64_psr {
 	__u64 reserved4 : 19;
 };
=20
+union ia64_isr {
+	__u64  val;
+	struct {
+		__u64 code : 16;
+		__u64 vector : 8;
+		__u64 reserved1 : 8;
+		__u64 x : 1;
+		__u64 w : 1;
+		__u64 r : 1;
+		__u64 na : 1;
+		__u64 sp : 1;
+		__u64 rs : 1;
+		__u64 ir : 1;
+		__u64 ni : 1;
+		__u64 so : 1;
+		__u64 ei : 2;
+		__u64 ed : 1;
+		__u64 reserved2 : 20;
+	};
+};
+
+union ia64_lid {
+	__u64 val;
+	struct {
+		__u64  rv  : 16;
+		__u64  eid : 8;
+		__u64  id  : 8;
+		__u64  ig  : 32;
+	};
+};
+
+union ia64_tpr {
+	__u64 val;
+	struct {
+		__u64 ig0 : 4;
+		__u64 mic : 4;
+		__u64 rsv : 8;
+		__u64 mmi : 1;
+		__u64 ig1 : 47;
+	};
+};
+
+union ia64_itir {
+	__u64 val;
+	struct {
+		__u64 rv3  :  2; /* 0-1 */
+		__u64 ps   :  6; /* 2-7 */
+		__u64 key  : 24; /* 8-31 */
+		__u64 rv4  : 32; /* 32-63 */
+	};
+};
+
+union  ia64_rr {
+	__u64 val;
+	struct {
+		__u64  ve	:  1;  /* enable hw walker */
+		__u64  reserved0:  1;  /* reserved */
+		__u64  ps	:  6;  /* log page size */
+		__u64  rid	: 24;  /* region id */
+		__u64  reserved1: 32;  /* reserved */
+	};
+};
+
 /*
  * CPU type, hardware bug flags, and per-CPU state.  Frequently used
  * state comes earlier:
--=20
1.5.2

------_=_NextPart_001_01C893E5.27C20703
Content-Type: application/octet-stream;
	name="0003-KVM-IA64-Prepare-some-structure-and-routines-for.patch"
Content-Transfer-Encoding: base64
Content-Description: 0003-KVM-IA64-Prepare-some-structure-and-routines-for.patch
Content-Disposition: attachment;
	filename="0003-KVM-IA64-Prepare-some-structure-and-routines-for.patch"

RnJvbSA3ZjE3MTQzNzdlNmQ1ODEyYjQ1NTdiYjNjY2Q4MjY4YjU3ODY1OTUyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAxIEFwciAyMDA4IDE0OjQyOjAwICswODAwClN1YmplY3Q6IFtQQVRDSF0g
S1ZNOiBJQTY0IDogUHJlcGFyZSBzb21lIHN0cnVjdHVyZSBhbmQgcm91dGluZXMgZm9yIGt2bSB1
c2UuCgpSZWdpc3RlciBzdHJ1Y3R1cmVzIGFyZSBkZWZpbmVkIHBlciBTRE0uCkFkZCB0aHJlZSBz
bWFsbCByb3V0aW5lcyBmb3Iga2VybmVsOgppYTY0X3R0YWcsIGlhNjRfbG9hZHJzLCBpYTY0X2Zs
dXNocnMKU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5j
b20+Ci0tLQogaW5jbHVkZS9hc20taWE2NC9nY2NfaW50cmluLmggfCAgIDEyICsrKysrKysrCiBp
bmNsdWRlL2FzbS1pYTY0L3Byb2Nlc3Nvci5oICB8ICAgNjMgKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysKIDIgZmlsZXMgY2hhbmdlZCwgNzUgaW5zZXJ0aW9ucygrKSwg
MCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9pbmNsdWRlL2FzbS1pYTY0L2djY19pbnRyaW4u
aCBiL2luY2x1ZGUvYXNtLWlhNjQvZ2NjX2ludHJpbi5oCmluZGV4IGRlMmVkMmMuLjJmZTI5MmMg
MTAwNjQ0Ci0tLSBhL2luY2x1ZGUvYXNtLWlhNjQvZ2NjX2ludHJpbi5oCisrKyBiL2luY2x1ZGUv
YXNtLWlhNjQvZ2NjX2ludHJpbi5oCkBAIC0yMSw2ICsyMSwxMCBAQAogCiAjZGVmaW5lIGlhNjRf
aW52YWxhX2ZyKHJlZ251bSkJYXNtIHZvbGF0aWxlICgiaW52YWxhLmUgZiUwIiA6OiAiaSIocmVn
bnVtKSkKIAorI2RlZmluZSBpYTY0X2ZsdXNocnMoKSBhc20gdm9sYXRpbGUgKCJmbHVzaHJzOzsi
Ojo6Im1lbW9yeSIpCisKKyNkZWZpbmUgaWE2NF9sb2FkcnMoKSBhc20gdm9sYXRpbGUgKCJsb2Fk
cnM7OyI6OjoibWVtb3J5IikKKwogZXh0ZXJuIHZvaWQgaWE2NF9iYWRfcGFyYW1fZm9yX3NldHJl
ZyAodm9pZCk7CiBleHRlcm4gdm9pZCBpYTY0X2JhZF9wYXJhbV9mb3JfZ2V0cmVnICh2b2lkKTsK
IApAQCAtNTE3LDYgKzUyMSwxNCBAQCBkbyB7CQkJCQkJCQkJCVwKICNkZWZpbmUgaWE2NF9wdHJk
KGFkZHIsIHNpemUpCQkJCQkJXAogCWFzbSB2b2xhdGlsZSAoInB0ci5kICUwLCUxIiA6OiAiciIo
YWRkciksICJyIihzaXplKSA6ICJtZW1vcnkiKQogCisjZGVmaW5lIGlhNjRfdHRhZyhhZGRyKQkJ
CQkJCQlcCisoewkJCQkJCQkJCSAgXAorCV9fdTY0IGlhNjRfaW50cmlfcmVzOwkJCQkJCSAgIFwK
Kwlhc20gdm9sYXRpbGUgKCJ0dGFnICUwPSUxIiA6ICI9ciIoaWE2NF9pbnRyaV9yZXMpIDogInIi
IChhZGRyKSk7ICAgXAorCWlhNjRfaW50cmlfcmVzOwkJCQkJCQkgXAorfSkKKworCiAvKiBWYWx1
ZXMgZm9yIGxmaGludCBpbiBpYTY0X2xmZXRjaCBhbmQgaWE2NF9sZmV0Y2hfZmF1bHQgKi8KIAog
I2RlZmluZSBpYTY0X2xmaGludF9ub25lICAgMApkaWZmIC0tZ2l0IGEvaW5jbHVkZS9hc20taWE2
NC9wcm9jZXNzb3IuaCBiL2luY2x1ZGUvYXNtLWlhNjQvcHJvY2Vzc29yLmgKaW5kZXggNzQxZjdl
Yy4uNmFmZjEyNiAxMDA2NDQKLS0tIGEvaW5jbHVkZS9hc20taWE2NC9wcm9jZXNzb3IuaAorKysg
Yi9pbmNsdWRlL2FzbS1pYTY0L3Byb2Nlc3Nvci5oCkBAIC0xMTksNiArMTE5LDY5IEBAIHN0cnVj
dCBpYTY0X3BzciB7CiAJX191NjQgcmVzZXJ2ZWQ0IDogMTk7CiB9OwogCit1bmlvbiBpYTY0X2lz
ciB7CisJX191NjQgIHZhbDsKKwlzdHJ1Y3QgeworCQlfX3U2NCBjb2RlIDogMTY7CisJCV9fdTY0
IHZlY3RvciA6IDg7CisJCV9fdTY0IHJlc2VydmVkMSA6IDg7CisJCV9fdTY0IHggOiAxOworCQlf
X3U2NCB3IDogMTsKKwkJX191NjQgciA6IDE7CisJCV9fdTY0IG5hIDogMTsKKwkJX191NjQgc3Ag
OiAxOworCQlfX3U2NCBycyA6IDE7CisJCV9fdTY0IGlyIDogMTsKKwkJX191NjQgbmkgOiAxOwor
CQlfX3U2NCBzbyA6IDE7CisJCV9fdTY0IGVpIDogMjsKKwkJX191NjQgZWQgOiAxOworCQlfX3U2
NCByZXNlcnZlZDIgOiAyMDsKKwl9OworfTsKKwordW5pb24gaWE2NF9saWQgeworCV9fdTY0IHZh
bDsKKwlzdHJ1Y3QgeworCQlfX3U2NCAgcnYgIDogMTY7CisJCV9fdTY0ICBlaWQgOiA4OworCQlf
X3U2NCAgaWQgIDogODsKKwkJX191NjQgIGlnICA6IDMyOworCX07Cit9OworCit1bmlvbiBpYTY0
X3RwciB7CisJX191NjQgdmFsOworCXN0cnVjdCB7CisJCV9fdTY0IGlnMCA6IDQ7CisJCV9fdTY0
IG1pYyA6IDQ7CisJCV9fdTY0IHJzdiA6IDg7CisJCV9fdTY0IG1taSA6IDE7CisJCV9fdTY0IGln
MSA6IDQ3OworCX07Cit9OworCit1bmlvbiBpYTY0X2l0aXIgeworCV9fdTY0IHZhbDsKKwlzdHJ1
Y3QgeworCQlfX3U2NCBydjMgIDogIDI7IC8qIDAtMSAqLworCQlfX3U2NCBwcyAgIDogIDY7IC8q
IDItNyAqLworCQlfX3U2NCBrZXkgIDogMjQ7IC8qIDgtMzEgKi8KKwkJX191NjQgcnY0ICA6IDMy
OyAvKiAzMi02MyAqLworCX07Cit9OworCit1bmlvbiAgaWE2NF9yciB7CisJX191NjQgdmFsOwor
CXN0cnVjdCB7CisJCV9fdTY0ICB2ZQk6ICAxOyAgLyogZW5hYmxlIGh3IHdhbGtlciAqLworCQlf
X3U2NCAgcmVzZXJ2ZWQwOiAgMTsgIC8qIHJlc2VydmVkICovCisJCV9fdTY0ICBwcwk6ICA2OyAg
LyogbG9nIHBhZ2Ugc2l6ZSAqLworCQlfX3U2NCAgcmlkCTogMjQ7ICAvKiByZWdpb24gaWQgKi8K
KwkJX191NjQgIHJlc2VydmVkMTogMzI7ICAvKiByZXNlcnZlZCAqLworCX07Cit9OworCiAvKgog
ICogQ1BVIHR5cGUsIGhhcmR3YXJlIGJ1ZyBmbGFncywgYW5kIHBlci1DUFUgc3RhdGUuICBGcmVx
dWVudGx5IHVzZWQKICAqIHN0YXRlIGNvbWVzIGVhcmxpZXI6Ci0tIAoxLjUuMgoK

------_=_NextPart_001_01C893E5.27C20703--
