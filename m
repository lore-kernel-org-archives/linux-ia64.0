From: Andreas Schwab <schwab@suse.de>
Date: Wed, 20 Feb 2002 15:34:27 +0000
Subject: [Linux-ia64] Bug in linker script
Message-Id: <marc-linux-ia64-105590701905140@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The linker script for linking vmlinux is discarding the .text.exit
section, but not the corresponding .IA64_unwind.text.exit and
.IA64_unwind_info.text.exit sections.  This can cause dangling relocations
when compiling with gcc3.

Andreas.

--- linux/arch/ia64/vmlinux.lds.S.~1~	Tue Jul 31 19:30:09 2001
+++ linux/arch/ia64/vmlinux.lds.S	Tue Feb 19 15:34:49 2002
@@ -13,6 +13,8 @@
 	*(.text.exit)
 	*(.data.exit)
 	*(.exitcall.exit)
+	*(.IA_64.unwind.text.exit)
+	*(.IA_64.unwind_info.text.exit)
 	}
=20
   v =3D PAGE_OFFSET;	/* this symbol is here to make debugging easier... */

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

