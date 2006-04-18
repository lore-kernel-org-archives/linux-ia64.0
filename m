From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Tue, 18 Apr 2006 22:02:17 +0000
Subject: [patch] SN SAL call to inject memory errors
Message-Id: <200604182202.k3IM2HjH175182@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] SN SAL call to inject memory errors

The SGI Altix SAL provides an interface for modifying 
the ECC on memory to create memory errors.  The SAL call
can be used to inject memory errors for testing MCA recovery
code.

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 include/asm-ia64/sn/sn_sal.h |   13 +++++++++++++
 1 file changed, 13 insertions(+)

Index: test/include/asm-ia64/sn/sn_sal.h
=================================--- test.orig/include/asm-ia64/sn/sn_sal.h	2006-04-18 16:17:24.662610451 -0500
+++ test/include/asm-ia64/sn/sn_sal.h	2006-04-18 16:29:09.176872976 -0500
@@ -85,6 +85,7 @@
 
 #define  SN_SAL_GET_PROM_FEATURE_SET		   0x02000065
 #define  SN_SAL_SET_OS_FEATURE_SET		   0x02000066
+#define  SN_SAL_INJECT_ERROR			   0x02000067
 
 /*
  * Service-specific constants
@@ -1138,4 +1139,16 @@ ia64_sn_set_os_feature(int feature)
 	return rv.status;
 }
 
+static inline int
+sn_inject_error(u64 paddr, u64 *data, u64 *ecc)
+{
+	struct ia64_sal_retval ret_stuff;
+	unsigned long irq_flags;
+
+	local_irq_save(irq_flags);
+	ia64_sal_oemcall_nolock(&ret_stuff, SN_SAL_INJECT_ERROR, paddr, (u64)data,
+				(u64)ecc, 0, 0, 0, 0);
+	local_irq_restore(irq_flags);
+	return ret_stuff.status;
+}
 #endif /* _ASM_IA64_SN_SN_SAL_H */
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
