From: Daniel Kiper <daniel.kiper@oracle.com>
Date: Mon, 30 Jun 2014 17:52:58 +0000
Subject: [PATCH v7 04/10] efi: Introduce EFI_PARAVIRT flag
Message-Id: <1404150784-27921-5-git-send-email-daniel.kiper@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1404150784-27921-1-git-send-email-daniel.kiper@oracle.com>
In-Reply-To: <1404150784-27921-1-git-send-email-daniel.kiper@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org
Cc: andrew.cooper3@citrix.com, boris.ostrovsky@oracle.com, david.vrabel@citrix.com, eshelton@pobox.com, fenghua.yu@intel.com, hpa@zytor.com, ian.campbell@citrix.com, jbeulich@suse.com, jeremy@goop.org, konrad.wilk@oracle.com, matt.fleming@intel.com, mingo@redhat.com, mjg59@srcf.ucam.org, stefano.stabellini@eu.citrix.com, tglx@linutronix.de, tony.luck@intel.com

Introduce EFI_PARAVIRT flag. If it is set then kernel runs
on EFI platform but it has not direct control on EFI stuff
like EFI runtime, tables, structures, etc. If not this means
that Linux Kernel has direct access to EFI infrastructure
and everything runs as usual.

This functionality is used in Xen dom0 because hypervisor
has full control on EFI stuff and all calls from dom0 to
EFI must be requested via special hypercall which in turn
executes relevant EFI code in behalf of dom0.

Signed-off-by: Daniel Kiper <daniel.kiper@oracle.com>
---
v6 - suggestions/fixes:
   - rename EFI_NO_DIRECT to EFI_PARAVIRT
     (suggested by David Vrabel),
   - improve code comments
     (suggested by Matt Fleming).

v5 - suggestions/fixes:
   - rename EFI_DIRECT to EFI_NO_DIRECT
     (suggested by David Vrabel),
   - limit EFI_NO_DIRECT usage
     (suggested by Jan Beulich and Matt Fleming),
   - improve commit message
     (suggested by David Vrabel).
---
 arch/x86/platform/efi/efi.c |   31 +++++++++++++++++++++++++------
 drivers/firmware/efi/efi.c  |   21 ++++++++++++---------
 include/linux/efi.h         |    3 ++-
 3 files changed, 39 insertions(+), 16 deletions(-)

diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index d2d3c41..b9c23d7 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -350,6 +350,9 @@ int __init efi_memblock_x86_reserve_range(void)
 	struct efi_info *e = &boot_params.efi_info;
 	unsigned long pmap;
 
+	if (efi_enabled(EFI_PARAVIRT))
+		return 0;
+
 #ifdef CONFIG_X86_32
 	/* Can't handle data above 4GB at this time */
 	if (e->efi_memmap_hi) {
@@ -616,14 +619,24 @@ static int __init efi_runtime_init(void)
 	 * the runtime services table so that we can grab the physical
 	 * address of several of the EFI runtime functions, needed to
 	 * set the firmware into virtual mode.
+	 *
+	 * When EFI_PARAVIRT is in force then we could not map runtime
+	 * service memory region because we do not have direct access to it.
+	 * However, runtime services are available through proxy functions
+	 * (e.g. in case of Xen dom0 EFI implementation they call special
+	 * hypercall which executes relevant EFI functions) and that is why
+	 * they are always enabled.
 	 */
-	if (efi_enabled(EFI_64BIT))
-		rv = efi_runtime_init64();
-	else
-		rv = efi_runtime_init32();
 
-	if (rv)
-		return rv;
+	if (!efi_enabled(EFI_PARAVIRT)) {
+		if (efi_enabled(EFI_64BIT))
+			rv = efi_runtime_init64();
+		else
+			rv = efi_runtime_init32();
+
+		if (rv)
+			return rv;
+	}
 
 	set_bit(EFI_RUNTIME_SERVICES, &efi.flags);
 
@@ -632,6 +645,9 @@ static int __init efi_runtime_init(void)
 
 static int __init efi_memmap_init(void)
 {
+	if (efi_enabled(EFI_PARAVIRT))
+		return 0;
+
 	/* Map the EFI memory map */
 	memmap.map = early_memremap((unsigned long)memmap.phys_map,
 				   memmap.nr_map * memmap.desc_size);
@@ -1188,6 +1204,9 @@ static void __init __efi_enter_virtual_mode(void)
 
 void __init efi_enter_virtual_mode(void)
 {
+	if (efi_enabled(EFI_PARAVIRT))
+		return;
+
 	if (efi_setup)
 		kexec_enter_virtual_mode();
 	else
diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 4fd17ca..07329d1 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -104,16 +104,19 @@ static struct attribute *efi_subsys_attrs[] = {
 static umode_t efi_attr_is_visible(struct kobject *kobj,
 				   struct attribute *attr, int n)
 {
-	umode_t mode = attr->mode;
-
-	if (attr = &efi_attr_fw_vendor.attr)
-		return (efi.fw_vendor = EFI_INVALID_TABLE_ADDR) ? 0 : mode;
-	else if (attr = &efi_attr_runtime.attr)
-		return (efi.runtime = EFI_INVALID_TABLE_ADDR) ? 0 : mode;
-	else if (attr = &efi_attr_config_table.attr)
-		return (efi.config_table = EFI_INVALID_TABLE_ADDR) ? 0 : mode;
+	if (attr = &efi_attr_fw_vendor.attr) {
+		if (efi_enabled(EFI_PARAVIRT) ||
+				efi.fw_vendor = EFI_INVALID_TABLE_ADDR)
+			return 0;
+	} else if (attr = &efi_attr_runtime.attr) {
+		if (efi.runtime = EFI_INVALID_TABLE_ADDR)
+			return 0;
+	} else if (attr = &efi_attr_config_table.attr) {
+		if (efi.config_table = EFI_INVALID_TABLE_ADDR)
+			return 0;
+	}
 
-	return mode;
+	return attr->mode;
 }
 
 static struct attribute_group efi_subsys_attr_group = {
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 41bbf8b..713a4f1 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -916,7 +916,8 @@ extern int __init efi_setup_pcdp_console(char *);
 #define EFI_RUNTIME_SERVICES	3	/* Can we use runtime services? */
 #define EFI_MEMMAP		4	/* Can we use EFI memory map? */
 #define EFI_64BIT		5	/* Is the firmware 64-bit? */
-#define EFI_ARCH_1		6	/* First arch-specific bit */
+#define EFI_PARAVIRT		6	/* Access is via a paravirt interface */
+#define EFI_ARCH_1		7	/* First arch-specific bit */
 
 #ifdef CONFIG_EFI
 /*
-- 
1.7.10.4

