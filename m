From: Jack Steiner <steiner@sgi.com>
Date: Fri, 18 Nov 2005 22:11:27 +0000
Subject: [PATCH] - SN support for older versions of PROM - second try
Message-Id: <20051118221127.GA3123@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051118151911.GA10918@sgi.com>
In-Reply-To: <20051118151911.GA10918@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Second try. I missed some code for supporting partitioned systems
in the first patch.



Add support for old versions of the SN PROMs. Eventually this
support will be deleted but it is useful right now to continue 
supporting older PROMs.

	Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	2005-11-18 08:21:42.608445510 -0600
+++ linux/include/asm-ia64/sn/sn_sal.h	2005-11-18 10:27:29.460540516 -0600
@@ -56,6 +56,7 @@
 #define  SN_SAL_BUS_CONFIG		   	   0x02000037
 #define  SN_SAL_SYS_SERIAL_GET			   0x02000038
 #define  SN_SAL_PARTITION_SERIAL_GET		   0x02000039
+#define  SN_SAL_SYSCTL_PARTITION_GET               0x0200003a
 #define  SN_SAL_SYSTEM_POWER_DOWN		   0x0200003b
 #define  SN_SAL_GET_MASTER_BASEIO_NASID		   0x0200003c
 #define  SN_SAL_COHERENCE                          0x0200003d
@@ -581,6 +582,21 @@ sn_partition_serial_number_val(void) {
 }
 
 /*
+ * Returns the partition id of the nasid passed in as an argument,
+ * or INVALID_PARTID if the partition id cannot be retrieved.
+ */
+static inline partid_t
+ia64_sn_sysctl_partition_get(nasid_t nasid)
+{
+	struct ia64_sal_retval ret_stuff;
+	SAL_CALL(ret_stuff, SN_SAL_SYSCTL_PARTITION_GET, nasid,
+		0, 0, 0, 0, 0, 0);
+	if (ret_stuff.status != 0)
+	    return -1;
+	return ((partid_t)ret_stuff.v0);
+}
+
+/*
  * Returns the physical address of the partition's reserved page through
  * an iterative number of calls.
  *
@@ -1018,6 +1034,24 @@ ia64_sn_get_sn_info(int fc, u8 *shubtype
 	ret_stuff.v2 = 0;
 	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_GET_SN_INFO, fc, 0, 0, 0, 0, 0, 0);
 
+/***** BEGIN HACK - temp til old proms no longer supported ********/
+	if (ret_stuff.status = SALRET_NOT_IMPLEMENTED) {
+		int nasid = get_sapicid() & 0xfff;;
+#define SH_SHUB_ID_NODES_PER_BIT_MASK 0x001f000000000000UL
+#define SH_SHUB_ID_NODES_PER_BIT_SHFT 48
+		if (shubtype) *shubtype = 0;
+		if (nasid_bitmask) *nasid_bitmask = 0x7ff;
+		if (nasid_shift) *nasid_shift = 38;
+		if (systemsize) *systemsize = 10;
+		if (sharing_domain_size) *sharing_domain_size = 8;
+		if (partid) *partid = ia64_sn_sysctl_partition_get(nasid);
+		if (coher) *coher = nasid >> 9;
+		if (reg) *reg = (HUB_L((u64 *) LOCAL_MMR_ADDR(SH1_SHUB_ID)) & SH_SHUB_ID_NODES_PER_BIT_MASK) >>
+			SH_SHUB_ID_NODES_PER_BIT_SHFT;
+		return 0;
+	}
+/***** END HACK *******/
+
 	if (ret_stuff.status < 0)
 		return ret_stuff.status;
 
