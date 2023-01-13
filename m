From: "Russell King (Oracle)" <linux@armlinux.org.uk>
Date: Fri, 13 Jan 2023 17:38:31 +0000
Subject: Re: [PATCH mm-unstable v1 04/26] arm/mm: support __HAVE_ARCH_PTE_SWP_EXCLUSIVE
Message-Id: <Y8GXF/AgLKgWQW5p@shell.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230113171026.582290-1-david@redhat.com>
 <20230113171026.582290-5-david@redhat.com>
In-Reply-To: <20230113171026.582290-5-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@nvidia.com>, Mike Rapoport <rppt@linux.ibm.com>, Yang Shi <shy828301@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Nadav Amit <namit@vmware.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, linux-mm@kvack.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org

On Fri, Jan 13, 2023 at 06:10:04PM +0100, David Hildenbrand wrote:
> Let's support __HAVE_ARCH_PTE_SWP_EXCLUSIVE by stealing one bit from the
> offset. This reduces the maximum swap space per file to 64 GiB (was 128
> GiB).
> 
> While at it drop the PTE_TYPE_FAULT from __swp_entry_to_pte() which is
> defined to be 0 and is rather confusing because we should be dealing
> with "Linux PTEs" not "hardware PTEs". Also, properly mask the type in
> __swp_entry().
> 
> Cc: Russell King <linux@armlinux.org.uk>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Russell King (Oracle) <rmk+kernel@armlinux.org.uk>

Thanks.

-- 
RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
FTTP is here! 40Mbps down 10Mbps up. Decent connectivity at last!
