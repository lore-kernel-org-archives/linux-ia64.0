From: Andreas Schwab <schwab@suse.de>
Date: Wed, 07 Jan 2004 16:17:28 +0000
Subject: __ia64_memcpy_fromio my be missing from kernel
Message-Id: <je8ykjivhj.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

When building a highly modular, non-generic kernel it can happen that
arch/ia64/lib/io.o is not included in the image because nothing built-in
needs __ia64_memcpy_fromio, etc., yet it may be called from a module.  We
should force it to be linked in.

Andreas.

--- linux-2.6.0/arch/ia64/lib/Makefile.~1~	2004-01-07 14:23:16.000000000 +0=
100
+++ linux-2.6.0/arch/ia64/lib/Makefile	2004-01-07 17:08:07.000000000 +0100
@@ -2,11 +2,13 @@
 # Makefile for ia64-specific library routines..
 #
=20
+obj-y :=3D io.o
+
 lib-y :=3D __divsi3.o __udivsi3.o __modsi3.o __umodsi3.o			\
 	__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o			\
 	checksum.o clear_page.o csum_partial_copy.o copy_page.o		\
 	clear_user.o strncpy_from_user.o strlen_user.o strnlen_user.o	\
-	flush.o io.o ip_fast_csum.o do_csum.o				\
+	flush.o ip_fast_csum.o do_csum.o				\
 	memset.o strlen.o swiotlb.o
=20
 lib-$(CONFIG_ITANIUM)	+=3D copy_page.o copy_user.o memcpy.o

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
