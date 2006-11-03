From: Andy Whitcroft <apw@shadowen.org>
Date: Fri, 03 Nov 2006 10:23:42 +0000
Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <454B18AE.3070603@shadowen.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zou, Nanhai wrote:
> Hi,
> 	This patch should fix the issue.
> 

This patch affects the semantics of the generic code.  To change it
would mean changing all the other architectures to use the new semantics.

add_active_ranges(nid, start, end) is defined to add the range below to
node nid:

	start <= pfn < end

The change in this patch makes it:

	start <= pfn <= end

This will incorrectly add pages to regions registered by all other
architectures.  This implies one of two things:

1) the EFI map is actually defining regions start <= pfn <= end, and
these should be registered as add_active_region(nid, start, end + 1), or

2) the kexec EFI map is being incorrectly filled in using start <= pfn
<= end form.

Looking at (1), it seems that the EFI map actually defines the region
using (start, num_pages) tuples.  These are converted in walk() to
(start, end) where end = start + num_pages.  This implies to me that the
callback is recieving (start, end) where the valid region is start <pfn < end, which is compatible with the add_active_region
implementation.  A quick look at the contig and discontig
implementations they preserve this through.

>>> Index: linux-2.6/arch/ia64/mm/discontig.c
>>> =================================>>> --- linux-2.6.orig/arch/ia64/mm/discontig.c	2006-11-02
>> 16:17:59.000000000 +0900
>>> +++ linux-2.6/arch/ia64/mm/discontig.c	2006-11-02 16:18:03.000000000
>> +0900
>>> @@ -689,6 +689,8 @@
>>> 	arch_sparse_init();
>>>
>>> 	efi_memmap_walk(filter_rsvd_memory, count_node_pages);
>>> +	add_active_range(0, ia64_tpa(_text) >> PAGE_SHIFT,
>>> +	                 (ia64_tpa(_end) -1 ) >> PAGE_SHIFT);

Ok, this is wrong in the sense that you should be adjusting the end up
to the page following the end of the region.  You are rounding the end
down making it start <= pfn <= end.  It should be something like this:

	add_active_range(0, ia64_tpa(_text) >> PAGE_SHIFT,
		(ia64_tpa(_end) + PAGE_SIZE - 1) >> PAGE_SHIFT);

Does this change on its own fix things?

>>>
>>> #ifdef CONFIG_VIRTUAL_MEM_MAP
>>> 	vmalloc_end -= PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *

-apw
