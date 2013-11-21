From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 21 Nov 2013 11:40:03 +0000
Subject: [PATCH] firmware/dmi_scan: generalize for use by other archs
Message-Id: <1385034003-32160-1-git-send-email-ard.biesheuvel@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch makes a couple of changes to the SMBIOS/DMI scanning
code so it can be used on other archs (such as ARM and arm64):
(a) wrap the calls to ioremap()/iounmap(), this allows the use of a
    flavor of ioremap() more suitable for random unaligned access;
(b) allow the non-EFI fallback probe into hardcoded physical address
    0xF0000 to be disabled.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---

@Tony: does the fallback probe make any sense at all on IA-64? It was enabled
before, so I added the #define for IA-64 as well, but perhaps we could remove it
altogether?

 arch/ia64/include/asm/dmi.h | 10 +++++++---
 arch/x86/include/asm/dmi.h  |  8 ++++++--
 drivers/firmware/dmi_scan.c | 20 +++++++++++---------
 3 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/arch/ia64/include/asm/dmi.h b/arch/ia64/include/asm/dmi.h
index 185d3d1..61e3b56 100644
--- a/arch/ia64/include/asm/dmi.h
+++ b/arch/ia64/include/asm/dmi.h
@@ -5,8 +5,12 @@
 #include <asm/io.h>
 
 /* Use normal IO mappings for DMI */
-#define dmi_ioremap ioremap
-#define dmi_iounmap(x,l) iounmap(x)
-#define dmi_alloc(l) kzalloc(l, GFP_ATOMIC)
+#define dmi_early_remap		ioremap
+#define dmi_early_unmap(x,l)	iounmap(x)
+#define dmi_remap		ioremap
+#define dmi_unmap		iounmap
+#define dmi_alloc(l)		kzalloc(l, GFP_ATOMIC)
+
+#define DMI_SCAN_MACHINE_NON_EFI_FALLBACK	1
 
 #endif
diff --git a/arch/x86/include/asm/dmi.h b/arch/x86/include/asm/dmi.h
index fd8f9e2..bb2b572 100644
--- a/arch/x86/include/asm/dmi.h
+++ b/arch/x86/include/asm/dmi.h
@@ -13,7 +13,11 @@ static __always_inline __init void *dmi_alloc(unsigned len)
 }
 
 /* Use early IO mappings for DMI because it's initialized early */
-#define dmi_ioremap early_ioremap
-#define dmi_iounmap early_iounmap
+#define dmi_early_remap		early_ioremap
+#define dmi_early_unmap		early_iounmap
+#define dmi_remap		ioremap
+#define dmi_unmap		iounmap
+
+#define DMI_SCAN_MACHINE_NON_EFI_FALLBACK	1
 
 #endif /* _ASM_X86_DMI_H */
diff --git a/drivers/firmware/dmi_scan.c b/drivers/firmware/dmi_scan.c
index fa0affb..2c7c793 100644
--- a/drivers/firmware/dmi_scan.c
+++ b/drivers/firmware/dmi_scan.c
@@ -108,7 +108,7 @@ static int __init dmi_walk_early(void (*decode)(const struct dmi_header *,
 {
 	u8 *buf;
 
-	buf = dmi_ioremap(dmi_base, dmi_len);
+	buf = dmi_early_remap(dmi_base, dmi_len);
 	if (buf = NULL)
 		return -1;
 
@@ -116,7 +116,7 @@ static int __init dmi_walk_early(void (*decode)(const struct dmi_header *,
 
 	add_device_randomness(buf, dmi_len);
 
-	dmi_iounmap(buf, dmi_len);
+	dmi_early_unmap(buf, dmi_len);
 	return 0;
 }
 
@@ -483,18 +483,19 @@ void __init dmi_scan_machine(void)
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
 	} else {
-		p = dmi_ioremap(0xF0000, 0x10000);
+#ifdef DMI_SCAN_MACHINE_NON_EFI_FALLBACK
+		p = dmi_early_remap(0xF0000, 0x10000);
 		if (p = NULL)
 			goto error;
 
@@ -510,12 +511,13 @@ void __init dmi_scan_machine(void)
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
+#endif
 	}
  error:
 	pr_info("DMI not present or invalid.\n");
@@ -787,13 +789,13 @@ int dmi_walk(void (*decode)(const struct dmi_header *, void *),
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

