From: Leif Lindholm <leif.lindholm@linaro.org>
Date: Tue, 30 Jul 2013 16:47:35 +0000
Subject: [PATCH 1/4] efi: provide a generic efi_config_init()
Message-Id: <1375202858-28470-2-git-send-email-leif.lindholm@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1375202858-28470-1-git-send-email-leif.lindholm@linaro.org>
In-Reply-To: <1375202858-28470-1-git-send-email-leif.lindholm@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, hpa@zytor.com, tglx@linutronix.de, patches@linaro.org, Leif Lindholm <leif.lindholm@linaro.org>

Common to (U)EFI support on all platforms is the global "efi" data
structure, and the code that parses the System Table to locate
addresses to populate that structure with.

This patch adds both of these to the global EFI driver code.

Since existing code for both x86 and ia64 contained handling of
tables specific to the respective platform, efi_config_init()
takes an optional pointer to a list of valid architecture-specific 
tables and pointers to populate on comparison hit.

Patches removing the original platform-specific code and moving
those platforms to using the below code follow later in the series.

Note: use of early_memremap() instead of early_ioremap() for better
semantic match for ARM support.

Signed-off-by: Leif Lindholm <leif.lindholm@linaro.org>
---
 drivers/firmware/efi/efi.c |  106 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/efi.h        |    7 +++
 2 files changed, 113 insertions(+)

diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 5145fa3..4fa944a 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -18,6 +18,20 @@
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
@@ -132,3 +146,95 @@ err_put:
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
+	u8 str[38];
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

