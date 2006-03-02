From: Jack Steiner <steiner@sgi.com>
Date: Thu, 02 Mar 2006 22:02:21 +0000
Subject: PATCH[1/4] - Increase max node count on SN platforms
Message-Id: <20060302220221.GA16668@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add a configuration option to allow the maximum
number of nodes to be configurable for GENERIC or SN
kernels. 


	Signed-off-by: Jack Steiner <steiner@sgi.com>


 arch/ia64/Kconfig           |    9 +++++++++
 include/asm-ia64/numnodes.h |   13 +++++++++----
 2 files changed, 18 insertions(+), 4 deletions(-)




Index: linux/arch/ia64/Kconfig
=================================--- linux.orig/arch/ia64/Kconfig	2006-03-02 13:18:50.720983429 -0600
+++ linux/arch/ia64/Kconfig	2006-03-02 13:21:53.330183650 -0600
@@ -252,6 +252,15 @@ config NR_CPUS
 	  than 64 will cause the use of a CPU mask array, causing a small
 	  performance hit.
 
+config IA64_NR_NODES
+	int "Maximum number of NODEs (256-1024)" if (IA64_SGI_SN2 || IA64_GENERIC)
+	range 256 1024
+	depends on IA64_SGI_SN2 || IA64_GENERIC
+	default "256"
+	help
+	  This option specifies the maximum number of nodes in your SSI system.
+	  If in doubt, use the default.
+
 config HOTPLUG_CPU
 	bool "Support for hot-pluggable CPUs (EXPERIMENTAL)"
 	depends on SMP && EXPERIMENTAL
Index: linux/include/asm-ia64/numnodes.h
=================================--- linux.orig/include/asm-ia64/numnodes.h	2006-03-02 13:18:50.721959896 -0600
+++ linux/include/asm-ia64/numnodes.h	2006-03-02 13:21:53.357524740 -0600
@@ -3,13 +3,18 @@
 
 #ifdef CONFIG_IA64_DIG
 /* Max 8 Nodes */
-#define NODES_SHIFT	3
+#  define NODES_SHIFT	3
 #elif defined(CONFIG_IA64_HP_ZX1) || defined(CONFIG_IA64_HP_ZX1_SWIOTLB)
 /* Max 32 Nodes */
-#define NODES_SHIFT	5
+#  define NODES_SHIFT	5
 #elif defined(CONFIG_IA64_SGI_SN2) || defined(CONFIG_IA64_GENERIC)
-/* Max 256 Nodes */
-#define NODES_SHIFT	8
+#  if CONFIG_IA64_NR_NODES = 256
+#    define NODES_SHIFT	8
+#  elif CONFIG_IA64_NR_NODES <= 512
+#    define NODES_SHIFT    9
+#  elif CONFIG_IA64_NR_NODES <= 1024
+#    define NODES_SHIFT    10
+#  endif
 #endif
 
 #endif /* _ASM_MAX_NUMNODES_H */
