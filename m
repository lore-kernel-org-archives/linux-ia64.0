From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 17 Jan 2008 06:20:00 +0000
Subject: [PATCH] Export three symbols out.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCC4BAA2@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C858D0.FDAC8746"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: kvm-devel <kvm-devel@lists.sourceforge.net>, linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C858D0.FDAC8746
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi, Avi/Tony=20
    This patch exports three symbols out for module use.  Please
comments! :)=20
Thanks
Xiantao

From: xiantao.zhang@intel.com <xiantao.zhang@intel.com>
Date: Thu, 17 Jan 2008 14:03:04 +0800
Subject: [PATCH] kvm: ia64 : Export some symbols out for module use.

Export empty_zero_page, ia64_sal_cache_flush, ia64_sal_freq_base
in this patch.
Signed-off-by: xiantao.zhang@intel.com <xiantao.zhang@intel.com>
---
 arch/ia64/kernel/ia64_ksyms.c |    3 +++
 arch/ia64/kernel/sal.c        |   14 ++++++++++++++
 include/asm-ia64/sal.h        |   14 +++-----------
 3 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/arch/ia64/kernel/ia64_ksyms.c
b/arch/ia64/kernel/ia64_ksyms.c
index c3b4412..43d227f 100644
--- a/arch/ia64/kernel/ia64_ksyms.c
+++ b/arch/ia64/kernel/ia64_ksyms.c
@@ -12,6 +12,9 @@ EXPORT_SYMBOL(memset);
 EXPORT_SYMBOL(memcpy);
 EXPORT_SYMBOL(strlen);
=20
+#include<asm/pgtable.h>
+EXPORT_SYMBOL(empty_zero_page);
+
 #include <asm/checksum.h>
 EXPORT_SYMBOL(ip_fast_csum);		/* hand-coded assembly */
 EXPORT_SYMBOL(csum_ipv6_magic);
diff --git a/arch/ia64/kernel/sal.c b/arch/ia64/kernel/sal.c
index 27c2ef4..67c1d34 100644
--- a/arch/ia64/kernel/sal.c
+++ b/arch/ia64/kernel/sal.c
@@ -284,6 +284,7 @@ ia64_sal_cache_flush (u64 cache_type)
 	SAL_CALL(isrv, SAL_CACHE_FLUSH, cache_type, 0, 0, 0, 0, 0, 0);
 	return isrv.status;
 }
+EXPORT_SYMBOL(ia64_sal_cache_flush);
=20
 void __init
 ia64_sal_init (struct ia64_sal_systab *systab)
@@ -372,3 +373,16 @@ ia64_sal_oemcall_reentrant(struct ia64_sal_retval
*isrvp, u64 oemfunc,
 	return 0;
 }
 EXPORT_SYMBOL(ia64_sal_oemcall_reentrant);
+
+long
+ia64_sal_freq_base (unsigned long which, unsigned long
*ticks_per_second,
+		    unsigned long *drift_info)
+{
+	struct ia64_sal_retval isrv;
+
+	SAL_CALL(isrv, SAL_FREQ_BASE, which, 0, 0, 0, 0, 0, 0);
+	*ticks_per_second =3D isrv.v0;
+	*drift_info =3D isrv.v1;
+	return isrv.status;
+}
+EXPORT_SYMBOL(ia64_sal_freq_base);
diff --git a/include/asm-ia64/sal.h b/include/asm-ia64/sal.h
index 1f5412d..2251118 100644
--- a/include/asm-ia64/sal.h
+++ b/include/asm-ia64/sal.h
@@ -649,17 +649,6 @@ typedef struct err_rec {
  * Now define a couple of inline functions for improved type checking
  * and convenience.
  */
-static inline long
-ia64_sal_freq_base (unsigned long which, unsigned long
*ticks_per_second,
-		    unsigned long *drift_info)
-{
-	struct ia64_sal_retval isrv;
-
-	SAL_CALL(isrv, SAL_FREQ_BASE, which, 0, 0, 0, 0, 0, 0);
-	*ticks_per_second =3D isrv.v0;
-	*drift_info =3D isrv.v1;
-	return isrv.status;
-}
=20
 extern s64 ia64_sal_cache_flush (u64 cache_type);
 extern void __init check_sal_cache_flush (void);
@@ -841,6 +830,9 @@ extern int ia64_sal_oemcall_nolock(struct
ia64_sal_retval *, u64, u64, u64,
 				   u64, u64, u64, u64, u64);
 extern int ia64_sal_oemcall_reentrant(struct ia64_sal_retval *, u64,
u64, u64,
 				      u64, u64, u64, u64, u64);
+extern long
+ia64_sal_freq_base (unsigned long which, unsigned long
*ticks_per_second,
+		    unsigned long *drift_info);
 #ifdef CONFIG_HOTPLUG_CPU
 /*
  * System Abstraction Layer Specification
--=20
1.5.2

------_=_NextPart_001_01C858D0.FDAC8746
Content-Type: application/octet-stream;
	name="0001-kvm-ia64-Export-some-symbols-out-for-module-use.patch"
Content-Transfer-Encoding: base64
Content-Description: 0001-kvm-ia64-Export-some-symbols-out-for-module-use.patch
Content-Disposition: attachment;
	filename="0001-kvm-ia64-Export-some-symbols-out-for-module-use.patch"

RnJvbSAxYzViZDM1MTJlMDg3Y2QyODNhZTVkZTY2ZTc0YmViYzQwY2UwOGNkIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiB4aWFudGFvLnpoYW5nQGludGVsLmNvbSA8eGlhbnRhby56aGFu
Z0BpbnRlbC5jb20+CkRhdGU6IFRodSwgMTcgSmFuIDIwMDggMTQ6MDM6MDQgKzA4MDAKU3ViamVj
dDogW1BBVENIXSBrdm06IGlhNjQgOiBFeHBvcnQgc29tZSBzeW1ib2xzIG91dCBmb3IgbW9kdWxl
IHVzZS4KCkV4cG9ydCBlbXB0eV96ZXJvX3BhZ2UsIGlhNjRfc2FsX2NhY2hlX2ZsdXNoLCBpYTY0
X3NhbF9mcmVxX2Jhc2UKaW4gdGhpcyBwYXRjaC4KU2lnbmVkLW9mZi1ieTogeGlhbnRhby56aGFu
Z0BpbnRlbC5jb20gPHhpYW50YW8uemhhbmdAaW50ZWwuY29tPgotLS0KIGFyY2gvaWE2NC9rZXJu
ZWwvaWE2NF9rc3ltcy5jIHwgICAgMyArKysKIGFyY2gvaWE2NC9rZXJuZWwvc2FsLmMgICAgICAg
IHwgICAxNCArKysrKysrKysrKysrKwogaW5jbHVkZS9hc20taWE2NC9zYWwuaCAgICAgICAgfCAg
IDE0ICsrKy0tLS0tLS0tLS0tCiAzIGZpbGVzIGNoYW5nZWQsIDIwIGluc2VydGlvbnMoKyksIDEx
IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rZXJuZWwvaWE2NF9rc3ltcy5j
IGIvYXJjaC9pYTY0L2tlcm5lbC9pYTY0X2tzeW1zLmMKaW5kZXggYzNiNDQxMi4uNDNkMjI3ZiAx
MDA2NDQKLS0tIGEvYXJjaC9pYTY0L2tlcm5lbC9pYTY0X2tzeW1zLmMKKysrIGIvYXJjaC9pYTY0
L2tlcm5lbC9pYTY0X2tzeW1zLmMKQEAgLTEyLDYgKzEyLDkgQEAgRVhQT1JUX1NZTUJPTChtZW1z
ZXQpOwogRVhQT1JUX1NZTUJPTChtZW1jcHkpOwogRVhQT1JUX1NZTUJPTChzdHJsZW4pOwogCisj
aW5jbHVkZTxhc20vcGd0YWJsZS5oPgorRVhQT1JUX1NZTUJPTChlbXB0eV96ZXJvX3BhZ2UpOwor
CiAjaW5jbHVkZSA8YXNtL2NoZWNrc3VtLmg+CiBFWFBPUlRfU1lNQk9MKGlwX2Zhc3RfY3N1bSk7
CQkvKiBoYW5kLWNvZGVkIGFzc2VtYmx5ICovCiBFWFBPUlRfU1lNQk9MKGNzdW1faXB2Nl9tYWdp
Yyk7CmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva2VybmVsL3NhbC5jIGIvYXJjaC9pYTY0L2tlcm5l
bC9zYWwuYwppbmRleCAyN2MyZWY0Li42N2MxZDM0IDEwMDY0NAotLS0gYS9hcmNoL2lhNjQva2Vy
bmVsL3NhbC5jCisrKyBiL2FyY2gvaWE2NC9rZXJuZWwvc2FsLmMKQEAgLTI4NCw2ICsyODQsNyBA
QCBpYTY0X3NhbF9jYWNoZV9mbHVzaCAodTY0IGNhY2hlX3R5cGUpCiAJU0FMX0NBTEwoaXNydiwg
U0FMX0NBQ0hFX0ZMVVNILCBjYWNoZV90eXBlLCAwLCAwLCAwLCAwLCAwLCAwKTsKIAlyZXR1cm4g
aXNydi5zdGF0dXM7CiB9CitFWFBPUlRfU1lNQk9MKGlhNjRfc2FsX2NhY2hlX2ZsdXNoKTsKIAog
dm9pZCBfX2luaXQKIGlhNjRfc2FsX2luaXQgKHN0cnVjdCBpYTY0X3NhbF9zeXN0YWIgKnN5c3Rh
YikKQEAgLTM3MiwzICszNzMsMTYgQEAgaWE2NF9zYWxfb2VtY2FsbF9yZWVudHJhbnQoc3RydWN0
IGlhNjRfc2FsX3JldHZhbCAqaXNydnAsIHU2NCBvZW1mdW5jLAogCXJldHVybiAwOwogfQogRVhQ
T1JUX1NZTUJPTChpYTY0X3NhbF9vZW1jYWxsX3JlZW50cmFudCk7CisKK2xvbmcKK2lhNjRfc2Fs
X2ZyZXFfYmFzZSAodW5zaWduZWQgbG9uZyB3aGljaCwgdW5zaWduZWQgbG9uZyAqdGlja3NfcGVy
X3NlY29uZCwKKwkJICAgIHVuc2lnbmVkIGxvbmcgKmRyaWZ0X2luZm8pCit7CisJc3RydWN0IGlh
NjRfc2FsX3JldHZhbCBpc3J2OworCisJU0FMX0NBTEwoaXNydiwgU0FMX0ZSRVFfQkFTRSwgd2hp
Y2gsIDAsIDAsIDAsIDAsIDAsIDApOworCSp0aWNrc19wZXJfc2Vjb25kID0gaXNydi52MDsKKwkq
ZHJpZnRfaW5mbyA9IGlzcnYudjE7CisJcmV0dXJuIGlzcnYuc3RhdHVzOworfQorRVhQT1JUX1NZ
TUJPTChpYTY0X3NhbF9mcmVxX2Jhc2UpOwpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9hc20taWE2NC9z
YWwuaCBiL2luY2x1ZGUvYXNtLWlhNjQvc2FsLmgKaW5kZXggMWY1NDEyZC4uMjI1MTExOCAxMDA2
NDQKLS0tIGEvaW5jbHVkZS9hc20taWE2NC9zYWwuaAorKysgYi9pbmNsdWRlL2FzbS1pYTY0L3Nh
bC5oCkBAIC02NDksMTcgKzY0OSw2IEBAIHR5cGVkZWYgc3RydWN0IGVycl9yZWMgewogICogTm93
IGRlZmluZSBhIGNvdXBsZSBvZiBpbmxpbmUgZnVuY3Rpb25zIGZvciBpbXByb3ZlZCB0eXBlIGNo
ZWNraW5nCiAgKiBhbmQgY29udmVuaWVuY2UuCiAgKi8KLXN0YXRpYyBpbmxpbmUgbG9uZwotaWE2
NF9zYWxfZnJlcV9iYXNlICh1bnNpZ25lZCBsb25nIHdoaWNoLCB1bnNpZ25lZCBsb25nICp0aWNr
c19wZXJfc2Vjb25kLAotCQkgICAgdW5zaWduZWQgbG9uZyAqZHJpZnRfaW5mbykKLXsKLQlzdHJ1
Y3QgaWE2NF9zYWxfcmV0dmFsIGlzcnY7Ci0KLQlTQUxfQ0FMTChpc3J2LCBTQUxfRlJFUV9CQVNF
LCB3aGljaCwgMCwgMCwgMCwgMCwgMCwgMCk7Ci0JKnRpY2tzX3Blcl9zZWNvbmQgPSBpc3J2LnYw
OwotCSpkcmlmdF9pbmZvID0gaXNydi52MTsKLQlyZXR1cm4gaXNydi5zdGF0dXM7Ci19CiAKIGV4
dGVybiBzNjQgaWE2NF9zYWxfY2FjaGVfZmx1c2ggKHU2NCBjYWNoZV90eXBlKTsKIGV4dGVybiB2
b2lkIF9faW5pdCBjaGVja19zYWxfY2FjaGVfZmx1c2ggKHZvaWQpOwpAQCAtODQxLDYgKzgzMCw5
IEBAIGV4dGVybiBpbnQgaWE2NF9zYWxfb2VtY2FsbF9ub2xvY2soc3RydWN0IGlhNjRfc2FsX3Jl
dHZhbCAqLCB1NjQsIHU2NCwgdTY0LAogCQkJCSAgIHU2NCwgdTY0LCB1NjQsIHU2NCwgdTY0KTsK
IGV4dGVybiBpbnQgaWE2NF9zYWxfb2VtY2FsbF9yZWVudHJhbnQoc3RydWN0IGlhNjRfc2FsX3Jl
dHZhbCAqLCB1NjQsIHU2NCwgdTY0LAogCQkJCSAgICAgIHU2NCwgdTY0LCB1NjQsIHU2NCwgdTY0
KTsKK2V4dGVybiBsb25nCitpYTY0X3NhbF9mcmVxX2Jhc2UgKHVuc2lnbmVkIGxvbmcgd2hpY2gs
IHVuc2lnbmVkIGxvbmcgKnRpY2tzX3Blcl9zZWNvbmQsCisJCSAgICB1bnNpZ25lZCBsb25nICpk
cmlmdF9pbmZvKTsKICNpZmRlZiBDT05GSUdfSE9UUExVR19DUFUKIC8qCiAgKiBTeXN0ZW0gQWJz
dHJhY3Rpb24gTGF5ZXIgU3BlY2lmaWNhdGlvbgotLSAKMS41LjIKCg==

------_=_NextPart_001_01C858D0.FDAC8746--
