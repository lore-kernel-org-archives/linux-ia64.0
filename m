From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 20 Oct 2004 17:17:22 +0000
Subject: [PATCH] use NULL instead of 0
Message-Id: <200410201017.22174.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_i2pdBT2vcKaBXjD"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_i2pdBT2vcKaBXjD
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Clean up a couple of places that were using 0 instead of NULL, which is the 
more proper value.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_i2pdBT2vcKaBXjD
Content-Type: text/plain;
  charset="us-ascii";
  name="sparse-null-cleanups.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sparse-null-cleanups.patch"

===== arch/ia64/mm/discontig.c 1.22 vs edited =====
--- 1.22/arch/ia64/mm/discontig.c	2004-10-19 02:40:14 -07:00
+++ edited/arch/ia64/mm/discontig.c	2004-10-20 09:24:04 -07:00
@@ -681,7 +681,7 @@
 				PAGE_ALIGN(max_low_pfn * sizeof(struct page));
 			vmem_map = (struct page *) vmalloc_end;
 
-			efi_memmap_walk(create_mem_map_page_table, 0);
+			efi_memmap_walk(create_mem_map_page_table, NULL);
 			printk("Virtual mem_map starts at 0x%p\n", vmem_map);
 		}
 
===== arch/ia64/mm/numa.c 1.7 vs edited =====
--- 1.7/arch/ia64/mm/numa.c	2004-02-03 21:35:17 -08:00
+++ edited/arch/ia64/mm/numa.c	2004-10-20 09:23:43 -07:00
@@ -70,7 +70,7 @@
 	memset(sysfs_cpus, 0, sizeof(struct cpu) * NR_CPUS);
 
 	for (i = 0; i < numnodes; i++)
-		if ((err = register_node(&sysfs_nodes[i], i, 0)))
+		if ((err = register_node(&sysfs_nodes[i], i, NULL)))
 			goto out;
 
 	for (i = 0; i < NR_CPUS; i++)

--Boundary-00=_i2pdBT2vcKaBXjD--
