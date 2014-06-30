From: Daniel Kiper <daniel.kiper@oracle.com>
Date: Mon, 30 Jun 2014 17:52:56 +0000
Subject: [PATCH v7 02/10] efi: Use early_mem*() instead of early_io*()
Message-Id: <1404150784-27921-3-git-send-email-daniel.kiper@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1404150784-27921-1-git-send-email-daniel.kiper@oracle.com>
In-Reply-To: <1404150784-27921-1-git-send-email-daniel.kiper@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org
Cc: andrew.cooper3@citrix.com, boris.ostrovsky@oracle.com, david.vrabel@citrix.com, eshelton@pobox.com, fenghua.yu@intel.com, hpa@zytor.com, ian.campbell@citrix.com, jbeulich@suse.com, jeremy@goop.org, konrad.wilk@oracle.com, matt.fleming@intel.com, mingo@redhat.com, mjg59@srcf.ucam.org, stefano.stabellini@eu.citrix.com, tglx@linutronix.de, tony.luck@intel.com

Use early_mem*() instead of early_io*() because all mapped EFI regions
are memory (usually RAM but they could also be ROM, EPROM, EEPROM, flash,
etc.) not I/O regions. Additionally, I/O family calls do not work correctly
under Xen in our case. early_ioremap() skips the PFN to MFN conversion
when building the PTE. Using it for memory will attempt to map the wrong
machine frame. However, all artificial EFI structures created under Xen
live in dom0 memory and should be mapped/unmapped using early_mem*() family
calls which map domain memory.

Signed-off-by: Daniel Kiper <daniel.kiper@oracle.com>
---
v6 - suggestions/fixes:
   - improve commit message
     (suggested by Matthew Garrett and Matt Fleming),
   - do not change indentation
     (suggested by Matt Fleming).
---
 arch/x86/platform/efi/efi.c |   32 ++++++++++++++++----------------
 drivers/firmware/efi/efi.c  |    4 ++--
 2 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index 87fc96b..0ee1f46 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -427,7 +427,7 @@ void __init efi_unmap_memmap(void)
 {
 	clear_bit(EFI_MEMMAP, &efi.flags);
 	if (memmap.map) {
-		early_iounmap(memmap.map, memmap.nr_map * memmap.desc_size);
+		early_memunmap(memmap.map, memmap.nr_map * memmap.desc_size);
 		memmap.map = NULL;
 	}
 }
@@ -467,12 +467,12 @@ static int __init efi_systab_init(void *phys)
 			if (!data)
 				return -ENOMEM;
 		}
-		systab64 = early_ioremap((unsigned long)phys,
+		systab64 = early_memremap((unsigned long)phys,
 					 sizeof(*systab64));
 		if (systab64 = NULL) {
 			pr_err("Couldn't map the system table!\n");
 			if (data)
-				early_iounmap(data, sizeof(*data));
+				early_memunmap(data, sizeof(*data));
 			return -ENOMEM;
 		}
 
@@ -504,9 +504,9 @@ static int __init efi_systab_init(void *phys)
 					   systab64->tables;
 		tmp |= data ? data->tables : systab64->tables;
 
-		early_iounmap(systab64, sizeof(*systab64));
+		early_memunmap(systab64, sizeof(*systab64));
 		if (data)
-			early_iounmap(data, sizeof(*data));
+			early_memunmap(data, sizeof(*data));
 #ifdef CONFIG_X86_32
 		if (tmp >> 32) {
 			pr_err("EFI data located above 4GB, disabling EFI.\n");
@@ -516,7 +516,7 @@ static int __init efi_systab_init(void *phys)
 	} else {
 		efi_system_table_32_t *systab32;
 
-		systab32 = early_ioremap((unsigned long)phys,
+		systab32 = early_memremap((unsigned long)phys,
 					 sizeof(*systab32));
 		if (systab32 = NULL) {
 			pr_err("Couldn't map the system table!\n");
@@ -537,7 +537,7 @@ static int __init efi_systab_init(void *phys)
 		efi_systab.nr_tables = systab32->nr_tables;
 		efi_systab.tables = systab32->tables;
 
-		early_iounmap(systab32, sizeof(*systab32));
+		early_memunmap(systab32, sizeof(*systab32));
 	}
 
 	efi.systab = &efi_systab;
@@ -563,7 +563,7 @@ static int __init efi_runtime_init32(void)
 {
 	efi_runtime_services_32_t *runtime;
 
-	runtime = early_ioremap((unsigned long)efi.systab->runtime,
+	runtime = early_memremap((unsigned long)efi.systab->runtime,
 			sizeof(efi_runtime_services_32_t));
 	if (!runtime) {
 		pr_err("Could not map the runtime service table!\n");
@@ -578,7 +578,7 @@ static int __init efi_runtime_init32(void)
 	efi_phys.set_virtual_address_map  			(efi_set_virtual_address_map_t *)
 			(unsigned long)runtime->set_virtual_address_map;
-	early_iounmap(runtime, sizeof(efi_runtime_services_32_t));
+	early_memunmap(runtime, sizeof(efi_runtime_services_32_t));
 
 	return 0;
 }
@@ -587,7 +587,7 @@ static int __init efi_runtime_init64(void)
 {
 	efi_runtime_services_64_t *runtime;
 
-	runtime = early_ioremap((unsigned long)efi.systab->runtime,
+	runtime = early_memremap((unsigned long)efi.systab->runtime,
 			sizeof(efi_runtime_services_64_t));
 	if (!runtime) {
 		pr_err("Could not map the runtime service table!\n");
@@ -602,7 +602,7 @@ static int __init efi_runtime_init64(void)
 	efi_phys.set_virtual_address_map  			(efi_set_virtual_address_map_t *)
 			(unsigned long)runtime->set_virtual_address_map;
-	early_iounmap(runtime, sizeof(efi_runtime_services_64_t));
+	early_memunmap(runtime, sizeof(efi_runtime_services_64_t));
 
 	return 0;
 }
@@ -633,7 +633,7 @@ static int __init efi_runtime_init(void)
 static int __init efi_memmap_init(void)
 {
 	/* Map the EFI memory map */
-	memmap.map = early_ioremap((unsigned long)memmap.phys_map,
+	memmap.map = early_memremap((unsigned long)memmap.phys_map,
 				   memmap.nr_map * memmap.desc_size);
 	if (memmap.map = NULL) {
 		pr_err("Could not map the memory map!\n");
@@ -697,10 +697,10 @@ static int __init efi_reuse_config(u64 tables, int nr_tables)
 			((efi_config_table_64_t *)p)->table = data->smbios;
 		p += sz;
 	}
-	early_iounmap(tablep, nr_tables * sz);
+	early_memunmap(tablep, nr_tables * sz);
 
 out_memremap:
-	early_iounmap(data, sizeof(*data));
+	early_memunmap(data, sizeof(*data));
 out:
 	return ret;
 }
@@ -737,14 +737,14 @@ void __init efi_init(void)
 	/*
 	 * Show what we know for posterity
 	 */
-	c16 = tmp = early_ioremap(efi.systab->fw_vendor, 2);
+	c16 = tmp = early_memremap(efi.systab->fw_vendor, 2);
 	if (c16) {
 		for (i = 0; i < sizeof(vendor) - 1 && *c16; ++i)
 			vendor[i] = *c16++;
 		vendor[i] = '\0';
 	} else
 		pr_err("Could not map the firmware vendor!\n");
-	early_iounmap(tmp, 2);
+	early_memunmap(tmp, 2);
 
 	pr_info("EFI v%u.%.02u by %s\n",
 		efi.systab->hdr.revision >> 16,
diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index eff1a2f..4fd17ca 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -298,7 +298,7 @@ int __init efi_config_init(efi_config_table_type_t *arch_tables)
 			if (table64 >> 32) {
 				pr_cont("\n");
 				pr_err("Table located above 4GB, disabling EFI.\n");
-				early_iounmap(config_tables,
+				early_memunmap(config_tables,
 					       efi.systab->nr_tables * sz);
 				return -EINVAL;
 			}
@@ -314,7 +314,7 @@ int __init efi_config_init(efi_config_table_type_t *arch_tables)
 		tablep += sz;
 	}
 	pr_cont("\n");
-	early_iounmap(config_tables, efi.systab->nr_tables * sz);
+	early_memunmap(config_tables, efi.systab->nr_tables * sz);
 
 	set_bit(EFI_CONFIG_TABLES, &efi.flags);
 
-- 
1.7.10.4

