From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 04 Nov 2004 16:57:25 +0000
Subject: [RFC] prefer allocations from nodes w/o CPUs
Message-Id: <200411040857.25664.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_19liBHf5TxcY9MJ"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_19liBHf5TxcY9MJ
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Small patch for the ia64 version of topology.h to make the zonelist building 
code prefer nodes w/o CPUs for allocations.  Do any platforms aside from 
Altix have nodes with only memory?  If not, then this will only affect sn2, 
otherwise I'm interested in hearing feedback.

Thanks,
Jesse

--Boundary-00=_19liBHf5TxcY9MJ
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

--Boundary-00=_19liBHf5TxcY9MJ--
