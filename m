From: Martin Hicks <mort@wildopensource.com>
Date: Mon, 25 Aug 2003 13:56:15 +0000
Subject: [patch] paddr_to_nid fixup
Message-Id: <marc-linux-ia64-106184707622424@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


David,

Here is a small patch for paddr_to_nid().  This fix is already in 2.4
and is used in the case where a NUMA kernel is running on a machine
without a SRAT ACPI table.  Without this patch the node info is not
correctly located.

mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1149  -> 1.1150 
#	 arch/ia64/mm/numa.c	1.2     -> 1.3    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/21	mort@green.i.bork.org	1.1150
# This fixes paddr_to_nid() for the case where there is no
# ACPI SRAT table, and thus num_memblks = 0.
# --------------------------------------------
#
diff -Nru a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
--- a/arch/ia64/mm/numa.c	Thu Aug 21 12:02:28 2003
+++ b/arch/ia64/mm/numa.c	Thu Aug 21 12:02:28 2003
@@ -43,5 +43,5 @@
 		    paddr < node_memblk[i].start_paddr + node_memblk[i].size)
 			break;
 
-	return (i < num_memblks) ? node_memblk[i].nid : -1;
+	return (i < num_memblks) ? node_memblk[i].nid : (num_memblks ? -1 : 0);
 }
