From: Robin Holt <holt@sgi.com>
Date: Thu, 03 Mar 2005 21:27:49 +0000
Subject: [Patch 2/3] Free page tables belonging to remote nodes.
Message-Id: <20050303212749.GB947@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050302184103.GC16517@lnx-holt.americas.sgi.com>
In-Reply-To: <20050302184103.GC16517@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony,

This patch is simple but necessary for large numa configurations.
It simply ensures that only pages from the local node are added to a
cpus quicklist.  This prevents the trapping of pages on a remote nodes
quicklist by starting a process, touching a large number of pages to
fill pmd and pte entries, migrating to another node, and then unmapping
or exiting.  With those conditions, the pages get trapped and if the
machine has more than 100 nodes of the same size, the calculation of
the pgtable high water mark will be larger than any single node so page
table cache flushing will never occur.

I ran lmbench lat_proc fork and lat_proc exec on a zx1 with and without
this patch and did not notice any change.

On an sn2 machine, there was a slight improvement which is possibly
due to pages from other nodes trapped on the test node before starting
the run.  I did not investigate further.

Signed-off-by: Robin Holt <holt@sgi.com>

Before:
Process fork+exit: 186.7037 microseconds
Process fork+execve: 699.0000 microseconds
Process fork+/bin/sh -c: 2960.0000 microseconds

After:
Process fork+exit: 182.2333 microseconds
Process fork+execve: 692.7500 microseconds
Process fork+/bin/sh -c: 2905.5000 microseconds

 pgalloc.h |    7 +++++++
 1 files changed, 7 insertions(+)

Index: linux-2.6/include/asm-ia64/pgalloc.h
=================================--- linux-2.6.orig/include/asm-ia64/pgalloc.h	2005-03-02 17:40:38.500562862 -0600
+++ linux-2.6/include/asm-ia64/pgalloc.h	2005-03-03 06:54:13.068518897 -0600
@@ -66,6 +66,13 @@
 static inline void
 pgtable_quicklist_free (void *pgtable_entry)
 {
+#ifdef CONFIG_NUMA
+	if (unlikely(page_to_nid(virt_to_page(pgtable_entry)) != numa_node_id())) {
+		free_page((unsigned long) pgtable_entry);
+		return;
+	}
+#endif
+
 	preempt_disable();
 	*(unsigned long *)pgtable_entry = (unsigned long) pgtable_quicklist;
 	pgtable_quicklist = (unsigned long *) pgtable_entry;
