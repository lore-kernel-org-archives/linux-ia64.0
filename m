From: Andreas Schwab <schwab@suse.de>
Date: Sun, 12 Feb 2006 16:01:35 +0000
Subject: [PATCH] Remove duplicate EXPORT_SYMBOLs
Message-Id: <jevevkwops.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Remove symbol exports from ia64_ksyms.c that are already exported in
lib/string.c.

Signed-off-by: Andreas Schwab <schwab@suse.de>

--- linux-2.6.16-rc2/arch/ia64/kernel/ia64_ksyms.c.~1~	2006-02-12 16:00:59.=
232687629 +0100
+++ linux-2.6.16-rc2/arch/ia64/kernel/ia64_ksyms.c	2006-02-12 16:05:23.7004=
47309 +0100
@@ -9,23 +9,8 @@
=20
 #include <linux/string.h>
 EXPORT_SYMBOL(memset);
-EXPORT_SYMBOL(memchr);
-EXPORT_SYMBOL(memcmp);
 EXPORT_SYMBOL(memcpy);
-EXPORT_SYMBOL(memmove);
-EXPORT_SYMBOL(memscan);
-EXPORT_SYMBOL(strcat);
-EXPORT_SYMBOL(strchr);
-EXPORT_SYMBOL(strcmp);
-EXPORT_SYMBOL(strcpy);
 EXPORT_SYMBOL(strlen);
-EXPORT_SYMBOL(strncat);
-EXPORT_SYMBOL(strncmp);
-EXPORT_SYMBOL(strncpy);
-EXPORT_SYMBOL(strnlen);
-EXPORT_SYMBOL(strrchr);
-EXPORT_SYMBOL(strstr);
-EXPORT_SYMBOL(strpbrk);
=20
 #include <asm/checksum.h>
 EXPORT_SYMBOL(ip_fast_csum);		/* hand-coded assembly */

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
