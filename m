From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 25 Jun 2004 16:12:16 +0000
Subject: [PATCH] trashing bootmem on non-NUMA boxes
Message-Id: <1088179936.4106.15.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   call_pernode_memory() is rounding memory regions to page boundaries,
but in the non-NUMA case, it's incorrectly passing the rounded start and
the original length.  Any reserved memory regions sitting beyond a
memory region that isn't nicely aligned is potentially at risk for
getting freed and trashed.  This is a fairly nasty bug that can bite in
very hard to find ways.  In my case, the EFI memory map was getting
overwritten, causing the ACPI methods to access chipset registers
cachable instead of uncachable.  It could potentially be causing some of
the random hangs and strange behavior we're seeing lately.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>

=== arch/ia64/mm/discontig.c 1.15 vs edited ==--- 1.15/arch/ia64/mm/discontig.c	Thu Jun 24 02:55:57 2004
+++ edited/arch/ia64/mm/discontig.c	Fri Jun 25 09:39:20 2004
@@ -549,7 +549,7 @@
 	if (!num_node_memblks) {
 		/* No SRAT table, so assume one node (node 0) */
 		if (start < end)
-			(*func)(start, len, 0);
+			(*func)(start, end - start, 0);
 		return;
 	}
 


