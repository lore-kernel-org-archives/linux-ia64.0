From: Andreas Schwab <schwab@suse.de>
Date: Tue, 27 Aug 2002 11:15:19 +0000
Subject: [Linux-ia64] Missing EXPORT_SYMBOL
Message-Id: <marc-linux-ia64-105590701905982@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This fixes some missing symbol exports for kernel modules.

--- linux/arch/ia64/mm/Makefile.~1~
+++ linux/arch/ia64/mm/Makefile
@@ -9,6 +9,8 @@
=20
 O_TARGET :=3D mm.o
=20
+export-objs :=3D init.o
+
 obj-y	 :=3D init.o fault.o tlb.o extable.o
=20
 include $(TOPDIR)/Rules.make
--- linux/arch/ia64/mm/init.c.~1~
+++ linux/arch/ia64/mm/init.c
@@ -5,6 +5,7 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #include <linux/config.h>
+#include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
=20
@@ -40,6 +41,7 @@ static unsigned long totalram_pages;
=20
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 unsigned long vmalloc_end =3D VMALLOC_END_INIT;
+EXPORT_SYMBOL(vmalloc_end);
=20
 static struct page *vmem_map;
 static unsigned long num_dma_physpages;
@@ -475,6 +477,8 @@ ia64_page_valid (struct page *page)
 	return __get_user(byte, (char *) page) =3D 0;
 }
=20
+EXPORT_SYMBOL(ia64_page_valid);
+
 #endif /* CONFIG_VIRTUAL_MEM_MAP */
=20
 static int

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

