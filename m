From: Robin Holt <holt@sgi.com>
Date: Wed, 15 Dec 2004 21:21:29 +0000
Subject: Re: [very very drafty] prezeroing to increase the page fault rate
Message-Id: <20041215212129.GA29941@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 14, 2004 at 06:34:13PM -0800, Christoph Lameter wrote:
> The page fault patches address the scalability of the fault handler
> by aggregating requests (anticipatory prefaulting) or by reducing the locking
> overhead (page fault scalability patches). However, the main time spend in
> the page fault handler is by zeroing pages. The following patch
> zeroes pages in the background through hardware (Altix Block Transfer Engine)
> or via software when the system is idle. This increases the performance
> of the page fault handler dramatically even for only a single thread:
> 
> 2.6.10-rc3-bk7 (allocating 1 GB):
> 
>  Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
>   1   1    8    0.029s      1.373s   0.039s 46733.217 167449.984
>   1   1    4    0.016s      1.152s   0.043s 56064.229 152067.012
>   1   1    2    0.011s      1.074s   0.056s 60349.726 115679.719
>   1   1    1    0.012s      0.708s   0.072s 90933.436  90849.200
> 
> with patch:
> 
>  Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
>   1   1    8    0.012s      0.759s   0.023s 84840.529 279197.309
>   1   1    4    0.014s      0.307s   0.018s203360.588 354015.152
>   1   1    2    0.021s      0.373s   0.023s166111.155 283594.162
>   1   1    1    0.012s      0.200s   0.021s307839.729 306791.723
> 
> I have some spot results here that indicate that a single thread may
> do up to 500000 faults a second with this patch alone.

This sounds impressive, but from my limited understanding of the patches,
I think it is a misleading figure.  This would require the system to
sit idle for a period of time between large jobs to ensure that
enough pages are free so all allocations could be satisfied from the
pre-zeroed section.

My understanding (very limited as I only spent 15 minutes looking)
is that only idle cpus are actually queueing pages for zereoing.
Is this correct or am I off the mark?

If that is so, I think we need to rethink this some.  I believe the
largest benefit would come if you used timers to check for a previous
page zero operation completing and then queueing up the next.  This
could be done for all nodes that are owned by a parent node.  That would
allow a system with many mbricks (and therefore many btes) with very
few cbricks to effeciently use all the btes for zeroeoing.  Is that
the intent at any point in this patch life?  Otherwise you end up
with speedups only when you have idle cpus for zereoing.

> Index: linux-2.6.9/arch/ia64/sn/kernel/bte.c
> =================================> --- linux-2.6.9.orig/arch/ia64/sn/kernel/bte.c	2004-12-13 21:36:19.000000000 -0800
> +++ linux-2.6.9/arch/ia64/sn/kernel/bte.c	2004-12-14 18:19:07.000000000 -0800
> @@ -448,6 +458,94 @@
>  		mynodepda->bte_if[i].bte_num = i;
>  		mynodepda->bte_if[i].cleanup_active = 0;
>  		mynodepda->bte_if[i].bh_error = 0;
> +		mynodepda->bte_if[i].zp = NULL;
> +	}
> +}
> +
> +static inline void check_bzero_complete(void)
> +{
> +	unsigned long irq_flags;
> +	struct bteinfo_s *bte;
> +
> +	/* CPU 0 (per node) uses bte0 , CPU 1 uses bte1 */
> +	bte = bte_if_on_node(get_nasid(), cpuid_to_subnode(smp_processor_id()));
> +
> +	if (!bte->zp)
> +		return;
> +	local_irq_save(irq_flags);
> +	if (!spin_trylock(&bte->spinlock)) {
> +		local_irq_restore(irq_flags);
> +		return;
> +	}
> +	if (*bte->most_rcnt_na = BTE_WORD_BUSY ||
> +            (BTE_LNSTAT_LOAD(bte) & BTE_ACTIVE)) {
> +                spin_unlock_irqrestore(&bte->spinlock, irq_flags);
> +		return;
> +	}
> +	bte_bzero_complete(bte);
> +	spin_unlock_irqrestore(&bte->spinlock, irq_flags);
> +}
> +

Why not have a seperate notification line for zereoing operations.
Add a seperate bte flag in that says "use the zereoing notification
line" and have it return the address of the line being used.

You start then calls bte_copy with the flags and you get back
the notification line you are concerned with.  Alternatively,
you could put the notification line into a structure owned
by the bte_start_zero() private structures and pass the address
in.  This allows the bte_copy code to operation as is.  It will
also simplify the bte_start_bzero significantly and make it
very easy to keep things consistent.  I also makes understanding
the bte_copy code easier since there is no back-door interaction
with any other functions.


> +static int bte_start_bzero(struct page *p, int order)
> +{
> +	struct bteinfo_s *bte;
> +	unsigned int len = PAGE_SIZE << order;
> +	unsigned long irq_flags;
> +
> +
> +	/* Check limitations.
> +		1. System must be running (weird things happen during bootup)
> +		2. Size >128KB. Smaller requests cause too much bte traffic
> +	 */
> +	if (len > BTE_MAX_XFER ||
> +	    order < 4 ||
> +	    system_state != SYSTEM_RUNNING) {
> +		check_bzero_complete();
> +		return EINVAL;
> +	}
> +
> +	/* CPU 0 (per node) uses bte0 , CPU 1 uses bte1 */
> +	bte = bte_if_on_node(get_nasid(), cpuid_to_subnode(smp_processor_id()));
> +	local_irq_save(irq_flags);
> +
> +	if (!spin_trylock(&bte->spinlock)) {
> +		local_irq_restore(irq_flags);
> +		printk(KERN_INFO "bzero: bte spinlock locked\n");
> +		return EBUSY;
>  	}
> 
> +	/* Complete any pending bzero notification */
> +	bte_bzero_complete(bte);
> +
> +	if (bte->zp ||
> +	    !(*bte->most_rcnt_na & BTE_WORD_AVAILABLE) ||
> +	    (BTE_LNSTAT_LOAD(bte) & BTE_ACTIVE)) {
> +		/* Got the lock but BTE still busy */
> +		spin_unlock_irqrestore(&bte->spinlock, irq_flags);
> +		return EBUSY;
> +	}
> +	printk(KERN_INFO "bzero: start address=%p length=%d\n", page_address(p), len);
> +	bte->most_rcnt_na = &bte->notify;
> +	*bte->most_rcnt_na = BTE_WORD_BUSY;
> +	bte->zp = p;
> +	SetPageLocked(p);
> +	SetPageZero(p);
> +	BTE_LNSTAT_STORE(bte, IBLS_BUSY | ((len >> L1_CACHE_SHIFT) & BTE_LEN_MASK));
> +	BTE_SRC_STORE(bte, TO_PHYS(ia64_tpa(page_address(p))));
> +	BTE_DEST_STORE(bte, 0);
> +	BTE_NOTIF_STORE(bte,
> +			TO_PHYS(ia64_tpa((unsigned long)bte->most_rcnt_na)));
> +	BTE_CTRL_STORE(bte, BTE_ZERO_FILL);
> +
> +	spin_unlock_irqrestore(&bte->spinlock, irq_flags);
> +	return 0;
> +
> +}
> +
> +static struct zero_driver bte_bzero = {
> +	.start_bzero = bte_start_bzero
> +};
> +
> +void sn_bte_bzero_init(void) {
> +	register_zero_driver(&bte_bzero);
>  }
