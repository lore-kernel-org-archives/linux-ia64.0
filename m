From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 27 Jun 2005 15:30:01 +0000
Subject: Re: [RFC] Hierarchical BackOff Locks
Message-Id: <42C01B79.4080204@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506151550440.6431@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506151550440.6431@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:

>>Can we consider instead of "cpu_to_node_map[(ia64_getreg(_IA64_REG_TP)->cpu)]"
>>perhaps some "per_cpu__my_slock_idx" ?
>>
>>
>>>+	ia64_spinlock_val = ia64_cmpxchg4_acq(ia64_spinlock_ptr,
>>>numa_node_id()+ 1, 0);	\
>>
>>Instead of "numa_node_id()+ 1" perhaps some "per_cpu__my_slock_id" ?
> 
> 
> I just tried to implement your proposed method but we will run into issues 
> with preemption. I would have preempt disable/enables or irq 
> disable/enables inline as well as in the contention handlers.

We do have got the appropriate preempt disable/enables or irq disable/enables,
see in "_spin_lock_irq()", "_spin_lock(), etc.
Otherwise even the numa node ID wouldn't be stable.
This is why we could include the CPU ID, too, in to the lock word, for
dead-lock hunting.

>>Assuming the lock is taken by a CPU in node X.
>>Assuming all the CPUs in the node Y call "_raw_spin_lock_flags()".
>>They can proceed only with some 100 nanosec. one after the other.
>>All of them find ".spin_at" not equal to the lock address.
>>As the lock is busy, all of them go to spin in "hbo_spinlock_contention()".
>>Only one of them should spin there, the others should go to spin in
>>"hbo_spinlock_wait_remote()", should not they ?
> 
> 
> Ideally yes but that is not necessary for the correctness of the 
> algorithm.

I'm afraid the hierarchical back-off algorithm will not work, you will
not take advantage of having just a single task looping on the remote
lock word and the others in the same node, looping on a local cache line.
In addition to the scenario above:

		if (unlikely(remote)) {
			/* Remove off-node block */
			ndata[numa_node_id()].spin_at = NULL;

Here, you kick off all the other CPUs waiting for the lock in the
current node. You do it regardless if the lock is really yours or not.
Assuming that the "anger_level < anger_limit", then there is not much
chance to get a remote lock before the others.
The other CPUs waiting for the lock in the current node, most probably
all of them, will enter "hbo_spinlock_contention()" almost at the same time.

I'm afraid the "hierarchical back-off"-ness of the algorithm will be lost.

Should not there be some node-local atomic operation to make sure only
one CPU goes out through the NUMA interconnect?

One more thing about:

		ndata[numa_node_id()].spin_at = NULL;

If I have acquired the lock =>
	why to wake them (all of them) up (the lock is busy) ?
If it is someone else =>
	The other CPUs in the current node can loop at ".spin_at"-s

>>I am not sure if the algorithm works correctly if more than 1 CPUs enter
>>in "hbo_spinlock_contention()".
> 
> 
> Then multiple attempts to acquire the same remote lock may occur. This 
> will reduce performance.

Can you estimate how many remote read / write / invalidate / atomic op.
etc. would a change in the lock ownership costs?

E.g. for the traditional spin lock:
- Waiting on a busy lock does not cost a penny: we loop on a shared
  line in the cache.
- Setting free costs obtaining the exclusivity: killing the other copies
  of the cache line at the N waiting CPUs - very expensive.
- The N CPUs re-read the cache line, it costs almost N remote reads.
  (Assuming cache intervention, no real memory read / write)
- One of the CPUs manages to obtain the exclusivity: kills the other copies
  of the cache line at the N-1 CPUs - very expensive.
- Some not too expensive internal delay due to the atomic operation.
- The N-1 CPUs re-read the cache line, it costs almost N remote reads.
Total: 2 global cache line kills + 2 * N remote reads

The hierarchical back-off algorithm should be cheaper (in average).

>> With the values of "cap" and "back off" you gave, it always results "cap".
> We should have  >> instead of <<. 

As backoff_factor = 2*8, the expression

		/* Increase backoff for next cycle */
		backoff = min(((backoff * backoff_factor) >> 8), cap);

would be:	backoff = min((backoff / 16), cap);

This decreasing "back off", the values of "cap" and "back off" you gave,
do not correspond to the description in the chapter 11.1 in your paper.

Can you give the actual min. - max. time the "back off" would last?

>>>+			for_each_online_node(i)
>>>+				cmpxchg(&(ndata[i].spin_at), lock, NULL);
...
>>You may have up to 256 nodes. I think we should not touch in vain the
>>".spin_at"-s for the nodes which are not waiting for the lock.

Is it really necessary to clear all the ".spin_at"-s ?
It will disturb those nodes which we haven't stopped while we were "angry".
In addition, the ".spin_at" we set, should be cleared only if we have got
the lock, otherwise we increase our chance for starvation.

>>>+extern struct node_lock_s ndata[MAX_NUMNODES];
>>Can we have a more speaking name, not just "ndata" ?
> Ok. Changed to node_lock_info.

Have you got just a single global "node_lock_info[]",
common for all the spin locks?

>>I guess it would be more readable to take the address of the field "->lock".
>>Please take advantage of the type checking mechanisms.
> 
>>	volatile __u32 *ia64_spinlock_ptr = &__x->lock;
>>
>>Please consider the other similar lock references, too.
> 
> Cannot find any other references like that.

I mean a lock is a structure, not just the lock word.
(Some lock instrumentation wound require additional structure fields.)

E.g. passing the lock to "hbo_spinlock_contention()": it could have a
lock pointer instead the address of the lock word itself. It would be more
easy to use some #ifdef-s to activate lock instrumentation.

> +			stopped_nodes++;

Nowadays, it can overflow. I guess you need a flag, not a counter.

Thanks,

Zoltan
