From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 03 Feb 2005 17:06:53 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <200502030906.54144.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, February 3, 2005 12:38 am, Jes Sorensen wrote:
> Jack> ...  + printk(KERN_WARNING "smp_call_function failed for " +
> Jack> "mspec_ipi_visibility! (%i)\n", status); + } + +
> Jack> sn_flush_all_caches((unsigned long)tmp, IA64_GRANULE_SIZE);
>
> Jack> Don't the TLBs need to be flushed before you flush
> Jack> caches. Otherwise, the cpu may reload data via speculation.
>
> Jack> I dont see any TLB flushing of the kernel TLB entries that map
> Jack> the chunks. That needs to be done.  ...
>
> I thought about this one a fair bit after reading your comments and I
> don't think it's an issue. The pages in the kernel's cached mapping
> are identity mapped which means we shouldn't see any tlbs for this,
> which leaves us with just tlbs for pages that have explicitly been
> mapped somewhere - user tlbs should be removed when a process is shot
> down or pages unmapped and vfree() calls flush_tlb_all(). Or, am I
> missing something?

Even identity mapped regions have TLB entries associated with them.  The 
translation registers only cover the code and static data section, afaik.  
When we take a miss on an identity mapped region, the kernel still does an 
'itc', so you'll still need to purge the TLB.

Jesse
