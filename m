From: Michal Hocko <mhocko@kernel.org>
Date: Tue, 03 Mar 2020 09:50:05 +0000
Subject: Re: [PATCH v3 1/7] mm/memory_hotplug: Drop the flags field from struct mhp_restrictions
Message-Id: <20200303095005.GE4380@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200221182503.28317-1-logang@deltatee.com>
 <20200221182503.28317-2-logang@deltatee.com>
In-Reply-To: <20200221182503.28317-2-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, Will Deacon <will@kernel.org>, Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org, David Hildenbrand <david@redhat.com>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dan Williams <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Eric Badger <ebadger@gigaio.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org

On Fri 21-02-20 11:24:57, Logan Gunthorpe wrote:
> This variable is not used anywhere and should therefore be removed
> from the structure.
> 
> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
> Reviewed-by: David Hildenbrand <david@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memory_hotplug.h | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index f4d59155f3d4..69ff3037528d 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -55,11 +55,9 @@ enum {
>  
>  /*
>   * Restrictions for the memory hotplug:
> - * flags:  MHP_ flags
>   * altmap: alternative allocator for memmap array
>   */
>  struct mhp_restrictions {
> -	unsigned long flags;
>  	struct vmem_altmap *altmap;
>  };
>  
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs
