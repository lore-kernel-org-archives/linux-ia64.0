From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 27 Feb 2023 19:46:31 +0000
Subject: Re: [PATCH mm-unstable v1 11/26] microblaze/mm: support __HAVE_ARCH_PTE_SWP_EXCLUSIVE
Message-Id: <CAMuHMdX7MND++KXgTpx4jscfctQA_-zPt3EN9-+79EWE7e+OjA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230113171026.582290-1-david@redhat.com> <20230113171026.582290-12-david@redhat.com>
 <CAMuHMdX-FDga8w=pgg1myskEx6wp+oyZifhPPPFnWrc1zW7ZpQ@mail.gmail.com>
 <9ed766a6-cf06-535d-3337-ea6ff25c2362@redhat.com> <CAMuHMdWSaoKqO1Nx7QMDCcXrRmFbqqX8uwDRezXs8g+HdEFjKA@mail.gmail.com>
 <c145a2db-f92c-65aa-3e68-07dbb2e097a6@redhat.com>
In-Reply-To: <c145a2db-f92c-65aa-3e68-07dbb2e097a6@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@nvidia.com>, Mike Rapoport <rppt@linux.ibm.com>, Yang Shi <shy828301@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Nadav Amit <namit@vmware.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, linux-mm@kvack.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, Michal Simek <monstr@monstr.eu>

Hi David,

On Mon, Feb 27, 2023 at 6:01 PM David Hildenbrand <david@redhat.com> wrote:
> >>>>    /*
> >>>>     * Externally used page protection values.
> >>>> diff --git a/arch/microblaze/include/asm/pgtable.h b/arch/microblaze/include/asm/pgtable.h
> >>>> index 42f5988e998b..7e3de54bf426 100644
> >>>> --- a/arch/microblaze/include/asm/pgtable.h
> >>>> +++ b/arch/microblaze/include/asm/pgtable.h

> >>>>     * - All other bits of the PTE are loaded into TLBLO without
> >>>>     *  * modification, leaving us only the bits 20, 21, 24, 25, 26, 30 for
> >>>>     * software PTE bits.  We actually use bits 21, 24, 25, and
> >>>> @@ -155,6 +155,9 @@ extern pte_t *va_to_pte(unsigned long address);
> >>>>    #define _PAGE_ACCESSED 0x400   /* software: R: page referenced */
> >>>>    #define _PMD_PRESENT   PAGE_MASK
> >>>>
> >>>> +/* We borrow bit 24 to store the exclusive marker in swap PTEs. */
> >>>> +#define _PAGE_SWP_EXCLUSIVE    _PAGE_DIRTY
> >>>
> >>> _PAGE_DIRTY is 0x80, so this is also bit 7, thus the new comment is
> >>> wrong?
> >>
> >> In the example, I use MSB-0 bit numbering (which I determined to be
> >> correct in microblaze context eventually, but I got confused a couple a
> >> times because it's very inconsistent). That should be MSB-0 bit 24.
> >
> > Thanks, TIL microblaze uses IBM bit numbering...
>
> I assume IBM bit numbering corresponds to MSB-0 bit numbering, correct?

Correct, as seen in s370 and PowerPC manuals...

> I recall that I used the comment above "/* Definitions for MicroBlaze.
> */" as an orientation.
>
> 0  1  2  3  4  ... 18 19 20 21 22 23 24 25 26 27 28 29 30 31
> RPN.....................  0  0 EX WR ZSEL.......  W  I  M  G

Indeed, that's where I noticed the "unconventional" numbering...

> So ... either we adjust both or we leave it as is. (again, depends on
> what the right thing to to is -- which I don't know :) )

It depends whether you want to match the hardware documentation,
or the Linux BIT() macro and friends...

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
