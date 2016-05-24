From: David Daney <ddaney.cavm@gmail.com>
Date: Tue, 24 May 2016 22:35:32 +0000
Subject: [PATCH v7 02/15] acpi, numa: Replace ACPI_DEBUG_PRINT() with pr_debug()
Message-Id: <1464129345-18985-3-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1464129345-18985-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1464129345-18985-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org
Cc: linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>, David Daney <david.daney@cavium.com>

From: Hanjun Guo <hanjun.guo@linaro.org>

ACPI_DEBUG_PRINT is a bit fragile in acpi/numa.c, the first thing
is that component ACPI_NUMA(0x80000000) is not described in the
Documentation/acpi/debug.txt, and even not defined in the struct
acpi_dlayer acpi_debug_layers which we can not dynamically enable/disable
it with /sys/modules/acpi/parameters/debug_layer. another thing
is that ACPI_DEBUG_OUTPUT is controlled by ACPICA which not coordinate
well with ACPI drivers.

Replace ACPI_DEBUG_PRINT() with pr_debug() in this patch as pr_debug
will do the same thing for debug purpose and it can make the code much
cleaner, also remove the related code which not needed anymore if
ACPI_DEBUG_PRINT() is gone.

Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
Signed-off-by: Robert Richter <rrichter@cavium.com>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/acpi/numa.c | 59 +++++++++++++++++++----------------------------------
 1 file changed, 21 insertions(+), 38 deletions(-)

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index bdb7622..a089c39 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -31,10 +31,6 @@
 #include <linux/nodemask.h>
 #include <linux/topology.h>
 
-#define ACPI_NUMA	0x80000000
-#define _COMPONENT	ACPI_NUMA
-ACPI_MODULE_NAME("numa");
-
 static nodemask_t nodes_found_map = NODE_MASK_NONE;
 
 /* maps to convert between proximity domain and logical node ID */
@@ -129,64 +125,51 @@ EXPORT_SYMBOL(acpi_map_pxm_to_online_node);
 static void __init
 acpi_table_print_srat_entry(struct acpi_subtable_header *header)
 {
-
-	ACPI_FUNCTION_NAME("acpi_table_print_srat_entry");
-
 	if (!header)
 		return;
 
 	switch (header->type) {
-
 	case ACPI_SRAT_TYPE_CPU_AFFINITY:
-#ifdef ACPI_DEBUG_OUTPUT
 		{
 			struct acpi_srat_cpu_affinity *p  			    (struct acpi_srat_cpu_affinity *)header;
-			ACPI_DEBUG_PRINT((ACPI_DB_INFO,
-					  "SRAT Processor (id[0x%02x] eid[0x%02x]) in proximity domain %d %s\n",
-					  p->apic_id, p->local_sapic_eid,
-					  p->proximity_domain_lo,
-					  (p->flags & ACPI_SRAT_CPU_ENABLED)?
-					  "enabled" : "disabled"));
+			pr_debug("SRAT Processor (id[0x%02x] eid[0x%02x]) in proximity domain %d %s\n",
+				 p->apic_id, p->local_sapic_eid,
+				 p->proximity_domain_lo,
+				 (p->flags & ACPI_SRAT_CPU_ENABLED) ?
+				 "enabled" : "disabled");
 		}
-#endif				/* ACPI_DEBUG_OUTPUT */
 		break;
 
 	case ACPI_SRAT_TYPE_MEMORY_AFFINITY:
-#ifdef ACPI_DEBUG_OUTPUT
 		{
 			struct acpi_srat_mem_affinity *p  			    (struct acpi_srat_mem_affinity *)header;
-			ACPI_DEBUG_PRINT((ACPI_DB_INFO,
-					  "SRAT Memory (0x%lx length 0x%lx) in proximity domain %d %s%s%s\n",
-					  (unsigned long)p->base_address,
-					  (unsigned long)p->length,
-					  p->proximity_domain,
-					  (p->flags & ACPI_SRAT_MEM_ENABLED)?
-					  "enabled" : "disabled",
-					  (p->flags & ACPI_SRAT_MEM_HOT_PLUGGABLE)?
-					  " hot-pluggable" : "",
-					  (p->flags & ACPI_SRAT_MEM_NON_VOLATILE)?
-					  " non-volatile" : ""));
+			pr_debug("SRAT Memory (0x%lx length 0x%lx) in proximity domain %d %s%s%s\n",
+				 (unsigned long)p->base_address,
+				 (unsigned long)p->length,
+				 p->proximity_domain,
+				 (p->flags & ACPI_SRAT_MEM_ENABLED) ?
+				 "enabled" : "disabled",
+				 (p->flags & ACPI_SRAT_MEM_HOT_PLUGGABLE) ?
+				 " hot-pluggable" : "",
+				 (p->flags & ACPI_SRAT_MEM_NON_VOLATILE) ?
+				 " non-volatile" : "");
 		}
-#endif				/* ACPI_DEBUG_OUTPUT */
 		break;
 
 	case ACPI_SRAT_TYPE_X2APIC_CPU_AFFINITY:
-#ifdef ACPI_DEBUG_OUTPUT
 		{
 			struct acpi_srat_x2apic_cpu_affinity *p  			    (struct acpi_srat_x2apic_cpu_affinity *)header;
-			ACPI_DEBUG_PRINT((ACPI_DB_INFO,
-					  "SRAT Processor (x2apicid[0x%08x]) in"
-					  " proximity domain %d %s\n",
-					  p->apic_id,
-					  p->proximity_domain,
-					  (p->flags & ACPI_SRAT_CPU_ENABLED) ?
-					  "enabled" : "disabled"));
+			pr_debug("SRAT Processor (x2apicid[0x%08x]) in proximity domain %d %s\n",
+				 p->apic_id,
+				 p->proximity_domain,
+				 (p->flags & ACPI_SRAT_CPU_ENABLED) ?
+				 "enabled" : "disabled");
 		}
-#endif				/* ACPI_DEBUG_OUTPUT */
 		break;
+
 	default:
 		pr_warn("Found unsupported SRAT entry (type = 0x%x)\n",
 			header->type);
-- 
1.7.11.7

