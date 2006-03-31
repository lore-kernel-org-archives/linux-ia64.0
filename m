From: Zoltan Menyhart <Zoltan.Menyhart@free.fr>
Date: Fri, 31 Mar 2006 16:23:00 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <442D5764.5090903@free.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ken wrote:

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

Let's apply the same logic to the dirty bit handler.

Assume a nested TLB miss, i.e. we dig up the PTE entry in the same way as
we do in "vhpt_miss" (in physical addressing mode):

	rx = ... -> pgd[i] -> pud[j] -> pmd[k] -> pte[l]

(and some NULL pointer verifications)

Having inserted the new PTE (and the srlz.d is done), we re-read the
PTE value only.
What makes it sure that the PTE address is still valid when we re-read the
PTE value (we are still in physical addressing mode)?
Should not we re-read the complete pgd ... pte chain as we do in "vhpt_miss"?

Should not we insert the TLB entry for the relevant virtual page table page
as we do in "vhpt_miss" (it's an efficiency issue only)?

Thanks,

Zoltan

