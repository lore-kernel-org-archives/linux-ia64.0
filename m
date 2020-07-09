From: David Hildenbrand <david@redhat.com>
Date: Thu, 09 Jul 2020 09:10:36 +0000
Subject: Re: [PATCH v3 3/6] sh/mm: use default dummy memory_add_physaddr_to_nid()
Message-Id: <f1a172b2-80c2-1ec7-483f-f3fba761ccb0@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200709020629.91671-1-justin.he@arm.com>
 <20200709020629.91671-4-justin.he@arm.com>
In-Reply-To: <20200709020629.91671-4-justin.he@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jia He <justin.he@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Chuhong Yuan <hslester96@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Masahiro Yamada <masahiroy@kernel.org>, Michal Hocko <mhocko@suse.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Jonathan Cameron <Jonathan.Cameron@Huawei.com>, Kaly Xin <Kaly.Xin@arm.com>

On 09.07.20 04:06, Jia He wrote:
> After making default memory_add_physaddr_to_nid in mm/memory_hotplug,
> there is no use to define a similar one in arch specific directory.
> 
> Signed-off-by: Jia He <justin.he@arm.com>
> ---
>  arch/sh/mm/init.c | 9 ---------
>  1 file changed, 9 deletions(-)
> 
> diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
> index a70ba0fdd0b3..f75932ba87a6 100644
> --- a/arch/sh/mm/init.c
> +++ b/arch/sh/mm/init.c
> @@ -430,15 +430,6 @@ int arch_add_memory(int nid, u64 start, u64 size,
>  	return ret;
>  }
>  
> -#ifdef CONFIG_NUMA
> -int memory_add_physaddr_to_nid(u64 addr)
> -{
> -	/* Node 0 for now.. */
> -	return 0;
> -}
> -EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
> -#endif
> -
>  void arch_remove_memory(int nid, u64 start, u64 size,
>  			struct vmem_altmap *altmap)
>  {
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 
Thanks,

David / dhildenb
