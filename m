From: Leif Lindholm <leif.lindholm@linaro.org>
Date: Thu, 05 Sep 2013 10:34:54 +0000
Subject: [PATCH v4 2/3] efi: x86: ia64: provide a generic efi_config_init()
Message-Id: <1378377295-32758-3-git-send-email-leif.lindholm@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1378377295-32758-1-git-send-email-leif.lindholm@linaro.org>
In-Reply-To: <1378377295-32758-1-git-send-email-leif.lindholm@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, tony.luck@gmail.com, grant.likely@secretlab.ca, Leif Lindholm <leif.lindholm@linaro.org>

Common to (U)EFI support on all platforms is the global "efi" data
structure, and the code that parses the System Table to locate
addresses to populate that structure with.

This patch adds both of these to the global EFI driver code and
removes the local definition of the global "efi" data structure from
the x86 and ia64 code.

Squashed into one big patch to avoid breaking bisection.

Signed-off-by: Leif Lindholm <leif.lindholm@linaro.org>
Acked-by: Tony Luck <tony.luck@intel.com>
Signed-off-by: Matt Fleming <matt.fleming@intel.com>
---
 arch/ia64/kernel/efi.c      |   54 +++++-----------------
 arch/x86/platform/efi/efi.c |   96 ++++----------------------------------
 drivers/firmware/efi/efi.c  |  108 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/efi.h         |    7 +++
 4 files changed, 134 insertions(+), 131 deletions(-)

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 51bce59..da5b462 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -44,10 +44,15 @@
 
 #define EFI_DEBUG	0
 
+static __initdata unsigned long palo_phys;
+
+static __initdata efi_config_table_type_t arch_tables[] = {
+	{PROCESSOR_ABSTRACTION_LAYER_OVERWRITE_GUID, "PALO", &palo_phys},
+	{NULL_GUID, NULL, 0},
+};
+
 extern efi_status_t efi_call_phys (void *, ...);
 
-struct efi efi;
-EXPORT_SYMBOL(efi);
 static efi_runtime_services_t *runtime;
 static u64 mem_limit = ~0UL, max_addr = ~0UL, min_addr = 0UL;
 
@@ -423,9 +428,9 @@ static u8 __init palo_checksum(u8 *buffer, u32 length)
  * Parse and handle PALO table which is published at:
  * http://www.dig64.org/home/DIG64_PALO_R1_0.pdf
  */
-static void __init handle_palo(unsigned long palo_phys)
+static void __init handle_palo(unsigned long phys_addr)
 {
-	struct palo_table *palo = __va(palo_phys);
+	struct palo_table *palo = __va(phys_addr);
 	u8  checksum;
 
 	if (strncmp(palo->signature, PALO_SIG, sizeof(PALO_SIG) - 1)) {
@@ -467,12 +472,10 @@ void __init
 efi_init (void)
 {
 	void *efi_map_start, *efi_map_end;
-	efi_config_table_t *config_tables;
 	efi_char16_t *c16;
 	u64 efi_desc_size;
 	char *cp, vendor[100] = "unknown";
 	int i;
-	unsigned long palo_phys;
 
 	/*
 	 * It's too early to be able to use the standard kernel command line
@@ -514,8 +517,6 @@ efi_init (void)
 		       efi.systab->hdr.revision >> 16,
 		       efi.systab->hdr.revision & 0xffff);
 
-	config_tables = __va(efi.systab->tables);
-
 	/* Show what we know for posterity */
 	c16 = __va(efi.systab->fw_vendor);
 	if (c16) {
@@ -528,43 +529,10 @@ efi_init (void)
 	       efi.systab->hdr.revision >> 16,
 	       efi.systab->hdr.revision & 0xffff, vendor);
 
-	efi.mps        = EFI_INVALID_TABLE_ADDR;
-	efi.acpi       = EFI_INVALID_TABLE_ADDR;
-	efi.acpi20     = EFI_INVALID_TABLE_ADDR;
-	efi.smbios     = EFI_INVALID_TABLE_ADDR;
-	efi.sal_systab = EFI_INVALID_TABLE_ADDR;
-	efi.boot_info  = EFI_INVALID_TABLE_ADDR;
-	efi.hcdp       = EFI_INVALID_TABLE_ADDR;
-	efi.uga        = EFI_INVALID_TABLE_ADDR;
-
 	palo_phys      = EFI_INVALID_TABLE_ADDR;
 
-	for (i = 0; i < (int) efi.systab->nr_tables; i++) {
-		if (efi_guidcmp(config_tables[i].guid, MPS_TABLE_GUID) = 0) {
-			efi.mps = config_tables[i].table;
-			printk(" MPS=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, ACPI_20_TABLE_GUID) = 0) {
-			efi.acpi20 = config_tables[i].table;
-			printk(" ACPI 2.0=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, ACPI_TABLE_GUID) = 0) {
-			efi.acpi = config_tables[i].table;
-			printk(" ACPI=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, SMBIOS_TABLE_GUID) = 0) {
-			efi.smbios = config_tables[i].table;
-			printk(" SMBIOS=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, SAL_SYSTEM_TABLE_GUID) = 0) {
-			efi.sal_systab = config_tables[i].table;
-			printk(" SALsystab=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, HCDP_TABLE_GUID) = 0) {
-			efi.hcdp = config_tables[i].table;
-			printk(" HCDP=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid,
-			 PROCESSOR_ABSTRACTION_LAYER_OVERWRITE_GUID) = 0) {
-			palo_phys = config_tables[i].table;
-			printk(" PALO=0x%lx", config_tables[i].table);
-		}
-	}
-	printk("\n");
+	if (efi_config_init(arch_tables) != 0)
+		return;
 
 	if (palo_phys != EFI_INVALID_TABLE_ADDR)
 		handle_palo(palo_phys);
diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index 90f6ed1..ed2be58 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -60,19 +60,6 @@
 
 static efi_char16_t efi_dummy_name[6] = { 'D', 'U', 'M', 'M', 'Y', 0 };
 
-struct efi __read_mostly efi = {
-	.mps        = EFI_INVALID_TABLE_ADDR,
-	.acpi       = EFI_INVALID_TABLE_ADDR,
-	.acpi20     = EFI_INVALID_TABLE_ADDR,
-	.smbios     = EFI_INVALID_TABLE_ADDR,
-	.sal_systab = EFI_INVALID_TABLE_ADDR,
-	.boot_info  = EFI_INVALID_TABLE_ADDR,
-	.hcdp       = EFI_INVALID_TABLE_ADDR,
-	.uga        = EFI_INVALID_TABLE_ADDR,
-	.uv_systab  = EFI_INVALID_TABLE_ADDR,
-};
-EXPORT_SYMBOL(efi);
-
 struct efi_memory_map memmap;
 
 static struct efi efi_phys __initdata;
@@ -80,6 +67,13 @@ static efi_system_table_t efi_systab __initdata;
 
 unsigned long x86_efi_facility;
 
+static __initdata efi_config_table_type_t arch_tables[] = {
+#ifdef CONFIG_X86_UV
+	{UV_SYSTEM_TABLE_GUID, "UVsystab", &efi.uv_systab},
+#endif
+	{NULL_GUID, NULL, 0},
+};
+
 /*
  * Returns 1 if 'facility' is enabled, 0 otherwise.
  */
@@ -578,80 +572,6 @@ static int __init efi_systab_init(void *phys)
 	return 0;
 }
 
-static int __init efi_config_init(u64 tables, int nr_tables)
-{
-	void *config_tables, *tablep;
-	int i, sz;
-
-	if (efi_enabled(EFI_64BIT))
-		sz = sizeof(efi_config_table_64_t);
-	else
-		sz = sizeof(efi_config_table_32_t);
-
-	/*
-	 * Let's see what config tables the firmware passed to us.
-	 */
-	config_tables = early_ioremap(tables, nr_tables * sz);
-	if (config_tables = NULL) {
-		pr_err("Could not map Configuration table!\n");
-		return -ENOMEM;
-	}
-
-	tablep = config_tables;
-	pr_info("");
-	for (i = 0; i < efi.systab->nr_tables; i++) {
-		efi_guid_t guid;
-		unsigned long table;
-
-		if (efi_enabled(EFI_64BIT)) {
-			u64 table64;
-			guid = ((efi_config_table_64_t *)tablep)->guid;
-			table64 = ((efi_config_table_64_t *)tablep)->table;
-			table = table64;
-#ifdef CONFIG_X86_32
-			if (table64 >> 32) {
-				pr_cont("\n");
-				pr_err("Table located above 4GB, disabling EFI.\n");
-				early_iounmap(config_tables,
-					      efi.systab->nr_tables * sz);
-				return -EINVAL;
-			}
-#endif
-		} else {
-			guid = ((efi_config_table_32_t *)tablep)->guid;
-			table = ((efi_config_table_32_t *)tablep)->table;
-		}
-		if (!efi_guidcmp(guid, MPS_TABLE_GUID)) {
-			efi.mps = table;
-			pr_cont(" MPS=0x%lx ", table);
-		} else if (!efi_guidcmp(guid, ACPI_20_TABLE_GUID)) {
-			efi.acpi20 = table;
-			pr_cont(" ACPI 2.0=0x%lx ", table);
-		} else if (!efi_guidcmp(guid, ACPI_TABLE_GUID)) {
-			efi.acpi = table;
-			pr_cont(" ACPI=0x%lx ", table);
-		} else if (!efi_guidcmp(guid, SMBIOS_TABLE_GUID)) {
-			efi.smbios = table;
-			pr_cont(" SMBIOS=0x%lx ", table);
-#ifdef CONFIG_X86_UV
-		} else if (!efi_guidcmp(guid, UV_SYSTEM_TABLE_GUID)) {
-			efi.uv_systab = table;
-			pr_cont(" UVsystab=0x%lx ", table);
-#endif
-		} else if (!efi_guidcmp(guid, HCDP_TABLE_GUID)) {
-			efi.hcdp = table;
-			pr_cont(" HCDP=0x%lx ", table);
-		} else if (!efi_guidcmp(guid, UGA_IO_PROTOCOL_GUID)) {
-			efi.uga = table;
-			pr_cont(" UGA=0x%lx ", table);
-		}
-		tablep += sz;
-	}
-	pr_cont("\n");
-	early_iounmap(config_tables, efi.systab->nr_tables * sz);
-	return 0;
-}
-
 static int __init efi_runtime_init(void)
 {
 	efi_runtime_services_t *runtime;
@@ -745,7 +665,7 @@ void __init efi_init(void)
 		efi.systab->hdr.revision >> 16,
 		efi.systab->hdr.revision & 0xffff, vendor);
 
-	if (efi_config_init(efi.systab->tables, efi.systab->nr_tables))
+	if (efi_config_init(arch_tables))
 		return;
 
 	set_bit(EFI_CONFIG_TABLES, &x86_efi_facility);
diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 5145fa3..e1010d4 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -13,11 +13,27 @@
  * This file is released under the GPLv2.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kobject.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/device.h>
 #include <linux/efi.h>
+#include <linux/io.h>
+
+struct efi __read_mostly efi = {
+	.mps        = EFI_INVALID_TABLE_ADDR,
+	.acpi       = EFI_INVALID_TABLE_ADDR,
+	.acpi20     = EFI_INVALID_TABLE_ADDR,
+	.smbios     = EFI_INVALID_TABLE_ADDR,
+	.sal_systab = EFI_INVALID_TABLE_ADDR,
+	.boot_info  = EFI_INVALID_TABLE_ADDR,
+	.hcdp       = EFI_INVALID_TABLE_ADDR,
+	.uga        = EFI_INVALID_TABLE_ADDR,
+	.uv_systab  = EFI_INVALID_TABLE_ADDR,
+};
+EXPORT_SYMBOL(efi);
 
 static struct kobject *efi_kobj;
 static struct kobject *efivars_kobj;
@@ -132,3 +148,95 @@ err_put:
 }
 
 subsys_initcall(efisubsys_init);
+
+
+static __initdata efi_config_table_type_t common_tables[] = {
+	{ACPI_20_TABLE_GUID, "ACPI 2.0", &efi.acpi20},
+	{ACPI_TABLE_GUID, "ACPI", &efi.acpi},
+	{HCDP_TABLE_GUID, "HCDP", &efi.hcdp},
+	{MPS_TABLE_GUID, "MPS", &efi.mps},
+	{SAL_SYSTEM_TABLE_GUID, "SALsystab", &efi.sal_systab},
+	{SMBIOS_TABLE_GUID, "SMBIOS", &efi.smbios},
+	{UGA_IO_PROTOCOL_GUID, "UGA", &efi.uga},
+	{NULL_GUID, NULL, 0},
+};
+
+static __init int match_config_table(efi_guid_t *guid,
+				     unsigned long table,
+				     efi_config_table_type_t *table_types)
+{
+	u8 str[EFI_VARIABLE_GUID_LEN + 1];
+	int i;
+
+	if (table_types) {
+		efi_guid_unparse(guid, str);
+
+		for (i = 0; efi_guidcmp(table_types[i].guid, NULL_GUID); i++) {
+			efi_guid_unparse(&table_types[i].guid, str);
+
+			if (!efi_guidcmp(*guid, table_types[i].guid)) {
+				*(table_types[i].ptr) = table;
+				pr_cont(" %s=0x%lx ",
+					table_types[i].name, table);
+				return 1;
+			}
+		}
+	}
+
+	return 0;
+}
+
+int __init efi_config_init(efi_config_table_type_t *arch_tables)
+{
+	void *config_tables, *tablep;
+	int i, sz;
+
+	if (efi_enabled(EFI_64BIT))
+		sz = sizeof(efi_config_table_64_t);
+	else
+		sz = sizeof(efi_config_table_32_t);
+
+	/*
+	 * Let's see what config tables the firmware passed to us.
+	 */
+	config_tables = early_memremap(efi.systab->tables,
+				       efi.systab->nr_tables * sz);
+	if (config_tables = NULL) {
+		pr_err("Could not map Configuration table!\n");
+		return -ENOMEM;
+	}
+
+	tablep = config_tables;
+	pr_info("");
+	for (i = 0; i < efi.systab->nr_tables; i++) {
+		efi_guid_t guid;
+		unsigned long table;
+
+		if (efi_enabled(EFI_64BIT)) {
+			u64 table64;
+			guid = ((efi_config_table_64_t *)tablep)->guid;
+			table64 = ((efi_config_table_64_t *)tablep)->table;
+			table = table64;
+#ifndef CONFIG_64BIT
+			if (table64 >> 32) {
+				pr_cont("\n");
+				pr_err("Table located above 4GB, disabling EFI.\n");
+				early_iounmap(config_tables,
+					       efi.systab->nr_tables * sz);
+				return -EINVAL;
+			}
+#endif
+		} else {
+			guid = ((efi_config_table_32_t *)tablep)->guid;
+			table = ((efi_config_table_32_t *)tablep)->table;
+		}
+
+		if (!match_config_table(&guid, table, common_tables))
+			match_config_table(&guid, table, arch_tables);
+
+		tablep += sz;
+	}
+	pr_cont("\n");
+	early_iounmap(config_tables, efi.systab->nr_tables * sz);
+	return 0;
+}
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 5f8f176..09d9e42 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -404,6 +404,12 @@ typedef struct {
 	unsigned long table;
 } efi_config_table_t;
 
+typedef struct {
+	efi_guid_t guid;
+	const char *name;
+	unsigned long *ptr;
+} efi_config_table_type_t;
+
 #define EFI_SYSTEM_TABLE_SIGNATURE ((u64)0x5453595320494249ULL)
 
 #define EFI_2_30_SYSTEM_TABLE_REVISION  ((2 << 16) | (30))
@@ -587,6 +593,7 @@ static inline efi_status_t efi_query_variable_store(u32 attributes, unsigned lon
 }
 #endif
 extern void __iomem *efi_lookup_mapped_addr(u64 phys_addr);
+extern int efi_config_init(efi_config_table_type_t *arch_tables);
 extern u64 efi_get_iobase (void);
 extern u32 efi_mem_type (unsigned long phys_addr);
 extern u64 efi_mem_attributes (unsigned long phys_addr);
-- 
1.7.10.4

