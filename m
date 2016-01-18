From: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
Date: Mon, 18 Jan 2016 16:48:05 +0000
Subject: [RFC PATCH v9 6/6] topology, cleanup: Avoid redefinition of cpumask_of_pcibus in asm header files.
Message-Id: <1453134965-6125-7-git-send-email-gkulkarni@caviumnetworks.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1453134965-6125-1-git-send-email-gkulkarni@caviumnetworks.com>
In-Reply-To: <1453134965-6125-1-git-send-email-gkulkarni@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-arch@vger.kernel.org, Will.Deacon@arm.com, catalin.marinas@arm.com, grant.likely@linaro.org, leif.lindholm@linaro.org, rfranz@cavium.com, ard.biesheuvel@linaro.org, msalter@redhat.com, robh+dt@kernel.org, steve.capper@linaro.org, hanjun.guo@linaro.org, al.stone@linaro.org, arnd@arndb.de, pawel.moll@arm.com, mark.rutland@arm.com, ijc+devicetree@hellion.org.uk, galak@codeaurora.org, rjw@rjwysocki.net, lenb@kernel.org, marc.zyngier@arm.com, lorenzo.pieralisi@arm.com, bhelgaas@google.com, tony.luck@intel.com, fenghua.yu@intel.com, james.hoga
Cc: gpkulkarni@gmail.com

At present cpumask_of_pcibus is defined for !CONFIG_NUMA and moving out
to common will allow to use for numa too. This also avoids
redefinition of this macro in respective architecture header files.

Signed-off-by: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
---
 arch/arm64/include/asm/topology.h   | 3 ---
 arch/ia64/include/asm/topology.h    | 4 ----
 arch/metag/include/asm/topology.h   | 3 ---
 arch/powerpc/include/asm/topology.h | 4 ----
 arch/s390/include/asm/pci.h         | 2 +-
 arch/s390/include/asm/topology.h    | 1 +
 arch/sh/include/asm/topology.h      | 3 ---
 arch/x86/include/asm/pci.h          | 2 +-
 arch/x86/include/asm/topology.h     | 1 +
 include/asm-generic/topology.h      | 4 ++--
 10 files changed, 6 insertions(+), 21 deletions(-)

diff --git a/arch/arm64/include/asm/topology.h b/arch/arm64/include/asm/topology.h
index 8b57339..6e1f62c 100644
--- a/arch/arm64/include/asm/topology.h
+++ b/arch/arm64/include/asm/topology.h
@@ -26,9 +26,6 @@ const struct cpumask *cpu_coregroup_mask(int cpu);
 
 struct pci_bus;
 int pcibus_to_node(struct pci_bus *bus);
-#define cpumask_of_pcibus(bus)	(pcibus_to_node(bus) = -1 ?		\
-				 cpu_all_mask :				\
-				 cpumask_of_node(pcibus_to_node(bus)))
 
 #endif /* CONFIG_NUMA */
 
diff --git a/arch/ia64/include/asm/topology.h b/arch/ia64/include/asm/topology.h
index 3ad8f69..2778eb6 100644
--- a/arch/ia64/include/asm/topology.h
+++ b/arch/ia64/include/asm/topology.h
@@ -58,10 +58,6 @@ void build_cpu_to_node_map(void);
 
 extern void arch_fix_phys_package_id(int num, u32 slot);
 
-#define cpumask_of_pcibus(bus)	(pcibus_to_node(bus) = -1 ?		\
-				 cpu_all_mask :				\
-				 cpumask_of_node(pcibus_to_node(bus)))
-
 #include <asm-generic/topology.h>
 
 #endif /* _ASM_IA64_TOPOLOGY_H */
diff --git a/arch/metag/include/asm/topology.h b/arch/metag/include/asm/topology.h
index e95f874..b285196 100644
--- a/arch/metag/include/asm/topology.h
+++ b/arch/metag/include/asm/topology.h
@@ -9,9 +9,6 @@
 #define cpumask_of_node(node)	((void)node, cpu_online_mask)
 
 #define pcibus_to_node(bus)	((void)(bus), -1)
-#define cpumask_of_pcibus(bus)	(pcibus_to_node(bus) = -1 ? \
-					cpu_all_mask : \
-					cpumask_of_node(pcibus_to_node(bus)))
 
 #endif
 
diff --git a/arch/powerpc/include/asm/topology.h b/arch/powerpc/include/asm/topology.h
index 8b3b46b..eee025d 100644
--- a/arch/powerpc/include/asm/topology.h
+++ b/arch/powerpc/include/asm/topology.h
@@ -32,10 +32,6 @@ static inline int pcibus_to_node(struct pci_bus *bus)
 }
 #endif
 
-#define cpumask_of_pcibus(bus)	(pcibus_to_node(bus) = -1 ?		\
-				 cpu_all_mask :				\
-				 cpumask_of_node(pcibus_to_node(bus)))
-
 extern int __node_distance(int, int);
 #define node_distance(a, b) __node_distance(a, b)
 
diff --git a/arch/s390/include/asm/pci.h b/arch/s390/include/asm/pci.h
index c873e68..539fb2d 100644
--- a/arch/s390/include/asm/pci.h
+++ b/arch/s390/include/asm/pci.h
@@ -205,7 +205,7 @@ static inline int __pcibus_to_node(const struct pci_bus *bus)
 }
 
 static inline const struct cpumask *
-cpumask_of_pcibus(const struct pci_bus *bus)
+__cpumask_of_pcibus(const struct pci_bus *bus)
 {
 	return cpu_online_mask;
 }
diff --git a/arch/s390/include/asm/topology.h b/arch/s390/include/asm/topology.h
index 94fc55f..280eafc 100644
--- a/arch/s390/include/asm/topology.h
+++ b/arch/s390/include/asm/topology.h
@@ -78,6 +78,7 @@ static inline const struct cpumask *cpumask_of_node(int node)
 #define parent_node(node) (node)
 
 #define pcibus_to_node(bus) __pcibus_to_node(bus)
+#define cpumask_of_pcibus(bus) __cpumask_of_pcibus(bus)
 
 #define node_distance(a, b) __node_distance(a, b)
 
diff --git a/arch/sh/include/asm/topology.h b/arch/sh/include/asm/topology.h
index b0a282d..357983d 100644
--- a/arch/sh/include/asm/topology.h
+++ b/arch/sh/include/asm/topology.h
@@ -9,9 +9,6 @@
 #define cpumask_of_node(node)	((void)node, cpu_online_mask)
 
 #define pcibus_to_node(bus)	((void)(bus), -1)
-#define cpumask_of_pcibus(bus)	(pcibus_to_node(bus) = -1 ? \
-					cpu_all_mask : \
-					cpumask_of_node(pcibus_to_node(bus)))
 
 #endif
 
diff --git a/arch/x86/include/asm/pci.h b/arch/x86/include/asm/pci.h
index 4625943..4a6f358 100644
--- a/arch/x86/include/asm/pci.h
+++ b/arch/x86/include/asm/pci.h
@@ -121,7 +121,7 @@ static inline int __pcibus_to_node(const struct pci_bus *bus)
 }
 
 static inline const struct cpumask *
-cpumask_of_pcibus(const struct pci_bus *bus)
+__cpumask_of_pcibus(const struct pci_bus *bus)
 {
 	int node;
 
diff --git a/arch/x86/include/asm/topology.h b/arch/x86/include/asm/topology.h
index 0fb4648..980f6ee 100644
--- a/arch/x86/include/asm/topology.h
+++ b/arch/x86/include/asm/topology.h
@@ -91,6 +91,7 @@ extern void setup_node_to_cpumask_map(void);
 #define parent_node(node) (node)
 
 #define pcibus_to_node(bus) __pcibus_to_node(bus)
+#define cpumask_of_pcibus(bus) __cpumask_of_pcibus(bus)
 
 extern int __node_distance(int, int);
 #define node_distance(a, b) __node_distance(a, b)
diff --git a/include/asm-generic/topology.h b/include/asm-generic/topology.h
index fc824e2..ee305f1 100644
--- a/include/asm-generic/topology.h
+++ b/include/asm-generic/topology.h
@@ -54,14 +54,14 @@
 #define pcibus_to_node(bus)	((void)(bus), -1)
 #endif
 
+#endif	/* !CONFIG_NUMA */
+
 #ifndef cpumask_of_pcibus
 #define cpumask_of_pcibus(bus)	(pcibus_to_node(bus) = -1 ?		\
 				 cpu_all_mask :				\
 				 cpumask_of_node(pcibus_to_node(bus)))
 #endif
 
-#endif	/* CONFIG_NUMA */
-
 #if !defined(CONFIG_NUMA) || !defined(CONFIG_HAVE_MEMORYLESS_NODES)
 
 #ifndef set_numa_mem
-- 
1.8.1.4

