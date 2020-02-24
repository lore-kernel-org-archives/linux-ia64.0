From: David Hildenbrand <david@redhat.com>
Date: Mon, 24 Feb 2020 09:26:10 +0000
Subject: Re: [PATCH v3 6/7] mm/memory_hotplug: Add pgprot_t to mhp_params
Message-Id: <09de85e5-4e66-2d36-2d1c-65f7d341b7f0@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200221182503.28317-1-logang@deltatee.com>
 <20200221182503.28317-7-logang@deltatee.com>
In-Reply-To: <20200221182503.28317-7-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Badger <ebadger@gigaio.com>, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>, Christoph Hellwig <hch@lst.de>

On 21.02.20 19:25, Logan Gunthorpe wrote:
> devm_memremap_pages() is currently used by the PCI P2PDMA code to create
> struct page mappings for IO memory. At present, these mappings are created
> with PAGE_KERNEL which implies setting the PAT bits to be WB. However, on
> x86, an mtrr register will typically override this and force the cache
> type to be UC-. In the case firmware doesn't set this register it is
> effectively WB and will typically result in a machine check exception
> when it's accessed.
> 
> Other arches are not currently likely to function correctly seeing they
> don't have any MTRR registers to fall back on.
> 
> To solve this, provide a way to specify the pgprot value explicitly to
> arch_add_memory().
> 
> Of the arches that support MEMORY_HOTPLUG: x86_64, and arm64 need a simple
> change to pass the pgprot_t down to their respective functions which set
> up the page tables. For x86_32, set the page tables explicitly using
> _set_memory_prot() (seeing they are already mapped). For ia64, s390 and
> sh, reject anything but PAGE_KERNEL settings -- this should be fine,
> for now, seeing these architectures don't support ZONE_DEVICE.
> 
> A check in __add_pages() is also added to ensure the pgprot parameter was
> set for all arches.
> 
> Cc: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
> Acked-by: David Hildenbrand <david@redhat.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

[...]

> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index c5df1b3dada0..30d6c1b8847e 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -56,9 +56,11 @@ enum {
>  /*
>   * Extended parameters for memory hotplug:
>   * altmap: alternative allocator for memmap array (optional)
> + * pgprot: page protection flags to apply to newly added page tables (required)

s/added/created/?



-- 
Thanks,

David / dhildenb
