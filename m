From: Aron Griffis <aron@hp.com>
Date: Wed, 12 Dec 2007 15:07:50 +0000
Subject: [PATCH 3 of 4] Add /* never reached */ annotation
Message-Id: <cc913b598bc641c5584b.1197472070@jenkins.nashua>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

# HG changeset patch
# User Aron Griffis <aron@hp.com>
# Date 1197470595 18000
# Node ID cc913b598bc641c5584bff8ad379d4e213367076
# Parent  049467433cda01769d2f8c276fcfeb7d216658d7
Add /* never reached */ annotation

As written, this loop could be for (;;) instead of do while (md).  The
tests inside the loop always result in a return so the loop never
terminates by the while() test.  This annotation hopefully points that out.

Signed-off-by: Aron Griffis <aron@hp.com>

diff -r 049467433cda -r cc913b598bc6 arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c	Wed Dec 12 09:41:03 2007 -0500
+++ b/arch/ia64/kernel/efi.c	Wed Dec 12 09:43:15 2007 -0500
@@ -768,7 +768,7 @@ efi_mem_attribute (unsigned long phys_ad
 		if (!md || (md->attribute & ~EFI_MEMORY_RUNTIME) != attr)
 			return 0;
 	} while (md);
-	return 0;
+	return 0;	/* never reached */
 }
 
 u64
@@ -804,7 +804,7 @@ kern_mem_attribute (unsigned long phys_a
 		if (!md || md->attribute != attr)
 			return 0;
 	} while (md);
-	return 0;
+	return 0;	/* never reached */
 }
 EXPORT_SYMBOL(kern_mem_attribute);
 


