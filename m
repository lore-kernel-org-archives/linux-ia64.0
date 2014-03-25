From: Daniel Kiper <daniel.kiper@oracle.com>
Date: Tue, 25 Mar 2014 20:57:52 +0000
Subject: [PATCH v3 1/5] efi: Add efi_init_ops variable
Message-Id: <1395781076-12000-2-git-send-email-daniel.kiper@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
In-Reply-To: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org
Cc: boris.ostrovsky@oracle.com, david.vrabel@citrix.com, eshelton@pobox.com, fenghua.yu@intel.com, hpa@zytor.com, ian.campbell@citrix.com, jbeulich@suse.com, jeremy@goop.org, konrad.wilk@oracle.com, matt.fleming@intel.com, mingo@redhat.com, stefano.stabellini@eu.citrix.com, tglx@linutronix.de, tony.luck@intel.com, Daniel Kiper <daniel.kiper@oracle.com>, Tang Liang <liang.tang@oracle.com>

Add efi_init_ops variable which allows us to replace
EFI init functions on Xen with its specific stuff.

This patch is based on Jan Beulich and Tang Liang work.

Signed-off-by: Daniel Kiper <daniel.kiper@oracle.com>
Signed-off-by: Tang Liang <liang.tang@oracle.com>
---
 arch/ia64/kernel/efi.c      |   30 +++++++++++++++++++++---------
 arch/x86/platform/efi/efi.c |   18 +++++++++++++-----
 drivers/firmware/efi/efi.c  |   26 ++++++++++++++++++++++++++
 include/linux/efi.h         |    8 ++++++++
 4 files changed, 68 insertions(+), 14 deletions(-)

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index da5b462..f646374 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -468,8 +468,8 @@ efi_map_pal_code (void)
 	ia64_set_psr(psr);		/* restore psr */
 }
 
-void __init
-efi_init (void)
+static void __init
+efi_init_generic (void)
 {
 	void *efi_map_start, *efi_map_end;
 	efi_char16_t *c16;
@@ -593,8 +593,13 @@ efi_init (void)
 	efi_enter_virtual_mode();
 }
 
-void
-efi_enter_virtual_mode (void)
+static void
+efi_reserve_boot_services_generic (void)
+{
+}
+
+static void
+efi_enter_virtual_mode_generic (void)
 {
 	void *efi_map_start, *efi_map_end, *p;
 	efi_memory_desc_t *md;
@@ -751,8 +756,8 @@ efi_memmap_intersects (unsigned long phys_addr, unsigned long size)
 	return 0;
 }
 
-u32
-efi_mem_type (unsigned long phys_addr)
+static u32
+efi_mem_type_generic (unsigned long phys_addr)
 {
 	efi_memory_desc_t *md = efi_memory_descriptor(phys_addr);
 
@@ -761,8 +766,8 @@ efi_mem_type (unsigned long phys_addr)
 	return 0;
 }
 
-u64
-efi_mem_attributes (unsigned long phys_addr)
+static u64
+efi_mem_attributes_generic (unsigned long phys_addr)
 {
 	efi_memory_desc_t *md = efi_memory_descriptor(phys_addr);
 
@@ -770,7 +775,14 @@ efi_mem_attributes (unsigned long phys_addr)
 		return md->attribute;
 	return 0;
 }
-EXPORT_SYMBOL(efi_mem_attributes);
+
+struct efi_init_ops efi_init_ops = {
+	.efi_init = efi_init_generic,
+	.efi_reserve_boot_services = efi_reserve_boot_services_generic,
+	.efi_enter_virtual_mode = efi_enter_virtual_mode_generic,
+	.efi_mem_type = efi_mem_type_generic,
+	.efi_mem_attributes = efi_mem_attributes_generic
+};
 
 u64
 efi_mem_attribute (unsigned long phys_addr, unsigned long size)
diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index b97acec..e4af217 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -422,7 +422,7 @@ static void __init print_efi_memmap(void)
 #endif  /*  EFI_DEBUG  */
 }
 
-void __init efi_reserve_boot_services(void)
+static void __init efi_reserve_boot_services_generic(void)
 {
 	void *p;
 
@@ -700,7 +700,7 @@ out:
 	return ret;
 }
 
-void __init efi_init(void)
+static void __init efi_init_generic(void)
 {
 	efi_char16_t *c16;
 	char vendor[100] = "unknown";
@@ -998,7 +998,7 @@ out:
  * be passed in via setup_data. In that case runtime ranges will be mapped
  * to the same virtual addresses as the first kernel.
  */
-void __init efi_enter_virtual_mode(void)
+static void __init efi_enter_virtual_mode_generic(void)
 {
 	efi_status_t status;
 	void *new_memmap = NULL;
@@ -1085,7 +1085,7 @@ void __init efi_enter_virtual_mode(void)
 /*
  * Convenience functions to obtain memory types and attributes
  */
-u32 efi_mem_type(unsigned long phys_addr)
+static u32 efi_mem_type_generic(unsigned long phys_addr)
 {
 	efi_memory_desc_t *md;
 	void *p;
@@ -1103,7 +1103,7 @@ u32 efi_mem_type(unsigned long phys_addr)
 	return 0;
 }
 
-u64 efi_mem_attributes(unsigned long phys_addr)
+static u64 efi_mem_attributes_generic(unsigned long phys_addr)
 {
 	efi_memory_desc_t *md;
 	void *p;
@@ -1118,6 +1118,14 @@ u64 efi_mem_attributes(unsigned long phys_addr)
 	return 0;
 }
 
+struct efi_init_ops efi_init_ops = {
+	.efi_init = efi_init_generic,
+	.efi_reserve_boot_services = efi_reserve_boot_services_generic,
+	.efi_enter_virtual_mode = efi_enter_virtual_mode_generic,
+	.efi_mem_type = efi_mem_type_generic,
+	.efi_mem_attributes = efi_mem_attributes_generic
+};
+
 /*
  * Some firmware has serious problems when using more than 50% of the EFI
  * variable store, i.e. it triggers bugs that can brick machines. Ensure that
diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 4753bac..5ce75cf 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -137,6 +137,32 @@ static void generic_ops_unregister(void)
 	efivars_unregister(&generic_efivars);
 }
 
+void __init efi_init(void)
+{
+	efi_init_ops.efi_init();
+}
+
+void __init efi_reserve_boot_services(void)
+{
+	efi_init_ops.efi_reserve_boot_services();
+}
+
+void __init efi_enter_virtual_mode(void)
+{
+	efi_init_ops.efi_enter_virtual_mode();
+}
+
+u32 efi_mem_type(unsigned long phys_addr)
+{
+	return efi_init_ops.efi_mem_type(phys_addr);
+}
+
+u64 efi_mem_attributes(unsigned long phys_addr)
+{
+	return efi_init_ops.efi_mem_attributes(phys_addr);
+}
+EXPORT_SYMBOL(efi_mem_attributes);
+
 /*
  * We register the efi subsystem with the firmware subsystem and the
  * efivars subsystem with the efi subsystem, if the system was booted with
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 0a819e7..67ba1a0 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -541,6 +541,14 @@ typedef struct _efi_file_io_interface {
 
 #define EFI_INVALID_TABLE_ADDR		(~0UL)
 
+extern struct efi_init_ops {
+	void (*efi_init)(void);
+	void (*efi_reserve_boot_services)(void);
+	void (*efi_enter_virtual_mode)(void);
+	u32 (*efi_mem_type)(unsigned long phys_addr);
+	u64 (*efi_mem_attributes)(unsigned long phys_addr);
+} efi_init_ops;
+
 /*
  * All runtime access to EFI goes through this structure:
  */
-- 
1.7.10.4

