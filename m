From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 22 Jun 2005 15:45:02 +0000
Subject: Re: [RFC] Hierarchical BackOff Locks
Message-Id: <42B9877E.5090404@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506151550440.6431@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506151550440.6431@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph,

I like your idea.
I'm not sure that I understand correctly the implementation.

I have not got any big machine at hand yet, but as the architectures
will not become any simper in the future, you are right, we should do
something.

My first problem in "_raw_spin_lock_flags()" is:

Assuming the lock is taken by a CPU in node X.
Assuming all the CPUs in the node Y call "_raw_spin_lock_flags()".
They can proceed only with some 100 nanosec. one after the other.
All of them find ".spin_at" not equal to the lock address.
As the lock is busy, all of them go to spin in "hbo_spinlock_contention()".
Only one of them should spin there, the others should go to spin in
"hbo_spinlock_wait_remote()", should not they ?
I am not sure if the algorithm works correctly if more than 1 CPUs enter
in "hbo_spinlock_contention()".

in "hbo_spinlock_contention()":

Have you got just a single global "ndata[]", common for all the spin locks?

> +	/* Increase backoff for next cycle */
> +	backoff = min(((backoff * backoff_factor) << 8), cap);

With the values of "cap" and "back off" you gave, it always results "cap".

BTW should not the local vs. remote values be calculated from some
ACPI table values ?

> +	if (unlikely(remote)) {
> +		/* Remove off-node block */
> +		ndata[numa_node_id()].spin_at = NULL;
> +		if (stopped_nodes) {
> +			int i;
> +			/*
> +			 * Remove any remote blocks we established when we
> +			 * got angry
> +			 */
> +			for_each_online_node(i)
> +				cmpxchg(&(ndata[i].spin_at), lock, NULL);

I guess we should clean the ".spin_at" on the stopped nodes only if
we really have got the lock.

You may have up to 256 nodes. I think we should not touch in vain the
".spin_at"-s for the nodes which are not waiting for the lock.

Why to use "cmpxchg()" ?

Some more verbose comments will be appreciated :-)
(in spinlock.h, at the function headers: what, why, ...)

> See http://www.sgi.com/products/software/linux/downloads/sync_linux.pdf

What beck mark and what measurement tools do you use e.g. for creating
"Illustration 3 Average Fault Time..." ?

> +/* These definitions do not mean much. Lots of code for IA64 depends on
> + * zeroed memory containing unlocked spinlocks
> + */
>  #define SPIN_LOCK_UNLOCKED			(spinlock_t) { 0 }
>  #define spin_lock_init(x)			((x)->lock = 0)

I am for using them everywhere, instead of forgetting about them :-)

> +extern struct node_lock_s ndata[MAX_NUMNODES];

Can we have a more speaking name, not just "ndata" ?

> +
> +#define _raw_spin_lock_flags(__x, __flags)						\
> +do {											\
> +	__u32 *ia64_spinlock_ptr = (__u32 *) (__x);					\

I guess it would be more readable to take the address of the field "->lock".
Please take advantage of the type checking mechanisms.
A lock word is a volatile...

	volatile __u32 *ia64_spinlock_ptr = &__x->lock;

Please consider the other similar lock references, too.

> +	if (unlikely(ndata[numa_node_id()].spin_at = ia64_spinlock_ptr))		\

It will be expanded in to *some* nested arrays:

if (!!(ndata[((int)(cpu_to_node_map[(ia64_getreg(_IA64_REG_TP)->cpu)]))].spin_at = ia64_spinlock_ptr))

Can we consider instead of "cpu_to_node_map[(ia64_getreg(_IA64_REG_TP)->cpu)]"
perhaps some "per_cpu__my_slock_idx" ?

> +	ia64_spinlock_val = ia64_cmpxchg4_acq(ia64_spinlock_ptr, numa_node_id()+ 1, 0);	\

Instead of "numa_node_id()+ 1" perhaps some "per_cpu__my_slock_id" ?

As we have got 32 bits, perhaps we could include both the node ID and the CPU number
in to the busy lock word format. It could help to find out on a dead-locked system,
who has locked what :-)

Regards,

Zoltan Menyhart

