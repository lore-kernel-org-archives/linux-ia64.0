From: Leif Lindholm <leif.lindholm@linaro.org>
Date: Fri, 02 Aug 2013 16:56:21 +0000
Subject: [PATCH v2 4/5] efi: ia64: use common code for (U)EFI configuration scanning
Message-Id: <1375462582-16423-5-git-send-email-leif.lindholm@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1375462582-16423-1-git-send-email-leif.lindholm@linaro.org>
In-Reply-To: <1375462582-16423-1-git-send-email-leif.lindholm@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, tony.luck@gmail.com, patches@linaro.org, Leif Lindholm <leif.lindholm@linaro.org>

This patch makes ia64 use the new common code for configuration table
scanning. It also removes the local definition of the global "efi"
data structure.

Signed-off-by: Leif Lindholm <leif.lindholm@linaro.org>
---
 arch/ia64/kernel/efi.c |   54 ++++++++++--------------------------------------
 1 file changed, 11 insertions(+), 43 deletions(-)

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
-- 
1.7.10.4

