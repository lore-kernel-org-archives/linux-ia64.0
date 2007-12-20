From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 20 Dec 2007 05:57:01 +0000
Subject: [PATCH] Export three symbols for kvm use.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCB139E3@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C842CD.2466FDCB"
List-Id: <linux-ia64.vger.kernel.org>
To: "Luck, Tony" <tony.luck@intel.com>, Avi Kivity <avi@qumranet.com>
Cc: kvm-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C842CD.2466FDCB
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi Tony,
	In order to build kvm source successfully, we need to export
three symbols for kvm use. Please review. Maybe Avi can check-in to
kvm.git upstream first.=20

Thanks
Xiantao=20
From: Zhang Xiantao <xiantao.zhang@intel.com>
Date: Thu, 20 Dec 2007 09:37:41 +0800
Subject: [PATCH] ia64: Export three symbols for module use

Since kvm/module needs to use some unexported functions in kernel,
so export them with this patch.
Signed-off-by: Zhang Xiantao <xiantao.zhang@intel.com>
---
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

------_=_NextPart_001_01C842CD.2466FDCB
Content-Type: application/octet-stream;
	name="kernel.patch"
Content-Transfer-Encoding: base64
Content-Description: kernel.patch
Content-Disposition: attachment;
	filename="kernel.patch"

RnJvbTogWmhhbmcgWGlhbnRhbyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+DQpEYXRlOiBUaHUs
IDIwIERlYyAyMDA3IDA5OjM3OjQxICswODAwDQpTdWJqZWN0OiBbUEFUQ0hdIGlhNjQ6IEV4cG9y
dCB0aHJlZSBzeW1ib2xzIGZvciBtb2R1bGUgdXNlDQoNClNpbmNlIGt2bS9tb2R1bGUgbmVlZHMg
dG8gdXNlIHNvbWUgdW5leHBvcnRlZCBmdW5jdGlvbnMgaW4ga2VybmVsLA0Kc28gZXhwb3J0IHRo
ZW0gd2l0aCB0aGlzIHBhdGNoLg0KU2lnbmVkLW9mZi1ieTogWmhhbmcgWGlhbnRhbyA8eGlhbnRh
by56aGFuZ0BpbnRlbC5jb20+DQotLS0NCmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva2VybmVsL2lh
NjRfa3N5bXMuYyBiL2FyY2gvaWE2NC9rZXJuZWwvaWE2NF9rc3ltcy5jDQppbmRleCBjM2I0NDEy
Li40M2QyMjdmIDEwMDY0NA0KLS0tIGEvYXJjaC9pYTY0L2tlcm5lbC9pYTY0X2tzeW1zLmMNCisr
KyBiL2FyY2gvaWE2NC9rZXJuZWwvaWE2NF9rc3ltcy5jDQpAQCAtMTIsNiArMTIsOSBAQCBFWFBP
UlRfU1lNQk9MKG1lbXNldCk7DQogRVhQT1JUX1NZTUJPTChtZW1jcHkpOw0KIEVYUE9SVF9TWU1C
T0woc3RybGVuKTsNCiANCisjaW5jbHVkZTxhc20vcGd0YWJsZS5oPg0KK0VYUE9SVF9TWU1CT0wo
ZW1wdHlfemVyb19wYWdlKTsNCisNCiAjaW5jbHVkZSA8YXNtL2NoZWNrc3VtLmg+DQogRVhQT1JU
X1NZTUJPTChpcF9mYXN0X2NzdW0pOwkJLyogaGFuZC1jb2RlZCBhc3NlbWJseSAqLw0KIEVYUE9S
VF9TWU1CT0woY3N1bV9pcHY2X21hZ2ljKTsNCmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva2VybmVs
L3NhbC5jIGIvYXJjaC9pYTY0L2tlcm5lbC9zYWwuYw0KaW5kZXggMjdjMmVmNC4uNjdjMWQzNCAx
MDA2NDQNCi0tLSBhL2FyY2gvaWE2NC9rZXJuZWwvc2FsLmMNCisrKyBiL2FyY2gvaWE2NC9rZXJu
ZWwvc2FsLmMNCkBAIC0yODQsNiArMjg0LDcgQEAgaWE2NF9zYWxfY2FjaGVfZmx1c2ggKHU2NCBj
YWNoZV90eXBlKQ0KIAlTQUxfQ0FMTChpc3J2LCBTQUxfQ0FDSEVfRkxVU0gsIGNhY2hlX3R5cGUs
IDAsIDAsIDAsIDAsIDAsIDApOw0KIAlyZXR1cm4gaXNydi5zdGF0dXM7DQogfQ0KK0VYUE9SVF9T
WU1CT0woaWE2NF9zYWxfY2FjaGVfZmx1c2gpOw0KIA0KIHZvaWQgX19pbml0DQogaWE2NF9zYWxf
aW5pdCAoc3RydWN0IGlhNjRfc2FsX3N5c3RhYiAqc3lzdGFiKQ0KQEAgLTM3MiwzICszNzMsMTYg
QEAgaWE2NF9zYWxfb2VtY2FsbF9yZWVudHJhbnQoc3RydWN0IGlhNjRfc2FsX3JldHZhbCAqaXNy
dnAsIHU2NCBvZW1mdW5jLA0KIAlyZXR1cm4gMDsNCiB9DQogRVhQT1JUX1NZTUJPTChpYTY0X3Nh
bF9vZW1jYWxsX3JlZW50cmFudCk7DQorDQorbG9uZw0KK2lhNjRfc2FsX2ZyZXFfYmFzZSAodW5z
aWduZWQgbG9uZyB3aGljaCwgdW5zaWduZWQgbG9uZyAqdGlja3NfcGVyX3NlY29uZCwNCisJCSAg
ICB1bnNpZ25lZCBsb25nICpkcmlmdF9pbmZvKQ0KK3sNCisJc3RydWN0IGlhNjRfc2FsX3JldHZh
bCBpc3J2Ow0KKw0KKwlTQUxfQ0FMTChpc3J2LCBTQUxfRlJFUV9CQVNFLCB3aGljaCwgMCwgMCwg
MCwgMCwgMCwgMCk7DQorCSp0aWNrc19wZXJfc2Vjb25kID0gaXNydi52MDsNCisJKmRyaWZ0X2lu
Zm8gPSBpc3J2LnYxOw0KKwlyZXR1cm4gaXNydi5zdGF0dXM7DQorfQ0KK0VYUE9SVF9TWU1CT0wo
aWE2NF9zYWxfZnJlcV9iYXNlKTsNCmRpZmYgLS1naXQgYS9pbmNsdWRlL2FzbS1pYTY0L3NhbC5o
IGIvaW5jbHVkZS9hc20taWE2NC9zYWwuaA0KaW5kZXggMWY1NDEyZC4uMjI1MTExOCAxMDA2NDQN
Ci0tLSBhL2luY2x1ZGUvYXNtLWlhNjQvc2FsLmgNCisrKyBiL2luY2x1ZGUvYXNtLWlhNjQvc2Fs
LmgNCkBAIC02NDksMTcgKzY0OSw2IEBAIHR5cGVkZWYgc3RydWN0IGVycl9yZWMgew0KICAqIE5v
dyBkZWZpbmUgYSBjb3VwbGUgb2YgaW5saW5lIGZ1bmN0aW9ucyBmb3IgaW1wcm92ZWQgdHlwZSBj
aGVja2luZw0KICAqIGFuZCBjb252ZW5pZW5jZS4NCiAgKi8NCi1zdGF0aWMgaW5saW5lIGxvbmcN
Ci1pYTY0X3NhbF9mcmVxX2Jhc2UgKHVuc2lnbmVkIGxvbmcgd2hpY2gsIHVuc2lnbmVkIGxvbmcg
KnRpY2tzX3Blcl9zZWNvbmQsDQotCQkgICAgdW5zaWduZWQgbG9uZyAqZHJpZnRfaW5mbykNCi17
DQotCXN0cnVjdCBpYTY0X3NhbF9yZXR2YWwgaXNydjsNCi0NCi0JU0FMX0NBTEwoaXNydiwgU0FM
X0ZSRVFfQkFTRSwgd2hpY2gsIDAsIDAsIDAsIDAsIDAsIDApOw0KLQkqdGlja3NfcGVyX3NlY29u
ZCA9IGlzcnYudjA7DQotCSpkcmlmdF9pbmZvID0gaXNydi52MTsNCi0JcmV0dXJuIGlzcnYuc3Rh
dHVzOw0KLX0NCiANCiBleHRlcm4gczY0IGlhNjRfc2FsX2NhY2hlX2ZsdXNoICh1NjQgY2FjaGVf
dHlwZSk7DQogZXh0ZXJuIHZvaWQgX19pbml0IGNoZWNrX3NhbF9jYWNoZV9mbHVzaCAodm9pZCk7
DQpAQCAtODQxLDYgKzgzMCw5IEBAIGV4dGVybiBpbnQgaWE2NF9zYWxfb2VtY2FsbF9ub2xvY2so
c3RydWN0IGlhNjRfc2FsX3JldHZhbCAqLCB1NjQsIHU2NCwgdTY0LA0KIAkJCQkgICB1NjQsIHU2
NCwgdTY0LCB1NjQsIHU2NCk7DQogZXh0ZXJuIGludCBpYTY0X3NhbF9vZW1jYWxsX3JlZW50cmFu
dChzdHJ1Y3QgaWE2NF9zYWxfcmV0dmFsICosIHU2NCwgdTY0LCB1NjQsDQogCQkJCSAgICAgIHU2
NCwgdTY0LCB1NjQsIHU2NCwgdTY0KTsNCitleHRlcm4gbG9uZw0KK2lhNjRfc2FsX2ZyZXFfYmFz
ZSAodW5zaWduZWQgbG9uZyB3aGljaCwgdW5zaWduZWQgbG9uZyAqdGlja3NfcGVyX3NlY29uZCwN
CisJCSAgICB1bnNpZ25lZCBsb25nICpkcmlmdF9pbmZvKTsNCiAjaWZkZWYgQ09ORklHX0hPVFBM
VUdfQ1BVDQogLyoNCiAgKiBTeXN0ZW0gQWJzdHJhY3Rpb24gTGF5ZXIgU3BlY2lmaWNhdGlvbg0K

------_=_NextPart_001_01C842CD.2466FDCB--
