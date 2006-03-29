From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 29 Mar 2006 22:59:21 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <200603292258.k2TMwbg12513@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote on Wednesday, March 29, 2006 9:02 AM
> Can you please tell me why are the pud - pmd pointers are re-checked
> in "vhpt_miss" ?

This code has been there for over five years, and was written by a
prominent ia64 pioneer. I trusted it with my whole heart that it is
there for a good reason.


> As far as I know, pud, pmd, pte pages can go away only via:
> 
> 	free_pgtables()
> 		free_pgd_range()
> 			free_pud_range()
> 				free_pmd_range()
> 					free_pte_range()
> 
> If a 0xa000... stuff goes away => BUG.
> For the user mode pages:
> 
> "free_pgtables()" is called only from:
> 
> - "exit_mmap()": we simply cannot have the chance to have a vhpt miss
> - "unmap_region()" calls "unmap_vmas()" before "free_pgtables()":
>    again, we cannot fault in that region
> 
> Have I missed something?

OK, let's see what happens without re-read pud/pmd:

cpu0                            cpu1                  cpu2
Vhpt miss:
  walk page table
                                free_pgtables
                                ptc.g fault address
                                ptc.g hash address
                                                      pud_alloc/pmd_alloc
                                                      new page instantiation
  itc.d faulting address
  itc.d hash address
  read pte
  kill tlb for fault addr
  rfi

Touch fault addr
Walker install the tlb
with staled vhpt tlb
-> using someone else's page
 -> data corruption
   -> poor kernel engineer
      scratch his head with
      straight 7 days of debug
      with no clue what the
      hack is going on ....

It's a far fetched scenario, but ....

I suppose we can close the race with killing hash address tlb along with
the faulting address tlb.

- Ken
