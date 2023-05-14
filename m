From: Hugh Dickins <hughd@google.com>
Date: Sun, 14 May 2023 18:20:16 +0000
Subject: Re: [PATCH 08/23] parisc: add pte_unmap() to balance get_ptep()
Message-Id: <6de39db5-d9aa-b35a-1652-8bdf90e7df72@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <77a5d8c-406b-7068-4f17-23b7ac53bc83@google.com> <44ebbf90-5fbb-2815-17c7-fcfe3c87d78e@google.com> <ca4ac780-42b0-4818-bd84-e1a4acbb28dd@gmx.de>
In-Reply-To: <ca4ac780-42b0-4818-bd84-e1a4acbb28dd@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Helge Deller <deller@gmx.de>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, David Hildenbrand <david@redhat.com>, Suren Baghdasaryan <surenb@google.com>, Qi Zheng <zhengqi.arch@bytedance.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, John David Anglin <dave.anglin@bell.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Alexandre Ghiti <alexghiti@rivosinc.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Claudio Imbrenda <imbrenda@linux.ibm.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 13 May 2023, Helge Deller wrote:

> Hi Hugh,
> 
> On 5/10/23 06:52, Hugh Dickins wrote:
> > To keep balance in future, remember to pte_unmap() after a successful
> > get_ptep().  And (we might as well) pretend that flush_cache_pages()
> > really needed a map there, to read the pfn before "unmapping".
> >
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > ---
> >   arch/parisc/kernel/cache.c | 26 +++++++++++++++++++++-----
> >   1 file changed, 21 insertions(+), 5 deletions(-)
> >
> > diff --git a/arch/parisc/kernel/cache.c b/arch/parisc/kernel/cache.c
> > index 1d3b8bc8a623..b0c969b3a300 100644
> > --- a/arch/parisc/kernel/cache.c
> > +++ b/arch/parisc/kernel/cache.c
> > @@ -425,10 +425,15 @@ void flush_dcache_page(struct page *page)
> >     offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
> >     addr = mpnt->vm_start + offset;
> >     if (parisc_requires_coherency()) {
> > +			bool needs_flush = false;
> >      pte_t *ptep;
> >
> >   			ptep = get_ptep(mpnt->vm_mm, addr);
> > -			if (ptep && pte_needs_flush(*ptep))
> > +			if (ptep) {
> > +				needs_flush = pte_needs_flush(*ptep);
> > +				pte_unmap(ptep);
> > +			}
> > +			if (needs_flush)
> >     		flush_user_cache_page(mpnt, addr);
> >     } else {
> >   			/*
> > @@ -560,14 +565,20 @@ EXPORT_SYMBOL(flush_kernel_dcache_page_addr);
> >   static void flush_cache_page_if_present(struct vm_area_struct *vma,
> >   	unsigned long vmaddr, unsigned long pfn)
> >   {
> > -	pte_t *ptep = get_ptep(vma->vm_mm, vmaddr);
> > +	bool needs_flush = false;
> > +	pte_t *ptep;
> >
> >    /*
> >     * The pte check is racy and sometimes the flush will trigger
> >     * a non-access TLB miss. Hopefully, the page has already been
> >     * flushed.
> >     */
> > -	if (ptep && pte_needs_flush(*ptep))
> > +	ptep = get_ptep(vma->vm_mm, vmaddr);
> > +	if (ptep) {
> > +		needs_flush = pte_needs_flush(*ptep))
> 
> ^^^^^
> One ")" too much and lacks a trailing ";"
> Should be:
> 		needs_flush = pte_needs_flush(*ptep);
> 
> With that fixed the kernel compiles and boots sucessfully on parisc.

Urgh! Indeed, thanks a lot Helge: I'll fold that in.

Hugh
