From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 18 Dec 2003 20:16:56 +0000
Subject: [PATCH] make NODES_SHIFT a little biggger
Message-Id: <marc-linux-ia64-107177886023956@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Make NODES_SHIFT larger to accomodate 256 node machines.

Jesse

diff -Nru a/include/asm-ia64/numnodes.h b/include/asm-ia64/numnodes.h
--- a/include/asm-ia64/numnodes.h	Mon Nov 24 12:45:35 2003
+++ b/include/asm-ia64/numnodes.h	Mon Nov 24 12:45:35 2003
@@ -5,8 +5,8 @@
 /* Max 8 Nodes */
 #define NODES_SHIFT	3
 #elif defined(CONFIG_IA64_SGI_SN2) || defined(CONFIG_IA64_GENERIC)
-/* Max 128 Nodes */
-#define NODES_SHIFT	7
+/* Max 256 Nodes */
+#define NODES_SHIFT	8
 #endif
 
 #endif /* _ASM_MAX_NUMNODES_H */
