From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 09 Oct 2003 16:09:38 +0000
Subject: [PATCH] fix is_headless_node() for systems w/<64p
Message-Id: <marc-linux-ia64-106571607829917@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I didn't realize that any_online_cpu() wouldn't work for
is_headless_node(), so this patch reverts the function back to using the
node_to_cpu_mask[] array, fixing sn2 for systems with less than 64p.

Thanks,
Jesse

=== include/asm-ia64/sn/nodepda.h 1.9 vs edited ==--- 1.9/include/asm-ia64/sn/nodepda.h	Tue Sep  9 04:19:45 2003
+++ edited/include/asm-ia64/sn/nodepda.h	Wed Oct  1 10:28:12 2003
@@ -128,7 +128,7 @@
  * Check if given a compact node id the corresponding node has all the
  * cpus disabled. 
  */
-#define is_headless_node(cnode)		(!any_online_cpu(node_to_cpumask(cnode)))
+#define is_headless_node(cnode)		(!node_to_cpu_mask[cnode])
 
 /*
  * Check if given a node vertex handle the corresponding node has all the
