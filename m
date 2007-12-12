From: Aron Griffis <aron@hp.com>
Date: Wed, 12 Dec 2007 15:07:51 +0000
Subject: [PATCH 4 of 4] Add efi_guidtest_set to reduce duplication
Message-Id: <81b2361265e2950b6a62.1197472071@jenkins.nashua>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

# HG changeset patch
# User Aron Griffis <aron@hp.com>
# Date 1197470701 18000
# Node ID 81b2361265e2950b6a627c00e36a27aa43e3fdb5
# Parent  cc913b598bc641c5584bff8ad379d4e213367076
Add efi_guidtest_set to reduce duplication

This is a list of duplicated tests.  Using a #define makes it easier to add new
ones and harder to introduce an error.

Signed-off-by: Aron Griffis <aron@hp.com>

diff -r cc913b598bc6 -r 81b2361265e2 arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c	Wed Dec 12 09:43:15 2007 -0500
+++ b/arch/ia64/kernel/efi.c	Wed Dec 12 09:45:01 2007 -0500
@@ -497,32 +497,20 @@ efi_init (void)
 	efi.hcdp       = EFI_INVALID_TABLE_ADDR;
 	efi.uga        = EFI_INVALID_TABLE_ADDR;
 
+#define efi_guidcmp_set(g, t, s)					       \
+	if (efi_guidcmp(config_tables[i].guid, g) = 0) {		       \
+		efi.t = config_tables[i].table;				       \
+		printk(" " s "=0x%lx", config_tables[i].table);		       \
+		continue;						       \
+	} else /* silly hack for semicolon */
+
 	for (i = 0; i < (int) efi.systab->nr_tables; i++) {
-		if (efi_guidcmp(config_tables[i].guid, 
-				MPS_TABLE_GUID) = 0) {
-			efi.mps = config_tables[i].table;
-			printk(" MPS=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, 
-				       ACPI_20_TABLE_GUID) = 0) {
-			efi.acpi20 = config_tables[i].table;
-			printk(" ACPI 2.0=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, 
-				       ACPI_TABLE_GUID) = 0) {
-			efi.acpi = config_tables[i].table;
-			printk(" ACPI=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, 
-				       SMBIOS_TABLE_GUID) = 0) {
-			efi.smbios = config_tables[i].table;
-			printk(" SMBIOS=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, 
-				       SAL_SYSTEM_TABLE_GUID) = 0) {
-			efi.sal_systab = config_tables[i].table;
-			printk(" SALsystab=0x%lx", config_tables[i].table);
-		} else if (efi_guidcmp(config_tables[i].guid, 
-				       HCDP_TABLE_GUID) = 0) {
-			efi.hcdp = config_tables[i].table;
-			printk(" HCDP=0x%lx", config_tables[i].table);
-		}
+		efi_guidcmp_set(MPS_TABLE_GUID,        mps,        "MPS");
+		efi_guidcmp_set(ACPI_20_TABLE_GUID,    acpi20,     "ACPI 2.0");
+		efi_guidcmp_set(ACPI_TABLE_GUID,       acpi,       "ACPI");
+		efi_guidcmp_set(SMBIOS_TABLE_GUID,     smbios,     "SMBIOS");
+		efi_guidcmp_set(SAL_SYSTEM_TABLE_GUID, sal_systab, "SALsystab");
+		efi_guidcmp_set(HCDP_TABLE_GUID,       hcdp,       "HCDP");
 	}
 	printk("\n");
 


