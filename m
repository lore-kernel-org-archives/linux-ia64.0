From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 04 Nov 2004 17:30:24 +0000
Subject: [PATCH] prefer allocation from nodes w/o CPUs
Message-Id: <200411040930.24930.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_wcmiBhcGQMNci4d"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_wcmiBhcGQMNci4d
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch increases the allocation penalty for nodes with CPUs, which has the 
effect of making nodes w/o CPUs preferred for memory allocations.  Both Altix 
and sx1000 will benefit from using the extra memory before touching the 
memory 'belonging' to other CPUs, so I'm sending it in for inclusion.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_wcmiBhcGQMNci4d
Content-Type: text/plain;
  charset="us-ascii";
  name="prefer-headless-nodes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="prefer-headless-nodes.patch"

===== include/asm-ia64/topology.h 1.13 vs edited =====
--- 1.13/include/asm-ia64/topology.h	2004-10-20 11:20:44 -07:00
+++ edited/include/asm-ia64/topology.h	2004-11-02 12:02:48 -08:00
@@ -18,6 +18,10 @@
 #include <asm/smp.h>
 
 #ifdef CONFIG_NUMA
+
+/* Nodes w/o CPUs are preferred for memory allocations, see build_zonelists */
+#define PENALTY_FOR_NODE_WITH_CPUS 255
+
 /*
  * Returns the number of the node containing CPU 'cpu'
  */

--Boundary-00=_wcmiBhcGQMNci4d--
