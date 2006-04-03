From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 03 Apr 2006 08:46:06 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <4430E0CE.40102@bull.net>
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

The problem common to both the VHPT miss and the nested DTLB handler is
that we have to walk the

    rx = IA64_KR_PT_BASE -> pgd[i] -> pud[j] -> pmd[k] -> pte[l]

chain without any locking.

IA64_KR_PT_BASE remains valid, the PGD page remains in its place until exit
(of the last thread in a multi-threaded application).

Assume we have picked up a valid PUD pointer from pgd[i].
Today, nothing makes sure that the PUD page remains valid by the time when
we dereference the PUD pointer.
The same can be said about the other steps in the chain.

I agree, the probability that it happens is very very low.
Yet we do not program for the statistics but for the security.

Someone wants more chance to hit this bug? Here it is:

Assume we have picked up a valid PUD / PMD / PTE pointer.
A local MCA happens that is corrected by the PAL / SAL => CMCI (later).
As the recovery can take no matter how much time, another CPU has got
plenty of time to unmap a region, set free a PUD / PMD / PTE page
whose physical address is in a register of our CPU.

We are insensitive to the ptc.g of the hash address, issued by the CPU
tearing down the mapping.

We may be obliged to pronounce the 4 letter dirty word: lock.

> Can you do some stress test experiments and let us know how many time ptc.l
> was actually executed in vhpt_miss/tlb_miss/dirty/access
> handler? Thanks.

Did you think of locking, too? Do you want to estimate the loss of the
performance?

Using the page-table-lock is out of question:
- can be split (looking up "struct page"-es not a good idea)
- scales badly
- we do not want to exclude page faults (which only add pages)
- we do not want to exclude the swapper (that takes away "leaf" pages only)

I can think of taking the mm semaphore for read:
- can be taken for read almost all the time
- scales well
- requires 2 atomic operation, say 4 memory accesses:
  it doubles the original number of memory accesses needed to walk
  the PGD ... PTE chain

Unless ... the P*D[] pointers become virtual addresses.
(Either the virtual addresses themselves are stored in the tables or we
keep the physical ones and we or 0xe000... to them.)

This idea is based on the following:
If we have got a virtual address and we manages to access the memory via
this virtual address => the virtual address was valid during the access.
Whoever tears down the mapping clears first the pointer then purges the
translation enabling to access the pointer. We can catch it by the usual
technique.

Here is my first guess for the VHPT miss handler (sanity checks, e.g.
"presence", and other minor calculations are left for the reader):

// This is the fast path
- Do not switch off the data translation
- IA64_KR_PT_BASE holds the virtual address of the PGD page
- Set the return address for all nested faults
  (always re-run the complete sequence in case of fault)
- Set a predicate to indicate that we try to read pgd[i]
  (or bx = @dedicated-nested-fault-handler)
- Read pgd[i] - may fault, see below
- Set a predicate to indicate that we try to read pud[j]
- Read pud[j] - may fault, see below
- Set a predicate to indicate that we try to read pmd[k]
- Read pmd[k] - may fault, see below
- Insert the translation for the PTE page + srlz.d
- Re-read pmd[k] - may fault...
- If it does not match => purge the translation + re-start
- Set a predicate to indicate that we try to read pte[l]
- Read pte[l] - may fault despite the fact that the PTE page just
                has been mapped "by hand"
- Insert the new translation + srlz.*
- Re-read pte[l] - may fault...
- If it does not match => purge the translation + re-start

As we use virtual addresses => the nested fault handler has to insert
an identity mapped translation for the PGD, PUD or PMD page, or the
translation - as today - for the PTE page (it will be used by the HW
walker, too).

The fast path of this proposal includes the same number of loads, itc-s
and srlz-s as the current version (with the missing srlz.d added).

The drawback of this latter approach is that it requires 5 TLB entries
to be able to "progress forward". The architecture does not guarantee
that many. However, the ia64 CPUs in production (and the foreseen ones)
have got 128 TLB entries...
(We may check at boot time if they are available.
If not we may fall back...)


Zoltan

