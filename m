From: Zoltan Menyhart <Zoltan.Menyhart@free.fr>
Date: Fri, 21 Apr 2006 18:08:23 +0000
Subject: Re: Protect PGD...PTE walking in ivt.S
Message-Id: <44491F97.4070704@free.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <4448E85B.5080906@bull.net>
In-Reply-To: <4448E85B.5080906@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> On Fri, 21 Apr 2006, Zoltan Menyhart wrote:
> 
>>- it scales well
> 
> mmap_sem is the major performance bottleneck for page faults at this time 
> because it creates a bouncing cacheline. Figure out a way to avoid that to 
> increase performance.

Have you got some numbers?
Can I have a copy of your test program, please?

>>4. On one hand, as "free_pgtables()" cannot run in the mean time,
>>  there is no need to re-read pgd[i] -> pud[j] -> pmd[k].
>>  On the other hand, the swapper is not excluded => we keep re-checking
>>  pte[l] and purging the freshly inserted TLB entry if it has been changed.
> 
> The walking of pgd/pud/pmd can happen anytime through the mmu on many
> architectures. It is therefore not protectable by any lock. 

I do not know much about the other architectures.

As TBL loading is not the same mechanism on all the architectures,
therefore architecture dependent solutions can be applied.

If PGD...PTE walking does not need protection / cannot be protected on
other architectures, then it is not a strong argument about the ia64's
behavior.

We were talking about this issue in the thread "accessed/dirty bit
handler tuning". I thought we had agreed that this PGD...PTE walking
is unsafe.
Locking _is_ a logically correct solution.
Any other suggestion?

> free_pgtables() is run when all processes in a mm_struct have terminated 
> or when all vmas from an area have been removed.
> 
> There can be no one using the page tables.

Please refer to "unmap_region()".

Thanks,

Zoltan


