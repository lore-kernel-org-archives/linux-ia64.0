From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 15 Dec 2004 22:00:29 +0000
Subject: Re: [very very drafty] prezeroing to increase the page fault rate
Message-Id: <Pine.LNX.4.58.0412151358170.13325@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 15 Dec 2004, Robin Holt wrote:

> > +static inline void check_bzero_complete(void)
> > +{
> > +	unsigned long irq_flags;
> > +	struct bteinfo_s *bte;
> > +
> > +	/* CPU 0 (per node) uses bte0 , CPU 1 uses bte1 */
> > +	bte = bte_if_on_node(get_nasid(), cpuid_to_subnode(smp_processor_id()));
> > +
> > +	if (!bte->zp)
> > +		return;
> > +	local_irq_save(irq_flags);
> > +	if (!spin_trylock(&bte->spinlock)) {
> > +		local_irq_restore(irq_flags);
> > +		return;
> > +	}
> > +	if (*bte->most_rcnt_na = BTE_WORD_BUSY ||
> > +            (BTE_LNSTAT_LOAD(bte) & BTE_ACTIVE)) {
> > +                spin_unlock_irqrestore(&bte->spinlock, irq_flags);
> > +		return;
> > +	}
> > +	bte_bzero_complete(bte);
> > +	spin_unlock_irqrestore(&bte->spinlock, irq_flags);
> > +}
> > +
>
> Why not have a seperate notification line for zereoing operations.
> Add a seperate bte flag in that says "use the zereoing notification
> line" and have it return the address of the line being used.
>
> You start then calls bte_copy with the flags and you get back
> the notification line you are concerned with.  Alternatively,
> you could put the notification line into a structure owned
> by the bte_start_zero() private structures and pass the address
> in.  This allows the bte_copy code to operation as is.  It will
> also simplify the bte_start_bzero significantly and make it
> very easy to keep things consistent.  I also makes understanding
> the bte_copy code easier since there is no back-door interaction
> with any other functions.

Good idea. Will do that in the next rev
