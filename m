From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 21 Jul 2003 23:55:59 +0000
Subject: [PATCH] don't use ld.bias
Message-Id: <marc-linux-ia64-105883179830025@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patch to fix spin_lock to not use ld.bias since it causes a bunch of bus
activity that hurts scalability when a lock is contended.

Thanks,
Jesse

=== include/asm-ia64/spinlock.h 1.13 vs edited ==--- 1.13/include/asm-ia64/spinlock.h	Fri May 30 19:59:40 2003
+++ edited/include/asm-ia64/spinlock.h	Mon Jul 21 16:54:15 2003
@@ -93,13 +93,16 @@
  * Streamlined test_and_set_bit(0, (x)).  We use test-and-test-and-set
  * rather than a simple xchg to avoid writing the cache-line when
  * there is contention.
+ *
+ * Don't use ld.bias since it generates unnecessary bus activity on
+ * multiprocessor systems when the lock is contended.
  */
 #define _raw_spin_lock(x) __asm__ __volatile__ (		\
 	"mov ar.ccv = r0\n"					\
 	"mov r29 = 1\n"						\
 	";;\n"							\
 	"1:\n"							\
-	"ld4.bias r2 = [%0]\n"					\
+	"ld4 r2 = [%0]\n"					\
 	";;\n"							\
 	"cmp4.eq p0,p7 = r0,r2\n"				\
 	"(p7) br.cond.spnt.few 1b \n"				\
