From: Andreas Schwab <schwab@suse.de>
Date: Tue, 06 Aug 2002 20:40:36 +0000
Subject: Re: [Linux-ia64] utime emulation
Message-Id: <marc-linux-ia64-105590701905920@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905917@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905917@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Wichmann, Mats D" <mats.d.wichmann@intel.com> writes:

|> I'm finding that utime(filename, NULL) doesn't
|> follow specs - this comes up in plodding through
|> the LSB certification test suite.
|>=20
|> For example, if the process does not own the
|> file but has write permission, the above
|> referenced call should succeed but fails with EPERM.
|>=20
|> utime() is emulated on Itanium: in the kernel,
|> fs/open.c doesn't have a sys_utime routine=20
|> if __ia64__ or alpha; the emulation comes from
|> glibc's sysdeps/unix/utime.c but appears to
|> be bogus.  The problem is that if the second
|> argument to utime is NULL the emulation code
|> does some work to build up a "struct timeval"
|> array as expected by utimes(), and passes that
|> off, instead of passing NULL... and so the
|> proper checks in the NULL case don't get done
|> by the kernel.
|>=20
|> I guess this is a query to see if anyone
|> on this list knows anything about this code.
|> Is this just a glibc problem,

Yes.  Here is a patch:

2002-08-06  Andreas Schwab  <schwab@suse.de>

	* sysdeps/unix/utime.c: If TIMES is NULL pass it through to
	utimes.

--- sysdeps/unix/utime.c.~1.3.~	2001-07-16 10:45:00.000000000 +0200
+++ sysdeps/unix/utime.c	2002-08-06 22:29:53.000000000 +0200
@@ -1,4 +1,4 @@
-/* Copyright (C) 1991, 1994, 1997 Free Software Foundation, Inc.
+/* Copyright (C) 1991, 1994, 1997, 2002 Free Software Foundation, Inc.
    This file is part of the GNU C Library.
=20
    The GNU C Library is free software; you can redistribute it and/or
@@ -31,7 +31,7 @@ utime (file, times)
      const char *file;
      const struct utimbuf *times;
 {
-  struct timeval timevals[2];
+  struct timeval timevals[2], *tvp;
=20
   if (times !=3D NULL)
     {
@@ -39,13 +39,10 @@ utime (file, times)
       timevals[0].tv_usec =3D 0L;
       timevals[1].tv_sec =3D (long int) times->modtime;
       timevals[1].tv_usec =3D 0L;
+      tvp =3D timevals;
     }
   else
-    {
-      if (__gettimeofday (&timevals[0], NULL) < 0)
-	return -1;
-      timevals[1] =3D timevals[0];
-    }
+    tvp =3D NULL;
=20
-  return __utimes (file, timevals);
+  return __utimes (file, tvp);
 }

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

