From: Leif Lindholm <leif.lindholm@linaro.org>
Date: Fri, 02 Aug 2013 16:56:20 +0000
Subject: [PATCH v2 3/5] efi: x86: use common code for (U)EFI configuration scanning
Message-Id: <1375462582-16423-4-git-send-email-leif.lindholm@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1375462582-16423-1-git-send-email-leif.lindholm@linaro.org>
In-Reply-To: <1375462582-16423-1-git-send-email-leif.lindholm@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, tony.luck@gmail.com, patches@linaro.org, Leif Lindholm <leif.lindholm@linaro.org>

This patch makes x86 use the new common code for configuration table
scanning. It also removes the local definition of the global "efi"
data structure.

Signed-off-by: Leif Lindholm <leif.lindholm@linaro.org>
---
 arch/x86/platform/efi/efi.c |   96 ++++---------------------------------------
 1 file changed, 8 insertions(+), 88 deletions(-)

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
-- 
1.7.10.4

