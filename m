From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 15 Jun 2016 17:18:00 +0000
Subject: Re: [RFC PATCH-tip v2 1/6] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <20160615171800.GP30921@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com>
 <1465944489-43440-2-git-send-email-Waiman.Long@hpe.com>
 <20160615080446.GA28443@insomnia>
In-Reply-To: <20160615080446.GA28443@insomnia>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Boqun Feng <boqun.feng@gmail.com>
Cc: Waiman Long <Waiman.Long@hpe.com>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On Wed, Jun 15, 2016 at 04:04:46PM +0800, Boqun Feng wrote:
> On Tue, Jun 14, 2016 at 06:48:04PM -0400, Waiman Long wrote:

> > @@ -198,7 +198,7 @@ void osq_unlock(struct optimistic_spin_queue *lock)
> >  	 * Second most likely case.
> >  	 */
> >  	node = this_cpu_ptr(&osq_node);
> > -	next = xchg(&node->next, NULL);
> > +	next = xchg_release(&node->next, NULL);
> >  	if (next) {
> >  		WRITE_ONCE(next->locked, 1);
> 
> So we still use WRITE_ONCE() rather than smp_store_release() here?
> 
> Though, IIUC, This is fine for all the archs but ARM64, because there
> will always be a xchg_release()/xchg() before the WRITE_ONCE(), which
> carries a necessary barrier to upgrade WRITE_ONCE() to a RELEASE.

Not sure. On PPC for example, you'll use lwsync() but will that not
attach to the store to &node->next instead?

Still leaving that store and the WRITE_ONCE() unordered.

Also I don't see the control dependency between xchg-load and WRITE_ONCE
helping anything to order the two stores.


So yeah, subtle if not broken, definitely needs more explanation.
