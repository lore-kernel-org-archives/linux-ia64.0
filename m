From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 08 Aug 2003 21:45:26 +0000
Subject: [PATCH] is_headless_node fix
Message-Id: <marc-linux-ia64-106037918027371@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix is_headless_node() macro to use node_to_cpumask().

Thanks,
Jesse

diff -Nru a/include/asm-ia64/sn/nodepda.h b/include/asm-ia64/sn/nodepda.h
--- a/include/asm-ia64/sn/nodepda.h	Fri Aug  8 14:44:53 2003
+++ b/include/asm-ia64/sn/nodepda.h	Fri Aug  8 14:44:53 2003
@@ -12,6 +12,7 @@
 #include <linux/config.h>
 #include <asm/sn/sgi.h>
 #include <asm/irq.h>
+#include <asm/topology.h>
 #include <asm/sn/intr.h>
 #include <asm/sn/router.h>
 #include <asm/sn/pda.h>
@@ -127,7 +128,7 @@
  * Check if given a compact node id the corresponding node has all the
  * cpus disabled. 
  */
-#define is_headless_node(cnode)		(!test_bit(cnode, &node_has_active_cpus))
+#define is_headless_node(cnode)		(!node_to_cpumask(cnode))
 
 /*
  * Check if given a node vertex handle the corresponding node has all the
