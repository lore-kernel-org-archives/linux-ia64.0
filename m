From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 31 Mar 2016 08:33:36 +0000
Subject: Re: [PATCH 03/11] locking, rwsem: introduce basis for down_write_killable
Message-Id: <20160331083336.GA27831@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1456750705-7141-1-git-send-email-mhocko@kernel.org>
 <1456750705-7141-4-git-send-email-mhocko@kernel.org>
 <20160330132549.GU3408@twins.programming.kicks-ass.net>
In-Reply-To: <20160330132549.GU3408@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org

On Wed 30-03-16 15:25:49, Peter Zijlstra wrote:
[...]
> Why is the signal_pending_state() test _after_ the call to schedule()
> and before the 'trylock'.

No special reason. I guess I was just too focused on the wake_by_signal
path and didn't realize the trylock as well.

> __mutex_lock_common() has it before the call to schedule and after the
> 'trylock'.
> 
> The difference is that rwsem will now respond to the KILL and return
> -EINTR even if the lock is available, whereas mutex will acquire it and
> ignore the signal (for a little while longer).
> 
> Neither is wrong per se, but I feel all the locking primitives should
> behave in a consistent manner in this regard.

Agreed! What about the following on top? I will repost the full patch
if it looks OK.

Thanks!
---
diff --git a/kernel/locking/rwsem-spinlock.c b/kernel/locking/rwsem-spinlock.c
index d1d04ca10d0e..fb2db7b408f0 100644
--- a/kernel/locking/rwsem-spinlock.c
+++ b/kernel/locking/rwsem-spinlock.c
@@ -216,14 +216,13 @@ int __sched __down_write_state(struct rw_semaphore *sem, int state)
 		 */
 		if (sem->count = 0)
 			break;
-		set_task_state(tsk, state);
-		raw_spin_unlock_irqrestore(&sem->wait_lock, flags);
-		schedule();
 		if (signal_pending_state(state, current)) {
 			ret = -EINTR;
-			raw_spin_lock_irqsave(&sem->wait_lock, flags);
 			goto out;
 		}
+		set_task_state(tsk, state);
+		raw_spin_unlock_irqrestore(&sem->wait_lock, flags);
+		schedule();
 		raw_spin_lock_irqsave(&sem->wait_lock, flags);
 	}
 	/* got the lock */
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 5cec34f1ad6f..781b2628e41b 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -487,19 +487,19 @@ __rwsem_down_write_failed_state(struct rw_semaphore *sem, int state)
 
 		/* Block until there are no active lockers. */
 		do {
-			schedule();
 			if (signal_pending_state(state, current)) {
 				raw_spin_lock_irq(&sem->wait_lock);
 				ret = ERR_PTR(-EINTR);
 				goto out;
 			}
+			schedule();
 			set_current_state(state);
 		} while ((count = sem->count) & RWSEM_ACTIVE_MASK);
 
 		raw_spin_lock_irq(&sem->wait_lock);
 	}
-	__set_current_state(TASK_RUNNING);
 out:
+	__set_current_state(TASK_RUNNING);
 	list_del(&waiter.list);
 	raw_spin_unlock_irq(&sem->wait_lock);
 

-- 
Michal Hocko
SUSE Labs
