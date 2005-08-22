From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 22 Aug 2005 20:18:30 +0000
Subject: Re: [PATCH] Remove rwsem limitation of 32k waiters
Message-Id: <20050822201830.GB3150@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 22, 2005 at 12:38:45PM -0700, Christoph Lameter wrote:
> On Mon, 22 Aug 2005, Matthew Wilcox wrote:
> > Why not just change the BIAS value to 0x0010000?  As long as you don't
> > have more than 1024 processors trying to simultaneously acquire the same
> > write lock (and if you do, you have other problems ...), this won't fail
> > and gives you 2^19 waiters.
> 
> The same approach was already chosen by s390 and alpha.
> 
> Changing the bias value reduces the maximum number of waiting 
> processes as you noted. Note "processes" not processors. One processor can 
> have multiple processes waiting on semaphores. These are not spinlocks.

No, but you didn't look at the implementation in lib/rwsem.c.

static inline struct rw_semaphore *
rwsem_down_failed_common(struct rw_semaphore *sem,
                        struct rwsem_waiter *waiter, signed long adjustment)
...
        /* we're now waiting on the lock, but no longer actively read-locking */
        count = rwsem_atomic_update(adjustment, sem);

struct rw_semaphore fastcall __sched *
rwsem_down_write_failed(struct rw_semaphore *sem)
...
        rwsem_down_failed_common(sem, &waiter, -RWSEM_ACTIVE_BIAS);

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
