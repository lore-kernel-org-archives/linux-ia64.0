From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Thu, 24 Aug 2006 16:08:52 +0000
Subject: [patch] remove redundant local_irq_save() calls from sn_sal.h
Message-Id: <200608241608.k7OG8r1x2318881@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] remove redundant local_irq_save() calls from sn_sal.h

Tony, a small cleanup patch.

sn_change_memprotect() does a local_irq_save() then calls 
ia64_sal_oemcall_nolock() which calls SAL_CALL_NOLOCK()
which also does a local_irq_save().  

This patch removes the redundant local_irq_save() and local_irq_restore()
calls in sn_change_memprotect() and sn_inject_error().

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 include/asm-ia64/sn/sn_sal.h |    6 ------
 1 file changed, 6 deletions(-)

Index: test/include/asm-ia64/sn/sn_sal.h
=================================--- test.orig/include/asm-ia64/sn/sn_sal.h	2006-07-17 16:20:27.000000000 -0500
+++ test/include/asm-ia64/sn/sn_sal.h	2006-08-24 10:28:57.088378046 -0500
@@ -706,12 +706,9 @@ static inline int
 sn_change_memprotect(u64 paddr, u64 len, u64 perms, u64 *nasid_array)
 {
 	struct ia64_sal_retval ret_stuff;
-	unsigned long irq_flags;
 
-	local_irq_save(irq_flags);
 	ia64_sal_oemcall_nolock(&ret_stuff, SN_SAL_MEMPROTECT, paddr, len,
 				(u64)nasid_array, perms, 0, 0, 0);
-	local_irq_restore(irq_flags);
 	return ret_stuff.status;
 }
 #define SN_MEMPROT_ACCESS_CLASS_0		0x14a080
@@ -1143,12 +1140,9 @@ static inline int
 sn_inject_error(u64 paddr, u64 *data, u64 *ecc)
 {
 	struct ia64_sal_retval ret_stuff;
-	unsigned long irq_flags;
 
-	local_irq_save(irq_flags);
 	ia64_sal_oemcall_nolock(&ret_stuff, SN_SAL_INJECT_ERROR, paddr, (u64)data,
 				(u64)ecc, 0, 0, 0, 0);
-	local_irq_restore(irq_flags);
 	return ret_stuff.status;
 }
 
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
