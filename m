From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 27 Nov 2013 14:08:47 +0000
Subject: [PATCH v2] firmware/dmi_scan: generalize for use by other archs
Message-Id: <1385561327-8020-1-git-send-email-ard.biesheuvel@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: grant.likely@secretlab.ca, x86@kernel.org, linux-ia64@vger.kernel.org, mingo@redhat.com, tony.luck@intel.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: leif.lindholm@linaro.org, al.stone@linaro.org, yi.li@linaro.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>

This patch makes a couple of changes to the SMBIOS/DMI scanning
code so it can be used on other archs (such as ARM and arm64):
(a) wrap the calls to ioremap()/iounmap(), this allows the use of a
    flavor of ioremap() more suitable for random unaligned access;
(b) allow the non-EFI fallback probe into hardcoded physical address
    0xF0000 to be disabled.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---

Changes since v1:
- followed Grant's suggestion to use a Kconfig symbol in conjunction with
  IS_ENABLED() rather than a plain #ifdef to en-/disable the dmi scan fallback

 arch/ia64/Kconfig           |  1 +
 arch/ia64/include/asm/dmi.h |  8 +++++---
 arch/x86/Kconfig            |  1 +
 arch/x86/include/asm/dmi.h  |  6 ++++--
 drivers/firmware/Kconfig    |  3 +++
 drivers/firmware/dmi_scan.c | 20 ++++++++++----------
 6 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 4e4119b..bdb4aed 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -104,6 +104,7 @@ config HAVE_SETUP_PER_CPU_AREA
 config DMI
 	bool
 	default y
+	select DMI_SCAN_MACHINE_NON_EFI_FALLBACK
 
 config EFI
 	bool
diff --git a/arch/ia64/include/asm/dmi.h b/arch/ia64/include/asm/dmi.h
index 185d3d1..f365a61 100644
--- a/arch/ia64/include/asm/dmi.h
+++ b/arch/ia64/include/asm/dmi.h
@@ -5,8 +5,10 @@
 #include <asm/io.h>
 
 /* Use normal IO mappings for DMI */
-#define dmi_ioremap ioremap
-#define dmi_iounmap(x,l) iounmap(x)
-#define dmi_alloc(l) kzalloc(l, GFP_ATOMIC)
+#define dmi_early_remap		ioremap
+#define dmi_early_unmap(x, l)	iounmap(x)
+#define dmi_remap		ioremap
+#define dmi_unmap		iounmap
+#define dmi_alloc(l)		kzalloc(l, GFP_ATOMIC)
 
 #endif
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index e903c71..6350ab4 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -745,6 +745,7 @@ config APB_TIMER
 # The code disables itself when not needed.
 config DMI
 	default y
+	select DMI_SCAN_MACHINE_NON_EFI_FALLBACK
 	bool "Enable DMI scanning" if EXPERT
 	---help---
 	  Enabled scanning of DMI to identify machine quirks. Say Y
diff --git a/arch/x86/include/asm/dmi.h b/arch/x86/include/asm/dmi.h
index fd8f9e2..535192f 100644
--- a/arch/x86/include/asm/dmi.h
+++ b/arch/x86/include/asm/dmi.h
@@ -13,7 +13,9 @@ static __always_inline __init void *dmi_alloc(unsigned len)
 }
 
 /* Use early IO mappings for DMI because it's initialized early */
-#define dmi_ioremap early_ioremap
-#define dmi_iounmap early_iounmap
+#define dmi_early_remap		early_ioremap
+#define dmi_early_unmap		early_iounmap
+#define dmi_remap		ioremap
+#define dmi_unmap		iounmap
 
 #endif /* _ASM_X86_DMI_H */
diff --git a/drivers/firmware/Kconfig b/drivers/firmware/Kconfig
index 0747872..5a29fac 100644
--- a/drivers/firmware/Kconfig
+++ b/drivers/firmware/Kconfig
@@ -108,6 +108,9 @@ config DMI_SYSFS
 	  under /sys/firmware/dmi when this option is enabled and
 	  loaded.
 
+config DMI_SCAN_MACHINE_NON_EFI_FALLBACK
+	bool
+
 config ISCSI_IBFT_FIND
 	bool "iSCSI Boot Firmware Table Attributes"
 	depends on X86
diff --git a/drivers/firmware/dmi_scan.c b/drivers/firmware/dmi_scan.c
index c7e81ff..17afc51 100644
--- a/drivers/firmware/dmi_scan.c
+++ b/drivers/firmware/dmi_scan.c
@@ -116,7 +116,7 @@ static int __init dmi_walk_early(void (*decode)(const struct dmi_header *,
 {
 	u8 *buf;
 
-	buf = dmi_ioremap(dmi_base, dmi_len);
+	buf = dmi_early_remap(dmi_base, dmi_len);
 	if (buf = NULL)
 		return -1;
 
@@ -124,7 +124,7 @@ static int __init dmi_walk_early(void (*decode)(const struct dmi_header *,
 
 	add_device_randomness(buf, dmi_len);
 
-	dmi_iounmap(buf, dmi_len);
+	dmi_early_unmap(buf, dmi_len);
 	return 0;
 }
 
@@ -527,18 +527,18 @@ void __init dmi_scan_machine(void)
 		 * needed during early boot.  This also means we can
 		 * iounmap the space when we're done with it.
 		 */
-		p = dmi_ioremap(efi.smbios, 32);
+		p = dmi_early_remap(efi.smbios, 32);
 		if (p = NULL)
 			goto error;
 		memcpy_fromio(buf, p, 32);
-		dmi_iounmap(p, 32);
+		dmi_early_unmap(p, 32);
 
 		if (!dmi_present(buf)) {
 			dmi_available = 1;
 			goto out;
 		}
-	} else {
-		p = dmi_ioremap(0xF0000, 0x10000);
+	} else if (IS_ENABLED(CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK)) {
+		p = dmi_early_remap(0xF0000, 0x10000);
 		if (p = NULL)
 			goto error;
 
@@ -554,12 +554,12 @@ void __init dmi_scan_machine(void)
 			memcpy_fromio(buf + 16, q, 16);
 			if (!dmi_present(buf)) {
 				dmi_available = 1;
-				dmi_iounmap(p, 0x10000);
+				dmi_early_unmap(p, 0x10000);
 				goto out;
 			}
 			memcpy(buf, buf + 16, 16);
 		}
-		dmi_iounmap(p, 0x10000);
+		dmi_early_unmap(p, 0x10000);
 	}
  error:
 	pr_info("DMI not present or invalid.\n");
@@ -831,13 +831,13 @@ int dmi_walk(void (*decode)(const struct dmi_header *, void *),
 	if (!dmi_available)
 		return -1;
 
-	buf = ioremap(dmi_base, dmi_len);
+	buf = dmi_remap(dmi_base, dmi_len);
 	if (buf = NULL)
 		return -1;
 
 	dmi_table(buf, dmi_len, dmi_num, decode, private_data);
 
-	iounmap(buf);
+	dmi_unmap(buf);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(dmi_walk);
-- 
1.8.3.2

