From: Michal Hocko <mhocko@kernel.org>
Date: Wed, 10 Oct 2018 07:58:44 +0000
Subject: Re: [PATCH] memblock: stop using implicit alignement to SMP_CACHE_BYTES
Message-Id: <20181010075844.GA5873@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1538687224-17535-1-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1538687224-17535-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-um@lists.infradead.org

On Fri 05-10-18 00:07:04, Mike Rapoport wrote:
> When a memblock allocation APIs are called with align = 0, the alignment is
> implicitly set to SMP_CACHE_BYTES.

I would add something like
"
Implicit alignment is done deep in the memblock allocator and it can
come as a surprise. Not that such an alignment would be wrong even when
used incorrectly but it is better to be explicit for the sake of clarity
and the prinicple of the least surprise.
"

> Replace all such uses of memblock APIs with the 'align' parameter explicitly
> set to SMP_CACHE_BYTES and stop implicit alignment assignment in the
> memblock internal allocation functions.
> 
> For the case when memblock APIs are used via helper functions, e.g. like
> iommu_arena_new_node() in Alpha, the helper functions were detected with
> Coccinelle's help and then manually examined and updated where appropriate.
> 
> The direct memblock APIs users were updated using the semantic patch below:
> 
> @@
> expression size, min_addr, max_addr, nid;
> @@
> (
> |
> - memblock_alloc_try_nid_raw(size, 0, min_addr, max_addr, nid)
> + memblock_alloc_try_nid_raw(size, SMP_CACHE_BYTES, min_addr, max_addr,
> nid)
> |
> - memblock_alloc_try_nid_nopanic(size, 0, min_addr, max_addr, nid)
> + memblock_alloc_try_nid_nopanic(size, SMP_CACHE_BYTES, min_addr, max_addr,
> nid)
> |
> - memblock_alloc_try_nid(size, 0, min_addr, max_addr, nid)
> + memblock_alloc_try_nid(size, SMP_CACHE_BYTES, min_addr, max_addr, nid)
> |
> - memblock_alloc(size, 0)
> + memblock_alloc(size, SMP_CACHE_BYTES)
> |
> - memblock_alloc_raw(size, 0)
> + memblock_alloc_raw(size, SMP_CACHE_BYTES)
> |
> - memblock_alloc_from(size, 0, min_addr)
> + memblock_alloc_from(size, SMP_CACHE_BYTES, min_addr)
> |
> - memblock_alloc_nopanic(size, 0)
> + memblock_alloc_nopanic(size, SMP_CACHE_BYTES)
> |
> - memblock_alloc_low(size, 0)
> + memblock_alloc_low(size, SMP_CACHE_BYTES)
> |
> - memblock_alloc_low_nopanic(size, 0)
> + memblock_alloc_low_nopanic(size, SMP_CACHE_BYTES)
> |
> - memblock_alloc_from_nopanic(size, 0, min_addr)
> + memblock_alloc_from_nopanic(size, SMP_CACHE_BYTES, min_addr)
> |
> - memblock_alloc_node(size, 0, nid)
> + memblock_alloc_node(size, SMP_CACHE_BYTES, nid)
> )
> 
> Suggested-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

I do agree that this is an improvement. I would also add WARN_ON_ONCE on
0 alignment to catch some left overs. If we ever grown a user which
would explicitly require the zero alignment (I would be surprised) then
we can remove the warning.

Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs
