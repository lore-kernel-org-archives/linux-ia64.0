From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 12 Apr 2004 17:07:22 +0000
Subject: [PATCH] Allow IO port space without EFI RT attribute
Message-Id: <200404121107.22109.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some firmware does not require run-time mapping of the legacy IO port
space.  (It may not need to perform any IO port operations, or it may
do them with translation disabled.)

(efi_get_iobase): Don't require that IO port space be marked RT, since
	there's no reason the firmware should require mappings for it.
	Thanks to Greg Albrecht for noticing this.

	Also, allow attributes in addition to EFI_MEMORY_UC.  I can't
	think of another current attribute that makes sense, but the
	kernel only depends on being able to use UC.

=== arch/ia64/kernel/efi.c 1.18 vs edited ==--- 1.18/arch/ia64/kernel/efi.c	Wed Jan 14 17:12:30 2004
+++ edited/arch/ia64/kernel/efi.c	Mon Apr 12 10:21:11 2004
@@ -673,8 +673,7 @@
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
 		if (md->type = EFI_MEMORY_MAPPED_IO_PORT_SPACE) {
-			/* paranoia attribute checking */
-			if (md->attribute = (EFI_MEMORY_UC | EFI_MEMORY_RUNTIME))
+			if (md->attribute & EFI_MEMORY_UC)
 				return md->phys_addr;
 		}
 	}
