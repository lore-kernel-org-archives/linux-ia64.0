From: dcn@sgi.com (Dean Nelson)
Date: Mon, 04 Apr 2005 12:14:01 +0000
Subject: [PATCH] convert AMO address found in XPC's reserved page
Message-Id: <42512F89.mailxES41PPV6D@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch detects the existence of an uncached physical AMO address setup
by EFI's XPBOOT (SGI) and converts it to an uncached virtual AMO address.
Depends on a patch submitted on 23 March 2005 with the subject of:
    [PATCH 2/3] SGI Altix cross partition functionality (2nd revision)

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/arch/ia64/sn/kernel/xpc_partition.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_partition.c	2005-03-31 12:34:54.109073128 -0600
+++ linux-2.6/arch/ia64/sn/kernel/xpc_partition.c	2005-04-01 08:00:41.669311390 -0600
@@ -187,8 +187,8 @@
 		if (amos_page = NULL) {
 			dev_err(xpc_part, "can't allocate page of AMOs\n");
 			return NULL;
-		}      
-		
+		}
+
 		/*
 		 * Open up AMO-R/W to cpu.  This is done for Shub 1.1 systems
 		 * when xpc_allow_IPI_ops() is called via xpc_hb_init().
@@ -204,6 +204,19 @@
 				return NULL;
 			}
 		}
+	} else if (!IS_AMO_ADDRESS((u64) amos_page)) {
+		/*
+		 * EFI's XPBOOT can also set amos_page in the reserved page,
+		 * but it happens to leave it as an uncached physical address
+		 * and we need it to be an uncached virtual, so we'll have to
+		 * convert it.
+		 */
+		if (!IS_AMO_PHYS_ADDRESS((u64) amos_page)) {
+			dev_err(xpc_part, "previously used amos_page address "
+				"is bad = 0x%p\n", (void *) amos_page);
+			return NULL;
+		}
+		amos_page = (AMO_t *) TO_AMO((u64) amos_page);
 	}
 
 	memset(xpc_vars, 0, sizeof(struct xpc_vars));
@@ -944,7 +957,7 @@
 
 /*
  * Given a partid, get the nasids owned by that partition from the
- * remote partitions reserved page.
+ * remote partition's reserved page.
  */
 enum xpc_retval
 xpc_initiate_partid_to_nasids(partid_t partid, void *nasid_mask)
Index: linux-2.6/include/asm-ia64/sn/addrs.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/addrs.h	2005-03-21 09:33:28.550752495 -0600
+++ linux-2.6/include/asm-ia64/sn/addrs.h	2005-04-04 06:48:46.173527324 -0500
@@ -136,6 +136,7 @@
  */
 #define CAC_BASE		(CACHED   | AS_CAC_SPACE)
 #define AMO_BASE		(UNCACHED | AS_AMO_SPACE)
+#define AMO_PHYS_BASE		(UNCACHED_PHYS | AS_AMO_SPACE)
 #define GET_BASE		(CACHED   | AS_GET_SPACE)
 
 /*
@@ -160,6 +161,13 @@
 
 
 /*
+ * Macros to test for address type.
+ */
+#define IS_AMO_ADDRESS(x)	(((u64)(x) & (REGION_BITS | AS_MASK)) = AMO_BASE)
+#define IS_AMO_PHYS_ADDRESS(x)	(((u64)(x) & (REGION_BITS | AS_MASK)) = AMO_PHYS_BASE)
+
+
+/*
  * The following definitions pertain to the IO special address
  * space.  They define the location of the big and little windows
  * of any given node.
