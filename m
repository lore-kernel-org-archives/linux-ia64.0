From: David Daney <ddaney.cavm@gmail.com>
Date: Mon, 18 Apr 2016 21:14:06 +0000
Subject: [PATCH v4 08/14] acpi, numa: move bad_srat() and srat_disabled() to drivers/acpi/numa.c
Message-Id: <1461014052-30788-9-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461014052-30788-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1461014052-30788-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org
Cc: Robert Richter <rrichter@cavium.com>, linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>

From: Hanjun Guo <hanjun.guo@linaro.org>

bad_srat() and srat_disabled() are shared by x86 and follow-on arm64
patches.  Move them to drivers/acpi/numa.c in preparation for arm64
support.

Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
Signed-off-by: Robert Richter <rrichter@cavium.com>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/x86/include/asm/acpi.h |  1 -
 arch/x86/mm/numa.c          |  2 +-
 arch/x86/mm/srat.c          | 13 -------------
 drivers/acpi/numa.c         |  1 +
 include/acpi/acpi_numa.h    | 12 ++++++++++++
 5 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/arch/x86/include/asm/acpi.h b/arch/x86/include/asm/acpi.h
index 94c18eb..65f1e95 100644
--- a/arch/x86/include/asm/acpi.h
+++ b/arch/x86/include/asm/acpi.h
@@ -145,7 +145,6 @@ static inline void disable_acpi(void) { }
 #define ARCH_HAS_POWER_INIT	1
 
 #ifdef CONFIG_ACPI_NUMA
-extern int acpi_numa;
 extern int x86_acpi_numa_init(void);
 #endif /* CONFIG_ACPI_NUMA */
 
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index f70c1ff..57673f5 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -1,4 +1,5 @@
 /* Common code for 32 and 64-bit NUMA */
+#include <linux/acpi.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/string.h>
@@ -15,7 +16,6 @@
 #include <asm/e820.h>
 #include <asm/proto.h>
 #include <asm/dma.h>
-#include <asm/acpi.h>
 #include <asm/amd_nb.h>
 
 #include "numa_internal.h"
diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index 9e2a833..4217071f 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -24,19 +24,6 @@
 #include <asm/apic.h>
 #include <asm/uv/uv.h>
 
-int acpi_numa __initdata;
-
-static __init void bad_srat(void)
-{
-	printk(KERN_ERR "SRAT: SRAT not used.\n");
-	acpi_numa = -1;
-}
-
-static __init inline int srat_disabled(void)
-{
-	return acpi_numa < 0;
-}
-
 /* Callback for Proximity Domain -> x2APIC mapping */
 void __init
 acpi_numa_x2apic_affinity_init(struct acpi_srat_x2apic_cpu_affinity *pa)
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 5403d62..9b35ba9 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -40,6 +40,7 @@ static int node_to_pxm_map[MAX_NUMNODES]
 			= { [0 ... MAX_NUMNODES - 1] = PXM_INVAL };
 
 unsigned char acpi_srat_revision __initdata;
+int acpi_numa __initdata;
 
 int pxm_to_node(int pxm)
 {
diff --git a/include/acpi/acpi_numa.h b/include/acpi/acpi_numa.h
index 94a37cd..28f06a6 100644
--- a/include/acpi/acpi_numa.h
+++ b/include/acpi/acpi_numa.h
@@ -15,6 +15,18 @@ extern int pxm_to_node(int);
 extern int node_to_pxm(int);
 extern int acpi_map_pxm_to_node(int);
 extern unsigned char acpi_srat_revision;
+extern int acpi_numa __initdata;
+
+static inline void bad_srat(void)
+{
+	pr_err("SRAT: SRAT not used.\n");
+	acpi_numa = -1;
+}
+
+static  inline int srat_disabled(void)
+{
+	return acpi_numa < 0;
+}
 
 #endif				/* CONFIG_ACPI_NUMA */
 #endif				/* __ACP_NUMA_H */
-- 
1.7.11.7

