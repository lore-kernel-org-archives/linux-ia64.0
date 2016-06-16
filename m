From: Will Deacon <will.deacon@arm.com>
Date: Thu, 16 Jun 2016 10:16:28 +0000
Subject: Re: [RFC PATCH-tip v2 1/6] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <20160616101627.GA5827@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com>
 <1465944489-43440-2-git-send-email-Waiman.Long@hpe.com>
 <20160615080446.GA28443@insomnia>
 <5761A5FF.5070703@hpe.com>
 <20160616021951.GA16918@insomnia>
In-Reply-To: <20160616021951.GA16918@insomnia>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Boqun Feng <boqun.feng@gmail.com>
Cc: Waiman Long <waiman.long@hpe.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

Hi guys,

On Thu, Jun 16, 2016 at 10:19:51AM +0800, Boqun Feng wrote:
> On Wed, Jun 15, 2016 at 03:01:19PM -0400, Waiman Long wrote:
> > On 06/15/2016 04:04 AM, Boqun Feng wrote:
> > > On Tue, Jun 14, 2016 at 06:48:04PM -0400, Waiman Long wrote:
> > > > @@ -198,7 +198,7 @@ void osq_unlock(struct optimistic_spin_queue *lock)
> > > >   	 * Second most likely case.
> > > >   	 */
> > > >   	node = this_cpu_ptr(&osq_node);
> > > > -	next = xchg(&node->next, NULL);
> > > > +	next = xchg_release(&node->next, NULL);
> > > >   	if (next) {
> > > >   		WRITE_ONCE(next->locked, 1);
> > > So we still use WRITE_ONCE() rather than smp_store_release() here?
> > > 
> > > Though, IIUC, This is fine for all the archs but ARM64, because there
> > > will always be a xchg_release()/xchg() before the WRITE_ONCE(), which
> > > carries a necessary barrier to upgrade WRITE_ONCE() to a RELEASE.
> > > 
> > > Not sure whether it's a problem on ARM64, but I think we certainly need
> > > to add some comments here, if we count on this trick.
> > > 
> > > Am I missing something or misunderstanding you here?
> > > 
> > The change on the unlock side is more for documentation purpose than is
> > actually needed. As you had said, the xchg() call has provided the necessary
> > memory barrier. Using the _release variant, however, may have some
> 
> But I'm afraid the barrier doesn't remain if we replace xchg() with
> xchg_release() on ARM64v8, IIUC, xchg_release() is just a ldxr+stlxr
> loop with no barrier on ARM64v8. This means the following code:
> 
> 	CPU 0					CPU 1 (next)
> 	============		=========
> 	WRITE_ONCE(x, 1);			r1 = smp_load_acquire(next->locked, 1);
> 	xchg_release(&node->next, NULL);	r2 = READ_ONCE(x);
> 	WRITE_ONCE(next->locked, 1);
> 
> could result in (r1 = 1 && r2 = 0) on ARM64v8, IIUC.

Yes, of course. Why is that unexpected? You could just as easily make
the xchg_release an smp_store_release and this would still be permitted,
that's the whole point of acquire/release -- they're semi-permeable
barriers that allow accesses outside of the critical section to leak in,
but not the other way around.

It's worth noting that you've omitted the control dependency from
xchg_release to the subsequent write in your litmus tests, but I don't
think that actually changes anything here.

Will
