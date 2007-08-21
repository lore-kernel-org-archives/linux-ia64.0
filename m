From: Russ Anderson <rja@sgi.com>
Date: Tue, 21 Aug 2007 21:45:12 +0000
Subject: [patch] Fix Altix BTE error return status
Message-Id: <200708212145.l7LLjCGn154815582@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Fix Altix BTE error return status

The Altix shub2 BTE error detail bits are in a different location
than on shub1.  The current code does not take this into account
resulting in all shub2 BTE failures mapping to "unknown".

This patch reads the error detail bits from the proper location,
so the correct BTE failure reason is returned for both shub1 
and shub2.  

Signed-off-by: Russ Anderson <rja@sgi.com>

---
 arch/ia64/sn/kernel/bte.c       |    4 ++--
 arch/ia64/sn/kernel/bte_error.c |    8 ++++++--
 include/asm-ia64/sn/bte.h       |   31 ++++++++++++++++++++++++++++++-
 include/asm-ia64/sn/xp.h        |   27 +++++++++++++++++++++++++--
 include/asm-ia64/sn/xpc.h       |    8 +++++++-
 5 files changed, 70 insertions(+), 8 deletions(-)

Index: test/arch/ia64/sn/kernel/bte.c
=================================--- test.orig/arch/ia64/sn/kernel/bte.c	2007-08-20 13:23:34.150957556 -0500
+++ test/arch/ia64/sn/kernel/bte.c	2007-08-21 11:46:16.839696594 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2006 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2007 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 #include <linux/module.h>
@@ -227,7 +227,7 @@ retry_bteop:
 		     BTE_LNSTAT_LOAD(bte), *bte->most_rcnt_na));
 
 	if (transfer_stat & IBLS_ERROR) {
-		bte_status = transfer_stat & ~IBLS_ERROR;
+		bte_status = BTE_GET_ERROR_STATUS(transfer_stat);
 	} else {
 		bte_status = BTE_SUCCESS;
 	}
Index: test/include/asm-ia64/sn/bte.h
=================================--- test.orig/include/asm-ia64/sn/bte.h	2007-08-20 13:23:38.723522158 -0500
+++ test/include/asm-ia64/sn/bte.h	2007-08-21 11:46:16.863699511 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2006 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2007 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -150,6 +150,35 @@ typedef enum {
 	BTEFAIL_NOTAVAIL,	/* BTE not available */
 } bte_result_t;
 
+#define BTEFAIL_SH2_RESP_SHORT	0x1	/* bit 000001 */
+#define BTEFAIL_SH2_RESP_LONG	0x2	/* bit 000010 */
+#define BTEFAIL_SH2_RESP_DSP	0x4	/* bit 000100 */
+#define BTEFAIL_SH2_RESP_ACCESS	0x8	/* bit 001000 */
+#define BTEFAIL_SH2_CRB_TO	0x10	/* bit 010000 */
+#define BTEFAIL_SH2_NACK_LIMIT	0x20	/* bit 100000 */
+#define BTEFAIL_SH2_ALL		0x3F	/* bit 111111 */
+
+#define	BTE_ERR_BITS	0x3FUL
+#define	BTE_ERR_SHIFT	36
+#define BTE_ERR_MASK	(BTE_ERR_BITS << BTE_ERR_SHIFT)
+
+#define BTE_ERROR_RETRY(value)						\
+	(is_shub2() ? (value != BTEFAIL_SH2_CRB_TO)			\
+		: (value != BTEFAIL_TOUT))
+
+/*
+ * On shub1 BTE_ERR_MASK will always be false, so no need for is_shub2()
+ */
+#define BTE_SHUB2_ERROR(_status)					\
+	((_status & BTE_ERR_MASK) 					\
+	   ? (((_status >> BTE_ERR_SHIFT) & BTE_ERR_BITS) | IBLS_ERROR) \
+	   : _status)
+
+#define BTE_GET_ERROR_STATUS(_status)					\
+	(BTE_SHUB2_ERROR(_status) & ~IBLS_ERROR)
+
+#define BTE_VALID_SH2_ERROR(value)					\
+	((value >= BTEFAIL_SH2_RESP_SHORT) && (value <= BTEFAIL_SH2_ALL))
 
 /*
  * Structure defining a bte.  An instance of this
Index: test/include/asm-ia64/sn/xpc.h
=================================--- test.orig/include/asm-ia64/sn/xpc.h	2007-08-20 13:23:38.731523146 -0500
+++ test/include/asm-ia64/sn/xpc.h	2007-08-21 11:46:16.895703399 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2004-2006 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2004-2007 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -1211,6 +1211,12 @@ xpc_IPI_init(int index)
 static inline enum xpc_retval
 xpc_map_bte_errors(bte_result_t error)
 {
+	if (is_shub2()) {
+		if (BTE_VALID_SH2_ERROR(error))
+			return xpcBteSh2Start + error;
+		else
+			return xpcBteUnmappedError;
+	}
 	switch (error) {
 	case BTE_SUCCESS:	return xpcSuccess;
 	case BTEFAIL_DIR:	return xpcBteDirectoryError;
Index: test/include/asm-ia64/sn/xp.h
=================================--- test.orig/include/asm-ia64/sn/xp.h	2007-08-20 13:23:38.731523146 -0500
+++ test/include/asm-ia64/sn/xp.h	2007-08-21 11:46:16.915705829 -0500
@@ -86,7 +86,7 @@ xp_bte_copy(u64 src, u64 vdst, u64 len, 
 	BUG_ON(REGION_NUMBER(vdst) != RGN_KERNEL);
 
 	ret = bte_copy(src, pdst, len, mode, notification);
-	if (ret != BTE_SUCCESS) {
+	if ((ret != BTE_SUCCESS) && BTE_ERROR_RETRY(ret)) {
 		if (!in_interrupt()) {
 			cond_resched();
 		}
@@ -244,7 +244,30 @@ enum xpc_retval {
 
 	xpcDisconnected,	/* 51: channel disconnected (closed) */
 
-	xpcUnknownReason	/* 52: unknown reason -- must be last in list */
+	xpcBteSh2Start,		/* 52: BTE CRB timeout */
+
+				/* 53: 0x1 BTE Error Response Short */
+	xpcBteSh2RspShort = xpcBteSh2Start + BTEFAIL_SH2_RESP_SHORT,
+
+				/* 54: 0x2 BTE Error Response Long */
+	xpcBteSh2RspLong = xpcBteSh2Start + BTEFAIL_SH2_RESP_LONG,
+
+				/* 56: 0x4 BTE Error Response DSB */
+	xpcBteSh2RspDSB = xpcBteSh2Start + BTEFAIL_SH2_RESP_DSP,
+
+				/* 60: 0x8 BTE Error Response Access */
+	xpcBteSh2RspAccess = xpcBteSh2Start + BTEFAIL_SH2_RESP_ACCESS,
+
+				/* 68: 0x10 BTE Error CRB timeout */
+	xpcBteSh2CRBTO = xpcBteSh2Start + BTEFAIL_SH2_CRB_TO,
+
+				/* 84: 0x20 BTE Error NACK limit */
+	xpcBteSh2NACKLimit = xpcBteSh2Start + BTEFAIL_SH2_NACK_LIMIT,
+
+				/* 115: BTE end */
+	xpcBteSh2End = xpcBteSh2Start + BTEFAIL_SH2_ALL,
+
+	xpcUnknownReason	/* 116: unknown reason -- must be last in list */
 };
 
 
Index: test/arch/ia64/sn/kernel/bte_error.c
=================================--- test.orig/arch/ia64/sn/kernel/bte_error.c	2007-08-20 13:23:34.154958050 -0500
+++ test/arch/ia64/sn/kernel/bte_error.c	2007-08-21 11:46:16.935708260 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2007 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 #include <linux/types.h>
@@ -148,7 +148,11 @@ int shub2_bte_error_handler(unsigned lon
 	for (i = 0; i < BTES_PER_NODE; i++) {
 		bte = &err_nodepda->bte_if[i];
 		status = BTE_LNSTAT_LOAD(bte);
-		if ((status & IBLS_ERROR) || !(status & IBLS_BUSY))
+		if (status & IBLS_ERROR) {
+			bte->bh_error = BTE_SHUB2_ERROR(status);
+			continue;
+		}
+		if (!(status & IBLS_BUSY))
 			continue;
 		mod_timer(recovery_timer, jiffies + (HZ * 5));
 		BTE_PRINTK(("eh:%p:%d Marked Giving up\n", err_nodepda,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
