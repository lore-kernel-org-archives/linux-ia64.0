From: Andreas Schwab <schwab@suse.de>
Date: Fri, 17 Oct 2003 11:12:07 +0000
Subject: [2.6 PATCH] Missing exported symbol
Message-Id: <marc-linux-ia64-106638921002098@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This fixes some missing symbol exports.

Andreas.

--- linux-2.6.0-test7.orig/arch/ia64/kernel/ia64_ksyms.c	2003-10-08 21:24:0=
4.000000000 +0200
+++ linux-2.6.0-test7/arch/ia64/kernel/ia64_ksyms.c	2003-10-17 13:10:43.000=
000000 +0200
@@ -41,6 +41,7 @@
 EXPORT_SYMBOL(csum_tcpudp_magic);
 EXPORT_SYMBOL(ip_compute_csum);
 EXPORT_SYMBOL(ip_fast_csum);
+EXPORT_SYMBOL(csum_partial);
=20
 #include <asm/io.h>
 EXPORT_SYMBOL(__ia64_memcpy_fromio);
@@ -61,6 +62,8 @@
 #include <asm/pgtable.h>
 EXPORT_SYMBOL(vmalloc_end);
 EXPORT_SYMBOL(ia64_pfn_valid);
+EXPORT_SYMBOL(max_low_pfn);
+EXPORT_SYMBOL(vmem_map);
 #endif
=20
 #include <asm/processor.h>
@@ -213,3 +216,7 @@
=20
 #include <linux/pm.h>
 EXPORT_SYMBOL(pm_idle);
+
+#include <linux/reboot.h>
+EXPORT_SYMBOL(machine_power_off);
+EXPORT_SYMBOL(machine_restart);

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
