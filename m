From: Claudio Imbrenda <imbrenda@linux.ibm.com>
Date: Tue, 23 May 2023 12:00:56 +0000
Subject: Re: [PATCH 15/23] s390: allow pte_offset_map_lock() to fail
Message-Id: <20230523140056.55b664b1@p-imbrenda>
List-Id: <linux-ia64.vger.kernel.org>
References: <77a5d8c-406b-7068-4f17-23b7ac53bc83@google.com>
        <94aec8fe-383f-892-dcbf-d4c14e460a7@google.com>
        <20230517123546.672fb9b0@p-imbrenda>
        <4a15dbaa-1614-ce-ce1f-f73959cef895@google.com>
In-Reply-To: <4a15dbaa-1614-ce-ce1f-f73959cef895@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, David Hildenbrand <david@redhat.com>, Suren Baghdasaryan <surenb@google.com>, Qi Zheng <zhengqi.arch@bytedance.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Helge Deller <deller@gmx.de>, John David Anglin <dave.anglin@bell.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Alexandre Ghiti <alexghiti@rivosinc.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 17 May 2023 14:50:28 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> On Wed, 17 May 2023, Claudio Imbrenda wrote:
> > On Tue, 9 May 2023 22:01:16 -0700 (PDT)
> > Hugh Dickins <hughd@google.com> wrote:
> >   
> > > In rare transient cases, not yet made possible, pte_offset_map() and
> > > pte_offset_map_lock() may not find a page table: handle appropriately.
> > > 
> > > Signed-off-by: Hugh Dickins <hughd@google.com>
> > > ---
> > >  arch/s390/kernel/uv.c  |  2 ++
> > >  arch/s390/mm/gmap.c    |  2 ++
> > >  arch/s390/mm/pgtable.c | 12 +++++++++---
> > >  3 files changed, 13 insertions(+), 3 deletions(-)
> > > 
> > > diff --git a/arch/s390/kernel/uv.c b/arch/s390/kernel/uv.c
> > > index cb2ee06df286..3c62d1b218b1 100644
> > > --- a/arch/s390/kernel/uv.c
> > > +++ b/arch/s390/kernel/uv.c
> > > @@ -294,6 +294,8 @@ int gmap_make_secure(struct gmap *gmap, unsigned long gaddr, void *uvcb)
> > >  
> > >  	rc = -ENXIO;
> > >  	ptep = get_locked_pte(gmap->mm, uaddr, &ptelock);
> > > +	if (!ptep)
> > > +		goto out;  
> 
> You may or may not be asking about this instance too.  When I looked at

actually no, because of the reasons you give here :)

> how the code lower down handles -ENXIO (promoting it to -EFAULT if an
> access fails, or to -EAGAIN to ask for a retry), this looked just right
> (whereas using -EAGAIN here would be wrong: that expects a "page" which
> has not been initialized at this point).
> 
> > >  	if (pte_present(*ptep) && !(pte_val(*ptep) & _PAGE_INVALID) && pte_write(*ptep)) {
> > >  		page = pte_page(*ptep);
> > >  		rc = -EAGAIN;
> > > diff --git a/arch/s390/mm/gmap.c b/arch/s390/mm/gmap.c
> > > index dc90d1eb0d55..d198fc9475a2 100644
> > > --- a/arch/s390/mm/gmap.c
> > > +++ b/arch/s390/mm/gmap.c
> > > @@ -2549,6 +2549,8 @@ static int __zap_zero_pages(pmd_t *pmd, unsigned long start,
> > >  		spinlock_t *ptl;
> > >  
> > >  		ptep = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
> > > +		if (!ptep)
> > > +			break;  
> > 
> > so if pte_offset_map_lock fails, we abort and skip both the failed
> > entry and the rest of the entries?  
> 
> Yes.
> 
> > 
> > can pte_offset_map_lock be retried immediately if it fails? (consider
> > that we currently don't allow THP with KVM guests)
> > 
> > Would something like this:
> > 
> > do {
> > 	ptep = pte_offset_map_lock(...);
> > 	mb();	/* maybe? */
> > } while (!ptep);
> > 
> > make sense?  
> 
> No.  But you're absolutely right to be asking: thank you for looking
> into it so carefully - and I realize that it's hard at this stage to
> judge what's appropriate, when I've not yet even posted the endpoint
> of these changes, the patches which make it possible not to find a
> page table here.  And I'm intentionally keeping that vague, because
> although I shall only introduce a THP case, I do expect it to be built
> upon later in reclaiming empty page tables: it would be nice not to
> have to change the arch code again when extending further.
> 
> My "rare transient cases" phrase may be somewhat misleading: one thing
> that's wrong with your tight pte_offset_map_lock() loop above is that
> the pmd entry pointing to page table may have been suddenly replaced
> by a pmd_none() entry; and there's nothing in your loop above to
> break out if that is so.
> 
> But if a page table is suddenly removed, that would be because it was
> either empty, or replaced by a THP entry, or easily reconstructable on
> demand (by that, I probably mean it was only mapping shared file
> pages, which can just be refaulted if needed again).
> 
> The case you're wary of, is if the page table were removed briefly,
> then put back shortly after: and still contains zero pages further
> down. That's not something mm does now, nor at the end of my several
> series, nor that I imagine us wanting to do in future: but I am
> struggling to find a killer argument to persuade you that it could
> never be done - most pages in a page table do need rmap tracking,
> which will BUG if it's broken, but that argument happens not to apply
> to the zero page.
> 
> (Hmm, there could be somewhere, where we would find it convenient to
> remove a page table with intent to do ...something, then validation
> of that isolated page table fails, so we just put it back again.)
> 
> Is it good enough for me to promise you that we won't do that?
> 
> There are several ways in which we could change __zap_zero_pages(),
> but I don't see them as actually dealing with the concern at hand.
> 
> One change, I've tended to make at the mm end but did not dare
> to interfere here: it would seem more sensible to do a single
> pte_offset_map_lock() outside the loop, return if that fails,
> increment ptep inside the loop, pte_unmap_unlock() after the loop.
> 
> But perhaps you have preemption reasons for not wanting that; and
> although it would eliminate the oddity of half-processing a page
> table, it would not really resolve the problem at hand: because,
> what if this page table got removed just before __zap_zero_pages()
> tries to take the lock, then got put back just after?
> 
> Another change: I see __zap_zero_pages() is driven by
> walk_page_range(), and over at the mm end I'm usually setting
> walk->action to ACTION_AGAIN in these failure cases; but thought that
> an unnecessary piece of magic here, and cannot see how it could
> actually help.  Your "retry the whole walk_page_range()" suggestion
> below would be a heavier equivalent of that: but neither way gives
> confidence, if a page table could actually be removed then reinserted
> without mmap_write_lock().
> 
> I think I want to keep this s390 __zap_zero_pages() issue in mind, it
> is important and thank you for raising it; but don't see any change
> to the patch as actually needed.
> 
> Hugh

so if I understand the above correctly, pte_offset_map_lock will only
fail if the whole page table has disappeared, and in that case, it will
never reappear with zero pages, therefore we can safely skip (in that
case just break). if we were to do a continue instead of a break, we
would most likely fail again anyway.

in that case I would still like a small change in your patch: please
write a short (2~3 lines max) comment about why it's ok to do things
that way
