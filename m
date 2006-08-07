From: Robin Holt <holt@sgi.com>
Date: Mon, 07 Aug 2006 17:49:33 +0000
Subject: Silent data corruption caused by XPC V2.
Message-Id: <20060807174933.GB24663@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
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
and verified it works.  I also added DBUG_ON statements to help catch
this if a similar situation is encountered.

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Dean Nelson <dcn@sgi.com>
Signed-off-by: Jack Steiner <steiner@sgi.com>

----

I originally built this against a git tree that I was using for a
git-bisect and did not catch that error before posting.  Here is a
repost with that corrected.  I am reposting this assuming you
accept our argument about the DBUG_ON() being left as is.  If not,
Dean Nelson will repost later today.

Sorry for the confusion,
Robin


Index: linux-2.6/arch/ia64/sn/kernel/xpc_channel.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_channel.c	2006-08-07 12:37:56.187180666 -0500
+++ linux-2.6/arch/ia64/sn/kernel/xpc_channel.c	2006-08-07 12:37:58.935517909 -0500
@@ -274,6 +274,7 @@ xpc_pull_remote_cachelines(struct xpc_pa
 	DBUG_ON((u64) src != L1_CACHE_ALIGN((u64) src));
 	DBUG_ON((u64) dst != L1_CACHE_ALIGN((u64) dst));
 	DBUG_ON(cnt != L1_CACHE_ALIGN(cnt));
+	DBUG_ON((ia64_tpa(dst) + cnt) != ia64_tpa(&((char *) dst)[cnt]));
 
 	if (part->act_state = XPC_P_DEACTIVATING) {
 		return part->reason;
Index: linux-2.6/arch/ia64/sn/kernel/xpc_partition.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_partition.c	2006-08-07 12:37:56.187180666 -0500
+++ linux-2.6/arch/ia64/sn/kernel/xpc_partition.c	2006-08-07 12:41:41.550828812 -0500
@@ -71,19 +71,15 @@ struct xpc_partition xpc_partitions[XP_M
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
@@ -148,6 +144,9 @@ xpc_get_rsvd_page_pa(int nasid)
 			}
 		}
 
+		DBUG_ON((ia64_tpa(buf) + buf_len) !+					ia64_tpa(&((char *) buf)[buf_len]));
+
 		bte_res = xp_bte_copy(rp_pa, ia64_tpa(buf), buf_len,
 					(BTE_NOTIFY | BTE_WACQUIRE), NULL);
 		if (bte_res != BTE_SUCCESS) {
@@ -445,6 +444,9 @@ xpc_check_remote_hb(void)
 			continue;
 		}
 
+		DBUG_ON((ia64_tpa(remote_vars) + XPC_RP_VARS_SIZE) !+			ia64_tpa(&((char *) remote_vars)[XPC_RP_VARS_SIZE]));
+
 		/* pull the remote_hb cache line */
 		bres = xp_bte_copy(part->remote_vars_pa,
 					ia64_tpa((u64) remote_vars),
@@ -496,9 +498,11 @@ xpc_get_remote_rp(int nasid, u64 *discov
 		return xpcNoRsvdPageAddr;
 	}
 
+	DBUG_ON((ia64_tpa(remote_rp + XPC_RP_HEADER_SIZE + xp_nasid_mask_bytes) !+		ia64_tpa(&((char *) remote_rp)[XPC_RP_HEADER_SIZE + xp_nasid_mask_bytes])));
 
-	/* pull over the reserved page header and part_nasids mask */
 
+	/* pull over the reserved page header and part_nasids mask */
 	bres = xp_bte_copy(*remote_rp_pa, ia64_tpa((u64) remote_rp),
 				XPC_RP_HEADER_SIZE + xp_nasid_mask_bytes,
 				(BTE_NOTIFY | BTE_WACQUIRE), NULL);
@@ -554,9 +558,11 @@ xpc_get_remote_vars(u64 remote_vars_pa, 
 		return xpcVarsNotSet;
 	}
 
+	DBUG_ON((ia64_tpa(remote_vars) + XPC_RP_VARS_SIZE) !+		ia64_tpa(&((char *) remote_vars)[XPC_RP_VARS_SIZE]));
 
-	/* pull over the cross partition variables */
 
+	/* pull over the cross partition variables */
 	bres = xp_bte_copy(remote_vars_pa, ia64_tpa((u64) remote_vars),
 				XPC_RP_VARS_SIZE,
 				(BTE_NOTIFY | BTE_WACQUIRE), NULL);
@@ -1239,6 +1245,9 @@ xpc_initiate_partid_to_nasids(partid_t p
 
 	part_nasid_pa = (u64) XPC_RP_PART_NASIDS(part->remote_rp_pa);
 
+	DBUG_ON((ia64_tpa(nasid_mask) + xp_nasid_mask_bytes) !+			ia64_tpa(&((char *) nasid_mask)[xp_nasid_mask_bytes]));
+
 	bte_res = xp_bte_copy(part_nasid_pa, ia64_tpa((u64) nasid_mask),
 			xp_nasid_mask_bytes, (BTE_NOTIFY | BTE_WACQUIRE), NULL);
 
Index: linux-2.6/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_main.c	2006-08-07 12:37:56.187180666 -0500
+++ linux-2.6/arch/ia64/sn/kernel/xpc_main.c	2006-08-07 12:37:58.939518400 -0500
@@ -1052,6 +1052,8 @@ xpc_do_exit(enum xpc_retval reason)
 	if (xpc_sysctl) {
 		unregister_sysctl_table(xpc_sysctl);
 	}
+
+	kfree(xpc_remote_copy_buffer_base);
 }
 
 
@@ -1212,24 +1214,19 @@ xpc_init(void)
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
+	buf_size = max(XPC_RP_VARS_SIZE, XPC_RP_HEADER_SIZE + XP_NASID_MASK_BYTES);
+	xpc_remote_copy_buffer = xpc_kmalloc_cacheline_aligned(buf_size, GFP_KERNEL,
+						&xpc_remote_copy_buffer_base);
+	if (xpc_remote_copy_buffer = NULL)
+		return -ENOMEM;
 
 	snprintf(xpc_part->bus_id, BUS_ID_SIZE, "part");
 	snprintf(xpc_chan->bus_id, BUS_ID_SIZE, "chan");
@@ -1293,6 +1290,8 @@ xpc_init(void)
 		if (xpc_sysctl) {
 			unregister_sysctl_table(xpc_sysctl);
 		}
+
+		kfree(xpc_remote_copy_buffer_base);
 		return -EBUSY;
 	}
 
@@ -1311,6 +1310,8 @@ xpc_init(void)
 		if (xpc_sysctl) {
 			unregister_sysctl_table(xpc_sysctl);
 		}
+
+		kfree(xpc_remote_copy_buffer_base);
 		return -EBUSY;
 	}
 
@@ -1362,6 +1363,8 @@ xpc_init(void)
 		if (xpc_sysctl) {
 			unregister_sysctl_table(xpc_sysctl);
 		}
+
+		kfree(xpc_remote_copy_buffer_base);
 		return -EBUSY;
 	}
 
Index: linux-2.6/include/asm-ia64/sn/xpc.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/xpc.h	2006-08-07 12:37:56.187180666 -0500
+++ linux-2.6/include/asm-ia64/sn/xpc.h	2006-08-07 12:43:44.201871144 -0500
@@ -684,7 +684,9 @@ extern struct xpc_vars *xpc_vars;
 extern struct xpc_rsvd_page *xpc_rsvd_page;
 extern struct xpc_vars_part *xpc_vars_part;
 extern struct xpc_partition xpc_partitions[XP_MAX_PARTITIONS + 1];
-extern char xpc_remote_copy_buffer[];
+extern char *xpc_remote_copy_buffer;
+extern void *xpc_remote_copy_buffer_base;
+extern void * xpc_kmalloc_cacheline_aligned(size_t, gfp_t, void **);
 extern struct xpc_rsvd_page *xpc_rsvd_page_init(void);
 extern void xpc_allow_IPI_ops(void);
 extern void xpc_restrict_IPI_ops(void);
@@ -720,6 +722,7 @@ extern void xpc_teardown_infrastructure(
 
 
 
+
 static inline void
 xpc_wakeup_channel_mgr(struct xpc_partition *part)
 {
