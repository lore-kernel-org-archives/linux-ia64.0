From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 07 Jan 2005 00:19:08 +0000
Subject: [PATCH] long line, codingstyle, & include cleanups for numa.c
Message-Id: <200501061619.08795.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_8Vd3Bj1UoiVKYOm"
List-Id: <linux-ia64.vger.kernel.org>
References: <200501061609.20040.jbarnes@engr.sgi.com>
In-Reply-To: <200501061609.20040.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org

--Boundary-00=_8Vd3Bj1UoiVKYOm
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Remove a bunch of unused #includes, fix long lines, and fixup codingstyle in 
numa.c.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_8Vd3Bj1UoiVKYOm
Content-Type: text/plain;
  charset="us-ascii";
  name="numa-cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="numa-cleanup.patch"

===== arch/ia64/mm/numa.c 1.9 vs edited =====
--- 1.9/arch/ia64/mm/numa.c	2004-10-28 00:36:29 -07:00
+++ edited/arch/ia64/mm/numa.c	2005-01-06 16:00:32 -08:00
@@ -6,21 +6,14 @@
  * This file contains NUMA specific variables and functions which can
  * be split away from DISCONTIGMEM and are used on NUMA machines with
  * contiguous memory.
- * 
+ *
  *                         2002/08/07 Erich Focht <efocht@ess.nec.de>
  */
-
-#include <linux/config.h>
-#include <linux/cpu.h>
-#include <linux/kernel.h>
-#include <linux/mm.h>
-#include <linux/node.h>
-#include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/numa.h>
+#include <linux/threads.h>
 #include <asm/mmzone.h>
 #include <asm/numa.h>
 
-
 /*
  * The following structures are usually initialized by ACPI or
  * similar mechanisms and describe the NUMA characteristics of the machine.
@@ -35,15 +28,15 @@
 u8 numa_slit[MAX_NUMNODES * MAX_NUMNODES];
 
 /* Identify which cnode a physical address resides on */
-int
-paddr_to_nid(unsigned long paddr)
+int paddr_to_nid(unsigned long paddr)
 {
-	int	i;
+	int i;
 
 	for (i = 0; i < num_node_memblks; i++)
 		if (paddr >= node_memblk[i].start_paddr &&
 		    paddr < node_memblk[i].start_paddr + node_memblk[i].size)
 			break;
 
-	return (i < num_node_memblks) ? node_memblk[i].nid : (num_node_memblks ? -1 : 0);
+	return (i < num_node_memblks) ?	node_memblk[i].nid :
+		(num_node_memblks ? -1 : 0);
 }

--Boundary-00=_8Vd3Bj1UoiVKYOm--
