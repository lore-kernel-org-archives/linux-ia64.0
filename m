From: Mike Rapoport <rppt@kernel.org>
Date: Fri, 12 May 2023 03:38:24 +0000
Subject: Re: [PATCH 00/23] arch: allow pte_offset_map[_lock]() to fail
Message-Id: <20230512033824.GF4135@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <77a5d8c-406b-7068-4f17-23b7ac53bc83@google.com>
 <ZFs0k2rrLPH9A/UU@casper.infradead.org>
 <d7f3c7b2-25b8-ef66-98a8-43d68f4499f@google.com>
 <ZFz1j1slZHCQmwMJ@casper.infradead.org>
In-Reply-To: <ZFz1j1slZHCQmwMJ@casper.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Hildenbrand <david@redhat.com>, Suren Baghdasaryan <surenb@google.com>, Qi Zheng <zhengqi.arch@bytedance.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Helge Deller <deller@gmx.de>, John David Anglin <dave.anglin@bell.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Alexandre Ghiti <alexghiti@rivosinc.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Claudio Imbrenda <imbrenda@linux.ibm.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michel Lespinasse <michel@lespinasse.org>

Hi,

On Thu, May 11, 2023 at 03:02:55PM +0100, Matthew Wilcox wrote:
> On Wed, May 10, 2023 at 09:35:44PM -0700, Hugh Dickins wrote:
> > On Wed, 10 May 2023, Matthew Wilcox wrote:
> > 
> > I don't really understand why you're going down a remove-CONFIG_HIGHPTE
> > route: I thought you were motivated by the awkardness of kmap on large
> > folios; but I don't see how removing HIGHPTE helps with that at all
> > (unless you have a "large page tables" effort in mind, but I doubt it).
> 
> Quite right, my primary concern is filesystem metadata; primarily
> directories as I don't think anybody has ever supported symlinks or
> superblocks larger than 4kB.
> 
> I was thinking that removing CONFIG_HIGHPTE might simplify the page
> fault handling path a little, but now I've looked at it some more, and
> I'm not sure there's any simplification to be had.  It should probably
> use kmap_local instead of kmap_atomic(), though.
 
Removing CONFIG_HIGHPTE will drop several lines and will allow to get rid
of custom __pte_alloc_one on x86.

--
Sincerely yours,
Mike.
