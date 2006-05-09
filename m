From: Jon Mason <jdmason@us.ibm.com>
Date: Tue, 09 May 2006 23:59:46 +0000
Subject: [PATCH 3/5] mm: create __alloc_bootmem_low_nopanic
Message-Id: <20060509235946.GG22385@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: ak@suse.de, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, mulix@mulix.org

Per Andi Kleen's suggestion in the review of our Calgary IOMMU code, I
tried to use the alloc_bootmem_nopanic when allocing bootmem.
Unfortunately, it needs low mem for our translation tables, so we needed
a new function to do this.

I have updated swiotlb to take advantage of this new function in the
patch following this one.

This patch has been tested individually and cumulatively on x86_64 and
cross-compile tested on IA64.  Since I have no IA64 hardware, any
testing on that platform would be appreciated.

Thanks,
Jon

Signed-off-by: Jon Mason <jdmason@us.ibm.com>

diff -r 235bc05ff8b1 -r 9459ba92585b include/linux/bootmem.h
--- a/include/linux/bootmem.h	Mon May  8 16:17:49 2006
+++ b/include/linux/bootmem.h	Mon May  8 16:30:29 2006
@@ -54,6 +54,9 @@
 extern void * __init __alloc_bootmem_low(unsigned long size,
 					 unsigned long align,
 					 unsigned long goal);
+extern void * __init __alloc_bootmem_low_nopanic(unsigned long size,
+						 unsigned long align,
+						 unsigned long goal);
 extern void * __init __alloc_bootmem_low_node(pg_data_t *pgdat,
 					      unsigned long size,
 					      unsigned long align,
diff -r 235bc05ff8b1 -r 9459ba92585b mm/bootmem.c
--- a/mm/bootmem.c	Mon May  8 16:17:49 2006
+++ b/mm/bootmem.c	Mon May  8 16:30:29 2006
@@ -473,3 +473,16 @@
 {
 	return __alloc_bootmem_core(pgdat->bdata, size, align, goal, LOW32LIMIT);
 }
+
+void * __init __alloc_bootmem_low_nopanic(unsigned long size,
+		unsigned long align, unsigned long goal)
+{
+	bootmem_data_t *bdata;
+	void *ptr;
+
+	list_for_each_entry(bdata, &bdata_list, list)
+		if ((ptr = __alloc_bootmem_core(bdata, size, align, goal,
+						LOW32LIMIT)))
+			return ptr;
+	return NULL;
+}
