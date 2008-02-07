From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 07 Feb 2008 22:08:59 +0000
Subject: Re: [PATCH] SGI Altix mmtimer - allow larger number of timers per
Message-Id: <20080207140859.36cb9c53.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080207213552.GA2658@sgi.com>
In-Reply-To: <20080207213552.GA2658@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 7 Feb 2008 15:35:52 -0600
Dimitri Sivanich <sivanich@sgi.com> wrote:

> This patch to the SGI Altix specific mmtimer driver is to allow a
> virtually infinite number of timers to be set per node.
> 
> Timers will now be kept on a sorted per-node list and a single node-based
> hardware comparator is used to trigger the next timer.
> 

It is unclear whether Tony or I handle mmtimer patches?

I hope he understands the code better than I ("what's an mmtimer?")

> =================================> --- linux.orig/drivers/char/mmtimer.c	2008-01-24 16:58:37.000000000 -0600
> +++ linux/drivers/char/mmtimer.c	2008-02-07 14:51:15.158550577 -0600

erk.  Please feed this diff (and all future diffs) through
scripts/checkpatch.pl.  This patch sends it wild.

> @@ -74,7 +74,6 @@ static const struct file_operations mmti
>   * We only have comparison registers RTC1-4 currently available per
>   * node.  RTC0 is used by SAL.
>   */
> -#define NUM_COMPARATORS 3
>  /* Check for an RTC interrupt pending */
>  static int inline mmtimer_int_pending(int comparator)
>  {
> @@ -92,7 +91,7 @@ static void inline mmtimer_clr_int_pendi
>  }
>  
>  /* Setup timer on comparator RTC1 */
> -static void inline mmtimer_setup_int_0(u64 expires)
> +static void inline mmtimer_setup_int_0(int cpu, u64 expires)

OK, this driver has inline disease.  When I removed all the inlines from
it, the amount of text shrunk by a kilobyte.  That's your precious L1
icache I'm saving.

> -/* There is one of these for each comparator */
> +#define TIMER_OFF	0xbadcabLL	/* Timer is not setup */
> +#define TIMER_LIST	-1		/* Timer is on a node list */
> +#define TIMER_SET	0		/* Comparator is set for this timer */
> +
> +/* There is one of these for each timer */
>  typedef struct mmtimer {
> -	spinlock_t lock ____cacheline_aligned;
> +	struct list_head list ____cacheline_aligned;
>  	struct k_itimer *timer;
> -	int i;
>  	int cpu;
> -	struct tasklet_struct tasklet;
>  } mmtimer_t;

hm.  Is the ____cacheline_aligned on a struct member actually meaningful
and useful?  I guess it had some rationale when it was on a spinlock, but
what's it there for now?

While you're there, please consider removing the mmtimer_t typedef
altogether and using "struct mmtimer" everywhere.


> -static mmtimer_t ** timers;
> +typedef struct mmtimer_node {
> +	spinlock_t lock ____cacheline_aligned;
> +	mmtimer_t timer_head;
> +	mmtimer_t * ctimer;
> +	struct tasklet_struct tasklet;
> +} mmtimer_node_t;

Use `struct mmtimer_node' everywhere, remove typedef (checkpatch would have
mentioned this)

> +static mmtimer_node_t * timers;
> +
> +
> +/*
> + * Add a new mmtimer_t to the node's mmtimer list.
> + * This function assumes the mmtimer_node_t is locked.
> + */
> +void mmtimer_add_list(mmtimer_t * n) {
> +	mmtimer_t * x = NULL;
> +	unsigned long expires = n->timer->it.mmtimer.expires;
> +	int nodeid = n->timer->it.mmtimer.node;
> +
> +	/* Add the new mmtimer_t to node's timer list */
> +	if (list_empty(&timers[nodeid].timer_head.list)) {
> +		/* Add to head of the list. */
> +		list_add(&n->list, &timers[nodeid].timer_head.list);
> +		return;
> +	}
> +
> +	list_for_each_entry(x, &timers[nodeid].timer_head.list, list) {
> +		struct k_itimer * tt = x->timer;
> +		if (expires < tt->it.mmtimer.expires) {
> +			list_add_tail(&n->list, &x->list);
> +			return;
> +		}
> +		if (list_is_last(&x->list, &timers[nodeid].timer_head.list)) {
> +			list_add(&n->list, &x->list);
> +			return;
> +		}
> +	}
> +}

That's a linear search?  Experience tells us that each time we add an O(n)
algorith to the kernel, _someone_ will manage to produce amazingly-large-n
and their kernel sucks and we have to fix it.

We have several nice O(log(n)) storage libraries in the tree.  Can one be
used here?  hashtable, radix-tree, idr tree, rbtree, ...?

> +/*
> + * Set the comparator for the next timer.
> + * This function assumes the mmtimer_node_t is locked.
> + */
> +void mmtimer_set_next_timer(int nodeid) {
> +	mmtimer_node_t * n = &timers[nodeid];

Does (or will) ia64 support node hotplug?  If so, what are the implications?

> +	mmtimer_t * x, * y;
> +	struct k_itimer *t;
> +
> +	/* Set comparator for next timer, if there is one */
> +	list_for_each_entry_safe(x, y, &n->timer_head.list, list) {
> +		int o = 0;
> +
> +		n->ctimer = x;
> +		t = x->timer;
> +		t->it.mmtimer.clock = TIMER_SET;
> +		if (!t->it.mmtimer.incr) {
> +			/* Not an interval timer */
> +			if (!mmtimer_setup(x->cpu, COMPARATOR,
> +						t->it.mmtimer.expires)) {
> +					/* Late setup, fire now */
> +					tasklet_schedule(&n->tasklet);
> +			}
> +			break;
> +		}
> +
> +		/* Interval timer */
> +		while (!mmtimer_setup(x->cpu, COMPARATOR,
> +				t->it.mmtimer.expires)) {
> +			t->it.mmtimer.expires += t->it.mmtimer.incr << o;
> +			t->it_overrun += 1 << o;
> +			o++;
> +			if (o > 20) {
> +				printk(KERN_ALERT "mmtimer: cannot reschedule interval timer\n");
> +				n->ctimer = NULL;
> +				t->it.mmtimer.clock = TIMER_OFF;
> +				list_del(&x->list);
> +				break;
> +			}
> +		}
> +		if (o <= 20) break;
> +	}
> +}

Another arbitrarily large linear search under spin_lock_irqsave().  Ouch.

Can userspace control the length of that search?  If so, double ouch.


