From: Jack Steiner <steiner@sgi.com>
Date: Thu, 18 Dec 2003 19:14:42 +0000
Subject: [PATCH] - linux/arch/ia64/kernel/acpi.c
Message-Id: <marc-linux-ia64-107177513519511@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The code in acpi_numa_memory_affinity_init that sorts the node_memblk
can overrun the array & clobber the memory that follows the end 
of the array. The error will be seen only on systems that fill
the node_memblk array and only if SAL doesnt sort the entries
in the SRAT. 



--- linux.base/arch/ia64/kernel/acpi.c	Wed Nov 26 14:44:07 2003
+++ linux/arch/ia64/kernel/acpi.c	Thu Dec 18 13:10:03 2003
@@ -413,7 +413,7 @@
 			break;
 	}
 	if (p < pend) {
-		for (q = pend; q >= p; q--)
+		for (q = pend-1; q >= p; q--)
 			*(q + 1) = *q;
 	}
 	p->start_paddr = paddr;
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


