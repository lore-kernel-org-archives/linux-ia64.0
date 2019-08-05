From: Chuhong Yuan <hslester96@gmail.com>
Date: Mon, 05 Aug 2019 07:27:09 +0000
Subject: [PATCH 2/2] ia64: Replace strncmp with str_has_prefix
Message-Id: <20190805072709.345-1-hslester96@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-efi@vger.kernel.org, Chuhong Yuan <hslester96@gmail.com>

strncmp(str, const, len) is error-prone since the len is
easy to be wrong because of counting error or sizeof(const)
without - 1.

Use the newly introduced str_has_prefix() to substitute
it to make code better.

Signed-off-by: Chuhong Yuan <hslester96@gmail.com>
---
 arch/ia64/kernel/acpi.c | 9 ++++-----
 arch/ia64/kernel/efi.c  | 2 +-
 arch/ia64/kernel/esi.c  | 2 +-
 arch/ia64/kernel/sal.c  | 2 +-
 4 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index c597ab5275b8..f01e6fb2f962 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -77,7 +77,7 @@ acpi_get_sysname(void)
 	}
 
 	rsdp = (struct acpi_table_rsdp *)__va(rsdp_phys);
-	if (strncmp(rsdp->signature, ACPI_SIG_RSDP, sizeof(ACPI_SIG_RSDP) - 1)) {
+	if (!str_has_prefix(rsdp->signature, ACPI_SIG_RSDP)) {
 		printk(KERN_ERR
 		       "ACPI 2.0 RSDP signature incorrect, default to \"dig\"\n");
 		return "dig";
@@ -85,7 +85,7 @@ acpi_get_sysname(void)
 
 	xsdt = (struct acpi_table_xsdt *)__va(rsdp->xsdt_physical_address);
 	hdr = &xsdt->header;
-	if (strncmp(hdr->signature, ACPI_SIG_XSDT, sizeof(ACPI_SIG_XSDT) - 1)) {
+	if (!str_has_prefix(hdr->signature, ACPI_SIG_XSDT)) {
 		printk(KERN_ERR
 		       "ACPI 2.0 XSDT signature incorrect, default to \"dig\"\n");
 		return "dig";
@@ -106,8 +106,7 @@ acpi_get_sysname(void)
 			 sizeof(xsdt->table_offset_entry[0]);
 	for (i = 0; i < nentries; i++) {
 		hdr = __va(xsdt->table_offset_entry[i]);
-		if (strncmp(hdr->signature, ACPI_SIG_DMAR,
-			sizeof(ACPI_SIG_DMAR) - 1) = 0)
+		if (str_has_prefix(hdr->signature, ACPI_SIG_DMAR))
 			return "dig_vtd";
 	}
 #endif
@@ -348,7 +347,7 @@ acpi_parse_nmi_src(union acpi_subtable_headers * header, const unsigned long end
 
 static void __init acpi_madt_oem_check(char *oem_id, char *oem_table_id)
 {
-	if (!strncmp(oem_id, "IBM", 3) && (!strncmp(oem_table_id, "SERMOW", 6))) {
+	if (str_has_prefix(oem_id, "IBM") && (str_has_prefix(oem_table_id, "SERMOW"))) {
 
 		/*
 		 * Unfortunately ITC_DRIFT is not yet part of the
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 3795d18276c4..615e73bd88fd 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -434,7 +434,7 @@ static void __init handle_palo(unsigned long phys_addr)
 	struct palo_table *palo = __va(phys_addr);
 	u8  checksum;
 
-	if (strncmp(palo->signature, PALO_SIG, sizeof(PALO_SIG) - 1)) {
+	if (!str_has_prefix(palo->signature, PALO_SIG)) {
 		printk(KERN_INFO "PALO signature incorrect.\n");
 		return;
 	}
diff --git a/arch/ia64/kernel/esi.c b/arch/ia64/kernel/esi.c
index cb514126ef7f..d929689a99e4 100644
--- a/arch/ia64/kernel/esi.c
+++ b/arch/ia64/kernel/esi.c
@@ -70,7 +70,7 @@ static int __init esi_init (void)
 
 	systab = __va(esi);
 
-	if (strncmp(systab->signature, "ESIT", 4) != 0) {
+	if (!str_has_prefix(systab->signature, "ESIT")) {
 		printk(KERN_ERR "bad signature in ESI system table!");
 		return -ENODEV;
 	}
diff --git a/arch/ia64/kernel/sal.c b/arch/ia64/kernel/sal.c
index 9b2331ac10ce..9f02e3ec28e5 100644
--- a/arch/ia64/kernel/sal.c
+++ b/arch/ia64/kernel/sal.c
@@ -315,7 +315,7 @@ ia64_sal_init (struct ia64_sal_systab *systab)
 		return;
 	}
 
-	if (strncmp(systab->signature, "SST_", 4) != 0)
+	if (!str_has_prefix(systab->signature, "SST_"))
 		printk(KERN_ERR "bad signature in system table!");
 
 	check_versions(systab);
-- 
2.20.1
