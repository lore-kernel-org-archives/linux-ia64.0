From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 10 Apr 2008 15:24:43 +0000
Subject: [PATCH] NUMA memory configuration issue
Message-Id: <47FE313B.2010600@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010000000101020103050700"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010000000101020103050700
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

There is a NUMA memory configuration issue in 2.6.24:

A 2-node machine of ours has got the following memory layout:

Node 0:	0 - 2 Gbytes
Node 0:	4 - 8 Gbytes
Node 1:	8 - 16 Gbytes
Node 0:	16 - 18 Gbytes

"efi_memmap_init()" merges the three last ranges into one.

"register_active_ranges()" is called as follows:

	efi_memmap_walk(register_active_ranges, NULL);

i.e. once for the 4 - 18 Gbytes range. It picks up the node
number from the start address, and registers all the memory for
the node #0.

"register_active_ranges()" should be called as follows to
make sure there is no merged address range at its entry:

	efi_memmap_walk(filter__memory, register_active_ranges);

"filter__memory()" is similar to "filter_rsvd_memory()",
but the reserved memory ranges are not filtered out.

Thanks,

Zoltan Menyhart

Signed-off-by: Zoltan Menyhart, <Zoltan.Menyhart@bull.net>


--------------010000000101020103050700
Content-Type: text/plain;
 name="diff2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="diff2"

diff -Nru linux-2.6.24.4/arch/ia64/kernel/setup.c linux-2.6.24.4-test/arch/ia64/kernel/setup.c
--- linux-2.6.24.4/arch/ia64/kernel/setup.c	2008-03-24 19:49:18.000000000 +0100
+++ linux-2.6.24.4-test/arch/ia64/kernel/setup.c	2008-04-10 15:57:13.000000000 +0200
@@ -178,6 +178,27 @@
 	return 0;
 }
 
+/*
+ * Similar to "filter_rsvd_memory()", but the reserved memory ranges are not filtered out.
+ */
+int __init
+filter__memory (unsigned long start, unsigned long end, void *arg)
+{
+	void (*func)(unsigned long, unsigned long, int);
+
+#if IGNORE_PFN0
+	if (start == PAGE_OFFSET) {
+		printk(KERN_WARNING "warning: skipping physical page 0\n");
+		start += PAGE_SIZE;
+		if (start >= end) return 0;
+	}
+#endif
+	func = arg;
+	if (start < end)
+		call_pernode_memory(__pa(start), end - start, func);
+	return 0;
+}
+
 static void __init
 sort_regions (struct rsvd_region *rsvd_region, int max)
 {
diff -Nru linux-2.6.24.4/arch/ia64/mm/discontig.c linux-2.6.24.4-test/arch/ia64/mm/discontig.c
--- linux-2.6.24.4/arch/ia64/mm/discontig.c	2008-03-24 19:49:18.000000000 +0100
+++ linux-2.6.24.4-test/arch/ia64/mm/discontig.c	2008-04-10 15:58:46.000000000 +0200
@@ -444,7 +444,7 @@
 			mem_data[node].min_pfn = ~0UL;
 		}
 
-	efi_memmap_walk(register_active_ranges, NULL);
+	efi_memmap_walk(filter__memory, register_active_ranges);
 
 	/*
 	 * Initialize the boot memory maps in reverse order since that's
diff -Nru linux-2.6.24.4/arch/ia64/mm/init.c linux-2.6.24.4-test/arch/ia64/mm/init.c
--- linux-2.6.24.4/arch/ia64/mm/init.c	2008-03-24 19:49:18.000000000 +0100
+++ linux-2.6.24.4-test/arch/ia64/mm/init.c	2008-04-10 15:59:05.000000000 +0200
@@ -553,12 +553,10 @@
 #endif /* CONFIG_VIRTUAL_MEM_MAP */
 
 int __init
-register_active_ranges(u64 start, u64 end, void *arg)
+register_active_ranges(u64 start, u64 len, int nid)
 {
-	int nid = paddr_to_nid(__pa(start));
+	u64 end = start + len;
 
-	if (nid < 0)
-		nid = 0;
 #ifdef CONFIG_KEXEC
 	if (start > crashk_res.start && start < crashk_res.end)
 		start = crashk_res.end;
diff -Nru linux-2.6.24.4/include/asm-ia64/meminit.h linux-2.6.24.4-test/include/asm-ia64/meminit.h
--- linux-2.6.24.4/include/asm-ia64/meminit.h	2008-03-24 19:49:18.000000000 +0100
+++ linux-2.6.24.4-test/include/asm-ia64/meminit.h	2008-04-10 15:57:13.000000000 +0200
@@ -35,6 +35,7 @@
 extern void reserve_memory (void);
 extern void find_initrd (void);
 extern int filter_rsvd_memory (unsigned long start, unsigned long end, void *arg);
+extern int filter__memory (unsigned long start, unsigned long end, void *arg);
 extern unsigned long efi_memmap_init(unsigned long *s, unsigned long *e);
 extern int find_max_min_low_pfn (unsigned long , unsigned long, void *);
 
@@ -56,7 +57,7 @@
 
 #define IGNORE_PFN0	1	/* XXX fix me: ignore pfn 0 until TLB miss handler is updated... */
 
-extern int register_active_ranges(u64 start, u64 end, void *arg);
+extern int register_active_ranges(u64 start, u64 len, int nid);
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 # define LARGE_GAP	0x40000000 /* Use virtual mem map if hole is > than this */

--------------010000000101020103050700--
