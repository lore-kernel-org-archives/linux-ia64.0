From: Russ Anderson <rja@sgi.com>
Date: Mon, 06 Nov 2006 22:45:18 +0000
Subject: Re: [patch] More Itanium PAL spec updates
Message-Id: <200611062245.kA6MjIcK33556787@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200610302243.k9UMhnr723897048@clink.americas.sgi.com>
In-Reply-To: <200610302243.k9UMhnr723897048@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> +#define PAL_MEMORY_BUFFER	277	/* Provide cacheable memory for PAL */
> 
> This call looks like a new headache for kexec :-(  While there are
> hooks to relocate the buffer, I can't see a way to just take back
> the buffer ... which makes life hard when kexec'ing from one kernel
> to a possibly entirely unrelated OS.  It might be a whole lot better
> if the OS didn't touch this (SAL or EFI could set up the buffer?)

I've pulled the PAL_MEMORY_BUFFER part out of this patch.
It can be debated as its own patch.

> +		     "Max Purges                     : %d\n"
>  		     "Size of RR.rid                 : %d\n",
>  		     vm_info_1.pal_vm_info_1_s.phys_add_size,
>  		     vm_info_2.pal_vm_info_2_s.impl_va_msb+1,
>  		     vm_info_1.pal_vm_info_1_s.max_pkr+1,
>  		     vm_info_1.pal_vm_info_1_s.key_size,
>  		     vm_info_1.pal_vm_info_1_s.hash_tag_id,
> +		     vm_info_2.pal_vm_info_2_s.max_purges?
> +				vm_info_2.pal_vm_info_2_s.max_purges : 1,
> 
> max_purges == 65535 means "unlimited".  Should we be helpful here > and
> print an explicit "unlimited" ... or rely on users having read SDM page
> 2:451?

Added the printing of "unlimited".

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 arch/ia64/kernel/palinfo.c |    9 ++++++++-
 include/asm-ia64/pal.h     |   43 +++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 49 insertions(+), 3 deletions(-)

Index: test/include/asm-ia64/pal.h
=================================--- test.orig/include/asm-ia64/pal.h	2006-10-30 14:39:06.810540257 -0600
+++ test/include/asm-ia64/pal.h	2006-11-06 16:28:04.616911109 -0600
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
@@ -102,6 +106,7 @@ typedef s64				pal_status_t;
 						 * cache without sideeffects
 						 * and "restrict" was 1
 						 */
+#define PAL_STATUS_REQUIRES_MEMORY	(-9)	/* Call requires PAL memory buffer */
 
 /* Processor cache level in the heirarchy */
 typedef u64				pal_cache_level_t;
@@ -838,7 +843,9 @@ typedef union pal_bus_features_u {
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
@@ -1081,6 +1088,24 @@ ia64_pal_freq_ratios (struct pal_freq_ra
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
@@ -1405,6 +1430,17 @@ ia64_pal_rse_info (u64 *num_phys_stacked
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
@@ -1528,12 +1564,15 @@ typedef union pal_vm_info_1_u {
 	} pal_vm_info_1_s;
 } pal_vm_info_1_u_t;
 
+#define PAL_MAX_PURGES		0xFFFF		/* all ones is means unlimited */
+
 typedef union pal_vm_info_2_u {
 	u64			pvi2_val;
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
+++ test/arch/ia64/kernel/palinfo.c	2006-11-06 11:09:57.152160107 -0600
@@ -315,13 +315,20 @@ vm_info(char *page)
 		     "Protection Key Registers(PKR)  : %d\n"
 		     "Implemented bits in PKR.key    : %d\n"
 		     "Hash Tag ID                    : 0x%x\n"
-		     "Size of RR.rid                 : %d\n",
+		     "Size of RR.rid                 : %d\n"
+		     "Max Purges                     : ",
 		     vm_info_1.pal_vm_info_1_s.phys_add_size,
 		     vm_info_2.pal_vm_info_2_s.impl_va_msb+1,
 		     vm_info_1.pal_vm_info_1_s.max_pkr+1,
 		     vm_info_1.pal_vm_info_1_s.key_size,
 		     vm_info_1.pal_vm_info_1_s.hash_tag_id,
 		     vm_info_2.pal_vm_info_2_s.rid_size);
+		if (vm_info_2.pal_vm_info_2_s.max_purges = PAL_MAX_PURGES)
+			p += sprintf(p, "unlimited\n");
+		else
+			p += sprintf(p, "%d\n",
+		     		vm_info_2.pal_vm_info_2_s.max_purges ?
+				vm_info_2.pal_vm_info_2_s.max_purges : 1);
 	}
 
 	if (ia64_pal_mem_attrib(&attrib) = 0) {

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
