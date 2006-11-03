From: Zou Nan hai <nanhai.zou@intel.com>
Date: Fri, 03 Nov 2006 10:06:45 +0000
Subject: RE: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <1162548405.3378.8.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2006-11-03 at 17:27, Mel Gorman wrote:
> On Fri, 3 Nov 2006, Zou, Nanhai wrote:
> 
> > Hi,
> > 	This patch should fix the issue.
> >
> 
> It would appear to fix the issue for IA64 but you are blotting over the 
> issue that the map is reporting a one page hole. On arches with really 
> adjacent regions that are getting merged, the regions will appear to 
> overlap by one page. What can happen is something like this
> 
> PFN ranges for nodes
> Node 1: 0 -> 1000
> Node 0: 1000 -> 2000
> 
Hi,
 But the patch Andy and you are commenting is not my patch...., It was
in the previous thread. 
My patch was in the attachment.....

 Sorry for using outlook to send that patch as attachment, my Linux box
was not accessable at the time when I was posting the patch.
 I post the patch again, and copy the discription from my previous mail.

When ia64 kernel is configured as discontinuous memory model, 
active_pages are added through efi_memmap_walk(filter_rsvd_memory, count_node_pages). 
filter_rsvd_memory  will filter out all regions in rsvd_regions include 
- boot param
- mem map
- initrd
- command line
- **** kernel code and data ***
- kernel map built from efi memmap
- crash kernel reserved region
So the kernel code and data is excluded even without kdump support,
check /proc/iomem and dmesg for early_node_data can verify that.
But magically, the first kernel boots happily without any complain...,
I guess that is related to the init value in memmap. 

This patch use another filter to add_acvitive_pages, only exclude crash kernel reserved region if CONFIG_KEXEC is on.

Thanks
Zou Nan hai
--- a/arch/ia64/mm/discontig.c	2006-11-02 20:09:47.000000000 -0500
+++ b/arch/ia64/mm/discontig.c	2006-11-02 19:57:27.000000000 -0500
@@ -21,6 +21,7 @@
 #include <linux/acpi.h>
 #include <linux/efi.h>
 #include <linux/nodemask.h>
+#include <linux/kexec.h>
 #include <asm/pgalloc.h>
 #include <asm/tlb.h>
 #include <asm/meminit.h>
@@ -653,8 +654,6 @@ void call_pernode_memory(unsigned long s
 static __init int count_node_pages(unsigned long start, unsigned long len, int node)
 {
 	unsigned long end = start + len;
-
-	add_active_range(node, start >> PAGE_SHIFT, end >> PAGE_SHIFT);
 	mem_data[node].num_physpages += len >> PAGE_SHIFT;
 	if (start <= __pa(MAX_DMA_ADDRESS))
 		mem_data[node].num_dma_physpages +@@ -669,7 +668,31 @@ static __init int count_node_pages(unsig
 
 	return 0;
 }
+static __init int add_active_range_wrapper(unsigned long start, 
+		unsigned long len, int node)
+{
+	unsigned long end = start + len;
+	add_active_range(node, start >> PAGE_SHIFT, end >> PAGE_SHIFT);
+	return 0;
+}
 
+static int __init
+filter_pernode_memory (unsigned long start, unsigned long end, void *arg)
+{
+	void (*func)(unsigned long, unsigned long, int);
+	func = arg;
+
+#ifdef CONFIG_KEXEC
+	if (start > crashk_res.start && start < crashk_res.end)
+		start = max(start, crashk_res.end);
+	if (end > crashk_res.start && end < crashk_res.end)
+		end = min(end, crashk_res.start);
+#endif
+	if (start < end)
+		call_pernode_memory(__pa(start), end - start, func);
+
+	return 0;
+}
 /**
  * paging_init - setup page tables
  *
@@ -689,6 +712,7 @@ void __init paging_init(void)
 	arch_sparse_init();
 
 	efi_memmap_walk(filter_rsvd_memory, count_node_pages);
+	efi_memmap_walk(filter_pernode_memory, add_active_range_wrapper);
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 	vmalloc_end -= PAGE_ALIGN(ALIGN(max_low_pfn, MAX_ORDER_NR_PAGES) *



