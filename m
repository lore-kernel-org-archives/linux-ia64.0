From: Robin Holt <holt@sgi.com>
Date: Sat, 25 Sep 2004 12:40:34 +0000
Subject: Re: Uncached memory allocator for ia64.
Message-Id: <20040925124030.GA23068@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
In-Reply-To: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 23, 2004 at 03:12:40PM -0700, Luck, Tony wrote:
> 
> >I am not sure what will be acceptable at this point.  Should I write
> >an uncached allocator which grabs the granules at boot time before they
> >are ever initialized for cacheable use?  If so, would it be acceptable
> >to just shrink each efi memory map entry by a command line specified
> >size during the efi_memmap_walk callout?  At this point I am so vague
> >on what I should be doing that I am afraid to do much of anything.
> 
> We already make adjustments to the efi memory map (to trim sections to
> granule boundaries) ... but another hack on top of the layers of ugliness
> there already is going to make things worse.  Perhaps someday we can
> delete it all and start over.
> 
> Grabbing your memory out of the map before any of the rest of Linux
> ever sees it sounds to be a good idea ... it avoids wasting memory
> for page structures in mem_map that can only get you into trouble
> if anyone ever looks at them.
> 
> If your allocator only needs a small number of pages from each node, then
> it is possible that you'd be able to feed it the trimmed off scraps
> from incomplete granules, rather than pull a whole granule.  So you
> might want to run your scan through the efi map before anyone else
> messes with it.
> 

I have a first pass at this.  This has not even been compiled yet.
It is only a check to ensure I am on the right track.

Robin

--------   uncached_allocator   --------
Index: linux-2.6/arch/ia64/mm/discontig.c
=================================--- linux-2.6.orig/arch/ia64/mm/discontig.c	2004-09-24 10:47:03.000000000 -0500
+++ linux-2.6/arch/ia64/mm/discontig.c	2004-09-25 07:11:17.000000000 -0500
@@ -544,6 +544,58 @@
 	printk("%d free buffer pages\n", nr_free_buffer_pages());
 }
 
+struct node_uncached_regions {
+        long            paddr;
+        int             uncached_pages;
+        unsigned long   bits[1];        /* Bitmap for managing pages. */
+};
+
+static struct node_uncached_regions       *node_uncached_regions[MAX_COMPACT_NODES];
+
+/* Just for discussion */
+#define UNCACHED_GRANULES_PER_NODE	2
+
+/* I am assuming start is granule aligned.  I need to verify that further. */
+void reserve_uncached_memory(unsigned long start, unsigned long len, void *arg, int nid)
+{
+	void (*func)(unsigned long, unsigned long, int);
+
+	func = arg;
+
+	if ((UNCACHED_GRANULES_PER_NODE = 0) ||
+	    (UNCACHED_GRANULES_PER_NODE * IA64_GRANULE_SIZE >= len)) {
+		(*func)(start, len, nid);
+		return;
+	}
+
+	if (node_uncached_regions[nid] = NULL) {
+		unsigned long grs;
+		int bytes, uncached_pages;
+		struct node_uncached_regions *uncached_region;
+
+		uncached_pages = UNCACHED_GRANULES_PER_NODE * IA64_GRANULE_SIZE / PAGE_SIZE;
+		bytes = sizeof(struct node_uncached_regions) + uncached_pages/8;
+		uncached_region = alloc_bootmem_node(NODE_DATA(nid), bytes);
+		if (uncached_region = NULL) {
+			(*func)(start, len, nid);
+			return;
+		}
+		memset(uncached_region, 0, bytes);
+		uncached_region->paddr = start;
+		uncached_region->uncached_pages = uncached_pages;
+		node_uncached_regions[nid] = uncached_region;
+	}
+
+	if ((node_uncached_regions[nid] != NULL) &&
+	    (node_uncached_regions[nid].paddr = start_address)) {
+		start += UNCACHED_GRANULES_PER_NODE * IA64_GRANULE_SIZE;
+		len -= UNCACHED_GRANULES_PER_NODE * IA64_GRANULE_SIZE;
+	}
+		
+	(*func)(start, len, nid);
+}
+
+
 /**
  * call_pernode_memory - use SRAT to call callback functions with node info
  * @start: physical start of range
@@ -560,7 +612,6 @@
 void call_pernode_memory(unsigned long start, unsigned long len, void *arg)
 {
 	unsigned long rs, re, end = start + len;
-	void (*func)(unsigned long, unsigned long, int);
 	int i;
 
 	start = PAGE_ALIGN(start);
@@ -568,12 +619,10 @@
 	if (start >= end)
 		return;
 
-	func = arg;
-
 	if (!num_node_memblks) {
 		/* No SRAT table, so assume one node (node 0) */
 		if (start < end)
-			(*func)(start, end - start, 0);
+			reserve_uncached_memory(start, end-start, arg, 0);
 		return;
 	}
 
@@ -583,7 +632,7 @@
 			 node_memblk[i].size);
 
 		if (rs < re)
-			(*func)(rs, re - rs, node_memblk[i].nid);
+			reserve_uncached_memory(rs, re - rs, arg, node_memblk[i].nid);
 
 		if (re = end)
 			break;
