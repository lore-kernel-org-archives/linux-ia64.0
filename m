From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 20 Jan 2005 16:12:59 +0000
Subject: [patch 3/3] spinlock fix #3: type-checking spinlock primitives, x86
Message-Id: <20050120161259.GB13812@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <16878.9678.73202.771962@wombat.chubb.wattle.id.au> <20050119092013.GA2045@elte.hu> <16878.54402.344079.528038@cargo.ozlabs.ibm.com> <20050120023445.GA3475@taniwha.stupidest.org> <20050119190104.71f0a76f.akpm@osdl.org> <20050120031854.GA8538@taniwha.stupidest.org> <16879.29449.734172.893834@wombat.chubb.wattle.id.au> <Pine.LNX.4.58.0501200747230.8178@ppc970.osdl.org> <20050120160839.GA13067@elte.hu> <20050120161116.GA13812@elte.hu>
In-Reply-To: <20050120161116.GA13812@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, Chris Wedgwood <cw@f00f.org>, Andrew Morton <akpm@osdl.org>, paulus@samba.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, dsw@gelato.unsw.edu.au, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, hch@infradead.org, wli@holomorphy.com, jbarnes@sgi.com


[this patch didnt change due to can_lock but i've resent it so that the
patch stream is complete.]

--
this patch would have caught the bug in -BK-curr (that patch #1 fixes),
via a compiler warning. Test-built/booted on x86.

	Ingo

Signed-off-by: Ingo Molnar <mingo@elte.hu>

--- linux/include/asm-i386/spinlock.h.orig
+++ linux/include/asm-i386/spinlock.h
@@ -36,7 +36,10 @@ typedef struct {
 
 #define SPIN_LOCK_UNLOCKED (spinlock_t) { 1 SPINLOCK_MAGIC_INIT }
 
-#define spin_lock_init(x)	do { *(x) = SPIN_LOCK_UNLOCKED; } while(0)
+static inline void spin_lock_init(spinlock_t *lock)
+{
+	*lock = SPIN_LOCK_UNLOCKED;
+}
 
 /*
  * Simple spin lock operations.  There are two variants, one clears IRQ's
@@ -45,8 +48,17 @@ typedef struct {
  * We make no fairness assumptions. They have a cost.
  */
 
-#define spin_is_locked(x)	(*(volatile signed char *)(&(x)->lock) <= 0)
-#define spin_unlock_wait(x)	do { barrier(); } while(spin_is_locked(x))
+static inline int spin_is_locked(spinlock_t *lock)
+{
+	return *(volatile signed char *)(&lock->lock) <= 0;
+}
+
+static inline void spin_unlock_wait(spinlock_t *lock)
+{
+	do {
+		barrier();
+	} while (spin_is_locked(lock));
+}
 
 #define spin_lock_string \
 	"\n1:\t" \
