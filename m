From: Andreas Schwab <schwab@suse.de>
Date: Sat, 06 Apr 2002 16:15:42 +0000
Subject: [Linux-ia64] Modules without unwind data
Message-Id: <marc-linux-ia64-105590701905402@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The kernel cannot cope with modules without unwind data, which happens
with data-only modules like the fs/nls modules when compiling with gcc
3.1.

--- linux/include/asm-ia64/module.h.~1~	2002-03-19 21:51:32.000000000 +0100
+++ linux/include/asm-ia64/module.h	2002-04-06 18:08:41.000000000 +0200
@@ -51,6 +51,9 @@
 		return 0;
 	archdata =3D (struct archdata *)(mod->archdata_start);
=20
+	if (archdata->unw_start =3D 0)
+		return 0;
+
 	/*
 	 * Make sure the unwind pointers are sane.
 	 */

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

