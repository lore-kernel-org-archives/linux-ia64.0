From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 30 Nov 2006 00:53:35 +0000
Subject: Resolve name clash in 2.6.19-rc6-mm2 by naming is_available_memory
Message-Id: <Pine.LNX.4.64.0611291651530.18636@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is a name clash with ia64 arch code in Andrew's tree. Rename

is_avialable_memory to is_memory_available to avoid the clash.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc6-mm2/arch/ia64/kernel/efi.c
=================================--- linux-2.6.19-rc6-mm2.orig/arch/ia64/kernel/efi.c	2006-11-29 18:36:28.879625138 -0600
+++ linux-2.6.19-rc6-mm2/arch/ia64/kernel/efi.c	2006-11-29 18:41:43.882576353 -0600
@@ -225,7 +225,7 @@ efi_gettimeofday (struct timespec *ts)
 }
 
 static int
-is_available_memory (efi_memory_desc_t *md)
+is_memory_available (efi_memory_desc_t *md)
 {
 	if (!(md->attribute & EFI_MEMORY_WB))
 		return 0;
@@ -892,7 +892,7 @@ find_memmap_space (void)
 			}
 			contig_high = GRANULEROUNDDOWN(contig_high);
 		}
-		if (!is_available_memory(md) || md->type = EFI_LOADER_DATA)
+		if (!is_memory_available(md) || md->type = EFI_LOADER_DATA)
 			continue;
 
 		/* Round ends inward to granule boundaries */
@@ -968,7 +968,7 @@ efi_memmap_init(unsigned long *s, unsign
 			}
 			contig_high = GRANULEROUNDDOWN(contig_high);
 		}
-		if (!is_available_memory(md))
+		if (!is_memory_available(md))
 			continue;
 
 		/*
