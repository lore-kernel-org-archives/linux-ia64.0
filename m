From: David Hildenbrand <david@redhat.com>
Date: Thu, 08 Dec 2022 08:52:57 +0000
Subject: Re: [PATCH mm-unstable RFC 17/26] powerpc/mm: support __HAVE_ARCH_PTE_SWP_EXCLUSIVE on 32bit book3s
Message-Id: <0b5b1303-8bcb-c19d-5f63-0e4a3517fea5@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221206144730.163732-1-david@redhat.com>
 <20221206144730.163732-18-david@redhat.com>
 <8be167b6-3836-25c3-9f69-b8b3916ee5b4@csgroup.eu>
In-Reply-To: <8be167b6-3836-25c3-9f69-b8b3916ee5b4@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@nvidia.com>, Mike Rapoport <rppt@linux.ibm.com>, Yang Shi <shy828301@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Nadav Amit <namit@vmware.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "loongarch@lists.linux.dev" <loongarch@lists.linux.dev>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>

On 07.12.22 14:55, Christophe Leroy wrote:
> 
> 
> Le 06/12/2022 à 15:47, David Hildenbrand a écrit :
>> We already implemented support for 64bit book3s in commit bff9beaa2e80
>> ("powerpc/pgtable: support __HAVE_ARCH_PTE_SWP_EXCLUSIVE for book3s")
>>
>> Let's support __HAVE_ARCH_PTE_SWP_EXCLUSIVE also in 32bit by reusing yet
>> unused LSB 2 / MSB 29. There seems to be no real reason why that bit cannot
>> be used, and reusing it avoids having to steal one bit from the swap
>> offset.
>>
>> While at it, mask the type in __swp_entry().
>>
>> Cc: Michael Ellerman <mpe@ellerman.id.au>
>> Cc: Nicholas Piggin <npiggin@gmail.com>
>> Cc: Christophe Leroy <christophe.leroy@csgroup.eu>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>>    arch/powerpc/include/asm/book3s/32/pgtable.h | 38 +++++++++++++++++---
>>    1 file changed, 33 insertions(+), 5 deletions(-)
>>
>> diff --git a/arch/powerpc/include/asm/book3s/32/pgtable.h b/arch/powerpc/include/asm/book3s/32/pgtable.h
>> index 75823f39e042..8107835b38c1 100644
>> --- a/arch/powerpc/include/asm/book3s/32/pgtable.h
>> +++ b/arch/powerpc/include/asm/book3s/32/pgtable.h
>> @@ -42,6 +42,9 @@
>>    #define _PMD_PRESENT_MASK (PAGE_MASK)
>>    #define _PMD_BAD	(~PAGE_MASK)
>>    
>> +/* We borrow the _PAGE_USER bit to store the exclusive marker in swap PTEs. */
>> +#define _PAGE_SWP_EXCLUSIVE	_PAGE_USER
>> +
>>    /* And here we include common definitions */
>>    
>>    #define _PAGE_KERNEL_RO		0
>> @@ -363,17 +366,42 @@ static inline void __ptep_set_access_flags(struct vm_area_struct *vma,
>>    #define pmd_page(pmd)		pfn_to_page(pmd_pfn(pmd))
>>    
>>    /*
>> - * Encode and decode a swap entry.
>> - * Note that the bits we use in a PTE for representing a swap entry
>> - * must not include the _PAGE_PRESENT bit or the _PAGE_HASHPTE bit (if used).
>> - *   -- paulus
>> + * Encode/decode swap entries and swap PTEs. Swap PTEs are all PTEs that
>> + * are !pte_none() && !pte_present().
>> + *
>> + * Format of swap PTEs (32bit PTEs):
>> + *
>> + *                         1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 3 3
>> + *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
>> + *   E H P <- type --> <----------------- offset ------------------>
> 
> That's in reversed order. _PAGE_HASHPTE is bit 30 and should be on the
> right hand side. Etc ...

Ugh, messed it up while converting back and forth between LSB 0 and MSB 0.

/*
  * Format of swap PTEs (32bit PTEs):
  *
  *                         1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 3 3
  *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
  *   <----------------- offset ------------------> <- type --> E H P


Now the patch description ("unused LSB 2 / MSB 29") makes sense.

Thanks!

Any feedback if the bit could be problematic?

-- 
Thanks,

David / dhildenb
