From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 19 Jan 2005 00:14:30 +0000
Subject: Re: Horrible regression with -CURRENT from "Don't busy-lock-loop in preemptable spinlocks" patch
Message-Id: <16877.42598.336096.561224@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050117055044.GA3514@taniwha.stupidest.org>
	<20050116230922.7274f9a2.akpm@osdl.org>
	<20050117143301.GA10341@elte.hu>
	<20050118014752.GA14709@cse.unsw.EDU.AU>
In-Reply-To: <20050118014752.GA14709@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Darren Williams <dsw@gelato.unsw.edu.au>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@osdl.org>, Chris Wedgwood <cw@f00f.org>, torvalds@osdl.org, benh@kernel.crashing.org, linux-kernel@vger.kernel.org, Ia64 Linux <linux-ia64@vger.kernel.org>



Here's a patch that adds the missing read_is_locked() and
write_is_locked() macros for IA64.  When combined with Ingo's patch, I
can boot an SMP kernel with CONFIG_PREEMPT on.

However, I feel these macros are misnamed: read_is_locked() returns true if
the lock is held for writing; write_is_locked() returns true if the
lock is held for reading or writing.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

Index: linux-2.6-bklock/include/asm-ia64/spinlock.h
=================================--- linux-2.6-bklock.orig/include/asm-ia64/spinlock.h	2005-01-18 13:46:08.138077857 +1100
+++ linux-2.6-bklock/include/asm-ia64/spinlock.h	2005-01-19 08:58:59.303821753 +1100
@@ -126,8 +126,20 @@
 #define RW_LOCK_UNLOCKED (rwlock_t) { 0, 0 }
 
 #define rwlock_init(x)		do { *(x) = RW_LOCK_UNLOCKED; } while(0)
+
 #define rwlock_is_locked(x)	(*(volatile int *) (x) != 0)
 
+/* read_is_locked --  - would read_trylock() fail?
+ * @lock: the rwlock in question.
+ */
+#define read_is_locked(x)       (*(volatile int *) (x) < 0)
+
+/**
+ * write_is_locked - would write_trylock() fail?
+ * @lock: the rwlock in question.
+ */
+#define write_is_locked(x)	(*(volatile int *) (x) != 0)
+
 #define _raw_read_lock(rw)								\
 do {											\
 	rwlock_t *__read_lock_ptr = (rw);						\

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
