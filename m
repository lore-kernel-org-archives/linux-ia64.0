From: "John Hawkes" <hawkes@sgi.com>
Date: Thu, 25 Mar 2004 20:06:46 +0000
Subject: Re: should ia64_spinlock_contention do backoff?
Message-Id: <001a01c412a4$c5562470$d7069aa3@PCJohn>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
In-Reply-To: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: "David Mosberger" <davidm@napali.hpl.hp.com>
> Has anyone studied the impact of doing exponential backoff in
> ia64_spinlock_contention.  My theory is that it wouldn't buy much _if_
> spinlocks always were in their own cachelines, but since they're not,
> not using backoff could cause extra cache-line bouncing.  To be
> honest, I'd rather not spend time on this myself, since I don't have
> convenient access to large machines, but me thinks this is a question
> that's long overdue to have a proper answer.

We (at SGI) don't have definitive measurements on this, but it's On The List
of things to do.
I believe that for a NUMA system, one big problem with highly-contended
spinlocks is the relative unfairness of the more remote nodes as the waiters
race to see the spinlock freed and to be the first to reacquire it.  In
extreme cases this unfairness becomes a near-starvation.  A backoff algorithm
would likely produce more fairness in these high-contention cases, although at
the expense of potentially lengthening the wait-times for the shortest
waiters.

John Hawkes


