From: dcn@sgi.com (Dean Nelson)
Date: Wed, 23 Mar 2005 19:04:44 +0000
Subject: [PATCH] convert some sn SAL_CALLs to ia64_sal_oemcall calls
Message-Id: <4241BDCC.mailxH6L1STP24@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Convert some sn SAL_CALLs to ia64_sal_oemcall calls so that they can be
called by kernel modules.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/include/asm-ia64/sn/sn_sal.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/sn_sal.h	2005-03-23 08:26:36.877169780 -0600
+++ linux-2.6/include/asm-ia64/sn/sn_sal.h	2005-03-23 09:41:10.048563921 -0600
@@ -555,7 +555,8 @@
 ia64_sn_partition_serial_get(void)
 {
 	struct ia64_sal_retval ret_stuff;
-	SAL_CALL(ret_stuff, SN_SAL_PARTITION_SERIAL_GET, 0, 0, 0, 0, 0, 0, 0);
+	ia64_sal_oemcall_reentrant(&ret_stuff, SN_SAL_PARTITION_SERIAL_GET, 0,
+				   0, 0, 0, 0, 0, 0);
 	if (ret_stuff.status != 0)
 	    return 0;
 	return ret_stuff.v0;
@@ -563,11 +564,10 @@
 
 static inline u64
 sn_partition_serial_number_val(void) {
-	if (sn_partition_serial_number) {
-		return(sn_partition_serial_number);
-	} else {
-		return(sn_partition_serial_number = ia64_sn_partition_serial_get());
+	if (unlikely(sn_partition_serial_number = 0)) {
+		sn_partition_serial_number = ia64_sn_partition_serial_get();
 	}
+	return sn_partition_serial_number;
 }
 
 /*
@@ -578,8 +578,8 @@
 ia64_sn_sysctl_partition_get(nasid_t nasid)
 {
 	struct ia64_sal_retval ret_stuff;
-	SAL_CALL(ret_stuff, SN_SAL_SYSCTL_PARTITION_GET, nasid,
-		 0, 0, 0, 0, 0, 0);
+	ia64_sal_oemcall_nolock(&ret_stuff, SN_SAL_SYSCTL_PARTITION_GET, nasid,
+				0, 0, 0, 0, 0, 0);
 	if (ret_stuff.status != 0)
 	    return INVALID_PARTID;
 	return ((partid_t)ret_stuff.v0);
@@ -593,11 +593,38 @@
 
 static inline partid_t
 sn_local_partid(void) {
-	if (sn_partid < 0) {
-		return (sn_partid = ia64_sn_sysctl_partition_get(cpuid_to_nasid(smp_processor_id())));
-	} else {
-		return sn_partid;
+	if (unlikely(sn_partid < 0)) {
+		sn_partid = ia64_sn_sysctl_partition_get(cpuid_to_nasid(smp_processor_id()));
 	}
+	return sn_partid;
+}
+
+/*
+ * Returns the physical address of the partition's reserved page through
+ * an iterative number of calls.
+ *
+ * On first call, 'cookie' and 'len' should be set to 0, and 'addr'
+ * set to the nasid of the partition whose reserved page's address is
+ * being sought.
+ * On subsequent calls, pass the values, that were passed back on the
+ * previous call.
+ *
+ * While the return status equals SALRET_MORE_PASSES, keep calling
+ * this function after first copying 'len' bytes starting at 'addr'
+ * into 'buf'. Once the return status equals SALRET_OK, 'addr' will
+ * be the physical address of the partition's reserved page. If the
+ * return status equals neither of these, an error as occurred.
+ */
+static inline s64
+sn_partition_reserved_page_pa(u64 buf, u64 *cookie, u64 *addr, u64 *len)
+{
+	struct ia64_sal_retval rv;
+	ia64_sal_oemcall_reentrant(&rv, SN_SAL_GET_PARTITION_ADDR, *cookie,
+				   *addr, buf, *len, 0, 0, 0);
+	*cookie = rv.v0;
+	*addr = rv.v1;
+	*len = rv.v2;
+	return rv.status;
 }
 
 /*
@@ -619,8 +646,8 @@
 sn_register_xp_addr_region(u64 paddr, u64 len, int operation)
 {
 	struct ia64_sal_retval ret_stuff;
-	SAL_CALL(ret_stuff, SN_SAL_XP_ADDR_REGION, paddr, len, (u64)operation,
-		 0, 0, 0, 0);
+	ia64_sal_oemcall(&ret_stuff, SN_SAL_XP_ADDR_REGION, paddr, len,
+			 (u64)operation, 0, 0, 0, 0);
 	return ret_stuff.status;
 }
 
@@ -644,8 +671,8 @@
 	} else {
 		call = SN_SAL_NO_FAULT_ZONE_PHYSICAL;
 	}
-	SAL_CALL(ret_stuff, call, start_addr, end_addr, return_addr, (u64)1,
-		 0, 0, 0);
+	ia64_sal_oemcall(&ret_stuff, call, start_addr, end_addr, return_addr,
+			 (u64)1, 0, 0, 0);
 	return ret_stuff.status;
 }
 
@@ -666,8 +693,8 @@
 sn_change_coherence(u64 *new_domain, u64 *old_domain)
 {
 	struct ia64_sal_retval ret_stuff;
-	SAL_CALL(ret_stuff, SN_SAL_COHERENCE, new_domain, old_domain, 0, 0,
-		 0, 0, 0);
+	ia64_sal_oemcall(&ret_stuff, SN_SAL_COHERENCE, (u64)new_domain,
+			 (u64)old_domain, 0, 0, 0, 0, 0);
 	return ret_stuff.status;
 }
 
@@ -686,8 +713,8 @@
 	cnodeid = nasid_to_cnodeid(get_node_number(paddr));
 	// spin_lock(&NODEPDA(cnodeid)->bist_lock);
 	local_irq_save(irq_flags);
-	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_MEMPROTECT, paddr, len, nasid_array,
-		 perms, 0, 0, 0);
+	ia64_sal_oemcall_nolock(&ret_stuff, SN_SAL_MEMPROTECT, paddr, len,
+				(u64)nasid_array, perms, 0, 0, 0);
 	local_irq_restore(irq_flags);
 	// spin_unlock(&NODEPDA(cnodeid)->bist_lock);
 	return ret_stuff.status;
