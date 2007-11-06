From: Roel Kluin <12o3l@tiscali.nl>
Date: Tue, 06 Nov 2007 21:13:53 +0000
Subject: [PATCH] fix number of bytes zeroed by sys_fw_init() in arch/ia64/hp/sim/boot/fw-emu.c
Message-Id: <4730D911.9010701@tiscali.nl>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The sizeof a pointer is constant, we want the sizeof what is pointed to.
--
Zero out 'sizeof(*efi_systab)' bytes of the efi_system_table_t pointer
'efi_systab' instead.

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/arch/ia64/hp/sim/boot/fw-emu.c b/arch/ia64/hp/sim/boot/fw-emu.c
index 1189d03..bf6d9d8 100644
--- a/arch/ia64/hp/sim/boot/fw-emu.c
+++ b/arch/ia64/hp/sim/boot/fw-emu.c
@@ -285,7 +285,7 @@ sys_fw_init (const char *args, int arglen)
 	}
 	cmd_line[arglen] = '\0';
 
-	memset(efi_systab, 0, sizeof(efi_systab));
+	memset(efi_systab, 0, sizeof(*efi_systab));
 	efi_systab->hdr.signature = EFI_SYSTEM_TABLE_SIGNATURE;
 	efi_systab->hdr.revision  = ((1 << 16) | 00);
 	efi_systab->hdr.headersize = sizeof(efi_systab->hdr);
