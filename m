From: Andi Kleen <ak@muc.de>
Date: Thu, 13 Jan 2005 18:02:05 +0000
Subject: Re: page table lock patch V15 [0/7]: overview
Message-Id: <20050113180205.GA17600@muc.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com> <20050112104326.69b99298.akpm@osdl.org> <41E5AFE6.6000509@yahoo.com.au> <20050112153033.6e2e4c6e.akpm@osdl.org> <41E5B7AD.40304@yahoo.com.au> <Pine.LNX.4.58.0501121552170.12669@schroedinger.engr.sgi.com> <41E5BC60.3090309@yahoo.com.au> <Pine.LNX.4.58.0501121611590.12872@schroedinger.engr.sgi.com> <20050113031807.GA97340@muc.de> <Pine.LNX.4.58.0501130907050.18742@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0501130907050.18742@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org

On Thu, Jan 13, 2005 at 09:11:29AM -0800, Christoph Lameter wrote:
> On Wed, 13 Jan 2005, Andi Kleen wrote:
> 
> > Alternatively you can use a lazy load, checking for changes.
> > (untested)
> >
> > pte_t read_pte(volatile pte_t *pte)
> > {
> > 	pte_t n;
> > 	do {
> > 		n.pte_low = pte->pte_low;
> > 		rmb();
> > 		n.pte_high = pte->pte_high;
> > 		rmb();
> > 	} while (n.pte_low != pte->pte_low);
> > 	return pte;

It should be return n; here of course.

> > }
> >
> > No atomic operations, I bet it's actually faster than the cmpxchg8.
> > There is a small risk for livelock, but not much worse than with an
> > ordinary spinlock.
> 
> Hmm.... This may replace the get of a 64 bit value. But here could still
> be another process that is setting the pte in a non-atomic way.

The rule in i386/x86-64 is that you cannot set the PTE in a non atomic way
when its present bit is set (because the hardware could asynchronously 
change bits in the PTE that would get lost). Atomic way means clearing
first and then replacing in an atomic operation.

This helps you because you shouldn't be looking at the pte anyways
when pte_present is false. When it is not false it is always updated
atomically.

-Andi
