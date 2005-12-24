From: Jack Steiner <steiner@sgi.com>
Date: Sat, 24 Dec 2005 13:45:23 +0000
Subject: Re: [PATCH] - Fix memory ordering problem in wake_futex()
Message-Id: <20051224134523.GA7187@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051223163816.GA30906@sgi.com>
In-Reply-To: <20051223163816.GA30906@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

This patch is identical to the first patch except I used smp_wmb() instead
of wmb(). Ordering doen't matter on non-SMP kernels.


Here is a fix for a ugly race condition that occurs in wake_futex() on IA64.

On IA64, locks are released using a "st.rel" instruction. This ensures that
preceding "stores" are visible before the lock is released but does NOT prevent
a "store" that follows the "st.rel" from becoming visible before the "st.rel".
The result is that the task that owns the futex_q continues prematurely. 

The failure I saw is the task that owned the futex_q resumed prematurely and
was context-switch off of the cpu. The task's switch_stack occupied the same
space of the futex_q. The store to q->lock_ptr overwrote the ar.bspstore in the
switch_stack. When the task resumed, it ran with a corrupted ar.bspstore.
Things went downhill from there.

Without the fix, the application fails roughly every 10 minutes. With
the fix, it ran 16 hours without a failure.

----
Fix a memory ordering problem that occurs on IA64. The "store" to q->lock_ptr
in wake_futex() can become visible before wake_up_all() clears the lock in the
futex_q. 


	Signed-off-by: Jack Steiner <steiner@sgi.com>





Index: linux/kernel/futex.c
=================================--- linux.orig/kernel/futex.c	2005-12-22 15:05:43.821889257 -0600
+++ linux/kernel/futex.c	2005-12-22 15:30:21.617973325 -0600
@@ -287,7 +287,13 @@ static void wake_futex(struct futex_q *q
 	/*
 	 * The waiting task can free the futex_q as soon as this is written,
 	 * without taking any locks.  This must come last.
+	 *
+	 * A memory barrier is required here to prevent the following store
+	 * to lock_ptr from getting ahead of the wakeup. Clearing the lock
+	 * at the end of wake_up_all() does not prevent this store from
+	 * moving.
 	 */
+	smp_wmb();
 	q->lock_ptr = NULL;
 }
 
