From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 12 Oct 2006 22:18:37 +0000
Subject: Re: [PATCH 4/4] vmm: Use a static memory map
Message-Id: <20061012221837.GA10186@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061012191828.21498.95831.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061012191828.21498.95831.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 12, 2006 at 12:18:28PM -0700, Christoph Lameter wrote:

Like Ken, I think this patch has much to offer ... but there are
some pitfalls (or at least we should be aware that the tradeoffs
could be somewhat worse than advertized here).

> Supported memory: 50 bits = 1 Petabyte

In _current_ implementations ... architecturally this could
be more in future implementations.  Each bit added here
doubles the size needed for virtual memory map.

> Amount of page structs needed for 16k pagesize:

We support page sizes down to 4k ... so potentially multiply
the following numbers by 4. (On the upside divide by 4 for
64K pagesize).

> 50 address bits - 14 page bits = 36 bits.
> This is 128 billion or 128 * 2^30
> 
> Size of struct page is 7 words = 56 bytes.
> Round to next power of two = 64 bytes / 6 bits.

Current size ... future Linux extensions could add extra fields
(though the trend seems to be to remove stuff, this is *much*
slimmer than the page structure of five years ago, less than
half the size IIRC!)

> Amount of virtual address space needed is:
> 36 pfn bits + 6 bits = 42 bits = 8 Terabyte.
> 
> So, the size of the virtual memory map is always less than 8 Terabyte.

32 TB for 4K pagesize using current physical address space limit and
existing Linux sizeof(struct page)

> I think its reasonable to take these 8 Terabyte away from the 128 Terabyte
> that we currently reserve for support for VMALLOC space.

Does it still sound as good to take 32/128 TB?  What if the physical
address space gets another 4 bits ... even with a 16K pagesize you'd
need the whole 128TB.

But 128TB is a somewhat arbitrary limit for VMALLOC space ... there's
plenty more unused space in region 5 if we needed to make it bigger.

> Advantages:
> - virt_to_page, page_address, pfn_to_page, page_to_pfn become simple address
>   calculations without a memory reference.
> - We no longer tinker around with VMALLOC_END. It is a true constant now.
> - virt_to_page(), page_address(), pfn_to_page(), page_to_pfn() do not need any
>   bootstrapping but can be used right waway.
> - The plan is to further generalize the virtual mem map support
>   in the Linux kernel. With this patch the virtual memory map
>   is more independent from VMALLOC.

All good stuff.

> - This patch will enable later patches to move the virtual memory map into
>   another region with a larger page size. Larger page sizes will reduce
>   TLB pressure.

It may be hard to use very large pagesize (to avoid wasting memory
on page stuctures for pages that don't exist at the edges of each
discontigous block of pages) ... but the benefits may be worth a little
waste here.

-Tony
