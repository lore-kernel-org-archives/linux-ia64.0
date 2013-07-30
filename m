From: Leif Lindholm <leif.lindholm@linaro.org>
Date: Tue, 30 Jul 2013 16:47:38 +0000
Subject: [PATCH 4/4] efi: x86: make efi_lookup_mapped_addr() a common function
Message-Id: <1375202858-28470-5-git-send-email-leif.lindholm@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1375202858-28470-1-git-send-email-leif.lindholm@linaro.org>
In-Reply-To: <1375202858-28470-1-git-send-email-leif.lindholm@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, hpa@zytor.com, tglx@linutronix.de, patches@linaro.org, Leif Lindholm <leif.lindholm@linaro.org>

efi_lookup_mapped_addr() is a handy utility for other platforms
than x86. Move it from arch/x86 to drivers/firmware/efi.

This function will be used by future ARM patches.

Signed-off-by: Leif Lindholm <leif.lindholm@linaro.org>
---
 arch/x86/platform/efi/efi.c |   28 ----------------------------
 drivers/firmware/efi/efi.c  |   30 ++++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index ed2be58..3af9d36 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -736,34 +736,6 @@ static void __init runtime_code_page_mkexec(void)
 	}
 }
 
-/*
- * We can't ioremap data in EFI boot services RAM, because we've already mapped
- * it as RAM.  So, look it up in the existing EFI memory map instead.  Only
- * callable after efi_enter_virtual_mode and before efi_free_boot_services.
- */
-void __iomem *efi_lookup_mapped_addr(u64 phys_addr)
-{
-	void *p;
-	if (WARN_ON(!memmap.map))
-		return NULL;
-	for (p = memmap.map; p < memmap.map_end; p += memmap.desc_size) {
-		efi_memory_desc_t *md = p;
-		u64 size = md->num_pages << EFI_PAGE_SHIFT;
-		u64 end = md->phys_addr + size;
-		if (!(md->attribute & EFI_MEMORY_RUNTIME) &&
-		    md->type != EFI_BOOT_SERVICES_CODE &&
-		    md->type != EFI_BOOT_SERVICES_DATA)
-			continue;
-		if (!md->virt_addr)
-			continue;
-		if (phys_addr >= md->phys_addr && phys_addr < end) {
-			phys_addr += md->virt_addr - md->phys_addr;
-			return (__force void __iomem *)(unsigned long)phys_addr;
-		}
-	}
-	return NULL;
-}
-
 void efi_memory_uc(u64 addr, unsigned long size)
 {
 	unsigned long page_shift = 1UL << EFI_PAGE_SHIFT;
diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 4fa944a..94f57c0 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -148,6 +148,36 @@ err_put:
 subsys_initcall(efisubsys_init);
 
 
+#if defined(CONFIG_X86)
+/*
+ * We can't ioremap data in EFI boot services RAM, because we've already mapped
+ * it as RAM.  So, look it up in the existing EFI memory map instead.  Only
+ * callable after efi_enter_virtual_mode and before efi_free_boot_services.
+ */
+void __iomem *efi_lookup_mapped_addr(u64 phys_addr)
+{
+	void *p;
+	if (WARN_ON(!memmap.map))
+		return NULL;
+	for (p = memmap.map; p < memmap.map_end; p += memmap.desc_size) {
+		efi_memory_desc_t *md = p;
+		u64 size = md->num_pages << EFI_PAGE_SHIFT;
+		u64 end = md->phys_addr + size;
+		if (!(md->attribute & EFI_MEMORY_RUNTIME) &&
+		    md->type != EFI_BOOT_SERVICES_CODE &&
+		    md->type != EFI_BOOT_SERVICES_DATA)
+			continue;
+		if (!md->virt_addr)
+			continue;
+		if (phys_addr >= md->phys_addr && phys_addr < end) {
+			phys_addr += md->virt_addr - md->phys_addr;
+			return (__force void __iomem *)(unsigned long)phys_addr;
+		}
+	}
+	return NULL;
+}
+#endif
+
 static __initdata efi_config_table_type_t common_tables[] = {
 	{ACPI_20_TABLE_GUID, "ACPI 2.0", &efi.acpi20},
 	{ACPI_TABLE_GUID, "ACPI", &efi.acpi},
-- 
1.7.10.4

