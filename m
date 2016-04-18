From: David Daney <ddaney.cavm@gmail.com>
Date: Mon, 18 Apr 2016 21:14:11 +0000
Subject: [PATCH v4 13/14] acpi, numa: Enable ACPI based NUMA on ARM64
Message-Id: <1461014052-30788-14-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461014052-30788-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1461014052-30788-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org
Cc: linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>, David Daney <david.daney@cavium.com>

From: Hanjun Guo <hanjun.guo@linaro.org>

Add function needed for cpu to node mapping, and enable ACPI based
NUMA for ARM64 in Kconfig

Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
Signed-off-by: Robert Richter <rrichter@cavium.com>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/acpi/Kconfig |  2 +-
 drivers/acpi/numa.c  | 35 +++++++++++++++++++++++++++++++++++
 include/linux/acpi.h | 17 ++++++++++++++++-
 3 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index 82b96ee..5ce9f66 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -291,7 +291,7 @@ config ACPI_THERMAL
 config ACPI_NUMA
 	bool "NUMA support"
 	depends on NUMA
-	depends on (X86 || IA64)
+	depends on (X86 || IA64 || ARM64)
 	default y if IA64_GENERIC || IA64_SGI_SN2
 
 config ACPI_CUSTOM_DSDT_FILE
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 6133eb1..0862ccd 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -170,6 +170,18 @@ acpi_table_print_srat_entry(struct acpi_subtable_header *header)
 		}
 		break;
 
+	case ACPI_SRAT_TYPE_GICC_AFFINITY:
+		{
+			struct acpi_srat_gicc_affinity *p +			    (struct acpi_srat_gicc_affinity *)header;
+			pr_debug("SRAT Processor (acpi id[0x%04x]) in proximity domain %d %s\n",
+				 p->acpi_processor_uid,
+				 p->proximity_domain,
+				 (p->flags & ACPI_SRAT_GICC_ENABLED) ?
+				 "enabled" : "disabled");
+		}
+		break;
+
 	default:
 		pr_warn("Found unsupported SRAT entry (type = 0x%x)\n",
 			header->type);
@@ -347,6 +359,24 @@ acpi_parse_processor_affinity(struct acpi_subtable_header *header,
 	return 0;
 }
 
+static int __init
+acpi_parse_gicc_affinity(struct acpi_subtable_header *header,
+			 const unsigned long end)
+{
+	struct acpi_srat_gicc_affinity *processor_affinity;
+
+	processor_affinity = (struct acpi_srat_gicc_affinity *)header;
+	if (!processor_affinity)
+		return -EINVAL;
+
+	acpi_table_print_srat_entry(header);
+
+	/* let architecture-dependent part to do it */
+	acpi_numa_gicc_affinity_init(processor_affinity);
+
+	return 0;
+}
+
 static int __initdata parsed_numa_memblks;
 
 static int __init
@@ -391,6 +421,9 @@ int __init acpi_numa_init(void)
 {
 	int cnt = 0;
 
+	if (acpi_disabled)
+		return -EINVAL;
+
 	/*
 	 * Should not limit number with cpu num that is from NR_CPUS or nr_cpus 	 * SRAT cpu entries could have different order with that in MADT.
@@ -403,6 +436,8 @@ int __init acpi_numa_init(void)
 				     acpi_parse_x2apic_affinity, 0);
 		acpi_table_parse_srat(ACPI_SRAT_TYPE_CPU_AFFINITY,
 				     acpi_parse_processor_affinity, 0);
+		acpi_table_parse_srat(ACPI_SRAT_TYPE_GICC_AFFINITY,
+				      acpi_parse_gicc_affinity, 0);
 		cnt = acpi_table_parse_srat(ACPI_SRAT_TYPE_MEMORY_AFFINITY,
 					    acpi_parse_memory_affinity,
 					    NR_NODE_MEMBLKS);
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index ab6fd96..af34064 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -239,10 +239,25 @@ int acpi_table_parse_madt(enum acpi_madt_type id,
 int acpi_parse_mcfg (struct acpi_table_header *header);
 void acpi_table_print_madt_entry (struct acpi_subtable_header *madt);
 
-/* the following four functions are architecture-dependent */
+/* the following numa functions are architecture-dependent */
 void acpi_numa_slit_init (struct acpi_table_slit *slit);
+
+#if defined(CONFIG_X86) || defined(CONFIG_IA64)
 void acpi_numa_processor_affinity_init (struct acpi_srat_cpu_affinity *pa);
+#else
+static inline void
+acpi_numa_processor_affinity_init(struct acpi_srat_cpu_affinity *pa) { }
+#endif
+
 void acpi_numa_x2apic_affinity_init(struct acpi_srat_x2apic_cpu_affinity *pa);
+
+#ifdef CONFIG_ARM64
+void acpi_numa_gicc_affinity_init(struct acpi_srat_gicc_affinity *pa);
+#else
+static inline void
+acpi_numa_gicc_affinity_init(struct acpi_srat_gicc_affinity *pa) { }
+#endif
+
 int acpi_numa_memory_affinity_init (struct acpi_srat_mem_affinity *ma);
 
 #ifndef PHYS_CPUID_INVALID
-- 
1.7.11.7

