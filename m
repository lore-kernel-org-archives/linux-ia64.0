From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 19:08:20 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <200603311907.k2VJ7ag04987@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote on Friday, March 31, 2006 8:23 AM
> Ken wrote:
> 
>  > cpu0                            cpu1                  cpu2
>  > Vhpt miss:
>  >   walk page table
>  >                                 free_pgtables
>  >                                 ptc.g fault address
>  >                                 ptc.g hash address
>  >                                                       pud_alloc/pmd_alloc
>  >                                                       new page instantiation
>  >   itc.d faulting address
>  >   itc.d hash address
>  >   read pte
>  >   kill tlb for fault addr
>  >   rfi
> 
> Let's apply the same logic to the dirty bit handler.
> 
> Assume a nested TLB miss, i.e. we dig up the PTE entry in the same way as
> we do in "vhpt_miss" (in physical addressing mode):
> 
> 	rx = ... -> pgd[i] -> pud[j] -> pmd[k] -> pte[l]
> 
> (and some NULL pointer verifications)
> 
> Having inserted the new PTE (and the srlz.d is done), we re-read the
> PTE value only.
> What makes it sure that the PTE address is still valid when we re-read the
> PTE value (we are still in physical addressing mode)?

Because nested DTLB miss will ensure the consistency.  If another CPU is
tearing down the address space, a separate purge will occur.


> Should not we re-read the complete pgd ... pte chain as we do in "vhpt_miss"?
> 
> Should not we insert the TLB entry for the relevant virtual page table page
> as we do in "vhpt_miss" (it's an efficiency issue only)?

I think both are really bad ideas.  The fast path should already have the
TLB for the hash address in the CPU, why bother looking it up again?
