From: Hugh Dickins <hughd@google.com>
Date: Thu, 11 May 2023 03:40:41 +0000
Subject: Re: [PATCH 01/23] arm: allow pte_offset_map[_lock]() to fail
Message-Id: <b9dc75bf-b13c-37ba-6c16-9fc163703dd@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <77a5d8c-406b-7068-4f17-23b7ac53bc83@google.com> <5011977-d876-6a24-a3fc-c7e6a02877b8@google.com> <ZFup/fG50MPFF979@casper.infradead.org>
In-Reply-To: <ZFup/fG50MPFF979@casper.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Hildenbrand <david@redhat.com>, Suren Baghdasaryan <surenb@google.com>, Qi Zheng <zhengqi.arch@bytedance.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Helge Deller <deller@gmx.de>, John David Anglin <dave.anglin@bell.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Alexandre Ghiti <alexghiti@rivosinc.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Claudio Imbrenda <imbrenda@linux.ibm.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 10 May 2023, Matthew Wilcox wrote:
> On Tue, May 09, 2023 at 09:42:44PM -0700, Hugh Dickins wrote:
> > diff --git a/arch/arm/lib/uaccess_with_memcpy.c b/arch/arm/lib/uaccess_with_memcpy.c
> > index e4c2677cc1e9..2f6163f05e93 100644
> > --- a/arch/arm/lib/uaccess_with_memcpy.c
> > +++ b/arch/arm/lib/uaccess_with_memcpy.c
> > @@ -74,6 +74,9 @@ pin_page_for_write(const void __user *_addr, pte_t **ptep, spinlock_t **ptlp)
> >  		return 0;
> >  
> >  	pte = pte_offset_map_lock(current->mm, pmd, addr, &ptl);
> > +	if (unlikely(!pte))
> > +		return 0;
> 
> Failing seems like the wrong thig to do if we transitioned from a PTE
> to PMD here?  Looks to me like we should goto a new label right after
> the 'pmd = pmd_offset(pud, addr);', no?

I'm pretty sure it's right as is; but probably more by luck than care -
I do not think I studied this code as closely as you have now made me do;
and it's clear that this is a piece of code where rare transient issues
could come up, and must be handled correctly.  Thank you for making me
look again.

The key is in the callers of pin_page_for_write(): __copy_to_user_memcpy()
and __clear_user_memset().  They're doing "while (!pin_page_for_write())"
loops - they hope for the fast path of getting pte_lock or pmd_lock on
the page, and doing a __memcpy() or __memset() to the user address; but
if anything goes "wrong", a __put_user() to fault in the page (or fail)
then pin_page_for_write() again.

"if (unlikely(!pte)) return 0" says that the expected fast path did not
succeed, so please __put_user() and have another go.

It is somewhere I could have done a "goto again", but that would be
superfluous when it's already designed that way at the outer level.

Hugh
