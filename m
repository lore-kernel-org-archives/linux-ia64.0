From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Date: Fri, 01 Sep 2017 02:56:33 +0000
Subject: [PATCH v2 1/7] ia64: topology: Remove the unused parent_node() macro
Message-Id: <1504234599-29533-2-git-send-email-douly.fnst@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1504234599-29533-1-git-send-email-douly.fnst@cn.fujitsu.com>
In-Reply-To: <1504234599-29533-1-git-send-email-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org
Cc: Dou Liyang <douly.fnst@cn.fujitsu.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Commit a7be6e5a7f8d ("mm: drop useless local parameters of
__register_one_node()") removes the last user of parent_node().

The parent_node() macro in IA64(Itanium) platform is unnecessary.

Remove it for cleanup.

Reported-by: Michael Ellerman <mpe@ellerman.id.au>
Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/include/asm/topology.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/arch/ia64/include/asm/topology.h b/arch/ia64/include/asm/topology.h
index 3ad8f69..82f9bf7 100644
--- a/arch/ia64/include/asm/topology.h
+++ b/arch/ia64/include/asm/topology.h
@@ -34,13 +34,6 @@
 			       &node_to_cpu_mask[node])
 
 /*
- * Returns the number of the node containing Node 'nid'.
- * Not implemented here. Multi-level hierarchies detected with
- * the help of node_distance().
- */
-#define parent_node(nid) (nid)
-
-/*
  * Determines the node for a given pci bus
  */
 #define pcibus_to_node(bus) PCI_CONTROLLER(bus)->node
-- 
2.5.5



