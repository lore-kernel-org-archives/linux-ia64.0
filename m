From: Joshua Aas <josha@sgi.com>
Date: Tue, 13 Jul 2004 22:59:46 +0000
Subject: free bootmem feedback patch
Message-Id: <40F46962.4090604@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

NUMA machines with a lot of memory/nodes appear to hang when freeing boot memory, as it can take on the order of 4 minutes. I would like to propose this patch, which adds progress feedback during this time. On a machine with only one memory region (a single node), it prints:

Freeing boot memory... done

It prints more dots every x nodes handled based on the total number of nodes, in such a way that the line never exceeds 80 chars. This way it is possible to see progress being made. I have tested this on a few machines, including a 512p/512GB machine, and it works fine.

Please apply.

Signed-off-by: Josh Aas <josha@sgi.com>

-----------------------------------------------------------------------
--- linux-2.6.7-clean/arch/ia64/mm/init.c       2004-06-16 00:19:22.000000000 -0500
+++ linux-2.6.7/arch/ia64/mm/init.c     2004-07-13 15:25:46.000000000 -0500
@@ -516,7 +516,7 @@ mem_init (void)
        long reserved_pages, codesize, datasize, initsize;
        unsigned long num_pgt_pages;
        pg_data_t *pgdat;
-       int i;
+       int i, pgdat_count;
        static struct kcore_list kcore_mem, kcore_vmem, kcore_kernel;
 
 #ifdef CONFIG_PCI
@@ -540,8 +540,29 @@ mem_init (void)
        kclist_add(&kcore_vmem, (void *)VMALLOC_START, VMALLOC_END-VMALLOC_START);
        kclist_add(&kcore_kernel, _stext, _end - _stext);
 
+       /*
+        * Give nice feedback while freeing boot memory. Each entry in pgdat corresponds to
+        * a memory zone, presumably a node in a NUMA machine. We need nice feedback so that 
+        * machines with lots of nodes/memory don't appear to be hanging.
+        */
+       printk(KERN_INFO "Freeing boot memory...");
+#      define NUM_FREE_BOOT_MEM_MSG_CHAR_COUNT 27 /* 22 + 5 for done message */
+       pgdat_count = 0;
+       i = 0;
        for_each_pgdat(pgdat)
+               pgdat_count++;
+       pgdat_count = (pgdat_count / (80 - NUM_FREE_BOOT_MEM_MSG_CHAR_COUNT)) - 1;
+       for_each_pgdat(pgdat) {
                totalram_pages += free_all_bootmem_node(pgdat);
+               if (i = pgdat_count) {
+                       printk(".");
+                       i = 0;
+               }
+               else {
+                       i++;
+               }
+       }
+       printk(" done\n");
 
        reserved_pages = 0;
        efi_memmap_walk(count_reserved_pages, &reserved_pages);

-----------------------------------------------------------------------

-- 
Josh Aas
Silicon Graphics, Inc. (SGI)
Linux System Software
651-683-3068
