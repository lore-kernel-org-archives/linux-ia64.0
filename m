From: Russ Anderson <rja@sgi.com>
Date: Mon, 17 Jan 2005 20:03:30 +0000
Subject: [patch] MCA contig memory fix
Message-Id: <200501172003.j0HK3USd3011609@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ashok Raj uncovered a problem while testing the MCA code
on a tiger box with contig memory.  The virtual address 
was getting saved instead of the physical address of the
MCA save area.  This patch fixes that problem.

Signed-off-by: Russ Anderson <rja@sgi.com>

-------------------------------------------------------
Index: 2.6.11/arch/ia64/mm/contig.c
=================================--- 2.6.11.orig/arch/ia64/mm/contig.c	2005-01-10 15:39:36.531197800 -0600
+++ 2.6.11/arch/ia64/mm/contig.c	2005-01-14 14:15:32.800575500 -0600
@@ -195,7 +195,7 @@
 			__per_cpu_offset[cpu] = (char *) cpu_data - __per_cpu_start;
 			cpu_data += PERCPU_PAGE_SIZE;
 			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
-			__per_cpu_mca[cpu] = (unsigned long)mca_data;
+			__per_cpu_mca[cpu] = (unsigned long)__pa(mca_data);
 			mca_data += PERCPU_MCA_SIZE;
 		}
 	}

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
