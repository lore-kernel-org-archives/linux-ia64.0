From: jerome.marchand@ext.bull.net
Date: Thu, 11 Dec 2003 09:58:22 +0000
Subject: Re: ia64 atomic_dec_and_lock() patch
MIME-Version: 1
Content-Type: multipart/mixed; boundary="-2118675967-111017162-1071136702=:100180"
Message-Id: <marc-linux-ia64-107113674613234@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107107082810707@msgid-missing>
In-Reply-To: <marc-linux-ia64-107107082810707@msgid-missing>
To: linux-ia64@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---2118675967-111017162-1071136702=:100180
Content-Type: TEXT/PLAIN; charset=US-ASCII


On Wed, 10 Dec 2003, David Mosberger wrote:

> Could you try replacing the inline-asm with cmpxchg() function?  That
> way, you won't break compilation with Intel's compiler.

OK, here's the new patch.
I also join the right patch for lockmeter.



diff -urN linux-2.6.0-test11.orig/arch/ia64/Kconfig
linux-2.6.0-test11/arch/ia64/Kconfig
--- linux-2.6.0-test11.orig/arch/ia64/Kconfig   2003-12-09
11:26:58.000000000 +0100
+++ linux-2.6.0-test11/arch/ia64/Kconfig        2003-12-09
11:34:09.000000000 +0100
@@ -375,6 +375,11 @@
        depends on IA32_SUPPORT
        default y

+config HAVE_DEC_LOCK
+       bool
+       depends on (SMP || PREEMPT)
+       default y
+
 config PERFMON
        bool "Performance monitor support"
        help
diff -urN linux-2.6.0-test11.orig/arch/ia64/lib/Makefile
linux-2.6.0-test11/arch/ia64/lib/Makefile
--- linux-2.6.0-test11.orig/arch/ia64/lib/Makefile      2003-12-09
11:26:58.000000000 +0100
+++ linux-2.6.0-test11/arch/ia64/lib/Makefile   2003-12-09
11:32:05.000000000 +0100
@@ -13,6 +13,7 @@
 lib-$(CONFIG_MCKINLEY) += copy_page_mck.o memcpy_mck.o
 lib-$(CONFIG_PERFMON)  += carta_random.o
 lib-$(CONFIG_MD_RAID5) += xor.o
+lib-$(CONFIG_HAVE_DEC_LOCK) += dec_and_lock.o

 AFLAGS___divdi3.o      =
 AFLAGS___udivdi3.o     = -DUNSIGNED
diff -urN linux-2.6.0-test11.orig/arch/ia64/lib/dec_and_lock.c
linux-2.6.0-test11/arch/ia64/lib/dec_and_lock.c
--- linux-2.6.0-test11.orig/arch/ia64/lib/dec_and_lock.c        1970-01-01
01:00:00.000000000 +0100
+++ linux-2.6.0-test11/arch/ia64/lib/dec_and_lock.c     2003-12-11
10:42:49.000000000 +0100
@@ -0,0 +1,38 @@
+/*
+ * Copyright (C) 2003 Jerome Marchand, Bull S.A.
+ *
+ * This file is released under the GPLv2, or at
+ * your option any later version.
+ *
+ * ia64 version of "atomic_dec_and_lock()" using
+ * the atomic "cmpxchg" instruction.
+ * This code is an adaptation of the x86 version
+ * of "atomic_dec_and_lock()".
+ */
+
+#include <linux/spinlock.h>
+#include <asm/atomic.h>
+
+int atomic_dec_and_lock(atomic_t *atomic, spinlock_t *lock)
+{
+       int counter;
+       int newcount;
+
+repeat:
+       counter = atomic_read(atomic);
+       newcount = counter-1;
+
+       if (!newcount)
+               goto slow_path;
+
+       if(cmpxchg(&atomic->counter, counter, newcount) != counter)
+               goto repeat;
+       return 0;
+
+slow_path:
+       spin_lock(lock);
+       if (atomic_dec_and_test(atomic))
+               return 1;
+       spin_unlock(lock);
+       return 0;
+}

---2118675967-111017162-1071136702=:100180
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="lockmeter-ia64-atomic_dec_and_lock.patch"
Content-ID: <Pine.A41.4.53.0312111058220.100180@alpha12.frec.bull.fr>
Content-Description: lockmeter ia64 patch
Content-Disposition: attachment; filename="lockmeter-ia64-atomic_dec_and_lock.patch"
Content-Transfer-Encoding: BASE64

ZGlmZiAtdXJOIGxpbnV4LTIuNi4wLXRlc3QxMS5sb2NrbWV0ZXIub3JpZy9h
cmNoL2lhNjQvbGliL2RlY19hbmRfbG9jay5jIGxpbnV4LTIuNi4wLXRlc3Qx
MS5sb2NrbWV0ZXIvYXJjaC9pYTY0L2xpYi9kZWNfYW5kX2xvY2suYw0KLS0t
IGxpbnV4LTIuNi4wLXRlc3QxMS5sb2NrbWV0ZXIub3JpZy9hcmNoL2lhNjQv
bGliL2RlY19hbmRfbG9jay5jCTIwMDMtMTItMTEgMTA6NDQ6MTAuMDAwMDAw
MDAwICswMTAwDQorKysgbGludXgtMi42LjAtdGVzdDExLmxvY2ttZXRlci9h
cmNoL2lhNjQvbGliL2RlY19hbmRfbG9jay5jCTIwMDMtMTItMTEgMTA6NDM6
NDcuMDAwMDAwMDAwICswMTAwDQpAQCAtMTMsNiArMTMsNyBAQA0KICNpbmNs
dWRlIDxsaW51eC9zcGlubG9jay5oPg0KICNpbmNsdWRlIDxhc20vYXRvbWlj
Lmg+DQogDQorI2lmbmRlZiBBVE9NSUNfREVDX0FORF9MT0NLDQogaW50IGF0
b21pY19kZWNfYW5kX2xvY2soYXRvbWljX3QgKmF0b21pYywgc3BpbmxvY2tf
dCAqbG9jaykNCiB7DQogCWludCBjb3VudGVyOw0KQEAgLTM2LDMgKzM3LDQg
QEANCiAJc3Bpbl91bmxvY2sobG9jayk7DQogCXJldHVybiAwOw0KIH0NCisj
ZW5kaWYNCmRpZmYgLXVyTiBsaW51eC0yLjYuMC10ZXN0MTEubG9ja21ldGVy
Lm9yaWcvaW5jbHVkZS9hc20taWE2NC9zcGlubG9jay5oIGxpbnV4LTIuNi4w
LXRlc3QxMS5sb2NrbWV0ZXIvaW5jbHVkZS9hc20taWE2NC9zcGlubG9jay5o
DQotLS0gbGludXgtMi42LjAtdGVzdDExLmxvY2ttZXRlci5vcmlnL2luY2x1
ZGUvYXNtLWlhNjQvc3BpbmxvY2suaAkyMDAzLTEyLTExIDEwOjA5OjQyLjAw
MDAwMDAwMCArMDEwMA0KKysrIGxpbnV4LTIuNi4wLXRlc3QxMS5sb2NrbWV0
ZXIvaW5jbHVkZS9hc20taWE2NC9zcGlubG9jay5oCTIwMDMtMTItMTEgMTA6
MTU6NDUuMDAwMDAwMDAwICswMTAwDQpAQCAtMjQ3LDEzICsyNDcsMjcgQEAN
CiBleHRlcm4gdm9pZCBfbWV0ZXJlZF9zcGluX3VubG9jayhzcGlubG9ja190
ICpsb2NrKTsNCiANCiAvKg0KLSAqICBVc2UgYSBsZXNzIGVmZmljaWVudCwg
YW5kIGlubGluZSwgYXRvbWljX2RlY19hbmRfbG9jaygpIGlmIGxvY2ttZXRl
cmluZw0KLSAqICBzbyB3ZSBjYW4gc2VlIHRoZSBjYWxsZXJQQyBvZiB3aG8g
aXMgYWN0dWFsbHkgZG9pbmcgdGhlIHNwaW5fbG9jaygpLg0KLSAqICBPdGhl
cndpc2UsIGFsbCB3ZSBzZWUgaXMgdGhlIGdlbmVyaWMgcm9sbHVwIG9mIGFs
bCBsb2NrcyBkb25lIGJ5DQotICogIGF0b21pY19kZWNfYW5kX2xvY2soKS4N
CisgKiAgTWF0Y2hlcyB3aGF0IGlzIGluIGFyY2gvaWE2NC9saWIvZGVjX2Fu
ZF9sb2NrLmMsIGV4Y2VwdCB0aGlzIG9uZSBpcw0KKyAqICAic3RhdGljIGlu
bGluZSIgc28gdGhhdCB0aGUgc3Bpbl9sb2NrKCksIGlmIGFjdHVhbGx5IGlu
dm9rZWQsIGlzIGNoYXJnZWQNCisgKiAgYWdhaW5zdCB0aGUgcmVhbCBjYWxs
ZXIsIG5vdCBhZ2FpbnN0IHRoZSBjYXRjaC1hbGwgYXRvbWljX2RlY19hbmRf
bG9jaw0KICAqLw0KIHN0YXRpYyBpbmxpbmUgaW50IGF0b21pY19kZWNfYW5k
X2xvY2soYXRvbWljX3QgKmF0b21pYywgc3BpbmxvY2tfdCAqbG9jaykNCiB7
DQorCWludCBjb3VudGVyOw0KKwlpbnQgbmV3Y291bnQ7DQorDQorcmVwZWF0
Og0KKwljb3VudGVyID0gYXRvbWljX3JlYWQoYXRvbWljKTsNCisJbmV3Y291
bnQgPSBjb3VudGVyLTE7DQorDQorCWlmICghbmV3Y291bnQpDQorCQlnb3Rv
IHNsb3dfcGF0aDsNCisNCisJaWYoY21weGNoZygmYXRvbWljLT5jb3VudGVy
LCBjb3VudGVyLCBuZXdjb3VudCkgIT0gY291bnRlcikNCisJCWdvdG8gcmVw
ZWF0Ow0KKwlyZXR1cm4gMDsNCisNCitzbG93X3BhdGg6DQogCV9tZXRlcmVk
X3NwaW5fbG9jayhsb2NrKTsNCiAJaWYgKGF0b21pY19kZWNfYW5kX3Rlc3Qo
YXRvbWljKSkNCiAJCXJldHVybiAxOw0K

---2118675967-111017162-1071136702=:100180--
