From: jerome.marchand@ext.bull.net
Date: Wed, 10 Dec 2003 15:37:22 +0000
Subject: ia64 atomic_dec_and_lock() patch
MIME-Version: 1
Content-Type: multipart/mixed; boundary="-2118675967-1190587504-1071070642=:245772"
Message-Id: <marc-linux-ia64-107107082810707@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---2118675967-1190587504-1071070642=:245772
Content-Type: TEXT/PLAIN; charset=US-ASCII

I have run a benchmark which load heavily the vfs on a 16 Itanium
computer. When using lockmeter, I have noticed that dcache_lock induce a
significant contention when called from dput. I observed a case in which
80% of CPUs time was used in spin-wait!
The ia64 kernel waste all this time because there is no ia64-specific
implementation of atomic_dec_and_lock() and the kernel use the generic
function instead.
I wrote the ia64 atomic_dec_and_lock function and since dcache_lock never
use more than 0.01% of CPUs time and I have encountered no problem. The
patch is here.
Does someone know why this function was not implemented before whereas it
is implemented for ia32, ppc, ppc64, sparc64 and alpha processors ?


Jerome Marchand

PS: I have also join the patch for lockmeter to this mail.


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
+++ linux-2.6.0-test11/arch/ia64/lib/dec_and_lock.c     2003-12-09
11:31:23.000000000 +0100
@@ -0,0 +1,42 @@
+/*
+ * ia64 version of "atomic_dec_and_lock()" using
+ * the atomic "cmpxchg" instruction.
+ * This code is an adaptation of the x86 version
+ * of "atomic_dec_and_lock()".
+ */
+
+#include <linux/spinlock.h>
+#include <asm/atomic.h>
+
+#ifndef ATOMIC_DEC_AND_LOCK
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
+       asm volatile("mov ar.ccv=%1;;\n\t"
+                    "cmpxchg4.acq %0=%2,%3,ar.ccv;;"
+                    :"=r" (newcount)
+                    :"r" (counter), "m" (atomic->counter), "r" (newcount)
+                    :"ar.ccv");
+
+       if (newcount != counter)
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
+#endif
---2118675967-1190587504-1071070642=:245772
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="lockmeter-ia64-atomic_dec_and_lock.patch"
Content-ID: <Pine.A41.4.53.0312101637220.245772@alpha12.frec.bull.fr>
Content-Description: lockmeter ia64 patch
Content-Disposition: attachment; filename="lockmeter-ia64-atomic_dec_and_lock.patch"
Content-Transfer-Encoding: BASE64

ZGlmZiAtdXJOIGxpbnV4LTIuNi4wLXRlc3QxMS5sb2NrbWV0ZXIub3JpZy9p
bmNsdWRlL2FzbS1pYTY0L3NwaW5sb2NrLmggbGludXgtMi42LjAtdGVzdDEx
LmxvY2ttZXRlci9pbmNsdWRlL2FzbS1pYTY0L3NwaW5sb2NrLmgNCi0tLSBs
aW51eC0yLjYuMC10ZXN0MTEubG9ja21ldGVyLm9yaWcvaW5jbHVkZS9hc20t
aWE2NC9zcGlubG9jay5oCTIwMDMtMTItMDkgMTM6MDM6MzYuMDAwMDAwMDAw
ICswMTAwDQorKysgbGludXgtMi42LjAtdGVzdDExLmxvY2ttZXRlci9pbmNs
dWRlL2FzbS1pYTY0L3NwaW5sb2NrLmgJMjAwMy0xMi0wOSAxMzowODoyNC4w
MDAwMDAwMDAgKzAxMDANCkBAIC0yNDcsMTMgKzI0NywzMyBAQA0KIGV4dGVy
biB2b2lkIF9tZXRlcmVkX3NwaW5fdW5sb2NrKHNwaW5sb2NrX3QgKmxvY2sp
Ow0KIA0KIC8qDQotICogIFVzZSBhIGxlc3MgZWZmaWNpZW50LCBhbmQgaW5s
aW5lLCBhdG9taWNfZGVjX2FuZF9sb2NrKCkgaWYgbG9ja21ldGVyaW5nDQot
ICogIHNvIHdlIGNhbiBzZWUgdGhlIGNhbGxlclBDIG9mIHdobyBpcyBhY3R1
YWxseSBkb2luZyB0aGUgc3Bpbl9sb2NrKCkuDQotICogIE90aGVyd2lzZSwg
YWxsIHdlIHNlZSBpcyB0aGUgZ2VuZXJpYyByb2xsdXAgb2YgYWxsIGxvY2tz
IGRvbmUgYnkNCi0gKiAgYXRvbWljX2RlY19hbmRfbG9jaygpLg0KKyAqICBN
YXRjaGVzIHdoYXQgaXMgaW4gYXJjaC9pYTY0L2xpYi9kZWNfYW5kX2xvY2su
YywgZXhjZXB0IHRoaXMgb25lIGlzDQorICogICJzdGF0aWMgaW5saW5lIiBz
byB0aGF0IHRoZSBzcGluX2xvY2soKSwgaWYgYWN0dWFsbHkgaW52b2tlZCwg
aXMgY2hhcmdlZA0KKyAqICBhZ2FpbnN0IHRoZSByZWFsIGNhbGxlciwgbm90
IGFnYWluc3QgdGhlIGNhdGNoLWFsbCBhdG9taWNfZGVjX2FuZF9sb2NrDQog
ICovDQogc3RhdGljIGlubGluZSBpbnQgYXRvbWljX2RlY19hbmRfbG9jayhh
dG9taWNfdCAqYXRvbWljLCBzcGlubG9ja190ICpsb2NrKQ0KIHsNCisJaW50
IGNvdW50ZXI7DQorCWludCBuZXdjb3VudDsNCisNCityZXBlYXQ6DQorCWNv
dW50ZXIgPSBhdG9taWNfcmVhZChhdG9taWMpOw0KKwluZXdjb3VudCA9IGNv
dW50ZXItMTsNCisNCisJaWYgKCFuZXdjb3VudCkNCisJCWdvdG8gc2xvd19w
YXRoOw0KKw0KKwlhc20gdm9sYXRpbGUoIm1vdiBhci5jY3Y9JTE7O1xuXHQi
DQorCQkgICAgICJjbXB4Y2hnNC5hY3EgJTA9JTIsJTMsYXIuY2N2OzsiDQor
CQkgICAgIDoiPXIiIChuZXdjb3VudCkNCisJCSAgICAgOiJyIiAoY291bnRl
ciksICJtIiAoYXRvbWljLT5jb3VudGVyKSwgInIiIChuZXdjb3VudCkNCisJ
CSAgICAgOiJhci5jY3YiKTsNCisNCisJaWYgKG5ld2NvdW50ICE9IGNvdW50
ZXIpDQorCQlnb3RvIHJlcGVhdDsNCisJcmV0dXJuIDA7DQorDQorc2xvd19w
YXRoOg0KIAlfbWV0ZXJlZF9zcGluX2xvY2sobG9jayk7DQogCWlmIChhdG9t
aWNfZGVjX2FuZF90ZXN0KGF0b21pYykpDQogCQlyZXR1cm4gMTsNCg==

---2118675967-1190587504-1071070642=:245772--
