From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:28:29 +0000
Subject: [PATCH][03]Export some symbols out for module use.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FC6@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F4.058D7CB7"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F4.058D7CB7
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: xiantao.zhang@intel.com <xiantao.zhang@intel.com>
Date: Thu, 17 Jan 2008 14:03:04 +0800
Subject: [PATCH] kvm: ia64 : Export some symbols out for module use.

Export empty_zero_page, ia64_sal_cache_flush, ia64_sal_freq_base
in this patch.
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
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
1.5.1

------_=_NextPart_001_01C863F4.058D7CB7
Content-Type: application/octet-stream;
	name="0003-kvm-ia64-Export-some-symbols-out-for-module-use.patch"
Content-Transfer-Encoding: base64
Content-Description: 0003-kvm-ia64-Export-some-symbols-out-for-module-use.patch
Content-Disposition: attachment;
	filename="0003-kvm-ia64-Export-some-symbols-out-for-module-use.patch"

RnJvbSA3NDIxYWJhZDFhNzExMzU4MWE3YjE5YTg0NTQ1ZGExZWJiMmZiYzlhIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiB4aWFudGFvLnpoYW5nQGludGVsLmNvbSA8eGlhbnRhby56aGFu
Z0BpbnRlbC5jb20+CkRhdGU6IFRodSwgMTcgSmFuIDIwMDggMTQ6MDM6MDQgKzA4MDAKU3ViamVj
dDogW1BBVENIXSBrdm06IGlhNjQgOiBFeHBvcnQgc29tZSBzeW1ib2xzIG91dCBmb3IgbW9kdWxl
IHVzZS4KCkV4cG9ydCBlbXB0eV96ZXJvX3BhZ2UsIGlhNjRfc2FsX2NhY2hlX2ZsdXNoLCBpYTY0
X3NhbF9mcmVxX2Jhc2UKaW4gdGhpcyBwYXRjaC4KU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFu
ZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+Ci0tLQogYXJjaC9pYTY0L2tlcm5lbC9pYTY0X2tz
eW1zLmMgfCAgICAzICsrKwogYXJjaC9pYTY0L2tlcm5lbC9zYWwuYyAgICAgICAgfCAgIDE0ICsr
KysrKysrKysrKysrCiBpbmNsdWRlL2FzbS1pYTY0L3NhbC5oICAgICAgICB8ICAgMTQgKysrLS0t
LS0tLS0tLS0KIDMgZmlsZXMgY2hhbmdlZCwgMjAgaW5zZXJ0aW9ucygrKSwgMTEgZGVsZXRpb25z
KC0pCgpkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2tlcm5lbC9pYTY0X2tzeW1zLmMgYi9hcmNoL2lh
NjQva2VybmVsL2lhNjRfa3N5bXMuYwppbmRleCBjM2I0NDEyLi40M2QyMjdmIDEwMDY0NAotLS0g
YS9hcmNoL2lhNjQva2VybmVsL2lhNjRfa3N5bXMuYworKysgYi9hcmNoL2lhNjQva2VybmVsL2lh
NjRfa3N5bXMuYwpAQCAtMTIsNiArMTIsOSBAQCBFWFBPUlRfU1lNQk9MKG1lbXNldCk7CiBFWFBP
UlRfU1lNQk9MKG1lbWNweSk7CiBFWFBPUlRfU1lNQk9MKHN0cmxlbik7CiAKKyNpbmNsdWRlPGFz
bS9wZ3RhYmxlLmg+CitFWFBPUlRfU1lNQk9MKGVtcHR5X3plcm9fcGFnZSk7CisKICNpbmNsdWRl
IDxhc20vY2hlY2tzdW0uaD4KIEVYUE9SVF9TWU1CT0woaXBfZmFzdF9jc3VtKTsJCS8qIGhhbmQt
Y29kZWQgYXNzZW1ibHkgKi8KIEVYUE9SVF9TWU1CT0woY3N1bV9pcHY2X21hZ2ljKTsKZGlmZiAt
LWdpdCBhL2FyY2gvaWE2NC9rZXJuZWwvc2FsLmMgYi9hcmNoL2lhNjQva2VybmVsL3NhbC5jCmlu
ZGV4IDI3YzJlZjQuLjY3YzFkMzQgMTAwNjQ0Ci0tLSBhL2FyY2gvaWE2NC9rZXJuZWwvc2FsLmMK
KysrIGIvYXJjaC9pYTY0L2tlcm5lbC9zYWwuYwpAQCAtMjg0LDYgKzI4NCw3IEBAIGlhNjRfc2Fs
X2NhY2hlX2ZsdXNoICh1NjQgY2FjaGVfdHlwZSkKIAlTQUxfQ0FMTChpc3J2LCBTQUxfQ0FDSEVf
RkxVU0gsIGNhY2hlX3R5cGUsIDAsIDAsIDAsIDAsIDAsIDApOwogCXJldHVybiBpc3J2LnN0YXR1
czsKIH0KK0VYUE9SVF9TWU1CT0woaWE2NF9zYWxfY2FjaGVfZmx1c2gpOwogCiB2b2lkIF9faW5p
dAogaWE2NF9zYWxfaW5pdCAoc3RydWN0IGlhNjRfc2FsX3N5c3RhYiAqc3lzdGFiKQpAQCAtMzcy
LDMgKzM3MywxNiBAQCBpYTY0X3NhbF9vZW1jYWxsX3JlZW50cmFudChzdHJ1Y3QgaWE2NF9zYWxf
cmV0dmFsICppc3J2cCwgdTY0IG9lbWZ1bmMsCiAJcmV0dXJuIDA7CiB9CiBFWFBPUlRfU1lNQk9M
KGlhNjRfc2FsX29lbWNhbGxfcmVlbnRyYW50KTsKKworbG9uZworaWE2NF9zYWxfZnJlcV9iYXNl
ICh1bnNpZ25lZCBsb25nIHdoaWNoLCB1bnNpZ25lZCBsb25nICp0aWNrc19wZXJfc2Vjb25kLAor
CQkgICAgdW5zaWduZWQgbG9uZyAqZHJpZnRfaW5mbykKK3sKKwlzdHJ1Y3QgaWE2NF9zYWxfcmV0
dmFsIGlzcnY7CisKKwlTQUxfQ0FMTChpc3J2LCBTQUxfRlJFUV9CQVNFLCB3aGljaCwgMCwgMCwg
MCwgMCwgMCwgMCk7CisJKnRpY2tzX3Blcl9zZWNvbmQgPSBpc3J2LnYwOworCSpkcmlmdF9pbmZv
ID0gaXNydi52MTsKKwlyZXR1cm4gaXNydi5zdGF0dXM7Cit9CitFWFBPUlRfU1lNQk9MKGlhNjRf
c2FsX2ZyZXFfYmFzZSk7CmRpZmYgLS1naXQgYS9pbmNsdWRlL2FzbS1pYTY0L3NhbC5oIGIvaW5j
bHVkZS9hc20taWE2NC9zYWwuaAppbmRleCAxZjU0MTJkLi4yMjUxMTE4IDEwMDY0NAotLS0gYS9p
bmNsdWRlL2FzbS1pYTY0L3NhbC5oCisrKyBiL2luY2x1ZGUvYXNtLWlhNjQvc2FsLmgKQEAgLTY0
OSwxNyArNjQ5LDYgQEAgdHlwZWRlZiBzdHJ1Y3QgZXJyX3JlYyB7CiAgKiBOb3cgZGVmaW5lIGEg
Y291cGxlIG9mIGlubGluZSBmdW5jdGlvbnMgZm9yIGltcHJvdmVkIHR5cGUgY2hlY2tpbmcKICAq
IGFuZCBjb252ZW5pZW5jZS4KICAqLwotc3RhdGljIGlubGluZSBsb25nCi1pYTY0X3NhbF9mcmVx
X2Jhc2UgKHVuc2lnbmVkIGxvbmcgd2hpY2gsIHVuc2lnbmVkIGxvbmcgKnRpY2tzX3Blcl9zZWNv
bmQsCi0JCSAgICB1bnNpZ25lZCBsb25nICpkcmlmdF9pbmZvKQotewotCXN0cnVjdCBpYTY0X3Nh
bF9yZXR2YWwgaXNydjsKLQotCVNBTF9DQUxMKGlzcnYsIFNBTF9GUkVRX0JBU0UsIHdoaWNoLCAw
LCAwLCAwLCAwLCAwLCAwKTsKLQkqdGlja3NfcGVyX3NlY29uZCA9IGlzcnYudjA7Ci0JKmRyaWZ0
X2luZm8gPSBpc3J2LnYxOwotCXJldHVybiBpc3J2LnN0YXR1czsKLX0KIAogZXh0ZXJuIHM2NCBp
YTY0X3NhbF9jYWNoZV9mbHVzaCAodTY0IGNhY2hlX3R5cGUpOwogZXh0ZXJuIHZvaWQgX19pbml0
IGNoZWNrX3NhbF9jYWNoZV9mbHVzaCAodm9pZCk7CkBAIC04NDEsNiArODMwLDkgQEAgZXh0ZXJu
IGludCBpYTY0X3NhbF9vZW1jYWxsX25vbG9jayhzdHJ1Y3QgaWE2NF9zYWxfcmV0dmFsICosIHU2
NCwgdTY0LCB1NjQsCiAJCQkJICAgdTY0LCB1NjQsIHU2NCwgdTY0LCB1NjQpOwogZXh0ZXJuIGlu
dCBpYTY0X3NhbF9vZW1jYWxsX3JlZW50cmFudChzdHJ1Y3QgaWE2NF9zYWxfcmV0dmFsICosIHU2
NCwgdTY0LCB1NjQsCiAJCQkJICAgICAgdTY0LCB1NjQsIHU2NCwgdTY0LCB1NjQpOworZXh0ZXJu
IGxvbmcKK2lhNjRfc2FsX2ZyZXFfYmFzZSAodW5zaWduZWQgbG9uZyB3aGljaCwgdW5zaWduZWQg
bG9uZyAqdGlja3NfcGVyX3NlY29uZCwKKwkJICAgIHVuc2lnbmVkIGxvbmcgKmRyaWZ0X2luZm8p
OwogI2lmZGVmIENPTkZJR19IT1RQTFVHX0NQVQogLyoKICAqIFN5c3RlbSBBYnN0cmFjdGlvbiBM
YXllciBTcGVjaWZpY2F0aW9uCi0tIAoxLjUuMQoK

------_=_NextPart_001_01C863F4.058D7CB7--
