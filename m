From: Hugh Dickins <hughd@google.com>
Date: Thu, 11 May 2023 22:37:06 +0000
Subject: Re: [PATCH 00/23] arch: allow pte_offset_map[_lock]() to fail
Message-Id: <5f1dd6f-1e75-8d98-3083-e1bd2163dcc6@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <77a5d8c-406b-7068-4f17-23b7ac53bc83@google.com> <ZFs0k2rrLPH9A/UU@casper.infradead.org> <d7f3c7b2-25b8-ef66-98a8-43d68f4499f@google.com> <ZFz1j1slZHCQmwMJ@casper.infradead.org>
In-Reply-To: <ZFz1j1slZHCQmwMJ@casper.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Hildenbrand <david@redhat.com>, Suren Baghdasaryan <surenb@google.com>, Qi Zheng <zhengqi.arch@bytedance.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Helge Deller <deller@gmx.de>, John David Anglin <dave.anglin@bell.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Alexandre Ghiti <alexghiti@rivosinc.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Claudio Imbrenda <imbrenda@linux.ibm.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michel Lespinasse <michel@lespinasse.org>

On Thu, 11 May 2023, Matthew Wilcox wrote:
> 
> I was thinking that removing CONFIG_HIGHPTE might simplify the page
> fault handling path a little, but now I've looked at it some more, and
> I'm not sure there's any simplification to be had.  It should probably
> use kmap_local instead of kmap_atomic(), though.

Re kmap_local, yes, one of the patches in the next series does make
that change.

> 
> I infer that what you need is a pte_access_start() and a
> pte_access_end() which look like they can be plausibly rcu_read_lock()
> and rcu_read_unlock(), but might need to be local_irq_save() and
> local_irq_restore() in some configurations?

Yes, except that the local_irq_restore() in PAE-like configurations
(if we need it at all) is not delayed until the pte_access_end() or
pte_unmap() - it's internal to the pte_access_start() or pte_offset_map():
interrupts only disabled across the getting of a consistent pmd entry.

Over-generalizing a little, any user of pte_offset_map() (as opposed to
pte_offset_map_lock()) has to be prepared for the ptes to change under
them: but we do need to give them something that is or was recently the
relevant page table, rather than a random page mishmashed from mismatched
pmd_low and pmd_high.

> 
> We also talked about moving x86 to always RCU-free page tables in
> order to make accessing /proc/$pid/smaps lockless.  I believe Michel
> is going to take a swing at this project.

(And /proc/$pid/numa_maps, I hope: that's even worse in some way, IIRC.)

That might be orthogonal to what I'm doing: many non-x86 architectures
already do RCU-freeing of page tables via the TLB route, but that doesn't
cover a pte_free() from retract_page_tables() or collapse_and_free_pmd().

Hugh
