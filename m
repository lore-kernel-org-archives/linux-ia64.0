From: Christoph Lameter <christoph@engr.sgi.com>
Date: Fri, 21 Apr 2006 18:54:25 +0000
Subject: Re: Protect PGD...PTE walking in ivt.S
Message-Id: <Pine.LNX.4.64.0604211147400.27818@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4448E85B.5080906@bull.net>
In-Reply-To: <4448E85B.5080906@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 21 Apr 2006, Zoltan Menyhart wrote:

> Christoph Lameter wrote:
> > On Fri, 21 Apr 2006, Zoltan Menyhart wrote:
> > 
> > > - it scales well
> > 
> > mmap_sem is the major performance bottleneck for page faults at this time
> > because it creates a bouncing cacheline. Figure out a way to avoid that to
> > increase performance.
> 
> Have you got some numbers?
> Can I have a copy of your test program, please?

Test program is available from 
ftp.kernel.org/pub/linux/kernel/people/christoph/ptl/pft.c. See the 
discussion of my page fault scalability patches on lkml in 2004/2005.

> > The walking of pgd/pud/pmd can happen anytime through the mmu on many
> > architectures. It is therefore not protectable by any lock. 
> 
> I do not know much about the other architectures.

They are relevant since they determine core linux functionality.

> If PGD...PTE walking does not need protection / cannot be protected on
> other architectures, then it is not a strong argument about the ia64's
> behavior.

Of course. This means that the core kernel was designed in such a way to 
cope with this issue.
 
> We were talking about this issue in the thread "accessed/dirty bit
> handler tuning". I thought we had agreed that this PGD...PTE walking
> is unsafe.

I did?

> Locking _is_ a logically correct solution.
> Any other suggestion?

Drop the non issue.

> > free_pgtables() is run when all processes in a mm_struct have terminated or
> > when all vmas from an area have been removed.
> > 
> > There can be no one using the page tables.
> 
> Please refer to "unmap_region()".

Only run after the vmas have been removed. Any fault will lead to an 
access error.
