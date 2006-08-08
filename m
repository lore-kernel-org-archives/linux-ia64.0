From: Dean Nelson <dcn@sgi.com>
Date: Tue, 08 Aug 2006 20:03:29 +0000
Subject: Re: Silent data corruption caused by XPC V2.
Message-Id: <20060808200329.GC30496@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060807174933.GB24663@lnx-holt.americas.sgi.com>
In-Reply-To: <20060807174933.GB24663@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack Steiner identified a problem where XPC can cause a silent
data corruption.  On module load, the placement may cause the
xpc_remote_copy_buffer to span two physical pages.  DMA transfers are
done to the start virtual address translated to physical.

This patch changes the buffer from a statically allocated buffer to a
kmalloc'd buffer.  Dean Nelson reviewed this before posting.  I have
tested it in the configuration that was showing the memory corruption
and verified it works.  I also added a BUG_ON statement to help catch
this if a similar situation is encountered.

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Dean Nelson <dcn@sgi.com>
Signed-off-by: Jack Steiner <steiner@sgi.com>

----

On Tue, Aug 08, 2006 at 10:44:24AM -0700, Luck, Tony wrote:
> +	/* ensure that the physically mapped memory is contiguous */
> +	DBUG_ON(REGION_NUMBER(vdst) != RGN_KERNEL &&
> +		REGION_NUMBER(vdst) != RGN_UNCACHED &&
> +		PAGE_SIZE - (vdst & ~PAGE_MASK) < len);
>  
> I thought that part of the point of this patch was that
> by using kmalloc() for the buffer, you actually guaranteed
> that the whole thing is contiguous (since kmalloc will give
> you an order(N) page for requests greater than a page.
> 
> This test is a bit convoluted, but looks it will ping you
> whenever a transfer crosses a page boundary, regardless of
> whether the pages are contiguous or not.  Certainly the
> comment seems tenuously connected to the code.
> 
> -Tony

This is a new version of the patch which hopefully will be more in line
with what you'd like to see. I've simplified the test down to a single 

	BUG_ON(REGION_NUMBER(vdst) != RGN_KERNEL);

since we currently only utilize region 7 buffers.

Thanks,
Dean



Index: linux-2.6/arch/ia64/sn/kernel/xpc_channel.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_channel.c	2006-08-08 14:30:06.750362170 -0500
+++ linux-2.6/arch/ia64/sn/kernel/xpc_channel.c	2006-08-08 14:30:09.350665624 -0500
@@ -279,8 +279,8 @@
 		return part->reason;
 	}
 
-	bte_ret = xp_bte_copy((u64) src, (u64) ia64_tpa((u64) dst),
-				(u64) cnt, (BTE_NORMAL | BTE_WACQUIRE), NULL);
+	bte_ret = xp_bte_copy((u64) src, (u64) dst, (u64) cnt,
+					(BTE_NORMAL | BTE_WACQUIRE), NULL);
 	if (bte_ret = BTE_SUCCESS) {
 		return xpcSuccess;
 	}
Index: linux-2.6/arch/ia64/sn/kernel/xpc_partition.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_partition.c	2006-08-08 14:30:06.750362170 -0500
+++ linux-2.6/arch/ia64/sn/kernel/xpc_partition.c	2006-08-08 14:30:09.350665624 -0500
@@ -71,19 +71,15 @@
  * Generic buffer used to store a local copy of portions of a remote
  * partition's reserved page (either its header and part_nasids mask,
  * or its vars).
- *
- * xpc_discovery runs only once and is a seperate thread that is
- * very likely going to be processing in parallel with receiving
- * interrupts.
  */
-char ____cacheline_aligned xpc_remote_copy_buffer[XPC_RP_HEADER_SIZE +
-							XP_NASID_MASK_BYTES];
+char *xpc_remote_copy_buffer;
+void *xpc_remote_copy_buffer_base;
 
 
 /*
  * Guarantee that the kmalloc'd memory is cacheline aligned.
  */
-static void *
+void *
 xpc_kmalloc_cacheline_aligned(size_t size, gfp_t flags, void **base)
 {
 	/* see if kmalloc will give us cachline aligned memory by default */
@@ -148,7 +144,7 @@
 			}
 		}
 
-		bte_res = xp_bte_copy(rp_pa, ia64_tpa(buf), buf_len,
+		bte_res = xp_bte_copy(rp_pa, buf, buf_len,
 					(BTE_NOTIFY | BTE_WACQUIRE), NULL);
 		if (bte_res != BTE_SUCCESS) {
 			dev_dbg(xpc_part, "xp_bte_copy failed %i\n", bte_res);
@@ -447,7 +443,7 @@
 
 		/* pull the remote_hb cache line */
 		bres = xp_bte_copy(part->remote_vars_pa,
-					ia64_tpa((u64) remote_vars),
+					(u64) remote_vars,
 					XPC_RP_VARS_SIZE,
 					(BTE_NOTIFY | BTE_WACQUIRE), NULL);
 		if (bres != BTE_SUCCESS) {
@@ -498,8 +494,7 @@
 
 
 	/* pull over the reserved page header and part_nasids mask */
-
-	bres = xp_bte_copy(*remote_rp_pa, ia64_tpa((u64) remote_rp),
+	bres = xp_bte_copy(*remote_rp_pa, (u64) remote_rp,
 				XPC_RP_HEADER_SIZE + xp_nasid_mask_bytes,
 				(BTE_NOTIFY | BTE_WACQUIRE), NULL);
 	if (bres != BTE_SUCCESS) {
@@ -554,11 +549,8 @@
 		return xpcVarsNotSet;
 	}
 
-
 	/* pull over the cross partition variables */
-
-	bres = xp_bte_copy(remote_vars_pa, ia64_tpa((u64) remote_vars),
-				XPC_RP_VARS_SIZE,
+	bres = xp_bte_copy(remote_vars_pa, (u64) remote_vars, XPC_RP_VARS_SIZE,
 				(BTE_NOTIFY | BTE_WACQUIRE), NULL);
 	if (bres != BTE_SUCCESS) {
 		return xpc_map_bte_errors(bres);
@@ -1239,7 +1231,7 @@
 
 	part_nasid_pa = (u64) XPC_RP_PART_NASIDS(part->remote_rp_pa);
 
-	bte_res = xp_bte_copy(part_nasid_pa, ia64_tpa((u64) nasid_mask),
+	bte_res = xp_bte_copy(part_nasid_pa, (u64) nasid_mask,
 			xp_nasid_mask_bytes, (BTE_NOTIFY | BTE_WACQUIRE), NULL);
 
 	return xpc_map_bte_errors(bte_res);
Index: linux-2.6/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_main.c	2006-08-08 14:30:06.750362170 -0500
+++ linux-2.6/arch/ia64/sn/kernel/xpc_main.c	2006-08-08 14:30:09.350665624 -0500
@@ -1052,6 +1052,8 @@
 	if (xpc_sysctl) {
 		unregister_sysctl_table(xpc_sysctl);
 	}
+
+	kfree(xpc_remote_copy_buffer_base);
 }
 
 
@@ -1212,24 +1214,20 @@
 	partid_t partid;
 	struct xpc_partition *part;
 	pid_t pid;
+	size_t buf_size;
 
 
 	if (!ia64_platform_is("sn2")) {
 		return -ENODEV;
 	}
 
-	/*
-	 * xpc_remote_copy_buffer is used as a temporary buffer for bte_copy'ng
-	 * various portions of a partition's reserved page. Its size is based
-	 * on the size of the reserved page header and part_nasids mask. So we
-	 * need to ensure that the other items will fit as well.
-	 */
-	if (XPC_RP_VARS_SIZE > XPC_RP_HEADER_SIZE + XP_NASID_MASK_BYTES) {
-		dev_err(xpc_part, "xpc_remote_copy_buffer is not big enough\n");
-		return -EPERM;
-	}
-	DBUG_ON((u64) xpc_remote_copy_buffer !-				L1_CACHE_ALIGN((u64) xpc_remote_copy_buffer));
+
+	buf_size = max(XPC_RP_VARS_SIZE,
+				XPC_RP_HEADER_SIZE + XP_NASID_MASK_BYTES);
+	xpc_remote_copy_buffer = xpc_kmalloc_cacheline_aligned(buf_size,
+				     GFP_KERNEL, &xpc_remote_copy_buffer_base);
+	if (xpc_remote_copy_buffer = NULL)
+		return -ENOMEM;
 
 	snprintf(xpc_part->bus_id, BUS_ID_SIZE, "part");
 	snprintf(xpc_chan->bus_id, BUS_ID_SIZE, "chan");
@@ -1293,6 +1291,8 @@
 		if (xpc_sysctl) {
 			unregister_sysctl_table(xpc_sysctl);
 		}
+
+		kfree(xpc_remote_copy_buffer_base);
 		return -EBUSY;
 	}
 
@@ -1311,6 +1311,8 @@
 		if (xpc_sysctl) {
 			unregister_sysctl_table(xpc_sysctl);
 		}
+
+		kfree(xpc_remote_copy_buffer_base);
 		return -EBUSY;
 	}
 
@@ -1362,6 +1364,8 @@
 		if (xpc_sysctl) {
 			unregister_sysctl_table(xpc_sysctl);
 		}
+
+		kfree(xpc_remote_copy_buffer_base);
 		return -EBUSY;
 	}
 
Index: linux-2.6/include/asm-ia64/sn/xpc.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/xpc.h	2006-08-08 14:30:06.750362170 -0500
+++ linux-2.6/include/asm-ia64/sn/xpc.h	2006-08-08 14:30:09.354666091 -0500
@@ -683,7 +683,9 @@
 extern struct xpc_rsvd_page *xpc_rsvd_page;
 extern struct xpc_vars_part *xpc_vars_part;
 extern struct xpc_partition xpc_partitions[XP_MAX_PARTITIONS + 1];
-extern char xpc_remote_copy_buffer[];
+extern char *xpc_remote_copy_buffer;
+extern void *xpc_remote_copy_buffer_base;
+extern void *xpc_kmalloc_cacheline_aligned(size_t, gfp_t, void **);
 extern struct xpc_rsvd_page *xpc_rsvd_page_init(void);
 extern void xpc_allow_IPI_ops(void);
 extern void xpc_restrict_IPI_ops(void);
Index: linux-2.6/include/asm-ia64/sn/xp.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/xp.h	2006-08-08 14:30:06.750362170 -0500
+++ linux-2.6/include/asm-ia64/sn/xp.h	2006-08-08 14:32:11.968983275 -0500
@@ -60,23 +60,37 @@
  * the bte_copy() once in the hope that the failure was due to a temporary
  * aberration (i.e., the link going down temporarily).
  *
- * See bte_copy for definition of the input parameters.
+ * 	src - physical address of the source of the transfer.
+ *	vdst - virtual address of the destination of the transfer.
+ *	len - number of bytes to transfer from source to destination.
+ *	mode - see bte_copy() for definition.
+ *	notification - see bte_copy() for definition.
  *
  * Note: xp_bte_copy() should never be called while holding a spinlock.
  */
 static inline bte_result_t
-xp_bte_copy(u64 src, u64 dest, u64 len, u64 mode, void *notification)
+xp_bte_copy(u64 src, u64 vdst, u64 len, u64 mode, void *notification)
 {
 	bte_result_t ret;
+	u64 pdst = ia64_tpa(vdst);
 
 
-	ret = bte_copy(src, dest, len, mode, notification);
+	/*
+	 * Ensure that the physically mapped memory is contiguous.
+	 *
+	 * We do this by ensuring that the memory is from region 7 only.
+	 * If the need should arise to use memory from one of the other
+	 * regions, then modify the BUG_ON() statement to ensure that the
+	 * memory from that region is always physically contiguous.
+	 */
+	BUG_ON(REGION_NUMBER(vdst) != RGN_KERNEL);
 
+	ret = bte_copy(src, pdst, len, mode, notification);
 	if (ret != BTE_SUCCESS) {
 		if (!in_interrupt()) {
 			cond_resched();
 		}
-		ret = bte_copy(src, dest, len, mode, notification);
+		ret = bte_copy(src, pdst, len, mode, notification);
 	}
 
 	return ret;
