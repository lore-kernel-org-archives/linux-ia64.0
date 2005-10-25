From: dcn@sgi.com (Dean Nelson)
Date: Tue, 25 Oct 2005 19:09:51 +0000
Subject: [PATCH] XPC changes to support more than 2k nasids
Message-Id: <435E82FF.mailx5K517F9ZJ@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

XPC needs to be changed to support up to 16k nasids on an SGI Altix system.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6.git-test/arch/ia64/sn/kernel/xpc.h
=================================--- linux-2.6.git-test.orig/arch/ia64/sn/kernel/xpc.h	2005-10-25 13:29:36.027368620 -0500
+++ linux-2.6.git-test/arch/ia64/sn/kernel/xpc.h	2005-10-25 13:37:21.877203540 -0500
@@ -68,29 +68,58 @@
 
 
 /*
- * Reserved Page provided by SAL.
+ * the reserved page
  *
- * SAL provides one page per partition of reserved memory.  When SAL
- * initialization is complete, SAL_signature, SAL_version, partid,
- * part_nasids, and mach_nasids are set.
+ *   SAL reserves one page of memory per partition for XPC. Though a full page
+ *   in length (16384 bytes), its starting address is not page aligned, but it
+ *   is cacheline aligned. The reserved page consists of the following:
+ *
+ *   reserved page header
+ *
+ *     The first cacheline of the reserved page contains the header
+ *     (struct xpc_rsvd_page). Before SAL initialization has completed,
+ *     SAL has set up the following fields of the reserved page header:
+ *     SAL_signature, SAL_version, partid, and nasids_size. The other
+ *     fields are set up by XPC. (xpc_rsvd_page points to the local
+ *     partition's reserved page.)
+ *
+ *   part_nasids mask
+ *   mach_nasids mask
+ *
+ *     SAL also sets up two bitmaps (or masks), one that reflects the actual
+ *     nasids in this partition (part_nasids), and the other that reflects
+ *     the actual nasids in the entire machine (mach_nasids). We're only
+ *     interested in the even numbered nasids (which contain the processors
+ *     and/or memory), so we only need half as many bits to represent the
+ *     nasids. The part_nasids mask is located starting at the first cacheline
+ *     following the reserved page header. The mach_nasids mask follows right
+ *     after the part_nasids mask. The size in bytes of each mask is reflected
+ *     by the reserved page header field 'nasids_size'. (Local partition's
+ *     mask pointers are xpc_part_nasids and xpc_mach_nasids.)
+ *
+ *   vars
+ *   vars part
+ *
+ *     Immediately following the mach_nasids mask are the XPC variables
+ *     required by other partitions. First are those that are generic to all
+ *     partitions (vars), followed on the next available cacheline by those
+ *     which are partition specific (vars part). These are setup by XPC.
+ *     (Local partition's vars pointers are xpc_vars and xpc_vars_part.)
  *
  * Note: Until vars_pa is set, the partition XPC code has not been initialized.
  */
 struct xpc_rsvd_page {
-	u64 SAL_signature;	/* SAL unique signature */
-	u64 SAL_version;	/* SAL specified version */
-	u8 partid;		/* partition ID from SAL */
+	u64 SAL_signature;	/* SAL: unique signature */
+	u64 SAL_version;	/* SAL: version */
+	u8 partid;		/* SAL: partition ID */
 	u8 version;
-	u8 pad[6];		/* pad to u64 align */
+	u8 pad1[6];		/* align to next u64 in cacheline */
 	volatile u64 vars_pa;
-	struct timespec stamp;	/* time when reserved page was initialized */
-	u64 part_nasids[XP_NASID_MASK_WORDS] ____cacheline_aligned;
-	u64 mach_nasids[XP_NASID_MASK_WORDS] ____cacheline_aligned;
+	struct timespec stamp;	/* time when reserved page was setup by XPC */
+	u64 pad2[9];		/* align to last u64 in cacheline */
+	u64 nasids_size;	/* SAL: size of each nasid mask in bytes */
 };
 
-#define XPC_RSVD_PAGE_ALIGNED_SIZE \
-			(L1_CACHE_ALIGN(sizeof(struct xpc_rsvd_page)))
-
 #define XPC_RP_VERSION _XPC_VERSION(1,1) /* version 1.1 of the reserved page */
 
 #define XPC_SUPPORTS_RP_STAMP(_version) \
@@ -142,8 +171,6 @@
 	AMO_t *amos_page;	/* vaddr of page of AMOs from MSPEC driver */
 };
 
-#define XPC_VARS_ALIGNED_SIZE  (L1_CACHE_ALIGN(sizeof(struct xpc_vars)))
-
 #define XPC_V_VERSION _XPC_VERSION(3,1) /* version 3.1 of the cross vars */
 
 #define XPC_SUPPORTS_DISENGAGE_REQUEST(_version) \
@@ -184,7 +211,7 @@
 /*
  * The AMOs page consists of a number of AMO variables which are divided into
  * four groups, The first two groups are used to identify an IRQ's sender.
- * These two groups consist of 64 and 16 AMO variables respectively. The last
+ * These two groups consist of 64 and 128 AMO variables respectively. The last
  * two groups, consisting of just one AMO variable each, are used to identify
  * the remote partitions that are currently engaged (from the viewpoint of
  * the XPC running on the remote partition).
@@ -233,6 +260,16 @@
 #define XPC_VP_MAGIC2	0x0073726176435058L  /* 'XPCvars\0'L (little endian) */
 
 
+/* the reserved page sizes and offsets */
+
+#define XPC_RP_HEADER_SIZE	L1_CACHE_ALIGN(sizeof(struct xpc_rsvd_page))
+#define XPC_RP_VARS_SIZE 	L1_CACHE_ALIGN(sizeof(struct xpc_vars))
+
+#define XPC_RP_PART_NASIDS(_rp) (u64 *) ((u8 *) _rp + XPC_RP_HEADER_SIZE)
+#define XPC_RP_MACH_NASIDS(_rp) (XPC_RP_PART_NASIDS(_rp) + xp_nasid_mask_words)
+#define XPC_RP_VARS(_rp)	((struct xpc_vars *) XPC_RP_MACH_NASIDS(_rp) + xp_nasid_mask_words)
+#define XPC_RP_VARS_PART(_rp)	(struct xpc_vars_part *) ((u8 *) XPC_RP_VARS(rp) + XPC_RP_VARS_SIZE)
+
 
 /*
  * Functions registered by add_timer() or called by kernel_thread() only
@@ -1147,9 +1184,9 @@
  * cacheable mapping for the entire region. This will prevent speculative
  * reading of cached copies of our lines from being issued which will cause
  * a PI FSB Protocol error to be generated by the SHUB. For XPC, we need 64
- * (XP_MAX_PARTITIONS) AMO variables for message notification and an
- * additional 16 (XP_NASID_MASK_WORDS) AMO variables for partition activation
- * and 2 AMO variables for partition deactivation.
+ * AMO variables (based on XP_MAX_PARTITIONS) for message notification and an
+ * additional 128 AMO variables (based on XP_NASID_MASK_WORDS) for partition
+ * activation and 2 AMO variables for partition deactivation.
  */
 static inline AMO_t *
 xpc_IPI_init(int index)
Index: linux-2.6.git-test/arch/ia64/sn/kernel/xpc_partition.c
=================================--- linux-2.6.git-test.orig/arch/ia64/sn/kernel/xpc_partition.c	2005-10-25 13:29:36.027368620 -0500
+++ linux-2.6.git-test/arch/ia64/sn/kernel/xpc_partition.c	2005-10-25 13:29:55.169982587 -0500
@@ -47,13 +47,16 @@
 u64 xpc_prot_vec[MAX_NUMNODES];
 
 
-/* this partition's reserved page */
+/* this partition's reserved page pointers */
 struct xpc_rsvd_page *xpc_rsvd_page;
-
-/* this partition's XPC variables (within the reserved page) */
+static u64 *xpc_part_nasids;
+static u64 *xpc_mach_nasids;
 struct xpc_vars *xpc_vars;
 struct xpc_vars_part *xpc_vars_part;
 
+static int xp_nasid_mask_bytes;	/* actual size in bytes of nasid mask */
+static int xp_nasid_mask_words;	/* actual size in words of nasid mask */
+
 
 /*
  * For performance reasons, each entry of xpc_partitions[] is cacheline
@@ -65,15 +68,16 @@
 
 
 /*
- * Generic buffer used to store a local copy of the remote partitions
- * reserved page or XPC variables.
+ * Generic buffer used to store a local copy of portions of a remote
+ * partition's reserved page (either its header and part_nasids mask,
+ * or its vars).
  *
  * xpc_discovery runs only once and is a seperate thread that is
  * very likely going to be processing in parallel with receiving
  * interrupts.
  */
-char ____cacheline_aligned
-		xpc_remote_copy_buffer[XPC_RSVD_PAGE_ALIGNED_SIZE];
+char ____cacheline_aligned xpc_remote_copy_buffer[XPC_RP_HEADER_SIZE +
+							XP_NASID_MASK_BYTES];
 
 
 /*
@@ -136,7 +140,7 @@
 {
 	struct xpc_rsvd_page *rp;
 	AMO_t *amos_page;
-	u64 rp_pa, next_cl, nasid_array = 0;
+	u64 rp_pa, nasid_array = 0;
 	int i, ret;
 
 
@@ -144,7 +148,8 @@
 
 	rp_pa = xpc_get_rsvd_page_pa(cnodeid_to_nasid(0),
 					(u64) xpc_remote_copy_buffer,
-						XPC_RSVD_PAGE_ALIGNED_SIZE);
+						XPC_RP_HEADER_SIZE +
+							L1_CACHE_BYTES);
 	if (rp_pa = 0) {
 		dev_err(xpc_part, "SAL failed to locate the reserved page\n");
 		return NULL;
@@ -159,12 +164,19 @@
 
 	rp->version = XPC_RP_VERSION;
 
-	/*
-	 * Place the XPC variables on the cache line following the
-	 * reserved page structure.
-	 */
-	next_cl = (u64) rp + XPC_RSVD_PAGE_ALIGNED_SIZE;
-	xpc_vars = (struct xpc_vars *) next_cl;
+	/* establish the actual sizes of the nasid masks */
+	if (rp->SAL_version = 1) {
+		/* SAL_version 1 didn't set the nasids_size field */
+		rp->nasids_size = 128;
+	}
+	xp_nasid_mask_bytes = rp->nasids_size;
+	xp_nasid_mask_words = xp_nasid_mask_bytes / 8;
+
+	/* setup the pointers to the various items in the reserved page */
+	xpc_part_nasids = XPC_RP_PART_NASIDS(rp);
+	xpc_mach_nasids = XPC_RP_MACH_NASIDS(rp);
+	xpc_vars = XPC_RP_VARS(rp);
+	xpc_vars_part = XPC_RP_VARS_PART(rp);
 
 	/*
 	 * Before clearing xpc_vars, see if a page of AMOs had been previously
@@ -216,26 +228,23 @@
 		amos_page = (AMO_t *) TO_AMO((u64) amos_page);
 	}
 
+	/* clear xpc_vars */
 	memset(xpc_vars, 0, sizeof(struct xpc_vars));
 
-	/*
-	 * Place the XPC per partition specific variables on the cache line
-	 * following the XPC variables structure.
-	 */
-	next_cl += XPC_VARS_ALIGNED_SIZE;
-	memset((u64 *) next_cl, 0, sizeof(struct xpc_vars_part) *
-							XP_MAX_PARTITIONS);
-	xpc_vars_part = (struct xpc_vars_part *) next_cl;
-	xpc_vars->vars_part_pa = __pa(next_cl);
-
 	xpc_vars->version = XPC_V_VERSION;
 	xpc_vars->act_nasid = cpuid_to_nasid(0);
 	xpc_vars->act_phys_cpuid = cpu_physical_id(0);
+	xpc_vars->vars_part_pa = __pa(xpc_vars_part);
+	xpc_vars->amos_page_pa = ia64_tpa((u64) amos_page);
 	xpc_vars->amos_page = amos_page;  /* save for next load of XPC */
 
 
+	/* clear xpc_vars_part */
+	memset((u64 *) xpc_vars_part, 0, sizeof(struct xpc_vars_part) *
+							XP_MAX_PARTITIONS);
+
 	/* initialize the activate IRQ related AMO variables */
-	for (i = 0; i < XP_NASID_MASK_WORDS; i++) {
+	for (i = 0; i < xp_nasid_mask_words; i++) {
 		(void) xpc_IPI_init(XPC_ACTIVATE_IRQ_AMOS + i);
 	}
 
@@ -243,10 +252,7 @@
 	(void) xpc_IPI_init(XPC_ENGAGED_PARTITIONS_AMO);
 	(void) xpc_IPI_init(XPC_DISENGAGE_REQUEST_AMO);
 
-	/* export AMO page's physical address to other partitions */
-	xpc_vars->amos_page_pa = ia64_tpa((u64) xpc_vars->amos_page);
-
-	/* timestamp of when reserved page was initialized */
+	/* timestamp of when reserved page was setup by XPC */
 	rp->stamp = CURRENT_TIME;
 
 	/*
@@ -406,7 +412,7 @@
 		/* pull the remote_hb cache line */
 		bres = xp_bte_copy(part->remote_vars_pa,
 					ia64_tpa((u64) remote_vars),
-					XPC_VARS_ALIGNED_SIZE,
+					XPC_RP_VARS_SIZE,
 					(BTE_NOTIFY | BTE_WACQUIRE), NULL);
 		if (bres != BTE_SUCCESS) {
 			XPC_DEACTIVATE_PARTITION(part,
@@ -434,10 +440,11 @@
 
 
 /*
- * Get a copy of the remote partition's rsvd page.
+ * Get a copy of a portion of the remote partition's rsvd page.
  *
  * remote_rp points to a buffer that is cacheline aligned for BTE copies and
- * assumed to be of size XPC_RSVD_PAGE_ALIGNED_SIZE.
+ * is large enough to contain a copy of their reserved page header and
+ * part_nasids mask.
  */
 static enum xpc_retval
 xpc_get_remote_rp(int nasid, u64 *discovered_nasids,
@@ -449,16 +456,17 @@
 	/* get the reserved page's physical address */
 
 	*remote_rp_pa = xpc_get_rsvd_page_pa(nasid, (u64) remote_rp,
-						XPC_RSVD_PAGE_ALIGNED_SIZE);
+						XPC_RP_HEADER_SIZE +
+							xp_nasid_mask_bytes);
 	if (*remote_rp_pa = 0) {
 		return xpcNoRsvdPageAddr;
 	}
 
 
-	/* pull over the reserved page structure */
+	/* pull over the reserved page header and part_nasids mask */
 
 	bres = xp_bte_copy(*remote_rp_pa, ia64_tpa((u64) remote_rp),
-				XPC_RSVD_PAGE_ALIGNED_SIZE,
+				XPC_RP_HEADER_SIZE + xp_nasid_mask_bytes,
 				(BTE_NOTIFY | BTE_WACQUIRE), NULL);
 	if (bres != BTE_SUCCESS) {
 		return xpc_map_bte_errors(bres);
@@ -466,8 +474,11 @@
 
 
 	if (discovered_nasids != NULL) {
-		for (i = 0; i < XP_NASID_MASK_WORDS; i++) {
-			discovered_nasids[i] |= remote_rp->part_nasids[i];
+		u64 *remote_part_nasids = XPC_RP_PART_NASIDS(remote_rp);
+
+
+		for (i = 0; i < xp_nasid_mask_words; i++) {
+			discovered_nasids[i] |= remote_part_nasids[i];
 		}
 	}
 
@@ -494,10 +505,10 @@
 
 
 /*
- * Get a copy of the remote partition's XPC variables.
+ * Get a copy of the remote partition's XPC variables from the reserved page.
  *
  * remote_vars points to a buffer that is cacheline aligned for BTE copies and
- * assumed to be of size XPC_VARS_ALIGNED_SIZE.
+ * assumed to be of size XPC_RP_VARS_SIZE.
  */
 static enum xpc_retval
 xpc_get_remote_vars(u64 remote_vars_pa, struct xpc_vars *remote_vars)
@@ -513,7 +524,7 @@
 	/* pull over the cross partition variables */
 
 	bres = xp_bte_copy(remote_vars_pa, ia64_tpa((u64) remote_vars),
-				XPC_VARS_ALIGNED_SIZE,
+				XPC_RP_VARS_SIZE,
 				(BTE_NOTIFY | BTE_WACQUIRE), NULL);
 	if (bres != BTE_SUCCESS) {
 		return xpc_map_bte_errors(bres);
@@ -778,14 +789,13 @@
 	u64 nasid;			/* remote nasid */
 	int n_IRQs_detected = 0;
 	AMO_t *act_amos;
-	struct xpc_rsvd_page *rp = (struct xpc_rsvd_page *) xpc_rsvd_page;
 
 
 	act_amos = xpc_vars->amos_page + XPC_ACTIVATE_IRQ_AMOS;
 
 
 	/* scan through act AMO variable looking for non-zero entries */
-	for (word = 0; word < XP_NASID_MASK_WORDS; word++) {
+	for (word = 0; word < xp_nasid_mask_words; word++) {
 
 		if (xpc_exiting) {
 			break;
@@ -807,7 +817,7 @@
 		 * remote nasid in our reserved pages machine mask.
 		 * This is used in the event of module reload.
 		 */
-		rp->mach_nasids[word] |= nasid_mask;
+		xpc_mach_nasids[word] |= nasid_mask;
 
 
 		/* locate the nasid(s) which sent interrupts */
@@ -992,6 +1002,7 @@
 	u64 remote_rp_pa;
 	u64 remote_vars_pa;
 	int region;
+	int region_size;
 	int max_regions;
 	int nasid;
 	struct xpc_rsvd_page *rp;
@@ -1001,7 +1012,8 @@
 	enum xpc_retval ret;
 
 
-	remote_rp = xpc_kmalloc_cacheline_aligned(XPC_RSVD_PAGE_ALIGNED_SIZE,
+	remote_rp = xpc_kmalloc_cacheline_aligned(XPC_RP_HEADER_SIZE +
+						xp_nasid_mask_bytes,
 						GFP_KERNEL, &remote_rp_base);
 	if (remote_rp = NULL) {
 		return;
@@ -1009,13 +1021,13 @@
 	remote_vars = (struct xpc_vars *) remote_rp;
 
 
-	discovered_nasids = kmalloc(sizeof(u64) * XP_NASID_MASK_WORDS,
+	discovered_nasids = kmalloc(sizeof(u64) * xp_nasid_mask_words,
 							GFP_KERNEL);
 	if (discovered_nasids = NULL) {
 		kfree(remote_rp_base);
 		return;
 	}
-	memset(discovered_nasids, 0, sizeof(u64) * XP_NASID_MASK_WORDS);
+	memset(discovered_nasids, 0, sizeof(u64) * xp_nasid_mask_words);
 
 	rp = (struct xpc_rsvd_page *) xpc_rsvd_page;
 
@@ -1024,11 +1036,19 @@
 	 * nodes that can comprise an access protection grouping. The access
 	 * protection is in regards to memory, IOI and IPI.
 	 */
-//>>> move the next two #defines into either include/asm-ia64/sn/arch.h or
-//>>> include/asm-ia64/sn/addrs.h
-#define SH1_MAX_REGIONS		64
-#define SH2_MAX_REGIONS		256
-	max_regions = is_shub2() ? SH2_MAX_REGIONS : SH1_MAX_REGIONS;
+	max_regions = 64;
+	region_size = sn_region_size;
+
+	switch (region_size) {
+	case 128:
+		max_regions *= 2;
+	case 64:
+		max_regions *= 2;
+	case 32:
+		max_regions *= 2;
+		region_size = 16;
+		DBUG_ON(!is_shub2());
+	}
 
 	for (region = 0; region < max_regions; region++) {
 
@@ -1038,8 +1058,8 @@
 
 		dev_dbg(xpc_part, "searching region %d\n", region);
 
-		for (nasid = (region * sn_region_size * 2);
-		     nasid < ((region + 1) * sn_region_size * 2);
+		for (nasid = (region * region_size * 2);
+		     nasid < ((region + 1) * region_size * 2);
 		     nasid += 2) {
 
 			if ((volatile int) xpc_exiting) {
@@ -1049,14 +1069,14 @@
 			dev_dbg(xpc_part, "checking nasid %d\n", nasid);
 
 
-			if (XPC_NASID_IN_ARRAY(nasid, rp->part_nasids)) {
+			if (XPC_NASID_IN_ARRAY(nasid, xpc_part_nasids)) {
 				dev_dbg(xpc_part, "PROM indicates Nasid %d is "
 					"part of the local partition; skipping "
 					"region\n", nasid);
 				break;
 			}
 
-			if (!(XPC_NASID_IN_ARRAY(nasid, rp->mach_nasids))) {
+			if (!(XPC_NASID_IN_ARRAY(nasid, xpc_mach_nasids))) {
 				dev_dbg(xpc_part, "PROM indicates Nasid %d was "
 					"not on Numa-Link network at reset\n",
 					nasid);
@@ -1178,12 +1198,12 @@
 		return xpcPartitionDown;
 	}
 
-	part_nasid_pa = part->remote_rp_pa +
-		(u64) &((struct xpc_rsvd_page *) 0)->part_nasids;
+	memset(nasid_mask, 0, XP_NASID_MASK_BYTES);
+
+	part_nasid_pa = (u64) XPC_RP_PART_NASIDS(part->remote_rp_pa);
 
 	bte_res = xp_bte_copy(part_nasid_pa, ia64_tpa((u64) nasid_mask),
-				L1_CACHE_ALIGN(XP_NASID_MASK_BYTES),
-				(BTE_NOTIFY | BTE_WACQUIRE), NULL);
+			xp_nasid_mask_bytes, (BTE_NOTIFY | BTE_WACQUIRE), NULL);
 
 	return xpc_map_bte_errors(bte_res);
 }
Index: linux-2.6.git-test/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.git-test.orig/arch/ia64/sn/kernel/xpc_main.c	2005-10-25 13:29:36.028345085 -0500
+++ linux-2.6.git-test/arch/ia64/sn/kernel/xpc_main.c	2005-10-25 13:29:55.171935516 -0500
@@ -1053,11 +1053,11 @@
 
 	/*
 	 * xpc_remote_copy_buffer is used as a temporary buffer for bte_copy'ng
-	 * both a partition's reserved page and its XPC variables. Its size was
-	 * based on the size of a reserved page. So we need to ensure that the
-	 * XPC variables will fit as well.
+	 * various portions of a partition's reserved page. Its size is based
+	 * on the size of the reserved page header and part_nasids mask. So we
+	 * need to ensure that the other items will fit as well.
 	 */
-	if (XPC_VARS_ALIGNED_SIZE > XPC_RSVD_PAGE_ALIGNED_SIZE) {
+	if (XPC_RP_VARS_SIZE > XPC_RP_HEADER_SIZE + XP_NASID_MASK_BYTES) {
 		dev_err(xpc_part, "xpc_remote_copy_buffer is not big enough\n");
 		return -EPERM;
 	}
