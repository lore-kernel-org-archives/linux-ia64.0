From: Andreas Schwab <schwab@suse.de>
Date: Thu, 04 Apr 2002 13:36:29 +0000
Subject: Re: [Linux-ia64] pipe() not setting errno.
Message-Id: <marc-linux-ia64-105590701905377@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905376@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905376@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Anders Herbj=F8rnsen <anders.herbjornsen@start.no> writes:

|> Hello,
|>=20
|> When running out of file descriptors pipe() does return -1 but
|> errno is not set. This is working ok on IA32 systems, but fails
|> on IA64. I've tested this with kernels 2.4.9 and 2.4.18.

It's a bug in glibc, this should fix it:

2002-04-04  Andreas Schwab  <schwab@suse.de>

	* sysdeps/unix/sysv/linux/ia64/pipe.S: Don't overwrite r8 on
	error.

--- sysdeps/unix/sysv/linux/ia64/pipe.S.~1.2.~	2001-07-16 10:45:29.00000000=
0 +0200
+++ sysdeps/unix/sysv/linux/ia64/pipe.S	2002-04-04 14:35:31.000000000 +0200
@@ -1,4 +1,4 @@
-/* Copyright (C) 1999, 2000 Free Software Foundation, Inc.
+/* Copyright (C) 1999, 2000, 2002 Free Software Foundation, Inc.
    This file is part of the GNU C Library.
    Contributed by David Mosberger <davidm@hpl.hp.com>
=20
@@ -28,7 +28,7 @@
        cmp.ne p6,p0=3D-1,r10
        ;;
 (p6)   st4 [r2]=3Dr8,4
-       mov ret0=3D0
+(p6)   mov ret0=3D0
        ;;
 (p6)   st4 [r2]=3Dr9
 (p6)   ret

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

