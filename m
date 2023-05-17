From: Alexander Gordeev <agordeev@linux.ibm.com>
Date: Wed, 17 May 2023 11:28:03 +0000
Subject: Re: [PATCH 16/23] s390: gmap use pte_unmap_unlock() not spin_unlock()
Message-Id: <ZGS6Q9jb/Rjwi4Rm@li-008a6a4c-3549-11b2-a85c-c5cc2836eea2.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <77a5d8c-406b-7068-4f17-23b7ac53bc83@google.com>
 <5579873-d7b-65e-5de0-a2ba8a144e7@google.com>
In-Reply-To: <5579873-d7b-65e-5de0-a2ba8a144e7@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, David Hildenbrand <david@redhat.com>, Suren Baghdasaryan <surenb@google.com>, Qi Zheng <zhengqi.arch@bytedance.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Helge Deller <deller@gmx.de>, John David Anglin <dave.anglin@bell.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Alexandre Ghiti <alexghiti@rivosinc.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Claudio Imbrenda <imbrenda@linux.ibm.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 09, 2023 at 10:02:32PM -0700, Hugh Dickins wrote:
> pte_alloc_map_lock() expects to be followed by pte_unmap_unlock(): to
> keep balance in future, pass ptep as well as ptl to gmap_pte_op_end(),
> and use pte_unmap_unlock() instead of direct spin_unlock() (even though
> ptep ends up unused inside the macro).
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>  arch/s390/mm/gmap.c | 22 +++++++++++-----------
>  1 file changed, 11 insertions(+), 11 deletions(-)

Acked-by: Alexander Gordeev <agordeev@linux.ibm.com>
