From: Russ Anderson <rja@sgi.com>
Date: Mon, 30 Oct 2006 22:43:49 +0000
Subject: [patch] More Itanium PAL spec updates
Message-Id: <200610302243.k9UMhnr723897048@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] More Itanium PAL spec updates

Additional updates to conform with Rev 2.2 of Volume 2 of "Intel
Itanium Architecture Software Developer's Manual" (January 2006).

Add pal_bus_features_s bits 52 & 53 (page 2:347)
Add pal_vm_info_2_s field max_purges (page 2:2:451)
Add PAL_GET_HW_POLICY call (page 2:381)
Add PAL_SET_HW_POLICY call (page 2:439)
Add PAL_MEMORY_BUFFER call (page 2:421)

Sample output before:
---------------------------------------------------------------------
cobra:~ # cat /proc/pal/cpu0/vm_info
Physical Address Space         : 50 bits
Virtual Address Space          : 61 bits
Protection Key Registers(PKR)  : 16
Implemented bits in PKR.key    : 24
Hash Tag ID                    : 0x2
Size of RR.rid                 : 24
Supported memory attributes    : WB, UC, UCE, WC, NaTPage
---------------------------------------------------------------------

Sample output after:
---------------------------------------------------------------------
cobra:~ # cat /proc/pal/cpu0/vm_info
Physical Address Space         : 50 bits
Virtual Address Space          : 61 bits
Protection Key Registers(PKR)  : 16
Implemented bits in PKR.key    : 24
Hash Tag ID                    : 0x2
Max Purges                     : 1
Size of RR.rid                 : 24
Supported memory attributes    : WB, UC, UCE, WC, NaTPage
---------------------------------------------------------------------

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 arch/ia64/kernel/palinfo.c |    3 ++
 include/asm-ia64/pal.h     |   57 +++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 58 insertions(+), 2 deletions(-)

Index: test/include/asm-ia64/pal.h
=================================--- test.orig/include/asm-ia64/pal.h	2006-10-30 14:39:06.810540257 -0600
+++ test/include/asm-ia64/pal.h	2006-10-30 16:37:36.950578888 -0600
@@ -20,6 +20,8 @@
  * 00/05/24     eranian Updated to latest PAL spec, fix structures bugs, added
  * 00/05/25	eranian Support for stack calls, and static physical calls
  * 00/06/18	eranian Support for stacked physical calls
+ * 06/10/26	rja	Support for Intel Itanium Architecture Software Developer's
+ *			Manual Rev 2.2 (Jan 2006)
  */
 
 /*
@@ -69,6 +71,8 @@
 #define PAL_PREFETCH_VISIBILITY	41	/* Make Processor Prefetches Visible */
 #define PAL_LOGICAL_TO_PHYSICAL 42	/* returns information on logical to physical processor mapping */
 #define PAL_CACHE_SHARED_INFO	43	/* returns information on caches shared by logical processor */
+#define PAL_GET_HW_POLICY	48	/* Get current hardware resource sharing policy */
+#define PAL_SET_HW_POLICY	49	/* Set current hardware resource sharing policy */
 
 #define PAL_COPY_PAL		256	/* relocate PAL procedures and PAL PMI */
 #define PAL_HALT_INFO		257	/* return the low power capabilities of processor */
@@ -79,6 +83,7 @@
 #define PAL_GET_PSTATE		262	/* get the current P-state */
 #define PAL_SET_PSTATE		263	/* set the P-state */
 #define PAL_BRAND_INFO		274	/* Processor branding information */
+#define PAL_MEMORY_BUFFER	277	/* Provide cacheable memory for PAL */
 
 #ifndef __ASSEMBLY__
 
@@ -102,6 +107,7 @@ typedef s64				pal_status_t;
 						 * cache without sideeffects
 						 * and "restrict" was 1
 						 */
+#define PAL_STATUS_REQUIRES_MEMORY	(-9)	/* Call requires PAL memory buffer */
 
 /* Processor cache level in the heirarchy */
 typedef u64				pal_cache_level_t;
@@ -838,7 +844,9 @@ typedef union pal_bus_features_u {
 		u64	pbf_req_bus_parking			:	1;
 		u64	pbf_bus_lock_mask			:	1;
 		u64	pbf_enable_half_xfer_rate		:	1;
-		u64	pbf_reserved2				:	22;
+		u64	pbf_reserved2				:	20;
+		u64	pbf_enable_shared_line_replace		:	1;
+		u64	pbf_enable_exclusive_line_replace	:	1;
 		u64	pbf_disable_xaction_queueing		:	1;
 		u64	pbf_disable_resp_err_check		:	1;
 		u64	pbf_disable_berr_check			:	1;
@@ -1081,6 +1089,24 @@ ia64_pal_freq_ratios (struct pal_freq_ra
 	return iprv.status;
 }
 
+/*
+ * Get the current hardware resource sharing policy of the processor
+ */
+static inline s64
+ia64_pal_get_hw_policy (u64 proc_num, u64 *cur_policy, u64 *num_impacted,
+			u64 *la)
+{
+	struct ia64_pal_retval iprv;
+	PAL_CALL(iprv, PAL_GET_HW_POLICY, proc_num, 0, 0);
+	if (cur_policy)
+		*cur_policy = iprv.v0;
+	if (num_impacted)
+		*num_impacted = iprv.v1;
+	if (la)
+		*la = iprv.v2;
+	return iprv.status;
+}
+
 /* Make the processor enter HALT or one of the implementation dependent low
  * power states where prefetching and execution are suspended and cache and
  * TLB coherency is not maintained.
@@ -1266,6 +1292,21 @@ ia64_pal_mem_for_test (u64 *bytes_needed
 	return iprv.status;
 }
 
+/*
+ * Provides cacheable memory to PAL for exclusive use during runtime
+ */
+static inline s64
+ia64_pal_memory_buffer (u64 base_address, u64 alloc_size, u64 control_word,
+			u64 *min_size)
+{
+	struct ia64_pal_retval iprv;
+	PAL_CALL_PHYS_STK(iprv, PAL_MEMORY_BUFFER, base_address, alloc_size,
+			  control_word);
+	if (min_size)
+		*min_size = iprv.v0;
+	return iprv.status;
+}
+
 typedef union pal_perf_mon_info_u {
 	u64			  ppmi_data;
 	struct {
@@ -1405,6 +1446,17 @@ ia64_pal_rse_info (u64 *num_phys_stacked
 	return iprv.status;
 }
 
+/*
+ * Set the current hardware resource sharing policy of the processor
+ */
+static inline s64
+ia64_pal_set_hw_policy (u64 policy)
+{
+	struct ia64_pal_retval iprv;
+	PAL_CALL(iprv, PAL_SET_HW_POLICY, policy, 0, 0);
+	return iprv.status;
+}
+
 /* Cause the processor to enter	SHUTDOWN state, where prefetching and execution are
  * suspended, but cause cache and TLB coherency to be maintained.
  * This is usually called in IA-32 mode.
@@ -1533,7 +1585,8 @@ typedef union pal_vm_info_2_u {
 	struct {
 		u64		impl_va_msb	: 8,
 				rid_size	: 8,
-				reserved	: 48;
+				max_purges	: 16,
+				reserved	: 32;
 	} pal_vm_info_2_s;
 } pal_vm_info_2_u_t;
 
Index: test/arch/ia64/kernel/palinfo.c
=================================--- test.orig/arch/ia64/kernel/palinfo.c	2006-10-30 14:39:06.810540257 -0600
+++ test/arch/ia64/kernel/palinfo.c	2006-10-30 14:43:20.881714752 -0600
@@ -315,12 +315,15 @@ vm_info(char *page)
 		     "Protection Key Registers(PKR)  : %d\n"
 		     "Implemented bits in PKR.key    : %d\n"
 		     "Hash Tag ID                    : 0x%x\n"
+		     "Max Purges                     : %d\n"
 		     "Size of RR.rid                 : %d\n",
 		     vm_info_1.pal_vm_info_1_s.phys_add_size,
 		     vm_info_2.pal_vm_info_2_s.impl_va_msb+1,
 		     vm_info_1.pal_vm_info_1_s.max_pkr+1,
 		     vm_info_1.pal_vm_info_1_s.key_size,
 		     vm_info_1.pal_vm_info_1_s.hash_tag_id,
+		     vm_info_2.pal_vm_info_2_s.max_purges?
+				vm_info_2.pal_vm_info_2_s.max_purges : 1,
 		     vm_info_2.pal_vm_info_2_s.rid_size);
 	}
 
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
