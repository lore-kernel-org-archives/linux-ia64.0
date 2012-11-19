From: Bill Pemberton <wfp5p@virginia.edu>
Date: Mon, 19 Nov 2012 18:24:50 +0000
Subject: [PATCH 341/493] ia64: remove use of __devinitdata
Message-Id: <1353349642-3677-341-git-send-email-wfp5p@virginia.edu>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

CONFIG_HOTPLUG is going away as an option so __devinitdata is no
longer needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Tony Luck <tony.luck@intel.com>  PL...)
Cc: Fenghua Yu <fenghua.yu@intel.com>  PL...)
Cc: linux-ia64@vger.kernel.org  PL...)
---
 arch/ia64/include/asm/acpi.h | 2 +-
 arch/ia64/include/asm/smp.h  | 2 +-
 arch/ia64/kernel/acpi.c      | 2 +-
 arch/ia64/kernel/iosapic.c   | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
index 301609c..359e68a 100644
--- a/arch/ia64/include/asm/acpi.h
+++ b/arch/ia64/include/asm/acpi.h
@@ -153,7 +153,7 @@ extern int additional_cpus;
 #else
 #define MAX_PXM_DOMAINS (256)
 #endif
-extern int __devinitdata pxm_to_nid_map[MAX_PXM_DOMAINS];
+extern int pxm_to_nid_map[MAX_PXM_DOMAINS];
 extern int __initdata nid_to_pxm_map[MAX_NUMNODES];
 #endif
 
diff --git a/arch/ia64/include/asm/smp.h b/arch/ia64/include/asm/smp.h
index 0b3b399..fea21e9 100644
--- a/arch/ia64/include/asm/smp.h
+++ b/arch/ia64/include/asm/smp.h
@@ -55,7 +55,7 @@ extern struct smp_boot_data {
 	int cpu_phys_id[NR_CPUS];
 } smp_boot_data __initdata;
 
-extern char no_int_routing __devinitdata;
+extern char no_int_routing;
 
 extern cpumask_t cpu_core_map[NR_CPUS];
 DECLARE_PER_CPU_SHARED_ALIGNED(cpumask_t, cpu_sibling_map);
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index fbaefd8..af28275 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -422,7 +422,7 @@ static int __init acpi_parse_madt(struct acpi_table_header *table)
 #define PXM_FLAG_LEN ((MAX_PXM_DOMAINS + 1)/32)
 
 static int __initdata srat_num_cpus;	/* number of cpus */
-static u32 __devinitdata pxm_flag[PXM_FLAG_LEN];
+static u32 pxm_flag[PXM_FLAG_LEN];
 #define pxm_bit_set(bit)	(set_bit(bit,(void *)pxm_flag))
 #define pxm_bit_test(bit)	(test_bit(bit,(void *)pxm_flag))
 static struct acpi_table_slit __initdata *slit_table;
diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index bf8709c..6d712b7 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -147,7 +147,7 @@ static struct iosapic_intr_info {
 	unsigned char	trigger	: 1;	/* trigger mode (see iosapic.h) */
 } iosapic_intr_info[NR_IRQS];
 
-static unsigned char pcat_compat __devinitdata;	/* 8259 compatibility flag */
+static unsigned char pcat_compat;	/* 8259 compatibility flag */
 
 static inline void
 iosapic_write(struct iosapic *iosapic, unsigned int reg, u32 val)
-- 
1.8.0

