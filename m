From: Christoph Lameter <clameter@engr.sgi.com>
Date: Mon, 22 Aug 2005 20:26:17 +0000
Subject: Re: [PATCH] Remove rwsem limitation of 32k waiters
Message-Id: <Pine.LNX.4.62.0508221320350.8094@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 22 Aug 2005, Matthew Wilcox wrote:

> > Changing the bias value reduces the maximum number of waiting 
> > processes as you noted. Note "processes" not processors. One processor can 
> > have multiple processes waiting on semaphores. These are not spinlocks.
> 
> No, but you didn't look at the implementation in lib/rwsem.c.
> 
> static inline struct rw_semaphore *
> rwsem_down_failed_common(struct rw_semaphore *sem,
>                         struct rwsem_waiter *waiter, signed long adjustment)
> ...
>         /* we're now waiting on the lock, but no longer actively read-locking */
>         count = rwsem_atomic_update(adjustment, sem);

The adjustment is RWSEM_WAITING_BIAS - RWSEM_ACTIVE bias. This eliminates
the RWSEM_ACTIVE_BIAS but adds RWSEM_WAITING_BIAS for each waiter.

