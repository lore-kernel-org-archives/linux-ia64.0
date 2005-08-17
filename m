From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Wed, 17 Aug 2005 17:00:21 +0000
Subject: [patch] SGI SN remove redundant partition SAL call
Message-Id: <200508171700.j7HH0MvN2051238@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] SGI SN remove redundant partition SAL call

Clean up of SGI SN partitioning related code.
The SN_SAL_GET_SN_INFO SAL call returns the partition ID, making
the SN_SAL_SYSCTL_PARTITION_GET SAL call redundant.  Remove sn_partid
and use sn_partition_id.

This patch applies on top of Jack Steiner's "New SN hardware support" patches
amd Mark Goodwin's "SGI SN hwperf enhancements" patches.  All the changes
are in ia64/sn code.

Signed-off-by: Russ Anderson (rja@sgi.com)


-----------------------------------------------------------------------
 arch/ia64/sn/kernel/setup.c          |    2 -
 arch/ia64/sn/kernel/sn2/sn_proc_fs.c |    4 +-
 include/asm-ia64/sn/geo.h            |    3 --
 include/asm-ia64/sn/sn_sal.h         |   48 -----------------------------------
 4 files changed, 3 insertions(+), 54 deletions(-)

Index: test-2.6/arch/ia64/sn/kernel/setup.c
=================================--- test-2.6.orig/arch/ia64/sn/kernel/setup.c	2005-08-16 10:13:57.149795507 -0500
+++ test-2.6/arch/ia64/sn/kernel/setup.c	2005-08-16 10:17:43.060832341 -0500
@@ -80,8 +80,6 @@ EXPORT_PER_CPU_SYMBOL(__sn_cnodeid_to_na
 DEFINE_PER_CPU(struct nodepda_s *, __sn_nodepda);
 EXPORT_PER_CPU_SYMBOL(__sn_nodepda);
 
-partid_t sn_partid = -1;
-EXPORT_SYMBOL(sn_partid);
 char sn_system_serial_number_string[128];
 EXPORT_SYMBOL(sn_system_serial_number_string);
 u64 sn_partition_serial_number;
Index: test-2.6/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
=================================--- test-2.6.orig/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	2005-08-16 10:13:57.150771972 -0500
+++ test-2.6/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	2005-08-16 10:17:43.061808806 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2000-2005 Silicon Graphics, Inc. All rights reserved.
  */
 #include <linux/config.h>
 #include <asm/uaccess.h>
@@ -15,7 +15,7 @@
 
 static int partition_id_show(struct seq_file *s, void *p)
 {
-	seq_printf(s, "%d\n", sn_local_partid());
+	seq_printf(s, "%d\n", sn_partition_id);
 	return 0;
 }
 
Index: test-2.6/include/asm-ia64/sn/sn_sal.h
=================================--- test-2.6.orig/include/asm-ia64/sn/sn_sal.h	2005-08-16 10:15:18.694387720 -0500
+++ test-2.6/include/asm-ia64/sn/sn_sal.h	2005-08-16 10:17:43.063761736 -0500
@@ -55,7 +55,6 @@
 #define  SN_SAL_BUS_CONFIG		   	   0x02000037
 #define  SN_SAL_SYS_SERIAL_GET			   0x02000038
 #define  SN_SAL_PARTITION_SERIAL_GET		   0x02000039
-#define  SN_SAL_SYSCTL_PARTITION_GET		   0x0200003a
 #define  SN_SAL_SYSTEM_POWER_DOWN		   0x0200003b
 #define  SN_SAL_GET_MASTER_BASEIO_NASID		   0x0200003c
 #define  SN_SAL_COHERENCE                          0x0200003d
@@ -587,35 +586,6 @@ sn_partition_serial_number_val(void) {
 }
 
 /*
- * Returns the partition id of the nasid passed in as an argument,
- * or INVALID_PARTID if the partition id cannot be retrieved.
- */
-static inline partid_t
-ia64_sn_sysctl_partition_get(nasid_t nasid)
-{
-	struct ia64_sal_retval ret_stuff;
-	ia64_sal_oemcall_nolock(&ret_stuff, SN_SAL_SYSCTL_PARTITION_GET, nasid,
-				0, 0, 0, 0, 0, 0);
-	if (ret_stuff.status != 0)
-	    return INVALID_PARTID;
-	return ((partid_t)ret_stuff.v0);
-}
-
-/*
- * Returns the partition id of the current processor.
- */
-
-extern partid_t sn_partid;
-
-static inline partid_t
-sn_local_partid(void) {
-	if (unlikely(sn_partid < 0)) {
-		sn_partid = ia64_sn_sysctl_partition_get(cpuid_to_nasid(smp_processor_id()));
-	}
-	return sn_partid;
-}
-
-/*
  * Returns the physical address of the partition's reserved page through
  * an iterative number of calls.
  *
@@ -1020,24 +990,6 @@ ia64_sn_get_sn_info(int fc, u8 *shubtype
 	ret_stuff.v2 = 0;
 	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_GET_SN_INFO, fc, 0, 0, 0, 0, 0, 0);
 
-/***** BEGIN HACK - temp til old proms no longer supported ********/
-	if (ret_stuff.status = SALRET_NOT_IMPLEMENTED) {
-		int nasid = get_sapicid() & 0xfff;;
-#define SH_SHUB_ID_NODES_PER_BIT_MASK 0x001f000000000000UL                                               
-#define SH_SHUB_ID_NODES_PER_BIT_SHFT 48                                                               
-		if (shubtype) *shubtype = 0;
-		if (nasid_bitmask) *nasid_bitmask = 0x7ff;
-		if (nasid_shift) *nasid_shift = 38;
-		if (systemsize) *systemsize = 11;
-		if (sharing_domain_size) *sharing_domain_size = 9;
-		if (partid) *partid = ia64_sn_sysctl_partition_get(nasid);
-		if (coher) *coher = nasid >> 9;
-		if (reg) *reg = (HUB_L((u64 *) LOCAL_MMR_ADDR(SH1_SHUB_ID)) & SH_SHUB_ID_NODES_PER_BIT_MASK) >>
-			SH_SHUB_ID_NODES_PER_BIT_SHFT;
-		return 0;
-	}
-/***** END HACK *******/
-
 	if (ret_stuff.status < 0)
 		return ret_stuff.status;
 
Index: test-2.6/include/asm-ia64/sn/geo.h
=================================--- test-2.6.orig/include/asm-ia64/sn/geo.h	2005-08-16 10:13:57.151748437 -0500
+++ test-2.6/include/asm-ia64/sn/geo.h	2005-08-16 10:17:43.066691131 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992 - 1997, 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1992 - 1997, 2000-2005 Silicon Graphics, Inc. All rights reserved.
  */
 
 #ifndef _ASM_IA64_SN_GEO_H
@@ -108,7 +108,6 @@ typedef union geoid_u {
 #define INVALID_SLAB            (slabid_t)-1
 #define INVALID_SLOT            (slotid_t)-1
 #define INVALID_MODULE          ((moduleid_t)-1)
-#define INVALID_PARTID          ((partid_t)-1)
 
 static inline slabid_t geo_slab(geoid_t g)
 {
