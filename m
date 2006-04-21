From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 21 Apr 2006 17:13:40 +0000
Subject: Re: Protect PGD...PTE walking in ivt.S
Message-Id: <Pine.LNX.4.64.0604211004240.27420@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4448E85B.5080906@bull.net>
In-Reply-To: <4448E85B.5080906@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 21 Apr 2006, Zoltan Menyhart wrote:

> - it scales well

mmap_sem is the major performance bottleneck for page faults at this time 
because it creates a bouncing cacheline. Figure out a way to avoid that to 
increase performance.

> 4. On one hand, as "free_pgtables()" cannot run in the mean time,
>   there is no need to re-read pgd[i] -> pud[j] -> pmd[k].
>   On the other hand, the swapper is not excluded => we keep re-checking
>   pte[l] and purging the freshly inserted TLB entry if it has been changed.

The walking of pgd/pud/pmd can happen anytime through the mmu on many
architectures. It is therefore not protectable by any lock. 

free_pgtables() is run when all processes in a mm_struct have terminated 
or when all vmas from an area have been removed.

There can be no one using the page tables.
