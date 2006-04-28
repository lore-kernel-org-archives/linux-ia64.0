From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 28 Apr 2006 07:53:19 +0000
Subject: Re: Read *pgd again in vhpt_miss handler
Message-Id: <4451C9EF.9060807@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <444F79CA.7060804@bull.net>
In-Reply-To: <444F79CA.7060804@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> On Thu, 27 Apr 2006, Zoltan Menyhart wrote:
> 
> 
>>I wanted to use the mm semaphore => no need to walk again the
>>pgd ... pte chain.
> 
> 
> The pgd ... pte chain does not change even without mmap until 
> the usage of the memory area ceases.

It is about about un-mapping a zone while another thread faults
on an address belonging to the same zone.

We have got a

	rx = ... -> pgd[i] -> pud[j] -> pmd[k] -> pte[l]

chain to walk in the VHPT miss handler.

Having reached somewhere in this chain walking, we have got
the ph. address of the next page in the chain in a register.

Before we can fetch the next item in the chain, "unpredictable
long" time can pass.

In the mean time:
- "free_pgtables()" kills the page we are about to touch.
- Someone re-uses the same page for something else.

As we are still keeping the same ph. address, we fetch an item
from a page that is no more ours.

Even if this security window is small, it does exist.

The probability to hit this bug grows higher on a NUMA machine
with lots of CPUs.

I can accept that the VHPT miss handler cannot protected by
some locks, it is the other end that should use some "careful
un-mapping" in order to avoid race conditions.

Here is what I'm working on:

PTE, PMD and PUD page usage perfectly fits into the RCU approach:

1. The VHPT miss handler is protected by "rcu_read_lock_bh()".
   There is not a single instruction added, the required semantics
   is provided by the fact that the interrupts are off.

2. "free_pgtables()" keeps working as today for the non multi-
   threaded applications.

3. "free_pgtables()" and its subroutines do not actually free
   the PTE, PMD and PUD pages for multi-threaded applications.
   These pages will set free via an "call_rcu_bh()"-activated
   service.

(Perhaps, the weaker protection "rcu_read_lock()" - "call_rcu()"
will be enough...)

Please note that:
- The life span of the PTE, PMD and PUD pages is rather long:
  they are freed when the usage of the memory area ceases,
  provided no other map (using the same PTE, PMD and PUD pages)
  is valid.
- The number of the PTE, PMD and PUD pages is much more smaller
  that that of the leaf pages.
Therefore freeing them is not really performance critical.
As the "call_rcu_bh()"-activated freeing service will do a batch
processing, these is a chance that freeing the PTE, PMD and PUD
pages in this way be more efficient then the "pte_free()"... etc.
services of today are.

Regards,

Zoltan

