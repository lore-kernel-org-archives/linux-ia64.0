From: Andreas Schwab <schwab@suse.de>
Date: Mon, 05 Apr 2004 14:00:54 +0000
Subject: Missing include in hugetlbpage.c
Message-Id: <jesmfi7cdl.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This fixes a missing include file in arch/ia64/mm/hugetlbpage.c in 2.6.5.

Andreas.

--- linux-2.6.5/arch/ia64/mm/hugetlbpage.c.~1~	2004-04-05 14:56:14.08517919=
6 +0200
+++ linux-2.6.5/arch/ia64/mm/hugetlbpage.c	2004-04-05 15:06:44.868178163 +0=
200
@@ -9,6 +9,7 @@
  */
=20
 #include <linux/config.h>
+#include <linux/module.h>
 #include <linux/init.h>
 #include <linux/fs.h>
 #include <linux/mm.h>

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
