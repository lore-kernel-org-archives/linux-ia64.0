From: Josh Aas <josha@sgi.com>
Date: Fri, 06 Aug 2004 14:11:50 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <411391A6.1040904@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------000604070109080103090607"
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------000604070109080103090607
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Attached is an improved version of Tony Luck's patch. It shaves another 
~25% off by not using atomic ops to clear the page reserved bits and 
prefetching. Tony - will you sign off on it with me and we'll get this in?

Unfortunately, this still leaves a ~1 minute delay with no indication of 
what is going on for 4TB machines, and ~2 minutes for 8TB. Thus, I'd 
still like to see my progrees indicator patch go in. I am guessing 
memory sizes are only going to get bigger than even 8 TB, and memory is 
not going to get faster at the rate the totals increase (it certainly 
didn't double in speed between 4 and 8 TB installations). Thoughts?

Signed-off-by: Josh Aas <josha@sgi.com>

-Josh

William Lee Irwin III wrote:
> On Tue, Aug 03, 2004 at 12:53:53PM -0500, Josh Aas wrote:
> 
>>Are there any outstanding issues with Tony's second revision of the 
>>free_all_bootmem_core function? Do we still have the problem of making 
>>sure longwork in node_bootmem_map[] corresponds to an order 6 page with 
>>the right physical alignment? The second revision looks good to me. If I 
>>could get some more feedback on it I'll clean up any remaining issues so 
>>it can land sometime soon. I'll post test results (unpatched vs. 
>>patched) on a big machine later this afternoon.
> 
> 
> I think it's fine.
> 
> On Tue, Aug 03, 2004 at 12:53:53PM -0500, Josh Aas wrote:
> 
>>wli - do you still want to see the memory map for my big test machine 
>>(512GB RAM)?
> 
> 
> Sure.
> 
> 
> -- wli

-- 
Josh Aas
Silicon Graphics, Inc. (SGI)
Linux System Software
651-683-3068

--------------000604070109080103090607
Content-Type: text/x-patch;
 name="bootmem3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bootmem3.patch"

--- a/mm/bootmem.c	2004-08-05 15:33:39.000000000 -0500
+++ b/mm/bootmem.c	2004-08-05 16:25:05.000000000 -0500
@@ -259,6 +259,7 @@ static unsigned long __init free_all_boo
 	unsigned long i, count, total = 0;
 	unsigned long idx;
 	unsigned long *map; 
+	int gofast = 0;
 
 	BUG_ON(!bdata->node_bootmem_map);
 
@@ -267,14 +268,32 @@ static unsigned long __init free_all_boo
 	page = virt_to_page(phys_to_virt(bdata->node_boot_start));
 	idx = bdata->node_low_pfn - (bdata->node_boot_start >> PAGE_SHIFT);
 	map = bdata->node_bootmem_map;
+	if (bdata->node_boot_start == 0 ||
+	    ffs(bdata->node_boot_start) - PAGE_SHIFT > ffs(BITS_PER_LONG))
+		gofast = 1;
 	for (i = 0; i < idx; ) {
 		unsigned long v = ~map[i / BITS_PER_LONG];
-		if (v) {
+		if (gofast && v == ~0UL) {
+			int j;
+
+			count += BITS_PER_LONG;
+			(page)->flags &= ~(1UL << PG_reserved);
+			set_page_count(page, 1);
+			for (j = 1; j < BITS_PER_LONG; j++) {
+				if (j + 16 < BITS_PER_LONG) {
+                      			prefetchw(page + j + 16);
+                                }
+				(page + j)->flags &= ~(1UL << PG_reserved);
+			}	
+			__free_pages(page, ffs(BITS_PER_LONG)-1);
+			i += BITS_PER_LONG;
+			page += BITS_PER_LONG;
+		} else if (v) {
 			unsigned long m;
 			for (m = 1; m && i < idx; m<<=1, page++, i++) {
 				if (v & m) {
 					count++;
-					ClearPageReserved(page);
+					(page)->flags &= ~(1UL << PG_reserved);	
 					set_page_count(page, 1);
 					__free_page(page);
 				}

--------------000604070109080103090607--
