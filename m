From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Tue, 18 Apr 2006 16:26:34 +0000
Subject: [patch] Remove unused variable in sn_sal.h
Message-Id: <200604181626.k3IGQYFg172104@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Remove unused variable in sn_sal.h

cnodeid was being set but not used.  The dead code was
left over from a previous version that grabbed a per node lock.

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 include/asm-ia64/sn/sn_sal.h |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

Index: test/include/asm-ia64/sn/sn_sal.h
=================================--- test.orig/include/asm-ia64/sn/sn_sal.h	2006-04-18 10:01:31.000000000 -0500
+++ test/include/asm-ia64/sn/sn_sal.h	2006-04-18 10:29:44.931444400 -0500
@@ -8,7 +8,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2005 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2000-2006 Silicon Graphics, Inc.  All rights reserved.
  */
 
 
@@ -705,10 +705,8 @@ static inline int
 sn_change_memprotect(u64 paddr, u64 len, u64 perms, u64 *nasid_array)
 {
 	struct ia64_sal_retval ret_stuff;
-	int cnodeid;
 	unsigned long irq_flags;
 
-	cnodeid = nasid_to_cnodeid(get_node_number(paddr));
 	local_irq_save(irq_flags);
 	ia64_sal_oemcall_nolock(&ret_stuff, SN_SAL_MEMPROTECT, paddr, len,
 				(u64)nasid_array, perms, 0, 0, 0);
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
