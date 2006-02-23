From: Jack Steiner <steiner@sgi.com>
Date: Thu, 23 Feb 2006 19:16:44 +0000
Subject: [PATCH] - Make number of TIO nodes configurable
Message-Id: <20060223191644.GA16261@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Make the limit for the number of TIO nodes a function of the number
of C/M nodes in the system instead of a hardcoded constant.  The
number of TIO nodes should be the same as the number of C/M nodes.
	
	Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/include/asm-ia64/sn/arch.h
=================================--- linux.orig/include/asm-ia64/sn/arch.h	2006-02-15 12:32:56.000000000 -0600
+++ linux/include/asm-ia64/sn/arch.h	2006-02-23 13:10:57.137540810 -0600
@@ -31,7 +31,8 @@
  * 	to ACPI3.0, this limit will be removed. The notion of "compact nodes"
  * 	should be deleted and TIOs should be included in MAX_NUMNODES.
  */
-#define MAX_COMPACT_NODES	512
+#define MAX_TIO_NODES		MAX_NUMNODES
+#define MAX_COMPACT_NODES	(MAX_NUMNODES + MAX_TIO_NODES)
 
 /*
  * Maximum number of nodes in all partitions and in all coherency domains.
