From: Robin Holt <holt@sgi.com>
Date: Sat, 26 Feb 2005 14:26:27 +0000
Subject: [Patch 2/3] Free off node page tables instead of placing on the quicklist.
Message-Id: <20050226142627.GF10965@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
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

On and sn2 machine, there was a slight improvement which is possibly
due to pages from other nodes trapped on the test node before starting
the run.  I did not investigate further.

Signed-off-by: Robin Holt <holt@sgi.com>

Before:
Process fork+exit: 184.2333 microseconds
Process fork+exit: 184.7241 microseconds
Process fork+exit: 184.0333 microseconds
Process fork+exit: 185.6667 microseconds
Process fork+exit: 185.4000 microseconds
Process fork+exit: 184.6000 microseconds
Process fork+exit: 184.1333 microseconds
Process fork+exit: 184.3667 microseconds
Process fork+exit: 184.7667 microseconds
Process fork+exit: 183.7097 microseconds
Process fork+execve: 188.5172 microseconds
Process fork+execve: 190.0000 microseconds
Process fork+execve: 189.7931 microseconds
Process fork+execve: 190.2414 microseconds
Process fork+execve: 190.5517 microseconds
Process fork+execve: 190.5172 microseconds
Process fork+execve: 191.0000 microseconds
Process fork+execve: 189.9310 microseconds
Process fork+execve: 191.2069 microseconds
Process fork+execve: 190.8276 microseconds

After:
Process fork+exit: 180.8065 microseconds
Process fork+exit: 182.4286 microseconds
Process fork+exit: 184.0333 microseconds
Process fork+exit: 183.3226 microseconds
Process fork+exit: 182.6333 microseconds
Process fork+exit: 183.4000 microseconds
Process fork+exit: 183.4667 microseconds
Process fork+exit: 182.1935 microseconds
Process fork+exit: 182.0667 microseconds
Process fork+exit: 183.7742 microseconds
Process fork+execve: 188.1667 microseconds
Process fork+execve: 188.6071 microseconds
Process fork+execve: 187.5333 microseconds
Process fork+execve: 188.9286 microseconds
Process fork+execve: 188.4333 microseconds
Process fork+execve: 187.6000 microseconds
Process fork+execve: 187.6333 microseconds
Process fork+execve: 188.5333 microseconds
Process fork+execve: 187.9655 microseconds
Process fork+execve: 186.3667 microseconds




 pgalloc.h |   10 ++++++++++
 1 files changed, 10 insertions(+)


Index: linux-2.6/include/asm-ia64/pgalloc.h
=================================--- linux-2.6.orig/include/asm-ia64/pgalloc.h	2005-02-25 14:40:02.208212833 -0600
+++ linux-2.6/include/asm-ia64/pgalloc.h	2005-02-25 15:10:32.929665721 -0600
@@ -49,6 +49,16 @@
 static inline void
 pgtable_quicklist_free (void *pgtable_entry)
 {
+#ifdef CONFIG_NUMA
+	int pg_node;
+
+	pg_node = page_zone(virt_to_page(pgtable_entry))->zone_pgdat->node_id;
+	if (pg_node != numa_node_id()) {
+		free_page((unsigned long) pgtable_entry);
+		return;
+	}
+#endif
+
 	preempt_disable();
 	*(unsigned long *)pgtable_entry = (unsigned long) local_cpu_data->pgtable_quicklist;
 	local_cpu_data->pgtable_quicklist = (unsigned long *) pgtable_entry;
