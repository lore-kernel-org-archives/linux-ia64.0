From: Claudio Imbrenda <imbrenda@linux.ibm.com>
Date: Thu, 25 May 2023 07:23:51 +0000
Subject: Re: [PATCH 15/23] s390: allow pte_offset_map_lock() to fail
Message-Id: <20230525092351.7671f2a4@p-imbrenda>
List-Id: <linux-ia64.vger.kernel.org>
References: <77a5d8c-406b-7068-4f17-23b7ac53bc83@google.com>
        <94aec8fe-383f-892-dcbf-d4c14e460a7@google.com>
        <20230517123546.672fb9b0@p-imbrenda>
        <4a15dbaa-1614-ce-ce1f-f73959cef895@google.com>
        <20230523140056.55b664b1@p-imbrenda>
        <b64cd153-18e8-81a6-b852-c04d8b1381d@google.com>
In-Reply-To: <b64cd153-18e8-81a6-b852-c04d8b1381d@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, David Hildenbrand <david@redhat.com>, Suren Baghdasaryan <surenb@google.com>, Qi Zheng <zhengqi.arch@bytedance.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Helge Deller <deller@gmx.de>, John David Anglin <dave.anglin@bell.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Alexandre Ghiti <alexghiti@rivosinc.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 23 May 2023 18:49:14 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> On Tue, 23 May 2023, Claudio Imbrenda wrote:
> > 
> > so if I understand the above correctly, pte_offset_map_lock will only
> > fail if the whole page table has disappeared, and in that case, it will
> > never reappear with zero pages, therefore we can safely skip (in that
> > case just break). if we were to do a continue instead of a break, we
> > would most likely fail again anyway.  
> 
> Yes, that's the most likely; and you hold mmap_write_lock() there,
> and VM_NOHUGEPAGE on all vmas, so I think it's the only foreseeable
> possibility.
> 
> > 
> > in that case I would still like a small change in your patch: please
> > write a short (2~3 lines max) comment about why it's ok to do things
> > that way  
> 
> Sure.
> 
> But I now see that I've disobeyed you, and gone to 4 lines (but in the
> comment above the function, so as not to distract from the code itself):
> is this good wording to you?  I needed to research how they were stopped
> from coming in afterwards, so wanted to put something greppable in there.
> 
> And, unless I'm misunderstanding, that "after THP was enabled" was
> always supposed to say "after THP was disabled" (because splitting a
> huge zero page pmd inserts a a page table full of little zero ptes).

indeed, thanks for noticing and fixing it

> 
> Or would you prefer the comment in the commit message instead,
> or down just above the pte_offset_map_lock() line?
> 
> It would much better if I could find one place at the mm end, to
> enforce its end of the contract; but cannot think how to do that.
> 
> Hugh
> 
> --- a/arch/s390/mm/gmap.c
> +++ b/arch/s390/mm/gmap.c
> @@ -2537,7 +2537,12 @@ static inline void thp_split_mm(struct mm_struct *mm)
>   * Remove all empty zero pages from the mapping for lazy refaulting
>   * - This must be called after mm->context.has_pgste is set, to avoid
>   *   future creation of zero pages
> - * - This must be called after THP was enabled
> + * - This must be called after THP was disabled.
> + *
> + * mm contracts with s390, that even if mm were to remove a page table,
> + * racing with the loop below and so causing pte_offset_map_lock() to fail,
> + * it will never insert a page table containing empty zero pages once
> + * mm_forbids_zeropage(mm) i.e. mm->context.has_pgste is set.
>   */
>  static int __zap_zero_pages(pmd_t *pmd, unsigned long start,
>  			   unsigned long end, struct mm_walk *walk)

looks good, thanks
