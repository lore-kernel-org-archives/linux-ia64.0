From: Davidlohr Bueso <dave@stgolabs.net>
Date: Wed, 15 Jun 2016 16:56:59 +0000
Subject: Re: [RFC PATCH-tip v2 1/6] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <20160615165659.GC2094@linux-80c1.suse>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com>
 <1465944489-43440-2-git-send-email-Waiman.Long@hpe.com>
In-Reply-To: <1465944489-43440-2-git-send-email-Waiman.Long@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <Waiman.Long@hpe.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On Tue, 14 Jun 2016, Waiman Long wrote:

>The osq_lock() and osq_unlock() function may not provide the necessary
>acquire and release barrier in some cases. This patch makes sure
>that the proper barriers are provided when osq_lock() is successful
>or when osq_unlock() is called.
>
>Signed-off-by: Waiman Long <Waiman.Long@hpe.com>
>---
> kernel/locking/osq_lock.c |    4 ++--
> 1 files changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/kernel/locking/osq_lock.c b/kernel/locking/osq_lock.c
>index 05a3785..7dd4ee5 100644
>--- a/kernel/locking/osq_lock.c
>+++ b/kernel/locking/osq_lock.c
>@@ -115,7 +115,7 @@ bool osq_lock(struct optimistic_spin_queue *lock)
> 	 * cmpxchg in an attempt to undo our queueing.
> 	 */
>
>-	while (!READ_ONCE(node->locked)) {
>+	while (!smp_load_acquire(&node->locked)) {

Hmm this being a polling path, that barrier can get pretty expensive and
last I checked it was unnecessary:

036cc30c6b6 (locking/osq: No need for load/acquire when acquire-polling)

Thanks,
Davidlohr
