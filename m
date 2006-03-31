From: Zoltan Menyhart <Zoltan.Menyhart@free.fr>
Date: Fri, 31 Mar 2006 22:57:51 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <442DB3EF.7020801@free.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:

> You are correct.  I forgot that nested_dtlb_miss doesn't actually do the check.
> I rather prefer not to add anything in the fast path to detect an exceedingly
> rare race event (only if ia64 architect screwed up so bad that made itc.d have
> 10,000 cycle latency and at the same time does a splendid job at job at ptc.g
> which completes in zero cycle along with other thousands of other instructions).
> 
> In that event, as I said, it's actually better to simple purge the entry, write
> the dirty bit into in-memory page table entry and let the hardware page walker
> insert the new entry.

My first guess is:
- keep the fast path as it is (we are in virtual mode)
- after a nested DTLB fault, we do not return return to the fast path in physical
   but to the "completed" dirty bit fault handler

I guess it is more efficient than to let the hardware page walker
insert the new entry (we already have it in a register).

I'll have to think it over. I'm not sure we can write anything after the
nested DTLB fault. The next example:

cpu0:                          cpu1:                   cpu2:
dirty bit fault:
attempts to read the PTE
nested DTLB fault:
walks page table
back to dirty bit handler:
(keeps the physical address
of the PTE in r17)
                                free_pgtables:
                                ptc.g dirty bit fault address
                                free the data page
                                ptc.g PTE page address
                                free the PTE page
                                                        page_alloc:
                                                        re-uses the old PTE page
(still keeps the physical address
of the PTE whose page has gone)
ld
or
cmpxchg

Probably, there is no way to make sure the physical address of the PTE
remains valid => we have to switch back to virtual mode for the "completed"
dirty bit fault handler.

 > Can you do some stress test experiments and let us know how many time ptc.l
 > was actually executed in vhpt_miss/tlb_miss/dirty/access
 > handler? Thanks.

Well, to instrument the kernel may take some time...
What stress test program do you think of?

Zoltan



