From: Jack Steiner <steiner@sgi.com>
Date: Wed, 02 Mar 2005 02:51:56 +0000
Subject: [PATCH 1/2] - New chipset support for SN platform
Message-Id: <20050302025155.GA16290@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Here are 2 additional patches for supporting the next SGI
chipset (shub2).

The patches do the following:

patch 1:
	- add new parameters to a platform-specific SAL 
	  call to retrieve addition chipset specific info.

	- change partition_coherence_id() so that it works
	  on platforms using the new chipset.

patch 2:
	- move a number of fields out of the SN pda & into 
	  per-cpu data. The pda is ugly & will be deleted. 
	  This is a first step. Additional patches will follow.

Signed-off-by: Jack Steiner <steiner@sgi.com>

-------------------------------- -------------------------------------------


Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	2005-03-01 17:40:13.696920037 -0600
+++ linux/include/asm-ia64/sn/sn_sal.h	2005-03-01 18:53:47.473568499 -0600
@@ -18,6 +18,7 @@
 #include <asm/sn/arch.h>
 #include <asm/sn/geo.h>
 #include <asm/sn/nodepda.h>
+#include <asm/sn/shub_mmr.h>
 
 // SGI Specific Calls
 #define  SN_SAL_POD_MODE                           0x02000001
@@ -34,7 +35,7 @@
 #define  SN_SAL_PRINT_ERROR			   0x02000012
 #define  SN_SAL_SET_ERROR_HANDLING_FEATURES	   0x0200001a	// reentrant
 #define  SN_SAL_GET_FIT_COMPT			   0x0200001b	// reentrant
-#define  SN_SAL_GET_HUB_INFO                       0x0200001c
+#define  SN_SAL_GET_SN_INFO                        0x0200001c
 #define  SN_SAL_GET_SAPIC_INFO                     0x0200001d
 #define  SN_SAL_CONSOLE_PUTC                       0x02000021
 #define  SN_SAL_CONSOLE_GETC                       0x02000022
@@ -935,15 +936,24 @@ ia64_sn_get_sapic_info(int sapicid, int 
 /*
  * Returns information about the HUB/SHUB.
  *  In:
- *	arg0 - SN_SAL_GET_HUB_INFO
+ *	arg0 - SN_SAL_GET_SN_INFO
  * 	arg1 - 0 (other values reserved for future use)
  *  Out:
- *	v0 - shub type (0=shub1, 1=shub2)
- *	v1 - masid mask (ex., 0x7ff for 11 bit nasid)
- *	v2 - bit position of low nasid bit
+ *	v0 
+ *		[7:0]   - shub type (0=shub1, 1=shub2)
+ *		[15:8]  - Log2 max number of nodes in entire system (includes
+ *			  C-bricks, I-bricks, etc)
+ *		[23:16] - Log2 of nodes per sharing domain			 
+ * 		[31:24] - partition ID
+ * 		[39:32] - coherency_id
+ * 		[47:40] - regionsize
+ *	v1 
+ *		[15:0]  - nasid mask (ex., 0x7ff for 11 bit nasid)
+ *	 	[23:15] - bit position of low nasid bit
  */
 static inline u64
-ia64_sn_get_hub_info(int fc, u64 *arg1, u64 *arg2, u64 *arg3)
+ia64_sn_get_sn_info(int fc, u8 *shubtype, u16 *nasid_bitmask, u8 *nasid_shift, 
+		u8 *systemsize, u8 *sharing_domain_size, u8 *partid, u8 *coher, u8 *reg)
 {
 	struct ia64_sal_retval ret_stuff;
 
@@ -951,13 +961,22 @@ ia64_sn_get_hub_info(int fc, u64 *arg1, 
 	ret_stuff.v0 = 0;
 	ret_stuff.v1 = 0;
 	ret_stuff.v2 = 0;
-	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_GET_HUB_INFO, fc, 0, 0, 0, 0, 0, 0);
+	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_GET_SN_INFO, fc, 0, 0, 0, 0, 0, 0);
 
 /***** BEGIN HACK - temp til old proms no longer supported ********/
 	if (ret_stuff.status = SALRET_NOT_IMPLEMENTED) {
-		if (arg1) *arg1 = 0;
-		if (arg2) *arg2 = 0x7ff;
-		if (arg3) *arg3 = 38;
+		int nasid = get_sapicid() & 0xfff;;
+#define SH_SHUB_ID_NODES_PER_BIT_MASK 0x001f000000000000UL                                               
+#define SH_SHUB_ID_NODES_PER_BIT_SHFT 48                                                               
+		if (shubtype) *shubtype = 0;
+		if (nasid_bitmask) *nasid_bitmask = 0x7ff;
+		if (nasid_shift) *nasid_shift = 38;
+		if (systemsize) *systemsize = 11;
+		if (sharing_domain_size) *sharing_domain_size = 9;
+		if (partid) *partid = ia64_sn_sysctl_partition_get(nasid);
+		if (coher) *coher = nasid >> 9;
+		if (reg) *reg = (HUB_L((u64 *) LOCAL_MMR_ADDR(SH1_SHUB_ID)) & SH_SHUB_ID_NODES_PER_BIT_MASK) >>
+			SH_SHUB_ID_NODES_PER_BIT_SHFT;
 		return 0;
 	}
 /***** END HACK *******/
@@ -965,9 +984,14 @@ ia64_sn_get_hub_info(int fc, u64 *arg1, 
 	if (ret_stuff.status < 0)
 		return ret_stuff.status;
 
-	if (arg1) *arg1 = ret_stuff.v0;
-	if (arg2) *arg2 = ret_stuff.v1;
-	if (arg3) *arg3 = ret_stuff.v2;
+	if (shubtype) *shubtype = ret_stuff.v0 & 0xff;
+	if (systemsize) *systemsize = (ret_stuff.v0 >> 8) & 0xff;
+	if (sharing_domain_size) *sharing_domain_size = (ret_stuff.v0 >> 16) & 0xff;
+	if (partid) *partid = (ret_stuff.v0 >> 24) & 0xff;
+	if (coher) *coher = (ret_stuff.v0 >> 32) & 0xff;
+	if (reg) *reg = (ret_stuff.v0 >> 40) & 0xff;
+	if (nasid_bitmask) *nasid_bitmask = (ret_stuff.v1 & 0xffff);
+	if (nasid_shift) *nasid_shift = (ret_stuff.v1 >> 16) & 0xff;
 	return 0;
 }
  
Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	2005-03-01 17:40:13.699849690 -0600
+++ linux/arch/ia64/sn/kernel/setup.c	2005-03-01 18:59:07.726652496 -0600
@@ -76,6 +76,16 @@ char sn_system_serial_number_string[128]
 EXPORT_SYMBOL(sn_system_serial_number_string);
 u64 sn_partition_serial_number;
 EXPORT_SYMBOL(sn_partition_serial_number);
+u8 sn_partition_id;
+EXPORT_SYMBOL(sn_partition_id);
+u8 sn_system_size;
+EXPORT_SYMBOL(sn_system_size);
+u8 sn_sharing_domain_size;
+EXPORT_SYMBOL(sn_sharing_domain_size);
+u8 sn_coherency_id;
+EXPORT_SYMBOL(sn_coherency_id);
+u8 sn_region_size;
+EXPORT_SYMBOL(sn_region_size);
 
 short physical_node_map[MAX_PHYSNODE_ID];
 
@@ -424,15 +434,13 @@ void __init sn_cpu_init(void)
 	int slice;
 	int cnode;
 	int i;
-	u64 shubtype, nasid_bitmask, nasid_shift;
 	static int wars_have_been_checked;
 
 	memset(pda, 0, sizeof(pda));
-	if (ia64_sn_get_hub_info(0, &shubtype, &nasid_bitmask, &nasid_shift))
+	if (ia64_sn_get_sn_info(0, &pda->shub2, &pda->nasid_bitmask, &pda->nasid_shift, 
+				&sn_system_size, &sn_sharing_domain_size, &sn_partition_id,
+				&sn_coherency_id, &sn_region_size))
 		BUG();
-	pda->shub2 = (u8)shubtype;
-	pda->nasid_bitmask = (u16)nasid_bitmask;
-	pda->nasid_shift = (u8)nasid_shift;
 	pda->as_shift = pda->nasid_shift - 2;
 
 	/*
Index: linux/include/asm-ia64/sn/sn_cpuid.h
=================================--- linux.orig/include/asm-ia64/sn/sn_cpuid.h	2005-03-01 17:40:13.698873139 -0600
+++ linux/include/asm-ia64/sn/sn_cpuid.h	2005-03-01 17:44:01.190297397 -0600
@@ -135,9 +135,10 @@ extern int nasid_slice_to_cpuid(int, int
 #define nasid_to_cnodeid(nasid)		(physical_node_map[nasid])
 
 /*
- * partition_coherence_id - cget the coherence ID of the current partition
+ * partition_coherence_id - get the coherence ID of the current partition
  */
-#define partition_coherence_id()	(get_nasid() >> 9)
+extern u8 sn_coherency_id;
+#define partition_coherence_id()	(sn_coherency_id)
 
 #endif /* _ASM_IA64_SN_SN_CPUID_H */
 
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


