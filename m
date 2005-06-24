From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 24 Jun 2005 13:08:45 +0000
Subject: Re: [RFC] Hierarchical BackOff Locks
Message-Id: <Pine.LNX.4.62.0506220904080.29540@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506151550440.6431@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506151550440.6431@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 22 Jun 2005, Zoltan Menyhart wrote:

> My first problem in "_raw_spin_lock_flags()" is:
> 
> Assuming the lock is taken by a CPU in node X.
> Assuming all the CPUs in the node Y call "_raw_spin_lock_flags()".
> They can proceed only with some 100 nanosec. one after the other.
> All of them find ".spin_at" not equal to the lock address.
> As the lock is busy, all of them go to spin in "hbo_spinlock_contention()".
> Only one of them should spin there, the others should go to spin in
> "hbo_spinlock_wait_remote()", should not they ?

Ideally yes but that is not necessary for the correctness of the 
algorithm.

> I am not sure if the algorithm works correctly if more than 1 CPUs enter
> in "hbo_spinlock_contention()".

Then multiple attempts to acquire the same remote lock may occur. This 
will reduce performance.

> > +	/* Increase backoff for next cycle */
> > +	backoff = min(((backoff * backoff_factor) << 8), cap);
> 
> With the values of "cap" and "back off" you gave, it always results "cap".

We should have  >> instead of <<.
 
> BTW should not the local vs. remote values be calculated from some
> ACPI table values ?

Yes consulting a slit table would be ideal.

> > +			for_each_online_node(i)
> > +				cmpxchg(&(ndata[i].spin_at), lock, NULL);
> 
> I guess we should clean the ".spin_at" on the stopped nodes only if
> we really have got the lock.

No we need to remove any nodes that we stopped even if we did not get the 
lock otherwise we may cause other processes to be be stuck waiting in a 
"spin_at" loop.

> You may have up to 256 nodes. I think we should not touch in vain the
> ".spin_at"-s for the nodes which are not waiting for the lock.
> 
> Why to use "cmpxchg()" ?

Another cpu may have overwritten the spin_at value and its not good to 
reset the spin_at value to NULL if its in use by another node.

> > See http://www.sgi.com/products/software/linux/downloads/sync_linux.pdf
> 
> What beck mark and what measurement tools do you use e.g. for creating
> "Illustration 3 Average Fault Time..." ?

See the performance counter patch posted to linux-ia64.

> > +/* These definitions do not mean much. Lots of code for IA64 depends on
> > + * zeroed memory containing unlocked spinlocks
> > + */
> >  #define SPIN_LOCK_UNLOCKED			(spinlock_t) { 0 }
> >  #define spin_lock_init(x)			((x)->lock = 0)
> 
> I am for using them everywhere, instead of forgetting about them :-)

Agreed. But the reality is that IA64 arch specific code assumes zeroed 
memory contains unlocked spinlocks.

> > +extern struct node_lock_s ndata[MAX_NUMNODES];
> 
> Can we have a more speaking name, not just "ndata" ?

Ok. Changed to node_lock_info.

> > +
> > +#define _raw_spin_lock_flags(__x, __flags)
> > \
> > +do {
> > \
> > +	__u32 *ia64_spinlock_ptr = (__u32 *) (__x);
> > \
> 
> I guess it would be more readable to take the address of the field "->lock".
> Please take advantage of the type checking mechanisms.
> A lock word is a volatile...

Ok. Done.

> 
> 	volatile __u32 *ia64_spinlock_ptr = &__x->lock;
> 
> Please consider the other similar lock references, too.

Cannot find any other references like that.

> 
> > +	if (unlikely(ndata[numa_node_id()].spin_at = ia64_spinlock_ptr))
> > \
> 
> It will be expanded in to *some* nested arrays:
> 
> if
> (!!(ndata[((int)(cpu_to_node_map[(ia64_getreg(_IA64_REG_TP)->cpu)]))].spin_at
> = ia64_spinlock_ptr))
> 
> Can we consider instead of "cpu_to_node_map[(ia64_getreg(_IA64_REG_TP)->cpu)]"
> perhaps some "per_cpu__my_slock_idx" ?

Yes that may be a good optimization.

