From: Jack Steiner <steiner@sgi.com>
Date: Tue, 04 Nov 2003 20:26:24 +0000
Subject: Patch to fix "is_headless_node()" for SN
Message-Id: <marc-linux-ia64-106797787702028@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The macro for determining whether a node has cpus is incorect
for SN. Here is a fix:


--- linux_base/include/asm-ia64/sn/nodepda.h	Tue Nov  4 14:23:55 2003
+++ linux/include/asm-ia64/sn/nodepda.h	Tue Nov  4 14:22:11 2003
@@ -128,7 +128,7 @@
  * Check if given a compact node id the corresponding node has all the
  * cpus disabled. 
  */
-#define is_headless_node(cnode)		(!node_to_cpu_mask[cnode])
+#define is_headless_node(cnode)		(nr_cpus_node(cnode) = 0)
 
 /*
  * Check if given a node vertex handle the corresponding node has all the





-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


