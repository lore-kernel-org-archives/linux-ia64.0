From: "Magnus Damm" <magnus.damm@gmail.com>
Date: Wed, 28 Feb 2007 10:01:00 +0000
Subject: Re: [Patch] min_low_pfn and max_low_pfn calcultion fix
Message-Id: <aec7e5c30702280201p6a002136s91437526424345e2@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1172619535.20006.334.camel@linux-znh>
In-Reply-To: <1172619535.20006.334.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 28 Feb 2007 07:38:55 +0800, Zou Nan hai <nanhai.zou@intel.com> wrote:
>
> Hi,
>   We have seen bad_pte_print when testing crashdump on an SN machine in
> recent 2.6.20 kernel.
>   There are tons of bad pte print (pfn < max_low_pfn) reports when the
> crash kernel boots up, all those reported bad pages are inside initmem
> range;
>   That is because if the crash kernel code and data happens to be at the
> beginning of the 1st node. build_node_maps in discontig.c will bypass
> reserved regions with filter_rsvd_memory. Since min_low_pfn is
> calculated in build_node_map, so in this case, min_low_pfn will be
> greater than kernel code and data.
>
>   Because pages inside initmem are freed and reused later, we saw
> pfn_valid check fail on those pages.
>
>   I think this theoretically happen on a normal kernel. When I check
> min_low_pfn and max_low_pfn calculation in contig.c and discontig.c.
> I found more issues than this.
>
>   1. min_low_pfn and max_low_pfn calculation is inconsistent between
> contig.c and discontig.c,
>   min_low_pfn is calculated as the first page number of boot memmap in
> contig.c (Why? Though this may work at the most of the time, I don't
> think it is the right logic). It is calculated as the lowest physical
> memory page number bypass reserved regions in discontig.c.
>   max_low_pfn is calculated include reserved regions in contig.c. It is
> calculated exclude reserved regions in discontig.c.
>
>   2. If kernel code and data region is happen to be at the begin or the
> end of physical memory, when min_low_pfn and max_low_pfn calculation is
> bypassed kernel code and data, pages in initmem will report bad.
>
>   3. initrd is also in reserved regions, if it is at the begin or at the
> end of physical memory, kernel will refuse to reuse the memory. Because
> the virt_addr_valid check in free_initrd_mem.
>
>   So it is better to fix and clean up those issues.
> Calculate min_low_pfn and max_low_pfn in a consistent way.
>
> Below is the patch, please review and comments
>
> Signed-off-by:  Zou Nan hai <nanhai.zou@intel.com>

I've seen similar problems on a HP rx2620 box using 2.6.20. I managed
to resolve that problem with a patch similar to this one, but then I
realized that the issue I was seeing had been solved already by some
mm-related patch by Bob Picco that got included in 2.6.21-rc1.

So, I suspect that 2.6.21-rc1 and rc2 should work just fine without this patch.

/ magnus

PS. Any comments on the EFI_LOADER_DATA for ELF core header would be
greatly appreciated, I think it is sort of related to this issue as
well.
