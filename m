From: Andreas Schwab <schwab@suse.de>
Date: Fri, 12 Apr 2002 15:05:37 +0000
Subject: [Linux-ia64] Missing EXPORT_SYMBOL memset
Message-Id: <marc-linux-ia64-105590701905441@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

GCC 3 may generate calls to memset, so we need to export it to modules.
For example, lvm requires it now, referenced from lvm.c:lvm_do_vg_rename.

--- linux/arch/ia64/kernel/ia64_ksyms.c.~1~	2002-04-11 12:02:05.000000000 +=
0200
+++ linux/arch/ia64/kernel/ia64_ksyms.c	2002-04-11 17:40:21.000000000 +0200
@@ -27,6 +27,10 @@
 EXPORT_SYMBOL(strtok);
 EXPORT_SYMBOL(strpbrk);
=20
+#undef memset
+extern void *memset(void *, int, size_t);
+EXPORT_SYMBOL_NOVERS(memset);
+
 #include <linux/irq.h>
 EXPORT_SYMBOL(isa_irq_to_vector_map);
 EXPORT_SYMBOL(enable_irq);

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

