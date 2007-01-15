From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 15 Jan 2007 16:33:55 +0000
Subject: [PATCH] remove bogus prototype
Message-Id: <1168878835.14363.355.camel@bling>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   This function doesn't exist.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

diff -r b1128b48dc99 include/asm-ia64/esi.h
--- a/include/asm-ia64/esi.h	Fri Jan 12 20:00:03 2007 +0000
+++ b/include/asm-ia64/esi.h	Mon Jan 15 09:15:24 2007 -0700
@@ -19,7 +19,6 @@ enum esi_proc_type {
 	ESI_PROC_REENTRANT	/* MP-safe and reentrant */
 };
 
-extern int ia64_esi_init (void);
 extern struct ia64_sal_retval esi_call_phys (void *, u64 *);
 extern int ia64_esi_call(efi_guid_t, struct ia64_sal_retval *,
 			 enum esi_proc_type,


