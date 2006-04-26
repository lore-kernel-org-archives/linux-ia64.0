From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Wed, 26 Apr 2006 20:06:10 +0000
Subject: [patch] Add mca recovery failure messages
Message-Id: <200604262006.k3QK6AA5287600@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Add mca recovery failure messages

When the mca recovery code encounters a condition that makes
the MCA non-recoverable, print the reason it could not recover.
This will make it easier to identify why the recovery code did
not recover.

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 arch/ia64/kernel/mca_drv.c |   54 ++++++++++++++++++++++++++++++---------------
 1 file changed, 36 insertions(+), 18 deletions(-)

Index: test/arch/ia64/kernel/mca_drv.c
=================================--- test.orig/arch/ia64/kernel/mca_drv.c	2006-04-20 09:01:10.880579074 -0500
+++ test/arch/ia64/kernel/mca_drv.c	2006-04-26 14:43:52.507645704 -0500
@@ -62,6 +62,11 @@ typedef enum {
 	ISOLATE_NONE
 } isolate_status_t;
 
+typedef enum {
+	MCA_NOT_RECOVERED = 0,
+	MCA_RECOVERED	  = 1
+} recovery_status_t;
+
 /*
  *  This pool keeps pointers to the section part of SAL error record
  */
@@ -71,6 +76,18 @@ static struct {
 	int	     max_idx; /* Maximum index of section pointer list pool */
 } slidx_pool;
 
+int
+fatal_mca(const char *fmt, ...)
+{
+	va_list args;
+
+	va_start(args, fmt);
+	vprintk(fmt, args);
+	va_end(args);
+
+	return MCA_NOT_RECOVERED;
+}
+
 /**
  * mca_page_isolate - isolate a poisoned page in order not to use it later
  * @paddr:	poisoned memory location
@@ -424,7 +441,7 @@ recover_from_read_error(slidx_table_t *s
 
 	/* Is target address valid? */
 	if (!pbci->tv)
-		return 0;
+		return fatal_mca(KERN_ALERT "MCA: target address not valid\n");
 
 	/*
 	 * cpu read or memory-mapped io read
@@ -442,7 +459,7 @@ recover_from_read_error(slidx_table_t *s
 
 	/* Is minstate valid? */
 	if (!peidx_bottom(peidx) || !(peidx_bottom(peidx)->valid.minstate))
-		return 0;
+		return fatal_mca(KERN_ALERT "MCA: minstate not valid\n");
 	psr1 =(struct ia64_psr *)&(peidx_minstate_area(peidx)->pmsa_ipsr);
 	psr2 =(struct ia64_psr *)&(peidx_minstate_area(peidx)->pmsa_xpsr);
 
@@ -476,12 +493,13 @@ recover_from_read_error(slidx_table_t *s
 			psr2->bn  = 1;
 			psr2->i  = 0;
 
-			return 1;
+			return MCA_RECOVERED;
 		}
 
 	}
 
-	return 0;
+	return fatal_mca(KERN_ALERT "MCA: kernel context not recovered,"
+			  " iip 0x%lx\n", pmsa->pmsa_iip);
 }
 
 /**
@@ -567,13 +585,13 @@ recover_from_processor_error(int platfor
 	 * The machine check is corrected.
 	 */
 	if (psp->cm = 1)
-		return 1;
+		return MCA_RECOVERED;
 
 	/*
 	 * The error was not contained.  Software must be reset.
 	 */
 	if (psp->us || psp->ci = 0)
-		return 0;
+		return fatal_mca(KERN_ALERT "MCA: error not contained\n");
 
 	/*
 	 * The cache check and bus check bits have four possible states
@@ -584,20 +602,22 @@ recover_from_processor_error(int platfor
 	 *    1  1	Memory error, attempt recovery
 	 */
 	if (psp->bc = 0 || pbci = NULL)
-		return 0;
+		return fatal_mca(KERN_ALERT "MCA: No bus check\n");
 
 	/*
 	 * Sorry, we cannot handle so many.
 	 */
 	if (peidx_bus_check_num(peidx) > 1)
-		return 0;
+		return fatal_mca(KERN_ALERT "MCA: Too many bus checks\n");
 	/*
 	 * Well, here is only one bus error.
 	 */
-	if (pbci->ib || pbci->cc)
-		return 0;
+	if (pbci->ib)
+		return fatal_mca(KERN_ALERT "MCA: Internal Bus error\n");
+	if (pbci->cc)
+		return fatal_mca(KERN_ALERT "MCA: Cache-cache error\n");
 	if (pbci->eb && pbci->bsi > 0)
-		return 0;
+		return fatal_mca(KERN_ALERT "MCA: External bus check fatal status\n");
 
 	/*
 	 * This is a local MCA and estimated as recoverble external bus error.
@@ -609,7 +629,7 @@ recover_from_processor_error(int platfor
 	/*
 	 * On account of strange SAL error record, we cannot recover.
 	 */
-	return 0;
+	return fatal_mca(KERN_ALERT "MCA: Strange SAL record\n");
 }
 
 /**
@@ -638,12 +658,10 @@ mca_try_to_recover(void *rec, struct ia6
 
 	 /* Now, OS can recover when there is one processor error section */
 	if (n_proc_err > 1)
-		return 0;
-	else if (n_proc_err = 0) {
+		return fatal_mca(KERN_ALERT "MCA: Too Many Errors\n");
+	else if (n_proc_err = 0)
 		/* Weird SAL record ... We need not to recover */
-
-		return 1;
-	}
+		return fatal_mca(KERN_ALERT "MCA: Weird SAL record\n");
 
 	/* Make index of processor error section */
 	mca_make_peidx((sal_log_processor_info_t*)
@@ -654,7 +672,7 @@ mca_try_to_recover(void *rec, struct ia6
 
 	/* Check whether MCA is global or not */
 	if (is_mca_global(&peidx, &pbci, sos))
-		return 0;
+		return fatal_mca(KERN_ALERT "MCA: global MCA\n");
 	
 	/* Try to recover a processor error */
 	return recover_from_processor_error(platform_err, &slidx, &peidx,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
