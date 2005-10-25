From: dcn@sgi.com (Dean Nelson)
Date: Tue, 25 Oct 2005 19:11:53 +0000
Subject: [PATCH] cleanup the way XPC locates the reserved page
Message-Id: <435E8379.mailx5LV11L2VS@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Eliminate the passing in of a scratch buffer used for locating the
reserved page setup for XPC.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6.git-test/arch/ia64/sn/kernel/xpc_partition.c
=================================--- linux-2.6.git-test.orig/arch/ia64/sn/kernel/xpc_partition.c	2005-10-24 13:18:59.192592629 -0500
+++ linux-2.6.git-test/arch/ia64/sn/kernel/xpc_partition.c	2005-10-24 13:22:00.933245452 -0500
@@ -85,13 +85,16 @@
  * for that nasid. This function returns 0 on any error.
  */
 static u64
-xpc_get_rsvd_page_pa(int nasid, u64 buf, u64 buf_size)
+xpc_get_rsvd_page_pa(int nasid)
 {
 	bte_result_t bte_res;
 	s64 status;
 	u64 cookie = 0;
 	u64 rp_pa = nasid;	/* seed with nasid */
 	u64 len = 0;
+	u64 buf = buf;
+	u64 buf_len = 0;
+	void *buf_base = NULL;
 
 
 	while (1) {
@@ -107,13 +110,22 @@
 			break;
 		}
 
-		if (len > buf_size) {
-			dev_err(xpc_part, "len (=0x%016lx) > buf_size\n", len);
-			status = SALRET_ERROR;
-			break;
+		if (L1_CACHE_ALIGN(len) > buf_len) {
+			if (buf_base != NULL) {
+				kfree(buf_base);
+			}
+			buf_len = L1_CACHE_ALIGN(len);
+			buf = (u64) xpc_kmalloc_cacheline_aligned(buf_len,
+							GFP_KERNEL, &buf_base);
+			if (buf_base = NULL) {
+				dev_err(xpc_part, "unable to kmalloc "
+					"len=0x%016lx\n", buf_len);
+				status = SALRET_ERROR;
+				break;
+			}
 		}
 
-		bte_res = xp_bte_copy(rp_pa, ia64_tpa(buf), buf_size,
+		bte_res = xp_bte_copy(rp_pa, ia64_tpa(buf), buf_len,
 					(BTE_NOTIFY | BTE_WACQUIRE), NULL);
 		if (bte_res != BTE_SUCCESS) {
 			dev_dbg(xpc_part, "xp_bte_copy failed %i\n", bte_res);
@@ -122,6 +134,10 @@
 		}
 	}
 
+	if (buf_base != NULL) {
+		kfree(buf_base);
+	}
+
 	if (status != SALRET_OK) {
 		rp_pa = 0;
 	}
@@ -146,10 +162,9 @@
 
 	/* get the local reserved page's address */
 
-	rp_pa = xpc_get_rsvd_page_pa(cnodeid_to_nasid(0),
-					(u64) xpc_remote_copy_buffer,
-						XPC_RP_HEADER_SIZE +
-							L1_CACHE_BYTES);
+	preempt_disable();
+	rp_pa = xpc_get_rsvd_page_pa(cpuid_to_nasid(smp_processor_id()));
+	preempt_enable();
 	if (rp_pa = 0) {
 		dev_err(xpc_part, "SAL failed to locate the reserved page\n");
 		return NULL;
@@ -455,9 +470,7 @@
 
 	/* get the reserved page's physical address */
 
-	*remote_rp_pa = xpc_get_rsvd_page_pa(nasid, (u64) remote_rp,
-						XPC_RP_HEADER_SIZE +
-							xp_nasid_mask_bytes);
+	*remote_rp_pa = xpc_get_rsvd_page_pa(nasid);
 	if (*remote_rp_pa = 0) {
 		return xpcNoRsvdPageAddr;
 	}
