From: David Daney <ddaney.cavm@gmail.com>
Date: Wed, 27 Apr 2016 18:07:15 +0000
Subject: [PATCH v6 13/14] arm64, acpi, numa: NUMA support based on SRAT and SLIT
Message-Id: <1461780436-27182-14-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461780436-27182-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1461780436-27182-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org
Cc: linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>, Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>, David Daney <david.daney@cavium.com>

From: Hanjun Guo <hanjun.guo@linaro.org>

Introduce a new file to hold ACPI based NUMA information parsing from
SRAT and SLIT.

SRAT includes the CPU ACPI ID to Proximity Domain mappings and memory
ranges to Proximity Domain mapping.  SLIT has the information of inter
node distances(relative number for access latency).

Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
Signed-off-by: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
[rrichter@cavium.com Reworked for numa v10 series ]
Signed-off-by: Robert Richter <rrichter@cavium.com>
[david.daney@cavium.com reorderd and combinded with other patches in Hanjun Guo's original set]
Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/arm64/include/asm/acpi.h |   8 +++
 arch/arm64/include/asm/numa.h |   2 +
 arch/arm64/kernel/Makefile    |   1 +
 arch/arm64/kernel/acpi_numa.c | 149 ++++++++++++++++++++++++++++++++++++++++++
 arch/arm64/kernel/smp.c       |   2 +
 arch/arm64/mm/numa.c          |   5 +-
 6 files changed, 166 insertions(+), 1 deletion(-)
 create mode 100644 arch/arm64/kernel/acpi_numa.c

diff --git a/arch/arm64/include/asm/acpi.h b/arch/arm64/include/asm/acpi.h
index aee323b..4b13ecd 100644
--- a/arch/arm64/include/asm/acpi.h
+++ b/arch/arm64/include/asm/acpi.h
@@ -113,4 +113,12 @@ static inline const char *acpi_get_enable_method(int cpu)
 pgprot_t arch_apei_get_mem_attribute(phys_addr_t addr);
 #endif
 
+#ifdef CONFIG_ACPI_NUMA
+int arm64_acpi_numa_init(void);
+int acpi_numa_get_nid(unsigned int cpu, u64 hwid);
+#else
+static inline int arm64_acpi_numa_init(void) { return -ENOSYS; }
+static inline int acpi_numa_get_nid(unsigned int cpu, u64 hwid) { return NUMA_NO_NODE; }
+#endif /* CONFIG_ACPI_NUMA */
+
 #endif /*_ASM_ACPI_H*/
diff --git a/arch/arm64/include/asm/numa.h b/arch/arm64/include/asm/numa.h
index e9b4f29..600887e 100644
--- a/arch/arm64/include/asm/numa.h
+++ b/arch/arm64/include/asm/numa.h
@@ -5,6 +5,8 @@
 
 #ifdef CONFIG_NUMA
 
+#define NR_NODE_MEMBLKS		(MAX_NUMNODES * 2)
+
 /* currently, arm64 implements flat NUMA topology */
 #define parent_node(node)	(node)
 
diff --git a/arch/arm64/kernel/Makefile b/arch/arm64/kernel/Makefile
index 3793003..69569c6 100644
--- a/arch/arm64/kernel/Makefile
+++ b/arch/arm64/kernel/Makefile
@@ -42,6 +42,7 @@ arm64-obj-$(CONFIG_EFI)			+= efi.o efi-entry.stub.o
 arm64-obj-$(CONFIG_PCI)			+= pci.o
 arm64-obj-$(CONFIG_ARMV8_DEPRECATED)	+= armv8_deprecated.o
 arm64-obj-$(CONFIG_ACPI)		+= acpi.o
+arm64-obj-$(CONFIG_ACPI_NUMA)		+= acpi_numa.o
 arm64-obj-$(CONFIG_ARM64_ACPI_PARKING_PROTOCOL)	+= acpi_parking_protocol.o
 arm64-obj-$(CONFIG_PARAVIRT)		+= paravirt.o
 arm64-obj-$(CONFIG_RANDOMIZE_BASE)	+= kaslr.o
diff --git a/arch/arm64/kernel/acpi_numa.c b/arch/arm64/kernel/acpi_numa.c
new file mode 100644
index 0000000..94a6b35
--- /dev/null
+++ b/arch/arm64/kernel/acpi_numa.c
@@ -0,0 +1,149 @@
+/*
+ * ACPI 5.1 based NUMA setup for ARM64
+ * Lots of code was borrowed from arch/x86/mm/srat.c
+ *
+ * Copyright 2004 Andi Kleen, SuSE Labs.
+ * Copyright (C) 2013-2016, Linaro Ltd.
+ *		Author: Hanjun Guo <hanjun.guo@linaro.org>
+ *
+ * Reads the ACPI SRAT table to figure out what memory belongs to which CPUs.
+ *
+ * Called from acpi_numa_init while reading the SRAT and SLIT tables.
+ * Assumes all memory regions belonging to a single proximity domain
+ * are in one chunk. Holes between them will be included in the node.
+ */
+
+#define pr_fmt(fmt) "ACPI: NUMA: " fmt
+
+#include <linux/acpi.h>
+#include <linux/bitmap.h>
+#include <linux/bootmem.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/memblock.h>
+#include <linux/mmzone.h>
+#include <linux/module.h>
+#include <linux/topology.h>
+
+#include <acpi/processor.h>
+#include <asm/numa.h>
+
+static int cpus_in_srat;
+
+struct __node_cpu_hwid {
+	u32 node_id;    /* logical node containing this CPU */
+	u64 cpu_hwid;   /* MPIDR for this CPU */
+};
+
+static struct __node_cpu_hwid early_node_cpu_hwid[NR_CPUS] = {
+[0 ... NR_CPUS - 1] = {NUMA_NO_NODE, PHYS_CPUID_INVALID} };
+
+int acpi_numa_get_nid(unsigned int cpu, u64 hwid)
+{
+	int i;
+
+	for (i = 0; i < cpus_in_srat; i++) {
+		if (hwid = early_node_cpu_hwid[i].cpu_hwid)
+			return early_node_cpu_hwid[i].node_id;
+	}
+
+	return NUMA_NO_NODE;
+}
+
+static int __init get_mpidr_in_madt(int acpi_id, u64 *mpidr)
+{
+	unsigned long madt_end, entry;
+	struct acpi_table_madt *madt;
+	acpi_size tbl_size;
+
+	if (ACPI_FAILURE(acpi_get_table_with_size(ACPI_SIG_MADT, 0,
+			(struct acpi_table_header **)&madt, &tbl_size)))
+		return -ENODEV;
+
+	entry = (unsigned long)madt;
+	madt_end = entry + madt->header.length;
+
+	/* Parse all entries looking for a match. */
+	entry += sizeof(struct acpi_table_madt);
+	while (entry + sizeof(struct acpi_subtable_header) < madt_end) {
+		struct acpi_subtable_header *header +			(struct acpi_subtable_header *)entry;
+
+		if (header->type = ACPI_MADT_TYPE_GENERIC_INTERRUPT) {
+			struct acpi_madt_generic_interrupt *gicc +				container_of(header,
+				struct acpi_madt_generic_interrupt, header);
+
+			if ((gicc->flags & ACPI_MADT_ENABLED) &&
+			    (gicc->uid = acpi_id)) {
+				*mpidr = gicc->arm_mpidr;
+				early_acpi_os_unmap_memory(madt, tbl_size);
+				return 0;
+			}
+		}
+		entry += header->length;
+	}
+
+	early_acpi_os_unmap_memory(madt, tbl_size);
+	return -ENODEV;
+}
+
+/* Callback for Proximity Domain -> ACPI processor UID mapping */
+void __init acpi_numa_gicc_affinity_init(struct acpi_srat_gicc_affinity *pa)
+{
+	int pxm, node;
+	u64 mpidr;
+
+	if (srat_disabled())
+		return;
+
+	if (pa->header.length < sizeof(struct acpi_srat_gicc_affinity)) {
+		pr_err("SRAT: Invalid SRAT header length: %d\n",
+			pa->header.length);
+		bad_srat();
+		return;
+	}
+
+	if (!(pa->flags & ACPI_SRAT_GICC_ENABLED))
+		return;
+
+	if (cpus_in_srat >= NR_CPUS) {
+		pr_warn_once("SRAT: cpu_to_node_map[%d] is too small, may not be able to use all cpus\n",
+			     NR_CPUS);
+		return;
+	}
+
+	pxm = pa->proximity_domain;
+	node = acpi_map_pxm_to_node(pxm);
+
+	if (node = NUMA_NO_NODE || node >= MAX_NUMNODES) {
+		pr_err("SRAT: Too many proximity domains %d\n", pxm);
+		bad_srat();
+		return;
+	}
+
+	if (get_mpidr_in_madt(pa->acpi_processor_uid, &mpidr)) {
+		pr_err("SRAT: PXM %d with ACPI ID %d has no valid MPIDR in MADT\n",
+			pxm, pa->acpi_processor_uid);
+		bad_srat();
+		return;
+	}
+
+	early_node_cpu_hwid[cpus_in_srat].node_id = node;
+	early_node_cpu_hwid[cpus_in_srat].cpu_hwid =  mpidr;
+	node_set(node, numa_nodes_parsed);
+	cpus_in_srat++;
+	pr_info("SRAT: PXM %d -> MPIDR 0x%Lx -> Node %d\n",
+		pxm, mpidr, node);
+}
+
+int __init arm64_acpi_numa_init(void)
+{
+	int ret;
+
+	ret = acpi_numa_init();
+	if (ret)
+		return ret;
+
+	return srat_disabled() ? -EINVAL : 0;
+}
diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index fef2e73..fe85940 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -562,6 +562,8 @@ acpi_map_gic_cpu_interface(struct acpi_madt_generic_interrupt *processor)
 	 */
 	acpi_set_mailbox_entry(cpu_count, processor);
 
+	early_map_cpu_to_node(cpu_count, acpi_numa_get_nid(cpu_count, hwid));
+
 	cpu_count++;
 }
 
diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
index 1def1de..c7fe3ec 100644
--- a/arch/arm64/mm/numa.c
+++ b/arch/arm64/mm/numa.c
@@ -17,6 +17,7 @@
  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
  */
 
+#include <linux/acpi.h>
 #include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/module.h>
@@ -391,7 +392,9 @@ static int __init dummy_numa_init(void)
 void __init arm64_numa_init(void)
 {
 	if (!numa_off) {
-		if (!numa_init(of_numa_init))
+		if (!acpi_disabled && !numa_init(arm64_acpi_numa_init))
+			return;
+		if (acpi_disabled && !numa_init(of_numa_init))
 			return;
 	}
 
-- 
1.7.11.7

