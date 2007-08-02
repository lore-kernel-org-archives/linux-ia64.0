From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 02 Aug 2007 07:09:56 +0000
Subject: RE: ia64 mmu_gather question
Message-Id: <1186038596.5495.588.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186026055.5495.585.camel@localhost.localdomain>
In-Reply-To: <1186026055.5495.585.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2007-08-01 at 22:38 -0700, Luck, Tony wrote:
> No locking.  But we do have race detection.  After we chase the
> PGD>PUD>PMD>PTE
> pointers we insert the TLB entry.  Then we retrace the pointer chain
> and
> make sure that the pte we find is still the same.  If it isn't, then
> we
> purge the entry we just inserted and go for a full page fault.
> 
> Time to tell bed-time stories to my daughter.  More tomorrow (if
> someone
> else doesn't fill in the rest of the answers before I get back to
> this).

Ok, that's what I think I understood from the asm. However, what
prevents the very unlikely race where you insert a stale pgtable
mapping entry, and before you backtrack and remove it, another
CPU accesses the stale PTE ?

I'm tempted, while at working on the mmu_gather, to add a generic
mechanism for putting the page table quicklist pages in there too.
Though that would only help for archs that 1) have the problem
(typically are SW loaded in a way or another) and 2) use an IPI for SMP
flush (not ppc64 for example).

Cheers,
Ben.

