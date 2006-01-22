From: Robin Holt <holt@sgi.com>
Date: Sun, 22 Jan 2006 13:52:42 +0000
Subject: Re: ia64: allnoconfig build fails
Message-Id: <20060122135242.GA25709@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601210320.05771.len.brown@intel.com>
In-Reply-To: <200601210320.05771.len.brown@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I think I used git bisect correctly and narrowed it down to
this commit:

1be7d9935b9c7fb9bd5964bfaf3ac543381277db

I would guess it is related to the change in pfn_valid around:

-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
# define pfn_valid(pfn) (((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
# define page_to_pfn(page) ((unsigned long) (page - mem_map))
# define pfn_to_page(pfn) (mem_map + (pfn))
-#else
+#elif defined(CONFIG_DISCONTIGMEM)

Thanks,
Robin Holt

On Sat, Jan 21, 2006 at 01:11:38PM -0800, Luck, Tony wrote:
> > Need to wrap huge_zonelist function with CONFIG_HUGETLBFS.
> >
> >
> > Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
> 
> Fixes this new problem ... allnoconfig still fails for me
> with lots of:
> 
>      undefined reference to `vmem_map'
> 
> and a few
> 
>      undefined reference to `ia64_pfn_valid'
> 
> but these have been around for a while.
> 
> -Tony
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
