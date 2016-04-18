From: David Daney <ddaney.cavm@gmail.com>
Date: Mon, 18 Apr 2016 21:14:03 +0000
Subject: [PATCH v4 05/14] acpi, numa: move acpi_numa_slit_init() to drivers/acpi/numa.c
Message-Id: <1461014052-30788-6-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461014052-30788-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1461014052-30788-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org
Cc: linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>, David Daney <david.daney@cavium.com>

From: Hanjun Guo <hanjun.guo@linaro.org>

Identical implementations of acpi_numa_slit_init() are used by both
x86 and follow-on arm64 support.  Move it to drivers/acpi/numa.c, and
mark it as __weak because ia64 has its own architecture specific
implementation.

No code change.

Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
Signed-off-by: Robert Richter <rrichter@cavium.com>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/x86/mm/srat.c  | 27 ---------------------------
 drivers/acpi/numa.c | 27 +++++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index 90b6ed9..f242a11 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -42,33 +42,6 @@ static __init inline int srat_disabled(void)
 	return acpi_numa < 0;
 }
 
-/*
- * Callback for SLIT parsing.  pxm_to_node() returns NUMA_NO_NODE for
- * I/O localities since SRAT does not list them.  I/O localities are
- * not supported at this point.
- */
-void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
-{
-	int i, j;
-
-	for (i = 0; i < slit->locality_count; i++) {
-		const int from_node = pxm_to_node(i);
-
-		if (from_node = NUMA_NO_NODE)
-			continue;
-
-		for (j = 0; j < slit->locality_count; j++) {
-			const int to_node = pxm_to_node(j);
-
-			if (to_node = NUMA_NO_NODE)
-				continue;
-
-			numa_set_distance(from_node, to_node,
-				slit->entry[slit->locality_count * i + j]);
-		}
-	}
-}
-
 /* Callback for Proximity Domain -> x2APIC mapping */
 void __init
 acpi_numa_x2apic_affinity_init(struct acpi_srat_x2apic_cpu_affinity *pa)
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index f41f06b..5403d62 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -197,6 +197,33 @@ static int __init slit_valid(struct acpi_table_slit *slit)
 	return 1;
 }
 
+/*
+ * Callback for SLIT parsing.  pxm_to_node() returns NUMA_NO_NODE for
+ * I/O localities since SRAT does not list them.  I/O localities are
+ * not supported at this point.
+ */
+void __init __weak acpi_numa_slit_init(struct acpi_table_slit *slit)
+{
+	int i, j;
+
+	for (i = 0; i < slit->locality_count; i++) {
+		const int from_node = pxm_to_node(i);
+
+		if (from_node = NUMA_NO_NODE)
+			continue;
+
+		for (j = 0; j < slit->locality_count; j++) {
+			const int to_node = pxm_to_node(j);
+
+			if (to_node = NUMA_NO_NODE)
+				continue;
+
+			numa_set_distance(from_node, to_node,
+				slit->entry[slit->locality_count * i + j]);
+		}
+	}
+}
+
 static int __init acpi_parse_slit(struct acpi_table_header *table)
 {
 	struct acpi_table_slit *slit = (struct acpi_table_slit *)table;
-- 
1.7.11.7

