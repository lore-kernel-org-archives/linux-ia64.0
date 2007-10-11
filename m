From: "Xu, Anthony" <anthony.xu@intel.com>
Date: Thu, 11 Oct 2007 08:53:58 +0000
Subject: [PATCH]  correctly use sal call attribute
Message-Id: <51CFAB8CB6883745AE7B93B3E084EBE201244820@pdsmsx412.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C80BE4.436D5F8D"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C80BE4.436D5F8D
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Correctly use sal call attribute such as mf-safe and reentrant=20


Signed-off-by: Anthony Xu < anthony.xu@intel.com >


diff -urN linux-2.6.23-rc8/arch/ia64/kernel/sal.c
linux/arch/ia64/kernel/sal.c
--- linux-2.6.23-rc8/arch/ia64/kernel/sal.c	2007-09-25
08:33:10.000000000 +0800
+++ linux/arch/ia64/kernel/sal.c	2007-09-29 14:13:10.000000000
+0800
@@ -243,7 +243,7 @@
 	while (!ia64_get_irr(IA64_TIMER_VECTOR))
 		cpu_relax();
=20
-	SAL_CALL(isrv, SAL_CACHE_FLUSH, cache_type, 0, 0, 0, 0, 0, 0);
+	SAL_CALL_NOLOCK(isrv, SAL_CACHE_FLUSH, cache_type, 0, 0, 0, 0,
0, 0);
=20
 	if (isrv.status)
 		printk(KERN_ERR "SAL_CAL_FLUSH failed with %ld\n",
isrv.status);
diff -urN linux-2.6.23-rc8/include/asm-ia64/sal.h
linux/include/asm-ia64/sal.h
--- linux-2.6.23-rc8/include/asm-ia64/sal.h	2007-09-25
08:33:10.000000000 +0800
+++ linux/include/asm-ia64/sal.h	2007-09-29 14:16:46.000000000
+0800
@@ -652,7 +652,7 @@
 {
 	struct ia64_sal_retval isrv;
=20
-	SAL_CALL(isrv, SAL_FREQ_BASE, which, 0, 0, 0, 0, 0, 0);
+	SAL_CALL_NOLOCK(isrv, SAL_FREQ_BASE, which, 0, 0, 0, 0, 0, 0);
 	*ticks_per_second =3D isrv.v0;
 	*drift_info =3D isrv.v1;
 	return isrv.status;
@@ -666,7 +666,7 @@
 ia64_sal_cache_init (void)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_CACHE_INIT, 0, 0, 0, 0, 0, 0, 0);
+	SAL_CALL_NOLOCK(isrv, SAL_CACHE_INIT, 0, 0, 0, 0, 0, 0, 0);
 	return isrv.status;
 }
=20
@@ -748,7 +748,8 @@
 ia64_sal_pci_config_read (u64 pci_config_addr, int type, u64 size, u64
*value)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_PCI_CONFIG_READ, pci_config_addr, size, type,
0, 0, 0, 0);
+	SAL_CALL_REENTRANT(isrv, SAL_PCI_CONFIG_READ, pci_config_addr,
size,
+	         type, 0, 0, 0, 0);
 	if (value)
 		*value =3D isrv.v0;
 	return isrv.status;
@@ -759,8 +760,8 @@
 ia64_sal_pci_config_write (u64 pci_config_addr, int type, u64 size, u64
value)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_PCI_CONFIG_WRITE, pci_config_addr, size,
value,
-	         type, 0, 0, 0);
+	SAL_CALL_REENTRANT(isrv, SAL_PCI_CONFIG_WRITE, pci_config_addr,
size,
+	         value, type, 0, 0, 0);
 	return isrv.status;
 }
=20
@@ -815,7 +816,7 @@
 ia64_sal_physical_id_info(u16 *splid)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_PHYSICAL_ID_INFO, 0, 0, 0, 0, 0, 0, 0);
+	SAL_CALL_NOLOCK(isrv, SAL_PHYSICAL_ID_INFO, 0, 0, 0, 0, 0, 0,
0);
 	if (splid)
 		*splid =3D isrv.v0;
 	return isrv.status;


------_=_NextPart_001_01C80BE4.436D5F8D
Content-Type: application/octet-stream;
	name="sal_call.patch"
Content-Transfer-Encoding: base64
Content-Description: sal_call.patch
Content-Disposition: attachment;
	filename="sal_call.patch"

ZGlmZiAtdXJOIGxpbnV4LTIuNi4yMy1yYzgvYXJjaC9pYTY0L2tlcm5lbC9zYWwuYyBsaW51eC9h
cmNoL2lhNjQva2VybmVsL3NhbC5jCi0tLSBsaW51eC0yLjYuMjMtcmM4L2FyY2gvaWE2NC9rZXJu
ZWwvc2FsLmMJMjAwNy0wOS0yNSAwODozMzoxMC4wMDAwMDAwMDAgKzA4MDAKKysrIGxpbnV4L2Fy
Y2gvaWE2NC9rZXJuZWwvc2FsLmMJMjAwNy0wOS0yOSAxNDoxMzoxMC4wMDAwMDAwMDAgKzA4MDAK
QEAgLTI0Myw3ICsyNDMsNyBAQAogCXdoaWxlICghaWE2NF9nZXRfaXJyKElBNjRfVElNRVJfVkVD
VE9SKSkKIAkJY3B1X3JlbGF4KCk7CiAKLQlTQUxfQ0FMTChpc3J2LCBTQUxfQ0FDSEVfRkxVU0gs
IGNhY2hlX3R5cGUsIDAsIDAsIDAsIDAsIDAsIDApOworCVNBTF9DQUxMX05PTE9DSyhpc3J2LCBT
QUxfQ0FDSEVfRkxVU0gsIGNhY2hlX3R5cGUsIDAsIDAsIDAsIDAsIDAsIDApOwogCiAJaWYgKGlz
cnYuc3RhdHVzKQogCQlwcmludGsoS0VSTl9FUlIgIlNBTF9DQUxfRkxVU0ggZmFpbGVkIHdpdGgg
JWxkXG4iLCBpc3J2LnN0YXR1cyk7CmRpZmYgLXVyTiBsaW51eC0yLjYuMjMtcmM4L2luY2x1ZGUv
YXNtLWlhNjQvc2FsLmggbGludXgvaW5jbHVkZS9hc20taWE2NC9zYWwuaAotLS0gbGludXgtMi42
LjIzLXJjOC9pbmNsdWRlL2FzbS1pYTY0L3NhbC5oCTIwMDctMDktMjUgMDg6MzM6MTAuMDAwMDAw
MDAwICswODAwCisrKyBsaW51eC9pbmNsdWRlL2FzbS1pYTY0L3NhbC5oCTIwMDctMDktMjkgMTQ6
MTY6NDYuMDAwMDAwMDAwICswODAwCkBAIC02NTIsNyArNjUyLDcgQEAKIHsKIAlzdHJ1Y3QgaWE2
NF9zYWxfcmV0dmFsIGlzcnY7CiAKLQlTQUxfQ0FMTChpc3J2LCBTQUxfRlJFUV9CQVNFLCB3aGlj
aCwgMCwgMCwgMCwgMCwgMCwgMCk7CisJU0FMX0NBTExfTk9MT0NLKGlzcnYsIFNBTF9GUkVRX0JB
U0UsIHdoaWNoLCAwLCAwLCAwLCAwLCAwLCAwKTsKIAkqdGlja3NfcGVyX3NlY29uZCA9IGlzcnYu
djA7CiAJKmRyaWZ0X2luZm8gPSBpc3J2LnYxOwogCXJldHVybiBpc3J2LnN0YXR1czsKQEAgLTY2
Niw3ICs2NjYsNyBAQAogaWE2NF9zYWxfY2FjaGVfaW5pdCAodm9pZCkKIHsKIAlzdHJ1Y3QgaWE2
NF9zYWxfcmV0dmFsIGlzcnY7Ci0JU0FMX0NBTEwoaXNydiwgU0FMX0NBQ0hFX0lOSVQsIDAsIDAs
IDAsIDAsIDAsIDAsIDApOworCVNBTF9DQUxMX05PTE9DSyhpc3J2LCBTQUxfQ0FDSEVfSU5JVCwg
MCwgMCwgMCwgMCwgMCwgMCwgMCk7CiAJcmV0dXJuIGlzcnYuc3RhdHVzOwogfQogCkBAIC03NDgs
NyArNzQ4LDggQEAKIGlhNjRfc2FsX3BjaV9jb25maWdfcmVhZCAodTY0IHBjaV9jb25maWdfYWRk
ciwgaW50IHR5cGUsIHU2NCBzaXplLCB1NjQgKnZhbHVlKQogewogCXN0cnVjdCBpYTY0X3NhbF9y
ZXR2YWwgaXNydjsKLQlTQUxfQ0FMTChpc3J2LCBTQUxfUENJX0NPTkZJR19SRUFELCBwY2lfY29u
ZmlnX2FkZHIsIHNpemUsIHR5cGUsIDAsIDAsIDAsIDApOworCVNBTF9DQUxMX1JFRU5UUkFOVChp
c3J2LCBTQUxfUENJX0NPTkZJR19SRUFELCBwY2lfY29uZmlnX2FkZHIsIHNpemUsCisJICAgICAg
ICAgdHlwZSwgMCwgMCwgMCwgMCk7CiAJaWYgKHZhbHVlKQogCQkqdmFsdWUgPSBpc3J2LnYwOwog
CXJldHVybiBpc3J2LnN0YXR1czsKQEAgLTc1OSw4ICs3NjAsOCBAQAogaWE2NF9zYWxfcGNpX2Nv
bmZpZ193cml0ZSAodTY0IHBjaV9jb25maWdfYWRkciwgaW50IHR5cGUsIHU2NCBzaXplLCB1NjQg
dmFsdWUpCiB7CiAJc3RydWN0IGlhNjRfc2FsX3JldHZhbCBpc3J2OwotCVNBTF9DQUxMKGlzcnYs
IFNBTF9QQ0lfQ09ORklHX1dSSVRFLCBwY2lfY29uZmlnX2FkZHIsIHNpemUsIHZhbHVlLAotCSAg
ICAgICAgIHR5cGUsIDAsIDAsIDApOworCVNBTF9DQUxMX1JFRU5UUkFOVChpc3J2LCBTQUxfUENJ
X0NPTkZJR19XUklURSwgcGNpX2NvbmZpZ19hZGRyLCBzaXplLAorCSAgICAgICAgIHZhbHVlLCB0
eXBlLCAwLCAwLCAwKTsKIAlyZXR1cm4gaXNydi5zdGF0dXM7CiB9CiAKQEAgLTgxNSw3ICs4MTYs
NyBAQAogaWE2NF9zYWxfcGh5c2ljYWxfaWRfaW5mbyh1MTYgKnNwbGlkKQogewogCXN0cnVjdCBp
YTY0X3NhbF9yZXR2YWwgaXNydjsKLQlTQUxfQ0FMTChpc3J2LCBTQUxfUEhZU0lDQUxfSURfSU5G
TywgMCwgMCwgMCwgMCwgMCwgMCwgMCk7CisJU0FMX0NBTExfTk9MT0NLKGlzcnYsIFNBTF9QSFlT
SUNBTF9JRF9JTkZPLCAwLCAwLCAwLCAwLCAwLCAwLCAwKTsKIAlpZiAoc3BsaWQpCiAJCSpzcGxp
ZCA9IGlzcnYudjA7CiAJcmV0dXJuIGlzcnYuc3RhdHVzOwo=

------_=_NextPart_001_01C80BE4.436D5F8D--
