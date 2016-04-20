From: David Daney <ddaney.cavm@gmail.com>
Date: Wed, 20 Apr 2016 01:40:32 +0000
Subject: [PATCH v5 07/14] x86, acpi, numa: cleanup acpi_numa_processor_affinity_init()
Message-Id: <1461116439-22991-8-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461116439-22991-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1461116439-22991-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org
Cc: Robert Richter <rrichter@cavium.com>, linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>

From: Hanjun Guo <hanjun.guo@linaro.org>

Cleanup acpi_numa_processor_affinity_init() in preparation for its
move to drivers/acpi/numa.c.  It will be reused by arm64, this has no
functional change.

Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
Signed-off-by: Robert Richter <rrichter@cavium.com>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/x86/mm/srat.c | 21 +++++----------------
 1 file changed, 5 insertions(+), 16 deletions(-)

diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index f242a11..9e2a833 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -26,11 +26,6 @@
 
 int acpi_numa __initdata;
 
-static __init int setup_node(int pxm)
-{
-	return acpi_map_pxm_to_node(pxm);
-}
-
 static __init void bad_srat(void)
 {
 	printk(KERN_ERR "SRAT: SRAT not used.\n");
@@ -64,7 +59,7 @@ acpi_numa_x2apic_affinity_init(struct acpi_srat_x2apic_cpu_affinity *pa)
 			 pxm, apic_id);
 		return;
 	}
-	node = setup_node(pxm);
+	node = acpi_map_pxm_to_node(pxm);
 	if (node < 0) {
 		printk(KERN_ERR "SRAT: Too many proximity domains %x\n", pxm);
 		bad_srat();
@@ -100,7 +95,7 @@ acpi_numa_processor_affinity_init(struct acpi_srat_cpu_affinity *pa)
 	pxm = pa->proximity_domain_lo;
 	if (acpi_srat_revision >= 2)
 		pxm |= *((unsigned int*)pa->proximity_domain_hi) << 8;
-	node = setup_node(pxm);
+	node = acpi_map_pxm_to_node(pxm);
 	if (node < 0) {
 		printk(KERN_ERR "SRAT: Too many proximity domains %x\n", pxm);
 		bad_srat();
@@ -124,12 +119,6 @@ acpi_numa_processor_affinity_init(struct acpi_srat_cpu_affinity *pa)
 	       pxm, apic_id, node);
 }
 
-#ifdef CONFIG_MEMORY_HOTPLUG
-static inline int save_add_info(void) {return 1;}
-#else
-static inline int save_add_info(void) {return 0;}
-#endif
-
 /* Callback for parsing of the Proximity Domain <-> Memory Area mappings */
 int __init
 acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
@@ -145,7 +134,7 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 	if ((ma->flags & ACPI_SRAT_MEM_ENABLED) = 0)
 		goto out_err;
 	hotpluggable = ma->flags & ACPI_SRAT_MEM_HOT_PLUGGABLE;
-	if (hotpluggable && !save_add_info())
+	if (hotpluggable && !IS_ENABLED(CONFIG_MEMORY_HOTPLUG))
 		goto out_err;
 
 	start = ma->base_address;
@@ -154,7 +143,7 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 	if (acpi_srat_revision <= 1)
 		pxm &= 0xff;
 
-	node = setup_node(pxm);
+	node = acpi_map_pxm_to_node(pxm);
 	if (node < 0) {
 		printk(KERN_ERR "SRAT: Too many proximity domains.\n");
 		goto out_err_bad_srat;
@@ -182,7 +171,7 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 out_err_bad_srat:
 	bad_srat();
 out_err:
-	return -1;
+	return -EINVAL;
 }
 
 int __init x86_acpi_numa_init(void)
-- 
1.7.11.7

