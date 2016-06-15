From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 15 Jun 2016 17:12:50 +0000
Subject: Re: [RFC PATCH-tip v2 1/6] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <20160615171250.GO30921@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com>
 <1465944489-43440-2-git-send-email-Waiman.Long@hpe.com>
 <20160615165659.GC2094@linux-80c1.suse>
In-Reply-To: <20160615165659.GC2094@linux-80c1.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Waiman Long <Waiman.Long@hpe.com>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On Wed, Jun 15, 2016 at 09:56:59AM -0700, Davidlohr Bueso wrote:
> On Tue, 14 Jun 2016, Waiman Long wrote:

> >+++ b/kernel/locking/osq_lock.c
> >@@ -115,7 +115,7 @@ bool osq_lock(struct optimistic_spin_queue *lock)
> >	 * cmpxchg in an attempt to undo our queueing.
> >	 */
> >
> >-	while (!READ_ONCE(node->locked)) {
> >+	while (!smp_load_acquire(&node->locked)) {
> 
> Hmm this being a polling path, that barrier can get pretty expensive and
> last I checked it was unnecessary:

I think he'll go rely on it later on.

In any case, its fairly simple to cure, just add
smp_acquire__after_ctrl_dep() at the end. If we bail because
need_resched() we don't need the acquire I think.
