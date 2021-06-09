From: David Hildenbrand <david@redhat.com>
Date: Wed, 09 Jun 2021 10:56:00 +0000
Subject: Re: [PATCH 7/9] docs: remove description of DISCONTIGMEM
Message-Id: <6b92d273-dd0b-d67f-c2f6-cce13a33afd1@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210602105348.13387-1-rppt@kernel.org>
 <20210602105348.13387-8-rppt@kernel.org>
In-Reply-To: <20210602105348.13387-8-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Jonathan Corbet <corbet@lwn.net>, Matt Turner <mattst88@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Richard Henderson <rth@twiddle.net>, Vineet Gupta <vgupta@synopsys.com>, kexec@lists.infradead.org, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On 02.06.21 12:53, Mike Rapoport wrote:
> From: Mike Rapoport <rppt@linux.ibm.com>
> 
> Remove description of DISCONTIGMEM from the "Memory Models" document and
> update VM sysctl description so that it won't mention DISCONIGMEM.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>   Documentation/admin-guide/sysctl/vm.rst | 12 +++----
>   Documentation/vm/memory-model.rst       | 45 ++-----------------------
>   2 files changed, 8 insertions(+), 49 deletions(-)
> 
> diff --git a/Documentation/admin-guide/sysctl/vm.rst b/Documentation/admin-guide/sysctl/vm.rst
> index 586cd4b86428..ddbd71d592e0 100644
> --- a/Documentation/admin-guide/sysctl/vm.rst
> +++ b/Documentation/admin-guide/sysctl/vm.rst
> @@ -936,12 +936,12 @@ allocations, THP and hugetlbfs pages.
>   
>   To make it sensible with respect to the watermark_scale_factor
>   parameter, the unit is in fractions of 10,000. The default value of
> -15,000 on !DISCONTIGMEM configurations means that up to 150% of the high
> -watermark will be reclaimed in the event of a pageblock being mixed due
> -to fragmentation. The level of reclaim is determined by the number of
> -fragmentation events that occurred in the recent past. If this value is
> -smaller than a pageblock then a pageblocks worth of pages will be reclaimed
> -(e.g.  2MB on 64-bit x86). A boost factor of 0 will disable the feature.
> +15,000 means that up to 150% of the high watermark will be reclaimed in the
> +event of a pageblock being mixed due to fragmentation. The level of reclaim
> +is determined by the number of fragmentation events that occurred in the
> +recent past. If this value is smaller than a pageblock then a pageblocks
> +worth of pages will be reclaimed (e.g.  2MB on 64-bit x86). A boost factor
> +of 0 will disable the feature.
>   
>   
>   watermark_scale_factor
> diff --git a/Documentation/vm/memory-model.rst b/Documentation/vm/memory-model.rst
> index ce398a7dc6cd..30e8fbed6914 100644
> --- a/Documentation/vm/memory-model.rst
> +++ b/Documentation/vm/memory-model.rst
> @@ -14,15 +14,11 @@ for the CPU. Then there could be several contiguous ranges at
>   completely distinct addresses. And, don't forget about NUMA, where
>   different memory banks are attached to different CPUs.
>   
> -Linux abstracts this diversity using one of the three memory models:
> -FLATMEM, DISCONTIGMEM and SPARSEMEM. Each architecture defines what
> +Linux abstracts this diversity using one of the two memory models:
> +FLATMEM and SPARSEMEM. Each architecture defines what
>   memory models it supports, what the default memory model is and
>   whether it is possible to manually override that default.
>   
> -.. note::
> -   At time of this writing, DISCONTIGMEM is considered deprecated,
> -   although it is still in use by several architectures.
> -
>   All the memory models track the status of physical page frames using
>   struct page arranged in one or more arrays.
>   
> @@ -63,43 +59,6 @@ straightforward: `PFN - ARCH_PFN_OFFSET` is an index to the
>   The `ARCH_PFN_OFFSET` defines the first page frame number for
>   systems with physical memory starting at address different from 0.
>   
> -DISCONTIGMEM
> -======
> -
> -The DISCONTIGMEM model treats the physical memory as a collection of
> -`nodes` similarly to how Linux NUMA support does. For each node Linux
> -constructs an independent memory management subsystem represented by
> -`struct pglist_data` (or `pg_data_t` for short). Among other
> -things, `pg_data_t` holds the `node_mem_map` array that maps
> -physical pages belonging to that node. The `node_start_pfn` field of
> -`pg_data_t` is the number of the first page frame belonging to that
> -node.
> -
> -The architecture setup code should call :c:func:`free_area_init_node` for
> -each node in the system to initialize the `pg_data_t` object and its
> -`node_mem_map`.
> -
> -Every `node_mem_map` behaves exactly as FLATMEM's `mem_map` -
> -every physical page frame in a node has a `struct page` entry in the
> -`node_mem_map` array. When DISCONTIGMEM is enabled, a portion of the
> -`flags` field of the `struct page` encodes the node number of the
> -node hosting that page.
> -
> -The conversion between a PFN and the `struct page` in the
> -DISCONTIGMEM model became slightly more complex as it has to determine
> -which node hosts the physical page and which `pg_data_t` object
> -holds the `struct page`.
> -
> -Architectures that support DISCONTIGMEM provide :c:func:`pfn_to_nid`
> -to convert PFN to the node number. The opposite conversion helper
> -:c:func:`page_to_nid` is generic as it uses the node number encoded in
> -page->flags.
> -
> -Once the node number is known, the PFN can be used to index
> -appropriate `node_mem_map` array to access the `struct page` and
> -the offset of the `struct page` from the `node_mem_map` plus
> -`node_start_pfn` is the PFN of that page.
> -
>   SPARSEMEM
>   ====>   
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 
Thanks,

David / dhildenb
