From: David Daney <ddaney.cavm@gmail.com>
Date: Mon, 18 Apr 2016 21:13:59 +0000
Subject: [PATCH v4 01/14] acpi, numa: Use pr_fmt() instead of printk
Message-Id: <1461014052-30788-2-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461014052-30788-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1461014052-30788-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org
Cc: Robert Richter <rrichter@cavium.com>, linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>

From: Hanjun Guo <hanjun.guo@linaro.org>

Just do some cleanups to replace printk with pr_fmt().

Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
Signed-off-by: Robert Richter <rrichter@cavium.com>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/acpi/numa.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 72b6e9e..4e427fc 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -18,6 +18,9 @@
  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  *
  */
+
+#define pr_fmt(fmt) "ACPI: " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
@@ -28,8 +31,6 @@
 #include <linux/nodemask.h>
 #include <linux/topology.h>
 
-#define PREFIX "ACPI: "
-
 #define ACPI_NUMA	0x80000000
 #define _COMPONENT	ACPI_NUMA
 ACPI_MODULE_NAME("numa");
@@ -187,9 +188,8 @@ acpi_table_print_srat_entry(struct acpi_subtable_header *header)
 #endif				/* ACPI_DEBUG_OUTPUT */
 		break;
 	default:
-		printk(KERN_WARNING PREFIX
-		       "Found unsupported SRAT entry (type = 0x%x)\n",
-		       header->type);
+		pr_warn("Found unsupported SRAT entry (type = 0x%x)\n",
+			header->type);
 		break;
 	}
 }
@@ -222,7 +222,7 @@ static int __init acpi_parse_slit(struct acpi_table_header *table)
 	struct acpi_table_slit *slit = (struct acpi_table_slit *)table;
 
 	if (!slit_valid(slit)) {
-		printk(KERN_INFO "ACPI: SLIT table looks invalid. Not used.\n");
+		pr_info("SLIT table looks invalid. Not used.\n");
 		return -EINVAL;
 	}
 	acpi_numa_slit_init(slit);
@@ -233,12 +233,9 @@ static int __init acpi_parse_slit(struct acpi_table_header *table)
 void __init __weak
 acpi_numa_x2apic_affinity_init(struct acpi_srat_x2apic_cpu_affinity *pa)
 {
-	printk(KERN_WARNING PREFIX
-	       "Found unsupported x2apic [0x%08x] SRAT entry\n", pa->apic_id);
-	return;
+	pr_warn("Found unsupported x2apic [0x%08x] SRAT entry\n", pa->apic_id);
 }
 
-
 static int __init
 acpi_parse_x2apic_affinity(struct acpi_subtable_header *header,
 			   const unsigned long end)
-- 
1.7.11.7

