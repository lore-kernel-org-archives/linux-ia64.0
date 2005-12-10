From: Keith Owens <kaos@sgi.com>
Date: Sat, 10 Dec 2005 03:24:28 +0000
Subject: [patch 2.6.15-rc5] Define an ia64 version of __raw_read_trylock
Message-Id: <17916.1134185068@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

IA64 is using the generic version of __raw_read_trylock, which always
waits for the lock to be free instead of returning when the lock is in
use.  Define an ia64 version of __raw_read_trylock which behaves
correctly, and drop the generic one.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/include/asm-ia64/spinlock.h
=================================--- linux.orig/include/asm-ia64/spinlock.h	2005-12-09 14:44:56.883252331 +1100
+++ linux/include/asm-ia64/spinlock.h	2005-12-10 14:20:44.459423430 +1100
@@ -201,6 +201,16 @@ static inline void __raw_write_unlock(ra
 
 #endif /* !ASM_SUPPORTED */
 
-#define __raw_read_trylock(lock) generic__raw_read_trylock(lock)
+static inline int __raw_read_trylock(raw_rwlock_t *x)
+{
+	union {
+		raw_rwlock_t lock;
+		__u32 word;
+	} old, new;
+	old.lock = new.lock = *x;
+	old.lock.write_lock = new.lock.write_lock = 0;
+	++new.lock.read_counter;
+	return (u32)ia64_cmpxchg4_acq((__u32 *)(x), new.word, old.word) = old.word;
+}
 
 #endif /*  _ASM_IA64_SPINLOCK_H */

