From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 04 Nov 2003 18:56:19 +0000
Subject: [PATCH] fix 256 node machines by increasing NODES_SHIFT value
Message-Id: <marc-linux-ia64-106797223026432@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We need 8 bits for the NODE_SHIFT otherwise 256 node systems fail in
weird ways.

Thanks,
Jesse

=== include/asm-ia64/numnodes.h 1.3 vs edited ==--- 1.3/include/asm-ia64/numnodes.h	Wed Oct 22 06:26:08 2003
+++ edited/include/asm-ia64/numnodes.h	Tue Nov  4 10:48:55 2003
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
