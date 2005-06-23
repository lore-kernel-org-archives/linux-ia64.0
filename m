From: davidm@mostang.com (David Mosberger-Tang)
Date: Thu, 23 Jun 2005 05:24:16 +0000
Subject: [patch] pfn_to_nid() compile-fix
Message-Id: <20050623052416.14091D41B8@panda.mostang.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Without this patch, the current git tree doesn't compile unless
CONFIG_DISCONTIGMEM is specified.  The problem is that linux/mmzone.h
defines its own version of pfn_to_nid in that case.

	--david

[IA64] Fix pfn_to_nid() so the kernel compiles again for !CONFIG_DISCONTIGMEM.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

diff --git a/include/asm-ia64/mmzone.h b/include/asm-ia64/mmzone.h
--- a/include/asm-ia64/mmzone.h
+++ b/include/asm-ia64/mmzone.h
@@ -15,6 +15,8 @@
 #include <asm/page.h>
 #include <asm/meminit.h>
 
+#ifdef CONFIG_DISCONTIGMEM
+
 static inline int pfn_to_nid(unsigned long pfn)
 {
 #ifdef CONFIG_NUMA
@@ -29,8 +31,6 @@ static inline int pfn_to_nid(unsigned lo
 #endif
 }
 
-#ifdef CONFIG_DISCONTIGMEM
-
 #ifdef CONFIG_IA64_DIG /* DIG systems are small */
 # define MAX_PHYSNODE_ID	8
 # define NR_NODE_MEMBLKS	(MAX_NUMNODES * 8)
