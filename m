From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 27 Apr 2006 11:04:10 +0000
Subject: Re: Read *pgd again in vhpt_miss handler
Message-Id: <4450A52A.5030406@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <444F79CA.7060804@bull.net>
In-Reply-To: <444F79CA.7060804@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:

> A more favorable change is to remove comparing pud/pmd entry, but
> condition the vhpt TLB purging upon detecting pte modification.
> I had this patch in my pocket for a while for other optimizations
> I'm working on and it looks like a good timing to post it now.

I cannot agree with you.

1. If *pte becomes invalid in the mean time, then the translation
   for the PTE page can be still valid.
   E.g. the swapper removes PTE-s and purges the translations for
   user pages only, never for a PTE page.

2. Let's have a look at your posting on the 30th os March, in the thread
  "accessed/dirty bit handler tuning":

> cpu0                            cpu1                  cpu2
> Vhpt miss:
>   walk page table
>                                 free_pgtables
>                                 ptc.g fault address
>                                 ptc.g hash address
>                                                       pud_alloc/pmd_alloc
>                                                       new page instantiation
>   itc.d faulting address
>   itc.d hash address
>   read pte
>   kill tlb for fault addr
>   rfi
> 
> Touch fault addr
> Walker install the tlb
> with staled vhpt tlb
> -> using someone else's page
>  -> data corruption

I did agree with you.

In addition, I wanted to add a protection for protecting the
pgd ... pte chain walking.
I wanted to use the mm semaphore => no need to walk again the
pgd ... pte chain.

I think your new patch widens the security hole.

Regards,

Zoltan
