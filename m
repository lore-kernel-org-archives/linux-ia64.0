From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 22:14:11 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <200603312213.k2VMDSg07090@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan,

Can you do some stress test experiments and let us know how many time ptc.l was actually executed in vhpt_miss/tlb_miss/dirty/access
handler? Thanks.

- Ken


-----Original Message-----
From: Zoltan Menyhart [mailto:Zoltan.Menyhart@free.fr] 
Sent: Friday, March 31, 2006 1:18 PM
To: Chen, Kenneth W; linux-ia64@vger.kernel.org
Subject: Re: accessed/dirty bit handler tuning

Chen, Kenneth W wrote:

> Zoltan Menyhart wrote on Friday, March 31, 2006 8:23 AM
> 
>>Ken wrote:
>>
>> > cpu0                            cpu1                  cpu2
>> > Vhpt miss:
>> >   walk page table
>> >                                 free_pgtables
>> >                                 ptc.g fault address
>> >                                 ptc.g hash address
>> >                                                       pud_alloc/pmd_alloc
>> >                                                       new page instantiation
>> >   itc.d faulting address
>> >   itc.d hash address
>> >   read pte
>> >   kill tlb for fault addr
>> >   rfi
>>
>>Let's apply the same logic to the dirty bit handler.
>>
>>Assume a nested TLB miss, i.e. we dig up the PTE entry in the same way as
>>we do in "vhpt_miss" (in physical addressing mode):
>>
>>	rx = ... -> pgd[i] -> pud[j] -> pmd[k] -> pte[l]
>>
>>(and some NULL pointer verifications)
>>
>>Having inserted the new PTE (and the srlz.d is done), we re-read the
>>PTE value only.
>>What makes it sure that the PTE address is still valid when we re-read the
>>PTE value (we are still in physical addressing mode)?
> 
> 
> Because nested DTLB miss will ensure the consistency.  If another CPU is
> tearing down the address space, a separate purge will occur.

Lets assume the following for cpu0:

- it owns a copy of a shared cache line
- this cache line is on a data page that has never been modified
- it has got a valid TLB entry for mapping the data page
- it has NOT got a valid TLB entry for mapping the corresponding PTE page
- it tries to modify the cache line

cpu0:                          cpu1:                   cpu2:
dirty bit fault:
attempts to read the PTE
nested DTLB fault:
walks page table
back to dirty bit handler:
reads the PTE using phys. addr.
itc.d new PTE
                                free_pgtables:
                                ptc.g dirty bit fault address
                                free the data page
                                ptc.g PTE page address
                                free the PTE page
                                                        pte_alloc:
                                                        re-uses the old PTE page
                                                        new page instantiation:
                                                        re-uses the old data page
srlz.d completes
re-reads the PTE using phys. addr.
PTE value matches


Problem #1:

cpu0 keeps (see r17) the physical address of a PTE whose page has gone.
cpu0 is not sensitive to ptc.g-ing the PTE page address, because it accesses
the PTE page by use of this (potentially invalid) physical address, not as the
virtually mapped linear page table.

cpu0 has not got the right to touch a PTE page unless it makes sure
that the PTE page is still anchored by its current->mm->pgd...

Problem #2:

cpu2 may install the old data page freed by cpu1 at the same PTE offset as it
was before.
The new PTE may be numerically the same as the one just inserted by cpu0
(and it is at the same physical address), but it belongs to another process.
cpu0 cannot catch the ptc.g for the dirty bit fault address because
itc.d + srlz.d have not completed by that moment.
The compare may result in a false positive.
cpu0 may be granted the write access right to a data page of someone else.

Thanks,

Zoltan







