From: Roel Kluin <12o3l@tiscali.nl>
Date: Sat, 03 Nov 2007 23:30:14 +0000
Subject: [PATCH] iounmap after ioremap in efi_enter_virtual_mode, file arch/ia64/kernel/efi.c
Message-Id: <472D0486.8080604@tiscali.nl>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am less certain about this one, so please review
--
Iounmap when EFI won't switch to virtual mode

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 3f7ea13..af925ab 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -585,6 +585,8 @@ efi_enter_virtual_mode (void)
 			       efi_desc_size, ia64_boot_param->efi_memdesc_version,
 			       ia64_boot_param->efi_memmap);
 	if (status != EFI_SUCCESS) {
+		if ((md->attribute & EFI_MEMORY_UC) || (md->attribute & EFI_MEMORY_WC))
+			iounmap(md->virt_addr);
 		printk(KERN_WARNING "warning: unable to switch EFI into virtual mode "
 		       "(status=%lu)\n", status);
 		return;
