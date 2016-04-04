From: Michal Hocko <mhocko@kernel.org>
Date: Mon, 04 Apr 2016 09:17:00 +0000
Subject: Re: [PATCH 03/11] locking, rwsem: introduce basis for down_write_killable
Message-Id: <20160404091659.GA13463@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1459508695-14915-1-git-send-email-mhocko@kernel.org>
 <1459508695-14915-4-git-send-email-mhocko@kernel.org>
 <20160402044125.GC5329@linux-uzut.site>
In-Reply-To: <20160402044125.GC5329@linux-uzut.site>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org

On Fri 01-04-16 21:41:25, Davidlohr Bueso wrote:
> On Fri, 01 Apr 2016, Michal Hocko wrote:
> 
> >From: Michal Hocko <mhocko@suse.com>
> >
> >Introduce a generic implementation necessary for down_write_killable.
> >This is a trivial extension of the already existing down_write call
> >which can be interrupted by SIGKILL.  This patch doesn't provide
> >down_write_killable yet because arches have to provide the necessary
> >pieces before.
> >
> >rwsem_down_write_failed which is a generic slow path for the
> >write lock is extended to allow a task state and renamed to
> >__rwsem_down_write_failed_state. The return value is either a valid
> >semaphore pointer or ERR_PTR(-EINTR).
> >
> >rwsem_down_write_failed_killable is exported as a new way to wait for
> >the lock and be killable.
> >
> >For rwsem-spinlock implementation the current __down_write it updated
> >in a similar way as __rwsem_down_write_failed_state except it doesn't
> >need new exports just visible __down_write_killable.
> >
> >Architectures which are not using the generic rwsem implementation are
> >supposed to provide their __down_write_killable implementation and
> >use rwsem_down_write_failed_killable for the slow path.
> 
> So in a nutshell, this is supposed to be the (writer) rwsem counterpart of
> mutex_lock_killable() and down_killable(), right?

Yes.

> [...]
> 
> >--- a/kernel/locking/rwsem-xadd.c
> >+++ b/kernel/locking/rwsem-xadd.c
> >@@ -433,12 +433,13 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
> >/*
> > * Wait until we successfully acquire the write lock
> > */
> >-__visible
> >-struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
> >+static inline struct rw_semaphore *
> >+__rwsem_down_write_failed_state(struct rw_semaphore *sem, int state)
> 
> fwiw I'm not a fan of the _state naming. While I understand why you chose it, I feel
> it does not really describe the purpose of the call itself. The state logic alone is
> really quite small and therefore should not govern the function name. Why not just apply
> kiss and label things _common, ie like mutexes do? This would also standardize names a
> bit.

I really do not care much about naming. So if _common sounds better I
can certainly rename.

> 
> >{
> >	long count;
> >	bool waiting = true; /* any queued threads before us */
> >	struct rwsem_waiter waiter;
> >+	struct rw_semaphore *ret = sem;
> >
> >	/* undo write bias from down_write operation, stop active locking */
> >	count = rwsem_atomic_update(-RWSEM_ACTIVE_WRITE_BIAS, sem);
> >@@ -478,7 +479,7 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
> >		count = rwsem_atomic_update(RWSEM_WAITING_BIAS, sem);
> >
> >	/* wait until we successfully acquire the lock */
> >-	set_current_state(TASK_UNINTERRUPTIBLE);
> >+	set_current_state(state);
> >	while (true) {
> >		if (rwsem_try_write_lock(count, sem))
> >			break;
> >@@ -486,21 +487,39 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
> >
> >		/* Block until there are no active lockers. */
> >		do {
> >+			if (signal_pending_state(state, current)) {
> 
>                           ^^ unlikely()?

The generated code is identical after I've added unlikely. I haven't
tried more gcc versions (mine is 5.3.1) but is this worth it?

> 
> >+				raw_spin_lock_irq(&sem->wait_lock);
> 
> If the lock is highly contended + a bad workload for spin-on-owner, this could take a while :)
> Of course, this is a side effect of the wait until no active lockers optimization which avoids
> the wait_lock in the first place, so fortunately it somewhat mitigates the situation.
> 
> >+				ret = ERR_PTR(-EINTR);
> >+				goto out;
> >+			}
> >			schedule();
> >-			set_current_state(TASK_UNINTERRUPTIBLE);
> >+			set_current_state(state);
> >		} while ((count = sem->count) & RWSEM_ACTIVE_MASK);
> >
> >		raw_spin_lock_irq(&sem->wait_lock);
> >	}
> >+out:
> >	__set_current_state(TASK_RUNNING);
> >-
> 
> You certainly don't want this iff exiting due to TASK_KILLABLE situation.

Not sure I got your point here.

-- 
Michal Hocko
SUSE Labs
