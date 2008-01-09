From: Aron Griffis <aron@hp.com>
Date: Wed, 09 Jan 2008 03:29:38 +0000
Subject: [PATCH 3 of 3] Add /* never reached */ annotation
Message-Id: <bce918403f4c00fe3dfd.1199849378@jenkins.nashua>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

1 file changed, 2 insertions(+), 2 deletions(-)
arch/ia64/kernel/efi.c |    4 ++--


As written, this loop could be for (;;) instead of do while (md).  The tests
inside the loop always result in a return so the loop never terminates normally.

Signed-off-by: Aron Griffis <aron@hp.com>

diff -r bc50f0946b69 -r bce918403f4c arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c	Tue Jan 08 22:29:33 2008 -0500
+++ b/arch/ia64/kernel/efi.c	Tue Jan 08 22:29:33 2008 -0500
@@ -762,7 +762,7 @@ efi_mem_attribute (unsigned long phys_ad
 		if (!md || (md->attribute & ~EFI_MEMORY_RUNTIME) != attr)
 			return 0;
 	} while (md);
-	return 0;
+	return 0;	/* never reached */
 }
 
 u64
@@ -798,7 +798,7 @@ kern_mem_attribute (unsigned long phys_a
 		if (!md || md->attribute != attr)
 			return 0;
 	} while (md);
-	return 0;
+	return 0;	/* never reached */
 }
 EXPORT_SYMBOL(kern_mem_attribute);
 


