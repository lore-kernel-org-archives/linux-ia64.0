From: Horms <horms@verge.net.au>
Date: Thu, 16 Nov 2006 06:26:00 +0000
Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <20061116062559.GD23146@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 15, 2006 at 04:26:59PM +0000, Mel Gorman wrote:
> On Wed, 15 Nov 2006, Zou, Nanhai wrote:
> >>>>>>Zou Nan hai
> >>>>>>--- a/arch/ia64/mm/discontig.c	2006-11-02 20:09:47.000000000 -0500
> >>>>>>+++ b/arch/ia64/mm/discontig.c	2006-11-02 19:57:27.000000000 -0500
> >>>>>>@@ -21,6 +21,7 @@
> >>>>>> #include <linux/acpi.h>
> >>>>>> #include <linux/efi.h>
> >>>>>> #include <linux/nodemask.h>
> >>>>>>+#include <linux/kexec.h>
> >>>>>> #include <asm/pgalloc.h>
> >>>>>> #include <asm/tlb.h>
> >>>>>> #include <asm/meminit.h>
> >>>>>>@@ -653,8 +654,6 @@ void call_pernode_memory(unsigned long s
> >>>>>> static __init int count_node_pages(unsigned long start, unsigned long
> >>len,
> >>>>>>int node)
> >>>>>> {
> >>>>>> 	unsigned long end = start + len;
> >>>>>>-
> >>>>>>-	add_active_range(node, start >> PAGE_SHIFT, end >> PAGE_SHIFT);
> >>>>>> 	mem_data[node].num_physpages += len >> PAGE_SHIFT;
> >>>>>> 	if (start <= __pa(MAX_DMA_ADDRESS))
> >>>>>> 		mem_data[node].num_dma_physpages +> >>>>>>@@ -669,7 +668,31 @@ static __init int count_node_pages(unsig
> >>>>>>
> >>>>>> 	return 0;
> >>>>>> }
> >>>>>>+static __init int add_active_range_wrapper(unsigned long start,
> >>>>>>+		unsigned long len, int node)
> >>>>>>+{
> >>>>>>+	unsigned long end = start + len;
> >>>>>>+	add_active_range(node, start >> PAGE_SHIFT, end >> PAGE_SHIFT);
> >>>>>>+	return 0;
> >>>>>>+}
> >>>>>>
> >>>>
> >>>>The function name doesn't really tell the reader what it's meant to be
> >>>>doing. Something like register_active_ranges() might be a bit better.
> >>>>
> >>>Ok.
> >>>>>>+static int __init
> >>>>>>+filter_pernode_memory (unsigned long start, unsigned long end, void
> >>*arg)
> >>>>>>+{
> >>>>>>+	void (*func)(unsigned long, unsigned long, int);
> >>>>>>+	func = arg;
> >>>>>>+
> >>>>>>+#ifdef CONFIG_KEXEC
> >>>>>>+	if (start > crashk_res.start && start < crashk_res.end)
> >>>>>>+		start = max(start, crashk_res.end);
> >>>>>>+	if (end > crashk_res.start && end < crashk_res.end)
> >>>>>>+		end = min(end, crashk_res.start);

[snip]

> As you say, it's not clear why the normal discontig kernel boots because the 
> regions should have been skipped by add_active_range().
> 
> Try your patch and see does it work for kdump. It should work fine in the 
> normal case because at very worst, slightly more memmap is allocated than is 
> strictly required.

I tried the above patch and kdump does indeed work, whereas without it
it does not. The pfn ranges also look correct on my setup with the above
patch.


-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

