From: Andreas Schwab <schwab@suse.de>
Date: Wed, 14 May 2003 14:43:24 +0000
Subject: Re: [Linux-ia64] libc umount and umount2 can't both be right
Message-Id: <marc-linux-ia64-105590723705790@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705762@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705762@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"MONTGOMERY,BOB (HP-FtCollins,ex1)" <bob.montgomery@hp.com> writes:

|> The problem:  On IA64, the implementation of umount(2) in glibc
|> and of sys_umount in the kernel results in the kernel performing
|> umounts with essentially random flag words.

[ SYS_umount is actually umount2 on ia64 ]

Here is a patch:

2003-05-14  Andreas Schwab  <schwab@suse.de>

	* sysdeps/unix/sysv/linux/ia64/umount.c: New file.

--- /dev/null	2003-03-21 07:28:43.000000000 +0100
+++ sysdeps/unix/sysv/linux/ia64/umount.c	2003-05-14 14:33:40.000000000 +02=
00
@@ -0,0 +1,31 @@
+/* umount system call for Linux/ia64.
+   Copyright (C) 2003 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, write to the Free
+   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
+   02111-1307 USA.  */
+
+#include <sys/mount.h>
+#include <errno.h>
+
+#include <sysdep.h>
+#include <bp-checks.h>
+
+/* Unmount a filesystem.  */
+int
+umount (const char *special_file)
+{
+  return INLINE_SYSCALL (umount, 2, CHECK_STRING (special_file), 0);
+}

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

