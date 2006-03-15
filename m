From: Kenji Kaneshige <kaneshige.kenji@soft.fujitsu.com>
Date: Wed, 15 Mar 2006 05:45:11 +0000
Subject: [PATCH][BUG] Ignore disabled Local SAPIC Affinity Structure in SRAT
Message-Id: <4417A9E7.3030904@soft.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here is a patch to fix a bug in the code for parsing SRAT.

Thanks,
Kenji Kaneshige


According to the ACPI spec, the OSPM must ignore the contents of the
Processor Local APIC/SAPIC Affinity Structure in System Resource
Affinity Table (SRAT), if its enable flag is cleared. However, ia64
linux refers all of the Processor Local APIC/SAPIC Affinity Structures
in SRAT regardless of the enable flag. This is obviously against the
ACPI spec. This patch fixes this bug.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/acpi.c |    3 +++
 1 files changed, 3 insertions(+)

Index: linux-2.6.16-rc6/arch/ia64/kernel/acpi.c
=================================--- linux-2.6.16-rc6.orig/arch/ia64/kernel/acpi.c	2006-03-15 12:59:46.000000000 +0900
+++ linux-2.6.16-rc6/arch/ia64/kernel/acpi.c	2006-03-15 12:59:57.000000000 +0900
@@ -437,6 +437,9 @@
 void __init
 acpi_numa_processor_affinity_init(struct acpi_table_processor_affinity *pa)
 {
+	if (!pa->flags.enabled)
+		return;
+
 	/* record this node in proximity bitmap */
 	pxm_bit_set(pa->proximity_domain);
 
